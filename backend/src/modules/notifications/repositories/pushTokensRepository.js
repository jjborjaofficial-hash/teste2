const db = require('../../../config/database');

/**
 * Tokens de dispositivo para push (migration 032).
 */

async function upsertToken(userId, token, platform = 'web') {
  await db.query(
    `INSERT INTO push_tokens (user_id, token, platform)
     VALUES ($1, $2, $3)
     ON CONFLICT (token) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        platform = EXCLUDED.platform,
        last_used_at = now()`,
    [userId, token, platform]
  );
}

async function deleteToken(token) {
  await db.query(`DELETE FROM push_tokens WHERE token = $1`, [token]);
}

async function deleteTokens(tokens) {
  if (tokens.length === 0) return;
  await db.query(`DELETE FROM push_tokens WHERE token = ANY($1::text[])`, [tokens]);
}

async function listTokensByUser(userId, executor = db) {
  const { rows } = await executor.query(`SELECT token, platform FROM push_tokens WHERE user_id = $1`, [userId]);
  return rows;
}

module.exports = { upsertToken, deleteToken, deleteTokens, listTokensByUser };
