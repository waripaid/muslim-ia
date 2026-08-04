const axios = require('axios');
const fs = require('fs');
const path = require('path');
const os = require('os');
const FormData = require('form-data');
const logger = require('../utils/logger');

const fsp = fs.promises;

const MISTRAL_API_URL = 'https://api.mistral.ai/v1';
const API_KEY = process.env.MISTRAL_API_KEY;

const DEFAULT_VOICE_ID = 'c69964a6-ab8b-4f8a-9465-ec0925096ec8';

// Taille max d'un audio en base64 (≈ 15 Mo audio) — protège la mémoire.
const MAX_AUDIO_BASE64 = 20 * 1024 * 1024;
const AUDIO_TMP_DIR = path.join(os.tmpdir(), 'muslim-ia-audio');

// Voix natives par langue (voix préréglées disponibles sur le compte)
const VOICE_BY_LANGUAGE = {
  fr: '5a271406-039d-46fe-835b-fbbb00eaf08d', // Marie - Neutral (fr_fr)
  en: 'c69964a6-ab8b-4f8a-9465-ec0925096ec8', // Paul - Neutral (en_us)
  en_us: 'c69964a6-ab8b-4f8a-9465-ec0925096ec8', // Paul - Neutral
  en_gb: 'e3596645-b1af-469e-b857-f18ddedc7652', // Oliver - Neutral (en_gb)
  // Pas de voix arabe dédiée sur ce compte : la voix française (Marie)
  // translittère/trongue l'arabe, alors que Paul (en_us) le lit correctement.
  ar: 'c69964a6-ab8b-4f8a-9465-ec0925096ec8', // Paul - Neutral (lit l'arabe)
};

function pickVoice(language, voiceId) {
  if (voiceId) return voiceId;
  if (language) {
    const base = String(language).toLowerCase().replace('-', '_');
    if (VOICE_BY_LANGUAGE[base]) return VOICE_BY_LANGUAGE[base];
    const two = base.split('_')[0];
    if (VOICE_BY_LANGUAGE[two]) return VOICE_BY_LANGUAGE[two];
  }
  return process.env.MISTRAL_VOICE_ID || DEFAULT_VOICE_ID;
}

async function transcribeAudio(audioBase64, language = null) {
  if (typeof audioBase64 !== 'string' || audioBase64.length === 0) {
    return { success: false, error: 'Aucun audio reçu' };
  }
  if (audioBase64.length > MAX_AUDIO_BASE64) {
    return { success: false, error: 'Fichier audio trop volumineux' };
  }

  let tempFile = null;
  try {
    await fsp.mkdir(AUDIO_TMP_DIR, { recursive: true });
    tempFile = path.join(
      AUDIO_TMP_DIR,
      `audio_${Date.now()}_${Math.random().toString(36).slice(2, 10)}.wav`
    );
    const buffer = Buffer.from(audioBase64, 'base64');
    await fsp.writeFile(tempFile, buffer);

    const form = new FormData();
    form.append('file', fs.createReadStream(tempFile), { filename: 'audio.wav', contentType: 'audio/wav' });
    form.append('model', 'voxtral-mini-latest');
    if (language) form.append('language', language);

    let response;
    try {
      response = await axios.post(`${MISTRAL_API_URL}/audio/transcriptions`, form, {
        headers: {
          ...form.getHeaders(),
          Authorization: `Bearer ${API_KEY}`,
        },
        timeout: 120000,
        maxContentLength: Infinity,
        maxBodyLength: Infinity,
      });
    } catch (error) {
      logger.error('Audio', 'Erreur transcription Mistral', JSON.stringify(error.response?.data || error.message));
      throw error;
    }

    return {
      success: true,
      text: response.data.text || '',
      language: response.data.language || language || 'unknown',
    };
  } catch (error) {
    logger.error('Audio', 'Erreur transcription', error.message);
    return {
      success: false,
      error: error.response?.data?.error?.message || error.message,
    };
  } finally {
    // Nettoyage systématique du fichier temporaire (même en cas d'erreur).
    if (tempFile) {
      try {
        await fsp.unlink(tempFile);
      } catch (_) {}
    }
  }
}

