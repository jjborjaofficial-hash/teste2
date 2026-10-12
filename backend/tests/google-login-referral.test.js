// Convite no login com Google (12/10): antes só o cadastro por telefone ligava o convite, e quem entrava pelo botão
// "Continuar com Google" a partir de um link ?ref= perdia-o. O Google é simulado (não há login real nos testes).
const mockVerify = jest.fn();
jest.mock('google-auth-library', () => ({
  OAuth2Client: jest.fn().mockImplementation(() => ({ verifyIdToken: mockVerify })),
}));

process.env.GOOGLE_CLIENT_ID = 'cliente-de-teste';
const request = require('supertest');
const app = require('../src/app');
const db = require('../src/config/database');

const unico = () => `${Date.now()}${Math.floor(Math.random() * 1e6)}`;
let referrerId;
let code;
const criados = [];

function googleComo(sub, email) {
  mockVerify.mockResolvedValue({ getPayload: () => ({ sub, email, name: 'Convidado Google' }) });
}
const entrar = (ip, corpo) =>
  request(app).post('/api/v1/auth/google').set('X-Forwarded-For', ip).send({ idToken: 'token-simulado-123', ...corpo });
const convitesDe = async (referrer) =>
  (await db.query('SELECT referred_user_id FROM referrals WHERE referrer_user_id = $1', [referrer])).rows;

beforeAll(async () => {
  const phone = `84${Math.floor(1000000 + Math.random() * 8999999)}`;
  referrerId = (await db.query(
    `INSERT INTO users (name, phone, password_hash, phone_provider, status) VALUES ('Quem Convida', $1, 'x', 'mpesa', 'active') RETURNING id`,
    [phone]
  )).rows[0].id;
  code = `T${Math.floor(Math.random() * 1e8)}`.slice(0, 10);
  await db.query('INSERT INTO referral_codes (user_id, code) VALUES ($1, $2)', [referrerId, code]);
});

afterAll(async () => {
  await db.query('DELETE FROM referrals WHERE referrer_user_id = $1', [referrerId]);
  await db.query('DELETE FROM referral_codes WHERE user_id = $1', [referrerId]);
  for (const id of criados) {
    await db.query('DELETE FROM refresh_tokens WHERE user_id = $1', [id]).catch(() => {});
    await db.query('DELETE FROM audit_logs WHERE user_id = $1', [id]).catch(() => {});
    await db.query('DELETE FROM streaks WHERE user_id = $1', [id]).catch(() => {});
    await db.query('DELETE FROM users WHERE id = $1', [id]).catch(() => {});
  }
  await db.query('DELETE FROM users WHERE id = $1', [referrerId]).catch(() => {});
  await db.pool.end();
});

describe('POST /auth/google com código de convite', () => {
  it('uma conta Google NOVA fica ligada a quem a convidou (mesmo com o código em minúsculas)', async () => {
    googleComo(`g-${unico()}`, `novo${unico()}@exemplo.com`);
    const res = await entrar('203.0.113.51', { referralCode: code.toLowerCase() });
    expect(res.status).toBe(200);
    criados.push(res.body.data.user.id);
    const convites = await convitesDe(referrerId);
    expect(convites.map((c) => c.referred_user_id)).toContain(res.body.data.user.id);
  });

  it('um código inexistente não impede a entrada e não cria convite', async () => {
    const antes = (await convitesDe(referrerId)).length;
    googleComo(`g-${unico()}`, `novo${unico()}@exemplo.com`);
    const res = await entrar('203.0.113.52', { referralCode: 'NAOEXISTE1' });
    expect(res.status).toBe(200);
    criados.push(res.body.data.user.id);
    expect((await convitesDe(referrerId)).length).toBe(antes);
  });

  it('quem JÁ tinha conta Google não pode ser convidado depois', async () => {
    const sub = `g-${unico()}`;
    const email = `existente${unico()}@exemplo.com`;
    googleComo(sub, email);
    const primeira = await entrar('203.0.113.53', {}); // cria a conta, sem convite
    criados.push(primeira.body.data.user.id);
    const antes = (await convitesDe(referrerId)).length;
    const segunda = await entrar('203.0.113.54', { referralCode: code });
    expect(segunda.status).toBe(200);
    expect((await convitesDe(referrerId)).length).toBe(antes);
  });

  it('sem código continua a funcionar como antes', async () => {
    googleComo(`g-${unico()}`, `novo${unico()}@exemplo.com`);
    const res = await entrar('203.0.113.55', {});
    expect(res.status).toBe(200);
    criados.push(res.body.data.user.id);
  });

  it('rejeita um código com mais de 12 caracteres (mesma regra do cadastro)', async () => {
    googleComo(`g-${unico()}`, `novo${unico()}@exemplo.com`);
    const res = await entrar('203.0.113.56', { referralCode: 'A'.repeat(13) });
    expect(res.status).toBe(400);
  });
});
