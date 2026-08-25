const db = require('../../../config/database');

async function getCodeForUser(userId, executor = db) {
  const { rows } = await executor.query(
    'SELECT code FROM referral_codes WHERE user_id = $1',
    [userId]
  );
  return rows[0] ? rows[0].code : null;
}

async function createCodeForUser(executor, userId, code) {
  await executor.query(
    `INSERT INTO referral_codes (user_id, code) VALUES ($1, $2)
     ON CONFLICT (user_id) DO NOTHING`,
    [userId, code]
  );
}

async function findUserIdByCode(code, executor = db) {
  const { rows } = await executor.query(
    'SELECT user_id FROM referral_codes WHERE code = $1',
    [code]
  );
  return rows[0] ? rows[0].user_id : null;
}

async function createReferral(executor, { referrerUserId, referredUserId }) {
  const { rows } = await executor.query(
    `INSERT INTO referrals (referrer_user_id, referred_user_id)
     VALUES ($1, $2)
     ON CONFLICT (referred_user_id) DO NOTHING
     RETURNING id`,
    [referrerUserId, referredUserId]
  );
  return rows[0] || null;
}

async function countQualifyingActivity(referredUserId, executor = db) {
  const { rows } = await executor.query(
    `SELECT COUNT(*)::int AS count
     FROM quiz_attempts
     WHERE user_id = $1 AND is_correct = TRUE`,
    [referredUserId]
  );
  return rows[0].count;
}

async function getPendingReferralsForUser(referredUserId, executor = db) {
  const { rows } = await executor.query(
    `SELECT id, referrer_user_id, status FROM referrals
     WHERE referred_user_id = $1 AND status = 'pending' FOR UPDATE`,
    [referredUserId]
  );
  return rows;
}

async function markQualifiedAndRewarded(executor, referralId) {
  await executor.query(
    `UPDATE referrals SET status = 'rewarded', reward_granted_at = now() WHERE id = $1`,
    [referralId]
  );
}

async function listMyReferrals(userId, executor = db) {
  const { rows } = await executor.query(
    `SELECT r.id, r.status, r.created_at, r.reward_granted_at, u.name AS referred_name
     FROM referrals r
     JOIN users u ON u.id = r.referred_user_id
     WHERE r.referrer_user_id = $1
     ORDER BY r.created_at DESC`,
    [userId]
  );
  return rows;
}

module.exports = {
  getCodeForUser,
  createCodeForUser,
  findUserIdByCode,
  createReferral,
  countQualifyingActivity,
  getPendingReferralsForUser,
  markQualifiedAndRewarded,
  listMyReferrals,
};