// Nettoie le texte avant synthèse vocale pour que les symboles
// (tirets, dollars, markdown, etc.) ne soient pas lus littéralement.
function sanitizeForTTS(text, language = null) {
  if (!text) return '';
  const lang = String(language || 'fr').toLowerCase().split('-')[0].split('_')[0];

  const spoken = lang === 'en'
    ? { '%': 'percent', '€': 'euros', '$': 'dollars', '£': 'pounds', '&': 'and', '+': 'plus', '×': 'times', '÷': 'divided by', '=': 'equals', '°': 'degrees', '~': 'approximately' }
    : { '%': 'pour cent', '€': 'euros', '$': 'dollars', '£': 'livres', '&': 'et', '+': 'plus', '×': 'fois', '÷': 'divisé par', '=': 'égale', '°': 'degrés', '~': 'environ' };

  let t = String(text);

  // Symboles lus avec leur équivalent parlé (gère "3$" et "$3")
  for (const [sym, word] of Object.entries(spoken)) {
    t = t.split(sym).join(` ${word} `);
  }

  // Markdown : gras / italique / code / liens / titres
  t = t.replace(/\*\*/g, '');
  t = t.replace(/\*/g, '');
  t = t.replace(/__/g, '');
  t = t.replace(/`/g, '');
  t = t.replace(/\[([^\]]+)\]\([^)]*\)/g, '$1');
  t = t.replace(/^#{1,6}\s*/gm, '');

  // Puces en début de ligne
  t = t.replace(/^[ \t]*[-•▪]\s+/gm, '');

  // Tiret isolé (séparateur) : "a - b" → "a b" (préserve "franco-arabe", "2-3")
  t = t.replace(/[ \t]+-+[ \t]+/g, ' ');

  // Tiret cadratin / demi-cadratin → espace
  t = t.replace(/[—–]/g, ' ');

  // Points de suspension
  t = t.replace(/\.{3,}/g, ' point point point ');

  // Guillemets/apostrophes courbes → droits
  t = t.replace(/[\u201C\u201D\u00AB\u00BB]/g, '"');
  t = t.replace(/[\u2018\u2019]/g, "'");

  // Emojis (lus·e·s par la voix sinon)
  t = t.replace(/[\u{1F000}-\u{1FAFF}\u{2600}-\u{27BF}\u{FE0F}\u{2190}-\u{21FF}]/gu, ' ');

  // Espaces superflus
  t = t.replace(/[ \t]+/g, ' ').trim();
  t = t.replace(/ +([,.;:!?])/g, '$1');

  return t;
}

// Détecte si un texte est majoritairement arabe (caractères Unicode 0600-06FF).
function isArabic(text) {
  const chars = Array.from(String(text).trim());
  const arabic = chars.filter((c) => {
    const cp = c.codePointAt(0);
    return cp >= 0x0600 && cp <= 0x06FF;
  }).length;
  return chars.length > 0 && arabic > chars.length * 0.4;
}

// Découpe le texte en segments de synthèse, chacun avec sa langue.
// Les blocs [SOURCE]...[/SOURCE] (format : arabe — "traduction" (référence))
// sont découpés pour que le verset arabe soit lu en arabe, puis la
// traduction dans la langue du message.
function splitSegments(text, defaultLanguage) {
  const segments = [];
  let lastEnd = 0;
  const sourceRegex = /\[SOURCE\]([\s\S]*?)\[\/SOURCE\]/g;
  let match;
  while ((match = sourceRegex.exec(text)) !== null) {
    if (match.index > lastEnd) {
      const body = text.slice(lastEnd, match.index);
      if (body.trim()) segments.push({ text: body, language: defaultLanguage });
    }
    const content = match[1].trim();
    const sep = content.match(/^([\s\S]*?)[ \t]*[—–][ \t]*([\s\S]*)$/);
    if (sep && isArabic(sep[1])) {
      segments.push({ text: sep[1].trim(), language: 'ar' });
      if (sep[2].trim()) segments.push({ text: sep[2].trim(), language: defaultLanguage });
    } else {
      segments.push({ text: content, language: isArabic(content) ? 'ar' : defaultLanguage });
    }
    lastEnd = match.index + match[0].length;
  }
  if (lastEnd < text.length) {
    const body = text.slice(lastEnd);
    if (body.trim()) segments.push({ text: body, language: defaultLanguage });
  }
  return segments;
}

// Génère l'audio d'un seul segment et retourne l'audio_data (base64).
async function generateSpeech(input, language, voiceId) {
  const payload = {
    model: 'voxtral-mini-tts-2603',
    input: sanitizeForTTS(input, language),
    response_format: 'mp3',
    voice_id: pickVoice(language, voiceId),
  };

  const response = await axios.post(`${MISTRAL_API_URL}/audio/speech`, payload, {
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${API_KEY}`,
    },
    timeout: 60000,
  });

  const audioData = response.data?.audio_data;
  if (!audioData) {
    logger.warn('Audio', 'Réponse TTS sans audio_data');
    throw new Error('Aucun audio reçu du fournisseur TTS');
  }
  return audioData;
}

async function textToSpeech(text, language = null, voiceId = null) {
  if (typeof text !== 'string' || text.trim().length === 0) {
    return { success: false, error: 'Aucun texte à synthétiser' };
  }
  if (text.length > 5000) {
    return { success: false, error: 'Texte trop long (maximum 5000 caractères)' };
  }
  try {
    const lang = language || 'fr';
    const segments = splitSegments(text, lang).filter((s) => s.text.trim());
    if (segments.length <= 1) {
      const audioData = await generateSpeech(
        segments[0] ? segments[0].text : text,
        segments[0] ? segments[0].language : lang,
        voiceId
      );
      return { success: true, audio: audioData, format: 'mp3' };
    }

    logger.info('Audio', `TTS multi-segments (${segments.length})`);
    const audios = await Promise.all(
      segments.map((s) => generateSpeech(s.text, s.language, voiceId))
    );
    const combined = audios.filter(Boolean).join('');
    if (!combined) {
      return { success: false, error: 'Aucun audio reçu du fournisseur TTS' };
    }
    return { success: true, audio: combined, format: 'mp3' };
  } catch (error) {
    logger.error('Audio', 'Erreur TTS', error.message);
    return {
      success: false,
      error: error.response?.data?.error?.message || error.message,
    };
  }
}

async function checkPronunciation(audioBase64, expectedText, language = 'ar') {
  const transcription = await transcribeAudio(audioBase64, language);
  if (!transcription.success) return transcription;

  const transcribed = (transcription.text || '').trim();
  const expected = expectedText.trim();

  let score = 0;
  if (transcribed === expected) {
    score = 100;
  } else if (transcribed.length > 0) {
    const expectedWords = expected.split(/\s+/);
    const transcribedWords = transcribed.split(/\s+/);
    const matchedWords = expectedWords.filter(w => transcribedWords.includes(w));
    score = Math.round((matchedWords.length / Math.max(expectedWords.length, 1)) * 100);
  }

  return { success: true, transcribed, expected, score, isExact: transcribed === expected };
}

module.exports = { transcribeAudio, checkPronunciation, textToSpeech };
