const express = require('express');
const router = express.Router();
const { getAuth, isFirebaseAvailable } = require('../services/firebase');
const { sendVerificationEmail, isBrevoConfigured } = require('../services/email');

const VERIFY_CONTINUE_URL =
  process.env.AUTH_CONTINUE_URL || 'https://muslim-ia.firebaseapp.com/verify';

/**
 * POST /api/auth/send-verification-email
 * Vérifie l'idToken, génère le lien de vérification Firebase et envoie
 * un email personnalisé (logo de l'app) via Brevo.
 * Body: { idToken }
 */
router.post('/send-verification-email', async (req, res, next) => {
  try {
    const { idToken } = req.body;
    if (!idToken) {
      return res.status(400).json({ error: 'idToken requis', success: false });
    }

    if (!isFirebaseAvailable()) {
      return res.status(503).json({ error: 'Firebase non configuré côté serveur', success: false });
    }

    let decoded;
    try {
      decoded = await getAuth().verifyIdToken(idToken);
    } catch (e) {
      return res.status(401).json({ error: 'idToken invalide ou expiré', success: false });
    }

    const uid = decoded.uid;
    const userRecord = await getAuth().getUser(uid);
    const email = userRecord.email;

    if (!email) {
      return res.status(400).json({ error: 'Compte sans adresse email', success: false });
    }
    if (userRecord.emailVerified) {
      return res.json({ success: true, alreadyVerified: true });
    }

    const actionCodeSettings = {
      url: VERIFY_CONTINUE_URL,
      handleCodeInApp: true,
      android: { packageName: 'com.muslim_ia.app', installApp: true },
    };

    const link = await getAuth().generateEmailVerificationLink(email, actionCodeSettings);

    if (!isBrevoConfigured()) {
      return res.status(503).json({
        error: 'Brevo non configuré (BREVO_API_KEY / BREVO_SENDER_EMAIL)',
        success: false,
      });
    }

    const result = await sendVerificationEmail({
      to: email,
      displayName: userRecord.displayName,
      link,
    });

    if (result.sent) {
      return res.json({ success: true });
    }
    return res.status(502).json({ error: `Envoi Brevo échoué: ${result.reason}`, success: false });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
