const db = require('../../../config/database');
const { dateInPlatformTz } = require('../../../common/time/platformTimezone');

/**
 * Livro-razão de Pontos (docx "SISTEMA DE ECONOMIA E RECOMPENSAS", Seção 9 —
 * histórico auditável). Mesmo padrão já validado em wallet_transactions:
 * todo ganho e todo gasto de Pontos gera uma linha aqui, nunca editável.
 */

async function sumCreditsToday(userId, executor = db) {
  // "Hoje" no fuso oficial da plataforma (Moçambique), não no fuso da sessão
  // do Postgres — ver common/time/platformTimezone.js.
  const { rows } = await executor.query(
    `SELECT COALESCE(SUM(amount_points), 0) AS total
     FROM points_ledger
     WHERE user_id = $1 AND type = 'credit' AND ${dateInPlatformTz('created_at')} = ${dateInPlatformTz('now()')}`,
    [userId]
  );
  return Number(rows[0].total);
}

async function insertLedgerEntry(executor, { userId, type, amountPoints, balanceAfter, source, referenceId, metadata }) {
  const { rows } = await executor.query(
    `INSERT INTO points_ledger (user_id, type, source, amount_points, balance_after, reference_id, metadata)
     VALUES ($1, $2, $3, $4, $5, $6, $7)
     RETURNING id, created_at`,
    [userId, type, source, amountPoints, balanceAfter, referenceId || null, JSON.stringify(metadata || {})]
  );
  return rows[0];
}

/**
 * Debita Pontos do saldo do usuário (usado exclusivamente pela Loja — não
 * existe nenhum outro caminho de gasto de Pontos na plataforma, por decisão
 * explícita: "o usuário não poderá pagar para fazer missões").
 */
async function debitPoints(executor, { userId, amountPoints, source, referenceId, metadata }) {
  const lockResult = await executor.query(
    'SELECT points_balance FROM users WHERE id = $1 FOR UPDATE',
    [userId]
  );
  if (!lockResult.rows[0]) {
    throw new Error(`Usuário ${userId} não encontrado ao debitar Pontos.`);
  }

  const currentBalance = Number(lockResult.rows[0].points_balance);
  if (currentBalance < Number(amountPoints)) {
    const err = new Error('Pontos insuficientes.');
    err.code = 'INSUFFICIENT_BALANCE';
    throw err;
  }

  const newBalance = currentBalance - Number(amountPoints);

  await executor.query('UPDATE users SET points_balance = $1 WHERE id = $2', [newBalance, userId]);

  const entry = await insertLedgerEntry(executor, {
    userId,
    type: 'debit',
    amountPoints,
    balanceAfter: newBalance,
    source,
    referenceId,
    metadata,
  });

  return { ...entry, balanceAfter: newBalance };
}

async function listLedger(userId, { limit = 30, offset = 0 } = {}, executor = db) {
  const { rows } = await executor.query(
    `SELECT id, type, source, amount_points, balance_after, created_at
     FROM points_ledger
     WHERE user_id = $1
     ORDER BY created_at DESC
     LIMIT $2 OFFSET $3`,
    [userId, limit, offset]
  );
  return rows;
}

module.exports = { sumCreditsToday, insertLedgerEntry, debitPoints, listLedger };
