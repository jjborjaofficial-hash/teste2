const db = require('../../../config/database');

/**
 * Repository do módulo Gamificação (Doc. Mestre Seção 4, 5, 12 | Manual Parte 4).
 * Todas as funções de escrita aceitam um `executor` de transação para permitir
 * composição atômica com o módulo de Quiz (uma resposta pode gerar XP + streak juntos).
 */

async function addXpAndPoints(executor, { userId, xpDelta, pointsDelta }) {
  const { rows } = await executor.query(
    `UPDATE users
     SET xp_total = xp_total + $1,
         points_balance = points_balance + $2
     WHERE id = $3
     RETURNING xp_total, points_balance`,
    [xpDelta, pointsDelta, userId]
  );
  if (!rows[0]) throw new Error(`Usuário ${userId} não encontrado ao adicionar XP.`);
  return { xpTotal: Number(rows[0].xp_total), pointsBalance: Number(rows[0].points_balance) };
}

async function getStreak(userId, executor = db) {
  const { rows } = await executor.query(
    `SELECT user_id, current_streak_days, longest_streak_days, last_activity_date,
            protection_active, broken_at, pre_break_streak_days
     FROM streaks WHERE user_id = $1 FOR UPDATE`,
    [userId]
  );
  return rows[0] || null;
}

async function updateStreak(executor, { userId, currentStreakDays, longestStreakDays, lastActivityDate, protectionActive, brokenAt = null, preBreakStreakDays = null }) {
  await executor.query(
    `UPDATE streaks
     SET current_streak_days = $1,
         longest_streak_days = $2,
         last_activity_date = $3,
         protection_active = $4,
         broken_at = $5,
         pre_break_streak_days = COALESCE($6, pre_break_streak_days)
     WHERE user_id = $7`,
    [currentStreakDays, longestStreakDays, lastActivityDate, protectionActive, brokenAt, preBreakStreakDays, userId]
  );
}

/**
 * Ativa o item de proteção de streak fora do fluxo de marco de 15 dias — usado
 * pela compra do item "Proteção de Streak" na Loja.
 */
async function setProtectionActive(executor, userId) {
  await executor.query(`UPDATE streaks SET protection_active = TRUE WHERE user_id = $1`, [userId]);
}

/**
 * Restaura um streak quebrado recentemente para o valor que tinha antes de
 * quebrar — usado pela compra do item "Recuperar Streak" na Loja. A
 * elegibilidade (janela de 24h) é checada pelo chamador (shopService), antes
 * de invocar esta função.
 */
async function recoverStreak(executor, userId) {
  const { rows } = await executor.query(
    `UPDATE streaks
     SET current_streak_days = pre_break_streak_days,
         longest_streak_days = GREATEST(longest_streak_days, pre_break_streak_days),
         broken_at = NULL
     WHERE user_id = $1
     RETURNING current_streak_days`,
    [userId]
  );
  return rows[0]?.current_streak_days ?? 0;
}

module.exports = { addXpAndPoints, getStreak, updateStreak, setProtectionActive, recoverStreak };
