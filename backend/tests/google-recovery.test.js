// Recuperar a conta sem SMS: quem ligou o Google à conta redefine a senha entrando com ele.
// O Google é simulado (não há login real nos testes). Precisa de PostgreSQL (corre no CI).
const mockVerify = jest.fn();
jest.mock('google-auth-library', () => ({
  OAuth2Client: jest.fn().mockImplementation(() => ({ verifyIdToken: mockVerify })),
}));

process.env.GOOGLE_CLIENT_ID = 'cliente-de-teste';
const request = require('supertest');
const app = require('../src/app');
const db = require('../src/config/database');

const unico = () => `${Date.now()}${Math.floor(Math.random() * 1e6)}`;
const telefone = () => `84${Math.floor(1000000 + Math.random() * 8999999)}`;
const criados = [];
let ipSeq = 100;
const ip = () => `203.0.113.${(ipSeq += 1) % 250}`;

function googleComo(sub, email) {
  mockVerify.mockResolvedValue({ getPayload: () => ({ sub, email, name: 'Pessoa Google', email_verified: true }) });
}

async function cadastrar(senha) {
  const phone = telefone();
  const res = await request(app)
    .post('/api/v1/auth/register')
    .set('X-Forwarded-For', ip())
    .send({ name: 'Pessoa Teste', phone, password: senha, isAdultDeclared: true, termsAccepted: true });
  expect(res.status).toBe(201);
  criados.push(res.body.data.user.id);
  return { phone, token: res.body.data.accessToken, cookie: res.headers['set-cookie'], id: res.body.data.user.id };
}

const ligar = (token, ipv) =>
  request(app).post('/api/v1/auth/link-google').set('X-Forwarded-For', ipv).set('Authorization', `Bearer ${token}`).send({ idToken: 'token-simulado-123' });
const recuperar = (novaSenha) =>
  request(app).post('/api/v1/auth/recover-with-google').set('X-Forwarded-For', ip()).send({ idToken: 'token-simulado-123', newPassword: novaSenha });
const entrar = (phone, password) =>
  request(app).post('/api/v1/auth/login').set('X-Forwarded-For', ip()).send({ phone, password });

afterAll(async () => {
  for (const id of criados) {
    await db.query('DELETE FROM refresh_tokens WHERE user_id = $1', [id]).catch(() => {});
    await db.query('DELETE FROM audit_logs WHERE user_id = $1', [id]).catch(() => {});
    await db.query('DELETE FROM streaks WHERE user_id = $1', [id]).catch(() => {});
    await db.query('DELETE FROM users WHERE id = $1', [id]).catch(() => {});
  }
  await db.pool.end();
});

describe('Ligar o Google e recuperar a senha', () => {
  it('liga o Google, redefine a senha, termina as sessões antigas e entra com a nova', async () => {
    const conta = await cadastrar('senhaAntiga123');
    googleComo(`g-${unico()}`, `pessoa${unico()}@exemplo.com`);

    const lig = await ligar(conta.token, ip());
    expect(lig.status).toBe(200);

    const rec = await recuperar('senhaNova12345');
    expect(rec.status).toBe(200);
    expect(rec.body.data.user.id).toBe(conta.id);

    expect((await entrar(conta.phone, 'senhaNova12345')).status).toBe(200);
    expect((await entrar(conta.phone, 'senhaAntiga123')).status).toBe(401);

    // A sessão aberta antes da recuperação deixa de renovar.
    const velha = await request(app).post('/api/v1/auth/refresh').set('X-Forwarded-For', ip()).set('Cookie', conta.cookie);
    expect(velha.status).toBe(401);
  });

  it('um Google que não está ligado a nenhuma conta não recupera nada', async () => {
    googleComo(`g-${unico()}`, `ninguem${unico()}@exemplo.com`);
    const rec = await recuperar('senhaNova12345');
    expect(rec.status).toBe(401);
  });

  it('o mesmo Google não pode ser ligado a duas contas', async () => {
    const a = await cadastrar('senhaAntiga123');
    const b = await cadastrar('senhaAntiga123');
    googleComo(`g-${unico()}`, `duplo${unico()}@exemplo.com`);
    expect((await ligar(a.token, ip())).status).toBe(200);
    expect((await ligar(b.token, ip())).status).toBe(409);
  });

  it('a senha nova tem de ter pelo menos 8 caracteres', async () => {
    googleComo(`g-${unico()}`, `curta${unico()}@exemplo.com`);
    const rec = await recuperar('curta');
    expect(rec.status).toBe(400);
  });

  it('ligar o Google exige sessão iniciada', async () => {
    const res = await request(app)
      .post('/api/v1/auth/link-google')
      .set('X-Forwarded-For', ip())
      .send({ idToken: 'token-simulado-123' });
    expect(res.status).toBe(401);
  });
});
