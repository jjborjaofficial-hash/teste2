const db = require('../../../config/database');

async function getScore(userId, executor = db) {
  const { rows } = await executor.query(
    'SELECT trust_score FROM users WHERE id = $1 AND deleted_at IS NULL',
    [userId]
  );
  return rows[0] ? rows[0].trust_score : null;
}

/**
 * Ajusta o Trust Score dentro de um intervalo [0, 100] e registra o histórico
 * com motivo (Manual Parte 4: histórico auditável do Trust Score).
 */
async function adjustScore(executor, { userId, delta, reason, metadata }) {
  const lockResult = await executor.query(
    'SELECT trust_score FROM users WHERE id = $1 FOR UPDATE',
    [userId]
  );
  if (!lockResult.rows[0]) {
    throw new Error(`Usuário ${userId} não encontrado ao ajustar Trust Score.`);
  }

  const previousScore = lockResult.rows[0].trust_score;
  const newScore = Math.max(0, Math.min(100, previousScore + delta));

  await executor.query('UPDATE users SET trust_score = $1 WHERE id = $2', [newScore, userId]);

  await executor.query(
    `INSERT INTO trust_score_history (user_id, previous_score, new_score, reason, metadata)
     VALUES ($1, $2, $3, $4, $5)`,
    [userId, previousScore, newScore, reason, JSON.stringify(metadata || {})]
  );

  return { previousScore, newScore };
}

async function getHistory(userId, { limit = 20 } = {}, executor = db) {
  const { rows } = await executor.query(
    `SELECT previous_score, new_score, reason, created_at
     FROM trust_score_history
     WHERE user_id = $1
     ORDER BY created_at DESC
     LIMIT $2`,
    [userId, limit]
  );
  return rows;
}

module.exports = { getScore, adjustScore, getHistory };
