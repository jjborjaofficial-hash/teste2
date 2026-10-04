/**
 * Quiz: rodada de 10 perguntas, checkpoint técnico aos 5 e resumo. Testes unitários
 * (sem banco nem Redis); o fluxo com banco real está em quiz-rounds.integration.test.js.
 */
const mockClient = { query: jest.fn().mockResolvedValue({}), release: jest.fn() };
jest.mock('../src/config/database', () => ({
  query: jest.fn(),
  getClient: jest.fn(async () => mockClient),
}));
jest.mock('../src/modules/quiz/repositories/quizRepository', () => ({
  categoryExists: jest.fn().mockResolvedValue(true),
  abandonStaleRounds: jest.fn(),
  findInProgressRound: jest.fn(),
  createRound: jest.fn(),
  getRoundProgress: jest.fn(),
  listAnsweredQuestionIds: jest.fn().mockResolvedValue([]),
  countRoundQuestions: jest.fn().mockResolvedValue(10),
  lockRound: jest.fn(),
  listRoundCandidates: jest.fn().mockResolvedValue([]),
  insertRoundQuestions: jest.fn(),
  getRandomQuestion: jest.fn(),
  getQuestionWithCorrectAlternative: jest.fn(),
  recordAttempt: jest.fn().mockResolvedValue({ id: 'a1' }),
  markRoundCheckpoint: jest.fn(),
  completeRound: jest.fn(),
  touchRound: jest.fn(),
  getRoundOfUser: jest.fn(),
  listRoundAttemptDetails: jest.fn(),
  markSummaryShown: jest.fn(),
}));
jest.mock('../src/modules/quiz/services/quizTimerService', () => ({
  consumeElapsedMs: jest.fn().mockResolvedValue(5000),
  markQuestionIssued: jest.fn(),
}));
jest.mock('../src/modules/gamification/services/xpService', () => ({
  addXpAndPoints: jest.fn().mockResolvedValue({
    xpTotal: 110, pointsBalance: 20, level: 2, leveledUp: false, pointsCredited: 10, pointsCappedByDailyLimit: false,
  }),
}));
jest.mock('../src/modules/gamification/services/streakService', () => ({
  registerDailyActivity: jest.fn().mockResolvedValue({ streak: { currentStreakDays: 1 }, alreadyRegisteredToday: false }),
}));
jest.mock('../src/modules/missions/services/missionsService', () => ({
  incrementProgressForCategory: jest.fn().mockResolvedValue([]),
}));
jest.mock('../src/modules/referrals/services/referralsService', () => ({ checkAndRewardQualification: jest.fn() }));
jest.mock('../src/modules/trustscore/services/trustScoreService', () => ({
  adjust: jest.fn(),
  REASONS: { SUSPICIOUSLY_FAST_ANSWER: 'x' },
}));
jest.mock('../src/common/repositories/systemConfigRepository', () => ({
  getConfigValue: jest.fn().mockResolvedValue(null),
}));

const repository = require('../src/modules/quiz/repositories/quizRepository');
const timer = require('../src/modules/quiz/services/quizTimerService');
const quizService = require('../src/modules/quiz/services/quizService');

const CAT = '11111111-1111-4111-8111-111111111111';
const ROUND = '22222222-2222-4222-8222-222222222222';
const round = { id: ROUND, target_questions: 10, checkpoint_at: null };

function question() {
  return {
    id: 'q1', category_id: CAT, time_limit_seconds: 30, xp_reward: 10, difficulty: 'easy', explanation: 'x',
    alternatives: [
      { id: 'a', label: 'A', is_correct: false },
      { id: 'b', label: 'B', is_correct: true },
    ],
  };
}

