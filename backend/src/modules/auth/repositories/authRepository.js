const db = require('../../../config/database');
const { normalizeEmail } = require('../../../common/utils/identity');

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

/** Só o estado da ligação com o Google (usado ao ligar o Google a uma conta). */
async function findGoogleLinkState(userId) {
  const { rows } = await db.query(
    'SELECT id, email, google_id FROM users WHERE id = $1 AND deleted_at IS NULL',
    [userId]
  );
  return rows[0] || null;
}

async function findUserByGoogleId(googleId) {
  const { rows } = await db.query(
    `SELECT id, name, phone, phone_provider, email, google_id, avatar_url,
            trust_score, status, role, xp_total, points_balance, wallet_balance_mzn
     FROM users
     WHERE google_id = $1 AND deleted_at IS NULL`,
    [googleId]
  );
  return rows[0] || null;
}

async function findUserByEmail(email) {
  const { rows } = await db.query(
    `SELECT id, name, phone, phone_provider, email, google_id, avatar_url,
            trust_score, status, role, xp_total, points_balance, wallet_balance_mzn
     FROM users
     WHERE email_normalized = $1 AND deleted_at IS NULL`,
    [normalizeEmail(email)]
  );
  return rows[0] || null;
}

/**
 * Cria uma conta a partir do primeiro login via Google. Nasce sem telefone
 * (Google não fornece) — a tela "completar perfil" preenche isso a seguir.
 * is_adult_declared/terms_accepted_at ficam pendentes até lá também.
 */
async function createUserFromGoogle({ name, email, googleId, avatarUrl }) {
  const { rows } = await db.query(
    `INSERT INTO users (
        name, email, email_normalized, google_id, avatar_url, status, is_adult_declared, theme_trial_eligible
     ) VALUES ($1, $2, $5, $3, $4, 'pending_verification', FALSE, TRUE)
     RETURNING id, name, phone, email, google_id, avatar_url, trust_score, status,
               xp_total, points_balance, wallet_balance_mzn`,
    [name, email, googleId, avatarUrl, normalizeEmail(email)]
  );
  return rows[0];
}

/** Vincula uma conta Google a uma conta já existente, encontrada pelo e-mail. */
async function linkGoogleToUser(userId, { googleId, avatarUrl }) {
  const { rows } = await db.query(
    `UPDATE users SET google_id = $1, avatar_url = COALESCE(avatar_url, $2)
     WHERE id = $3
     RETURNING id, name, phone, email, google_id, avatar_url, trust_score, status,
               xp_total, points_balance, wallet_balance_mzn`,
    [googleId, avatarUrl, userId]
  );
  return rows[0];
}


/**
 * Liga o Google (e o e-mail verificado por ele) a uma conta que ainda NÃO tem Google.
 * O "AND google_id IS NULL" torna a operação segura contra dois pedidos ao mesmo tempo.
 */
async function attachGoogleToAccount(userId, { googleId, email, avatarUrl }) {
  const { rows } = await db.query(
    `UPDATE users
        SET google_id = $1,
            email = COALESCE(email, $2),
            email_normalized = COALESCE(email_normalized, $3),
            avatar_url = COALESCE(avatar_url, $4),
            updated_at = now()
      WHERE id = $5 AND google_id IS NULL AND deleted_at IS NULL
      RETURNING id`,
    [googleId, email, normalizeEmail(email), avatarUrl, userId]
  );
  return rows[0] || null;
}

/** Guarda a nova senha e termina TODAS as sessões abertas da conta (recuperação). */
async function resetPasswordAndRevokeSessions(userId, passwordHash) {
  await db.query('UPDATE users SET password_hash = $2, updated_at = now() WHERE id = $1', [userId, passwordHash]);
  await db.query(
    `UPDATE refresh_tokens SET revoked_at = now() - interval '1 day'
      WHERE user_id = $1 AND revoked_at IS NULL`,
    [userId]
  );
}

/** Preenche telefone + check-in jurídico de uma conta criada via Google. */
async function completeGoogleProfile(userId, { phone, phoneProvider, isAdultDeclared }) {
  const { rows } = await db.query(
    `UPDATE users
        SET phone = $1, phone_provider = $2, is_adult_declared = $3, status = 'active'
      WHERE id = $4
      RETURNING id, name, phone, trust_score, status, xp_total, points_balance, wallet_balance_mzn`,
    [phone, phoneProvider, isAdultDeclared, userId]
  );
  return rows[0];
}

async function createUser({ name, phone, phoneProvider, passwordHash, isAdultDeclared, termsVersion }) {
  const { rows } = await db.query(
    `INSERT INTO users (
        name, phone, phone_provider, password_hash,
        is_adult_declared, terms_accepted_at, terms_version, status, theme_trial_eligible
     ) VALUES ($1, $2, $3, $4, $5, now(), $6, 'pending_verification', TRUE)
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

/**
 * Token de renovação válido. Com `graceSeconds` > 0 aceita também um token revogado há
 * poucos segundos (revogado POR ROTAÇÃO): quando a página é atualizada, vários pedidos
 * (ou duas abas) chegam juntos com o mesmo cookie e só o primeiro ganharia; os outros
 * davam 401 e a sessão caía (bug do F5 repetido 2-3 vezes). Fora dessa janela, um token
 * revogado continua inválido (logout e roubo de token seguem protegidos).
 */
async function findValidRefreshToken(tokenHash, { graceSeconds = 0 } = {}) {
  const { rows } = await db.query(
    `SELECT id, user_id, expires_at, created_at, revoked_at
     FROM refresh_tokens
     WHERE token_hash = $1
       AND expires_at > now()
       AND (revoked_at IS NULL
            OR ($2::int > 0
                AND revoked_at > now() - ($2::int * interval '1 second')))`,
    [tokenHash, graceSeconds]
  );
  return rows[0] || null;
}

// Só marca a primeira revogação (a janela de tolerância conta a partir dela).
// Rotação normal grava revoked_at = agora (entra na janela). Logout grava uma data antiga
// (fora da janela), para o token de quem saiu nunca mais renovar a sessão.
async function revokeRefreshToken(tokenHash, { logout = false } = {}) {
  await db.query(
    `UPDATE refresh_tokens
        SET revoked_at = CASE WHEN $2::boolean THEN now() - interval '1 day' ELSE now() END
      WHERE token_hash = $1 AND revoked_at IS NULL`,
    [tokenHash, logout]
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
  findUserByGoogleId,
  findUserByEmail,
  findGoogleLinkState,
  attachGoogleToAccount,
  resetPasswordAndRevokeSessions,
  createUser,
  createUserFromGoogle,
  linkGoogleToUser,
  completeGoogleProfile,
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
