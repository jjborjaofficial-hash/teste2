/**
 * Teste de integração (PostgreSQL + Redis com as migrations): o resgate de uma missão devolve `leveledUp` e
 * `newLevel`, para o frontend mostrar o ecrã animado de subida de nível (FE-007). Só muda a resposta do servidor:
 * o XP, os Pontos e o dinheiro creditados são os mesmos de antes (recompensas 0 de dinheiro nestas missões de teste).
 *
 * O utilizador de teste NÃO é apagado no fim (audit_logs é append-only e bloqueia o DELETE em cascata); removemos só as
 * missões e atribuições criadas aqui e suspendemos a conta. As missões são 'special' (não entram na atribuição
 * automática das diárias dos outros testes).
 */
const db = require('../src/config/database');
const adminMissionsService = require('../src/modules/missions/services/adminMissionsService');
const missionsRepository = require('../src/modules/missions/repositories/missionsRepository');
const missionsService = require('../src/modules/missions/services/missionsService');

let userId;
const missionIds = [];

async function makeCompletedMission(title, xpReward) {
  const created = await adminMissionsService.createMission({
    type: 'special', xpReward, pointsReward: 0, moneyRewardMzn: 0,
    title, activityType: 'quiz_count', targetQuizCount: 1,
  });
  missionIds.push(created.id);
  const um = await missionsRepository.assignMissionIfNotPresent(db, { userId, missionId: created.id, targetSnapshot: 1 });
  const userMissionId = um?.id ?? (await db.query('SELECT id FROM user_missions WHERE user_id = $1 AND mission_id = $2', [userId, created.id])).rows[0].id;
  await db.query(`UPDATE user_missions SET status = 'completed', progress_count = 1 WHERE id = $1`, [userMissionId]);
  return userMissionId;
}

beforeAll(async () => {
  const phone = `84${Math.floor(1000000 + Math.random() * 8999999)}`;
  const user = await db.query(
    `INSERT INTO users (name, phone, password_hash, phone_provider, status)
     VALUES ('Teste Missao LevelUp', $1, 'x', 'mpesa', 'active') RETURNING id`,
    [phone]
  );
  userId = user.rows[0].id;
  await db.query('INSERT INTO streaks (user_id) VALUES ($1) ON CONFLICT DO NOTHING', [userId]);
});

afterAll(async () => {
  await db.query('DELETE FROM user_missions WHERE user_id = $1', [userId]);
  await db.query('DELETE FROM missions WHERE id = ANY($1::uuid[])', [missionIds]);
  await db.query('DELETE FROM notifications WHERE user_id = $1', [userId]);
  await db.query(`UPDATE users SET status = 'suspended', phone = NULL WHERE id = $1`, [userId]);
  await db.pool.end();
});

describe('resgate de missão: aviso de subida de nível', () => {
  it('XP pequeno, sem mudar de nível: leveledUp = false', async () => {
    const umId = await makeCompletedMission('TESTE LevelUp pequena', 10);
    const res = await missionsService.claimReward(userId, umId);
    expect(res.leveledUp).toBe(false);
    expect(res.newLevel).toBe(1);
    expect(res.rewardsGranted.xp).toBe(10);
  });

  it('XP grande, que muda de nível: leveledUp = true e newLevel maior que 1', async () => {
    const umId = await makeCompletedMission('TESTE LevelUp grande', 2000);
    const res = await missionsService.claimReward(userId, umId);
    expect(res.leveledUp).toBe(true);
    expect(res.newLevel).toBeGreaterThan(1);
    expect(res.rewardsGranted.xp).toBe(2000);
  });

  it('missão sem XP: leveledUp = false (e não rebenta)', async () => {
    const umId = await makeCompletedMission('TESTE LevelUp zero', 0);
    const res = await missionsService.claimReward(userId, umId);
    expect(res.leveledUp).toBe(false);
    expect(res.rewardsGranted.xp).toBe(0);
  });
});
