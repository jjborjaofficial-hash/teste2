const db = require('../../config/database');

/**
 * Repository compartilhado de auditoria (Manual Parte 4: audit_logs é append-only).
 * Centralizado aqui para evitar duplicação entre módulos (Auth, Admin, etc.).
 */
async function insertAuditLog(executor, { userId, action, entity, entityId, metadata, ipAddress }) {
  await executor.query(
    `INSERT INTO audit_logs (user_id, action, entity, entity_id, metadata, ip_address)
     VALUES ($1, $2, $3, $4, $5, $6)`,
    [userId || null, action, entity, entityId || null, JSON.stringify(metadata || {}), ipAddress || null]
  );
}

module.exports = { insertAuditLog };
