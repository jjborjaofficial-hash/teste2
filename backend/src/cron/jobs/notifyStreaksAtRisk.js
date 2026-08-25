/**
 * CRON Job: notifica usuários cujo streak está em risco de quebrar hoje
 * (Doc. Mestre Seção 9 — "Quase lá! Sua ocorrência de 5 dias está em risco...").
 * Frequência recomendada: uma vez ao fim da tarde/noite, horário local de Moçambique.
 *
 * Uso manual: node src/cron/jobs/notifyStreaksAtRisk.js
 */
require('dotenv').config();
const logger = require('../../common/logger');
const db = require('../../config/database');
const notificationsService = require('../../modules/notifications/services/notificationsService');
const { pool } = require('../../config/database');
const { dateInPlatformTz } = require('../../common/time/platformTimezone');

async function run() {
  logger.info('CRON: verificando streaks em risco');

  // Em risco = teve atividade ontem, ainda não teve atividade hoje, e streak
  // atual > 0. "Ontem" calculado no fuso oficial da plataforma (Moçambique).
  const { rows } = await db.query(
    `SELECT user_id, current_streak_days
     FROM streaks
     WHERE last_activity_date = (${dateInPlatformTz('now()')} - INTERVAL '1 day')::date
       AND current_streak_days > 0`
  );

  let notified = 0;
  for (const row of rows) {
    // eslint-disable-next-line no-await-in-loop
    await notificationsService.notifyStreakAtRisk(db, row.user_id, row.current_streak_days);
    notified += 1;
  }

  logger.info(`CRON: ${notified} usuário(s) notificado(s) sobre streak em risco`);
}

run()
  .catch((err) => {
    logger.error('CRON: falha ao notificar streaks em risco', { error: err.message });
    process.exitCode = 1;
  })
  .finally(() => pool.end());
