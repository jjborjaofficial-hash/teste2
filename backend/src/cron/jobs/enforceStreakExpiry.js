/**
 * CRON Job: reconciliação diária de Streaks (docx "REDIS CACHE E CRON JOBS",
 * Cron Job 1 — "Bônus diário", adaptado às regras de negócio já confirmadas
 * pelo proprietário do projeto).
 *
 * ⚠️ Adaptação deliberada: a especificação original pede "liberar bônus
 * diário" só por estar ativo. Isso contradiz o Aviso Legal já publicado
 * ("recompensas dependem do cumprimento de missões... não constituindo
 * promessa de renda") e os Termos de Uso (recompensa vem de ESTUDAR, não de
 * apenas abrir o app). Este projeto não paga por login — só por atividade
 * educacional real (Doc. Mestre Seção 5). Por isso, este job não credita
 * nada; ele resolve um problema real e concreto do modelo atual: o streak só
 * é recalculado reativamente, na próxima atividade do usuário
 * (`streakService.registerDailyActivity`), então um streak já quebrado
 * continua aparecendo "vivo" para qualquer leitura (perfil, ranking, cache)
 * até o usuário voltar a estudar. Este job corrige isso proativamente, à
 * meia-noite, preservando corretamente o item de proteção do marco de 15 dias.
 *
 * Frequência recomendada: todos os dias às 00:00 (GMT+2).
 * Uso manual: node src/cron/jobs/enforceStreakExpiry.js
 */
require('dotenv').config();
const logger = require('../../common/logger');
const db = require('../../config/database');
const userCache = require('../../common/cache/userCache');
const { pool } = require('../../config/database');
const { dateInPlatformTz } = require('../../common/time/platformTimezone');

async function run() {
  logger.info('CRON: iniciando reconciliação de streaks expirados');

  // Streaks cuja última atividade foi antes de ontem (ou seja, o usuário
  // pulou pelo menos um dia inteiro sem estudar) e que ainda mostram um
  // streak "vivo" (current_streak_days > 0). "Ontem"/"hoje" calculados no
  // fuso oficial da plataforma (Moçambique), não no fuso do servidor.
  const { rows } = await db.query(
    `SELECT user_id, current_streak_days, protection_active, last_activity_date
     FROM streaks
     WHERE current_streak_days > 0
       AND last_activity_date < (${dateInPlatformTz('now()')} - INTERVAL '1 day')::date`
  );

  let broken = 0;
  let protectedCount = 0;

  for (const row of rows) {
    if (row.protection_active) {
      // Item de proteção do marco de 15 dias (Doc. Mestre Seção 5): perdoa
      // exatamente UM dia perdido. Avançamos last_activity_date em um dia
      // (em vez de para hoje) para preservar a contagem correta caso o
      // usuário tenha pulado só um único dia; se ele pulou mais de um dia
      // mesmo com proteção, o streak quebra normalmente no próximo cálculo.
      // eslint-disable-next-line no-await-in-loop
      await db.query(
        `UPDATE streaks
         SET last_activity_date = (last_activity_date + INTERVAL '1 day')::date,
             protection_active = FALSE
         WHERE user_id = $1`,
        [row.user_id]
      );
      protectedCount += 1;
    } else {
      // Registra broken_at/pre_break_streak_days — é o que habilita a compra
      // de "Recuperar Streak" na Loja, dentro da janela de 24h.
      // eslint-disable-next-line no-await-in-loop
      await db.query(
        `UPDATE streaks
         SET current_streak_days = 0, broken_at = now(), pre_break_streak_days = $2
         WHERE user_id = $1`,
        [row.user_id, row.current_streak_days]
      );
      broken += 1;
    }

    // eslint-disable-next-line no-await-in-loop
    await userCache.invalidateStreak(row.user_id);
  }

  logger.info(`CRON: reconciliação de streaks concluída`, {
    streaksQuebrados: broken,
    streaksProtegidos: protectedCount,
    totalProcessado: rows.length,
  });
}

run()
  .catch((err) => {
    logger.error('CRON: falha na reconciliação de streaks', { error: err.message });
    process.exitCode = 1;
  })
  .finally(() => pool.end());
