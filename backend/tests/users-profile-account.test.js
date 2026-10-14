/**
 * Itens 6 e 7: editar perfil / número de pagamento, exportar dados e apagar conta.
 */
process.env.USERS_SENSITIVE_MAX = '1000';
const supertest = require('supertest');
// IP próprio nesta suite: os limites por IP não misturam com os outros testes.
const request = (app) => {
  const t = supertest(app);
  const wrap = (m) => (path) => t[m](path).set('X-Forwarded-For', '10.77.0.1');
  return { get: wrap('get'), post: wrap('post'), put: wrap('put'), patch: wrap('patch'), delete: wrap('delete') };
};
const bcrypt = require('bcrypt');
const app = require('../src/app');
const db = require('../src/config/database');

const PASSWORD = 'senhaSegura123';
const rnd = () => String(Math.floor(1e6 + Math.random() * 9e6));

async function makeUser(prefix = '84') {
  const phone = `${prefix}${rnd()}`.slice(0, 9);
  const hash = await bcrypt.hash(PASSWORD, 4);
  const { rows } = await db.query(
    `INSERT INTO users (name, phone, phone_provider, password_hash, is_adult_declared)
     VALUES ('Teste Perfil', $1, $2, $3, true) RETURNING id`,
    [phone, ['84', '85'].includes(prefix) ? 'mpesa' : 'emola', hash]
  );
  const login = await request(app).post('/api/v1/auth/login').send({ phone, password: PASSWORD });
  expect(login.status).toBe(200);
  return { id: rows[0].id, phone, token: login.body.data.accessToken };
}
const auth = (u) => ({ Authorization: `Bearer ${u.token}` });


describe('editar perfil', () => {
  it('muda nome e foto (só https) e recusa foto http', async () => {
    const u = await makeUser();
    const ok = await request(app).patch('/api/v1/users/me').set(auth(u))
      .send({ name: 'Novo Nome', avatarUrl: 'https://exemplo.com/a.png' });
    expect(ok.status).toBe(200);
    expect(ok.body.data.name).toBe('Novo Nome');
    expect(ok.body.data.avatarUrl).toBe('https://exemplo.com/a.png');
    const bad = await request(app).patch('/api/v1/users/me').set(auth(u)).send({ avatarUrl: 'http://x.com/a.png' });
    expect(bad.status).toBe(400);
    const rem = await request(app).patch('/api/v1/users/me').set(auth(u)).send({ avatarUrl: null });
    expect(rem.body.data.avatarUrl).toBeNull();
    const empty = await request(app).patch('/api/v1/users/me').set(auth(u)).send({});
    expect(empty.status).toBe(400);
  });
});

describe('número de pagamento', () => {
  it('pede senha, deduz o operador do número e aplica o intervalo de 30 dias', async () => {
    const u = await makeUser('84');
    const novo = `86${rnd()}`.slice(0, 9);
    const semSenha = await request(app).put('/api/v1/users/me/payment-phone').set(auth(u)).send({ phone: novo });
    expect(semSenha.status).toBe(401);
    const ok = await request(app).put('/api/v1/users/me/payment-phone').set(auth(u)).send({ phone: novo, password: PASSWORD });
    expect(ok.status).toBe(200);
    expect(ok.body.data.phone).toBe(novo);
    const { rows } = await db.query('SELECT phone_provider FROM users WHERE id=$1', [u.id]);
    expect(rows[0].phone_provider).toBe('emola');
    const outro = `85${rnd()}`.slice(0, 9);
    const cd = await request(app).put('/api/v1/users/me/payment-phone').set(auth(u)).send({ phone: outro, password: PASSWORD });
    expect(cd.status).toBe(422);
  });

  it('recusa número de outra conta e saque em andamento', async () => {
    const a = await makeUser('84');
    const b = await makeUser('85');
    const dup = await request(app).put('/api/v1/users/me/payment-phone').set(auth(a)).send({ phone: b.phone, password: PASSWORD });
    expect(dup.status).toBe(409);
    await db.query(`INSERT INTO withdrawal_requests (user_id, amount_mzn, method, trust_score_at_request) VALUES ($1, 100, 'mpesa', 100)`, [b.id]);
    const w = await request(app).put('/api/v1/users/me/payment-phone').set(auth(b)).send({ phone: `87${rnd()}`.slice(0, 9), password: PASSWORD });
    expect(w.status).toBe(422);
  });

  it('o saque tem de usar o método do número registado', async () => {
    const u = await makeUser('84');
    await db.query('UPDATE users SET wallet_balance_mzn = 500 WHERE id=$1', [u.id]);
    const r = await request(app).post('/api/v1/wallet/withdrawals').set(auth(u)).send({ amountMzn: 100, method: 'emola' });
    expect(r.status).toBe(422);
    expect(r.body.message).toMatch(/M-Pesa/);
  });
});

