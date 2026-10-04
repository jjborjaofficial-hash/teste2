const db = require('../../../config/database');
const repository = require('../repositories/quizRepository');
const quizTimerService = require('./quizTimerService');
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

// Estrutura definitiva do quiz (docs/quiz-aprendizagem/INSTRUCAO_QUIZ.md, secção 3):
// a rodada tem EXATAMENTE 10 perguntas; aos 5 há só um checkpoint técnico (progresso
// gravado e verificado no servidor), sem resumo; o resumo aparece depois da 10.ª.
const ROUND_SIZE = 10;
const CHECKPOINT_EVERY = 5;
// Rodada em andamento sem atividade por este tempo é abandonada; a próxima abre uma nova.
const ROUND_IDLE_EXPIRY_HOURS = 12;
const { pickRoundQuestions } = require('./roundQuestionPicker');
const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

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

/**
 * Feedback pedagógico devolvido DEPOIS de a resposta ter sido registada: a alternativa
 * correta e a explicação. Antes de responder, o cliente nunca recebe nada disto
 * (getRandomQuestion não traz `is_correct` nem `explanation`).
 *
 * Anti-colheita: só revela a correta se a pergunta foi realmente entregue a este
 * utilizador por `next-question` (existe registo do cronómetro). Quem chama
 * `POST /quiz/answers` diretamente, com IDs de perguntas que nunca pediu, não fica a
 * conhecer as respostas. Se o Redis estiver indisponível o registo não existe, e o
 * feedback simplesmente não é enviado (o ecrã trata a ausência).
 */
function buildLearningFeedback(question, chosenAlternative, { questionWasIssued }) {
  const base = {
    chosenAlternativeId: chosenAlternative.id,
    difficulty: question.difficulty,
    categoryId: question.category_id,
  };
  if (!questionWasIssued) {
    return { ...base, correctAlternative: null, explanation: null, learnPoint: null, memoryTip: null };
  }
  const correct = question.alternatives.find((a) => a.is_correct);
  const clean = (text) => (text ? String(text).trim() || null : null);
  return {
    ...base,
    correctAlternative: correct ? { id: correct.id, label: correct.label } : null,
    explanation: clean(question.explanation),
    // "Aprenda:" / "O que aprender:" e "Dica:" (opcionais; nada é inventado quando faltam).
    learnPoint: clean(question.learn_point),
    memoryTip: clean(question.memory_tip),
  };
}

async function listCategories() {
  return repository.listActiveCategories();
}

/** Devolve a rodada em andamento da categoria ou abre uma nova (estado no servidor). */
async function getOrStartRound(userId, categoryId) {
  await repository.abandonStaleRounds(db, { userId, categoryId, idleHours: ROUND_IDLE_EXPIRY_HOURS });
  const existing = await repository.findInProgressRound(db, { userId, categoryId });
  if (existing) return existing;
  return repository.createRound(db, { userId, categoryId, targetQuestions: ROUND_SIZE });
}

function toRoundView(round, progress) {
  return {
    id: round.id,
    target: round.target_questions,
    answered: progress.answered,
    correct: progress.correct,
  };
}

/**
 * Garante que a rodada tem as suas perguntas escolhidas e guardadas (uma só vez, ao iniciar).
 * Rodadas antigas, já começadas antes desta funcionalidade (com respostas e sem perguntas
 * guardadas), continuam pelo caminho anterior.
 */
