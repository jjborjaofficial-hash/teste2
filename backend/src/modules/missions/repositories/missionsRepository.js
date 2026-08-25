const db = require('../../../config/database');
const { dateInPlatformTz } = require('../../../common/time/platformTimezone');

async function listActiveMissions(executor = db) {
  const { rows } = await executor.query(
    `SELECT id, title, description, type, category_id, target_quiz_count,
            xp_reward, points_reward, money_reward_mzn
     FROM missions
     WHERE is_active = TRUE
       AND (starts_at IS NULL OR starts_at <= now())
       AND (ends_at IS NULL OR ends_at >= now())`
  );
  return rows;
}

async function getUserMissionProgress(userId, executor = db) {
  const { rows } = await executor.query(
    `SELECT um.id, um.mission_id, um.progress_count, um.status, um.assigned_at, um.completed_at,
            m.title, m.description, m.type, m.category_id, m.target_quiz_count,
            m.xp_reward, m.points_reward, m.money_reward_mzn
     FROM user_missions um
     JOIN missions m ON m.id = um.mission_id
     WHERE um.user_id = $1 AND um.status IN ('in_progress', 'completed')
     ORDER BY um.assigned_at DESC`,
    [userId]
  );
  return rows;
}

async function assignMissionIfNotPresent(executor, { userId, missionId, targetSnapshot }) {
  // target_snapshot (migration 022, NOT NULL): alvo congelado no momento da
  // atribuição. period_date usa o fuso oficial da plataforma (Moçambique),
  // não o DEFAULT CURRENT_DATE da coluna (que resolveria no fuso do servidor).
  await executor.query(
    `INSERT INTO user_missions (user_id, mission_id, target_snapshot, period_date)
     VALUES ($1, $2, $3, ${dateInPlatformTz('now()')})
     ON CONFLICT DO NOTHING`,
    [userId, missionId, targetSnapshot]
  );
}

/**
 * Incrementa o progresso de todas as missões ativas do usuário que casam com a
 * categoria da pergunta respondida corretamente, marcando como concluída ao bater a meta.
 * Executado dentro da transação da submissão de resposta do Quiz (baixo acoplamento:
 * o Quiz apenas notifica "categoria X foi respondida corretamente", sem conhecer regras
 * internas de Missões).
 */
async function incrementProgressForCategory(executor, { userId, categoryId }) {
  const { rows } = await executor.query(
    `UPDATE user_missions um
     SET progress_count = um.progress_count + 1,
         status = CASE
             WHEN um.progress_count + 1 >= m.target_quiz_count THEN 'completed'
             ELSE um.status
         END,
         completed_at = CASE
             WHEN um.progress_count + 1 >= m.target_quiz_count THEN now()
             ELSE um.completed_at
         END
     FROM missions m
     WHERE um.mission_id = m.id
       AND um.user_id = $1
       AND um.status = 'in_progress'
       AND m.activity_type = 'quiz_count'
       AND (m.category_id IS NULL OR m.category_id = $2)
     RETURNING um.id, um.mission_id, um.status, m.title`,
    [userId, categoryId]
  );
  return rows; // missões que acabaram de ser concluídas ou tiveram progresso
}

/**
 * Progresso de missões activity_type='login': marca como concluída em
 * qualquer login válido do dia — sempre alvo 1 (não incrementa contador,
 * completa direto, já que "logar" não tem graus intermediários).
 */
async function completeLoginMissions(executor, { userId }) {
  const { rows } = await executor.query(
    `UPDATE user_missions um
     SET progress_count = 1,
         status = 'completed',
         completed_at = now()
     FROM missions m
     WHERE um.mission_id = m.id
       AND um.user_id = $1
       AND um.status = 'in_progress'
       AND m.activity_type = 'login'
     RETURNING um.id, um.mission_id, um.status, m.title`,
    [userId]
  );
  return rows;
}

/**
 * Progresso de missões activity_type='category_exploration': incrementa
 * apenas se `categoryId` ainda não estiver em `visited_categories` desta
 * atribuição — visitar a mesma categoria de novo não conta duas vezes.
 */
async function incrementCategoryExploration(executor, { userId, categoryId }) {
  const { rows } = await executor.query(
    `UPDATE user_missions um
     SET progress_count = um.progress_count + 1,
         visited_categories = array_append(um.visited_categories, $2::uuid),
         status = CASE
             WHEN um.progress_count + 1 >= um.target_snapshot THEN 'completed'
             ELSE um.status
         END,
         completed_at = CASE
             WHEN um.progress_count + 1 >= um.target_snapshot THEN now()
             ELSE um.completed_at
         END
     FROM missions m
     WHERE um.mission_id = m.id
       AND um.user_id = $1
       AND um.status = 'in_progress'
       AND m.activity_type = 'category_exploration'
       AND NOT ($2::uuid = ANY(um.visited_categories))
     RETURNING um.id, um.mission_id, um.status, m.title`,
    [userId, categoryId]
  );
  return rows;
}

async function getUserMissionById(userId, userMissionId, executor = db) {
  const { rows } = await executor.query(
    `SELECT um.id, um.status, um.progress_count,
            m.target_quiz_count, m.xp_reward, m.points_reward, m.money_reward_mzn, m.title
     FROM user_missions um
     JOIN missions m ON m.id = um.mission_id
     WHERE um.id = $1 AND um.user_id = $2
     FOR UPDATE`,
    [userMissionId, userId]
  );
  return rows[0] || null;
}

async function markRewardClaimed(executor, userMissionId) {
  await executor.query(
    `UPDATE user_missions SET status = 'reward_claimed', claimed_at = now() WHERE id = $1`,
    [userMissionId]
  );
}

module.exports = {
  listActiveMissions,
  getUserMissionProgress,
  assignMissionIfNotPresent,
  incrementProgressForCategory,
  completeLoginMissions,
  incrementCategoryExploration,
  getUserMissionById,
  markRewardClaimed,
};
