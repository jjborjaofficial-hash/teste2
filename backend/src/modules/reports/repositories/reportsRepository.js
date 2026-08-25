const db = require('../../../config/database');

/**
 * Repository do módulo Relatórios (docx "REDIS CACHE E CRON JOBS", Cron Job 5).
 */

async function computeDailyMetrics(reportDate, executor = db) {
  const [newUsers, activeUsers, rewards, withdrawals, suspicious] = await Promise.all([
    executor.query(
      `SELECT COUNT(*)::int AS count FROM users WHERE created_at::date = $1 AND deleted_at IS NULL`,
      [reportDate]
    ),
    executor.query(`SELECT COUNT(*)::int AS count FROM users WHERE last_login_at::date = $1`, [reportDate]),
    executor.query(
      `SELECT COALESCE(SUM(amount_mzn), 0) AS total
       FROM wallet_transactions
       WHERE type = 'credit' AND status = 'confirmed' AND created_at::date = $1`,
      [reportDate]
    ),
    executor.query(
      `SELECT COUNT(*)::int AS count, COALESCE(SUM(amount_mzn), 0) AS total
       FROM withdrawal_requests
       WHERE requested_at::date = $1`,
      [reportDate]
    ),
    executor.query(
      `SELECT COUNT(*)::int AS count
       FROM trust_score_history
       WHERE new_score < previous_score AND created_at::date = $1`,
      [reportDate]
    ),
  ]);

  return {
    newUsersCount: newUsers.rows[0].count,
    activeUsersCount: activeUsers.rows[0].count,
    totalRewardsDistributedMzn: Number(rewards.rows[0].total),
    totalWithdrawalsCount: withdrawals.rows[0].count,
    totalWithdrawalsAmountMzn: Number(withdrawals.rows[0].total),
    suspiciousActivityCount: suspicious.rows[0].count,
  };
}

async function upsertReport(reportDate, metrics, executor = db) {
  const { rows } = await executor.query(
    `INSERT INTO admin_daily_reports
        (report_date, new_users_count, active_users_count, total_rewards_distributed_mzn,
         total_withdrawals_count, total_withdrawals_amount_mzn, suspicious_activity_count)
     VALUES ($1, $2, $3, $4, $5, $6, $7)
     ON CONFLICT (report_date) DO UPDATE SET
        new_users_count = EXCLUDED.new_users_count,
        active_users_count = EXCLUDED.active_users_count,
        total_rewards_distributed_mzn = EXCLUDED.total_rewards_distributed_mzn,
        total_withdrawals_count = EXCLUDED.total_withdrawals_count,
        total_withdrawals_amount_mzn = EXCLUDED.total_withdrawals_amount_mzn,
        suspicious_activity_count = EXCLUDED.suspicious_activity_count,
        generated_at = now()
     RETURNING *`,
    [
      reportDate,
      metrics.newUsersCount,
      metrics.activeUsersCount,
      metrics.totalRewardsDistributedMzn,
      metrics.totalWithdrawalsCount,
      metrics.totalWithdrawalsAmountMzn,
      metrics.suspiciousActivityCount,
    ]
  );
  return rows[0];
}

async function listReports({ limit = 30, offset = 0 } = {}, executor = db) {
  const { rows } = await executor.query(
    `SELECT * FROM admin_daily_reports ORDER BY report_date DESC LIMIT $1 OFFSET $2`,
    [limit, offset]
  );
  return rows;
}

module.exports = { computeDailyMetrics, upsertReport, listReports };
