const express = require('express');
const router = express.Router();
const { transcribeAudio, checkPronunciation, textToSpeech } = require('../services/audio');

/**
 * POST /api/audio/transcribe
 * Transcrit un fichier audio en texte
 */
router.post('/transcribe', async (req, res, next) => {
  try {
    const { audio, language } = req.body;
    if (!audio) return res.status(400).json({ error: 'audio (base64) requis' });

    const result = await transcribeAudio(audio, language);
    res.json(result);
  } catch (error) {
    next(error);
  }
});

/**
 * POST /api/audio/tts
 * Synthèse vocale (TTS) d'un texte via Mistral Voxtral
 */
router.post('/tts', async (req, res, next) => {
  try {
    const { text, language, voice_id } = req.body;
    if (!text || !text.trim()) return res.status(400).json({ error: 'text requis' });

    const result = await textToSpeech(text, language, voice_id);
    res.json(result);
  } catch (error) {
    next(error);
  }
});

/**
 * POST /api/audio/pronounce
 * Vérifie la prononciation d'un texte attendu
 */
router.post('/pronounce', async (req, res, next) => {
  try {
    const { audio, expected, language } = req.body;
    if (!audio || !expected) return res.status(400).json({ error: 'audio et expected requis' });

    const result = await checkPronunciation(audio, expected, language || 'ar');
    res.json(result);
  } catch (error) {
    next(error);
  }
});

module.exports = router;
