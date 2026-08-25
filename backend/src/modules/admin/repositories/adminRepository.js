const db = require('../../../config/database');

async function listWithdrawals({ status = 'pending_review', limit = 20, offset = 0 } = {}, executor = db) {
  const { rows } = await executor.query(
    `SELECT wr.id, wr.user_id, wr.amount_mzn, wr.method, wr.status,
            wr.trust_score_at_request, wr.wallet_transaction_id, wr.requested_at,
            wr.resolved_at, wr.resolved_by_admin_id,
            u.name AS user_name, u.phone AS user_phone
     FROM withdrawal_requests wr
     JOIN users u ON u.id = wr.user_id
     WHERE wr.status = $1
     ORDER BY wr.requested_at ASC
     LIMIT $2 OFFSET $3`,
    [status, limit, offset]
  );
  return rows;
}

/**
 * Dossiê completo de um pedido de saque, conforme o documento "Sistema de
 * Saques v1.0" (Seção 5: "Informações Disponíveis ao Administrador"):
 * nome, contato, saldo, trust score, histórico de saques, data de criação da
 * conta, último acesso e situação da conta.
 */
async function getWithdrawalDetail(withdrawalId, executor = db) {
  const { rows } = await executor.query(
    `SELECT wr.id, wr.user_id, wr.amount_mzn, wr.method, wr.status,
            wr.trust_score_at_request, wr.requested_at, wr.resolved_at,
            wr.rejection_reason, wr.resolved_by_admin_id,
            admin.name AS resolved_by_admin_name,
            u.name AS user_name, u.phone AS user_phone, u.email AS user_email,
            u.wallet_balance_mzn, u.trust_score, u.status AS account_status,
            u.created_at AS account_created_at, u.last_login_at
     FROM withdrawal_requests wr
     JOIN users u ON u.id = wr.user_id
     LEFT JOIN users admin ON admin.id = wr.resolved_by_admin_id
     WHERE wr.id = $1`,
    [withdrawalId]
  );
  if (!rows[0]) return null;

  const detail = rows[0];

  const historyResult = await executor.query(
    `SELECT id, amount_mzn, method, status, requested_at, resolved_at
     FROM withdrawal_requests
     WHERE user_id = $1
     ORDER BY requested_at DESC
     LIMIT 20`,
    [detail.user_id]
  );

  // "Quantidade de denúncias ou alertas" — não existe uma tabela de denúncias
  // no sistema ainda, então usamos como proxy o número de reduções de Trust
  // Score já registradas no histórico (cada uma tem um motivo auditado).
  const alertsResult = await executor.query(
    `SELECT COUNT(*)::int AS count FROM trust_score_history
     WHERE user_id = $1 AND new_score < previous_score`,
    [detail.user_id]
  );

  return {
    ...detail,
    withdrawal_history: historyResult.rows,
    alerts_count: alertsResult.rows[0].count,
  };
}

async function getWithdrawalForUpdate(withdrawalId, executor) {
  const { rows } = await executor.query(
    `SELECT id, user_id, amount_mzn, method, status, wallet_transaction_id
     FROM withdrawal_requests WHERE id = $1 FOR UPDATE`,
    [withdrawalId]
  );
  return rows[0] || null;
}

async function setWithdrawalStatus(executor, { withdrawalId, status, rejectionReason, resolvedByAdminId }) {
  const { rows } = await executor.query(
    `UPDATE withdrawal_requests
     SET status = $1, rejection_reason = $2, resolved_at = now(), resolved_by_admin_id = $3
     WHERE id = $4
     RETURNING id, status`,
    [status, rejectionReason || null, resolvedByAdminId || null, withdrawalId]
  );
  return rows[0];
}

async function confirmLedgerEntry(executor, walletTransactionId) {
  await executor.query(
    `UPDATE wallet_transactions SET status = 'confirmed' WHERE id = $1`,
    [walletTransactionId]
  );
}

async function reverseLedgerEntry(executor, walletTransactionId) {
  await executor.query(
    `UPDATE wallet_transactions SET status = 'reversed' WHERE id = $1`,
    [walletTransactionId]
  );
}

async function refundWallet(executor, { userId, amountMzn, referenceId }) {
  const lockResult = await executor.query(
    'SELECT wallet_balance_mzn FROM users WHERE id = $1 FOR UPDATE',
    [userId]
  );
  const newBalance = Number(lockResult.rows[0].wallet_balance_mzn) + Number(amountMzn);

  await executor.query('UPDATE users SET wallet_balance_mzn = $1 WHERE id = $2', [newBalance, userId]);

  await executor.query(
    `INSERT INTO wallet_transactions (user_id, type, source, amount_mzn, balance_after, status, reference_id)
     VALUES ($1, 'credit', 'withdrawal_rejected_refund', $2, $3, 'confirmed', $4)`,
    [userId, amountMzn, newBalance, referenceId]
  );
}

async function listUsers({ search, limit = 20, offset = 0 } = {}, executor = db) {
  const { rows } = await executor.query(
    `SELECT id, name, phone, status, role, trust_score, wallet_balance_mzn, created_at
     FROM users
     WHERE deleted_at IS NULL
       AND ($1::text IS NULL OR name ILIKE '%' || $1 || '%' OR phone ILIKE '%' || $1 || '%')
     ORDER BY created_at DESC
     LIMIT $2 OFFSET $3`,
    [search || null, limit, offset]
  );
  return rows;
}

async function setUserStatus(executor, { userId, status }) {
  const { rows } = await executor.query(
    `UPDATE users SET status = $1 WHERE id = $2 AND deleted_at IS NULL RETURNING id, status`,
    [status, userId]
  );
  return rows[0] || null;
}

async function setUserRole(executor, { userId, role }) {
  const { rows } = await executor.query(
    `UPDATE users SET role = $1 WHERE id = $2 AND deleted_at IS NULL RETURNING id, role`,
    [role, userId]
  );
  return rows[0] || null;
}

async function listAuditLogs({ userId, limit = 50, offset = 0 } = {}, executor = db) {
  const { rows } = await executor.query(
    `SELECT id, user_id, action, entity, entity_id, metadata, ip_address, created_at
     FROM audit_logs
     WHERE ($1::uuid IS NULL OR user_id = $1)
     ORDER BY created_at DESC
     LIMIT $2 OFFSET $3`,
    [userId || null, limit, offset]
  );
  return rows;
}

module.exports = {
  listWithdrawals,
  getWithdrawalDetail,
  getWithdrawalForUpdate,
  setWithdrawalStatus,
  confirmLedgerEntry,
  reverseLedgerEntry,
  refundWallet,
  listUsers,
  setUserStatus,
  setUserRole,
  listAuditLogs,
};
