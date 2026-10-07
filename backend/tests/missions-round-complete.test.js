/**
 * Teste de integração (PostgreSQL + Redis com as migrations): missão "completar uma rodada" (BE-005 b,
 * activity_type = 'round_complete'). O utilizador de teste NÃO é apagado no fim (audit_logs é append-only e
 * bloqueia o DELETE em cascata); removemos só as missões, atribuições, rodadas e tentativas criadas aqui.
 * As missões do teste são do tipo 'special' (não entram na atribuição automática das diárias dos outros testes).
 */
const db = require('../src/config/database');
const quizService = require('../src/modules/quiz/services/quizService');
const adminMissionsService = require('../src/modules/missions/services/adminMissionsService');
const missionsRepository = require('../src/modules/missions/repositories/missionsRepository');
const { createMissionSchema } = require('../src/modules/missions/validators/adminMissionsValidators');

let userId;
let categories;
const missionIds = {};

async function alternativeId(questionId, correct) {
  const { rows } = await db.query(
    'SELECT id FROM question_alternatives WHERE question_id = $1 AND is_correct = $2 LIMIT 1',
    [questionId, correct]
  );
  return rows[0].id;
}

/** Joga a rodada inteira; `wrongEvery` = erra a cada N-ésima (0 = acerta todas). Devolve a última resposta. */
async function playRound(roundId, { wrongEvery = 0, stopAfter = 10 } = {}) {
  let last;
  for (let i = 0; i < stopAfter; i += 1) {
    const q = await quizService.getRoundQuestion({ userId, roundId });
    const correct = !(wrongEvery && (i + 1) % wrongEvery === 0);
    last = await quizService.submitAnswer({ userId, questionId: q.id, alternativeId: await alternativeId(q.id, correct), roundId });
  }
  return last;
}

async function progressOf(key) {
  const { rows } = await db.query('SELECT progress_count, status FROM user_missions WHERE user_id = $1 AND mission_id = $2', [userId, missionIds[key]]);
  return rows[0];
}

beforeAll(async () => {
  const phone = `84${Math.floor(1000000 + Math.random() * 8999999)}`;
  const user = await db.query(
    `INSERT INTO users (name, phone, password_hash, phone_provider, status)
     VALUES ('Teste Missao Rodada', $1, 'x', 'mpesa', 'active') RETURNING id`,
    [phone]
  );
  userId = user.rows[0].id;
  await db.query('INSERT INTO streaks (user_id) VALUES ($1) ON CONFLICT DO NOTHING', [userId]);
  categories = (await db.query('SELECT id, name FROM categories WHERE is_active ORDER BY name')).rows;

  // Criadas pelo caminho do admin (inclui o novo activityType).
  const base = { type: 'special', xpReward: 0, pointsReward: 0, moneyRewardMzn: 0 };
  const a = await adminMissionsService.createMission({ ...base, title: 'TESTE 2 rodadas (qualquer categoria)', activityType: 'round_complete', targetQuizCount: 2 });
  const b = await adminMissionsService.createMission({ ...base, title: 'TESTE 1 rodada (2ª categoria)', activityType: 'round_complete', targetQuizCount: 1, categoryId: categories[1].id });
  const c = await adminMissionsService.createMission({ ...base, title: 'TESTE controlo quiz_count', activityType: 'quiz_count', targetQuizCount: 100 });
  Object.assign(missionIds, { A: a.id, B: b.id, C: c.id });
  for (const id of Object.values(missionIds)) {
    await missionsRepository.assignMissionIfNotPresent(db, { userId, missionId: id, targetSnapshot: id === missionIds.A ? 2 : id === missionIds.B ? 1 : 100 });
  }
});

afterAll(async () => {
  await db.query('DELETE FROM user_missions WHERE user_id = $1', [userId]);
  await db.query('DELETE FROM missions WHERE id = ANY($1::uuid[])', [Object.values(missionIds)]);
  await db.query('DELETE FROM quiz_attempts WHERE user_id = $1', [userId]);
  await db.query('DELETE FROM quiz_rounds WHERE user_id = $1', [userId]);
  await db.pool.end();
});