describe('getNextQuestion: rodada no servidor', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    repository.categoryExists.mockResolvedValue(true);
    repository.listAnsweredQuestionIds.mockResolvedValue([]);
    repository.getRandomQuestion.mockResolvedValue({ id: 'q9', category_id: CAT, time_limit_seconds: 30, alternatives: [] });
  });

  it('abre uma rodada nova de 10 perguntas quando não há nenhuma em andamento', async () => {
    repository.findInProgressRound.mockResolvedValue(null);
    repository.createRound.mockResolvedValue({ id: ROUND, target_questions: 10 });
    repository.getRoundProgress.mockResolvedValue({ answered: 0, correct: 0 });
    const q = await quizService.getNextQuestion(CAT, 'u1');
    expect(repository.createRound).toHaveBeenCalledWith(expect.anything(), { userId: 'u1', categoryId: CAT, targetQuestions: 10 });
    expect(q.round).toEqual({ id: ROUND, target: 10, answered: 0, correct: 0 });
  });

  it('CASO 10: retoma a rodada em andamento (recarregar a página não perde o progresso)', async () => {
    repository.findInProgressRound.mockResolvedValue({ id: ROUND, target_questions: 10 });
    repository.getRoundProgress.mockResolvedValue({ answered: 6, correct: 4 });
    const q = await quizService.getNextQuestion(CAT, 'u1');
    expect(repository.createRound).not.toHaveBeenCalled();
    expect(q.round).toMatchObject({ answered: 6, correct: 4, target: 10 });
  });

  it('não repete perguntas já respondidas na rodada', async () => {
    repository.findInProgressRound.mockResolvedValue({ id: ROUND, target_questions: 10 });
    repository.getRoundProgress.mockResolvedValue({ answered: 2, correct: 1 });
    repository.listAnsweredQuestionIds.mockResolvedValue(['q1', 'q2']);
    await quizService.getNextQuestion(CAT, 'u1');
    expect(repository.getRandomQuestion).toHaveBeenCalledWith(CAT, ['q1', 'q2']);
  });

  it('categoria inválida ou inexistente devolve 404 (não erro 500 do banco)', async () => {
    await expect(quizService.getNextQuestion('nao-e-uuid', 'u1')).rejects.toMatchObject({ statusCode: 404 });
    repository.categoryExists.mockResolvedValue(false);
    await expect(quizService.getNextQuestion(CAT, 'u1')).rejects.toMatchObject({ statusCode: 404 });
  });
});

describe('ensureRoundQuestions (via getNextQuestion): perguntas escolhidas ao iniciar', () => {
  const candidates = [];
  for (const d of ['easy', 'medium', 'hard']) for (let i = 0; i < 20; i += 1) candidates.push({ id: `${d}-${i}`, difficulty: d, lastSeenAt: null });

  beforeEach(() => {
    jest.clearAllMocks();
    repository.categoryExists.mockResolvedValue(true);
    repository.findInProgressRound.mockResolvedValue({ id: ROUND, target_questions: 10 });
    repository.getRoundProgress.mockResolvedValue({ answered: 0, correct: 0 });
    repository.listAnsweredQuestionIds.mockResolvedValue([]);
    repository.getRandomQuestion.mockResolvedValue({ id: 'q9', category_id: CAT, time_limit_seconds: 30, alternatives: [] });
    repository.listRoundCandidates.mockResolvedValue(candidates);
  });

  it('rodada nova sem perguntas guardadas: escolhe 10 e grava com a rodada bloqueada', async () => {
    repository.countRoundQuestions.mockResolvedValue(0);
    await quizService.getNextQuestion(CAT, 'u1');
    expect(repository.lockRound).toHaveBeenCalledWith(expect.anything(), ROUND);
    const [, roundId, ids] = repository.insertRoundQuestions.mock.calls[0];
    expect(roundId).toBe(ROUND);
    expect(ids).toHaveLength(10);
    expect(new Set(ids).size).toBe(10);
  });

  it('rodada que já tem perguntas guardadas: não escolhe outra vez (recarregar não troca)', async () => {
    repository.countRoundQuestions.mockResolvedValue(10);
    await quizService.getNextQuestion(CAT, 'u1');
    expect(repository.insertRoundQuestions).not.toHaveBeenCalled();
    expect(repository.lockRound).not.toHaveBeenCalled();
  });

  it('outra chamada escolheu entretanto: depois do bloqueio não escolhe de novo', async () => {
    repository.countRoundQuestions.mockResolvedValueOnce(0).mockResolvedValueOnce(10);
    await quizService.getNextQuestion(CAT, 'u1');
    expect(repository.insertRoundQuestions).not.toHaveBeenCalled();
  });

  it('rodada antiga já começada (com respostas): não mexe nas perguntas', async () => {
    repository.getRoundProgress.mockResolvedValue({ answered: 4, correct: 2 });
    repository.countRoundQuestions.mockResolvedValue(0);
    await quizService.getNextQuestion(CAT, 'u1');
    expect(repository.insertRoundQuestions).not.toHaveBeenCalled();
  });
});

