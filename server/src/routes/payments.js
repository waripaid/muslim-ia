const express = require('express');
const router = express.Router();
const { getAuth, isFirebaseAvailable } = require('../services/firebase');
const geniuspay = require('../services/geniuspay');
const { str } = require('../utils/validate');
const logger = require('../utils/logger');

const SUCCESS_URL =
  process.env.PAYMENT_SUCCESS_URL || 'https://muslim-ia.web.app/payment/success';
const ERROR_URL =
  process.env.PAYMENT_ERROR_URL || 'https://muslim-ia.web.app/payment/error';

const PREMIUM_DAYS = 30;

/**
 * Vérifie l'idToken Firebase et retourne le décodage.
 */
async function verifyToken(idToken) {
  if (!idToken) throw Object.assign(new Error('idToken requis'), { status: 400 });
  if (!isFirebaseAvailable()) {
    throw Object.assign(new Error('Firebase non configuré côté serveur'), { status: 503 });
  }
  try {
    return await getAuth().verifyIdToken(idToken);
  } catch (e) {
    logger.warn('Payments', `Vérification idToken échouée: ${e.message} (code=${e.code || e.errorInfo?.code || 'unknown'})`);
    throw Object.assign(new Error('idToken invalide ou expiré'), { status: 401 });
  }
}

/**
 * POST /api/payments/checkout
 * Crée un paiement GeniusPay côté serveur (le secret ne quitte jamais le backend).
 * Body: { idToken, amount, email, customerName }
 */
router.post('/checkout', async (req, res, next) => {
  try {
    if (!geniuspay.isConfigured()) {
      return res.status(503).json({
        success: false,
        error: 'Paiement indisponible pour le moment (configuration serveur manquante)',
      });
    }

    const decoded = await verifyToken(req.body.idToken);

    const amount = Number(req.body.amount);
    if (!Number.isInteger(amount) || amount < 1 || amount > 10000000) {
      return res.status(400).json({ success: false, error: 'Montant invalide' });
    }

    const email = str(req.body.email, { max: 200, name: 'email' });
    if (email.error) return res.status(400).json({ success: false, error: email.error });
    if (!email.value || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.value)) {
      return res.status(400).json({ success: false, error: 'email invalide' });
    }
    const customerName = str(req.body.customerName, { max: 100, name: 'customerName' });
    const customerNameValue = customerName.value || undefined;

    logger.start('Payments', `checkout uid=${decoded.uid} amount=${amount} XOF email=${email.value}`);

    const payment = await geniuspay.createCheckout({
      amount,
      description: `Abonnement Muslim IA Premium (${PREMIUM_DAYS} jours)`,
      currency: 'XOF',
      customer: {
        ...(customerNameValue ? { name: customerNameValue } : {}),
        email: email.value,
      },
      successUrl: SUCCESS_URL,
      errorUrl: ERROR_URL,
      metadata: { app: 'muslim_ia', product: 'premium', email: email.value, uid: decoded.uid },
    });

    logger.success('Payments', `checkout créé reference=${payment.reference} status=${payment.status} env=${payment.environment}`);

    res.json({
      success: true,
      data: {
        reference: payment.reference,
        checkout_url: payment.checkout_url || payment.payment_url || null,
        status: payment.status || 'pending',
        environment: payment.environment || 'sandbox',
      },
    });
  } catch (error) {
    next(error);
  }
});

/**
 * POST /api/payments/status
 * Interroge le statut d'un paiement (vérifie que le paiement appartient bien
 * à l'utilisateur via metadata.uid).
 * Body: { idToken, reference }
 */
router.post('/status', async (req, res, next) => {
  try {
    if (!geniuspay.isConfigured()) {
      return res.status(503).json({
        success: false,
        error: 'Paiement indisponible pour le moment (configuration serveur manquante)',
      });
    }

    const decoded = await verifyToken(req.body.idToken);

    const ref = str(req.body.reference, { max: 120, name: 'reference', required: true });
    if (ref.error) return res.status(400).json({ success: false, error: ref.error });

    logger.start('Payments', `status reference=${ref.value} uid=${decoded.uid}`);

    const payment = await geniuspay.getPayment(ref.value);

    const meta = payment.metadata || {};
    if (meta.uid && meta.uid !== decoded.uid) {
      logger.warn('Payments', `Accès refusé à la référence ${ref.value} par uid=${decoded.uid}`);
      return res.status(403).json({ success: false, error: 'Paiement non autorisé' });
    }

    res.json({
      success: true,
      data: {
        reference: payment.reference,
        status: payment.status || 'pending',
        gateway: payment.gateway || null,
        completed_at: payment.completed_at || null,
        failed_at: payment.failed_at || null,
      },
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
