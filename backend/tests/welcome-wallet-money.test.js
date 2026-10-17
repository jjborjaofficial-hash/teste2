/**
 * Dinheiro (banco real): bónus de boas-vindas e saque.
 * Boas-vindas: 1 coleta por dia, valor do dia, fora do teto, 4 cliques simultâneos pagam uma só vez, dia 8 fechado,
 * conta reciclada sem bónus. Saque: mínimo, saldo, método = operador do número, um pedido ativo de cada vez.
 */
const db = require('../src/config/database');
const welcome = require('../src/modules/gamification/services/welcomeBonusService');
const walletService = require('../src/modules/wallet/services/walletService');

const ids = [];
async function newUser({ daysAgo = 0, provider = 'mpesa', balance = 0, recycled = false } = {}) {
  const phone = `${provider === 'mpesa' ? '84' : '86'}${Math.floor(1000000 + Math.random() * 8999999)}`;
  const { rows } = await db.query(
    `INSERT INTO users (name, phone, password_hash, phone_provider, status, wallet_balance_mzn, identity_recycled, created_at)
     VALUES ('Teste Dinheiro', $1, 'x', $2, 'active', $3, $4, now() - ($5 || ' days')::interval) RETURNING id`,
    [phone, provider, balance, recycled, String(daysAgo)]
  );
  ids.push(rows[0].id);
  return rows[0].id;
}
const balanceOf = async (id) => Number((await db.query('SELECT wallet_balance_mzn FROM users WHERE id = $1', [id])).rows[0].wallet_balance_mzn);

afterAll(async () => {
  // wallet_transactions é imutável: as contas de teste ficam, suspensas e sem telefone.
  await db.query("UPDATE users SET status = 'suspended', phone = NULL WHERE id = ANY($1::uuid[])", [ids]).catch(() => {});
  await db.pool.end();
});

describe('bónus de boas-vindas', () => {
  test('dia 1: paga o valor do dia 1 e credita a carteira', async () => {
    const id = await newUser();
    const r = await welcome.claimToday(id);
    expect(r).toEqual({ dayNumber: 1, amountMzn: 2 });
    expect(await balanceOf(id)).toBeCloseTo(2, 2);
  });

  test('só uma coleta por dia', async () => {
    const id = await newUser();
    await welcome.claimToday(id);
    await expect(welcome.claimToday(id)).rejects.toThrow(/já foi coletada/);
    expect(await balanceOf(id)).toBeCloseTo(2, 2);
  });

  test('4 cliques simultâneos pagam uma única vez', async () => {
    const id = await newUser();
    const res = await Promise.allSettled([1, 2, 3, 4].map(() => welcome.claimToday(id)));
    expect(res.filter((x) => x.status === 'fulfilled')).toHaveLength(1);
    expect(await balanceOf(id)).toBeCloseTo(2, 2);
  });

  test('conta de 2 dias: paga o valor do dia 2 e o dia 1 fica perdido', async () => {
    const id = await newUser({ daysAgo: 1 });
    const status = await welcome.getStatus(id);
    expect(status.days[0].status).toBe('missed');
    expect(status.days[1].status).toBe('available');
    const r = await welcome.claimToday(id);
    expect(r.dayNumber).toBe(2);
    expect(r.amountMzn).toBe(1);
  });

  test('depois dos 7 dias já não há bónus', async () => {
    const id = await newUser({ daysAgo: 8 });
    await expect(welcome.claimToday(id)).rejects.toThrow(/terminou/);
    expect(await balanceOf(id)).toBe(0);
  });

  test('conta com identidade reciclada não recebe bónus', async () => {
    const id = await newUser({ recycled: true });
    await expect(welcome.claimToday(id)).rejects.toThrow(/já foi usado antes/);
    expect(await balanceOf(id)).toBe(0);
  });
});

describe('saque', () => {
  test('abaixo do mínimo é recusado e não mexe no saldo', async () => {
    const id = await newUser({ balance: 150 });
    await expect(walletService.requestWithdrawal({ userId: id, amountMzn: 50, method: 'mpesa' })).rejects.toThrow(/mínimo/);
    expect(await balanceOf(id)).toBe(150);
  });

  test('saldo insuficiente é recusado', async () => {
    const id = await newUser({ balance: 100 });
    await expect(walletService.requestWithdrawal({ userId: id, amountMzn: 120, method: 'mpesa' })).rejects.toThrow(/Saldo insuficiente/);
    expect(await balanceOf(id)).toBe(100);
  });

  test('método diferente do operador do número é recusado', async () => {
    const id = await newUser({ balance: 200, provider: 'mpesa' });
    await expect(walletService.requestWithdrawal({ userId: id, amountMzn: 100, method: 'emola' })).rejects.toThrow(/M-Pesa/);
    expect(await balanceOf(id)).toBe(200);
  });

  test('saque válido debita o saldo e o segundo pedido enquanto o primeiro está ativo é recusado', async () => {
    const id = await newUser({ balance: 300 });
    const r = await walletService.requestWithdrawal({ userId: id, amountMzn: 100, method: 'mpesa' });
    expect(r.status).toBe('pending_review');
    expect(await balanceOf(id)).toBe(200);
    await expect(walletService.requestWithdrawal({ userId: id, amountMzn: 100, method: 'mpesa' })).rejects.toThrow(/em andamento/);
    expect(await balanceOf(id)).toBe(200);
  });

  test('2 pedidos simultâneos: só um é aceite e o saldo só desce uma vez', async () => {
    const id = await newUser({ balance: 300 });
    const res = await Promise.allSettled([1, 2].map(() => walletService.requestWithdrawal({ userId: id, amountMzn: 100, method: 'mpesa' })));
    expect(res.filter((x) => x.status === 'fulfilled')).toHaveLength(1);
    expect(await balanceOf(id)).toBe(200);
  });
});
