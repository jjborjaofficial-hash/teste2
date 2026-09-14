const db = require('../../../config/database');
const { dateInPlatformTz } = require('../../../common/time/platformTimezone');

/**
 * Repository do módulo Carteira (Manual Parte 4: livro-razão imutável).
 * Todas as funções aceitam um `executor` (pool ou client de transação) para permitir
 * composição com outros módulos (ex: Missões creditando recompensa dentro da mesma transação).
 */

async function getWalletBalance(userId, executor = db) {
  const { rows } = await executor.query(
    'SELECT wallet_balance_mzn FROM users WHERE id = $1 AND deleted_at IS NULL',
    [userId]
  );
  return rows[0] ? Number(rows[0].wallet_balance_mzn) : null;
}

/**
 * Retorna status da conta e trust score juntos — usado para validar a
 * solicitação de saque (documento "Sistema de Saques v1.0": "Conta do usuário
 * ativa e em conformidade").
 */
async function getUserStatusAndTrustScore(userId, executor = db) {
  const { rows } = await executor.query(
    'SELECT status, trust_score FROM users WHERE id = $1 AND deleted_at IS NULL',
    [userId]
  );
  return rows[0] || null;
}

/**
 * Verifica se o usuário já tem um pedido de saque "vivo" (pending_review,
 * approved ou suspended_for_review). Documento "Sistema de Saques v1.0",
 * Seção Segurança: "Impedir solicitações duplicadas".
 */
async function hasActiveWithdrawal(userId, executor = db) {
  const { rows } = await executor.query(
    `SELECT id FROM withdrawal_requests
     WHERE user_id = $1 AND status IN ('pending_review', 'approved', 'suspended_for_review')
     LIMIT 1`,
    [userId]
  );
  return rows.length > 0;
}

/**
 * Credita valor na carteira do usuário. Deve ser chamado dentro de uma transação
 * (client com BEGIN já iniciado) quando compuser outra operação de negócio.
 */
async function creditWallet(executor, { userId, amountMzn, source, referenceId, metadata }) {
  const lockResult = await executor.query(
    'SELECT wallet_balance_mzn FROM users WHERE id = $1 FOR UPDATE',
    [userId]
  );
  if (!lockResult.rows[0]) {
    throw new Error(`Usuário ${userId} não encontrado ao creditar carteira.`);
  }

  const newBalance = Number(lockResult.rows[0].wallet_balance_mzn) + Number(amountMzn);

  await executor.query(
    'UPDATE users SET wallet_balance_mzn = $1 WHERE id = $2',
    [newBalance, userId]
  );

  const { rows } = await executor.query(
    `INSERT INTO wallet_transactions
        (user_id, type, source, amount_mzn, balance_after, status, reference_id, metadata)
     VALUES ($1, 'credit', $2, $3, $4, 'confirmed', $5, $6)
     RETURNING id, balance_after, created_at`,
    [userId, source, amountMzn, newBalance, referenceId || null, JSON.stringify(metadata || {})]
  );

  return rows[0];
}

/**
 * Debita valor da carteira (usado ao criar uma solicitação de saque).
 * Lança erro se o saldo for insuficiente — quem chama deve tratar dentro da transação.
 */
async function debitWallet(executor, { userId, amountMzn, source, referenceId, metadata }) {
  const lockResult = await executor.query(
    'SELECT wallet_balance_mzn FROM users WHERE id = $1 FOR UPDATE',
    [userId]
  );
  if (!lockResult.rows[0]) {
    throw new Error(`Usuário ${userId} não encontrado ao debitar carteira.`);
  }

  const currentBalance = Number(lockResult.rows[0].wallet_balance_mzn);
  if (currentBalance < Number(amountMzn)) {
    const err = new Error('Saldo insuficiente.');
    err.code = 'INSUFFICIENT_BALANCE';
    throw err;
  }

  const newBalance = currentBalance - Number(amountMzn);

  await executor.query(
    'UPDATE users SET wallet_balance_mzn = $1 WHERE id = $2',
    [newBalance, userId]
  );

  const { rows } = await executor.query(
    `INSERT INTO wallet_transactions
        (user_id, type, source, amount_mzn, balance_after, status, reference_id, metadata)
     VALUES ($1, 'debit', $2, $3, $4, 'pending', $5, $6)
     RETURNING id, balance_after, created_at`,
    [userId, source, amountMzn, newBalance, referenceId || null, JSON.stringify(metadata || {})]
  );

  return rows[0];
}

async function getTransactionHistory(userId, { limit = 20, offset = 0 } = {}, executor = db) {
  const { rows } = await executor.query(
    `SELECT id, type, source, amount_mzn, balance_after, status, created_at
     FROM wallet_transactions
     WHERE user_id = $1
     ORDER BY created_at DESC
     LIMIT $2 OFFSET $3`,
    [userId, limit, offset]
  );
  return rows;
}

/**
 * Soma quanto o usuário já GANHOU em dinheiro real hoje (missões + streak +
 * conversão de Pontos), para aplicar o teto de ganho diário (não confundir
 * com teto de saque — saque não tem teto diário, só valor mínimo de 100
 * MZN). Refunds/estornos não contam como ganho, por isso são excluídos
 * explicitamente.
 *
 * `points_conversion` entrou aqui na migration 028: converter Pontos em MZN
 * também é "ganhar dinheiro real", então precisa respeitar o mesmo teto —
 * senão o teto vira decorativo (o usuário só precisaria acumular Pontos e
 * converter tudo de uma vez para contornar o limite diário).
 */
async function sumEarningsToday(userId, executor = db) {
  const { rows } = await executor.query(
    `SELECT COALESCE(SUM(amount_mzn), 0) AS total
     FROM wallet_transactions
     WHERE user_id = $1
       AND type = 'credit'
       AND ${dateInPlatformTz('created_at')} = ${dateInPlatformTz('now()')}
       AND (source = 'mission_reward' OR source = 'points_conversion' OR source LIKE 'streak_milestone_%')`,
    [userId]
  );
  return Number(rows[0].total);
}

async function createWithdrawalRequest(executor, { userId, amountMzn, method, trustScoreAtRequest, walletTransactionId }) {
  const { rows } = await executor.query(
    `INSERT INTO withdrawal_requests
        (user_id, amount_mzn, method, trust_score_at_request, wallet_transaction_id)
     VALUES ($1, $2, $3, $4, $5)
     RETURNING id, status, requested_at`,
    [userId, amountMzn, method, trustScoreAtRequest, walletTransactionId]
  );
  return rows[0];
}

module.exports = {
  getWalletBalance,
  getUserStatusAndTrustScore,
  hasActiveWithdrawal,
  creditWallet,
  debitWallet,
  getTransactionHistory,
  sumEarningsToday,
  createWithdrawalRequest,
};
