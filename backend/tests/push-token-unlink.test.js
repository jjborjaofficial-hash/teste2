/**
 * Teste de integração (PostgreSQL com as migrations): sair da conta desliga o aparelho dessa conta, mas uma conta
 * nunca consegue desligar o aparelho de outra (`pushTokensRepository.deleteToken(token, userId)`).
 */
const db = require('../src/config/database');
const pushTokensRepository = require('../src/modules/notifications/repositories/pushTokensRepository');

const users = [];
async function makeUser(name) {
  const phone = `84${Math.floor(1000000 + Math.random() * 8999999)}`;
  const { rows } = await db.query(
    `INSERT INTO users (name, phone, password_hash, phone_provider, status) VALUES ($1, $2, 'x', 'mpesa', 'active') RETURNING id`,
    [name, phone]
  );
  users.push(rows[0].id);
  return rows[0].id;
}
const count = async (token) => Number((await db.query('SELECT count(*) FROM push_tokens WHERE token = $1', [token])).rows[0].count);

afterAll(async () => {
  await db.query('DELETE FROM push_tokens WHERE user_id = ANY($1::uuid[])', [users]);
  await db.query(`UPDATE users SET status = 'suspended', phone = NULL WHERE id = ANY($1::uuid[])`, [users]);
  await db.pool.end();
});

describe('desligar o aparelho ao sair da conta', () => {
  it('a própria conta remove o seu aparelho', async () => {
    const a = await makeUser('Teste Push A');
    const token = `tok-a-${Date.now()}`;
    await pushTokensRepository.upsertToken(a, token, 'web');
    expect(await count(token)).toBe(1);
    await pushTokensRepository.deleteToken(token, a);
    expect(await count(token)).toBe(0);
  });

  it('outra conta NÃO consegue remover o aparelho de quem não é', async () => {
    const a = await makeUser('Teste Push A2');
    const b = await makeUser('Teste Push B2');
    const token = `tok-a2-${Date.now()}`;
    await pushTokensRepository.upsertToken(a, token, 'web');
    await pushTokensRepository.deleteToken(token, b);
    expect(await count(token)).toBe(1);
  });

  it('depois de sair, voltar a entrar (novo registo do mesmo aparelho) liga-o de novo, e a outra conta passa a ser a dona', async () => {
    const a = await makeUser('Teste Push A3');
    const b = await makeUser('Teste Push B3');
    const token = `tok-shared-${Date.now()}`;
    await pushTokensRepository.upsertToken(a, token, 'web');
    await pushTokensRepository.deleteToken(token, a);
    await pushTokensRepository.upsertToken(b, token, 'web');
    const { rows } = await db.query('SELECT user_id FROM push_tokens WHERE token = $1', [token]);
    expect(rows).toHaveLength(1);
    expect(rows[0].user_id).toBe(b);
  });
});
