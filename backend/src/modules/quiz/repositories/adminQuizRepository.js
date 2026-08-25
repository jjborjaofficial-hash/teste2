const db = require('../../../config/database');

/**
 * Repository administrativo do módulo Quiz (Gestão de Categorias e Perguntas).
 * Antes deste arquivo, categories/questions/question_alternatives só tinham
 * dado de seed de desenvolvimento — não havia NENHUMA rota para criar conteúdo
 * novo, o que travava a plataforma inteira em produção.
 */

// --- Categorias ---

async function listAllCategories() {
  const { rows } = await db.query(
    `SELECT c.*,
            (SELECT COUNT(*)::int FROM questions q WHERE q.category_id = c.id AND q.is_active) AS active_questions_count
     FROM categories c
     ORDER BY c.name`
  );
  return rows;
}

async function findCategoryBySlug(slug) {
  const { rows } = await db.query(`SELECT id FROM categories WHERE slug = $1`, [slug]);
  return rows[0] || null;
}

async function createCategory({ name, slug, description, iconKey }) {
  const { rows } = await db.query(
    `INSERT INTO categories (name, slug, description, icon_key)
     VALUES ($1, $2, $3, $4)
     RETURNING *`,
    [name, slug, description || null, iconKey || null]
  );
  return rows[0];
}

async function updateCategory(id, { name, description, iconKey, isActive }) {
  const { rows } = await db.query(
    `UPDATE categories
     SET name = COALESCE($2, name),
         description = COALESCE($3, description),
         icon_key = COALESCE($4, icon_key),
         is_active = COALESCE($5, is_active)
     WHERE id = $1
     RETURNING *`,
    [id, name || null, description || null, iconKey || null, isActive === undefined ? null : isActive]
  );
  return rows[0];
}

// --- Perguntas + Alternativas ---

async function listQuestionsByCategory(categoryId, { limit = 50, offset = 0 } = {}) {
  const { rows } = await db.query(
    `SELECT * FROM questions WHERE category_id = $1 ORDER BY created_at DESC LIMIT $2 OFFSET $3`,
    [categoryId, limit, offset]
  );
  return rows;
}

async function findQuestionById(id) {
  const { rows } = await db.query(`SELECT * FROM questions WHERE id = $1`, [id]);
  return rows[0] || null;
}

async function getAlternatives(questionId, executor = db) {
  const { rows } = await executor.query(
    `SELECT * FROM question_alternatives WHERE question_id = $1 ORDER BY display_order`,
    [questionId]
  );
  return rows;
}

async function createQuestionWithAlternatives({ categoryId, difficulty, statement, timeLimitSeconds, xpReward, alternatives }) {
  const client = await db.getClient();
  try {
    await client.query('BEGIN');

    const { rows } = await client.query(
      `INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
      [categoryId, difficulty, statement, timeLimitSeconds, xpReward]
    );
    const question = rows[0];

    for (let i = 0; i < alternatives.length; i += 1) {
      const alt = alternatives[i];
      // eslint-disable-next-line no-await-in-loop
      await client.query(
        `INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
         VALUES ($1, $2, $3, $4)`,
        [question.id, alt.label, alt.isCorrect, i]
      );
    }

    await client.query('COMMIT');
    return question;
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}

async function updateQuestion(id, { statement, difficulty, timeLimitSeconds, xpReward, isActive }) {
  const { rows } = await db.query(
    `UPDATE questions
     SET statement = COALESCE($2, statement),
         difficulty = COALESCE($3, difficulty),
         time_limit_seconds = COALESCE($4, time_limit_seconds),
         xp_reward = COALESCE($5, xp_reward),
         is_active = COALESCE($6, is_active)
     WHERE id = $1
     RETURNING *`,
    [id, statement || null, difficulty || null, timeLimitSeconds || null, xpReward === undefined ? null : xpReward, isActive === undefined ? null : isActive]
  );
  return rows[0];
}

/**
 * Substitui todas as alternativas de uma pergunta (nunca edição parcial —
 * mais simples e sem risco de deixar duas alternativas corretas por engano).
 */
async function replaceAlternatives(questionId, alternatives) {
  const client = await db.getClient();
  try {
    await client.query('BEGIN');
    await client.query(`DELETE FROM question_alternatives WHERE question_id = $1`, [questionId]);
    for (let i = 0; i < alternatives.length; i += 1) {
      const alt = alternatives[i];
      // eslint-disable-next-line no-await-in-loop
      await client.query(
        `INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
         VALUES ($1, $2, $3, $4)`,
        [questionId, alt.label, alt.isCorrect, i]
      );
    }
    await client.query('COMMIT');
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}

module.exports = {
  listAllCategories,
  findCategoryBySlug,
  createCategory,
  updateCategory,
  listQuestionsByCategory,
  findQuestionById,
  getAlternatives,
  createQuestionWithAlternatives,
  updateQuestion,
  replaceAlternatives,
};
