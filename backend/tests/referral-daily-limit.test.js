/**
 * Limite diário de convites (decisão do dono, 2026-10-29): no máximo 5 convites por pessoa por dia.
 * Teste de integração (PostgreSQL com as migrations). Os utilizadores de teste NÃO são apagados (audit_logs é
 * append-only); removemos só os convites e o código criados aqui.
 */
const db = require('../src/config/database');
const referralsService = require('../src/modules/referrals/services/referralsService');

const userIds = [];

async function makeUser(label) {
  const phone = `84${Math.floor(1000000 + Math.random() * 8999999)}`;
  const { rows } = await db.query(
    `INSERT INTO users (name, phone, password_hash, phone_provider, status)
     VALUES ($1, $2, 'x', 'mpesa', 'active') RETURNING id`,
    [`Teste Limite ${label}`, phone]
  );
  userIds.push(rows[0].id);
  return rows[0].id;
}

async function setLimit(value) {
  await db.query(
    `INSERT INTO system_config (key, value, description) VALUES ('referral_daily_invite_limit', $1, 'teste')
     ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value`,
    [String(value)]
  );
}

async function invite(code) {
  const invitee = await makeUser('Convidado');
  return referralsService.linkReferral(undefined, { referralCode: code, referredUserId: invitee });
}

afterAll(async () => {
  await db.query('DELETE FROM referrals WHERE referrer_user_id = ANY($1::uuid[])', [userIds]);
  await db.query('DELETE FROM referral_codes WHERE user_id = ANY($1::uuid[])', [userIds]);
  await setLimit(5);
  await db.pool.end();
});

describe('limite diário de convites', () => {
  beforeEach(async () => setLimit(5));

  it('os 5 primeiros convites do dia ficam vinculados e o 6.º não', async () => {
    const inviter = await makeUser('Convidador A');
    const code = await referralsService.getOrCreateMyCode(inviter);
    const results = [];
    for (let i = 0; i < 6; i += 1) results.push(await invite(code));
    expect(results.slice(0, 5).every((r) => r && r.id)).toBe(true);
    expect(results[5]).toBeNull();
    const { rows } = await db.query('SELECT COUNT(*)::int AS n FROM referrals WHERE referrer_user_id = $1', [inviter]);
    expect(rows[0].n).toBe(5);
  });

  it('o limite é por pessoa: outro convidador continua a poder convidar', async () => {
    const a = await makeUser('Convidador B1');
    const b = await makeUser('Convidador B2');
    const codeA = await referralsService.getOrCreateMyCode(a);
    const codeB = await referralsService.getOrCreateMyCode(b);
    for (let i = 0; i < 5; i += 1) await invite(codeA);
    expect(await invite(codeA)).toBeNull();
    expect(await invite(codeB)).toBeTruthy();
  });

  it('convites de dias anteriores não contam para o limite de hoje', async () => {
    const inviter = await makeUser('Convidador C');
    const code = await referralsService.getOrCreateMyCode(inviter);
    for (let i = 0; i < 5; i += 1) await invite(code);
    expect(await invite(code)).toBeNull();
    // Passa os 5 convites para há 2 dias: hoje volta a haver 5 vagas.
    await db.query(`UPDATE referrals SET created_at = now() - interval '2 days' WHERE referrer_user_id = $1`, [inviter]);
    expect(await invite(code)).toBeTruthy();
  });

  it('o limite lê-se de system_config: 2 limita a 2 e 0 desliga o limite', async () => {
    const inviter = await makeUser('Convidador D');
    const code = await referralsService.getOrCreateMyCode(inviter);
    await setLimit(2);
    expect(await invite(code)).toBeTruthy();
    expect(await invite(code)).toBeTruthy();
    expect(await invite(code)).toBeNull();
    await setLimit(0);
    for (let i = 0; i < 7; i += 1) expect(await invite(code)).toBeTruthy();
  });

  it('código inválido e auto-convite continuam a ser ignorados', async () => {
    const inviter = await makeUser('Convidador E');
    const code = await referralsService.getOrCreateMyCode(inviter);
    expect(await referralsService.linkReferral(undefined, { referralCode: 'NAOEXISTE', referredUserId: inviter })).toBeNull();
    expect(await referralsService.linkReferral(undefined, { referralCode: code, referredUserId: inviter })).toBeNull();
  });
});
