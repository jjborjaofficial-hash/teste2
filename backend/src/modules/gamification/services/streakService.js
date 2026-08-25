const repository = require('../repositories/gamificationRepository');
const xpService = require('./xpService');
const configRepository = require('../../../common/repositories/systemConfigRepository');
const walletService = require('../../wallet/services/walletService');
const notificationsService = require('../../notifications/services/notificationsService');
const userCache = require('../../../common/cache/userCache');
const { todayInPlatformTz, diffInCalendarDays } = require('../../../common/time/platformTimezone');

/**
 * Service de Streak / Ofensiva (Doc. Mestre Seção 5 — Tabela de Marcos de Ofensiva).
 * Deve ser chamado uma única vez por dia de atividade real do usuário (ex: ao concluir
 * o primeiro quiz do dia), sempre dentro da mesma transação da ação que a originou.
 */

const MILESTONES = [7, 15, 30, 60, 100];

// CORREÇÃO: antes "hoje" era calculado com `new Date()` + getters UTC, o que
// resolve a data no fuso UTC do processo Node — não no fuso de Moçambique
// (UTC+2). Um usuário estudando entre meia-noite e 2h da manhã (hora local)
// podia ter a atividade contada como "ontem" pelo servidor, quebrando o
// streak incorretamente. Ver common/time/platformTimezone.js.
function dateOnlyStringOf(dbDateValue) {
  // Colunas DATE do Postgres chegam ao driver `pg` como Date em meia-noite
  // UTC representando o calendário armazenado — extrair via getters UTC aqui
  // é correto (não é o mesmo bug: não estamos calculando "agora", só lendo
  // de volta um valor já gravado como data pura).
  const d = new Date(dbDateValue);
  return `${d.getUTCFullYear()}-${String(d.getUTCMonth() + 1).padStart(2, '0')}-${String(d.getUTCDate()).padStart(2, '0')}`;
}

async function grantMilestoneReward(executor, userId, days) {
  const config = await configRepository.getConfigValues([
    `streak_milestone_${days}_points`,
    `streak_milestone_${days}_money_mzn`,
  ]);

  const points = Number(config[`streak_milestone_${days}_points`] ?? 0);
  const moneyMzn = Number(config[`streak_milestone_${days}_money_mzn`] ?? 0);

  if (points > 0) {
    await xpService.addXpAndPoints(executor, {
      userId,
      xpDelta: 0,
      pointsDelta: points,
      pointsSource: `streak_milestone_${days}`,
    });
  }
  if (moneyMzn > 0) {
    await walletService.creditReward(
      { userId, amountMzn: moneyMzn, source: `streak_milestone_${days}` },
      executor
    );
  }

  return { days, pointsGranted: points, moneyGrantedMzn: moneyMzn };
}

/**
 * Registra a atividade diária do usuário e atualiza o streak.
 * Retorna o novo estado do streak e, se aplicável, o marco atingido nesta chamada.
 */
async function registerDailyActivity(executor, userId) {
  const streak = await repository.getStreak(userId, executor);
  if (!streak) throw new Error(`Registro de streak não encontrado para o usuário ${userId}.`);

  const todayStr = todayInPlatformTz();

  if (streak.last_activity_date) {
    const lastActivityStr = dateOnlyStringOf(streak.last_activity_date);
    const daysSince = diffInCalendarDays(todayStr, lastActivityStr);

    if (daysSince === 0) {
      // Já registrou atividade hoje — nada a fazer (evita duplo incremento).
      return { streak: normalizeStreak(streak), milestoneReached: null, alreadyRegisteredToday: true };
    }
  }

  let newCurrentStreak;
  let protectionConsumed = false;
  let justBroke = false;

  if (!streak.last_activity_date) {
    newCurrentStreak = 1;
  } else {
    const lastActivityStr = dateOnlyStringOf(streak.last_activity_date);
    const daysSince = diffInCalendarDays(todayStr, lastActivityStr);

    if (daysSince === 1) {
      newCurrentStreak = streak.current_streak_days + 1;
    } else if (streak.protection_active) {
      // Item de proteção (marco de 15 dias) evita a quebra do streak uma vez.
      newCurrentStreak = streak.current_streak_days + 1;
      protectionConsumed = true;
    } else {
      newCurrentStreak = 1; // streak quebrado
      justBroke = streak.current_streak_days > 0;
    }
  }

  const newLongestStreak = Math.max(streak.longest_streak_days, newCurrentStreak);

  await repository.updateStreak(executor, {
    userId,
    currentStreakDays: newCurrentStreak,
    longestStreakDays: newLongestStreak,
    lastActivityDate: todayStr,
    protectionActive: protectionConsumed ? false : streak.protection_active,
    // Registrado só quando um streak de verdade (>0 dias) acabou de quebrar —
    // é o que habilita a compra de "Recuperar Streak" na Loja, dentro de 24h
    // (docx "SISTEMA DE ECONOMIA E RECOMPENSAS" + catálogo da loja).
    brokenAt: justBroke ? new Date().toISOString() : null,
    preBreakStreakDays: justBroke ? streak.current_streak_days : null,
  });

  // Invalidação ativa do cache de streak (docx "REDIS CACHE E CRON JOBS",
  // Seção 3): a leitura seguinte (ex: tela de resultado do quiz) precisa
  // refletir o streak novo imediatamente, não o valor de até 10 min atrás.
  await userCache.invalidateStreak(userId);

  let milestoneReached = null;
  if (MILESTONES.includes(newCurrentStreak)) {
    const reward = await grantMilestoneReward(executor, userId, newCurrentStreak);
    if (newCurrentStreak === 15) {
      await repository.updateStreak(executor, {
        userId,
        currentStreakDays: newCurrentStreak,
        longestStreakDays: newLongestStreak,
        lastActivityDate: todayStr,
        protectionActive: true, // concede o item de proteção contra quebra do streak
      });
    }
    milestoneReached = reward;
    await notificationsService.notifyMilestoneReached(executor, userId, newCurrentStreak, reward);
  }

  return {
    streak: {
      currentStreakDays: newCurrentStreak,
      longestStreakDays: newLongestStreak,
      protectionConsumedToday: protectionConsumed,
    },
    milestoneReached,
    alreadyRegisteredToday: false,
  };
}

function normalizeStreak(row) {
  return {
    currentStreakDays: row.current_streak_days,
    longestStreakDays: row.longest_streak_days,
    protectionActive: row.protection_active,
  };
}

module.exports = { registerDailyActivity, MILESTONES };
