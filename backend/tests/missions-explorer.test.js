/**
 * Teste de integração (PostgreSQL + Redis com as migrations): missão "Explorador" (activity_type =
 * 'category_exploration', "experimente N categorias diferentes hoje"). Antes desta correção nada chamava o motor de
 * progresso desta missão (`missionProgressService.updateAfterCategoryExploration`), por isso ficava sempre a 0.
 * Agora começar uma rodada numa categoria nova conta; retomar a mesma rodada ou repetir uma categoria não soma.
 *
 * O utilizador de teste NÃO é apagado no fim (audit_logs é append-only e bloqueia o DELETE em cascata); removemos só as
 * missões, atribuições, rodadas e notificações criadas aqui. A missão do teste é 'special' (não entra na atribuição
 * automática das diárias dos outros testes).
 */
const db = require('../src/config/database');
const quizService = require('../src/modules/quiz/services/quizService');
const adminMissionsService = require('../src/modules/missions/services/adminMissionsService');
const missionsRepository = require('../src/modules/missions/repositories/missionsRepository');

let userId;
let categories;
let missionId;

async function progress() {
  const { rows } = await db.query(
    'SELECT progress_count, status, cardinality(visited_categories) AS visited FROM user_missions WHERE user_id = $1 AND mission_id = $2',
    [userId, missionId]
  );
  return rows[0];
}

beforeAll(async () => {
  const phone = `84${Math.floor(1000000 + Math.random() * 8999999)}`;
  const user = await db.query(
    `INSERT INTO users (name, phone, password_hash, phone_provider, status)
     VALUES ('Teste Missao Explorador', $1, 'x', 'mpesa', 'active') RETURNING id`,
    [phone]
  );
  userId = user.rows[0].id;
  await db.query('INSERT INTO streaks (user_id) VALUES ($1) ON CONFLICT DO NOTHING', [userId]);
  categories = (await db.query('SELECT id, name FROM categories WHERE is_active ORDER BY name')).rows;

  // O validador do admin só aceita tipos "criáveis"; cria-se como quiz_count e muda-se o tipo (o CHECK da base aceita).
  const created = await adminMissionsService.createMission({
    type: 'special', xpReward: 0, pointsReward: 0, moneyRewardMzn: 0,
    title: 'TESTE Explorador (3 categorias)', activityType: 'quiz_count', targetQuizCount: 3,
  });
  missionId = created.id;
  await db.query(`UPDATE missions SET activity_type = 'category_exploration' WHERE id = $1`, [missionId]);
  await missionsRepository.assignMissionIfNotPresent(db, { userId, missionId, targetSnapshot: 3 });
});

afterAll(async () => {
  await db.query('DELETE FROM user_missions WHERE user_id = $1', [userId]);
  await db.query('DELETE FROM missions WHERE id = $1', [missionId]);
  await db.query('DELETE FROM quiz_attempts WHERE user_id = $1', [userId]);
  await db.query('DELETE FROM quiz_rounds WHERE user_id = $1', [userId]);
  await db.query('DELETE FROM notifications WHERE user_id = $1', [userId]);
  await db.pool.end();
});

describe('missão "Explorador" (category_exploration)', () => {
  it('há categorias suficientes para o teste', () => {
    expect(categories.length).toBeGreaterThanOrEqual(3);
  });

  it('começar uma rodada numa categoria nova conta 1', async () => {
    await quizService.startRound({ userId, categoryId: categories[0].id });
    expect(await progress()).toMatchObject({ progress_count: 1, status: 'in_progress', visited: 1 });
  });

  it('retomar a mesma rodada (recarregar a página) não soma outra vez', async () => {
    await quizService.startRound({ userId, categoryId: categories[0].id });
    await quizService.startRound({ userId, categoryId: categories[0].id });
    expect(await progress()).toMatchObject({ progress_count: 1, visited: 1 });
  });

  it('uma segunda categoria soma 1; voltar à primeira depois não soma', async () => {
    await quizService.startRound({ userId, categoryId: categories[1].id });
    expect(await progress()).toMatchObject({ progress_count: 2, status: 'in_progress', visited: 2 });

    await quizService.startRound({ userId, categoryId: categories[0].id }); // rodada nova na categoria já visitada
    expect(await progress()).toMatchObject({ progress_count: 2, status: 'in_progress', visited: 2 });
  });

  it('a terceira categoria conclui a missão e avisa o utilizador', async () => {
    await quizService.startRound({ userId, categoryId: categories[2].id });
    expect(await progress()).toMatchObject({ progress_count: 3, status: 'completed', visited: 3 });

    const { rows } = await db.query(
      `SELECT count(*)::int AS n FROM notifications WHERE user_id = $1 AND type = 'mission_completed'`,
      [userId]
    );
    expect(rows[0].n).toBe(1);
  });

  it('missão concluída não anda mais (uma 4.ª categoria não passa do alvo)', async () => {
    if (categories.length < 4) return;
    await quizService.startRound({ userId, categoryId: categories[3].id });
    expect(await progress()).toMatchObject({ progress_count: 3, status: 'completed' });
  });
});