async function ensureRoundQuestions({ round, userId, categoryId }) {
  if ((await repository.countRoundQuestions(db, round.id)) > 0) return;

  const client = await db.getClient();
  try {
    await client.query('BEGIN');
    await repository.lockRound(client, round.id);
    // Reconfirmar já com a rodada bloqueada: outra chamada pode ter escolhido entretanto.
    if ((await repository.countRoundQuestions(client, round.id)) === 0) {
      const candidates = await repository.listRoundCandidates(client, { userId, categoryId });
      const ids = pickRoundQuestions(candidates, { count: round.target_questions });
      if (ids.length) await repository.insertRoundQuestions(client, round.id, ids);
    }
    await client.query('COMMIT');
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}

async function getNextQuestion(categoryId, userId) {
  // Categoria inválida ou inexistente: 404 em vez de erro 500 do banco.
  if (!UUID_RE.test(String(categoryId)) || !(await repository.categoryExists(categoryId))) {
    throw new NotFoundError('Categoria não encontrada.');
  }

  const round = await getOrStartRound(userId, categoryId);
  const progress = await repository.getRoundProgress(db, round.id);
  if (progress.answered === 0) await ensureRoundQuestions({ round, userId, categoryId });
  // P6b: se a rodada tem as suas perguntas guardadas, serve a primeira ainda não respondida,
  // pela posição. Rodadas antigas (sem perguntas guardadas) seguem o caminho anterior.
  const hasStoredQuestions = (await repository.countRoundQuestions(db, round.id)) > 0;
  let question;
  if (hasStoredQuestions) {
    question = await repository.getNextRoundQuestion(db, round.id);
    if (!question) throw new NotFoundError('Esta rodada não tem mais perguntas por responder.');
  } else {
    const answeredIds = await repository.listAnsweredQuestionIds(db, round.id);
    question = await repository.getRandomQuestion(categoryId, answeredIds);
    if (!question) throw new NotFoundError('Nenhuma pergunta disponível para esta categoria.');
  }

  // Antifraude (Seção 19.4): o relógio começa a contar AGORA, no servidor —
  // o frontend continua mostrando a contagem regressiva normalmente, mas ela
  // é só visual; quem decide o tempo real é este timestamp.
  // Com a pergunta guardada na rodada, recarregar a página serve a MESMA pergunta: o relógio
  // original é mantido (keepExisting) e o frontend recebe só o tempo que ainda resta.
  const issuedAtMs = await quizTimerService.markQuestionIssued(
    userId,
    question.id,
    question.time_limit_seconds,
    { keepExisting: hasStoredQuestions }
  );
  const elapsedSeconds = Math.max(0, Math.floor((Date.now() - issuedAtMs) / 1000));
  const remainingSeconds = Math.max(0, question.time_limit_seconds - elapsedSeconds);

  // O progresso viaja com a pergunta: o contador "Pergunta N de 10" vem do servidor,
  // então recarregar a página não perde nem reinicia a rodada.
  return { ...question, time_remaining_seconds: remainingSeconds, round: toRoundView(round, progress) };
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
  const pointsAwarded = isCorrect ? await getPointsRewardForDifficulty(question.difficulty) : 0;

  const client = await db.getClient();
  try {
    await client.query('BEGIN');

    // Só associa a tentativa a uma rodada se a pergunta foi realmente entregue a este
    // utilizador (existe registo do cronómetro). Tentativas diretas na API ficam fora da
    // rodada e, por isso, fora do resumo (que mostra respostas corretas).
    // FOR UPDATE serializa duas respostas simultâneas da mesma rodada.
    const round = elapsedMs !== null
      ? await repository.findInProgressRound(client, { userId, categoryId: question.category_id, forUpdate: true })
      : null;

    await repository.recordAttempt(client, {
      userId,
      questionId,
      alternativeId,
      isCorrect,
      responseTimeMs,
      xpAwarded,
      // Valor "bruto" pela dificuldade, antes do teto diário/boost aplicados em
      // xpService.addXpAndPoints — o valor efetivamente creditado (líquido) fica
      // em points_ledger.metadata (source = 'quiz_correct_answer').
      pointsAwarded,
      roundId: round ? round.id : null,
    });

    let roundState = null;
    if (round) {
      const progress = await repository.getRoundProgress(client, round.id);
      const completed = progress.answered >= round.target_questions;
      const checkpoint = !completed && progress.answered === CHECKPOINT_EVERY;
      if (completed) {
        await repository.completeRound(client, round.id);
      } else if (progress.answered >= CHECKPOINT_EVERY) {
        await repository.markRoundCheckpoint(client, round.id);
      } else {
        await repository.touchRound(client, round.id);
      }
      roundState = { ...toRoundView(round, progress), checkpoint, completed };
    }

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

    await client.query('COMMIT');

    return {
      isCorrect,
      timeExpired,
      ...buildLearningFeedback(question, chosenAlternative, { questionWasIssued: elapsedMs !== null }),
      round: roundState,
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

/**
 * Resumo da rodada (depois da 10.ª pergunta). Os dados vêm das tentativas guardadas no
 * servidor, não do estado do navegador, então sobrevivem a recarregar a página.
 */
async function getRoundSummary({ userId, roundId }) {
  if (!UUID_RE.test(String(roundId))) throw new NotFoundError('Rodada não encontrada.');
  const round = await repository.getRoundOfUser(db, { roundId, userId });
  if (!round) throw new NotFoundError('Rodada não encontrada.');
  if (round.status !== 'completed') {
    throw new BusinessRuleError('Esta rodada ainda não foi concluída.');
  }

  const details = await repository.listRoundAttemptDetails(db, roundId);
  const answered = details.length;
  const correct = details.filter((d) => d.is_correct).length;

  const byDifficulty = ['easy', 'medium', 'hard']
    .map((difficulty) => {
      const rows = details.filter((d) => d.difficulty === difficulty);
      return { difficulty, answered: rows.length, correct: rows.filter((d) => d.is_correct).length };
    })
    .filter((d) => d.answered > 0);

  // Melhor desempenho / vale a pena rever: a rodada é de uma só categoria e as perguntas
  // ainda não têm conceitos (tags), então o agrupamento disponível é a dificuldade.
  const ranked = byDifficulty
    .map((d) => ({ ...d, rate: d.correct / d.answered }))
    .sort((a, b) => b.rate - a.rate);
  const best = ranked.length && ranked[0].rate > 0 ? ranked[0].difficulty : null;
  const weakest = ranked.length && ranked[ranked.length - 1].rate < 1 ? ranked[ranked.length - 1].difficulty : null;

  // Só mostra a resposta correta de quem a viu na rodada (tentativas ligadas à rodada
  // exigem pergunta entregue ao utilizador).
  const toReview = details
    .filter((d) => !d.is_correct)
    .map((d) => ({ questionId: d.question_id, statement: d.statement, correctLabel: d.correct_label }));

  await repository.markSummaryShown(db, roundId);

  return {
    roundId: round.id,
    categoryId: round.category_id,
    categoryName: round.category_name,
    target: round.target_questions,
    answered,
    correct,
    wrong: answered - correct,
    accuracyPercent: answered ? Math.round((correct / answered) * 100) : 0,
    xpEarned: details.reduce((sum, d) => sum + d.xp_awarded, 0),
    pointsEarned: details.reduce((sum, d) => sum + d.points_awarded, 0),
    averageResponseSeconds: answered
      ? Math.round(details.reduce((sum, d) => sum + d.response_time_ms, 0) / answered / 100) / 10
      : 0,
    byDifficulty,
    bestDifficulty: best,
    reviewDifficulty: weakest,
    toReview,
    alreadyShown: Boolean(round.summary_shown_at),
  };
}

module.exports = { listCategories, getNextQuestion, submitAnswer, buildLearningFeedback, getRoundSummary, ROUND_SIZE, CHECKPOINT_EVERY };
