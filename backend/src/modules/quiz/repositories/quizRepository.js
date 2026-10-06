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
async function getRandomQuestion(categoryId, excludeQuestionIds = [], executor = db) {
  const pick = async (exclude) => {
    const { rows } = await executor.query(
      `SELECT id, category_id, difficulty, statement, time_limit_seconds
       FROM questions
       WHERE category_id = $1 AND is_active = TRUE
         AND NOT (id = ANY($2::uuid[]))
       ORDER BY random()
       LIMIT 1`,
      [categoryId, exclude]
    );
    return rows[0] || null;
  };

  // Dentro de uma rodada não repete perguntas já respondidas; só se o banco da
  // categoria se esgotar é que volta a permitir repetição (nunca deixa o utilizador sem pergunta).
  const question = (await pick(excludeQuestionIds)) || (excludeQuestionIds.length ? await pick([]) : null);
  if (!question) return null;

  const altResult = await executor.query(
    `SELECT id, label
     FROM question_alternatives
     WHERE question_id = $1
     ORDER BY display_order`,
    [question.id]
  );

  return { ...question, alternatives: altResult.rows };
}

async function categoryExists(categoryId, executor = db) {
  const { rows } = await executor.query(
    `SELECT 1 FROM categories WHERE id = $1 AND is_active = TRUE`,
    [categoryId]
  );
  return rows.length > 0;
}

async function getQuestionWithCorrectAlternative(questionId, executor = db) {
  const { rows } = await executor.query(
    `SELECT id, category_id, time_limit_seconds, xp_reward, difficulty, explanation, learn_point, memory_tip FROM questions WHERE id = $1 AND is_active = TRUE`,
    [questionId]
  );
  if (!rows[0]) return null;

  const altResult = await executor.query(
    `SELECT id, label, is_correct FROM question_alternatives WHERE question_id = $1 ORDER BY display_order`,
    [questionId]
  );

  return { ...rows[0], alternatives: altResult.rows };
}

