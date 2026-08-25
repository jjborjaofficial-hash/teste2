const db = require('../../../config/database');
const repository = require('../repositories/quizRepository');
const quizTimerService = require('./quizTimerService');
const xpService = require('../../gamification/services/xpService');
const streakService = require('../../gamification/services/streakService');
const missionsService = require('../../missions/services/missionsService');
const referralsService = require('../../referrals/services/referralsService');
const trustScoreService = require('../../trustscore/services/trustScoreService');
const { NotFoundError, BusinessRuleError } = require('../../../common/errors/AppError');

/**
 * Service do Quiz (Doc. Mestre Seção 19.4 — "O Coração do Sistema").
 * A validação da resposta acontece inteiramente aqui no backend; o frontend nunca
 * decide se uma resposta está certa (Manual Parte 5: o backend é a autoridade final).
 */

// Antifraude: tempo de resposta abaixo deste limiar é fisiologicamente improvável
// para leitura + decisão humana, e sinaliza possível automação (Doc. Mestre Seção 7).
const SUSPICIOUSLY_FAST_RESPONSE_MS = 400;

async function listCategories() {
  return repository.listActiveCategories();
}

async function getNextQuestion(categoryId, userId) {
  const question = await repository.getRandomQuestion(categoryId);
  if (!question) throw new NotFoundError('Nenhuma pergunta disponível para esta categoria.');

  // Antifraude (Seção 19.4): o relógio começa a contar AGORA, no servidor —
  // o frontend continua mostrando a contagem regressiva normalmente, mas ela
  // é só visual; quem decide o tempo real é este timestamp.
  await quizTimerService.markQuestionIssued(userId, question.id, question.time_limit_seconds);

  return question;
}

/**
 * Submete uma resposta. Fluxo (tudo em uma única transação):
 * 1. Busca a pergunta com a alternativa correta (nunca exposta ao cliente antes).
 * 2. Aplica a regra antifraude do cronômetro (Seção 19.4): tempo esgotado = errado.
 * 3. Registra a tentativa (medida antifraude / histórico — Seção 11).
 * 4. Se correta: credita XP, atualiza streak diário e progresso de missões da categoria.
 * 5. Ajusta o Trust Score se o tempo de resposta for suspeito (Seção 7).
 */
async function submitAnswer({ userId, questionId, alternativeId }) {
  const question = await repository.getQuestionWithCorrectAlternative(questionId);
  if (!question) throw new NotFoundError('Pergunta não encontrada.');

  const chosenAlternative = question.alternatives.find((a) => a.id === alternativeId);
  if (!chosenAlternative) {
    throw new BusinessRuleError('Alternativa não pertence a esta pergunta.');
  }

  // Antifraude (Seção 19.4): tempo medido INTEIRAMENTE pelo servidor — nunca
  // mais confiamos em um valor informado pelo cliente. `null` significa que
  // não existe (ou expirou) o registro de quando a pergunta foi entregue —
  // tratado como tempo esgotado por padrão (fail-safe a favor da integridade).
  const elapsedMs = await quizTimerService.consumeElapsedMs(userId, questionId);
  const responseTimeMs = elapsedMs === null ? question.time_limit_seconds * 1000 + 1 : elapsedMs;
  const timeExpired = elapsedMs === null || responseTimeMs > question.time_limit_seconds * 1000;
  const isCorrect = !timeExpired && chosenAlternative.is_correct;
  const xpAwarded = isCorrect ? question.xp_reward : 0;

  const client = await db.getClient();
  try {
    await client.query('BEGIN');

    await repository.recordAttempt(client, {
      userId,
      questionId,
      alternativeId,
      isCorrect,
      responseTimeMs,
      xpAwarded,
    });

    let xpResult = null;
    let streakResult = null;
    let missionsProgress = [];

    if (isCorrect) {
      xpResult = await xpService.addXpAndPoints(client, { userId, xpDelta: xpAwarded, pointsDelta: 0 });
      streakResult = await streakService.registerDailyActivity(client, userId);
      missionsProgress = await missionsService.incrementProgressForCategory(client, {
        userId,
        categoryId: question.category_id,
      });
      await referralsService.checkAndRewardQualification(client, userId);
    }

    // Antifraude: resposta certa E suspeitosamente rápida reduz o Trust Score,
    // mesmo que a resposta seja aceita (evita punir falsos positivos com reversão de XP).
    if (isCorrect && responseTimeMs < SUSPICIOUSLY_FAST_RESPONSE_MS) {
      await trustScoreService.adjust(client, {
        userId,
        delta: -5,
        reason: trustScoreService.REASONS.SUSPICIOUSLY_FAST_ANSWER,
        metadata: { questionId, responseTimeMs },
      });
    }

    await client.query('COMMIT');

    return {
      isCorrect,
      timeExpired,
      xpAwarded,
      newXpTotal: xpResult ? xpResult.xpTotal : undefined,
      newLevel: xpResult ? xpResult.level : undefined,
      leveledUp: xpResult ? xpResult.leveledUp : false,
      streak: streakResult ? streakResult.streak : undefined,
      streakMilestoneReached: streakResult ? streakResult.milestoneReached : undefined,
      missionsUpdated: missionsProgress.length,
    };
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}

module.exports = { listCategories, getNextQuestion, submitAnswer };
