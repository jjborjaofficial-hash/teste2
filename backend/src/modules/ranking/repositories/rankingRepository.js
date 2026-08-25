const db = require('../../../config/database');
const { todayInPlatformTz } = require('../../../common/time/platformTimezone');

// CORREÇÃO: calculava o início da semana a partir de `new Date()` + getters
// UTC, resolvendo o dia da semana no fuso UTC do servidor — não no fuso de
// Moçambique (UTC+2). Perto da virada de domingo, isso podia classificar
// erradamente em que semana um quiz contava, e também afetava a elegibilidade
// do selo "Top 10" na Loja (shopService usa esta mesma função). Agora deriva
// sempre do calendário oficial da plataforma primeiro, e só então calcula o
// dia da semana — sem depender do fuso do processo Node/Postgres.
function currentWeekStartDate() {
  const todayStr = todayInPlatformTz(); // 'YYYY-MM-DD' já no fuso de Moçambique
  const [y, m, d] = todayStr.split('-').map(Number);
  const todayUtcMidnight = new Date(Date.UTC(y, m - 1, d));
  const day = todayUtcMidnight.getUTCDay(); // 0 = domingo — cálculo de calendário puro, seguro
  const diffToSunday = day; // semana começa no domingo, conforme convenção rrule 'SU'
  const weekStart = new Date(Date.UTC(y, m - 1, d - diffToSunday));
  return weekStart.toISOString().slice(0, 10);
}

/**
 * Recalcula o ranking da semana a partir do XP ganho em quiz_attempts corretos
 * dentro da janela [weekStart, weekStart + 7 dias). Usado pelo CRON job semanal
 * (Manual Parte 3: CRON Jobs — "recalcular rankings").
 */
async function recomputeWeeklyRanking(weekStartDate, executor = db) {
  await executor.query(
    `INSERT INTO weekly_rankings (user_id, week_start_date, xp_earned, position)
     SELECT
        qa.user_id,
        $1::date AS week_start_date,
        SUM(qa.xp_awarded) AS xp_earned,
        RANK() OVER (ORDER BY SUM(qa.xp_awarded) DESC) AS position
     FROM quiz_attempts qa
     WHERE qa.is_correct = TRUE
       AND qa.created_at >= $1::date
       AND qa.created_at < ($1::date + INTERVAL '7 days')
     GROUP BY qa.user_id
     ON CONFLICT (user_id, week_start_date)
     DO UPDATE SET xp_earned = EXCLUDED.xp_earned, position = EXCLUDED.position, computed_at = now()`,
    [weekStartDate]
  );
}

async function getTopRanking(weekStartDate, limit = 20, executor = db) {
  const { rows } = await executor.query(
    `SELECT wr.position, wr.xp_earned, u.id AS user_id, u.name, u.avatar_url, u.xp_total, u.equipped_avatar_frame
     FROM weekly_rankings wr
     JOIN users u ON u.id = wr.user_id
     WHERE wr.week_start_date = $1
     ORDER BY wr.position ASC
     LIMIT $2`,
    [weekStartDate, limit]
  );
  return rows;
}

async function getUserPosition(userId, weekStartDate, executor = db) {
  const { rows } = await executor.query(
    `SELECT position, xp_earned FROM weekly_rankings WHERE user_id = $1 AND week_start_date = $2`,
    [userId, weekStartDate]
  );
  return rows[0] || null;
}

module.exports = { currentWeekStartDate, recomputeWeeklyRanking, getTopRanking, getUserPosition };
