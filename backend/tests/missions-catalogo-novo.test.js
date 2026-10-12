/**
 * Catálogo diário novo (migration 601): 6 missões ativas; "acertar 30 em pelo menos 3 categorias" só
 * completa com o alvo E o mínimo de categorias distintas; "convidar 1 utilizador novo" completa quando o
 * convite qualifica. O utilizador de teste NÃO é apagado (audit_logs é append-only).
 */
const db = require('../src/config/database');
const missionsRepository = require('../src/modules/missions/repositories/missionsRepository');
const missionsService = require('../src/modules/missions/services/missionsService');

let userId;
let categories;
let missionId;

async function status() {
  const { rows } = await db.query('SELECT progress_count, status FROM user_missions WHERE user_id = $1 AND mission_id = $2', [userId, missionId]);
  return rows[0];
}

beforeAll(async () => {
  const phone = `84${Math.floor(1000000 + Math.random() * 8999999)}`;
  const user = await db.query(
    `INSERT INTO users (name, phone, password_hash, phone_provider, status)
     VALUES ('Teste Catalogo Missoes', $1, 'x', 'mpesa', 'active') RETURNING id`,
    [phone]
  );
  userId = user.rows[0].id;
  categories = (await db.query('SELECT id FROM categories WHERE is_active ORDER BY name')).rows;
});

afterAll(async () => {
  await db.query('DELETE FROM user_missions WHERE user_id = $1', [userId]);
  if (missionId) await db.query('DELETE FROM missions WHERE id = $1', [missionId]);
  await db.pool.end();
});

describe('catálogo diário (migrations 601 a 604) e rotação semanal', () => {
  it('tem 7 missões ativas, com os alvos pedidos; as 3 fixas não têm dias e as outras 4 rodam', async () => {
    const { rows } = await db.query(
      `SELECT title, activity_type, target_quiz_count, min_distinct_categories, money_reward_mzn, weekdays FROM missions
       WHERE type = 'daily' AND is_active ORDER BY title`
    );
    expect(rows).toHaveLength(7);
    const by = (t, extra = () => true) => rows.find((r) => r.activity_type === t && extra(r));
    expect(by('login').target_quiz_count).toBe(1);
    expect(by('time_active_minutes').target_quiz_count).toBe(20);
    expect(by('quiz_count', (r) => r.min_distinct_categories === 1).target_quiz_count).toBe(50);
    expect(by('quiz_count', (r) => r.min_distinct_categories === 3).target_quiz_count).toBe(30);
    expect(by('referral').target_quiz_count).toBe(1);
    expect(by('round_streak').target_quiz_count).toBe(6);
    expect(by('category_exploration').target_quiz_count).toBe(3);
    const fixed = rows.filter((r) => r.weekdays === null).map((r) => r.title).sort();
    expect(fixed).toEqual(['20 minutos de estudo', 'Acerte 50 perguntas', 'Fazer login']);
  });

  it('todos os dias da semana têm exatamente 6 missões, no máximo 7,20 MZN, com as 3 fixas; Convidar só 3 dias', async () => {
    const { rows } = await db.query(
      `SELECT title, money_reward_mzn, weekdays FROM missions WHERE type = 'daily' AND is_active`
    );
    let convidarDias = 0;
    for (let dia = 1; dia <= 7; dia += 1) {
      const doDia = rows.filter((r) => r.weekdays === null || r.weekdays.includes(dia));
      expect(doDia).toHaveLength(6);
      expect(doDia.reduce((s, r) => s + Number(r.money_reward_mzn), 0)).toBeLessThanOrEqual(7.2);
      for (const t of ['Fazer login', '20 minutos de estudo', 'Acerte 50 perguntas']) {
        expect(doDia.map((r) => r.title)).toContain(t);
      }
      if (doDia.some((r) => r.title === 'Convide um amigo')) convidarDias += 1;
    }
    expect(convidarDias).toBe(3);
  });

  it('listActiveMissions só devolve as missões agendadas para hoje', async () => {
    const today = (await db.query(`SELECT EXTRACT(ISODOW FROM now() AT TIME ZONE 'Africa/Maputo')::int AS d`)).rows[0].d;
    const active = await missionsRepository.listActiveMissions();
    const titles = new Set(active.map((m) => m.title));
    const { rows } = await db.query(`SELECT title, weekdays FROM missions WHERE type = 'daily' AND is_active`);
    for (const r of rows) {
      const expected = r.weekdays === null || r.weekdays.includes(today);
      expect(titles.has(r.title)).toBe(expected);
    }
  });
});

