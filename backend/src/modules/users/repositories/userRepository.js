const db = require('../../../config/database');

async function findProfileById(id) {
  const { rows } = await db.query(
    `SELECT id, name, phone, phone_provider, avatar_url, country, locale, currency,
            xp_total, points_balance, wallet_balance_mzn, trust_score,
            status, role, terms_version, terms_accepted_at, created_at,
            equipped_avatar_frame, equipped_theme,
            theme_trial_eligible, theme_trial_started_at, theme_trial_intro_seen_at
     FROM users
     WHERE id = $1 AND deleted_at IS NULL`,
    [id]
  );
  return rows[0] || null;
}

async function findSecurityById(id, executor = db) {
  const { rows } = await executor.query(
    `SELECT id, phone, phone_provider, password_hash, google_id, role, wallet_balance_mzn
     FROM users WHERE id = $1 AND deleted_at IS NULL`,
    [id]
  );
  return rows[0] || null;
}

async function updateNameAvatar(id, { name, avatarUrl }) {
  await db.query(
    `UPDATE users SET name = COALESCE($2, name),
                      avatar_url = CASE WHEN $3::boolean THEN $4 ELSE avatar_url END,
                      updated_at = now()
     WHERE id = $1 AND deleted_at IS NULL`,
    [id, name ?? null, avatarUrl !== undefined, avatarUrl ?? null]
  );
}

async function hasActiveWithdrawal(userId, executor = db) {
  const { rows } = await executor.query(
    `SELECT 1 FROM withdrawal_requests
     WHERE user_id = $1 AND status IN ('pending_review','approved','suspended_for_review') LIMIT 1`,
    [userId]
  );
  return rows.length > 0;
}

async function phoneInUse(phone, exceptUserId) {
  const { rows } = await db.query(
    'SELECT 1 FROM users WHERE phone = $1 AND deleted_at IS NULL AND id <> $2 LIMIT 1',
    [phone, exceptUserId]
  );
  return rows.length > 0;
}

async function lastPaymentPhoneChange(userId) {
  const { rows } = await db.query(
    `SELECT created_at FROM audit_logs
     WHERE user_id = $1 AND action = 'user.payment_phone_changed'
     ORDER BY created_at DESC LIMIT 1`,
    [userId]
  );
  return rows[0]?.created_at || null;
}

async function updatePhone(userId, phone, provider) {
  await db.query(
    'UPDATE users SET phone = $2, phone_provider = $3, updated_at = now() WHERE id = $1',
    [userId, phone, provider]
  );
}

async function exportData(userId) {
  const q = async (sql) => (await db.query(sql, [userId])).rows;
  const [profile] = await q(
    `SELECT id, name, phone, phone_provider, email, avatar_url, country, locale, currency,
            xp_total, points_balance, wallet_balance_mzn, trust_score, status, role,
            terms_version, terms_accepted_at, created_at, last_login_at
     FROM users WHERE id = $1`
  );
  return {
    profile,
    wallet_transactions: await q('SELECT type, source, amount_mzn, balance_after, status, created_at FROM wallet_transactions WHERE user_id = $1 ORDER BY created_at'),
    withdrawals: await q('SELECT amount_mzn, method, status, rejection_reason, requested_at, resolved_at FROM withdrawal_requests WHERE user_id = $1 ORDER BY requested_at'),
    points_ledger: await q('SELECT * FROM points_ledger WHERE user_id = $1 ORDER BY created_at'),
    quiz_attempts: await q('SELECT question_id, is_correct, created_at FROM quiz_attempts WHERE user_id = $1 ORDER BY created_at'),
    missions: await q('SELECT * FROM user_missions WHERE user_id = $1 ORDER BY assigned_at'),
    notifications: await q('SELECT type, title, body, created_at FROM notifications WHERE user_id = $1 ORDER BY created_at'),
    legal_acceptances: await q('SELECT document_version_id, accepted_at, ip_address FROM user_legal_acceptances WHERE user_id = $1 ORDER BY accepted_at'),
    referrals_made: await q('SELECT * FROM referrals WHERE referrer_user_id = $1'),
    purchases: await q('SELECT * FROM user_purchases WHERE user_id = $1'),
    login_sessions: await q('SELECT user_agent, ip_address, created_at FROM refresh_tokens WHERE user_id = $1 ORDER BY created_at'),
  };
}

/** Anonimiza (não apaga): histórico financeiro e auditoria têm de ficar. */
async function anonymize(userId, executor) {
  await executor.query(
    `UPDATE users SET name = 'Utilizador removido', phone = NULL, phone_provider = NULL,
            email = NULL, google_id = NULL, avatar_url = NULL, password_hash = NULL,
            wallet_balance_mzn = 0, equipped_avatar_frame = NULL, equipped_theme = NULL,
            deleted_at = now(), updated_at = now()
     WHERE id = $1`,
    [userId]
  );
  await executor.query(`UPDATE refresh_tokens SET revoked_at = COALESCE(revoked_at, now() - interval '1 day') WHERE user_id = $1`, [userId]);
  await executor.query('DELETE FROM push_tokens WHERE user_id = $1', [userId]);
  await executor.query('DELETE FROM cookie_preferences WHERE user_id = $1', [userId]);
  await executor.query('DELETE FROM notifications WHERE user_id = $1', [userId]);
}

module.exports = {
  findProfileById, findSecurityById, updateNameAvatar, hasActiveWithdrawal, phoneInUse,
  lastPaymentPhoneChange, updatePhone, exportData, anonymize,
};
