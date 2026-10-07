const repository = require('../repositories/adminQuizRepository');
const { NotFoundError, ConflictError, ValidationError } = require('../../../common/errors/AppError');
const { evaluateNewQuestion, formatBlockers } = require('../validation/newQuestionGate');

/**
 * Regras de negócio da Gestão de Categorias e Perguntas (Manual Parte 5:
 * "regras de negócio nunca devem ser duplicadas entre frontend e backend —
 * o backend é sempre a autoridade final").
 */

function slugify(name) {
  return name
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '') // remove acentos
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/(^-|-$)/g, '');
}

function validateAlternatives(alternatives) {
  if (!Array.isArray(alternatives) || alternatives.length < 2) {
    throw new ValidationError('A pergunta precisa de pelo menos 2 alternativas.');
  }
  const correctCount = alternatives.filter((a) => a.isCorrect).length;
  if (correctCount !== 1) {
    throw new ValidationError('A pergunta precisa de exatamente 1 alternativa correta.');
  }
}

// --- Categorias ---

function mapCategory(c) {
  return {
    id: c.id,
    name: c.name,
    slug: c.slug,
    description: c.description,
    iconKey: c.icon_key,
    isActive: c.is_active,
    activeQuestionsCount: c.active_questions_count,
  };
}

async function listCategories() {
  const rows = await repository.listAllCategories();
  return rows.map(mapCategory);
}

async function createCategory({ name, description, iconKey }) {
  const slug = slugify(name);
  const existing = await repository.findCategoryBySlug(slug);
  if (existing) {
    throw new ConflictError('Já existe uma categoria com um nome muito parecido com este.');
  }
  const created = await repository.createCategory({ name, slug, description, iconKey });
  return mapCategory(created);
}

async function updateCategory(id, data) {
  const updated = await repository.updateCategory(id, data);
  if (!updated) throw new NotFoundError('Categoria não encontrada.');
  return mapCategory(updated);
}

// --- Perguntas ---

function mapQuestion(q, alternatives) {
  return {
    id: q.id,
    categoryId: q.category_id,
    difficulty: q.difficulty,
    statement: q.statement,
    timeLimitSeconds: q.time_limit_seconds,
    xpReward: q.xp_reward,
    isActive: q.is_active,
    alternatives: alternatives?.map((a) => ({ id: a.id, label: a.label, isCorrect: a.is_correct })),
  };
}

async function listQuestions(categoryId, pagination) {
  const rows = await repository.listQuestionsByCategory(categoryId, pagination);
  return rows.map((q) => mapQuestion(q));
}

async function getQuestion(id) {
  const question = await repository.findQuestionById(id);
  if (!question) throw new NotFoundError('Pergunta não encontrada.');
  const alternatives = await repository.getAlternatives(id);
  return mapQuestion(question, alternatives);
}

// Portão de qualidade (BE-003 P13): pergunta nova/reescrita só entra se passar no validador.
// Bloqueios viram erro 400 com os motivos em `message` (o painel mostra) e `details`; avisos
// (viés que não bloqueia) voltam em `qualityWarnings` na resposta.
async function enforceQualityGate({ statement, alternatives, ownId }) {
  const existing = await repository.listAllStatements();
  const result = evaluateNewQuestion({ statement, alternatives, existing, ownId });
  if (!result.ok) {
    throw new ValidationError(formatBlockers(result.blockers), { blockers: result.blockers, warnings: result.warnings });
  }
  return result.warnings;
}

async function createQuestion({ categoryId, difficulty, statement, timeLimitSeconds, xpReward, alternatives }) {
  validateAlternatives(alternatives);
  const qualityWarnings = await enforceQualityGate({ statement, alternatives });
  const created = await repository.createQuestionWithAlternatives({
    categoryId,
    difficulty,
    statement,
    timeLimitSeconds,
    xpReward,
    alternatives,
  });
  const savedAlternatives = await repository.getAlternatives(created.id);
  return { ...mapQuestion(created, savedAlternatives), qualityWarnings };
}

async function updateQuestion(id, { statement, difficulty, timeLimitSeconds, xpReward, isActive, alternatives }) {
  const existing = await repository.findQuestionById(id);
  if (!existing) throw new NotFoundError('Pergunta não encontrada.');

  // Valida TUDO antes de gravar qualquer coisa (antes, um erro nas alternativas deixava o
  // enunciado já alterado). O portão só corre quando o autor envia enunciado e/ou alternativas;
  // mudar só isActive, tempo ou XP não passa por ele, e perguntas antigas continuam a ser servidas.
  let qualityWarnings = [];
  if (alternatives) validateAlternatives(alternatives);
  if (alternatives || statement) {
    qualityWarnings = await enforceQualityGate({
      statement: statement || existing.statement,
      alternatives, // sem alternativas novas, só se confere o enunciado (duplicada)
      ownId: id,
    });
  }

  const updated = await repository.updateQuestion(id, { statement, difficulty, timeLimitSeconds, xpReward, isActive });

  if (alternatives) {
    await repository.replaceAlternatives(id, alternatives);
  }

  const savedAlternatives = await repository.getAlternatives(id);
  return { ...mapQuestion(updated, savedAlternatives), qualityWarnings };
}

module.exports = {
  listCategories,
  createCategory,
  updateCategory,
  listQuestions,
  getQuestion,
  createQuestion,
  updateQuestion,
};
