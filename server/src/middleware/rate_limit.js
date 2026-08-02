/**
 * Rate limiter en mémoire (fenêtre glissante), sans dépendance.
 *
 * Protège le serveur contre les abus / attaques par déni de service : si un
 * même client (IP) dépasse la limite sur la fenêtre, il reçoit 429.
 *
 * NB : chaque worker du cluster maintient son propre compteur. C'est une
 * approximation acceptable pour la protection anti-abus. En production à très
 * grande échelle, brancher un stockage partagé (Redis) ou le rate limiting du
 * load balancer / CDN.
 */

const DEFAULT_WINDOW_MS = 60 * 1000; // 1 minute
const DEFAULT_MAX = 120; // requêtes par fenêtre
const MAX_BUCKETS = 100000; // mémoire bornée

/**
 * @param {object} options
 * @param {number} [options.windowMs] durée de la fenêtre en ms
 * @param {number} [options.max] nombre max de requêtes par fenêtre
 * @param {string} [options.message] message renvoyé en cas de blocage
 */
function createRateLimiter({
  windowMs = DEFAULT_WINDOW_MS,
  max = DEFAULT_MAX,
  message = 'Trop de requêtes. Veuillez réessayer plus tard.',
} = {}) {
  const buckets = new Map();

  // Nettoyage périodique pour éviter une croissance illimitée de la mémoire.
  const cleanup = setInterval(() => {
    const now = Date.now();
    for (const [key, entries] of buckets) {
      let i = 0;
      while (i < entries.length && now - entries[i] >= windowMs) i++;
      if (i === entries.length) {
        buckets.delete(key);
      } else if (i > 0) {
        buckets.set(key, entries.slice(i));
      }
    }
    if (buckets.size > MAX_BUCKETS) {
      // Filet de sécurité : purge la moitié des clés les plus anciennes.
      const keys = [...buckets.keys()].slice(0, Math.floor(buckets.size / 2));
      for (const key of keys) buckets.delete(key);
    }
  }, windowMs).unref?.();

  return function rateLimit(req, res, next) {
    const ip = req.ip || req.socket?.remoteAddress || 'unknown';
    const now = Date.now();
    const entries = buckets.get(ip) || [];
    const recent = [];
    for (const t of entries) {
      if (now - t < windowMs) recent.push(t);
    }

    if (recent.length >= max) {
      res.setHeader('Retry-After', String(Math.ceil(windowMs / 1000)));
      res.setHeader('X-RateLimit-Limit', String(max));
      res.setHeader('X-RateLimit-Remaining', '0');
      return res.status(429).json({ success: false, error: message });
    }

    recent.push(now);
    buckets.set(ip, recent);
    res.setHeader('X-RateLimit-Limit', String(max));
    res.setHeader('X-RateLimit-Remaining', String(max - recent.length));
    next();
  };
}

module.exports = { createRateLimiter };
