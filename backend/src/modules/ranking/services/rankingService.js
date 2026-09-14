const redis = require('../../../config/redis');
const logger = require('../../../common/logger');
const repository = require('../repositories/rankingRepository');
const levelService = require('../../gamification/services/levelService');

/**
 * Service do Ranking Semanal (Doc. Mestre Seção 9 | Manual Parte 3: Camada de Cache).
 * Primeiro módulo a usar o Redis de fato: o ranking é lido com muito mais frequência
 * do que é escrito (só muda quando o CRON semanal recalcula), então é o caso de uso
 * ideal para cache-aside.
 */

const CACHE_TTL_SECONDS = 300; // 5 minutos — ranking não precisa ser em tempo real

function topRankingCacheKey(weekStart) {
  return `ranking:weekly:${weekStart}:top`;
}

function myPositionCacheKey(weekStart, userId) {
  return `ranking:weekly:${weekStart}:position:${userId}`;
}

async function getTopRanking(limit = 20) {
  const weekStart = repository.currentWeekStartDate();
  const cacheKey = topRankingCacheKey(weekStart);

  try {
    const cached = await redis.get(cacheKey);
    if (cached) {
      return JSON.parse(cached);
    }
  } catch (err) {
    // Cache indisponível não deve derrubar a funcionalidade (Manual Parte 3:
    // a plataforma deve continuar funcionando mesmo se o cache falhar).
    logger.warn('Falha ao ler cache de ranking, seguindo direto para o banco', { error: err.message });
  }

  const rows = await repository.getTopRanking(weekStart, limit);
  const result = await Promise.all(
    rows.map(async (r) => {
      const levelInfo = await levelService.calculateLevel(Number(r.xp_total));
      return {
        position: r.position,
        userId: r.user_id,
        name: r.name,
        avatarUrl: r.avatar_url,
        xpEarned: Number(r.xp_earned),
        // "Nível" pedido na especificação de cache (docx "REDIS CACHE E CRON
        // JOBS", Seção 1) — nível geral do usuário, calculado a partir do XP
        // total (vitalício), diferente do xpEarned (só da semana do ranking).
        level: levelInfo.level,
        // Moldura de perfil comprada na Loja (docx "SISTEMA DE ECONOMIA E
        // RECOMPENSAS"): sem isso, o item de status nunca aparecia para
        // ninguém além do próprio dono, esvaziando o propósito do item.
        avatarFrame: r.equipped_avatar_frame,
      };
    })
  );

  try {
    await redis.set(cacheKey, JSON.stringify(result), 'EX', CACHE_TTL_SECONDS);
  } catch (err) {
    logger.warn('Falha ao gravar cache de ranking', { error: err.message });
  }

  return result;
}

async function getMyPosition(userId) {
  const weekStart = repository.currentWeekStartDate();
  const cacheKey = myPositionCacheKey(weekStart, userId);

  try {
    const cached = await redis.get(cacheKey);
    if (cached) {
      return JSON.parse(cached);
    }
  } catch (err) {
    logger.warn('Falha ao ler cache de posição no ranking, seguindo direto para o banco', { error: err.message });
  }

  const row = await repository.getUserPosition(userId, weekStart);
  const result = row ? { position: row.position, xpEarned: Number(row.xp_earned) } : { position: null, xpEarned: 0 };

  // Sem invalidação explícita aqui de propósito: `weekly_rankings` só muda
  // pelo CRON de recomputeWeeklyRanking (a cada hora — ver src/queue/definitions.js),
  // então a mesma janela de 5 min já usada em getTopRanking não piora a
  // frescura dos dados. Invalidar ativamente exigiria varrer todas as chaves
  // de posição por usuário a cada recálculo semanal, sem ganho real de UX.
  try {
    await redis.set(cacheKey, JSON.stringify(result), 'EX', CACHE_TTL_SECONDS);
  } catch (err) {
    logger.warn('Falha ao gravar cache de posição no ranking', { error: err.message });
  }

  return result;
}

/**
 * Recalcula o ranking da semana atual e invalida o cache.
 * Chamado pelo CRON job (src/cron/jobs/recomputeWeeklyRanking.js).
 */
async function recomputeCurrentWeek() {
  const weekStart = repository.currentWeekStartDate();
  await repository.recomputeWeeklyRanking(weekStart);

  try {
    await redis.del(topRankingCacheKey(weekStart));
  } catch (err) {
    logger.warn('Falha ao invalidar cache de ranking após recálculo', { error: err.message });
  }

  return { weekStart };
}

module.exports = { getTopRanking, getMyPosition, recomputeCurrentWeek };
