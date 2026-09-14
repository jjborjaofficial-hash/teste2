/**
 * CRON Job: expira missões vencidas (Doc. Mestre Seção 20 — mesma lacuna de CRON Jobs).
 * Missões do tipo 'daily'/'weekly' com `ends_at` no passado e que o usuário não
 * completou a tempo são marcadas como 'expired', liberando espaço para novas
 * atribuições e mantendo a listagem de missões do usuário limpa.
 *
 * Frequência recomendada: uma vez por dia, logo após a atribuição diária.
 * Uso manual: node src/cron/jobs/expireMissions.js
 */
require('dotenv').config();
const logger = require('../../common/logger');
const db = require('../../config/database');
const { pool } = require('../../config/database');
const { dateInPlatformTz } = require('../../common/time/platformTimezone');

async function run() {
  logger.info('CRON: expirando missões vencidas');

  // Caso 1: missões com prazo definido no nível do template (weekly/special)
  // cujo ends_at já passou.
  const byEndsAt = await db.query(
    `UPDATE user_missions um
     SET status = 'expired'
     FROM missions m
     WHERE um.mission_id = m.id
       AND um.status = 'in_progress'
       AND m.ends_at IS NOT NULL
       AND m.ends_at < now()`
  );

  // Caso 2: missões diárias (sem ends_at no template) cujo period_date da
  // atribuição já não é "hoje" no fuso da plataforma. Sem isso, uma missão
  // diária não completada nunca expira — e a UNIQUE(user_id, mission_id)
  // WHERE status IN ('in_progress','completed') (migration 006) bloqueia
  // silenciosamente a atribuição do dia seguinte via ON CONFLICT DO NOTHING,
  // travando o usuário na missão de ontem para sempre.
  const byPeriodDate = await db.query(
    `UPDATE user_missions um
     SET status = 'expired'
     FROM missions m
     WHERE um.mission_id = m.id
       AND um.status = 'in_progress'
       AND m.ends_at IS NULL
       AND um.period_date < ${dateInPlatformTz('now()')}`
  );

  const totalExpired = byEndsAt.rowCount + byPeriodDate.rowCount;
  logger.info(`CRON: ${totalExpired} missão(ões) de usuário marcada(s) como expirada(s) (${byEndsAt.rowCount} por prazo do template, ${byPeriodDate.rowCount} por virada de dia)`);
}

module.exports = run;

if (require.main === module) {
  run()
    .catch((err) => {
      logger.error('CRON: falha ao expirar missões', { error: err.message });
      process.exitCode = 1;
    })
    .finally(() => pool.end());
}
