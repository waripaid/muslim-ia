const axios = require('axios');
const http = require('http');
const https = require('https');
const { SYSTEM_PROMPTS } = require('./system_prompts');
const { MODES } = require('../config/constants');
const logger = require('../utils/logger');
const {
  searchQuranComplete,
  fetchVerseComplete,
  fetchTranslation,
  fetchTafsir,
  fetchQuran,
  initializeMcp,
} = require('./mcp_quran');

const TRYIA_API_URL = process.env.TRYIA_API_URL || 'http://10.183.76.91:8000';
const MISTRAL_API_URL = 'https://api.mistral.ai/v1/chat/completions';

// Connexions HTTP(S) réutilisées (keep-alive) : évite un handshake TLS + une
// prise de socket par requête. Améliore fortement le débit sous charge.
const MISTRAL_AGENT = new https.Agent({
  keepAlive: true,
  maxSockets: 50,
  maxFreeSockets: 20,
  keepAliveMsecs: 30000,
});
const TRYIA_AGENT = new http.Agent({
  keepAlive: true,
  maxSockets: 50,
  keepAliveMsecs: 30000,
});

let mcpReady = false;
let tryiaAvailable = false;

async function checkTryiaHealth() {
  try {
    await axios.get(`${TRYIA_API_URL}/health`, { timeout: 2000 });
    tryiaAvailable = true;
    console.log('✓ TRYIA agent connecté');
  } catch {
    tryiaAvailable = false;
    console.log('⚠ TRYIA injoignable → utilisation directe de Mistral');
  }
}

async function ensureMcpReady() {
  if (mcpReady) return;
  try {
    await initializeMcp();
    mcpReady = true;
    console.log('✓ MCP Quran connecté');
  } catch (e) {
    console.warn('⚠ MCP Quran non disponible:', e.message);
  }
}

/**
 * Détecte si la question concerne le Coran
 */
function isQuranQuestion(question) {
  const keywords = [
    'coran', 'quran', 'verset', 'sourate', 'ayat', 'allah',
    'islam', 'coranique', 'tafsir', 'exégèse', 'récitation',
    'sourate', 'fatiha', 'bakara', 'versets', 'prophète',
    'mohammed', 'muhammad', 'révélation', 'hadith', 'sunnah',
    'بِسْمِ', 'القرآن', 'سورة', 'آية', 'الله', 'حَدِيث',
  ];
  const lower = question.toLowerCase();
  return keywords.some((k) => lower.includes(k));
}

/**
 * Extrait les références de versets d'une question (ex: "2:255", "sourate 1 verset 1")
 */
function extractReferences(question) {
  const refs = [];
  const patterns = [
    /(\d+)[:\s]*(\d+)(?:\s*[-–]\s*(\d+))?/g,
    /sourate\s+(\d+)\s+verset[s]?\s+(\d+)/gi,
    /ayat\s+(\d+)[:\s](\d+)/gi,
  ];

  for (const pattern of patterns) {
    let match;
    while ((match = pattern.exec(question)) !== null) {
      if (match[3]) {
        refs.push(`${match[1]}:${match[2]}-${match[3]}`);
      } else {
        refs.push(`${match[1]}:${match[2]}`);
      }
    }
  }

  return [...new Set(refs)];
}

/**
 * Appelle l'agent Mistral avec grounding MCP Quran
 */
async function callMistralAgent({ question, mode = 'general', history = [], userId = null }) {
  await ensureMcpReady();

  const systemPrompt = getSystemPrompt(mode);
  let quranContext = null;
  let sources = [];

  // Si la question concerne le Coran, récupérer les sources MCP
  if (mcpReady && isQuranQuestion(question)) {
    quranContext = await fetchQuranContext(question);
    if (quranContext?.sources) {
      sources = quranContext.sources;
    }
  }

  const messages = [
    { role: 'system', content: systemPrompt },
    ...history
      .filter((msg) => msg && typeof (msg.content || '') === 'string' && msg.content.trim().length > 0)
      .map((msg) => ({
        role: msg.role,
        content: msg.content,
      })),
    { role: 'user', content: question },
  ];

  // Injecter le contexte Quran dans le prompt utilisateur (sans révéler sa provenance)
  if (quranContext?.text) {
    const lastUserMsg = messages[messages.length - 1];
    lastUserMsg.content = `${lastUserMsg.content}\n\n--- RÉFÉRENCES ---\n${quranContext.text}\n--- FIN DES RÉFÉRENCES ---\n\nRéponds UNIQUEMENT en te basant sur ces références. Cite chaque sourate et verset. Si les références ne contiennent pas la réponse, dis-le. Ne révèle jamais d'où proviennent ces références.`;
  }

  try {
    // Ne jamais attendre 3 s sur un endpoint TRYIA connu mort : on passe
    // directement à Mistral (fallback). tryiaAvailable est maintenu par le
    // health check et rafraîchi à chaque échec.
    if (tryiaAvailable) {
      const response = await axios.post(
        `${TRYIA_API_URL}/chat`,
        {
          messages,
          mode,
          user_id: userId,
        },
        {
          headers: {
            'Content-Type': 'application/json',
            'X-API-Key': process.env.MISTRAL_API_KEY,
          },
          timeout: 3000, // 3 secondes pour TRYIA, puis fallback
          httpAgent: TRYIA_AGENT,
        }
      );

      return {
        answer: response.data.answer || response.data.content || response.data.message,
        sources: response.data.sources?.length ? response.data.sources : sources,
        usage: response.data.usage || {},
        grounded: quranContext !== null,
      };
    }
  } catch (error) {
    console.error('Erreur appel agent Mistral:', error.message);
    tryiaAvailable = false; // évite de réessayer un endpoint HS à chaque requête
  }
  return await callMistralDirect({ messages, mode, sources });
}

