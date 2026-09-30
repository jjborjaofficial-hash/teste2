const db = require('../../../config/database');
const configRepository = require('../../../common/repositories/systemConfigRepository');
const walletService = require('../../wallet/services/walletService');
const notificationsRepository = require('../../notifications/repositories/notificationsRepository');
const { dateInPlatformTz } = require('../../../common/time/platformTimezone');
const { BusinessRuleError, NotFoundError } = require('../../../common/errors/AppError');

/**
 * Calendário de recompensas de boas-vindas (migration 106).
 *
 * - Janela: 7 dias corridos a partir do cadastro (dia do cadastro = dia 1), fuso de Moçambique.
 * - Cada dia só pode ser coletado no próprio dia. Faltou? Esse dia fica BLOQUEADO e o
 *   calendário segue para o dia seguinte (que tem a sua própria recompensa — nada é empurrado).
 * - Fora do teto diário de 7,20 MZN e independente de missões/streak.
 * - Valores em system_config (`welcome_rewards_mzn`), dia 1 = 2,00 MZN.
 */
const TOTAL_DAYS = 7;
const DEFAULT_REWARDS = [2.0, 1.0, 1.0, 1.5, 1.5, 2.0, 3.0];

async function loadConfig(executor) {
  const cfg = await configRepository.getConfigValues(
    ['welcome_rewards_enabled', 'welcome_rewards_mzn'],
    executor
  );
  const list = Array.isArray(cfg.welcome_rewards_mzn) ? cfg.welcome_rewards_mzn : DEFAULT_REWARDS;
  const rewards = Array.from({ length: TOTAL_DAYS }, (_, i) => Number(list[i] ?? DEFAULT_REWARDS[i]));
  return {
    enabled: cfg.welcome_rewards_enabled !== false && cfg.welcome_rewards_enabled !== 'false',
    rewards,
  };
}

/** Número do dia da conta (1 = dia do cadastro) no fuso de Moçambique; null se a conta não está ativa. */
async function getAccountDayNumber(executor, userId) {
  const { rows } = await executor.query(
    `SELECT (${dateInPlatformTz('now()')} - ${dateInPlatformTz('created_at')})::int + 1 AS day_number
     FROM users WHERE id = $1 AND deleted_at IS NULL AND status = 'active'`,
    [userId]
  );
  return rows[0] ? rows[0].day_number : null;
}

async function getStatus(userId) {
  const cfg = await loadConfig(db);
  const dayNumber = await getAccountDayNumber(db, userId);
  if (dayNumber === null) throw new NotFoundError('Usuário não encontrado.');

  const { rows } = await db.query('SELECT day_number FROM welcome_rewards WHERE user_id = $1', [userId]);
  const claimed = new Set(rows.map((r) => r.day_number));
  const windowOpen = dayNumber >= 1 && dayNumber <= TOTAL_DAYS;

  const days = cfg.rewards.map((amountMzn, i) => {
    const n = i + 1;
    let status;
    if (claimed.has(n)) status = 'claimed';
    else if (dayNumber > n) status = 'missed'; // dia passou sem coletar: bloqueado
    else if (dayNumber === n) status = 'available';
    else status = 'locked'; // ainda vai chegar
    return { day: n, amountMzn, status };
  });

  return {
    // Só aparece enquanto o calendário está aberto (dia 1 a 7 da conta).
    visible: cfg.enabled && windowOpen,
    dayNumber: windowOpen ? dayNumber : null,
    days,
    claimedMzn: Math.round(days.filter((d) => d.status === 'claimed').reduce((s, d) => s + d.amountMzn, 0) * 100) / 100,
    remainingMzn: Math.round(days.filter((d) => d.status === 'available' || d.status === 'locked').reduce((s, d) => s + d.amountMzn, 0) * 100) / 100,
  };
}

/** Coleta a recompensa do dia de HOJE. Dias passados não podem ser coletados. */
async function claimToday(userId) {
  const client = await db.pool.connect();
  try {
    await client.query('BEGIN');

    const cfg = await loadConfig(client);
    if (!cfg.enabled) throw new BusinessRuleError('O bónus de boas-vindas não está disponível.');

    const dayNumber = await getAccountDayNumber(client, userId);
    if (dayNumber === null) throw new NotFoundError('Usuário não encontrado.');
    if (dayNumber < 1 || dayNumber > TOTAL_DAYS) {
      throw new BusinessRuleError('O período de boas-vindas (7 dias) já terminou.');
    }

    const amountMzn = cfg.rewards[dayNumber - 1];

    // Uma coleta por dia: a PK impede duplicar mesmo com cliques simultâneos.
    const inserted = await client.query(
      `INSERT INTO welcome_rewards (user_id, day_number, amount_mzn)
       VALUES ($1, $2, $3)
       ON CONFLICT (user_id, day_number) DO NOTHING
       RETURNING day_number`,
      [userId, dayNumber, amountMzn]
    );
    if (inserted.rowCount === 0) {
      throw new BusinessRuleError('A recompensa de hoje já foi coletada. Volte amanhã!');
    }

    await walletService.creditReward(
      {
        userId,
        amountMzn,
        source: 'welcome_reward',
        referenceId: null,
        metadata: { dayNumber },
        ignoreDailyCap: true,
      },
      client
    );

    await notificationsRepository.create(client, {
      userId,
      type: 'system',
      title: `Bónus de boas-vindas: dia ${dayNumber} de ${TOTAL_DAYS}`,
      body: `+${amountMzn.toFixed(2).replace('.', ',')} MZN creditados na sua carteira.`,
      metadata: { welcomeReward: true, dayNumber, amountMzn },
    });

    await client.query('COMMIT');
    return { dayNumber, amountMzn };
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}

module.exports = { getStatus, claimToday, TOTAL_DAYS };
