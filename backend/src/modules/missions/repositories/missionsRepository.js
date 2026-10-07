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
            um.target_snapshot, m.activity_type,
            m.title, m.description, m.type, m.category_id, m.target_quiz_count,
            m.xp_reward, m.points_reward, m.money_reward_mzn
     FROM user_missions um
     JOIN missions m ON m.id = um.mission_id
     WHERE um.user_id = $1
       AND (
         -- Missões diárias reiniciam a cada dia: o que ficou em andamento ontem expira.
         (um.status = 'in_progress' AND um.period_date = ${dateInPlatformTz('now()')})
         -- Concluídas e ainda não resgatadas continuam disponíveis para resgate.
         OR um.status = 'completed'
         -- Missões já resgatadas HOJE continuam visíveis (progresso do dia 6/6).
         OR (um.status = 'reward_claimed' AND um.period_date = ${dateInPlatformTz('now()')})
       )
     ORDER BY m.created_at ASC, um.assigned_at DESC`,
    [userId]
  );
  return rows;
}

/**
 * Expira as missões diárias deste utilizador que ficaram em andamento em dias
 * anteriores. É o mesmo critério do CRON expireMissions, aplicado ao abrir a lista:
 * sem isso (e sem o worker a correr) a missão de ontem bloqueia, pela UNIQUE
 * parcial (user_id, mission_id) WHERE status IN ('in_progress','completed'),
 * a atribuição de hoje e o utilizador fica com menos missões.
 */
async function expireStaleDailyForUser(executor, userId) {
  await executor.query(
    `UPDATE user_missions um
     SET status = 'expired'
     FROM missions m
     WHERE um.mission_id = m.id
       AND um.user_id = $1
       AND um.status = 'in_progress'
       AND m.ends_at IS NULL
       AND um.period_date < ${dateInPlatformTz('now()')}`,
    [userId]
  );
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
       AND um.period_date = ${dateInPlatformTz('now()')}
       AND m.activity_type = 'quiz_count'
       AND (m.category_id IS NULL OR m.category_id = $2)
     RETURNING um.id, um.mission_id, um.status, m.title`,
    [userId, categoryId]
  );
  return rows; // missões que acabaram de ser concluídas ou tiveram progresso
}

/**
 * Progresso de missões activity_type='round_complete' (BE-005 b): +1 por rodada concluída. Mesmo molde do
 * quiz_count: só missões em andamento do dia, e se a missão tiver categoria só conta rodadas dessa categoria.
 * Chamado pelo Quiz DENTRO da transação que fecha a rodada (por isso nunca conta a mesma rodada duas vezes).
 */
async function incrementRoundCompletion(executor, { userId, categoryId }) {
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
       AND um.period_date = ${dateInPlatformTz('now()')}
       AND m.activity_type = 'round_complete'
       AND (m.category_id IS NULL OR m.category_id = $2)
     RETURNING um.id, um.mission_id, um.status, m.title`,
    [userId, categoryId]
  );
  return rows;
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
       AND um.period_date = ${dateInPlatformTz('now()')}
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
       AND um.period_date = ${dateInPlatformTz('now()')}
       AND m.activity_type = 'category_exploration'
       AND NOT ($2::uuid = ANY(um.visited_categories))
     RETURNING um.id, um.mission_id, um.status, m.title`,
    [userId, categoryId]
  );
  return rows;
}


/**
 * Progresso de missões activity_type='time_active_minutes' (heartbeat).
 *
 * Anti-fraude: o cliente NÃO envia tempo nenhum. O servidor soma o intervalo
 * entre este heartbeat e o anterior, mas só se for <= 60s (o cliente envia a
 * cada 30s com a aba visível). Intervalos maiores (aba em segundo plano, app
 * fechado) valem 0 — não dá para "acumular" tempo sem estar realmente ativo.
 */
const HEARTBEAT_MAX_GAP_SECONDS = 60;
const HEARTBEAT_DELTA_SQL = `(CASE
    WHEN um.last_heartbeat_at IS NULL THEN 0
    WHEN EXTRACT(EPOCH FROM (now() - um.last_heartbeat_at)) <= ${HEARTBEAT_MAX_GAP_SECONDS}
      THEN FLOOR(EXTRACT(EPOCH FROM (now() - um.last_heartbeat_at)))::int
    ELSE 0
  END)`;

async function addActiveTime(executor, { userId }) {
  const { rows } = await executor.query(
    `UPDATE user_missions um
     SET active_seconds = um.active_seconds + ${HEARTBEAT_DELTA_SQL},
         last_heartbeat_at = now(),
         progress_count = LEAST(um.target_snapshot, (um.active_seconds + ${HEARTBEAT_DELTA_SQL}) / 60),
         status = CASE
             WHEN (um.active_seconds + ${HEARTBEAT_DELTA_SQL}) / 60 >= um.target_snapshot THEN 'completed'
             ELSE um.status
         END,
         completed_at = CASE
             WHEN (um.active_seconds + ${HEARTBEAT_DELTA_SQL}) / 60 >= um.target_snapshot THEN now()
             ELSE um.completed_at
         END
     FROM missions m
     WHERE um.mission_id = m.id
       AND um.user_id = $1
       AND um.status = 'in_progress'
       AND m.activity_type = 'time_active_minutes'
       AND um.period_date = ${dateInPlatformTz('now()')}
     RETURNING um.id, um.mission_id, um.status, um.progress_count, um.target_snapshot, m.title`,
    [userId]
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
  expireStaleDailyForUser,
  incrementProgressForCategory,
  incrementRoundCompletion,
  completeLoginMissions,
  incrementCategoryExploration,
  addActiveTime,
  getUserMissionById,
  markRewardClaimed,
};
