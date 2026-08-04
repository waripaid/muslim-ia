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

// Fusionne les segments consécutifs de même langue : réduit le nombre
// d'appels TTS sans changer l'ordre de lecture.
function mergeConsecutive(segments) {
  const merged = [];
  for (const s of segments) {
    const last = merged[merged.length - 1];
    if (last && last.language === s.language) {
      last.text = `${last.text}\n${s.text}`;
    } else {
      merged.push({ text: s.text, language: s.language });
    }
  }
  return merged;
}

// Longueur max d'un segment TTS (≈ 250 mots) : sous la limite de Mistral
// (~300 mots), sinon l'API refuse ou tronque la synthèse.
const MAX_CHARS_PER_SEGMENT = 1400;

// Découpe un texte trop long en sous-segments, de préférence aux frontières
// de phrases, sans jamais dépasser la limite par segment.
function chunkSegment(text) {
  const maxChars = MAX_CHARS_PER_SEGMENT;
  const chunks = [];
  let remaining = String(text).trim();
  while (remaining.length > maxChars) {
    let cut = -1;
    // Frontière de phrase préférée : ponctuation + espace ou saut de ligne.
    for (let i = maxChars; i > Math.floor(maxChars / 2); i--) {
      const c = remaining[i];
      if (c === '\n' || (c === ' ' && i > 0 && '.!?؛;'.includes(remaining[i - 1]))) {
        cut = i + 1;
        break;
      }
    }
    // Sinon : dernier espace de la fenêtre pour ne pas couper un mot.
    if (cut === -1) {
      for (let i = maxChars; i > Math.floor(maxChars / 2); i--) {
        if (remaining[i] === ' ') {
          cut = i + 1;
          break;
        }
      }
    }
    if (cut === -1) cut = maxChars;
    chunks.push(remaining.slice(0, cut).trim());
    remaining = remaining.slice(cut).trim();
  }
  if (remaining) chunks.push(remaining);
  return chunks.filter(Boolean);
}

// Garde l'ordre de lecture : les segments sont lus du début à la fin du
// texte, l'arabe au moment où il apparaît puis sa traduction. On ne
// réordonne jamais (un reclassement des versets arabes en tête coupait le
// début du texte). La taille reste bornée par le découpage des segments.
function capSegments(segments) {
  return segments;
}

// Génère l'audio de plusieurs segments en limitant la concurrence :
// Mistral étrangle les appels TTS parallèles, on en lance donc seulement
// deux à la fois pour rester sous le timeout de l'hébergement.
async function generateSegments(segments, voiceId, format = 'mp3') {
  const CONCURRENCY = 2;
  const results = new Array(segments.length);
  let i = 0;
  async function worker() {
    while (i < segments.length) {
      const idx = i++;
      results[idx] = await generateSpeech(segments[idx].text, segments[idx].language, voiceId, format);
    }
  }
  const workers = Array.from(
    { length: Math.min(CONCURRENCY, segments.length) },
    worker
  );
  await Promise.all(workers);
  return results;
}

// Génère l'audio d'un seul segment et retourne l'audio_data (base64).
async function generateSpeech(input, language, voiceId, format = 'mp3') {
  const payload = {
    model: 'voxtral-mini-tts-2603',
    input: sanitizeForTTS(input, language),
    response_format: format,
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

// Fusionne plusieurs fichiers WAV (PCM 16-bit, mêmes paramètres) : garde le
// header du premier, concatène les données PCM des suivants et corrige les
// tailles RIFF/data. Retourne un Buffer WAV complet.
// NB : la concaténation binaire de MP3 est imprévisible (les décodeurs
// s'arrêtent au premier segment), d'où le passage par du WAV pour le
// multi-segments.
function mergeWavs(wavBuffers) {
  const findChunk = (buf, name) => {
    const idx = buf.indexOf(name);
    return idx >= 0 ? idx : null;
  };

  let dataSize = 0;
  let header = null;
  for (const buf of wavBuffers) {
    const dIdx = findChunk(buf, Buffer.from('data'));
    if (dIdx === null) throw new Error('WAV sans chunk data');
    if (header === null) {
      header = Buffer.from(buf.subarray(0, dIdx + 8));
    }
    dataSize += buf.length - (dIdx + 8);
  }
  if (header === null) throw new Error('Aucun WAV à fusionner');

  const out = Buffer.alloc(header.length + dataSize);
  header.copy(out, 0);
  let offset = header.length;
  for (const buf of wavBuffers) {
    const dIdx = findChunk(buf, Buffer.from('data'));
    const start = dIdx + 8;
    buf.copy(out, offset, start, buf.length);
    offset += buf.length - start;
  }

  // RIFF size (octets 4-7) = taille fichier - 8
  out.writeUInt32LE(out.length - 8, 4);
  // data chunk size (4 octets avant les données PCM)
  out.writeUInt32LE(dataSize, header.length - 4);
  return out;
}

async function textToSpeech(text, language = null, voiceId = null) {
  if (typeof text !== 'string' || text.trim().length === 0) {
    return { success: false, error: 'Aucun texte à synthétiser' };
  }
  if (text.length > 8000) {
    return { success: false, error: 'Texte trop long (maximum 8000 caractères)' };
  }
  try {
    const lang = language || 'fr';
    let segments = splitSegments(text, lang).filter((s) => s.text.trim());
    segments = capSegments(mergeConsecutive(segments));
    // Découpe les segments trop longs (limite Mistral ~300 mots par appel).
    const chunked = [];
    for (const s of segments) {
      for (const c of chunkSegment(s.text)) chunked.push({ text: c, language: s.language });
    }
    segments = chunked;
    if (segments.length <= 1) {
      const audioData = await generateSpeech(
        segments[0] ? segments[0].text : text,
        segments[0] ? segments[0].language : lang,
        voiceId
      );
      return { success: true, audio: audioData, format: 'mp3' };
    }

    logger.info('Audio', `TTS multi-segments (${segments.length})`);
    const audios = await generateSegments(segments, voiceId, 'wav');
    const buffers = audios.filter(Boolean).map((b64) => Buffer.from(b64, 'base64'));
    if (buffers.length === 0) {
      return { success: false, error: 'Aucun audio reçu du fournisseur TTS' };
    }
    const merged = mergeWavs(buffers);
    logger.info('Audio', `WAV fusionné: ${merged.length} octets`);
    return { success: true, audio: merged.toString('base64'), format: 'wav' };
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
