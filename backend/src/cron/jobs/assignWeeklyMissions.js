/**
 * CRON Job: atribuição semanal de missões (Doc. Mestre Seção 4, 5, 8).
 *
 * PENDÊNCIA FECHADA: este job não existia. `assignDailyMissions.js` já
 * documentava a lacuna: "não existe ainda um job equivalente para
 * `type = 'weekly'` ... enquanto isso não existir, o catálogo só deve
 * conter missões 'daily'". Este arquivo resolve exatamente isso, seguindo
 * a mesma estratégia (INSERT...SELECT em lote, idempotente) e reutilizando
 * `currentWeekStartDate()` do módulo Ranking — a MESMA definição de "início
 * da semana" (domingo, fuso de Moçambique) usada no ranking semanal e na
 * elegibilidade do selo "Top 10" da Loja, para as três coisas nunca
 * divergirem sobre em que semana estamos.
 *
 * Idempotência: `period_date` = data de início da semana corrente. A
 * UNIQUE(user_id, mission_id, period_date) da migration 022 garante que
 * rodar este job mais de uma vez na mesma semana não duplica nada.
 *
 * Frequência recomendada: uma vez por semana, domingo à 00:10 (Moçambique) —
 * 10 minutos depois de `assignDailyMissions`, para não competir pelo mesmo
 * lock de escrita em `user_missions` no mesmo instante.
 * Uso manual: node src/cron/jobs/assignWeeklyMissions.js
 */
require('dotenv').config();
const logger = require('../../common/logger');
const db = require('../../config/database');
const { pool } = require('../../config/database');
const { currentWeekStartDate } = require('../../modules/ranking/repositories/rankingRepository');

async function run() {
  logger.info('CRON: iniciando atribuição semanal de missões (lote)');

  const weekStart = currentWeekStartDate();

  const { rowCount } = await db.query(
    `
    INSERT INTO user_missions (user_id, mission_id, target_snapshot, period_date)
    SELECT u.id, m.id, m.target_quiz_count, $1
    FROM users u
    CROSS JOIN missions m
    WHERE u.deleted_at IS NULL
      AND u.status = 'active'
      AND m.is_active = TRUE
      AND m.type = 'weekly'
      AND (m.starts_at IS NULL OR m.starts_at <= now())
      AND (m.ends_at IS NULL OR m.ends_at >= now())
    ON CONFLICT DO NOTHING
  `,
    [weekStart]
  );

  logger.info(`CRON: ${rowCount} nova(s) atribuição(ões) de missão semanal criada(s)`, { weekStart });
}

module.exports = run;

if (require.main === module) {
  run()
    .catch((err) => {
      logger.error('CRON: falha na atribuição semanal de missões', { error: err.message });
      process.exitCode = 1;
    })
    .finally(() => pool.end());
}
