const Redis = require('ioredis');
const logger = require('../common/logger');

const redis = new Redis(process.env.REDIS_URL || 'redis://localhost:6379', {
  maxRetriesPerRequest: 3,
  retryStrategy(times) {
    // Backoff exponencial limitado — a plataforma deve continuar funcionando
    // mesmo se o cache ficar temporariamente indisponível (Parte 3: Camada de Cache).
    return Math.min(times * 200, 2000);
  },
});

redis.on('error', (err) => {
  logger.error('Erro de conexão com Redis', { error: err.message });
});

module.exports = redis;
