/** Testes do portão de qualidade de perguntas novas (BE-003, P13). Sem banco: repositório simulado. */
jest.mock('../src/modules/quiz/repositories/adminQuizRepository');

const repository = require('../src/modules/quiz/repositories/adminQuizRepository');
const service = require('../src/modules/quiz/services/adminQuizService');
const { evaluateNewQuestion, formatBlockers } = require('../src/modules/quiz/validation/newQuestionGate');

const alt = (label, isCorrect = false) => ({ label, isCorrect });
const BOA = [alt('Guardar dinheiro', true), alt('Gastar tudo hoje'), alt('Pedir emprestado'), alt('Ignorar o orçamento')];
const CODES = (arr) => arr.map((x) => x.code);

describe('evaluateNewQuestion (puro)', () => {
  test('pergunta equilibrada e única passa sem avisos', () => {
    const r = evaluateNewQuestion({ statement: 'Qual hábito ajuda a poupar?', alternatives: BOA, existing: [] });
    expect(r).toEqual({ ok: true, blockers: [], warnings: [] });
  });

  test('bloqueia correta bem mais longa, explicação embutida e "todas as anteriores"', () => {
    const longa = [alt('Guardar parte do dinheiro todos os meses (para criar reserva)', true), alt('Gastar'), alt('Pedir'), alt('Todas as anteriores')];
    const r = evaluateNewQuestion({ statement: 'Qual hábito ajuda a poupar?', alternatives: longa });
    expect(r.ok).toBe(false);
    expect(CODES(r.blockers)).toEqual(expect.arrayContaining(['correta_mais_longa_destacada', 'explicacao_embutida_na_correta', 'todas_ou_nenhuma_das_anteriores']));
  });

  test('bloqueia pergunta duplicada e diz qual', () => {
    const r = evaluateNewQuestion({ statement: 'o que e a inflacao', alternatives: BOA, existing: [{ id: 'abc', statement: 'O que é inflação?' }] });
    expect(r.ok).toBe(false);
    expect(CODES(r.blockers)).toContain('pergunta_duplicada');
    expect(r.blockers[0].message).toContain('abc');
  });

  test('viés leve vira aviso e não bloqueia', () => {
    const alts = [alt('Nunca gastar mais', false), alt('Sempre pedir emprestado'), alt('Apenas poupar'), alt('Guardar parte do que ganha', true)];
    const r = evaluateNewQuestion({ statement: 'Qual hábito ajuda a poupar?', alternatives: alts });
    expect(CODES(r.warnings)).toContain('pista_absoluta_so_nas_erradas');
    expect(CODES(r.blockers)).not.toContain('pista_absoluta_so_nas_erradas');
  });

  test('só enunciado (sem alternativas): confere apenas duplicada', () => {
    expect(evaluateNewQuestion({ statement: 'Pergunta nova única sobre orçamento', existing: [{ id: '1', statement: 'Outra coisa' }] }).ok).toBe(true);
  });

  test('formatBlockers junta os motivos numa frase', () => {
    expect(formatBlockers([{ code: 'a', message: 'um' }, { code: 'b', message: 'dois' }])).toBe('Pergunta não aprovada pelo validador: um; dois.');
  });
});

describe('adminQuizService com o portão', () => {
  beforeEach(() => {
    jest.resetAllMocks();
    repository.listAllStatements.mockResolvedValue([{ id: 'q-old', statement: 'O que é inflação?' }]);
    repository.createQuestionWithAlternatives.mockResolvedValue({ id: 'q-new', category_id: 'c', difficulty: 'easy', statement: 'x', time_limit_seconds: 15, xp_reward: 10, is_active: true });
    repository.getAlternatives.mockResolvedValue([]);
    repository.findQuestionById.mockResolvedValue({ id: 'q-old', statement: 'O que é inflação?' });
    repository.updateQuestion.mockResolvedValue({ id: 'q-old', category_id: 'c', difficulty: 'easy', statement: 'x', time_limit_seconds: 15, xp_reward: 10, is_active: true });
    repository.replaceAlternatives.mockResolvedValue();
  });

  const base = { categoryId: 'c', difficulty: 'easy', statement: 'Qual hábito ajuda a poupar?', timeLimitSeconds: 15, xpReward: 10, alternatives: BOA };

  test('createQuestion grava uma pergunta boa e devolve qualityWarnings', async () => {
    const out = await service.createQuestion(base);
    expect(repository.createQuestionWithAlternatives).toHaveBeenCalledTimes(1);
    expect(out.qualityWarnings).toEqual([]);
  });

  test('createQuestion NÃO grava pergunta reprovada: erro 400 com os motivos', async () => {
    const ruim = { ...base, alternatives: [alt('Guardar parte do dinheiro todos os meses para criar reserva', true), alt('Gastar'), alt('Pedir'), alt('Ignorar')] };
    await expect(service.createQuestion(ruim)).rejects.toMatchObject({
      statusCode: 400,
      code: 'VALIDATION_ERROR',
      message: expect.stringContaining('Pergunta não aprovada pelo validador'),
    });
    expect(repository.createQuestionWithAlternatives).not.toHaveBeenCalled();
  });

  test('createQuestion NÃO grava enunciado duplicado', async () => {
    await expect(service.createQuestion({ ...base, statement: 'O que é a inflação?' })).rejects.toMatchObject({ statusCode: 400 });
    expect(repository.createQuestionWithAlternatives).not.toHaveBeenCalled();
  });

  test('updateQuestion só com isActive não passa pelo portão (perguntas antigas continuam editáveis)', async () => {
    await service.updateQuestion('q-old', { isActive: false });
    expect(repository.listAllStatements).not.toHaveBeenCalled();
    expect(repository.updateQuestion).toHaveBeenCalledTimes(1);
  });

  test('updateQuestion com alternativas reprovadas não grava nada (nem o enunciado)', async () => {
    const ruim = [alt('Guardar parte do dinheiro todos os meses para criar reserva', true), alt('Gastar'), alt('Pedir'), alt('Ignorar')];
    await expect(service.updateQuestion('q-old', { statement: 'Novo enunciado diferente aqui', alternatives: ruim })).rejects.toMatchObject({ statusCode: 400 });
    expect(repository.updateQuestion).not.toHaveBeenCalled();
    expect(repository.replaceAlternatives).not.toHaveBeenCalled();
  });

  test('updateQuestion ignora a própria pergunta ao procurar duplicada', async () => {
    await service.updateQuestion('q-old', { statement: 'O que é inflação?' });
    expect(repository.updateQuestion).toHaveBeenCalledTimes(1);
  });

  test('updateQuestion com alternativas boas grava e substitui', async () => {
    await service.updateQuestion('q-old', { alternatives: BOA });
    expect(repository.replaceAlternatives).toHaveBeenCalledWith('q-old', BOA);
  });
});
