const redis = require('../../../config/redis');
const logger = require('../../../common/logger');
const repository = require('../repositories/platformStatsRepository');

/**
 * Service de Estatísticas Públicas (prova social real, sem números fixos
 * — ver nota de correção no Onboarding.jsx e Dashboard.jsx).
 *
 * Cacheado no mesmo padrão do ranking semanal (Manual Parte 3: Camada de
 * Cache): rota pública, potencialmente chamada por qualquer visitante
 * sem login antes de criar conta, então evitar bater no banco a cada
 * carregamento de tela é importante aqui.
 */

const CACHE_TTL_SECONDS = 120; // 2 minutos — "vivo" o suficiente para parecer atualizado, sem sobrecarregar o banco
const CACHE_KEY = 'platform:public-stats';

async function getPlatformStats() {
  try {
    const cached = await redis.get(CACHE_KEY);
    if (cached) {
      return JSON.parse(cached);
    }
  } catch (err) {
    logger.warn('Falha ao ler cache de estatísticas públicas, seguindo direto para o banco', {
      error: err.message,
    });
  }

  const stats = await repository.getPlatformStats();

  try {
    await redis.set(CACHE_KEY, JSON.stringify(stats), 'EX', CACHE_TTL_SECONDS);
  } catch (err) {
    logger.warn('Falha ao gravar cache de estatísticas públicas', { error: err.message });
  }

  return stats;
}

module.exports = { getPlatformStats };
