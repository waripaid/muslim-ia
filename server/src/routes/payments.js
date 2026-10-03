const express = require('express');
const crypto = require('crypto');
const router = express.Router();
const { getAuth, isFirebaseAvailable, recordPayment, getPaymentRecord, setSubscription, getSubscription, revokeSubscription } = require('../services/firebase');
const geniuspay = require('../services/geniuspay');
const { str } = require('../utils/validate');
const logger = require('../utils/logger');

const SUCCESS_URL =
  process.env.PAYMENT_SUCCESS_URL || 'https://muslim-ia.web.app/payment/success';
const ERROR_URL =
  process.env.PAYMENT_ERROR_URL || 'https://muslim-ia.web.app/payment/error';

const PREMIUM_DAYS = 30;
// Tolérance anti-rejeu : un webhook plus vieux que 5 min est ignoré.
const MAX_WEBHOOK_AGE_SEC = 300;

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
    const code = e.code || e.errorInfo?.code || 'unknown';
    logger.warn('Payments', `Vérification idToken échouée: ${e.message} (code=${code})`);
    const expired = code === 'auth/id-token-expired' || /expired/i.test(e.message || '');
    throw Object.assign(
      new Error(expired ? 'Session expirée, reconnectez-vous puis réessayez.' : 'idToken invalide ou expiré'),
      { status: 401 }
    );
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

    // Trace l'intention de paiement côté serveur (pour réconciliation webhook).
    recordPayment(payment.reference, {
      uid: decoded.uid,
      email: email.value,
      amount: Number(payment.amount ?? amount),
      currency: payment.currency || 'XOF',
      status: payment.status || 'pending',
      environment: payment.environment || 'sandbox',
      product: 'premium',
      created_at: new Date().toISOString(),
    }).catch((e) => logger.warn('Payments', `Enregistrement checkout Firebase impossible: ${e.message}`));

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

/**
 * POST /api/payments/webhook
 * Webhook GeniusPay (corps brut + HMAC-SHA256). Ce endpoint est monté dans
 * index.js AVEC express.raw() pour conserver les octets exacts de la
 * signature. Sert de source de vérité : quand GeniusPay notifie payment.success,
 * on vérifie la signature, on confirme auprès de l'API puis on active le
 * Premium côté serveur (Firebase) — l'app n'a plus qu'à lire cet état.
 *
 * Headers attendus :
 *   X-Webhook-Signature : HMAC-SHA256(timestamp + "." + payload_brut, whsec)
 *   X-Webhook-Timestamp : timestamp Unix
 *   X-Webhook-Event     : payment.success | failed | cancelled | expired | refunded
 */
