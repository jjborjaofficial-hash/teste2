/**
 * CRON Job: atribuição diária de missões (Doc. Mestre Seção 20).
 *
 * Implementado como um único INSERT...SELECT (produto cartesiano usuários x missões
 * ativas, com ON CONFLICT DO NOTHING), em vez de uma query por combinação usuário/missão.
 * Isso responde à pergunta do Manual Parte 1 ("esta solução continua adequada com
 * centenas de milhares ou milhões de usuários?") com "sim": é uma única operação de
 * banco, e o índice único `uq_user_mission_active` (migration 006) garante que a
 * atribuição duplicada seja ignorada de forma barata pelo próprio Postgres.
 *
 * Frequência recomendada: uma vez por dia, à meia-noite (horário de Moçambique).
 * Uso manual: node src/cron/jobs/assignDailyMissions.js
 */
require('dotenv').config();
const logger = require('../../common/logger');
const db = require('../../config/database');
const { pool } = require('../../config/database');
const { dateInPlatformTz } = require('../../common/time/platformTimezone');

async function run() {
  logger.info('CRON: iniciando atribuição diária de missões (lote)');

  // target_snapshot (migration 022, NOT NULL): alvo da missão "congelado" no
  // momento da atribuição — se o admin editar target_quiz_count depois, não
  // afeta quem já está com a missão em andamento (ver comentário da migration).
  //
  // period_date: preenchido explicitamente com o fuso oficial da plataforma
  // (Moçambique) em vez de confiar no DEFAULT CURRENT_DATE da coluna, que
  // resolveria a data no fuso do servidor Postgres (normalmente UTC) — mesma
  // classe de bug já corrigida em walletRepository/quizRepository/streakService.
  const { rowCount } = await db.query(`
    INSERT INTO user_missions (user_id, mission_id, target_snapshot, period_date)
    SELECT u.id, m.id, m.target_quiz_count, ${dateInPlatformTz('now()')}
    FROM users u
    CROSS JOIN missions m
    WHERE u.deleted_at IS NULL
      AND u.status = 'active'
      AND m.is_active = TRUE
      AND (m.starts_at IS NULL OR m.starts_at <= now())
      AND (m.ends_at IS NULL OR m.ends_at >= now())
    ON CONFLICT DO NOTHING
  `);

  logger.info(`CRON: ${rowCount} nova(s) atribuição(ões) de missão criada(s)`);
}

run()
  .catch((err) => {
    logger.error('CRON: falha na atribuição diária de missões', { error: err.message });
    process.exitCode = 1;
  })
  .finally(() => pool.end());