/**
 * Récupère le contexte Quran via MCP
 */
async function fetchQuranContext(question) {
  const refs = extractReferences(question);
  const results = [];
  const allSources = [];

  // Si des références explicites sont trouvées
  for (const ref of refs) {
    try {
      const verseComplete = await fetchVerseComplete(ref);
      if (verseComplete) {
        const source = {
          sourate: ref.split(':')[0],
          verset: ref.split(':')[1],
          texte_arabe: verseComplete.arabe,
          traduction: verseComplete.traduction,
        };
        allSources.push(source);
        results.push(
          `📖 Sourate ${ref}:\n` +
          `Arabe: ${verseComplete.arabe}\n` +
          `Traduction (Hamidullah): ${verseComplete.traduction}\n` +
          (verseComplete.tafsir ? `Tafsir (Tabari): ${verseComplete.tafsir}\n` : '')
        );
      }
    } catch (e) {
      console.warn(`Erreur verset ${ref}:`, e.message);
    }
  }

  // Recherche thématique si pas de référence explicite
  if (refs.length === 0) {
    try {
      const searchResult = await searchQuranComplete(question);
      if (searchResult?.results) {
        results.push(`🔍 Recherche "${question}":\n${searchResult.results}`);
      }
    } catch (e) {
      console.warn('Erreur recherche Quran:', e.message);
    }
  }

  if (results.length === 0) return null;

  return {
    text: results.join('\n\n'),
    sources: allSources,
  };
}

/**
 * Fallback simple (non-streaming)
 */
