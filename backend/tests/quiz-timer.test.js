/**
 * Cronómetro antifraude do quiz: recarregar a mesma pergunta não reinicia o relógio.
 * Usa um Redis falso em memória (sem Redis real).
 */
const mockStore = new Map();
jest.mock('../src/config/redis', () => ({
  set: jest.fn(async (key, value, ...args) => {
    if (args.includes('NX') && mockStore.has(key)) return null;
    mockStore.set(key, value);
    return 'OK';
  }),
  get: jest.fn(async (key) => (mockStore.has(key) ? mockStore.get(key) : null)),
  del: jest.fn(async (key) => mockStore.delete(key)),
}));

const redis = require('../src/config/redis');
const timer = require('../src/modules/quiz/services/quizTimerService');

beforeEach(() => { mockStore.clear(); jest.clearAllMocks(); jest.useRealTimers(); });

describe('quizTimerService.markQuestionIssued', () => {
  it('comportamento normal (sem opção) continua a sobrescrever, com TTL curto', async () => {
    await timer.markQuestionIssued('u1', 'q1', 30);
    expect(redis.set).toHaveBeenCalledWith(expect.any(String), expect.any(String), 'EX', 40);
  });

  it('keepExisting: a 1.ª emissão grava e as seguintes devolvem o instante ORIGINAL', async () => {
    jest.useFakeTimers().setSystemTime(new Date('2026-10-04T10:00:00Z'));
    const first = await timer.markQuestionIssued('u1', 'q1', 30, { keepExisting: true });
    jest.setSystemTime(new Date('2026-10-04T10:05:00Z')); // 5 minutos depois (recarregou)
    const second = await timer.markQuestionIssued('u1', 'q1', 30, { keepExisting: true });
    expect(second).toBe(first);
    expect(first).toBe(new Date('2026-10-04T10:00:00Z').getTime());
  });

  it('recarregar depois do tempo NÃO dá tempo novo: a resposta conta como esgotada', async () => {
    jest.useFakeTimers().setSystemTime(new Date('2026-10-04T10:00:00Z'));
    await timer.markQuestionIssued('u1', 'q1', 30, { keepExisting: true });
    jest.setSystemTime(new Date('2026-10-04T10:02:00Z'));
    await timer.markQuestionIssued('u1', 'q1', 30, { keepExisting: true }); // recarregou
    const elapsed = await timer.consumeElapsedMs('u1', 'q1');
    expect(elapsed).toBe(120000); // 2 minutos desde a 1.ª entrega, muito acima dos 30 s
  });

  it('keepExisting usa um TTL longo (janela da rodada) e perguntas diferentes têm relógios diferentes', async () => {
    await timer.markQuestionIssued('u1', 'q1', 30, { keepExisting: true });
    expect(redis.set).toHaveBeenCalledWith(expect.any(String), expect.any(String), 'EX', 30 + 12 * 3600, 'NX');
    await timer.markQuestionIssued('u1', 'q2', 30, { keepExisting: true });
    expect(mockStore.size).toBe(2);
  });

  it('cada utilizador tem o seu relógio', async () => {
    jest.useFakeTimers().setSystemTime(new Date('2026-10-04T10:00:00Z'));
    await timer.markQuestionIssued('u1', 'q1', 30, { keepExisting: true });
    jest.setSystemTime(new Date('2026-10-04T10:01:00Z'));
    const other = await timer.markQuestionIssued('u2', 'q1', 30, { keepExisting: true });
    expect(other).toBe(new Date('2026-10-04T10:01:00Z').getTime());
  });
});
