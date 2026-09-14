/**
 * CRON Job: revalidação de saques pendentes (docx "REDIS CACHE E CRON JOBS",
 * Cron Job 3 — "Processamento de saques").
 *
 * ⚠️ Adaptação deliberada: este job NUNCA aprova, rejeita ou paga um saque
 * automaticamente — o pagamento continua 100% manual, por decisão explícita
 * do proprietário do projeto (ver `walletService.js` e `adminService.js`).
 * O que este job faz é:
 *   1. Revalidar pedidos "pending_review" contra o status/Trust Score ATUAL
 *      do usuário (que pode ter mudado DEPOIS do pedido ter sido feito) —
 *      suspendendo automaticamente para revisão qualquer pedido cujo usuário
 *      tenha sido suspenso ou cujo Trust Score tenha caído abaixo do mínimo
 *      desde a solicitação.
 *   2. Alertar o admin financeiro quando um pedido ultrapassa o SLA de 24h
 *      prometido ao usuário na confirmação imediata.
 *
 * Frequência recomendada: a cada 15 minutos.
 * Uso manual: node src/cron/jobs/revalidateWithdrawals.js
 */
require('dotenv').config();
const logger = require('../../common/logger');
const db = require('../../config/database');
const configRepository = require('../../common/repositories/systemConfigRepository');
const notificationsService = require('../../modules/notifications/services/notificationsService');
const { pool } = require('../../config/database');

const SLA_HOURS = 24;

async function run() {
  logger.info('CRON: iniciando revalidação de saques pendentes');

  const minTrustScore = Number((await configRepository.getConfigValue('min_trust_score_for_withdrawal')) ?? 60);

  const { rows: pending } = await db.query(
    `SELECT wr.id, wr.user_id, wr.amount_mzn, wr.requested_at,
            u.name, u.phone, u.status, u.trust_score
     FROM withdrawal_requests wr
     JOIN users u ON u.id = wr.user_id
     WHERE wr.status = 'pending_review'`
  );

  let autoSuspended = 0;
  let slaAlerts = 0;

  for (const w of pending) {
    const needsSuspension = w.status !== 'active' || w.trust_score < minTrustScore;

    if (needsSuspension) {
      const reason =
        w.status !== 'active'
          ? `Conta do usuário deixou de estar ativa (status atual: ${w.status}) após a solicitação do saque.`
          : `Trust Score caiu para ${w.trust_score} (abaixo do mínimo de ${minTrustScore}) após a solicitação do saque.`;

      // eslint-disable-next-line no-await-in-loop
      const client = await db.getClient();
      try {
        await client.query('BEGIN');
        await client.query(
          `UPDATE withdrawal_requests SET status = 'suspended_for_review', rejection_reason = $2 WHERE id = $1`,
          [w.id, reason]
        );
        await client.query('COMMIT');
        autoSuspended += 1;
        logger.warn('CRON: saque suspenso automaticamente para revisão', { withdrawalId: w.id, reason });
      } catch (err) {
        await client.query('ROLLBACK');
        logger.error('CRON: falha ao suspender saque automaticamente', { withdrawalId: w.id, error: err.message });
      } finally {
        client.release();
      }
      continue; // já tratado — não precisa checar SLA de algo que acabou de ser suspenso
    }

    const hoursPending = (Date.now() - new Date(w.requested_at).getTime()) / 3600000;
    if (hoursPending > SLA_HOURS) {
      // Evita spam: só reenvia o alerta a cada 6h de atraso, não a cada
      // execução do CRON (que roda a cada 15 min).
      // eslint-disable-next-line no-await-in-loop
      const { rows: recentAlerts } = await db.query(
        `SELECT 1 FROM notifications
         WHERE type = 'withdrawal_sla_risk'
           AND metadata->>'withdrawalId' = $1
           AND created_at > now() - INTERVAL '6 hours'
         LIMIT 1`,
        [w.id]
      );
      if (recentAlerts.length > 0) continue;

      // eslint-disable-next-line no-await-in-loop
      await notificationsService.notifyAdminsWithdrawalSlaRisk(db, {
        withdrawalId: w.id,
        userName: w.name,
        userPhone: w.phone,
        amountMzn: Number(w.amount_mzn),
        hoursPending: Math.floor(hoursPending),
      });
      slaAlerts += 1;
    }
  }

  logger.info('CRON: revalidação de saques concluída', {
    totalPendentes: pending.length,
    suspensosAutomaticamente: autoSuspended,
    alertasDeSla: slaAlerts,
  });
}

module.exports = run;

if (require.main === module) {
  run()
    .catch((err) => {
      logger.error('CRON: falha na revalidação de saques', { error: err.message });
      process.exitCode = 1;
    })
    .finally(() => pool.end());
}
