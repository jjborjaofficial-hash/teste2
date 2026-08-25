const repository = require('../repositories/missionsRepository');
const notificationsService = require('../../notifications/services/notificationsService');

/**
 * Motor de progresso de missões (spec original, Passo 7: "centralizar a
 * lógica para evitar inconsistências" — não espalhar regras de missão por
 * vários controllers).
 *
 * Cada `updateAfterX` corresponde a um `activity_type` de missões
 * (migration 022): login, quiz_count, category_exploration hoje têm lógica
 * real. lesson_complete e time_active_minutes ainda não têm — dependem de
 * módulos que não existem na plataforma (microaulas e rastreamento de
 * heartbeat de atividade), então missões desses tipos podem ser criadas pelo
 * admin mas nunca vão progredir sozinhas até esses módulos existirem. Isso é
 * intencional: melhor não fingir que funciona do que criar uma missão que o
 * usuário nunca consegue completar.
 */

async function notifyCompleted(executor, userId, justCompleted) {
  for (const mission of justCompleted) {
    // eslint-disable-next-line no-await-in-loop
    await notificationsService.notifyMissionCompleted(executor, userId, mission.title);
  }
}

/**
 * Chamado pelo módulo Quiz após uma resposta CORRETA, dentro da mesma
 * transação do resto da submissão.
 */
async function updateAfterQuiz(executor, { userId, categoryId }) {
  const updated = await repository.incrementProgressForCategory(executor, { userId, categoryId });
  await notifyCompleted(executor, userId, updated.filter((m) => m.status === 'completed'));
  return updated;
}

/**
 * Chamado pelo módulo Auth após um login válido (Missão 1 da spec de
 * missões diárias). Idempotente por dia: se a missão de login já estiver
 * 'completed' ou 'reward_claimed', a query simplesmente não afeta nenhuma
 * linha (WHERE status = 'in_progress') — múltiplos logins no mesmo dia não
 * completam a missão mais de uma vez.
 */
async function updateAfterLogin(executor, { userId }) {
  const updated = await repository.completeLoginMissions(executor, { userId });
  await notifyCompleted(executor, userId, updated);
  return updated;
}

/**
 * Chamado quando o usuário começa a explorar uma categoria (hoje, o sinal
 * real mais próximo de "visitou a categoria" que existe na plataforma é
 * pedir a primeira pergunta de um quiz nela — ver quizService.getNextQuestion).
 * Progresso conta CATEGORIAS DISTINTAS, não visitas (ver visited_categories,
 * migration 024).
 */
async function updateAfterCategoryExploration(executor, { userId, categoryId }) {
  const updated = await repository.incrementCategoryExploration(executor, { userId, categoryId });
  await notifyCompleted(executor, userId, updated.filter((m) => m.status === 'completed'));
  return updated;
}

module.exports = { updateAfterQuiz, updateAfterLogin, updateAfterCategoryExploration };
