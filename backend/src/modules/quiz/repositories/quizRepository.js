const db = require('../../../config/database');
const { dateInPlatformTz } = require('../../../common/time/platformTimezone');

async function listActiveCategories(executor = db) {
  const { rows } = await executor.query(
    `SELECT id, name, slug, description, icon_key
     FROM categories WHERE is_active = TRUE ORDER BY name`
  );
  return rows;
}

/**
 * Retorna uma pergunta aleatória da categoria, SEM revelar qual alternativa é correta
 * (a validação da resposta acontece inteiramente no backend — Manual Parte 5).
 */
async function getRandomQuestion(categoryId, executor = db) {
  const { rows } = await executor.query(
    `SELECT id, category_id, difficulty, statement, time_limit_seconds
     FROM questions
     WHERE category_id = $1 AND is_active = TRUE
     ORDER BY random()
     LIMIT 1`,
    [categoryId]
  );
  if (!rows[0]) return null;

  const question = rows[0];
  const altResult = await executor.query(
    `SELECT id, label
     FROM question_alternatives
     WHERE question_id = $1
     ORDER BY random()`, // opções em ordem aleatória a cada apresentação (BE-003); a validação usa o id, não a posição
    [question.id]
  );

  return { ...question, alternatives: altResult.rows };
}

/**
 * Busca uma pergunta específica pelo id, com as mesmas colunas e formato de
 * getRandomQuestion (sem revelar a alternativa correta). Usada para repetir
 * ao usuário a pergunta que o servidor já tinha emitido (ver F5 em
 * quizTimerService.getActiveIssuedQuestion), em vez de sortear uma nova.
 * Retorna `null` se a pergunta não existir mais ou tiver sido desativada —
 * quem chama deve então seguir o caminho normal de sortear uma nova.
 */
async function getQuestionById(questionId, categoryId, executor = db) {
  const { rows } = await executor.query(
    `SELECT id, category_id, difficulty, statement, time_limit_seconds
     FROM questions
     WHERE id = $1 AND category_id = $2 AND is_active = TRUE`,
    [questionId, categoryId]
  );
  if (!rows[0]) return null;

  const question = rows[0];
  const altResult = await executor.query(
    `SELECT id, label
     FROM question_alternatives
     WHERE question_id = $1
     ORDER BY random()`, // opções em ordem aleatória a cada apresentação (BE-003); a validação usa o id, não a posição
    [question.id]
  );

  return { ...question, alternatives: altResult.rows };
}

async function getQuestionWithCorrectAlternative(questionId, executor = db) {
  const { rows } = await executor.query(
    `SELECT id, category_id, time_limit_seconds, xp_reward, difficulty, explanation FROM questions WHERE id = $1 AND is_active = TRUE`,
    [questionId]
  );
  if (!rows[0]) return null;

  const altResult = await executor.query(
    `SELECT id, label, is_correct FROM question_alternatives WHERE question_id = $1`,
    [questionId]
  );

  return { ...rows[0], alternatives: altResult.rows };
}

async function recordAttempt(
  executor,
  { userId, questionId, alternativeId, isCorrect, responseTimeMs, xpAwarded, pointsAwarded = 0, roundId = null }
) {
  const { rows } = await executor.query(
    `INSERT INTO quiz_attempts
        (user_id, question_id, alternative_id, is_correct, response_time_ms, xp_awarded, points_awarded, round_id)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
     RETURNING id, created_at`,
    [userId, questionId, alternativeId, isCorrect, responseTimeMs, xpAwarded, pointsAwarded, roundId]
  );
  return rows[0];
}

async function countAttemptsToday(userId, executor = db) {
  const { rows } = await executor.query(
    `SELECT COUNT(*)::int AS count
     FROM quiz_attempts
     WHERE user_id = $1 AND ${dateInPlatformTz('created_at')} = ${dateInPlatformTz('now()')}`,
    [userId]
  );
  return rows[0].count;
}

// ---------------------------------------------------------------------------
// Rodadas (quiz v2) — ver migration 107 e docs/quiz-v2-rodadas-e-feedback.md
// ---------------------------------------------------------------------------

async function getActiveCategory(categoryId, executor = db) {
  const { rows } = await executor.query(
    `SELECT id, name, slug FROM categories WHERE id = $1 AND is_active = TRUE`,
    [categoryId]
  );
  return rows[0] || null;
}

