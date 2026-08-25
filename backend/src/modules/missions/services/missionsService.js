const db = require('../../../config/database');
const repository = require('../repositories/missionsRepository');
const progressEngine = require('./missionProgressService');
const xpService = require('../../gamification/services/xpService');
const walletService = require('../../wallet/services/walletService');
const notificationsService = require('../../notifications/services/notificationsService');
const { NotFoundError, BusinessRuleError, ConflictError } = require('../../../common/errors/AppError');

/**
 * Service do módulo Missões (Doc. Mestre Seção 4, 5, 8, 12 | Manual Parte 4).
 * Missões alimentam XP e Carteira quando concluídas e resgatadas (Mapa de Módulos, Seção 4).
 */

async function listMyMissions(userId) {
  // Garante que o usuário tenha as missões ativas atribuídas (auto-atribuição simples;
  // uma versão futura fará isso via CRON job diário — ver Manual Parte 3: CRON Jobs).
  const activeMissions = await repository.listActiveMissions();
  for (const mission of activeMissions) {
    // eslint-disable-next-line no-await-in-loop
    await repository.assignMissionIfNotPresent(db, {
      userId,
      missionId: mission.id,
      targetSnapshot: mission.target_quiz_count,
    });
  }

  const progress = await repository.getUserMissionProgress(userId);
  return progress.map((p) => ({
    userMissionId: p.id,
    title: p.title,
    description: p.description,
    type: p.type,
    progress: p.progress_count,
    target: p.target_quiz_count,
    status: p.status,
    rewards: {
      xp: p.xp_reward,
      points: p.points_reward,
      moneyMzn: Number(p.money_reward_mzn),
    },
  }));
}

/**
 * Chamado pelo módulo Quiz após uma resposta correta, dentro da mesma transação.
 */
async function incrementProgressForCategory(executor, { userId, categoryId }) {
  const updated = await repository.incrementProgressForCategory(executor, { userId, categoryId });

  const justCompleted = updated.filter((m) => m.status === 'completed');
  for (const mission of justCompleted) {
    // eslint-disable-next-line no-await-in-loop
    await notificationsService.notifyMissionCompleted(executor, userId, mission.title);
  }

  return updated;
}

async function claimReward(userId, userMissionId) {
  const client = await db.getClient();
  try {
    await client.query('BEGIN');

    const userMission = await repository.getUserMissionById(userId, userMissionId, client);
    if (!userMission) throw new NotFoundError('Missão não encontrada para este usuário.');

    if (userMission.status === 'reward_claimed') {
      throw new ConflictError('A recompensa desta missão já foi resgatada.');
    }
    if (userMission.status !== 'completed') {
      throw new BusinessRuleError('Esta missão ainda não foi concluída.');
    }

    let xpResult = null;
    if (userMission.xp_reward > 0 || userMission.points_reward > 0) {
      xpResult = await xpService.addXpAndPoints(client, {
        userId,
        xpDelta: userMission.xp_reward,
        pointsDelta: userMission.points_reward,
        pointsSource: 'mission_reward',
        pointsReferenceId: userMissionId,
      });
    }

    if (Number(userMission.money_reward_mzn) > 0) {
      await walletService.creditReward(
        {
          userId,
          amountMzn: Number(userMission.money_reward_mzn),
          source: 'mission_reward',
          referenceId: userMissionId,
        },
        client
      );
    }

    await repository.markRewardClaimed(client, userMissionId);

    await client.query('COMMIT');

    return {
      userMissionId,
      title: userMission.title,
      rewardsGranted: {
        xp: xpResult ? xpResult.xpCredited : 0,
        points: xpResult ? xpResult.pointsCredited : 0,
        moneyMzn: Number(userMission.money_reward_mzn),
        pointsBoostApplied: xpResult ? xpResult.pointsBoostApplied : false,
      },
    };
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}

module.exports = { listMyMissions, incrementProgressForCategory, claimReward };
