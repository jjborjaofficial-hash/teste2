const db = require('../../../config/database');

/**
 * Repository do Inventário ("Meus Recursos" — spec Seções 34-60).
 * `effective_inventory_status()` (migration 025) trata como 'expired'
 * qualquer linha 'active' cujo expires_at já passou, mesmo que o CRON de
 * limpeza ainda não tenha rodado — leitura nunca mente sobre expiração.
 */

async function listForUser(userId, executor = db) {
  const { rows } = await executor.query(
    `SELECT ui.id, ui.quantity, ui.source, ui.acquired_at, ui.activated_at, ui.expires_at, ui.used_at,
            effective_inventory_status(ui.status, ui.expires_at) AS status,
            si.key, si.category, si.name, si.description, si.effect_key,
            si.is_consumable, si.duration_seconds
     FROM user_inventory ui
     JOIN shop_items si ON si.id = ui.item_id
     WHERE ui.user_id = $1
     ORDER BY
       CASE effective_inventory_status(ui.status, ui.expires_at)
         WHEN 'active' THEN 0 WHEN 'owned' THEN 1 WHEN 'expired' THEN 2 ELSE 3
       END,
       ui.expires_at ASC NULLS LAST,
       ui.acquired_at DESC`,
    [userId]
  );
  return rows;
}

async function findOwnedRow(userId, itemId, executor = db) {
  const { rows } = await executor.query(
    `SELECT * FROM user_inventory
     WHERE user_id = $1 AND item_id = $2 AND status = 'owned'
     ORDER BY acquired_at ASC
     LIMIT 1
     FOR UPDATE`,
    [userId, itemId]
  );
  return rows[0] || null;
}

async function grantConsumable(executor, { userId, itemId, source, referenceId }) {
  const existing = await findOwnedRow(userId, itemId, executor);
  if (existing) {
    const { rows } = await executor.query(
      `UPDATE user_inventory SET quantity = quantity + 1, updated_at = now() WHERE id = $1 RETURNING *`,
      [existing.id]
    );
    return rows[0];
  }
  const { rows } = await executor.query(
    `INSERT INTO user_inventory (user_id, item_id, quantity, status, source, reference_id)
     VALUES ($1, $2, 1, 'owned', $3, $4)
     RETURNING *`,
    [userId, itemId, source, referenceId || null]
  );
  return rows[0];
}

async function grantTemporary(executor, { userId, itemId, source, referenceId }) {
  const { rows } = await executor.query(
    `INSERT INTO user_inventory (user_id, item_id, quantity, status, source, reference_id)
     VALUES ($1, $2, 1, 'owned', $3, $4)
     RETURNING *`,
    [userId, itemId, source, referenceId || null]
  );
  return rows[0];
}

async function findByIdForUser(id, userId, executor = db) {
  const { rows } = await executor.query(
    `SELECT ui.*, si.key, si.category, si.name, si.effect_key, si.is_consumable, si.duration_seconds
     FROM user_inventory ui
     JOIN shop_items si ON si.id = ui.item_id
     WHERE ui.id = $1 AND ui.user_id = $2
     FOR UPDATE OF ui`,
    [id, userId]
  );
  return rows[0] || null;
}

async function activate(executor, id, durationSeconds) {
  const { rows } = await executor.query(
    `UPDATE user_inventory
     SET status = 'active', activated_at = now(), expires_at = now() + ($2 || ' seconds')::interval, updated_at = now()
     WHERE id = $1
     RETURNING *`,
    [id, durationSeconds]
  );
  return rows[0];
}

async function consumeOne(executor, id) {
  const { rows } = await executor.query(
    `UPDATE user_inventory
     SET quantity = quantity - 1,
         status = CASE WHEN quantity - 1 <= 0 THEN 'used' ELSE status END,
         used_at = now(),
         updated_at = now()
     WHERE id = $1
     RETURNING *`,
    [id]
  );
  return rows[0];
}

/**
 * Usado pelo motor de pontos (xpService) para checar se o usuário tem um
 * boost de Pontos ativo no momento em que uma recompensa está sendo
 * creditada — SEMPRE revalidando expires_at no servidor (spec Seção 55).
 */
async function getActiveEffect(userId, effectKey, executor = db) {
  const { rows } = await executor.query(
    `SELECT ui.id, ui.expires_at
     FROM user_inventory ui
     JOIN shop_items si ON si.id = ui.item_id
     WHERE ui.user_id = $1
       AND si.effect_key = $2
       AND ui.status = 'active'
       AND ui.expires_at > now()
     LIMIT 1`,
    [userId, effectKey]
  );
  return rows[0] || null;
}

async function expireOverdue(executor = db) {
  const { rowCount } = await executor.query(
    `UPDATE user_inventory SET status = 'expired', updated_at = now()
     WHERE status = 'active' AND expires_at <= now()`
  );
  return rowCount;
}

module.exports = {
  listForUser,
  grantConsumable,
  grantTemporary,
  findByIdForUser,
  activate,
  consumeOne,
  getActiveEffect,
  expireOverdue,
};
