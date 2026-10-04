const db = require('../../../config/database');
const repository = require('../repositories/quizRepository');
const quizTimerService = require('./quizTimerService');
const { pickRoundQuestions } = require('./roundSelection');
const xpService = require('../../gamification/services/xpService');
const streakService = require('../../gamification/services/streakService');
const missionsService = require('../../missions/services/missionsService');
const referralsService = require('../../referrals/services/referralsService');
const trustScoreService = require('../../trustscore/services/trustScoreService');
const configRepository = require('../../../common/repositories/systemConfigRepository');
const { NotFoundError, BusinessRuleError } = require('../../../common/errors/AppError');

/**
 * Service do Quiz (Doc. Mestre Seção 19.4 — "O Coração do Sistema").
 * A validação da resposta acontece inteiramente aqui no backend; o frontend nunca
 * decide se uma resposta está certa (Manual Parte 5: o backend é a autoridade final).
 */

// Antifraude: tempo de resposta abaixo deste limiar é fisiologicamente improvável
// para leitura + decisão humana, e sinaliza possível automação (Doc. Mestre Seção 7).
const SUSPICIOUSLY_FAST_RESPONSE_MS = 400;

// Fallback caso `system_config` não tenha a chave (nunca deveria acontecer após a
// migration 029, mas evita que o Quiz pare de dar Pontos por uma linha ausente).
const DEFAULT_POINTS_BY_DIFFICULTY = { easy: 10, medium: 25, hard: 50 };

/**
 * Pontos por acerto, de acordo com a dificuldade da pergunta (docx
 * "Aprenda-e-Ganhe-Documentao-Oficial", Seção 5.9-B — "Quiz fácil: +10
 * pontos | Quiz médio: +25 pontos | Quiz difícil: +50 pontos"). Vem de
 * `system_config` (migration 029), não fixo no código, para poder ser
 * recalibrado sem deploy.
 */
async function getPointsRewardForDifficulty(difficulty) {
  const value = await configRepository.getConfigValue(`quiz_points_reward_${difficulty}`);
  return value !== null ? Number(value) : (DEFAULT_POINTS_BY_DIFFICULTY[difficulty] ?? 0);
}

async function listCategories() {
  return repository.listActiveCategories();
}

async function getNextQuestion(categoryId, userId) {
  // CORREÇÃO (F5 reinicia o relógio visual): antes de sortear uma pergunta
  // nova, verifica se o usuário já tem uma pergunta ativa e ainda dentro do
  // prazo real medido pelo servidor. Se tiver, repete a MESMA pergunta e
  // devolve o tempo restante real — em vez de sortear outra com o relógio
  // visual cheio de novo, o que permitiria "resetar" a contagem visualmente
  // só recarregando a tela. O tempo real sempre foi medido pelo servidor
  // (ver quizTimerService); esta correção só alinha o que o frontend mostra
  // a esse tempo real.
  const active = await quizTimerService.getActiveIssuedQuestion(userId);
  if (active) {
    const activeQuestion = await repository.getQuestionById(active.questionId, categoryId);
    if (activeQuestion) {
      return { ...activeQuestion, time_remaining_seconds: active.remainingSeconds };
    }
    // Pergunta ativa não existe mais nesta categoria (ex.: foi desativada) —
    // segue o caminho normal de sortear uma pergunta nova abaixo.
  }

  const question = await repository.getRandomQuestion(categoryId);
  if (!question) throw new NotFoundError('Nenhuma pergunta disponível para esta categoria.');

  // Antifraude (Seção 19.4): o relógio começa a contar AGORA, no servidor —
  // o frontend continua mostrando a contagem regressiva normalmente, mas ela
  // é só visual; quem decide o tempo real é este timestamp.
  await quizTimerService.markQuestionIssued(userId, question.id, question.time_limit_seconds);

  return { ...question, time_remaining_seconds: question.time_limit_seconds };
}

// ---------------------------------------------------------------------------
// Rodadas (quiz v2) — ver migration 107 e docs/quiz-v2-rodadas-e-feedback.md
// ---------------------------------------------------------------------------

const ROUND_SIZE = 10;
// Quantas candidatas olhar ao montar a rodada (o repositório já as ordena por preferência).
const ROUND_CANDIDATE_POOL = 80;

function serializeRound(round) {
  return {
    id: round.id,
    categoryId: round.category_id,
    status: round.status,
    total: round.total_questions,
    answered: round.answered_count,
    // posição da pergunta atual para o contador "n/10" (na última, nunca passa do total)
    current: Math.min(round.answered_count + 1, round.total_questions),
    correctCount: round.correct_count,
    finished: round.status === 'completed',
  };
}

