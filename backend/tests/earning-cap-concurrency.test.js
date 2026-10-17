/**
 * Teto diário de 7,20 MZN com pedidos SIMULTÂNEOS (banco real): dois resgates ao mesmo tempo não podem
 * passar do teto. Antes da correção os dois liam o mesmo total e ambos pagavam por inteiro.
 */
const db = require('../src/config/database');
const walletService = require('../src/modules/wallet/services/walletService');

let userId;

beforeAll(async () => {
  const phone = `84${Math.floor(1000000 + Math.random() * 8999999)}`;
  const { rows } = await db.query(
    `INSERT INTO users (name, phone, password_hash, phone_provider, status)
     VALUES ('Teto Simultaneo', $1, 'x', 'mpesa', 'active') RETURNING id`,
    [phone]
  );
  userId = rows[0].id;
});

afterAll(async () => {
  // wallet_transactions é um livro-razão imutável (não se apaga): a conta de teste fica, anonimizada e inativa.
  await db.query("UPDATE users SET status = 'suspended', phone = NULL WHERE id = $1", [userId]).catch(() => {});
  await db.pool.end();
});

async function claim(amountMzn, ref) {
  const client = await db.getClient();
  try {
    await client.query('BEGIN');
    const r = await walletService.creditReward(
      { userId, amountMzn, source: 'mission_reward', referenceId: ref },
      client
    );
    // Segura a transação um instante para dar tempo ao pedido concorrente de tentar ler o total.
    await new Promise((res) => setTimeout(res, 150));
    await client.query('COMMIT');
    return r;
  } catch (e) {
    await client.query('ROLLBACK');
    throw e;
  } finally {
    client.release();
  }
}

test('4 resgates simultâneos de 3 MZN não passam de 7,20 MZN no dia', async () => {
  const refs = [1, 2, 3, 4].map((n) => `00000000-0000-4000-8000-00000000000${n}`);
  await Promise.all(refs.map((r) => claim(3, r)));
  const { rows } = await db.query(
    `SELECT COALESCE(SUM(amount_mzn),0) AS total FROM wallet_transactions
      WHERE user_id = $1 AND source = 'mission_reward' AND type = 'credit'`,
    [userId]
  );
  expect(Number(rows[0].total)).toBeCloseTo(7.2, 2);
  const { rows: u } = await db.query('SELECT wallet_balance_mzn FROM users WHERE id = $1', [userId]);
  expect(Number(u[0].wallet_balance_mzn)).toBeCloseTo(7.2, 2);
});
