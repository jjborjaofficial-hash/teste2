/**
 * Convite pelo login com Google: o código só liga quando a conta NASCE agora.
 * Integração com PostgreSQL real; só a verificação do token do Google é simulada.
 * (Os utilizadores de teste ficam no banco: audit_logs é append-only; e-mails e ids são únicos por execução.)
 */
const mockTokens = new Map();
jest.mock('google-auth-library', () => ({
  OAuth2Client: jest.fn().mockImplementation(() => ({
    verifyIdToken: jest.fn(async ({ idToken }) => {
      const payload = mockTokens.get(idToken);
      if (!payload) throw new Error('token inválido');
      return { getPayload: () => payload };
    }),
  })),
}));

process.env.GOOGLE_CLIENT_ID = process.env.GOOGLE_CLIENT_ID || 'teste-client-id';
const db = require('../src/config/database');
const authService = require('../src/modules/auth/services/authService');
const referralsService = require('../src/modules/referrals/services/referralsService');
const repository = require('../src/modules/auth/repositories/authRepository');

const run = process.env.RUN_DB_TESTS === '1' ? describe : describe.skip;
const RUN = Date.now().toString(36);
const ctx = { ipAddress: '127.0.0.1', userAgent: 'jest' };
let seq = 0;

function googleToken(tag) {
  seq += 1;
  const token = `tok-${RUN}-${tag}-${seq}`.padEnd(24, 'x');
  const payload = { sub: `g-${RUN}-${tag}-${seq}`, email: `${tag}.${seq}.${RUN}@teste.local`, name: `Teste ${tag}` };
  mockTokens.set(token, payload);
  return { token, payload };
}
const referralOf = async (referredUserId) =>
  (await db.query('SELECT referrer_user_id, status FROM referrals WHERE referred_user_id = $1', [referredUserId])).rows[0];

run('login com Google e convites', () => {
  let referrerId;
  let code;
  beforeAll(async () => {
    const { payload } = googleToken('convidador');
    const u = await repository.createUserFromGoogle({ name: 'Convidador', email: payload.email, googleId: payload.sub, avatarUrl: null });
    await repository.createStreakRow(u.id);
    referrerId = u.id;
    code = await referralsService.getOrCreateMyCode(u.id);
  });
  afterAll(async () => { await db.pool.end(); });

  it('conta NOVA com código: o convite fica ligado ao convidador (pendente)', async () => {
    const { token } = googleToken('novo');
    const res = await authService.loginWithGoogle({ idToken: token, referralCode: code }, ctx);
    const ref = await referralOf(res.user.id);
    expect(ref).toEqual({ referrer_user_id: referrerId, status: 'pending' });
  });

  it('conta NOVA sem código: nenhum convite é criado', async () => {
    const { token } = googleToken('semcodigo');
    const res = await authService.loginWithGoogle({ idToken: token }, ctx);
    expect(await referralOf(res.user.id)).toBeUndefined();
  });

  it('código inválido não impede o cadastro e não cria convite', async () => {
    const { token } = googleToken('invalido');
    const res = await authService.loginWithGoogle({ idToken: token, referralCode: 'ZZZZZZZZ' }, ctx);
    expect(res.user.id).toBeTruthy();
    expect(await referralOf(res.user.id)).toBeUndefined();
  });

  it('conta que JÁ EXISTE (2.º login) ignora o código: ninguém se liga a um convidador depois', async () => {
    const { token } = googleToken('antigo');
    const first = await authService.loginWithGoogle({ idToken: token }, ctx); // cria sem convite
    await authService.loginWithGoogle({ idToken: token, referralCode: code }, ctx); // entra de novo, agora com código
    expect(await referralOf(first.user.id)).toBeUndefined();
  });

  it('conta já cadastrada com o mesmo e-mail (só liga o Google) também ignora o código', async () => {
    const { token, payload } = googleToken('poremail');
    const existing = await repository.createUserFromGoogle({ name: 'Antiga', email: payload.email, googleId: `outro-${payload.sub}`, avatarUrl: null });
    await repository.createStreakRow(existing.id);
    const res = await authService.loginWithGoogle({ idToken: token, referralCode: code }, ctx);
    expect(res.user.id).toBe(existing.id);
    expect(await referralOf(existing.id)).toBeUndefined();
  });

  it('o convidador não pode usar o próprio código (auto-indicação)', async () => {
    const { token, payload } = googleToken('auto');
    const created = await authService.loginWithGoogle({ idToken: token }, ctx);
    const ownCode = await referralsService.getOrCreateMyCode(created.user.id);
    expect(await referralsService.linkReferral(undefined, { referralCode: ownCode, referredUserId: created.user.id })).toBeNull();
    expect(payload.email).toBeTruthy();
  });
});
