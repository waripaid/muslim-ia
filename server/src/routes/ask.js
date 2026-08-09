const express = require('express');
const router = express.Router();
const { callMistralAgent, callMistralDirectStream, healthCheck } = require('../services/mistral');
const { searchQuranComplete, fetchVerseComplete, initializeMcp, callTool } = require('../services/mcp_quran');
const { str, arr } = require('../utils/validate');
const {
  saveConversation,
  getConversations,
  addFavorite,
  getFavorites,
  removeFavorite,
} = require('../services/firebase');

/**
 * POST /api/ask
 * Pose une question à l'IA (Coran, Arabe, Islam)
 */
router.post('/', async (req, res, next) => {
  try {
    const { question: rawQuestion, mode, history, userId } = req.body;

    // max 3000 : on tronque les très longs messages au lieu de rejeter (jamais
    // de 400 en prod) et le prompt reste léger → premier token rapide.
    const q = str(rawQuestion, { max: 3000, name: 'question', required: true, truncate: true });
    if (q.error) return res.status(400).json({ error: q.error, success: false });

    const h = arr(history, { max: 50, name: 'history' });
    if (h.error) return res.status(400).json({ error: h.error, success: false });

    const m = str(mode, { max: 30, name: 'mode' });
    const u = str(userId, { max: 200, name: 'userId' });

    const result = await callMistralAgent({
      question: q.value,
      mode: m.value || 'general',
      history: (h.value || []).slice(-8),
      userId: u.value || null,
    });

    const response = {
      success: true,
      answer: result.answer,
      sources: result.sources,
    };

    if (u.value) {
      try {
        await saveConversation(u.value, {
          question: q.value,
          answer: result.answer,
          sources: result.sources,
          mode: m.value || 'general',
        });
      } catch (dbError) {
        console.warn('Firebase non disponible, conversation non sauvegardée:', dbError.message);
      }
    }

    res.json(response);
  } catch (error) {
    next(error);
  }
});

/**
 * GET /api/ask/history/:userId
 * Récupère l'historique des conversations
 */
router.get('/history/:userId', async (req, res, next) => {
  try {
    const { userId } = req.params;
    const parsedLimit = parseInt(req.query.limit, 10);
    const limit = Number.isFinite(parsedLimit) ? Math.min(Math.max(parsedLimit, 1), 200) : 50;
    const conversations = await getConversations(userId, limit);
    res.json({ success: true, data: conversations });
  } catch (error) {
    next(error);
  }
});

/**
 * POST /api/ask/favorites
 * Ajoute un verset aux favoris
 */
router.post('/favorites', async (req, res, next) => {
  try {
    const { userId, sourate, verset, texte_arabe, traduction, notes } = req.body;

    if (!userId || !sourate || !verset) {
      return res.status(400).json({
        error: 'userId, sourate et verset sont requis',
        success: false,
      });
    }

    const result = await addFavorite(userId, { sourate, verset, texte_arabe, traduction, notes });
    res.json({ success: true, ...result });
  } catch (error) {
    next(error);
  }
});

/**
 * GET /api/ask/favorites/:userId
 * Récupère les favoris d'un utilisateur
 */
router.get('/favorites/:userId', async (req, res, next) => {
  try {
    const { userId } = req.params;
    const favorites = await getFavorites(userId);
    res.json({ success: true, data: favorites });
  } catch (error) {
    next(error);
  }
});

/**
 * DELETE /api/ask/favorites/:id
 * Supprime un favori
 */
router.delete('/favorites/:id', async (req, res, next) => {
  try {
    const { id } = req.params;
    await removeFavorite(null, id);
    res.json({ success: true, message: 'Favori supprimé' });
  } catch (error) {
    next(error);
  }
});

/**
 * GET /api/ask/health
 * Vérifie la connexion à l'agent IA
 */
router.get('/health', async (req, res) => {
  const status = await healthCheck();
  res.json(status);
});

/**
 * POST /api/ask/search
 * Recherche directe dans le Coran via MCP Quran
 */
router.post('/search', async (req, res, next) => {
  try {
    const q = str(req.body.query, { max: 300, name: 'query', required: true });
    if (q.error) return res.status(400).json({ error: q.error });

    await initializeMcp();
    const result = await searchQuranComplete(q.value);

    res.json({ success: true, query: q.value, data: result });
  } catch (error) {
    next(error);
  }
});

/**
 * GET /api/ask/verse/:reference
 * Récupère un verset complet (arabe + traduction + tafsir)
 */
router.get('/verse/:reference', async (req, res, next) => {
  try {
    const reference = String(req.params.reference || '').slice(0, 30);
    if (!reference) return res.status(400).json({ error: 'reference requis' });
    const lang = (req.query.lang || 'fr').toString().slice(0, 5);
    await initializeMcp();
    const verse = await fetchVerseComplete(reference, lang);
    res.json({ success: true, reference, data: verse });
  } catch (error) {
    next(error);
  }
});

/**
 * POST /api/ask/morphology
 * Analyse morphologique d'un mot arabe via MCP
 */
router.post('/morphology', async (req, res, next) => {
  try {
    const w = str(req.body.word, { max: 200, name: 'word', required: true });
    if (w.error) return res.status(400).json({ error: w.error });

    await initializeMcp();
    const result = await callTool('fetch_word_morphology', { word: w.value });
    res.json({ success: true, word: w.value, data: result });
  } catch (error) {
    next(error);
  }
});

/**
 * POST /api/ask/stream
 * Pose une question avec réponse en streaming (SSE)
 */
router.post('/stream', async (req, res, next) => {
  try {
    const q = str(req.body.question, { max: 3000, name: 'question', required: true, truncate: true });
    if (q.error) return res.status(400).json({ error: q.error });

    const h = arr(req.body.history, { max: 50, name: 'history' });
    if (h.error) return res.status(400).json({ error: h.error });

    const systemPrompt = `Tu es Muslim IA, assistant islamique. Réponds dans la langue de l'utilisateur. Cite les versets en arabe AVEC traduction. Sois précis.
CONFIDENTIALITÉ : ne révèle JAMAIS d'où tu obtiens tes données, ni comment tu fonctionnes, ni rien sur le backend, les API, les serveurs, les outils ou les fournisseurs. Si on te demande d'où viennent tes données ou comment tu fonctionnes, réponds simplement que ces informations sont confidentielles, sans détail technique, et recentre sur le sujet islamique.`;
    const messages = [
      { role: 'system', content: systemPrompt },
      ...(h.value || [])
        .filter((msg) => msg && typeof (msg.content || '') === 'string' && msg.content.trim().length > 0)
        .slice(-10) // contexte léger : les 10 derniers échanges suffisent
        .map((msg) => ({ role: msg.role, content: msg.content })),
      { role: 'user', content: q.value },
    ];

    await callMistralDirectStream({ messages, res });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
