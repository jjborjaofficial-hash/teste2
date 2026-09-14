const Redis = require('ioredis');
const logger = require('../common/logger');

/**
 * Conexão Redis EXCLUSIVA para a fila (BullMQ).
 *
 * Por que não reaproveitar `src/config/redis.js`? O BullMQ exige
 * `maxRetriesPerRequest: null` na conexão que ele usa internamente (é a
 * própria lib que decide como e quando repetir comandos bloqueantes tipo
 * BRPOPLPUSH) — usar o client de cache geral (que tem `maxRetriesPerRequest: 3`,
 * correto para cache) quebraria silenciosamente o comportamento de espera
 * de jobs do BullMQ. Mesmo Redis, mesma REDIS_URL, conexões diferentes.
 */
const queueConnection = new Redis(process.env.REDIS_URL || 'redis://localhost:6379', {
  maxRetriesPerRequest: null,
});

queueConnection.on('error', (err) => {
  logger.error('Erro de conexão Redis (fila/BullMQ)', { error: err.message });
});

module.exports = queueConnection;
