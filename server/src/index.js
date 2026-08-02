const cluster = require('cluster');
const os = require('os');

/**
 * Muslim IA Backend — serveur robuste et scalable.
 *
 * - Mode cluster : un worker par cœur CPU (repart le travail, augmente la
 *   capacité concurrente et ressource automatiquement un worker qui meurt).
 * - Chaque worker est un serveur Express stateless : on peut mettre plusieurs
 *   instances derrière un load balancer pour passer à l'échelle horizontale.
 */

const isDev = process.env.NODE_ENV !== 'production';
const numCores = os.cpus().length;

// Nombre de workers (surchargeable via WEB_CONCURRENCY). Un seul process si
// explicitement demandé (ex: exécution en dev avec nodemon).
const configured = parseInt(process.env.WEB_CONCURRENCY || '0', 10);
const WORKERS = process.env.WEB_CONCURRENCY === '1' || process.env.CLUSTER_DISABLED === '1'
  ? 1
  : Math.max(1, configured || Math.min(numCores, 4));

if (cluster.isPrimary) {
  // ---------------------------------------------------------------- MASTER --
  const logger = require('./utils/logger');
  logger.start('Server', `Cluster maître (PID ${process.pid}) — ${WORKERS} worker(s) sur ${numCores} CPU`);

  function spawnWorker() {
    const worker = cluster.fork();
    worker.on('exit', (code, signal) => {
      logger.warn('Server', `Worker ${worker.process.pid} arrêté (code=${code}, signal=${signal}) — relance...`);
      spawnWorker();
    });
  }

  for (let i = 0; i < WORKERS; i++) spawnWorker();

  function shutdown(signal) {
    logger.warn('Server', `Signal ${signal} reçu — arrêt gracieux du cluster...`);
    for (const id in cluster.workers) {
      try {
        cluster.workers[id].process.kill('SIGTERM');
      } catch (_) {}
    }
    // Force l'arrêt si les workers traînent.
    setTimeout(() => process.exit(0), 4000).unref();
  }
  process.on('SIGINT', () => shutdown('SIGINT'));
  process.on('SIGTERM', () => shutdown('SIGTERM'));
} else {
  // ----------------------------------------------------------------- WORKER --
  const express = require('express');
  const cors = require('cors');
  const helmet = require('helmet');
  const morgan = require('morgan');
  require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });

  const logger = require('./utils/logger');
  const { createRateLimiter } = require('./middleware/rate_limit');
  const askRoutes = require('./routes/ask');
  const userRoutes = require('./routes/user');
  const progressRoutes = require('./routes/progress');
  const audioRoutes = require('./routes/audio');
  const visionRoutes = require('./routes/vision');
  const authRoutes = require('./routes/auth');

  const app = express();
  const PORT = process.env.PORT || 4000;

  const windowMs = parseInt(process.env.RATE_LIMIT_WINDOW_MS || '60000', 10);
  const generalMax = parseInt(process.env.RATE_LIMIT_MAX || '120', 10);
  const strictMax = parseInt(process.env.RATE_LIMIT_STRICT_MAX || '20', 10);
  const heavyMax = parseInt(process.env.RATE_LIMIT_HEAVY_MAX || '30', 10);

  // Derrière un proxy / load balancer (Cloud Run, Nginx, GCP...).
  if (process.env.TRUST_PROXY === 'true') app.set('trust proxy', 1);

  app.disable('x-powered-by');
  app.use(helmet());
  app.use(cors());

  // Logs complets en dev uniquement ; en production on journalise via le
  // middleware sur-mesure (uniquement erreurs / requêtes lentes) pour éviter
  // un goulot d'étranglement console sous forte charge.
  if (isDev) {
    app.use(morgan('dev'));
  }

  // Limites de corps : 10 Mo par défaut, appliquées avant tout traitement.
  app.use(express.json({ limit: '10mb' }));

  // Middleware de journalisation sur-mesure.
  app.use((req, res, next) => {
    const start = Date.now();
    res.on('finish', () => {
      const duration = Date.now() - start;
      const status = res.statusCode;
      if (isDev || status >= 400 || duration > 2000) {
        logger.info('API', `${req.method} ${req.path} → ${status} (${duration}ms) [worker ${process.pid}]`);
      }
    });
    next();
  });

  // Rate limiting : limite stricte sur les routes lourdes / sensibles avant
  // le montage générique. Protège contre les abus et le déni de service.
  app.use('/api/ask/stream', createRateLimiter({ windowMs, max: strictMax }));
  app.use('/api/audio', createRateLimiter({ windowMs, max: heavyMax }));
  app.use('/api/vision', createRateLimiter({ windowMs, max: heavyMax }));
  app.use('/api/auth', createRateLimiter({ windowMs, max: strictMax }));
  app.use('/api', createRateLimiter({ windowMs, max: generalMax }));

  app.get('/health', (req, res) => {
    res.json({
      status: 'ok',
      service: 'muslim-ia-backend',
      pid: process.pid,
      timestamp: new Date().toISOString(),
    });
  });

  app.use('/api/ask', askRoutes);
  app.use('/api/user', userRoutes);
  app.use('/api/progress', progressRoutes);
  app.use('/api/audio', audioRoutes);
  app.use('/api/vision', visionRoutes);
  app.use('/api/auth', authRoutes);

  // 404 propre (JSON) — évite d'exposer la stack HTML par défaut.
  app.use((req, res) => {
    res.status(404).json({ success: false, error: 'Route introuvable' });
  });

  // Gestion d'erreur centralisée : ne jamais fuiter l'erreur interne.
  // eslint-disable-next-line no-unused-vars
  app.use((err, req, res, _next) => {
    const status = err.status || err.statusCode || 500;

    if (status === 413) {
      return res.status(413).json({ success: false, error: 'Corps de requête trop volumineux' });
    }
    if (status >= 500) {
      logger.error('API', `${req.method} ${req.path} → ${status}`, err.stack || err.message);
    } else {
      logger.warn('API', `${req.method} ${req.path} → ${status}`, err.message);
    }
    if (res.headersSent) return _next(err);
    return res.status(status).json({
      success: false,
      error: status >= 500 ? 'Erreur interne du serveur' : err.message,
    });
  });

  // Filet de sécurité : une promesse rejetée non gérée ne doit jamais faire
  // tomber un worker silencieusement.
  process.on('unhandledRejection', (reason) => {
    logger.error('Server', 'Unhandled promise rejection', reason);
  });
  process.on('uncaughtException', (err) => {
    logger.error('Server', 'Uncaught exception', err.stack || err);
  });

  const server = app.listen(PORT, '0.0.0.0', () => {
    logger.start('Server', `Worker ${process.pid} — Muslim IA Backend démarré sur http://0.0.0.0:${PORT}`);
    if (isDev) {
      console.log('Routes disponibles:');
      console.log('  POST /api/ask            - Chat IA');
      console.log('  POST /api/ask/stream     - Chat streaming');
      console.log('  POST /api/ask/search     - Recherche Coran');
      console.log('  GET  /api/ask/verse/:ref - Verset complet');
      console.log('  POST /api/vision/analyze - Analyse image');
      console.log('  POST /api/audio/transcribe - Transcription');
      console.log('  GET  /health              - Health check');
    }
  });

  // Durcissement des timeouts du serveur HTTP : aucun socket ne peut traîner
  // indéfiniment, chaque requête a une durée maximale.
  server.headersTimeout = 20000;
  server.requestTimeout = parseInt(process.env.REQUEST_TIMEOUT_MS || '65000', 10);
  server.keepAliveTimeout = 5000;

  // Arrêt gracieux du worker : arrête d'accepter, laisse finir les requêtes
  // en cours (jusqu'à ~4 s), puis quitte proprement.
  function gracefulShutdown() {
    logger.warn('Server', `Worker ${process.pid} — arrêt gracieux...`);
    server.close(() => process.exit(0));
    setTimeout(() => process.exit(0), 4000).unref();
  }
  process.on('SIGTERM', gracefulShutdown);
  process.on('SIGINT', gracefulShutdown);

  module.exports = app;
}
