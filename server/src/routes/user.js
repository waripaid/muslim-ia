const express = require('express');
const router = express.Router();
const { upsertUser, saveFcmToken } = require('../services/firebase');

/**
 * POST /api/user/sync
 * Synchronise le profil Firebase après authentification
 */
router.post('/sync', async (req, res, next) => {
  try {
    const { uid, email, displayName, photoURL } = req.body;
    if (!uid) {
      return res.status(400).json({ error: 'uid requis', success: false });
    }
    await upsertUser(uid, { email, displayName, photoURL });
    res.json({ success: true, message: 'Profil synchronisé' });
  } catch (error) {
    next(error);
  }
});

/**
 * POST /api/user/fcm-token
 * Enregistre le token FCM pour les push notifications
 */
router.post('/fcm-token', async (req, res, next) => {
  try {
    const { userId, fcmToken } = req.body;
    if (!userId || !fcmToken) {
      return res.status(400).json({ error: 'userId et fcmToken requis', success: false });
    }
    await saveFcmToken(userId, fcmToken);
    res.json({ success: true });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
