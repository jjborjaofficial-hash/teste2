const db = require('../../../config/database');
const cacheService = require('../../../common/cache/cacheService');
const { todayInPlatformTz } = require('../../../common/time/platformTimezone');
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

/**
 * Garante que o usuário tenha as missões ativas atribuídas hoje (o CRON diário
 * faz isso em lote à meia-noite; aqui cobrimos quem entra antes do CRON rodar
 * ou se cadastrou durante o dia). Só missões 'daily' — as demais têm ciclo próprio.
 */
async function ensureAssigned(userId) {
  // Primeiro expira o que ficou a meio em dias anteriores, para não bloquear as de hoje.
  await repository.expireStaleDailyForUser(db, userId);
  const activeMissions = await repository.listActiveMissions();
  for (const mission of activeMissions) {
    if (mission.type !== 'daily') continue;
    // eslint-disable-next-line no-await-in-loop
    await repository.assignMissionIfNotPresent(db, {
      userId,
      missionId: mission.id,
      targetSnapshot: mission.target_quiz_count,
    });
  }
}

async function listMyMissions(userId) {
  await ensureAssigned(userId);

  const progress = await repository.getUserMissionProgress(userId);
  return progress.map((p) => ({
    userMissionId: p.id,
    title: p.title,
    description: p.description,
    type: p.type,
    activityType: p.activity_type,
    progress: p.progress_count,
    target: p.target_snapshot ?? p.target_quiz_count,
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

/**
 * Chamado pelo módulo Quiz quando uma rodada termina por completo (BE-005 b), dentro da mesma transação.
 * Missões 'round_complete' ganham +1 (só de rodadas concluídas, nunca abandonadas).
 */
async function incrementRoundCompletion(executor, { userId, categoryId }) {
  const updated = await repository.incrementRoundCompletion(executor, { userId, categoryId });

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

    let moneyCreditedMzn = 0;
    if (Number(userMission.money_reward_mzn) > 0) {
      const credit = await walletService.creditReward(
        {
          userId,
          amountMzn: Number(userMission.money_reward_mzn),
          source: 'mission_reward',
          referenceId: userMissionId,
        },
        client
      );
      // Valor REAL creditado (pode ser menor que o nominal se o teto diário de 7,20 MZN cortar).
      moneyCreditedMzn = credit ? Number(credit.amountCreditedMzn) : 0;
    }

    await repository.markRewardClaimed(client, userMissionId);

    await client.query('COMMIT');

    return {
      userMissionId,
      title: userMission.title,
      rewardsGranted: {
        xp: xpResult ? xpResult.xpCredited : 0,
        points: xpResult ? xpResult.pointsCredited : 0,
        moneyMzn: moneyCreditedMzn,
        moneyNominalMzn: Number(userMission.money_reward_mzn),
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

/**
 * Heartbeat de atividade (missão de 12 minutos). Chamado pelo frontend a cada
 * ~30s com a aba visível. O servidor é a única fonte do tempo (ver
 * repository.addActiveTime). Devolve o estado da missão de tempo do dia.
 */
async function registerHeartbeat(userId) {
  let updated = await progressEngine.updateAfterHeartbeat(db, { userId });
  if (updated.length === 0) {
    // Nenhuma missão de tempo em andamento: ou ainda não foi atribuída hoje, ou já foi concluída.
    await ensureAssigned(userId);
    updated = await progressEngine.updateAfterHeartbeat(db, { userId });
  }

  const mission = updated[0] || null;
  return {
    tracking: mission !== null,
    justCompleted: mission ? mission.status === 'completed' : false,
    minutes: mission ? mission.progress_count : null,
    targetMinutes: mission ? mission.target_snapshot : null,
  };
}

/**
 * Missão \"Entrar na plataforma\" (activity_type = 'login'). Antes (BE-001) ninguém
 * chamava `updateAfterLogin`, então a missão ficava 0/1 para todos os utilizadores.
 * Garante as missões do dia (podem ainda não existir, pois são atribuídas sob
 * demanda ou pelo CRON) e completa a de login. Idempotente por dia.
 */
async function registerPresence(userId) {
  await ensureAssigned(userId);
  return progressEngine.updateAfterLogin(db, { userId });
}

/**
 * Versão para renovação de sessão (refresh do token): o app renova o acesso a cada
 * poucos minutos, então limitamos a uma execução por utilizador por dia (Redis) para
 * não repetir a atribuição das missões em todo refresh. Se o Redis falhar, executa
 * normalmente (a operação é idempotente).
 */
async function registerPresenceOncePerDay(userId) {
  return cacheService.getOrSet(
    `missions:presence:${userId}:${todayInPlatformTz()}`,
    86400,
    async () => {
      await registerPresence(userId);
      return true;
    }
  );
}

module.exports = {
  listMyMissions,
  incrementProgressForCategory,
  incrementRoundCompletion,
  claimReward,
  registerHeartbeat,
  registerPresence,
  registerPresenceOncePerDay,
};
