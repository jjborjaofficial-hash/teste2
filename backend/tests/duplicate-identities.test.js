// Anti-duplicação (12/10): eliminar a conta liberta o telefone/e-mail/Google; sem memória disso dava para repetir o bónus
// de boas-vindas (até 12 MZN) criando e eliminando contas. Agora a identidade libertada é reconhecida (por hash) e a conta
// nova fica marcada: usa a plataforma, mas sem bónus de boas-vindas nem convites. E o Gmail com pontos ou "+" é a mesma caixa.
const mockVerify = jest.fn();
jest.mock('google-auth-library', () => ({
  OAuth2Client: jest.fn().mockImplementation(() => ({ verifyIdToken: mockVerify })),
}));
process.env.GOOGLE_CLIENT_ID = 'cliente-de-teste';
process.env.BCRYPT_SALT_ROUNDS = '4';

const db = require('../src/config/database');
const authService = require('../src/modules/auth/services/authService');
const authRepository = require('../src/modules/auth/repositories/authRepository');
const userRepository = require('../src/modules/users/repositories/userRepository');
const identityRepository = require('../src/common/repositories/identityRepository');
const welcomeBonusService = require('../src/modules/gamification/services/welcomeBonusService');
const { normalizeEmail, identityHash } = require('../src/common/utils/identity');

const rnd = () => Math.floor(Math.random() * 1e6);
const telefone = () => `84${Math.floor(1000000 + Math.random() * 8999999)}`;
const contexto = { ipAddress: '203.0.113.9', userAgent: 'teste' };
const criados = [];

async function criarUtilizador({ phone = null, email = null, googleId = null } = {}) {
  const { rows } = await db.query(
    `INSERT INTO users (name, phone, phone_provider, email, email_normalized, google_id, password_hash, status)
     VALUES ('Teste Identidade', $1, $2, $3, $4, $5, 'x', 'active') RETURNING id`,
    [phone, phone ? 'mpesa' : null, email, email ? normalizeEmail(email) : null, googleId]
  );
  criados.push(rows[0].id);
  return rows[0].id;
}
const recicladaE = async (id) => (await db.query('SELECT identity_recycled FROM users WHERE id = $1', [id])).rows[0].identity_recycled;

afterAll(async () => {
  for (const id of criados) {
    for (const t of ['welcome_rewards', 'referrals', 'streaks', 'refresh_tokens', 'audit_logs', 'consents']) {
      await db.query(`DELETE FROM ${t} WHERE ${t === 'referrals' ? 'referred_user_id' : 'user_id'} = $1`, [id]).catch(() => {});
    }
    await db.query('DELETE FROM users WHERE id = $1', [id]).catch(() => {});
  }
  await db.pool.end();
});

describe('normalização do e-mail', () => {
  it('Gmail ignora pontos, tudo depois de + e googlemail.com é o mesmo', () => {
    const forma = normalizeEmail('joaojose@gmail.com');
    expect(normalizeEmail('joao.jose@gmail.com')).toBe(forma);
    expect(normalizeEmail('Joao.Jose+rifa@Gmail.com')).toBe(forma);
    expect(normalizeEmail('joaojose@googlemail.com')).toBe(forma);
  });
  it('outros domínios só passam a minúsculas (não se sabe se ignoram o +)', () => {
    expect(normalizeEmail('Ana.Silva+x@empresa.co.mz')).toBe('ana.silva+x@empresa.co.mz');
    expect(normalizeEmail(null)).toBeNull();
  });
  it('o JavaScript e o SQL da migration 606 dão o mesmo resultado', async () => {
    for (const e of ['a.b.c+z@gmail.com', 'Joao.Jose@googlemail.com', 'x@empresa.co.mz', 'sem.pontos@gmail.com']) {
      const { rows } = await db.query(
        `SELECT CASE WHEN lower($1) ~ '@(gmail|googlemail)\\.com$'
                THEN replace(split_part(split_part(lower($1), '@', 1), '+', 1), '.', '') || '@gmail.com'
                ELSE lower($1) END AS n`, [e]);
      expect(rows[0].n).toBe(normalizeEmail(e));
    }
  });
});

describe('hash da identidade', () => {
  it('é estável, separa por tipo e não contém o valor original', () => {
    const h = identityHash('phone', '841234567');
    expect(h).toBe(identityHash('phone', '841234567'));
    expect(h).not.toBe(identityHash('email', '841234567'));
    expect(h).toMatch(/^[0-9a-f]{64}$/);
    expect(h).not.toContain('841234567');
  });
});

