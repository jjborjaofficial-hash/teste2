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
     ORDER BY display_order`,
    [question.id]
  );

  return { ...question, alternatives: altResult.rows };
}

async function getQuestionWithCorrectAlternative(questionId, executor = db) {
  const { rows } = await executor.query(
    `SELECT id, category_id, time_limit_seconds, xp_reward, difficulty FROM questions WHERE id = $1 AND is_active = TRUE`,
    [questionId]
  );
  if (!rows[0]) return null;

  const altResult = await executor.query(
    `SELECT id, is_correct FROM question_alternatives WHERE question_id = $1`,
    [questionId]
  );

  return { ...rows[0], alternatives: altResult.rows };
}

async function recordAttempt(executor, { userId, questionId, alternativeId, isCorrect, responseTimeMs, xpAwarded, pointsAwarded = 0 }) {
  const { rows } = await executor.query(
    `INSERT INTO quiz_attempts
        (user_id, question_id, alternative_id, is_correct, response_time_ms, xp_awarded, points_awarded)
     VALUES ($1, $2, $3, $4, $5, $6, $7)
     RETURNING id, created_at`,
    [userId, questionId, alternativeId, isCorrect, responseTimeMs, xpAwarded, pointsAwarded]
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

module.exports = {
  listActiveCategories,
  getRandomQuestion,
  getQuestionWithCorrectAlternative,
  recordAttempt,
  countAttemptsToday,
};