describe('senha', () => {
  it('troca com a senha atual, recusa errada/igual/curta e termina outras sessões', async () => {
    const u = await makeUser();
    const outra = await request(app).post('/api/v1/auth/login').send({ phone: u.phone, password: PASSWORD });
    const outroCookie = outra.headers['set-cookie'];
    const errada = await request(app).put('/api/v1/users/me/password').set(auth(u)).send({ currentPassword: 'x', newPassword: 'novaSenha123' });
    expect(errada.status).toBe(401);
    const igual = await request(app).put('/api/v1/users/me/password').set(auth(u)).send({ currentPassword: PASSWORD, newPassword: PASSWORD });
    expect(igual.status).toBe(422);
    const curta = await request(app).put('/api/v1/users/me/password').set(auth(u)).send({ currentPassword: PASSWORD, newPassword: '123' });
    expect(curta.status).toBe(400);
    const ok = await request(app).put('/api/v1/users/me/password').set(auth(u)).send({ currentPassword: PASSWORD, newPassword: 'novaSenha123' });
    expect(ok.status).toBe(200);
    expect(ok.body.data.hadPassword).toBe(true);
    const velha = await request(app).post('/api/v1/auth/login').send({ phone: u.phone, password: PASSWORD });
    expect(velha.status).toBe(401);
    const nova = await request(app).post('/api/v1/auth/login').send({ phone: u.phone, password: 'novaSenha123' });
    expect(nova.status).toBe(200);
    const refresh = await request(app).post('/api/v1/auth/refresh').set('Cookie', outroCookie);
    expect(refresh.status).toBe(401);
  });

  it('conta criada pelo Google (sem senha) pode definir uma, sem senha atual', async () => {
    const u = await makeUser();
    await db.query('UPDATE users SET password_hash = NULL WHERE id=$1', [u.id]);
    const me = await request(app).get('/api/v1/users/me').set(auth(u));
    expect(me.body.data.hasPassword).toBe(false);
    const r = await request(app).put('/api/v1/users/me/password').set(auth(u)).send({ newPassword: 'minhaSenha123' });
    expect(r.status).toBe(200);
    expect(r.body.data.hadPassword).toBe(false);
    const login = await request(app).post('/api/v1/auth/login').send({ phone: u.phone, password: 'minhaSenha123' });
    expect(login.status).toBe(200);
    const me2 = await request(app).get('/api/v1/users/me').set(auth(u));
    expect(me2.body.data.hasPassword).toBe(true);
  });
});

describe('exportar e apagar conta', () => {
  it('exporta os dados do próprio utilizador', async () => {
    const u = await makeUser();
    const r = await request(app).get('/api/v1/users/me/export').set(auth(u));
    expect(r.status).toBe(200);
    expect(r.body.data.profile.id).toBe(u.id);
    expect(r.body.data.profile.password_hash).toBeUndefined();
    expect(Array.isArray(r.body.data.wallet_transactions)).toBe(true);
  });

  it('exige confirmação, senha, sem saque pendente e avisa do saldo', async () => {
    const u = await makeUser();
    const sem = await request(app).delete('/api/v1/users/me').set(auth(u)).send({ password: PASSWORD });
    expect(sem.status).toBe(400);
    const errada = await request(app).delete('/api/v1/users/me').set(auth(u)).send({ password: 'x', confirmation: 'ELIMINAR' });
    expect(errada.status).toBe(401);
    await db.query('UPDATE users SET wallet_balance_mzn = 20 WHERE id=$1', [u.id]);
    const saldo = await request(app).delete('/api/v1/users/me').set(auth(u)).send({ password: PASSWORD, confirmation: 'ELIMINAR' });
    expect(saldo.status).toBe(422);
    expect(saldo.body.message).toMatch(/20\.00 MZN/);
  });

  it('anonimiza a conta, fecha a sessão e liberta o número', async () => {
    const u = await makeUser();
    const r = await request(app).delete('/api/v1/users/me').set(auth(u)).send({ password: PASSWORD, confirmation: 'ELIMINAR' });
    expect(r.status).toBe(200);
    const { rows } = await db.query('SELECT name, phone, password_hash, deleted_at FROM users WHERE id=$1', [u.id]);
    expect(rows[0].name).toBe('Utilizador removido');
    expect(rows[0].phone).toBeNull();
    expect(rows[0].password_hash).toBeNull();
    expect(rows[0].deleted_at).not.toBeNull();
    const login = await request(app).post('/api/v1/auth/login').send({ phone: u.phone, password: PASSWORD });
    expect(login.status).toBe(401);
    const me = await request(app).get('/api/v1/users/me').set(auth(u));
    expect(me.status).toBe(404);
    const audit = await db.query(`SELECT 1 FROM audit_logs WHERE user_id=$1 AND action='user.account_deleted'`, [u.id]);
    expect(audit.rows.length).toBe(1);
    // o número pode ser usado de novo por uma conta nova
    const novo = await request(app).post('/api/v1/auth/register').send({
      name: 'De Novo', phone: u.phone, password: PASSWORD, isAdultDeclared: true, termsAccepted: true,
    });
    expect(novo.status).toBe(201);
  });
});