describe('submitAnswer: progresso da rodada', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    timer.consumeElapsedMs.mockResolvedValue(5000);
    repository.getQuestionWithCorrectAlternative.mockResolvedValue(question());
    repository.findInProgressRound.mockResolvedValue(round);
  });

  it('CASO 3: na 5.ª pergunta é checkpoint técnico, sem concluir a rodada', async () => {
    repository.getRoundProgress.mockResolvedValue({ answered: 5, correct: 3 });
    const res = await quizService.submitAnswer({ userId: 'u1', questionId: 'q1', alternativeId: 'b' });
    expect(res.round).toMatchObject({ answered: 5, target: 10, checkpoint: true, completed: false });
    expect(repository.markRoundCheckpoint).toHaveBeenCalledWith(expect.anything(), ROUND);
    expect(repository.completeRound).not.toHaveBeenCalled();
  });

  it('antes dos 5 só atualiza a atividade da rodada', async () => {
    repository.getRoundProgress.mockResolvedValue({ answered: 3, correct: 2 });
    const res = await quizService.submitAnswer({ userId: 'u1', questionId: 'q1', alternativeId: 'b' });
    expect(res.round).toMatchObject({ answered: 3, checkpoint: false, completed: false });
    expect(repository.markRoundCheckpoint).not.toHaveBeenCalled();
    expect(repository.touchRound).toHaveBeenCalled();
  });

  it('CASO 4: entre 6 e 9 não repete o checkpoint nem conclui', async () => {
    repository.getRoundProgress.mockResolvedValue({ answered: 7, correct: 5 });
    const res = await quizService.submitAnswer({ userId: 'u1', questionId: 'q1', alternativeId: 'b' });
    expect(res.round).toMatchObject({ answered: 7, checkpoint: false, completed: false });
  });

  it('na 10.ª pergunta conclui a rodada', async () => {
    repository.getRoundProgress.mockResolvedValue({ answered: 10, correct: 8 });
    const res = await quizService.submitAnswer({ userId: 'u1', questionId: 'q1', alternativeId: 'b' });
    expect(res.round).toMatchObject({ answered: 10, completed: true, checkpoint: false });
    expect(repository.completeRound).toHaveBeenCalledWith(expect.anything(), ROUND);
  });

  it('a tentativa é ligada à rodada e a rodada é bloqueada (FOR UPDATE)', async () => {
    repository.getRoundProgress.mockResolvedValue({ answered: 1, correct: 1 });
    await quizService.submitAnswer({ userId: 'u1', questionId: 'q1', alternativeId: 'b' });
    expect(repository.findInProgressRound).toHaveBeenCalledWith(expect.anything(), { userId: 'u1', categoryId: CAT, forUpdate: true });
    expect(repository.recordAttempt).toHaveBeenCalledWith(expect.anything(), expect.objectContaining({ roundId: ROUND }));
  });

  it('pergunta nunca entregue: a tentativa fica fora da rodada', async () => {
    timer.consumeElapsedMs.mockResolvedValue(null);
    const res = await quizService.submitAnswer({ userId: 'u1', questionId: 'q1', alternativeId: 'b' });
    expect(repository.findInProgressRound).not.toHaveBeenCalled();
    expect(repository.recordAttempt).toHaveBeenCalledWith(expect.anything(), expect.objectContaining({ roundId: null }));
    expect(res.round).toBeNull();
  });
});

describe('getRoundSummary', () => {
  beforeEach(() => jest.clearAllMocks());

  function attempts(flags) {
    return flags.map((ok, i) => ({
      question_id: `q${i}`, is_correct: ok, response_time_ms: 4000, xp_awarded: ok ? 10 : 0, points_awarded: ok ? 10 : 0,
      statement: `Pergunta ${i}`, difficulty: i < 5 ? 'easy' : 'medium', correct_label: `Certa ${i}`,
    }));
  }

  it('CASO 4/6: 8 acertos em 10 dá 80%, XP somado e lista do que rever', async () => {
    repository.getRoundOfUser.mockResolvedValue({ id: ROUND, category_id: CAT, category_name: 'Finanças', target_questions: 10, status: 'completed', summary_shown_at: null });
    repository.listRoundAttemptDetails.mockResolvedValue(attempts([true, true, true, true, false, true, true, true, true, false]));
    const s = await quizService.getRoundSummary({ userId: 'u1', roundId: ROUND });
    expect(s).toMatchObject({ answered: 10, correct: 8, wrong: 2, accuracyPercent: 80, xpEarned: 80, pointsEarned: 80, categoryName: 'Finanças' });
    expect(s.toReview.map((r) => r.questionId)).toEqual(['q4', 'q9']);
    expect(s.bestDifficulty).toBe('easy');
    expect(s.reviewDifficulty).toBe('medium');
    expect(repository.markSummaryShown).toHaveBeenCalledWith(expect.anything(), ROUND);
  });

  it('rodada ainda em andamento não tem resumo', async () => {
    repository.getRoundOfUser.mockResolvedValue({ id: ROUND, status: 'in_progress' });
    await expect(quizService.getRoundSummary({ userId: 'u1', roundId: ROUND })).rejects.toThrow(/ainda não foi concluída/);
  });

  it('rodada de outro utilizador ou inexistente devolve 404', async () => {
    repository.getRoundOfUser.mockResolvedValue(null);
    await expect(quizService.getRoundSummary({ userId: 'u1', roundId: ROUND })).rejects.toMatchObject({ statusCode: 404 });
    await expect(quizService.getRoundSummary({ userId: 'u1', roundId: 'xx' })).rejects.toMatchObject({ statusCode: 404 });
  });
});