async function recordAttempt(executor, { userId, questionId, alternativeId, isCorrect, responseTimeMs, xpAwarded, pointsAwarded = 0, roundId = null }) {
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
// Rodadas (migration 107): o servidor é a fonte de verdade do progresso.
// ---------------------------------------------------------------------------

const ROUND_COLUMNS = `id, user_id, category_id, target_questions, status, checkpoint_at,
                       started_at, updated_at, completed_at, summary_shown_at`;

/** Rodadas em andamento paradas há muito tempo passam a "abandoned" (a próxima abre uma nova). */
async function abandonStaleRounds(executor, { userId, categoryId, idleHours }) {
  await executor.query(
    `UPDATE quiz_rounds SET status = 'abandoned'
     WHERE user_id = $1 AND category_id = $2 AND status = 'in_progress'
       AND updated_at < now() - make_interval(hours => $3)`,
    [userId, categoryId, idleHours]
  );
}

async function findInProgressRound(executor, { userId, categoryId, forUpdate = false }) {
  const { rows } = await executor.query(
    `SELECT ${ROUND_COLUMNS} FROM quiz_rounds
     WHERE user_id = $1 AND category_id = $2 AND status = 'in_progress'
     ${forUpdate ? 'FOR UPDATE' : ''}`,
    [userId, categoryId]
  );
  return rows[0] || null;
}

/** Cria a rodada; se outra requisição criou primeiro (índice único parcial), devolve a existente. */
async function createRound(executor, { userId, categoryId, targetQuestions }) {
  const { rows } = await executor.query(
    `INSERT INTO quiz_rounds (user_id, category_id, target_questions)
     VALUES ($1, $2, $3)
     ON CONFLICT DO NOTHING
     RETURNING ${ROUND_COLUMNS}`,
    [userId, categoryId, targetQuestions]
  );
  return rows[0] || findInProgressRound(executor, { userId, categoryId });
}

async function getRoundProgress(executor, roundId) {
  const { rows } = await executor.query(
    `SELECT COUNT(*)::int AS answered,
            COUNT(*) FILTER (WHERE is_correct)::int AS correct,
            COALESCE(SUM(xp_awarded), 0)::int AS xp,
            COALESCE(SUM(points_awarded), 0)::int AS points
     FROM quiz_attempts WHERE round_id = $1`,
    [roundId]
  );
  return rows[0];
}

async function listAnsweredQuestionIds(executor, roundId) {
  const { rows } = await executor.query(
    `SELECT question_id FROM quiz_attempts WHERE round_id = $1`,
    [roundId]
  );
  return rows.map((r) => r.question_id);
}

async function markRoundCheckpoint(executor, roundId) {
  await executor.query(
    `UPDATE quiz_rounds SET checkpoint_at = COALESCE(checkpoint_at, now()) WHERE id = $1`,
    [roundId]
  );
}

async function completeRound(executor, roundId) {
  await executor.query(
    // P7: grava os totais da rodada no momento em que ela fecha (a última tentativa já foi
    // registada nesta mesma transação).
    `UPDATE quiz_rounds r
     SET status = 'completed', completed_at = now(), checkpoint_at = COALESCE(r.checkpoint_at, now()),
         correct_count     = t.correct_count,
         total_response_ms = t.total_response_ms,
         xp_total          = t.xp_total,
         points_total      = t.points_total
     FROM (
       SELECT COUNT(*) FILTER (WHERE is_correct)::int AS correct_count,
              COALESCE(SUM(response_time_ms), 0)::int AS total_response_ms,
              COALESCE(SUM(xp_awarded), 0)::int       AS xp_total,
              COALESCE(SUM(points_awarded), 0)::int   AS points_total
       FROM quiz_attempts WHERE round_id = $1
     ) t
     WHERE r.id = $1`,
    [roundId]
  );
}

async function touchRound(executor, roundId) {
  await executor.query(`UPDATE quiz_rounds SET updated_at = now() WHERE id = $1`, [roundId]);
}

async function getRoundOfUser(executor, { roundId, userId }) {
  const { rows } = await executor.query(
    `SELECT r.id, r.category_id, r.target_questions, r.status, r.started_at, r.completed_at,
            r.summary_shown_at, r.correct_count, r.total_response_ms, r.xp_total, r.points_total,
            c.name AS category_name
     FROM quiz_rounds r JOIN categories c ON c.id = r.category_id
     WHERE r.id = $1 AND r.user_id = $2`,
    [roundId, userId]
  );
  return rows[0] || null;
}

/** Uma linha por pergunta respondida na rodada, com a alternativa correta (para o resumo). */
async function listRoundAttemptDetails(executor, roundId) {
  const { rows } = await executor.query(
    `SELECT a.question_id, a.is_correct, a.response_time_ms, a.xp_awarded, a.points_awarded,
            a.created_at, q.statement, q.difficulty,
            cor.label AS correct_label
     FROM quiz_attempts a
     JOIN questions q ON q.id = a.question_id
     LEFT JOIN question_alternatives cor ON cor.question_id = q.id AND cor.is_correct = TRUE
     WHERE a.round_id = $1
     ORDER BY a.created_at`,
    [roundId]
  );
  return rows;
}

async function markSummaryShown(executor, roundId) {
  await executor.query(
    `UPDATE quiz_rounds SET summary_shown_at = COALESCE(summary_shown_at, now()) WHERE id = $1`,
    [roundId]
  );
}

// ---------------------------------------------------------------------------
// Perguntas da rodada (migration 109)
// ---------------------------------------------------------------------------

/** Perguntas ativas da categoria, com a última vez que ESTE utilizador as respondeu (qualquer rodada). */
async function listRoundCandidates(executor, { userId, categoryId }) {
  const { rows } = await executor.query(
    `SELECT q.id, q.difficulty, seen.last_seen_at AS "lastSeenAt"
     FROM questions q
     LEFT JOIN (
       SELECT question_id, MAX(created_at) AS last_seen_at
       FROM quiz_attempts WHERE user_id = $1 GROUP BY question_id
     ) seen ON seen.question_id = q.id
     WHERE q.category_id = $2 AND q.is_active = TRUE`,
    [userId, categoryId]
  );
  return rows;
}

/** Bloqueia a rodada até ao fim da transação (duas chamadas simultâneas não geram dois conjuntos). */
async function lockRound(executor, roundId) {
  await executor.query(`SELECT id FROM quiz_rounds WHERE id = $1 FOR UPDATE`, [roundId]);
}

async function countRoundQuestions(executor, roundId) {
  const { rows } = await executor.query(
    `SELECT COUNT(*)::int AS n FROM quiz_round_questions WHERE round_id = $1`,
    [roundId]
  );
  return rows[0].n;
}

/**
 * P6b: a próxima pergunta da rodada pela posição guardada = a primeira (menor posição) que
 * o utilizador ainda não respondeu nesta rodada. Devolve o mesmo formato de
 * `getRandomQuestion` (sem a alternativa correta), ou null se todas já foram respondidas.
 */
async function getNextRoundQuestion(executor, roundId) {
  const { rows } = await executor.query(
    `SELECT q.id, q.category_id, q.difficulty, q.statement, q.time_limit_seconds
     FROM quiz_round_questions rq
     JOIN questions q ON q.id = rq.question_id
     WHERE rq.round_id = $1
       AND NOT EXISTS (
         SELECT 1 FROM quiz_attempts a
         WHERE a.round_id = rq.round_id AND a.question_id = rq.question_id
       )
     ORDER BY rq.position
     LIMIT 1`,
    [roundId]
  );
  const question = rows[0];
  if (!question) return null;

  const altResult = await executor.query(
    `SELECT id, label FROM question_alternatives WHERE question_id = $1 ORDER BY display_order`,
    [question.id]
  );
  return { ...question, alternatives: altResult.rows };
}

/** Grava as perguntas escolhidas, com a posição 1..N pela ordem recebida. */
async function insertRoundQuestions(executor, roundId, questionIds) {
  const positions = questionIds.map((_, i) => i + 1);
  await executor.query(
    `INSERT INTO quiz_round_questions (round_id, position, question_id)
     SELECT $1, t.position, t.question_id
     FROM unnest($2::int[], $3::uuid[]) AS t(position, question_id)`,
    [roundId, positions, questionIds]
  );
}

module.exports = {
  listActiveCategories,
  categoryExists,
  getRandomQuestion,
  abandonStaleRounds,
  listRoundCandidates,
  lockRound,
  countRoundQuestions,
  insertRoundQuestions,
  findInProgressRound,
  createRound,
  getRoundProgress,
  listAnsweredQuestionIds,
  markRoundCheckpoint,
  completeRound,
  touchRound,
  getRoundOfUser,
  listRoundAttemptDetails,
  markSummaryShown,
  getQuestionWithCorrectAlternative,
  recordAttempt,
  countAttemptsToday,
  getNextRoundQuestion,
};