describe('acertar N perguntas em pelo menos 3 categorias', () => {
  it('só completa quando o alvo e o mínimo de categorias distintas estão cumpridos', async () => {
    expect(categories.length).toBeGreaterThanOrEqual(3);
    const { rows } = await db.query(
      `INSERT INTO missions (title, type, target_quiz_count, activity_type, min_distinct_categories)
       VALUES ('TESTE 4 certas em 3 categorias', 'special', 4, 'quiz_count', 3) RETURNING id`
    );
    missionId = rows[0].id;
    await missionsRepository.assignMissionIfNotPresent(db, { userId, missionId, targetSnapshot: 4 });
    const answer = (i) => missionsRepository.incrementProgressForCategory(db, { userId, categoryId: categories[i].id });

    for (let i = 0; i < 4; i += 1) await answer(0); // alvo atingido, mas só 1 categoria
    expect(await status()).toMatchObject({ progress_count: 4, status: 'in_progress' });
    await answer(1); // 2 categorias: ainda não
    expect(await status()).toMatchObject({ status: 'in_progress' });
    await answer(2); // 3.ª categoria: completa
    expect(await status()).toMatchObject({ progress_count: 6, status: 'completed' });
  });
});

describe('convidar 1 utilizador novo', () => {
  it('completa a missão do dia (atribuindo-a se ainda não existir) só nos dias em que ela está agendada', async () => {
    const today = (await db.query(`SELECT EXTRACT(ISODOW FROM now() AT TIME ZONE 'Africa/Maputo')::int AS d`)).rows[0].d;
    const scheduled = [2, 4, 6].includes(today);
    const done = await missionsService.completeReferralMissions(db, { userId });
    const { rows } = await db.query(
      `SELECT um.status FROM user_missions um JOIN missions m ON m.id = um.mission_id
       WHERE um.user_id = $1 AND m.activity_type = 'referral' AND m.type = 'daily'`, [userId]);
    if (scheduled) {
      expect(done.map((m) => m.title)).toContain('Convide um amigo');
      expect(rows[0].status).toBe('completed');
      // repetir no mesmo dia não completa outra vez
      expect(await missionsService.completeReferralMissions(db, { userId })).toHaveLength(0);
    } else {
      // fora dos dias agendados a missão não existe para o utilizador: nada é atribuído nem completado
      expect(done).toHaveLength(0);
      expect(rows).toHaveLength(0);
    }
  });
});

describe('acertar 6 perguntas seguidas numa rodada', () => {
  it('um erro volta a sequência a 0; 6 seguidas completam a missão e o progresso guarda a melhor sequência', async () => {
    const missionsService2 = require('../src/modules/missions/services/missionsService');
    const quizRepository = require('../src/modules/quiz/repositories/quizRepository');
    // uma pergunta diferente por resposta (índice único round_id + question_id)
    const qs = (await db.query(
      `SELECT q.id, (SELECT id FROM question_alternatives WHERE question_id = q.id LIMIT 1) AS alt
       FROM questions q WHERE q.is_active LIMIT 11`)).rows;
    const q = qs[0].id;
    let n = 0;
    const round = (await db.query(
      `INSERT INTO quiz_rounds (user_id, category_id, question_ids, total_questions) VALUES ($1, $2, ARRAY[$3]::uuid[], 10) RETURNING id`,
      [userId, categories[0].id, q])).rows[0].id;
    const answer = async (correct) => {
      const item = qs[n]; n += 1;
      await db.query(
        `INSERT INTO quiz_attempts (user_id, question_id, alternative_id, is_correct, response_time_ms, round_id)
         VALUES ($1, $2, $3, $4, 5000, $5)`, [userId, item.id, item.alt, correct, round]);
      const streak = await quizRepository.getRoundCorrectStreak(round);
      return { streak, state: await missionsService2.updateRoundStreak(db, { userId, streak }) };
    };
    for (let i = 0; i < 4; i += 1) await answer(true);
    expect((await answer(false)).state).toMatchObject({ current: 0, target: 6, completed: false });
    for (let i = 0; i < 5; i += 1) expect((await answer(true)).state.completed).toBe(false);
    const last = await answer(true);
    expect(last.streak).toBe(6);
    expect(last.state).toMatchObject({ current: 6, target: 6, completed: true });
    const { rows } = await db.query(
      `SELECT um.status, um.progress_count FROM user_missions um JOIN missions m ON m.id = um.mission_id
       WHERE um.user_id = $1 AND m.activity_type = 'round_streak' AND m.type = 'daily'`, [userId]);
    expect(rows[0]).toMatchObject({ status: 'completed', progress_count: 6 });
    await db.query('DELETE FROM quiz_attempts WHERE round_id = $1', [round]);
    await db.query('DELETE FROM quiz_rounds WHERE id = $1', [round]);
  });
});