describe('e-mail duplicado do Gmail', () => {
  it('encontra a conta pelo e-mail mesmo com pontos ou +, e o banco recusa a segunda', async () => {
    const base = `u${rnd()}x`;
    const id = await criarUtilizador({ email: `${base.slice(0, 3)}.${base.slice(3)}@gmail.com` });
    const achada = await authRepository.findUserByEmail(`${base}+promo@gmail.com`);
    expect(achada && achada.id).toBe(id);
    await expect(criarUtilizador({ email: `${base}@googlemail.com` })).rejects.toMatchObject({ code: '23505' });
  });
});

describe('ciclo criar -> eliminar -> voltar com o mesmo telefone', () => {
  it('a conta nova é marcada, não recebe convite nem bónus de boas-vindas', async () => {
    const phone = telefone();
    const antiga = await criarUtilizador({ phone });
    await userRepository.anonymize(antiga, db); // o mesmo que "eliminar conta"
    expect(await recicladaE(antiga)).toBe(false);

    // quem convida
    const convidante = await criarUtilizador({ phone: telefone() });
    const codigo = `R${rnd()}`.slice(0, 10);
    await db.query('INSERT INTO referral_codes (user_id, code) VALUES ($1, $2)', [convidante, codigo]);

    const { user } = await authService.register({ name: 'Volta', phone, password: 'Senha123!', isAdultDeclared: true, referralCode: codigo }, contexto);
    criados.push(user.id);
    expect(await recicladaE(user.id)).toBe(true);
    const convites = (await db.query('SELECT 1 FROM referrals WHERE referred_user_id = $1', [user.id])).rows;
    expect(convites).toHaveLength(0); // sem convite

    await db.query("UPDATE users SET status = 'active' WHERE id = $1", [user.id]);
    expect((await welcomeBonusService.getStatus(user.id)).visible).toBe(false);
    await expect(welcomeBonusService.claimToday(user.id)).rejects.toThrow(/já foi usado antes/);
    await db.query('DELETE FROM referral_codes WHERE user_id = $1', [convidante]);
  });

  it('um telefone NUNCA usado continua a funcionar como antes (convite e bónus)', async () => {
    const convidante = await criarUtilizador({ phone: telefone() });
    const codigo = `N${rnd()}`.slice(0, 10);
    await db.query('INSERT INTO referral_codes (user_id, code) VALUES ($1, $2)', [convidante, codigo]);
    const { user } = await authService.register({ name: 'Novo', phone: telefone(), password: 'Senha123!', isAdultDeclared: true, referralCode: codigo }, contexto);
    criados.push(user.id);
    expect(await recicladaE(user.id)).toBe(false);
    expect((await db.query('SELECT 1 FROM referrals WHERE referred_user_id = $1', [user.id])).rows).toHaveLength(1);
    await db.query("UPDATE users SET status = 'active' WHERE id = $1", [user.id]);
    expect((await welcomeBonusService.getStatus(user.id)).visible).toBe(true);
    await db.query('DELETE FROM referral_codes WHERE user_id = $1', [convidante]);
  });

  it('telefone já ocupado por uma conta ativa continua a ser recusado', async () => {
    const phone = telefone();
    await criarUtilizador({ phone });
    await expect(authService.register({ name: 'Dup', phone, password: 'Senha123!', isAdultDeclared: true }, contexto)).rejects.toThrow(/Já existe uma conta/);
  });
});

describe('ciclo com a conta Google', () => {
  it('quem elimina a conta Google e volta com o mesmo Google é reconhecido', async () => {
    const sub = `g-${rnd()}${rnd()}`;
    const email = `gg${rnd()}@gmail.com`;
    const antiga = await criarUtilizador({ email, googleId: sub });
    await userRepository.anonymize(antiga, db);

    mockVerify.mockResolvedValue({ getPayload: () => ({ sub, email, name: 'Volta Google' }) });
    const r = await authService.loginWithGoogle({ idToken: 'token-simulado-123' }, contexto);
    criados.push(r.user.id);
    expect(r.user.id).not.toBe(antiga); // conta nova
    expect(await recicladaE(r.user.id)).toBe(true);
  });
});