async function callMistralDirect({ messages, sources = [] }) {
  const response = await axios.post(MISTRAL_API_URL, {
    model: 'mistral-small-latest', messages, temperature: 0.7, max_tokens: 2000,
  }, {
    headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${process.env.MISTRAL_API_KEY}` },
    timeout: 45000,
    httpsAgent: MISTRAL_AGENT,
  });
  return { answer: response.data.choices[0].message.content, sources, usage: response.data.usage || {}, grounded: false };
}

/**
 * Fallback : appelle directement l'API Mistral avec streaming.
 * Gère la backpressure (ne bufferise pas à l'infini) et libère la connexion
 * upstream dès que le client se déconnecte.
 */
async function callMistralDirectStream({ messages, res }) {
  const controller = new AbortController();

  // Le client a fermé (page quittée, réseau coupé) → coupe immédiatement le
  // flux Mistral et libère les sockets au lieu d'écrire dans le vide.
  res.on('close', () => {
    if (!res.writableEnded) controller.abort();
  });

  // Envoie immédiatement les en-têtes SSE au client : la connexion est établie
  // tout de suite (l'app ne timeout plus sur client.send) pendant que Mistral
  // prépare le premier token.
  res.setHeader('Content-Type', 'text/event-stream');
  res.setHeader('Cache-Control', 'no-cache');
  res.setHeader('Connection', 'keep-alive');
  res.setHeader('X-Accel-Buffering', 'no');
  res.flushHeaders?.();

  let buffer = '';
  let finished = false;

  // Écrit en respectant la backpressure : si le client est plus lent que
  // Mistral, on met l'upstream en pause pour ne pas saturer la mémoire.
  const write = (data) => {
    if (finished) return;
    const ok = res.write(data);
    if (!ok && response?.data) response.data.pause();
  };
  res.on('drain', () => {
    if (!finished && response?.data) response.data.resume();
  });

  const finish = () => {
    if (finished) return;
    finished = true;
    clearInterval(keepAlive);
    try {
      res.end();
    } catch (_) {}
  };

  let response;
  // Une seule relance pour les erreurs transitoires (timeout réseau, 5xx,
  // cold start du fournisseur) avant de remonter l'erreur au client.
  for (let attempt = 0; attempt < 2; attempt++) {
    try {
      response = await axios.post(
        MISTRAL_API_URL,
        {
          model: 'mistral-small-latest',
          messages,
          temperature: 0.7,
          max_tokens: 4096,
          stream: true,
        },
        {
          headers: {
            'Content-Type': 'application/json',
            Authorization: `Bearer ${process.env.MISTRAL_API_KEY}`,
          },
          timeout: 60000,
          responseType: 'stream',
          signal: controller.signal,
          httpsAgent: MISTRAL_AGENT,
        }
      );
      break;
    } catch (error) {
      // Abort volontaire (client déconnecté) → ne rien envoyer.
      if (error.name === 'CanceledError' || error.code === 'ERR_CANCELED' || controller.signal.aborted) {
        try {
          res.end();
        } catch (_) {}
        return;
      }
      const status = error.response?.status;
      const transient = !status || status === 408 || status === 429 || status >= 500;
      if (attempt === 0 && transient) {
        console.error(`Stream setup error (retry ${attempt + 1}/2):`, error.message);
        await new Promise((resolve) => setTimeout(resolve, 1000));
        continue;
      }
      console.error('Stream setup error:', error.message);
      try {
        res.write(`data: ${JSON.stringify({ error: error.message })}\n\n`);
        res.end();
      } catch (_) {}
      return;
    }
  }

  // Keep-alive SSE : envoie un commentaire toutes les 10 s pour empêcher les
  // proxys/load-balancers de fermer la connexion pendant une génération longue.
  const keepAlive = setInterval(() => {
    if (!finished) {
      try {
        res.write(': ping\n\n');
      } catch (_) {}
    }
  }, 10000);

  response.data.on('data', (chunk) => {
    buffer += chunk.toString();
    const lines = buffer.split('\n');
    buffer = lines.pop() || '';

    for (const line of lines) {
      if (line.startsWith('data: ')) {
        const data = line.slice(6).trim();
        if (data === '[DONE]') {
          write('data: [DONE]\n\n');
          continue;
        }
        try {
          const parsed = JSON.parse(data);
          const content = parsed.choices?.[0]?.delta?.content || '';
          const finishReason = parsed.choices?.[0]?.finish_reason;
          if (content) {
            write(`data: ${JSON.stringify({ text: content })}\n\n`);
          }
          if (finishReason === 'length') {
            write('data: {"truncated":true}\n\n');
          }
        } catch (_) {
          // skip unparseable chunks
        }
      }
    }
  });

  response.data.on('end', () => {
    write('data: [DONE]\n\n');
    finish();
  });

  response.data.on('error', (err) => {
    console.error('Stream error:', err.message);
    try {
      res.write(`data: ${JSON.stringify({ error: err.message })}\n\n`);
    } catch (_) {}
    finish();
  });
}

module.exports = {
  callMistralAgent,
  callMistralDirect,
  callMistralDirectStream,
  healthCheck,
  getSystemPrompt,
};

/**
 * Sélectionne le prompt système selon le mode
 */
function getSystemPrompt(mode) {
  switch (mode) {
    case MODES.CHAT:
    case 'general':
      return SYSTEM_PROMPTS.GENERAL;
    case MODES.LEARN:
    case MODES.ARABIC_TEACHER:
      return SYSTEM_PROMPTS.ARABIC;
    case MODES.QUIZ:
      return SYSTEM_PROMPTS.QUIZ;
    case MODES.MEMORIZE:
      return SYSTEM_PROMPTS.MEMORIZE;
    case MODES.DAILY_LESSON:
      return SYSTEM_PROMPTS.DAILY_LESSON;
    default:
      return SYSTEM_PROMPTS.QURAN;
  }
}

/**
 * Vérifie les connexions
 */
async function healthCheck() {
  await ensureMcpReady();

  try {
    await axios.get(`${TRYIA_API_URL}/health`, { timeout: 5000 });
    return { online: true, provider: 'tryia', mcp: mcpReady };
  } catch {
    try {
      await axios.get('https://api.mistral.ai/v1/models', {
        headers: { Authorization: `Bearer ${process.env.MISTRAL_API_KEY}` },
        timeout: 5000,
      });
      return { online: true, provider: 'mistral_direct', mcp: mcpReady };
    } catch {
      return { online: false, provider: null, mcp: mcpReady };
    }
  }
}
