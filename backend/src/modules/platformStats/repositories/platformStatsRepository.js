const db = require('../../../config/database');

/**
 * Repository do módulo de Estatísticas Públicas (prova social do
 * Onboarding e do Dashboard — Doc. Mestre Seção 19.1 e 19.2).
 *
 * Substitui os números fixos ("12.000+ ativos • 46.000+ MZN
 * distribuídos") por valores reais, calculados a partir do banco.
 * Segue o mesmo padrão de query de reportsRepository.computeDailyMetrics,
 * mas sem filtro de data (total histórico da plataforma) e sem exigir
 * autenticação (esta tela é vista ANTES do login).
 */

async function getPlatformStats(executor = db) {
  const [activeUsers, rewards] = await Promise.all([
    executor.query(`SELECT COUNT(*)::int AS count FROM users WHERE deleted_at IS NULL`),
    executor.query(
      `SELECT COALESCE(SUM(amount_mzn), 0) AS total
       FROM wallet_transactions
       WHERE type = 'credit' AND status = 'confirmed'`
    ),
  ]);

  return {
    activeUsersCount: activeUsers.rows[0].count,
    totalRewardsDistributedMzn: Number(rewards.rows[0].total),
  };
}

module.exports = { getPlatformStats };
