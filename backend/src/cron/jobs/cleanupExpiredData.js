/**
 * CRON Job: limpeza automática (docx "REDIS CACHE E CRON JOBS", Cron Job 4).
 *
 * ⚠️ Adaptação deliberada: a especificação original pede remover "códigos OTP
 * expirados" — este projeto ainda não implementa verificação por OTP (ver
 * README, seção "O que ainda não está implementado"), então esse passo é
 * pulado por enquanto e ficará pronto para ativar quando o módulo de OTP for
 * criado (bastaria adicionar aqui: DELETE FROM otp_codes WHERE expires_at < now()).
 *
 * O que este job remove de fato:
 *   - refresh_tokens expirados ou revogados há mais de 30 dias (não são mais
 *     utilizáveis de qualquer forma — mantê-los só ocupa espaço).
 *   - login_attempts com mais de 90 dias (dado operacional de rate-limiting,
 *     não é dado financeiro nem de auditoria jurídica — pode ser podado).
 *   - notificações já lidas com mais de 90 dias.
 *
 * NUNCA remove (por design, mesmo que "logs" apareça na especificação
 * original): audit_logs, user_legal_acceptances, wallet_transactions — todos
 * são livros-razão append-only, exigidos para auditoria jurídica e financeira
 * (Manual do Desenvolvedor, Parte 4; docx jurídico, Parte 13).
 *
 * Frequência recomendada: todos os dias às 03:00 (GMT+2).
 * Uso manual: node src/cron/jobs/cleanupExpiredData.js
 */
require('dotenv').config();
const logger = require('../../common/logger');
const db = require('../../config/database');
const { pool } = require('../../config/database');

async function run() {
  logger.info('CRON: iniciando limpeza automática de dados temporários');

  const refreshTokens = await db.query(
    `DELETE FROM refresh_tokens
     WHERE expires_at < now()
        OR (revoked_at IS NOT NULL AND revoked_at < now() - INTERVAL '30 days')`
  );

  const loginAttempts = await db.query(
    `DELETE FROM login_attempts WHERE attempted_at < now() - INTERVAL '90 days'`
  );

  const oldNotifications = await db.query(
    `DELETE FROM notifications WHERE read_at IS NOT NULL AND read_at < now() - INTERVAL '90 days'`
  );

  logger.info('CRON: limpeza automática concluída', {
    refreshTokensRemovidos: refreshTokens.rowCount,
    loginAttemptsRemovidos: loginAttempts.rowCount,
    notificacoesRemovidas: oldNotifications.rowCount,
  });
}

run()
  .catch((err) => {
    logger.error('CRON: falha na limpeza automática', { error: err.message });
    process.exitCode = 1;
  })
  .finally(() => pool.end());
