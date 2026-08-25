const db = require('../../../config/database');

async function findProfileById(id) {
  const { rows } = await db.query(
    `SELECT id, name, phone, avatar_url, country, locale, currency,
            xp_total, points_balance, wallet_balance_mzn, trust_score,
            status, role, terms_version, terms_accepted_at, created_at,
            equipped_avatar_frame, equipped_theme
     FROM users
     WHERE id = $1 AND deleted_at IS NULL`,
    [id]
  );
  return rows[0] || null;
}

module.exports = { findProfileById };
