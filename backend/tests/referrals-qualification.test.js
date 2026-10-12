/**
 * Qualificação de convites com defesas contra contas falsas (migration 605).
 * Integração com PostgreSQL real. Cria utilizadores próprios (audit_logs é append-only, então ficam no banco).
 */
const db = require('../src/config/database');
const authRepository = require('../src/modules/auth/repositories/authRepository');
const referralsService = require('../src/modules/referrals/services/referralsService');

const run = process.env.RUN_DB_TESTS === '1' ? describe : describe.skip;
const RUN = Date.now().toString(36);
let seq = 0;
let question; let alternative; let categoryId;

async function newUser(tag) {
  seq += 1;
  const u = await authRepository.createUserFromGoogle({
    name: `T ${tag}`, email: `${tag}.${seq}.${RUN}@teste.local`, googleId: `g-${tag}-${seq}-${RUN}`, avatarUrl: null,
  });
  await authRepository.createStreakRow(u.id);
  return u.id;
}
async function link(referrerId, referredId) {
  await db.query('INSERT INTO referrals (referrer_user_id, referred_user_id) VALUES ($1, $2)', [referrerId, referredId]);
}
async function addCorrect(userId, n) {
  for (let i = 0; i < n; i += 1) {
    await db.query(
      `INSERT INTO quiz_attempts (user_id, question_id, alternative_id, is_correct, response_time_ms, xp_awarded, points_awarded)
       VALUES ($1, $2, $3, TRUE, 5000, 0, 0)`, [userId, question, alternative]);
  }
}
async function completeRound(userId) {
  await db.query(
    `INSERT INTO quiz_rounds (user_id, category_id, status, question_ids, answered_count, correct_count, completed_at)
     VALUES ($1, $2, 'completed', '{}', 10, 5, now())`, [userId, categoryId]);
}
const status = async (referredId) => (await db.query('SELECT status FROM referrals WHERE referred_user_id = $1', [referredId])).rows[0].status;
const points = async (userId) => Number((await db.query('SELECT points_balance FROM users WHERE id = $1', [userId])).rows[0].points_balance);
const check = (referredId) => referralsService.checkAndRewardQualification(db, referredId);
async function setConfig(key, value) {
  await db.query('UPDATE system_config SET value = to_jsonb($2::text::numeric) WHERE key = $1', [key, String(value)]);
}

run('convites: qualificação e antifraude', () => {
  const original = {};
  beforeAll(async () => {
    const q = (await db.query(`SELECT q.id, q.category_id, a.id AS alt FROM questions q JOIN question_alternatives a ON a.question_id = q.id WHERE q.is_active LIMIT 1`)).rows[0];
    question = q.id; alternative = q.alt; categoryId = q.category_id;
    for (const k of ['referral_min_completed_rounds', 'referral_min_trust_score', 'referral_max_rewards_per_referrer_per_day', 'referral_qualification_quiz_count', 'referral_reward_points']) {
      original[k] = (await db.query('SELECT value FROM system_config WHERE key = $1', [k])).rows[0]?.value;
    }
  });
  afterEach(async () => { for (const [k, v] of Object.entries(original)) if (v !== undefined) await setConfig(k, v); });
  afterAll(async () => { await db.pool.end(); });

  it('a migration 605 criou a configuração com valores prudentes', () => {
    expect(String(original.referral_min_completed_rounds)).toBe('1');
    expect(String(original.referral_min_trust_score)).toBe('60');
    expect(String(original.referral_max_rewards_per_referrer_per_day)).toBe('5');
  });

  it('menos de 5 respostas certas: nada acontece', async () => {
    const [a, b] = [await newUser('conv'), await newUser('conv')];
    await link(a, b); await addCorrect(b, 4); await completeRound(b);
    expect(await check(b)).toBeNull();
    expect(await status(b)).toBe('pending');
  });

  it('5 respostas certas SEM nenhuma rodada concluída: o convite fica pendente (conta falsa rápida não basta)', async () => {
    const [a, b] = [await newUser('conv'), await newUser('conv')];
    await link(a, b); await addCorrect(b, 5);
    const before = await points(a);
    expect(await check(b)).toBeNull();
    expect(await status(b)).toBe('pending');
    expect(await points(a)).toBe(before);
  });

  it('5 certas + 1 rodada concluída: recompensa o convidador uma só vez', async () => {
    const [a, b] = [await newUser('conv'), await newUser('conv')];
    await link(a, b); await addCorrect(b, 5); await completeRound(b);
    const before = await points(a);
    const r = await check(b);
    expect(r).toMatchObject({ referrerUserId: a, rewardPoints: 100 });
    expect(await status(b)).toBe('rewarded');
    expect(await points(a)).toBe(before + 100);
    expect(await check(b)).toBeNull(); // chamar de novo não paga outra vez
    expect(await points(a)).toBe(before + 100);
  });

  it('Trust Score baixo do convidado: pendente; quando recupera, qualifica depois', async () => {
    const [a, b] = [await newUser('conv'), await newUser('conv')];
    await link(a, b); await addCorrect(b, 5); await completeRound(b);
    await db.query('UPDATE users SET trust_score = 40 WHERE id = $1', [b]);
    expect(await check(b)).toBeNull();
    expect(await status(b)).toBe('pending');
    await db.query('UPDATE users SET trust_score = 80 WHERE id = $1', [b]);
    expect(await check(b)).not.toBeNull();
    expect(await status(b)).toBe('rewarded');
  });

  it('limite diário por convidador: acima dele o convite fica pendente e qualifica no dia seguinte', async () => {
    await setConfig('referral_max_rewards_per_referrer_per_day', 2);
    const a = await newUser('convidador');
    const done = [];
    for (let i = 0; i < 3; i += 1) {
      const b = await newUser('conv'); await link(a, b); await addCorrect(b, 5); await completeRound(b); done.push(b);
    }
    expect(await check(done[0])).not.toBeNull();
    expect(await check(done[1])).not.toBeNull();
    const before = await points(a);
    expect(await check(done[2])).toBeNull(); // 3.º do dia: passou do limite
    expect(await status(done[2])).toBe('pending');
    expect(await points(a)).toBe(before);
    // "Passa um dia": as recompensas de hoje passam para ontem.
    await db.query(`UPDATE referrals SET reward_granted_at = reward_granted_at - interval '1 day' WHERE referrer_user_id = $1 AND status = 'rewarded'`, [a]);
    expect(await check(done[2])).not.toBeNull();
    expect(await status(done[2])).toBe('rewarded');
  });

  it('o limite é por convidador: outro convidador não é afetado', async () => {
    await setConfig('referral_max_rewards_per_referrer_per_day', 1);
    const [a1, a2] = [await newUser('convidador'), await newUser('convidador')];
    const [b1, b2] = [await newUser('conv'), await newUser('conv')];
    await link(a1, b1); await link(a2, b2);
    for (const b of [b1, b2]) { await addCorrect(b, 5); await completeRound(b); }
    expect(await check(b1)).not.toBeNull();
    expect(await check(b2)).not.toBeNull();
  });

  it('o dono pode afrouxar pela configuração (rodadas mínimas = 0 aceita só as respostas certas)', async () => {
    await setConfig('referral_min_completed_rounds', 0);
    const [a, b] = [await newUser('conv'), await newUser('conv')];
    await link(a, b); await addCorrect(b, 5);
    expect(await check(b)).not.toBeNull();
  });
});