describe('missão "completar uma rodada" (round_complete)', () => {
  it('o admin cria missões do tipo novo e o tipo fica guardado', async () => {
    const { rows } = await db.query('SELECT activity_type FROM missions WHERE id = $1', [missionIds.A]);
    expect(rows[0].activity_type).toBe('round_complete');
  });

  it('o admin só pode criar tipos com lógica de progresso real (quiz_count, round_complete)', () => {
    const ok = { title: 'Missão X', type: 'daily' };
    expect(createMissionSchema.safeParse({ ...ok, activityType: 'round_complete' }).success).toBe(true);
    expect(createMissionSchema.safeParse({ ...ok, activityType: 'lesson_complete' }).success).toBe(false);
    expect(createMissionSchema.safeParse(ok).data.activityType).toBe('quiz_count'); // padrão antigo mantido
  });

  it('o banco recusa um tipo desconhecido (CHECK da migration 391)', async () => {
    await expect(db.query(`UPDATE missions SET activity_type = 'inventado' WHERE id = $1`, [missionIds.A])).rejects.toThrow();
  });

  it('no meio da rodada o progresso não anda; ao fechar a 10.ª conta +1 (só a missão de qualquer categoria)', async () => {
    const round = await quizService.startRound({ userId, categoryId: categories[0].id });
    await playRound(round.id, { wrongEvery: 4, stopAfter: 9 });
    expect((await progressOf('A')).progress_count).toBe(0);

    const q = await quizService.getRoundQuestion({ userId, roundId: round.id });
    const last = await quizService.submitAnswer({ userId, questionId: q.id, alternativeId: await alternativeId(q.id, true), roundId: round.id });
    expect(last.round.finished).toBe(true);

    expect(await progressOf('A')).toMatchObject({ progress_count: 1, status: 'in_progress' });
    expect(await progressOf('B')).toMatchObject({ progress_count: 0, status: 'in_progress' }); // outra categoria
  });

  it('o controlo quiz_count continua a contar só respostas certas (não foi quebrado)', async () => {
    const { rows } = await db.query('SELECT count(*)::int AS n FROM quiz_attempts WHERE user_id = $1 AND is_correct', [userId]);
    expect((await progressOf('C')).progress_count).toBe(rows[0].n);
  });

  it('a 2.ª rodada conclui a missão A e avisa o utilizador; contar não depende de acertar tudo', async () => {
    const round = await quizService.startRound({ userId, categoryId: categories[0].id });
    await playRound(round.id, { wrongEvery: 2 }); // erra metade
    const a = await progressOf('A');
    expect(a).toMatchObject({ progress_count: 2, status: 'completed' });
    const { rows } = await db.query(`SELECT count(*)::int AS n FROM notifications WHERE user_id = $1 AND type = 'mission_completed'`, [userId]);
    expect(rows[0].n).toBeGreaterThanOrEqual(1);
  });

  it('missão concluída não anda mais (uma 3.ª rodada não passa do alvo)', async () => {
    const round = await quizService.startRound({ userId, categoryId: categories[0].id });
    await playRound(round.id);
    expect(await progressOf('A')).toMatchObject({ progress_count: 2, status: 'completed' });
  });

  it('rodada abandonada não conta; a missão com categoria só conta rodadas dessa categoria', async () => {
    const abandoned = await quizService.startRound({ userId, categoryId: categories[1].id });
    await playRound(abandoned.id, { stopAfter: 4 });
    await quizService.startRound({ userId, categoryId: categories[2].id }); // abandona a da categoria 1
    const { rows } = await db.query('SELECT status FROM quiz_rounds WHERE id = $1', [abandoned.id]);
    expect(rows[0].status).toBe('abandoned');
    expect(await progressOf('B')).toMatchObject({ progress_count: 0, status: 'in_progress' });

    const round = await quizService.startRound({ userId, categoryId: categories[1].id });
    await playRound(round.id);
    expect(await progressOf('B')).toMatchObject({ progress_count: 1, status: 'completed' });
  });
});
