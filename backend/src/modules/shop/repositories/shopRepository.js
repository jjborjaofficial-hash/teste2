const db = require('../../../config/database');

/**
 * Repository do módulo Loja (docx "SISTEMA DE ECONOMIA E RECOMPENSAS", Seção 3
 * — "sink de economia"). Único caminho de gasto de Pontos na plataforma.
 */

async function listActiveItems(executor = db) {
  const { rows } = await executor.query(
    `SELECT id, key, category, name, description, price_points, effect_key, eligibility_rule
     FROM shop_items WHERE is_active = TRUE ORDER BY category, price_points`
  );
  return rows;
}

async function findItemByKey(key, executor = db) {
  const { rows } = await executor.query(`SELECT * FROM shop_items WHERE key = $1`, [key]);
  return rows[0] || null;
}

async function findItemById(id, executor = db) {
  const { rows } = await executor.query(`SELECT * FROM shop_items WHERE id = $1`, [id]);
  return rows[0] || null;
}

async function listAllItemsAdmin() {
  const { rows } = await db.query(
    `SELECT si.*, (SELECT COUNT(*)::int FROM user_purchases up WHERE up.shop_item_id = si.id) AS purchases_count
     FROM shop_items si ORDER BY si.category, si.price_points`
  );
  return rows;
}

async function createItem({ key, category, name, description, pricePoints, effectKey, eligibilityRule }) {
  const { rows } = await db.query(
    `INSERT INTO shop_items (key, category, name, description, price_points, effect_key, eligibility_rule)
     VALUES ($1, $2, $3, $4, $5, $6, $7)
     RETURNING *`,
    [key, category, name, description || null, pricePoints, effectKey || null, eligibilityRule || null]
  );
  return rows[0];
}

async function updateItem(id, { name, description, pricePoints, isActive }) {
  const { rows } = await db.query(
    `UPDATE shop_items
     SET name = COALESCE($2, name),
         description = COALESCE($3, description),
         price_points = COALESCE($4, price_points),
         is_active = COALESCE($5, is_active)
     WHERE id = $1
     RETURNING *`,
    [id, name || null, description || null, pricePoints || null, isActive === undefined ? null : isActive]
  );
  return rows[0];
}

async function hasPurchased(userId, shopItemId, executor = db) {
  const { rows } = await executor.query(
    `SELECT 1 FROM user_purchases WHERE user_id = $1 AND shop_item_id = $2 LIMIT 1`,
    [userId, shopItemId]
  );
  return rows.length > 0;
}

async function recordPurchase(executor, { userId, shopItemId, pricePaidPoints, pointsLedgerId }) {
  const { rows } = await executor.query(
    `INSERT INTO user_purchases (user_id, shop_item_id, price_paid_points, points_ledger_id)
     VALUES ($1, $2, $3, $4)
     RETURNING id, created_at`,
    [userId, shopItemId, pricePaidPoints, pointsLedgerId || null]
  );
  return rows[0];
}

async function listMyPurchases(userId) {
  const { rows } = await db.query(
    `SELECT up.id, up.price_paid_points, up.created_at, si.key, si.category, si.name
     FROM user_purchases up
     JOIN shop_items si ON si.id = up.shop_item_id
     WHERE up.user_id = $1
     ORDER BY up.created_at DESC`,
    [userId]
  );
  return rows;
}

async function listOwnedCosmeticKeys(userId, executor = db) {
  const { rows } = await executor.query(
    `SELECT si.key
     FROM user_purchases up
     JOIN shop_items si ON si.id = up.shop_item_id
     WHERE up.user_id = $1 AND si.category IN ('cosmetic', 'prestige')`,
    [userId]
  );
  return rows.map((r) => r.key);
}

async function listPurchasesAdmin({ limit = 50, offset = 0 } = {}) {
  const { rows } = await db.query(
    `SELECT up.id, up.price_paid_points, up.created_at, si.name AS item_name, si.category,
            u.name AS user_name, u.phone AS user_phone
     FROM user_purchases up
     JOIN shop_items si ON si.id = up.shop_item_id
     JOIN users u ON u.id = up.user_id
     ORDER BY up.created_at DESC
     LIMIT $1 OFFSET $2`,
    [limit, offset]
  );
  return rows;
}

module.exports = {
  listActiveItems,
  findItemByKey,
  findItemById,
  listAllItemsAdmin,
  createItem,
  updateItem,
  hasPurchased,
  recordPurchase,
  listMyPurchases,
  listOwnedCosmeticKeys,
  listPurchasesAdmin,
};
