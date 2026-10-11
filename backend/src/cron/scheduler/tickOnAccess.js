/**
 * Rede de segurança: sem worker e mesmo se o agendador externo falhar, qualquer acesso real ao backend,
 * no máximo 1 vez a cada 2 minutos (cadeado no Redis), dispara as tarefas devidas em segundo plano.
 * Só liga em produção. Desligue com CRON_ON_ACCESS=false (ex.: se um dia existir o worker pago).
 */
const redis = require('../../config/redis');
const logger = require('../../common/logger');
const { runDueJobs } = require('./runDueJobs');

let lastCheck = 0;

function isEnabled() {
  return process.env.NODE_ENV === 'production' && process.env.CRON_ON_ACCESS !== 'false';
}

function tickOnAccess(req, res, next) {
  next();
  if (!isEnabled()) return;
  const now = Date.now();
  if (now - lastCheck < 60 * 1000) return; // só consulta o Redis 1 vez por minuto por processo
  lastCheck = now;
  redis
    .set('cron:tick:throttle', '1', 'EX', 120, 'NX')
    .then((ok) => {
      if (ok) runDueJobs().catch((err) => logger.error('CRON-TICK (acesso): falha', { error: err.message }));
    })
    .catch(() => {});
}

module.exports = { tickOnAccess, isEnabled };