/**
 * Candidatas para uma rodada, já ordenadas por preferência: perguntas que o utilizador
 * NUNCA respondeu primeiro; depois as respondidas há mais tempo; empates aleatórios.
 * `limit` é o tamanho do pool (a escolha final com mistura de dificuldades é feita em
 * roundSelection.pickRoundQuestions).
 */
async function listRoundCandidates(userId, categoryId, limit, excludeIds = [], executor = db) {
  const { rows } = await executor.query(
    `SELECT q.id, q.difficulty
     FROM questions q
     LEFT JOIN (
       SELECT question_id, MAX(created_at) AS last_seen
       FROM quiz_attempts
       WHERE user_id = $1
       GROUP BY question_id
     ) seen ON seen.question_id = q.id
     WHERE q.category_id = $2
       AND q.is_active = TRUE
       AND NOT (q.id = ANY($4::uuid[]))
     ORDER BY (seen.last_seen IS NULL) DESC, seen.last_seen ASC NULLS FIRST, random()
     LIMIT $3`,
    [userId, categoryId, limit, excludeIds]
  );
  return rows;
}

async function getActiveRound(userId, executor = db, { forUpdate = false } = {}) {
  const { rows } = await executor.query(
    `SELECT * FROM quiz_rounds WHERE user_id = $1 AND status = 'in_progress'${forUpdate ? ' FOR UPDATE' : ''}`,
    [userId]
  );
  return rows[0] || null;
}

async function getRoundForUser(roundId, userId, executor = db, { forUpdate = false } = {}) {
  const { rows } = await executor.query(
    `SELECT * FROM quiz_rounds WHERE id = $1 AND user_id = $2${forUpdate ? ' FOR UPDATE' : ''}`,
    [roundId, userId]
  );
  return rows[0] || null;
}

async function abandonActiveRound(userId, executor = db) {
  await executor.query(
    `UPDATE quiz_rounds SET status = 'abandoned' WHERE user_id = $1 AND status = 'in_progress'`,
    [userId]
  );
}

async function createRound(executor, { userId, categoryId, questionIds }) {
  const { rows } = await executor.query(
    `INSERT INTO quiz_rounds (user_id, category_id, total_questions, question_ids)
     VALUES ($1, $2, $3, $4::uuid[])
     RETURNING *`,
    [userId, categoryId, questionIds.length, questionIds]
  );
  return rows[0];
}

/** Troca a pergunta de uma posição (1-based) quando a original foi desativada. */
async function replaceRoundQuestion(roundId, position, newQuestionId, executor = db) {
  await executor.query(`UPDATE quiz_rounds SET question_ids[$2] = $3 WHERE id = $1`, [
    roundId,
    position,
    newQuestionId,
  ]);
}

/** Avança a rodada depois de uma resposta; fecha na última (devolve a linha atualizada). */
async function advanceRound(executor, { roundId, isCorrect, xpAwarded, pointsAwarded }) {
  const { rows } = await executor.query(
    `UPDATE quiz_rounds
     SET answered_count = answered_count + 1,
         correct_count  = correct_count + $2,
         xp_total       = xp_total + $3,
         points_total   = points_total + $4,
         status         = CASE WHEN answered_count + 1 >= total_questions THEN 'completed' ELSE status END,
         completed_at   = CASE WHEN answered_count + 1 >= total_questions THEN now() ELSE completed_at END
     WHERE id = $1
     RETURNING *`,
    [roundId, isCorrect ? 1 : 0, xpAwarded, pointsAwarded]
  );
  return rows[0];
}

/** Respostas da rodada, com a pergunta, para montar o resumo (só desta rodada). */
async function listRoundAttempts(roundId, executor = db) {
  const { rows } = await executor.query(
    `SELECT a.question_id, a.is_correct, a.xp_awarded, q.difficulty, q.statement
     FROM quiz_attempts a
     JOIN questions q ON q.id = a.question_id
     WHERE a.round_id = $1
     ORDER BY a.created_at`,
    [roundId]
  );
  return rows;
}

module.exports = {
  listActiveCategories,
  getRandomQuestion,
  getQuestionById,
  getQuestionWithCorrectAlternative,
  recordAttempt,
  countAttemptsToday,
  getActiveCategory,
  listRoundCandidates,
  getActiveRound,
  getRoundForUser,
  abandonActiveRound,
  createRound,
  replaceRoundQuestion,
  advanceRound,
  listRoundAttempts,
};
