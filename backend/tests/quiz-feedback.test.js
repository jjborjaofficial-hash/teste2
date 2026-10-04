/**
 * Quiz: feedback pedagógico após cada resposta. Testes unitários (sem banco nem Redis).
 *
 * Regras verificadas:
 *  - acerto e erro devolvem a alternativa correta e a explicação (depois de registar);
 *  - a pergunta entregue ao cliente nunca traz is_correct nem explanation;
 *  - quem responde sem a pergunta ter sido entregue (sem registo do cronómetro) não
 *    descobre a resposta correta (anti-colheita);
 *  - pergunta sem explicação não inventa texto.
 */
const mockClient = { query: jest.fn().mockResolvedValue({}), release: jest.fn() };
jest.mock('../src/config/database', () => ({
  query: jest.fn(),
  getClient: jest.fn(async () => mockClient),
}));
jest.mock('../src/modules/quiz/repositories/quizRepository', () => ({
  getQuestionWithCorrectAlternative: jest.fn(),
  recordAttempt: jest.fn().mockResolvedValue({ id: 'a1' }),
  getRandomQuestion: jest.fn(),
  // Rodadas: estes testes não usam rodada (nenhuma em andamento).
  findInProgressRound: jest.fn().mockResolvedValue(null),
  getRoundProgress: jest.fn(),
  completeRound: jest.fn(),
  markRoundCheckpoint: jest.fn(),
  touchRound: jest.fn(),
}));
jest.mock('../src/modules/quiz/services/quizTimerService', () => ({
  consumeElapsedMs: jest.fn(),
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
jest.mock('../src/modules/referrals/services/referralsService', () => ({
  checkAndRewardQualification: jest.fn(),
}));
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

function buildQuestion(overrides = {}) {
  return {
    id: 'q1',
    category_id: 'c1',
    time_limit_seconds: 30,
    xp_reward: 10,
    difficulty: 'easy',
    explanation: 'Amortizar é reduzir a dívida aos poucos, com pagamentos.',
    alternatives: [
      { id: 'alt-a', label: 'Aumento do valor devido', is_correct: false },
      { id: 'alt-b', label: 'Redução gradual da dívida', is_correct: true },
      { id: 'alt-c', label: 'Um imposto sobre empréstimos', is_correct: false },
      { id: 'alt-d', label: 'Cancelamento automático', is_correct: false },
    ],
    ...overrides,
  };
}

describe('quizService.submitAnswer: feedback pedagógico', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    repository.getQuestionWithCorrectAlternative.mockResolvedValue(buildQuestion());
    timer.consumeElapsedMs.mockResolvedValue(5000);
  });

  it('CASO 1: acerto devolve a correta, a explicação e o XP', async () => {
    const res = await quizService.submitAnswer({ userId: 'u1', questionId: 'q1', alternativeId: 'alt-b' });
    expect(res.isCorrect).toBe(true);
    expect(res.xpAwarded).toBe(10);
    expect(res.correctAlternative).toEqual({ id: 'alt-b', label: 'Redução gradual da dívida' });
    expect(res.chosenAlternativeId).toBe('alt-b');
    expect(res.explanation).toMatch(/Amortizar/);
    expect(res.difficulty).toBe('easy');
    expect(res.categoryId).toBe('c1');
  });

  it('CASO 2: erro devolve a correta (diferente da escolhida), a explicação e 0 XP', async () => {
    const res = await quizService.submitAnswer({ userId: 'u1', questionId: 'q1', alternativeId: 'alt-a' });
    expect(res.isCorrect).toBe(false);
    expect(res.xpAwarded).toBe(0);
    expect(res.chosenAlternativeId).toBe('alt-a');
    expect(res.correctAlternative.id).toBe('alt-b');
    expect(res.explanation).toBeTruthy();
  });

  it('tempo esgotado conta como erro mas ainda ensina (a pergunta foi entregue)', async () => {
    timer.consumeElapsedMs.mockResolvedValue(31000);
    const res = await quizService.submitAnswer({ userId: 'u1', questionId: 'q1', alternativeId: 'alt-b' });
    expect(res.timeExpired).toBe(true);
    expect(res.isCorrect).toBe(false);
    expect(res.correctAlternative.id).toBe('alt-b');
  });

  it('anti-colheita: sem registo de entrega da pergunta, não revela a correta nem a explicação', async () => {
    timer.consumeElapsedMs.mockResolvedValue(null);
    const res = await quizService.submitAnswer({ userId: 'u1', questionId: 'q1', alternativeId: 'alt-a' });
    expect(res.isCorrect).toBe(false);
    expect(res.correctAlternative).toBeNull();
    expect(res.explanation).toBeNull();
  });

  it('pergunta sem explicação: explanation é null (nada é inventado)', async () => {
    repository.getQuestionWithCorrectAlternative.mockResolvedValue(buildQuestion({ explanation: null }));
    const res = await quizService.submitAnswer({ userId: 'u1', questionId: 'q1', alternativeId: 'alt-a' });
    expect(res.explanation).toBeNull();
    expect(res.correctAlternative.id).toBe('alt-b');
  });

  it('explicação só com espaços vira null', async () => {
    repository.getQuestionWithCorrectAlternative.mockResolvedValue(buildQuestion({ explanation: '   ' }));
    const res = await quizService.submitAnswer({ userId: 'u1', questionId: 'q1', alternativeId: 'alt-a' });
    expect(res.explanation).toBeNull();
  });

  it('alternativa que não pertence à pergunta continua a ser rejeitada', async () => {
    await expect(
      quizService.submitAnswer({ userId: 'u1', questionId: 'q1', alternativeId: 'outra' })
    ).rejects.toThrow(/não pertence/);
  });
});

describe('quizRepository: a pergunta enviada ao cliente não revela a resposta', () => {
  it('getRandomQuestion não seleciona is_correct nem explanation', async () => {
    jest.resetModules();
    const queries = [];
    jest.doMock('../src/config/database', () => ({
      query: jest.fn(async (sql) => {
        queries.push(sql);
        if (/FROM questions/.test(sql)) {
          return { rows: [{ id: 'q1', category_id: 'c1', difficulty: 'easy', statement: 'x', time_limit_seconds: 30 }] };
        }
        return { rows: [{ id: 'alt-a', label: 'A' }] };
      }),
    }));
    const realRepo = jest.requireActual('../src/modules/quiz/repositories/quizRepository');
    const q = await realRepo.getRandomQuestion('c1');
    const all = queries.join('\n');
    expect(all).not.toMatch(/is_correct/);
    expect(all).not.toMatch(/explanation/);
    expect(JSON.stringify(q)).not.toMatch(/is_correct|explanation|correct/i);
  });
});
