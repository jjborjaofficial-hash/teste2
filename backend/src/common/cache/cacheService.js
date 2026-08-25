const redis = require('../../config/redis');
const logger = require('../logger');

/**
 * Camada de Cache genérica (docx "IMPLANTAÇÃO OFICIAL — REDIS CACHE E CRON JOBS",
 * Seção 5: "Redis deve funcionar apenas como camada rápida de acesso"; Manual
 * Parte 3: Camada de Cache — "sempre que possível consultar primeiro o cache;
 * caso não exista, consultar o banco").
 *
 * Padrão cache-aside com degradação graciosa: se o Redis cair, a plataforma
 * continua funcionando normalmente direto no banco — nunca derruba uma
 * funcionalidade por causa do cache (mesmo princípio já usado no Ranking).
 */

async function getOrSet(key, ttlSeconds, fetchFn) {
  try {
    const cached = await redis.get(key);
    if (cached) return JSON.parse(cached);
  } catch (err) {
    logger.warn('Cache indisponível para leitura, seguindo direto para o banco', { key, error: err.message });
  }

  const fresh = await fetchFn();

  try {
    await redis.set(key, JSON.stringify(fresh), 'EX', ttlSeconds);
  } catch (err) {
    logger.warn('Falha ao gravar no cache', { key, error: err.message });
  }

  return fresh;
}

async function invalidate(key) {
  try {
    await redis.del(key);
  } catch (err) {
    logger.warn('Falha ao invalidar cache', { key, error: err.message });
  }
}

module.exports = { getOrSet, invalidate };
