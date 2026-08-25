const db = require('../../../config/database');

/**
 * Repository administrativo de Missões. Antes deste arquivo, a tabela
 * `missions` só tinha 1 linha de seed de desenvolvimento e nenhuma rota para
 * criar novas — sem isso, a plataforma em produção nunca teria missões reais.
 */

async function listAllMissions() {
  const { rows } = await db.query(
    `SELECT m.*, c.name AS category_name,
            (SELECT COUNT(*)::int FROM user_missions um WHERE um.mission_id = m.id) AS assignments_count
     FROM missions m
     LEFT JOIN categories c ON c.id = m.category_id
     ORDER BY m.created_at DESC`
  );
  return rows;
}

async function findMissionById(id) {
  const { rows } = await db.query(`SELECT * FROM missions WHERE id = $1`, [id]);
  return rows[0] || null;
}

async function createMission({ title, description, type, categoryId, targetQuizCount, xpReward, pointsReward, moneyRewardMzn, startsAt, endsAt }) {
  const { rows } = await db.query(
    `INSERT INTO missions
        (title, description, type, category_id, target_quiz_count, xp_reward, points_reward, money_reward_mzn, starts_at, ends_at)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
     RETURNING *`,
    [title, description || null, type, categoryId || null, targetQuizCount, xpReward, pointsReward, moneyRewardMzn, startsAt || null, endsAt || null]
  );
  return rows[0];
}

async function updateMission(id, { title, description, targetQuizCount, xpReward, pointsReward, moneyRewardMzn, isActive, startsAt, endsAt }) {
  const { rows } = await db.query(
    `UPDATE missions
     SET title = COALESCE($2, title),
         description = COALESCE($3, description),
         target_quiz_count = COALESCE($4, target_quiz_count),
         xp_reward = COALESCE($5, xp_reward),
         points_reward = COALESCE($6, points_reward),
         money_reward_mzn = COALESCE($7, money_reward_mzn),
         is_active = COALESCE($8, is_active),
         starts_at = COALESCE($9, starts_at),
         ends_at = COALESCE($10, ends_at)
     WHERE id = $1
     RETURNING *`,
    [
      id,
      title || null,
      description || null,
      targetQuizCount || null,
      xpReward === undefined ? null : xpReward,
      pointsReward === undefined ? null : pointsReward,
      moneyRewardMzn === undefined ? null : moneyRewardMzn,
      isActive === undefined ? null : isActive,
      startsAt || null,
      endsAt || null,
    ]
  );
  return rows[0];
}

module.exports = { listAllMissions, findMissionById, createMission, updateMission };
