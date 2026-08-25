const repository = require('../repositories/reportsRepository');

/**
 * Service do módulo Relatórios (docx "REDIS CACHE E CRON JOBS", Cron Job 5:
 * "Novos usuários cadastrados; Usuários ativos; Receita de publicidade; Total
 * de recompensas distribuídas; Total de saques; Atividades suspeitas").
 */

function mapReport(r) {
  return {
    id: r.id,
    reportDate: r.report_date,
    newUsersCount: r.new_users_count,
    activeUsersCount: r.active_users_count,
    // null enquanto não existir integração real de publicidade (ver README).
    adRevenueMzn: r.ad_revenue_mzn !== null ? Number(r.ad_revenue_mzn) : null,
    totalRewardsDistributedMzn: Number(r.total_rewards_distributed_mzn),
    totalWithdrawalsCount: r.total_withdrawals_count,
    totalWithdrawalsAmountMzn: Number(r.total_withdrawals_amount_mzn),
    suspiciousActivityCount: r.suspicious_activity_count,
    generatedAt: r.generated_at,
  };
}

/**
 * Gera (ou regenera) o relatório de um dia específico. Chamado pelo CRON
 * (`src/cron/jobs/generateDailyReport.js`), sempre para o dia anterior — o dia
 * atual ainda não terminou, então gerar hoje mesmo dia daria números parciais.
 */
async function generateReportForDate(reportDate) {
  const metrics = await repository.computeDailyMetrics(reportDate);
  const saved = await repository.upsertReport(reportDate, metrics);
  return mapReport(saved);
}

async function listReports(pagination) {
  const rows = await repository.listReports(pagination);
  return rows.map(mapReport);
}

module.exports = { generateReportForDate, listReports };
