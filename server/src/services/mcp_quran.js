const axios = require('axios');

const MCP_URL = 'https://mcp.quran.ai';
let sessionId = null;

// Cache en mémoire avec TTL pour les réponses Coran (données statiques).
// Sous forte charge, des milliers d'utilisateurs demandent souvent les mêmes
// versets : le cache évite de marteler le serveur MCP externe.
const CACHE_TTL_MS = 12 * 60 * 60 * 1000; // 12 heures
const MAX_CACHE_ENTRIES = 5000;
const cache = new Map(); // key -> { value, expiresAt }
const inFlight = new Map(); // key -> Promise (déduplique les appels concurrents)

function cacheGet(key) {
  const hit = cache.get(key);
  if (!hit) return undefined;
  if (hit.expiresAt > Date.now()) return hit.value;
  cache.delete(key);
  return undefined;
}

function cacheSet(key, value) {
  cache.set(key, { value, expiresAt: Date.now() + CACHE_TTL_MS });
  if (cache.size > MAX_CACHE_ENTRIES) {
    // Éviction simple : supprime les entrées les plus anciennes.
    const oldestKey = cache.keys().next().value;
    if (oldestKey !== undefined) cache.delete(oldestKey);
  }
}

function cacheKey(parts) {
  return parts.join('|');
}

/**
 * Récupère une valeur en passant par le cache, ou via la fonction fournie.
 * Déduplique les appels concurrents sur la même clé (anti-cache stampede).
 */
async function cached(key, fetcher) {
  const hit = cacheGet(key);
  if (hit !== undefined) return hit;

  const pending = inFlight.get(key);
  if (pending) return pending;

  const promise = fetcher()
    .then((value) => {
      if (value !== undefined && value !== null) cacheSet(key, value);
      return value;
    })
    .finally(() => {
      inFlight.delete(key);
    });
  inFlight.set(key, promise);
  return promise;
}

function parseSseResponse(data) {
  const text = typeof data === 'string' ? data : '';
  for (const line of text.split('\n')) {
    if (line.startsWith('data: ')) {
      try {
        return JSON.parse(line.slice(6));
      } catch (_) {}
    }
  }
  return null;
}

async function sendMcpRequest(method, params = {}) {
  const headers = {
    'Content-Type': 'application/json',
    Accept: 'application/json, text/event-stream',
  };
  if (sessionId) {
    headers['Mcp-Session-Id'] = sessionId;
  }

  const response = await axios.post(MCP_URL, {
    jsonrpc: '2.0',
    method,
    params,
    id: Date.now().toString(),
  }, { headers, timeout: 60000, responseType: 'text' });

  const newSessionId = response.headers['mcp-session-id'];
  if (newSessionId) sessionId = newSessionId;

  return parseSseResponse(response.data);
}

async function initializeMcp() {
  if (sessionId) return;
  await sendMcpRequest('initialize', {
    protocolVersion: '2025-03-26',
    capabilities: {},
    clientInfo: { name: 'muslim-ia', version: '1.0.0' },
  });
}

async function listTools() {
  await initializeMcp();
  const result = await sendMcpRequest('tools/list');
  return result?.result?.tools || [];
}

async function callTool(toolName, args = {}) {
  await initializeMcp();
  const result = await sendMcpRequest('tools/call', { name: toolName, arguments: args });
  return result?.result || null;
}

/**
 * Recherche des versets par mot-clé/thème
 */
async function searchQuran(query) {
  return await callTool('search_quran', { query });
}

/**
 * Récupère un verset spécifique
 */
async function fetchQuran(ayahs) {
  return await callTool('fetch_quran', { ayahs });
}

/**
 * Récupère une traduction selon la langue demandée
 */
const TRANSLATION_EDITIONS = {
  fr: 'fr-hamidullah',
  en: 'en-sahih',
  es: 'es-cortes',
  ar: null,
};
async function fetchTranslation(ayahs, editions = 'fr-hamidullah') {
  return await callTool('fetch_translation', { ayahs, editions });
}

/**
 * Récupère le tafsir
 */
async function fetchTafsir(ayahs, editions = 'ar-ibn-kathir') {
  return await callTool('fetch_tafsir', { ayahs, editions });
}

/**
 * Récupère les règles de grounding
 */
async function fetchGroundingRules() {
  return await callTool('fetch_grounding_rules', {});
}

function extractContent(result) {
  if (!result) return '';

  if (result.content && Array.isArray(result.content)) {
    for (const c of result.content) {
      if (c.type === 'text' && c.text) {
        try {
          const parsed = JSON.parse(c.text);
          const texts = _extractTexts(parsed);
          if (texts) return texts;
        } catch (_) {
          return c.text;
        }
      }
    }
    return result.content.map(c => c.text || '').join('\n');
  }

  return _extractTexts(result) || (typeof result === 'string' ? result : JSON.stringify(result));
}

function _extractTexts(data) {
  if (!data || typeof data !== 'object') return null;

  if (data.results && typeof data.results === 'object') {
    const texts = [];
    for (const [_edition, items] of Object.entries(data.results)) {
      if (Array.isArray(items)) {
        for (const item of items) {
          if (item.text) texts.push(item.text);
        }
      }
    }
    if (texts.length > 0) return texts.join('\n');
  }

  if (data.warnings && !data.results) {
    const warningText = data.warnings.map(w => w.suggestion || w.message || '').filter(Boolean).join('; ');
    if (warningText) return warningText;
  }

  return null;
}

/**
 * Récupère un verset complet (arabe + traduction + tafsir) selon la langue
 */
async function fetchVerseComplete(reference, lang = 'fr') {
  const key = cacheKey(['verse', String(reference).toLowerCase(), lang]);
  return cached(key, async () => {
    try {
      const edition = TRANSLATION_EDITIONS[lang] || TRANSLATION_EDITIONS.fr;
      const [arabic, translation, tafsir] = await Promise.all([
        fetchQuran(reference),
        edition ? fetchTranslation(reference, edition) : Promise.resolve(null),
        fetchTafsir(reference, 'ar-ibn-kathir').catch(() => null),
      ]);

      return {
        reference,
        arabe: extractContent(arabic),
        traduction: edition ? extractContent(translation) : '',
        tafsir: extractContent(tafsir),
      };
    } catch (e) {
      console.error(`Erreur fetchVerseComplete(${reference}, ${lang}):`, e.message);
      return null;
    }
  });
}

/**
 * Recherche thématique complète
 */
async function searchQuranComplete(query) {
  const key = cacheKey(['search', query.trim().toLowerCase()]);
  return cached(key, async () => {
    try {
      const result = await searchQuran(query);
      const text = extractContent(result);
      return { query, results: text, raw: result };
    } catch (e) {
      console.error(`Erreur searchQuranComplete("${query}"):`, e.message);
      return null;
    }
  });
}

module.exports = {
  initializeMcp,
  listTools,
  callTool,
  searchQuran,
  fetchQuran,
  fetchTranslation,
  fetchTafsir,
  fetchVerseComplete,
  searchQuranComplete,
  fetchGroundingRules,
};
