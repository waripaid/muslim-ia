const express = require('express');
const router = express.Router();
const { updateProgress, getProgress, sendPushNotification } = require('../services/firebase');

/**
 * POST /api/progress/update
 * Met à jour la progression d'apprentissage
 */
router.post('/update', async (req, res, next) => {
  try {
    const { userId, ...progress } = req.body;
    if (!userId) {
      return res.status(400).json({ error: 'userId requis', success: false });
    }
    await updateProgress(userId, progress);
    res.json({ success: true, message: 'Progression mise à jour' });
  } catch (error) {
    next(error);
  }
});

/**
 * GET /api/progress/:userId
 * Récupère la progression d'un utilisateur
 */
router.get('/:userId', async (req, res, next) => {
  try {
    const { userId } = req.params;
    const progress = await getProgress(userId);
    res.json({ success: true, data: progress || {} });
  } catch (error) {
    next(error);
  }
});

/**
 * POST /api/progress/daily-lesson
 * Génère la leçon quotidienne du programme 365 jours
 */
router.post('/daily-lesson', async (req, res, next) => {
  try {
    const { userId, day } = req.body;
    const { callMistralAgent } = require('../services/mistral');

    const question = day
      ? `Génère la leçon du jour ${day} du programme "Comprendre le Coran en 365 jours". 
         Inclus : 5 mots de vocabulaire coranique, 1 verset expliqué, exercice de prononciation, quiz.`
      : "Génère la leçon du jour du programme 'Comprendre le Coran en 365 jours'.";

    const result = await callMistralAgent({
      question,
      mode: 'daily_lesson',
      userId: userId || null,
    });

    res.json({
      success: true,
      lesson: result.answer,
      sources: result.sources,
    });
  } catch (error) {
    next(error);
  }
});

/**
 * POST /api/progress/notification
 * Envoie une notification push à l'utilisateur
 */
router.post('/notification', async (req, res, next) => {
  try {
    const { userId, title, body, data } = req.body;
    const result = await sendPushNotification(userId, { title, body, data });
    res.json({ success: true, ...result });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
