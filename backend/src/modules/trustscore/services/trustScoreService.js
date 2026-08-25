const repository = require('../repositories/trustScoreRepository');
const userCache = require('../../../common/cache/userCache');

/**
 * Service do Trust Score (Doc. Mestre Seção 7 e 16.2 — Tolerância Zero).
 * Motivos de ajuste devem ser explícitos e sempre auditados via trust_score_history.
 */

const REASONS = {
  LEGITIMATE_QUIZ_ACTIVITY: 'legitimate_quiz_activity',
  SUSPICIOUSLY_FAST_ANSWER: 'suspiciously_fast_answer',
  FAILED_LOGIN_PATTERN: 'failed_login_pattern',
  WITHDRAWAL_APPROVED: 'withdrawal_approved',
  MANUAL_ADMIN_ADJUSTMENT: 'manual_admin_adjustment',
};

async function adjust(executor, { userId, delta, reason, metadata }) {
  if (!Object.values(REASONS).includes(reason)) {
    throw new Error(`Motivo de ajuste de Trust Score não reconhecido: ${reason}`);
  }
  const result = await repository.adjustScore(executor, { userId, delta, reason, metadata });

  // Centralizado aqui (não em cada chamador) porque o Trust Score muda tanto
  // por ação manual do admin quanto automaticamente durante o quiz (docx
  // "REDIS CACHE E CRON JOBS", Seção 2 — trust_score faz parte do perfil
  // cacheado do usuário).
  await userCache.invalidateProfile(userId);

  return result;
}

async function getCurrentScore(userId) {
  return repository.getScore(userId);
}

async function getHistory(userId, options) {
  return repository.getHistory(userId, options);
}

module.exports = { adjust, getCurrentScore, getHistory, REASONS };