async function handleWebhook(req, res) {
  // --- Vérification de la signature HMAC ---
  const signature = (req.headers['x-webhook-signature'] || '').trim();
  const timestamp = Number(req.headers['x-webhook-timestamp'] || 0);
  const event = req.headers['x-webhook-event'] || '';

  if (!process.env.GENIUSPAY_WEBHOOK_SECRET) {
    logger.warn('Payments', 'Webhook reçu mais GENIUSPAY_WEBHOOK_SECRET non configuré');
    return res.status(503).json({ success: false, error: 'Webhook non configuré' });
  }
  if (!signature || !timestamp) {
    return res.status(401).json({ success: false, error: 'Signature manquante' });
  }

  const rawBody = Buffer.isBuffer(req.body) ? req.body.toString('utf8') : String(req.body || '');
  let payload = null;
  try {
    payload = JSON.parse(rawBody);
  } catch {
    return res.status(400).json({ success: false, error: 'JSON invalide' });
  }

  // Le payload exact est signé. On accepte aussi la forme re-sérialisée
  // (certains SDK re-encode le payload) — jamais d'échec lié à l'encodage.
  const candidates = [rawBody, JSON.stringify(payload)];
  const expectedList = candidates.map((body) =>
    crypto.createHmac('sha256', process.env.GENIUSPAY_WEBHOOK_SECRET)
      .update(`${timestamp}.${body}`)
      .digest('hex')
  );
  const sigBuf = Buffer.from(signature, 'utf8');
  const valid = expectedList.some((expected) => {
    const expBuf = Buffer.from(expected, 'utf8');
    return expBuf.length === sigBuf.length && crypto.timingSafeEqual(expBuf, sigBuf);
  });
  if (!valid) {
    logger.warn('Payments', 'Webhook REJETÉ (signature invalide)');
    return res.status(401).json({ success: false, error: 'Signature invalide' });
  }

  // Anti-rejeu : timestamp trop ancien (ou dans le futur) → ignoré.
  const nowSec = Math.floor(Date.now() / 1000);
  if (Math.abs(nowSec - timestamp) > MAX_WEBHOOK_AGE_SEC) {
    logger.warn('Payments', `Webhook rejeté (timestamp ${timestamp}, maintenant ${nowSec})`);
    return res.status(400).json({ success: false, error: 'Timestamp expiré' });
  }

  // --- Traitement de l'événement ---
  const data = payload.data || {};
  const reference = data.reference;
  const status = String(data.status || '').toLowerCase();
  const meta = data.metadata || payload.metadata || {};
  const uid = meta.uid || data.uid || null;
  const environment = payload.environment || 'unknown';

  logger.info('Payments', `Webhook valide event=${event || payload.event} ref=${reference} status=${status} uid=${uid} env=${environment}`);

  if (!reference) {
    logger.warn('Payments', 'Webhook sans référence, ignoré');
    return res.status(200).json({ success: true, received: true });
  }

  try {
    if (event === 'payment.success' || payload.event === 'payment.success') {
      // Confirmation secondaire auprès de l'API GeniusPay avant d'accorder quoi
      // que ce soit (le webhook seul ne suffit jamais en sécurité).
      let confirmed = false;
      try {
        const gp = await geniuspay.getPayment(reference);
        confirmed = ['completed', 'succeeded'].includes(String(gp.status).toLowerCase());
      } catch (e) {
        logger.warn('Payments', `Confirmation API GeniusPay indisponible pour ${reference}: ${e.message}`);
      }

      if (!confirmed) {
        logger.warn('Payments', `Réf ${reference} : non confirmée "completed" côté API, acquittement uniquement`);
        await recordPayment(reference, {
          uid,
          event,
          status,
          environment,
          received_at: new Date().toISOString(),
        });
        return res.status(200).json({ success: true, received: true, granted: false });
      }

      // App désormais gratuite : aucun grant Premium n'est effectué.
      await recordPayment(reference, {
        uid,
        event,
        status: 'completed',
        environment,
        received_at: new Date().toISOString(),
      });
      logger.info('Payments', `Paiement confirmé (${reference}) — aucun abonnement accordé (app gratuite)`);
      return res.status(200).json({ success: true, received: true, granted: false, free: true });
    }

    // Échec / annulation / expiration / remboursement
    await recordPayment(reference, {
      uid,
      event,
      status,
      environment,
      received_at: new Date().toISOString(),
    });

    if (event === 'payment.refunded' || payload.event === 'payment.refunded') {
      if (uid) {
        try {
          await revokeSubscription(uid);
        } catch {}
        logger.warn('Payments', `Remboursement reçu (réf ${reference}) — aucune action d'abonnement requise (app gratuite)`);
      }
    }

    return res.status(200).json({ success: true, received: true });
  } catch (e) {
    logger.error('Payments', 'Erreur traitement webhook', e);
    return res.status(500).json({ success: false, error: 'Erreur interne' });
  }
}

/**
 * POST /api/payments/entitlement
 * Source de vérité serveur : retourne l'abonnement Premium de l'utilisateur.
 * L'app l'interroge au démarrage / au changement de compte → le Premium survit
 * à la réinstallation et ne dépend plus du stockage local.
 * Body: { idToken }
 */
router.post('/entitlement', async (req, res, next) => {
  try {
    const decoded = await verifyToken(req.body?.idToken);
    const sub = await getSubscription(decoded.uid);

    let isPremium = false;
    let premiumEnd = null;
    if (sub && !sub.revoked && sub.premium_end) {
      const end = new Date(sub.premium_end);
      isPremium = end.getTime() > Date.now();
      premiumEnd = end.toISOString();
    }

    res.json({
      success: true,
      data: { isPremium, premiumEnd, plan: sub?.plan || null, source: sub?.source || null },
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
module.exports.handleWebhook = handleWebhook;
