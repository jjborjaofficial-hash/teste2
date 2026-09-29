const db = require('../../../config/database');
const levelService = require('./levelService');
const userCache = require('../../../common/cache/userCache');
const userRepository = require('../../users/repositories/userRepository');
const streakService = require('./streakService');
const { todayInPlatformTz, diffInCalendarDays } = require('../../../common/time/platformTimezone');
const { NotFoundError } = require('../../../common/errors/AppError');

/**
 * Agrega XP, Nível e Streak para a tela de status do usuário (Doc. Mestre
 * Seção 6 — "Centro de Comando"). O streak usa cache-aside (docx "REDIS CACHE
 * E CRON JOBS", Seção 3): é lido a cada abertura do app, mas só muda uma vez
 * por dia de atividade real — caso ideal de cache.
 *
 * CORREÇÃO: antes, este endpoint lia `xp_total`/`points_balance` direto do
 * banco a cada chamada, apesar de `xpService.addXpAndPoints` já invalidar
 * `userCache.invalidateProfile(userId)` após todo crédito — ou seja, a
 * invalidação já existia e funcionava, mas era órfã aqui: não tinha nenhum
 * cache correspondente escutando essa chave neste service (só existia em
 * `userService.getProfile`, endpoint diferente — `GET /users/me`). Ambos os
 * endpoints agora leem exatamente do mesmo cache, sem duplicar dado nem
 * lógica de invalidação nova.
 */
async function getMyStatus(userId) {
  const profile = await userCache.getOrSetProfile(userId, () => userRepository.findProfileById(userId));
  if (!profile) throw new NotFoundError('Usuário não encontrado.');

  const levelInfo = await levelService.calculateLevel(Number(profile.xp_total));

  const loadStreak = () => userCache.getOrSetStreak(userId, async () => {
    const streakResult = await db.query(
      `SELECT current_streak_days, longest_streak_days, protection_active, last_activity_date,
              broken_at, pre_break_streak_days
       FROM streaks WHERE user_id = $1`,
      [userId]
    );
    const row = streakResult.rows[0] || {
      current_streak_days: 0,
      longest_streak_days: 0,
      protection_active: false,
      last_activity_date: null,
      broken_at: null,
      pre_break_streak_days: null,
    };
    return {
      currentDays: row.current_streak_days,
      longestDays: row.longest_streak_days,
      protectionActive: row.protection_active,
      lastActivityDate: row.last_activity_date,
      brokenAt: row.broken_at,
      preBreakDays: row.pre_break_streak_days,
    };
  });

  let streak = await loadStreak();

  // Streak com mais de 1 dia sem atividade: quebra AGORA (não espera o CRON nem a
  // próxima atividade). O cache guarda lastActivityDate, então a checagem é barata.
  if (streak.currentDays > 0 && streak.lastActivityDate) {
    const d = new Date(streak.lastActivityDate);
    const lastStr = `${d.getUTCFullYear()}-${String(d.getUTCMonth() + 1).padStart(2, '0')}-${String(d.getUTCDate()).padStart(2, '0')}`;
    if (diffInCalendarDays(todayInPlatformTz(), lastStr) > 1) {
      await streakService.reconcileExpiredStreak(db, userId);
      streak = await loadStreak();
    }
  }

  return {
    xpTotal: Number(profile.xp_total),
    pointsBalance: Number(profile.points_balance),
    level: levelInfo.level,
    xpIntoCurrentLevel: levelInfo.xpIntoCurrentLevel,
    xpToNextLevel: levelInfo.xpToNextLevel,
    xpStep: levelInfo.xpStep,
    streak: {
      currentDays: streak.currentDays,
      longestDays: streak.longestDays,
      protectionActive: streak.protectionActive,
      // Só preenchidos enquanto o streak está quebrado (broken_at é limpo na próxima
      // atividade). O frontend usa isso para mostrar a animação de streak se partindo.
      brokenAt: streak.currentDays === 0 ? streak.brokenAt : null,
      brokenStreakDays: streak.currentDays === 0 ? streak.preBreakDays : null,
    },
  };
}

module.exports = { getMyStatus };