/**
 * Inicia a rodada da categoria ou RETOMA a que está em andamento nela (é assim que
 * recarregar a página, ou sair e voltar, não perde nem duplica respostas). Se havia uma
 * rodada em andamento noutra categoria, ela é abandonada: só existe uma por utilizador.
 * As 10 perguntas são escolhidas AQUI, pelo servidor.
 */
async function startRound({ userId, categoryId }) {
  const category = await repository.getActiveCategory(categoryId);
  if (!category) throw new NotFoundError('Categoria não encontrada.');

  const client = await db.getClient();
  try {
    await client.query('BEGIN');

    const existing = await repository.getActiveRound(userId, client, { forUpdate: true });
    if (existing && existing.category_id === categoryId) {
      await client.query('COMMIT');
      return serializeRound(existing);
    }
    if (existing) await repository.abandonActiveRound(userId, client);

    const candidates = await repository.listRoundCandidates(userId, categoryId, ROUND_CANDIDATE_POOL, [], client);
    const picked = pickRoundQuestions(candidates, ROUND_SIZE);
    if (picked.length === 0) throw new NotFoundError('Nenhuma pergunta disponível para esta categoria.');

    const round = await repository.createRound(client, {
      userId,
      categoryId,
      questionIds: picked.map((q) => q.id),
    });
    await client.query('COMMIT');
    return serializeRound(round);
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}

/** Rodada em andamento do utilizador (ou null) — para recuperar o estado. */
async function getActiveRoundState(userId) {
  const round = await repository.getActiveRound(userId);
  return round ? serializeRound(round) : null;
}

/**
 * Pergunta atual da rodada. Reaproveita o cronómetro do servidor: se a pergunta atual já
 * foi entregue e ainda está no prazo, devolve a MESMA com o tempo restante real (F5 não
 * reinicia o relógio); caso contrário, entrega-a agora e começa a contar.
 */
async function getRoundQuestion({ userId, roundId }) {
  const round = await repository.getRoundForUser(roundId, userId);
  if (!round) throw new NotFoundError('Rodada não encontrada.');
  if (round.status !== 'in_progress') {
    throw new BusinessRuleError('Esta rodada já terminou. Escolha uma categoria para começar outra.');
  }

  const position = round.answered_count + 1; // 1-based
  let questionId = round.question_ids[round.answered_count];
  let question = await repository.getQuestionById(questionId, round.category_id);

  if (!question) {
    // A pergunta foi desativada depois de a rodada ser criada: troca por outra da categoria
    // que ainda não esteja nesta rodada, mantendo o total de 10.
    const [replacement] = await repository.listRoundCandidates(userId, round.category_id, 1, round.question_ids);
    if (!replacement) throw new NotFoundError('Nenhuma pergunta disponível para esta categoria.');
    await repository.replaceRoundQuestion(round.id, position, replacement.id);
    questionId = replacement.id;
    question = await repository.getQuestionById(questionId, round.category_id);
  }

  const active = await quizTimerService.getActiveIssuedQuestion(userId);
  let timeRemaining = question.time_limit_seconds;
  if (active && active.questionId === questionId) {
    timeRemaining = active.remainingSeconds;
  } else {
    await quizTimerService.markQuestionIssued(userId, questionId, question.time_limit_seconds);
  }

  return {
    ...question,
    time_remaining_seconds: timeRemaining,
    round: serializeRound(round),
  };
}

const ACCURACY = (correct, total) => (total > 0 ? Math.round((correct / total) * 100) : 0);

/** Resumo EXCLUSIVO desta rodada (só as respostas com este round_id). */
async function buildRoundSummary(round, executor = db) {
  const attempts = await repository.listRoundAttempts(round.id, executor);
  const total = attempts.length;
  const correct = attempts.filter((a) => a.is_correct).length;

  const byDifficulty = {};
  for (const a of attempts) {
    const d = (byDifficulty[a.difficulty] ||= { total: 0, correct: 0 });
    d.total += 1;
    if (a.is_correct) d.correct += 1;
  }
  // Melhor desempenho: dificuldade com maior aproveitamento (empate -> a mais difícil).
  const rank = { easy: 0, medium: 1, hard: 2 };
  const bestDifficulty = Object.entries(byDifficulty)
    .filter(([, v]) => v.correct > 0)
    .sort((a, b) => ACCURACY(b[1].correct, b[1].total) - ACCURACY(a[1].correct, a[1].total) || (rank[b[0]] ?? 0) - (rank[a[0]] ?? 0))
    .map(([difficulty]) => difficulty)[0] || null;

  return {
    categoryId: round.category_id,
    total,
    correct,
    wrong: total - correct,
    accuracyPercent: ACCURACY(correct, total),
    xpTotal: round.xp_total,
    pointsTotal: round.points_total,
    byDifficulty,
    bestDifficulty,
    // "Vale a pena rever": as perguntas que errou nesta rodada
    reviewStatements: attempts.filter((a) => !a.is_correct).map((a) => a.statement).slice(0, 5),
  };
}

/**
 * Submete uma resposta. Fluxo (tudo em uma única transação):
 * 1. Busca a pergunta com a alternativa correta (nunca exposta ao cliente antes).
 * 2. Aplica a regra antifraude do cronômetro (Seção 19.4): tempo esgotado = errado.
 * 3. Registra a tentativa (medida antifraude / histórico — Seção 11).
 * 4. Se correta: credita XP, atualiza streak diário e progresso de missões da categoria.
 * 5. Ajusta o Trust Score se o tempo de resposta for suspeito (Seção 7).
 */
async function submitAnswer({ userId, questionId, alternativeId, roundId = null }) {
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
  const pointsAwarded = isCorrect ? await getPointsRewardForDifficulty(question.difficulty) : 0;

  const client = await db.getClient();
  try {
    await client.query('BEGIN');

    // Rodada (quiz v2): a resposta tem de ser da pergunta ATUAL da rodada em andamento. O
    // FOR UPDATE serializa cliques duplos: o segundo envio já encontra a rodada avançada.
    let round = null;
    if (roundId) {
      round = await repository.getRoundForUser(roundId, userId, client, { forUpdate: true });
      if (!round) throw new NotFoundError('Rodada não encontrada.');
      if (round.status !== 'in_progress') {
        throw new BusinessRuleError('Esta rodada já terminou. Escolha uma categoria para começar outra.');
      }
      if (round.question_ids[round.answered_count] !== questionId) {
        throw new BusinessRuleError('Esta não é a pergunta atual da rodada.');
      }
    }

    await repository.recordAttempt(client, {
      userId,
      questionId,
      alternativeId,
      isCorrect,
      responseTimeMs,
      roundId: round ? round.id : null,
      xpAwarded,
      // Valor "bruto" pela dificuldade, antes do teto diário/boost aplicados em
      // xpService.addXpAndPoints — o valor efetivamente creditado (líquido) fica
      // em points_ledger.metadata (source = 'quiz_correct_answer').
      pointsAwarded,
    });

    let xpResult = null;
    let streakResult = null;
    let missionsProgress = [];

    if (isCorrect) {
      xpResult = await xpService.addXpAndPoints(client, {
        userId,
        xpDelta: xpAwarded,
        pointsDelta: pointsAwarded,
        pointsSource: 'quiz_correct_answer',
        pointsReferenceId: question.id,
        pointsMetadata: { difficulty: question.difficulty, categoryId: question.category_id },
      });
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

    let roundState;
    let roundSummary;
    if (round) {
      const updated = await repository.advanceRound(client, {
        roundId: round.id,
        isCorrect,
        xpAwarded,
        pointsAwarded: xpResult ? xpResult.pointsCredited : 0,
      });
      roundState = serializeRound(updated);
      if (updated.status === 'completed') roundSummary = await buildRoundSummary(updated, client);
    }

    await client.query('COMMIT');

    return {
      round: roundState,
      roundSummary,
      isCorrect,
      timeExpired,
      xpAwarded,
      pointsAwarded: xpResult ? xpResult.pointsCredited : 0,
      newXpTotal: xpResult ? xpResult.xpTotal : undefined,
      newPointsBalance: xpResult ? xpResult.pointsBalance : undefined,
      newLevel: xpResult ? xpResult.level : undefined,
      leveledUp: xpResult ? xpResult.leveledUp : false,
      pointsCappedByDailyLimit: xpResult ? xpResult.pointsCappedByDailyLimit : false,
      streak: streakResult ? streakResult.streak : undefined,
      // true só na 1ª resposta correta do dia (quando a ofensiva realmente aumenta);
      // nas seguintes o front não repete o aviso "+1 ofensiva".
      streakIncreasedToday: streakResult ? !streakResult.alreadyRegisteredToday : undefined,
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

module.exports = {
  listCategories,
  getNextQuestion,
  submitAnswer,
  startRound,
  getActiveRoundState,
  getRoundQuestion,
  ROUND_SIZE,
};
