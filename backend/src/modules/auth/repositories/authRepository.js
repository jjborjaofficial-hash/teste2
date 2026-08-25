const db = require('../../../config/database');

/**
 * Repository: única camada autorizada a acessar o banco diretamente (Manual Parte 5).
 * Controllers e services nunca executam SQL diretamente.
 */

async function findUserByPhone(phone) {
  const { rows } = await db.query(
    `SELECT id, name, phone, phone_provider, password_hash, trust_score, status, role,
            xp_total, points_balance, wallet_balance_mzn
     FROM users
     WHERE phone = $1 AND deleted_at IS NULL`,
    [phone]
  );
  return rows[0] || null;
}

async function findUserById(id) {
  const { rows } = await db.query(
    `SELECT id, name, phone, trust_score, status, role, xp_total, points_balance, wallet_balance_mzn
     FROM users
     WHERE id = $1 AND deleted_at IS NULL`,
    [id]
  );
  return rows[0] || null;
}

async function createUser({ name, phone, phoneProvider, passwordHash, isAdultDeclared, termsVersion }) {
  const { rows } = await db.query(
    `INSERT INTO users (
        name, phone, phone_provider, password_hash,
        is_adult_declared, terms_accepted_at, terms_version, status
     ) VALUES ($1, $2, $3, $4, $5, now(), $6, 'pending_verification')
     RETURNING id, name, phone, trust_score, status, xp_total, points_balance, wallet_balance_mzn`,
    [name, phone, phoneProvider, passwordHash, isAdultDeclared, termsVersion]
  );
  return rows[0];
}

async function createStreakRow(userId, client = db) {
  await client.query(
    `INSERT INTO streaks (user_id) VALUES ($1) ON CONFLICT (user_id) DO NOTHING`,
    [userId]
  );
}

async function recordLoginAttempt({ phone, ipAddress, success }) {
  await db.query(
    `INSERT INTO login_attempts (phone, ip_address, success) VALUES ($1, $2, $3)`,
    [phone, ipAddress, success]
  );
}

async function touchLastLogin(userId) {
  await db.query(`UPDATE users SET last_login_at = now() WHERE id = $1`, [userId]);
}

/**
 * Registra o reaceite dos Termos de Uso (ex: depois de uma atualização de
 * versão). Usado tanto no cadastro inicial quanto em reaceites futuros.
 */
async function acceptTerms(userId, termsVersion) {
  await db.query(
    `UPDATE users SET terms_accepted_at = now(), terms_version = $1 WHERE id = $2`,
    [termsVersion, userId]
  );
}

async function countRecentFailedAttempts(phone, windowMinutes = 15) {
  const { rows } = await db.query(
    `SELECT COUNT(*)::int AS count
     FROM login_attempts
     WHERE phone = $1 AND success = FALSE
       AND attempted_at > now() - ($2 || ' minutes')::interval`,
    [phone, windowMinutes]
  );
  return rows[0].count;
}

async function storeRefreshToken({ userId, tokenHash, userAgent, ipAddress, expiresAt }) {
  await db.query(
    `INSERT INTO refresh_tokens (user_id, token_hash, user_agent, ip_address, expires_at)
     VALUES ($1, $2, $3, $4, $5)`,
    [userId, tokenHash, userAgent, ipAddress, expiresAt]
  );
}

async function findValidRefreshToken(tokenHash) {
  const { rows } = await db.query(
    `SELECT id, user_id, expires_at
     FROM refresh_tokens
     WHERE token_hash = $1 AND revoked_at IS NULL AND expires_at > now()`,
    [tokenHash]
  );
  return rows[0] || null;
}

async function revokeRefreshToken(tokenHash) {
  await db.query(
    `UPDATE refresh_tokens SET revoked_at = now() WHERE token_hash = $1`,
    [tokenHash]
  );
}

async function insertAuditLog({ userId, action, entity, entityId, metadata, ipAddress }) {
  await db.query(
    `INSERT INTO audit_logs (user_id, action, entity, entity_id, metadata, ip_address)
     VALUES ($1, $2, $3, $4, $5, $6)`,
    [userId, action, entity, entityId || null, JSON.stringify(metadata || {}), ipAddress]
  );
}

module.exports = {
  findUserByPhone,
  findUserById,
  createUser,
  createStreakRow,
  recordLoginAttempt,
  touchLastLogin,
  acceptTerms,
  countRecentFailedAttempts,
  storeRefreshToken,
  findValidRefreshToken,
  revokeRefreshToken,
  insertAuditLog,
};
