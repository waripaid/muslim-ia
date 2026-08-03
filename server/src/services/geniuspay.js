/**
 * Service GeniusPay — proxy serveur-à-serveur.
 * Le secret (X-API-Secret) ne circule JAMAIS côté client : le backend
 * crée les paiements et interroge leur statut à la place de l'app.
 */

const axios = require('axios');
const logger = require('../utils/logger');

const BASE_URL =
  process.env.GENIUSPAY_BASE_URL || 'https://pay.genius.ci/api/v1/merchant';

const TIMEOUT = Number(process.env.GENIUSPAY_TIMEOUT_MS || 30000);

function _headers() {
  const apiKey = process.env.GENIUSPAY_API_KEY;
  const apiSecret = process.env.GENIUSPAY_API_SECRET;
  if (!apiKey || !apiSecret) {
    throw Object.assign(
      new Error('Paiement indisponible pour le moment (configuration serveur manquante)'),
      { status: 503 }
    );
  }
  return {
    'X-API-Key': apiKey,
    'X-API-Secret': apiSecret,
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'MuslimIA-Backend/1.0',
  };
}

function isConfigured() {
  return Boolean(process.env.GENIUSPAY_API_KEY && process.env.GENIUSPAY_API_SECRET);
}

function _mapError(e) {
  logger.warn('GeniusPay', `Erreur API GeniusPay: ${e.message}`);
  if (e.response) {
    const msg =
      e.response.data?.message ||
      e.response.data?.error ||
      `GeniusPay (HTTP ${e.response.status})`;
    const status = e.response.status === 401 ? 401 : 502;
    return Object.assign(new Error(msg), { status });
  }
  const status = e.code === 'ECONNABORTED' ? 504 : 503;
  return Object.assign(
    new Error(
      status === 504
        ? 'La passerelle de paiement ne répond pas. Réessayez.'
        : 'Impossible de contacter la passerelle de paiement.'
    ),
    { status }
  );
}

/**
 * Crée une session de checkout hébergée.
 * @returns {Promise<object>} payment brut GeniusPay
 */
async function createCheckout({
  amount,
  description,
  currency = 'XOF',
  customer,
  successUrl,
  errorUrl,
  metadata,
}) {
  const body = {
    amount,
    description,
    currency,
    ...(customer ? { customer } : {}),
    ...(successUrl ? { success_url: successUrl } : {}),
    ...(errorUrl ? { error_url: errorUrl } : {}),
    ...(metadata ? { metadata } : {}),
  };

  try {
    const res = await axios.post(`${BASE_URL}/payments`, body, {
      headers: _headers(),
      timeout: TIMEOUT,
    });
    return res.data?.data || res.data;
  } catch (e) {
    throw _mapError(e);
  }
}

/**
 * Récupère un paiement par sa référence.
 * @returns {Promise<object>} payment brut GeniusPay
 */
async function getPayment(reference) {
  try {
    const res = await axios.get(`${BASE_URL}/payments/${encodeURIComponent(reference)}`, {
      headers: _headers(),
      timeout: TIMEOUT,
    });
    return res.data?.data || res.data;
  } catch (e) {
    throw _mapError(e);
  }
}

module.exports = { createCheckout, getPayment, isConfigured };
