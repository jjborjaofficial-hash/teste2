const db = require('../../../config/database');
const configRepository = require('../../../common/repositories/systemConfigRepository');
const walletService = require('../../wallet/services/walletService');
const notificationsRepository = require('../../notifications/repositories/notificationsRepository');
const { dateInPlatformTz } = require('../../../common/time/platformTimezone');

/**
 * Bónus de boas-vindas dos 7 primeiros dias (migration 105).
 *
 * Lógica:
 *  - Cada dia, dentro dos 7 primeiros dias corridos da conta, em que o utilizador
 *    ACERTA uma pergunta (estudo real), paga `welcome_bonus_daily_mzn`.
 *  - Ao atingir `welcome_bonus_required_days` dias de estudo, paga UMA vez
 *    `welcome_bonus_completion_mzn` (a "conclusão da semana").
 *  - Fica fora do teto diário de 7,20 MZN e cada dia só paga uma vez
 *    (PRIMARY KEY (user_id, day_index) + INSERT ... ON CONFLICT DO NOTHING).
 *  - Todos os valores vêm de system_config: dá para ajustar sem deploy.
 */
const WINDOW_DAYS = 7;
const COMPLETION_INDEX = 7;

async function loadConfig(executor) {
  const cfg = await configRepository.getConfigValues(
    [
      'welcome_bonus_enabled',
      'welcome_bonus_daily_mzn',
      'welcome_bonus_completion_mzn',
      'welcome_bonus_required_days',
    ],
    executor
  );
  return {
    enabled: cfg.welcome_bonus_enabled !== false && cfg.welcome_bonus_enabled !== 'false',
    dailyMzn: Number(cfg.welcome_bonus_daily_mzn ?? 0.5),
    completionMzn: Number(cfg.welcome_bonus_completion_mzn ?? 3.5),
    requiredDays: Number(cfg.welcome_bonus_required_days ?? 5),
  };
}

/** Dia da conta (0 = dia do cadastro) no fuso de Moçambique; null se o utilizador não existe. */
async function getAccountDayIndex(executor, userId) {
  const { rows } = await executor.query(
    `SELECT (${dateInPlatformTz('now()')} - ${dateInPlatformTz('created_at')})::int AS day_index
     FROM users WHERE id = $1 AND deleted_at IS NULL AND status = 'active'`,
    [userId]
  );
  return rows[0] ? rows[0].day_index : null;
}

/**
 * Chamado pelo quiz após uma resposta CORRETA, dentro da mesma transação.
 * Nunca lança por regra de negócio: o bónus jamais pode impedir uma resposta de ser registada.
 */
async function registerStudyDay(executor, userId) {
  const cfg = await loadConfig(executor);
  if (!cfg.enabled) return null;

  const dayIndex = await getAccountDayIndex(executor, userId);
  if (dayIndex === null || dayIndex < 0 || dayIndex >= WINDOW_DAYS) return null;

  // Um pagamento por dia: só o primeiro acerto do dia insere a linha.
  const inserted = await executor.query(
    `INSERT INTO welcome_bonus_days (user_id, day_index, credited_mzn)
     VALUES ($1, $2, $3)
     ON CONFLICT (user_id, day_index) DO NOTHING
     RETURNING day_index`,
    [userId, dayIndex, cfg.dailyMzn]
  );
  if (inserted.rowCount === 0) return null;

  let totalMzn = 0;
  if (cfg.dailyMzn > 0) {
    await walletService.creditReward(
      {
        userId,
        amountMzn: cfg.dailyMzn,
        source: 'welcome_bonus_day',
        referenceId: null,
        metadata: { dayNumber: dayIndex + 1 },
        ignoreDailyCap: true,
      },
      executor
    );
    totalMzn += cfg.dailyMzn;
  }

  // Bónus de conclusão: uma única vez, ao atingir o mínimo de dias de estudo.
  const { rows } = await executor.query(
    `SELECT count(*)::int AS studied FROM welcome_bonus_days WHERE user_id = $1 AND day_index < $2`,
    [userId, WINDOW_DAYS]
  );
  let completed = false;
  if (rows[0].studied >= cfg.requiredDays) {
    const done = await executor.query(
      `INSERT INTO welcome_bonus_days (user_id, day_index, credited_mzn)
       VALUES ($1, $2, $3)
       ON CONFLICT (user_id, day_index) DO NOTHING
       RETURNING day_index`,
      [userId, COMPLETION_INDEX, cfg.completionMzn]
    );
    if (done.rowCount > 0 && cfg.completionMzn > 0) {
      await walletService.creditReward(
        {
          userId,
          amountMzn: cfg.completionMzn,
          source: 'welcome_bonus_completion',
          referenceId: null,
          metadata: { studiedDays: rows[0].studied },
          ignoreDailyCap: true,
        },
        executor
      );
      totalMzn += cfg.completionMzn;
      completed = true;
    }
  }

  const fmt = (v) => v.toFixed(2).replace('.', ',');
  await notificationsRepository.create(executor, {
    userId,
    type: 'system',
    title: completed ? 'Semana de boas-vindas concluída!' : `Bónus de boas-vindas: dia ${dayIndex + 1} de ${WINDOW_DAYS}`,
    body: completed
      ? `Você ganhou +${fmt(totalMzn)} MZN de bónus de boas-vindas. Continue a estudar todos os dias!`
      : `+${fmt(totalMzn)} MZN creditados na sua carteira por estudar hoje.`,
    metadata: { welcomeBonus: true, dayNumber: dayIndex + 1, creditedMzn: totalMzn, completed },
  });

  return { dayNumber: dayIndex + 1, creditedMzn: totalMzn, completed };
}

/** Estado para a interface (cartão do Dashboard). */
async function getStatus(userId) {
  const cfg = await loadConfig(db);
  const dayIndex = await getAccountDayIndex(db, userId);
  const { rows } = await db.query(
    'SELECT day_index, credited_mzn FROM welcome_bonus_days WHERE user_id = $1',
    [userId]
  );

  const studied = new Set(rows.filter((r) => r.day_index < WINDOW_DAYS).map((r) => r.day_index));
  const completed = rows.some((r) => r.day_index === COMPLETION_INDEX);
  const earnedMzn = rows.reduce((sum, r) => sum + Number(r.credited_mzn), 0);
  const inWindow = dayIndex !== null && dayIndex >= 0 && dayIndex < WINDOW_DAYS;

  return {
    // Só aparece enquanto a janela de 7 dias está aberta.
    visible: cfg.enabled && inWindow,
    dayNumber: inWindow ? dayIndex + 1 : null,
    totalDays: WINDOW_DAYS,
    days: Array.from({ length: WINDOW_DAYS }, (_, i) => studied.has(i)),
    studiedDays: studied.size,
    studiedToday: inWindow ? studied.has(dayIndex) : false,
    requiredDays: cfg.requiredDays,
    dailyMzn: cfg.dailyMzn,
    completionMzn: cfg.completionMzn,
    maxTotalMzn: Math.round((cfg.dailyMzn * WINDOW_DAYS + cfg.completionMzn) * 100) / 100,
    earnedMzn: Math.round(earnedMzn * 100) / 100,
    completed,
  };
}

module.exports = { registerStudyDay, getStatus, WINDOW_DAYS };
