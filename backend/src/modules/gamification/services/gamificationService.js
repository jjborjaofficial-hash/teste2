const db = require('../../../config/database');
const levelService = require('./levelService');
const userCache = require('../../../common/cache/userCache');
const { NotFoundError } = require('../../../common/errors/AppError');

/**
 * Agrega XP, Nível e Streak para a tela de status do usuário (Doc. Mestre
 * Seção 6 — "Centro de Comando"). O streak usa cache-aside (docx "REDIS CACHE
 * E CRON JOBS", Seção 3): é lido a cada abertura do app, mas só muda uma vez
 * por dia de atividade real — caso ideal de cache.
 */
async function getMyStatus(userId) {
  const { rows } = await db.query(
    'SELECT xp_total, points_balance FROM users WHERE id = $1 AND deleted_at IS NULL',
    [userId]
  );
  if (!rows[0]) throw new NotFoundError('Usuário não encontrado.');

  const levelInfo = await levelService.calculateLevel(Number(rows[0].xp_total));

  const streak = await userCache.getOrSetStreak(userId, async () => {
    const streakResult = await db.query(
      'SELECT current_streak_days, longest_streak_days, protection_active, last_activity_date FROM streaks WHERE user_id = $1',
      [userId]
    );
    const row = streakResult.rows[0] || {
      current_streak_days: 0,
      longest_streak_days: 0,
      protection_active: false,
      last_activity_date: null,
    };
    return {
      currentDays: row.current_streak_days,
      longestDays: row.longest_streak_days,
      protectionActive: row.protection_active,
      lastActivityDate: row.last_activity_date,
    };
  });

  return {
    xpTotal: Number(rows[0].xp_total),
    pointsBalance: Number(rows[0].points_balance),
    level: levelInfo.level,
    xpIntoCurrentLevel: levelInfo.xpIntoCurrentLevel,
    xpToNextLevel: levelInfo.xpToNextLevel,
    xpStep: levelInfo.xpStep,
    streak: {
      currentDays: streak.currentDays,
      longestDays: streak.longestDays,
      protectionActive: streak.protectionActive,
    },
  };
}

module.exports = { getMyStatus };
