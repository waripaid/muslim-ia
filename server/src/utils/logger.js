const logger = {
  info: (module, msg, data = '') => console.log(`[${new Date().toISOString()}] ℹ️  ${module} | ${msg}`, data ? data : ''),
  success: (module, msg, data = '') => console.log(`[${new Date().toISOString()}] ✅ ${module} | ${msg}`, data ? data : ''),
  warn: (module, msg, data = '') => console.warn(`[${new Date().toISOString()}] ⚠️  ${module} | ${msg}`, data ? data : ''),
  error: (module, msg, data = '') => console.error(`[${new Date().toISOString()}] ❌ ${module} | ${msg}`, data ? data : ''),
  start: (module, msg) => console.log(`[${new Date().toISOString()}] 🚀 ${module} | ${msg}`),
  end: (module, msg, duration) => console.log(`[${new Date().toISOString()}] 🏁 ${module} | ${msg} (${duration}ms)`),
};

module.exports = logger;
