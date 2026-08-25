const db = require('../../../config/database');

/**
 * Repository: única camada autorizada a acessar o banco diretamente (Manual Parte 5).
 * Módulo Jurídico — docx "final jur.. do aprenda e ganhe" Partes 5-24.
 */

// --- Documentos e Versões ---

async function listDocumentsWithCurrentVersion() {
  const { rows } = await db.query(
    `SELECT d.id, d.type, d.title, d.requires_acceptance, d.status,
            v.id AS version_id, v.version, v.effective_date, v.published_at
     FROM legal_documents d
     LEFT JOIN legal_document_versions v ON v.id = d.current_version_id
     WHERE d.status = 'active'
     ORDER BY d.type`
  );
  return rows;
}

async function findDocumentByType(type) {
  const { rows } = await db.query(
    `SELECT d.id, d.type, d.title, d.requires_acceptance, d.status,
            v.id AS version_id, v.version, v.content, v.effective_date, v.published_at
     FROM legal_documents d
     LEFT JOIN legal_document_versions v ON v.id = d.current_version_id
     WHERE d.type = $1`,
    [type]
  );
  return rows[0] || null;
}

async function listMandatoryDocumentsWithCurrentVersion() {
  const { rows } = await db.query(
    `SELECT d.id, d.type, d.title,
            v.id AS version_id, v.version
     FROM legal_documents d
     JOIN legal_document_versions v ON v.id = d.current_version_id
     WHERE d.requires_acceptance = TRUE AND d.status = 'active'`
  );
  return rows;
}

async function listAllDocumentsAdmin() {
  const { rows } = await db.query(
    `SELECT d.id, d.type, d.title, d.requires_acceptance, d.status,
            v.id AS version_id, v.version, v.effective_date, v.published_at,
            (SELECT COUNT(*)::int FROM legal_document_versions vv WHERE vv.document_id = d.id) AS versions_count
     FROM legal_documents d
     LEFT JOIN legal_document_versions v ON v.id = d.current_version_id
     ORDER BY d.type`
  );
  return rows;
}

async function listVersionsByDocument(documentId) {
  const { rows } = await db.query(
    `SELECT id, version, content, effective_date, published_at, created_at
     FROM legal_document_versions
     WHERE document_id = $1
     ORDER BY created_at DESC`,
    [documentId]
  );
  return rows;
}

async function findDocumentById(documentId) {
  const { rows } = await db.query(`SELECT * FROM legal_documents WHERE id = $1`, [documentId]);
  return rows[0] || null;
}

async function findVersionById(versionId) {
  const { rows } = await db.query(`SELECT * FROM legal_document_versions WHERE id = $1`, [versionId]);
  return rows[0] || null;
}

async function createVersion({ documentId, version, content, effectiveDate, createdBy }) {
  const { rows } = await db.query(
    `INSERT INTO legal_document_versions (document_id, version, content, effective_date, created_by)
     VALUES ($1, $2, $3, $4, $5)
     RETURNING *`,
    [documentId, version, content, effectiveDate || null, createdBy || null]
  );
  return rows[0];
}

async function publishVersion(documentId, versionId) {
  const { rows } = await db.query(
    `UPDATE legal_documents SET current_version_id = $2 WHERE id = $1 RETURNING *`,
    [documentId, versionId]
  );
  await db.query(
    `UPDATE legal_document_versions SET published_at = now() WHERE id = $1 AND published_at IS NULL`,
    [versionId]
  );
  return rows[0];
}

async function archiveDocument(documentId) {
  await db.query(`UPDATE legal_documents SET status = 'archived' WHERE id = $1`, [documentId]);
}

// --- Consentimento (Registro de Aceitação) ---

async function findPendingMandatoryAcceptances(userId) {
  const { rows } = await db.query(
    `SELECT d.type, d.title, v.id AS version_id, v.version
     FROM legal_documents d
     JOIN legal_document_versions v ON v.id = d.current_version_id
     WHERE d.requires_acceptance = TRUE AND d.status = 'active'
       AND NOT EXISTS (
         SELECT 1 FROM user_legal_acceptances a
         WHERE a.user_id = $1 AND a.document_version_id = v.id
       )`,
    [userId]
  );
  return rows;
}

async function recordAcceptance(executor, { userId, documentVersionId, ipAddress, userAgent }) {
  await executor.query(
    `INSERT INTO user_legal_acceptances (user_id, document_version_id, ip_address, user_agent)
     VALUES ($1, $2, $3, $4)
     ON CONFLICT (user_id, document_version_id) DO NOTHING`,
    [userId, documentVersionId, ipAddress || null, userAgent || null]
  );
}

async function listAcceptancesByUser(userId) {
  const { rows } = await db.query(
    `SELECT a.accepted_at, a.ip_address, d.type, d.title, v.version
     FROM user_legal_acceptances a
     JOIN legal_document_versions v ON v.id = a.document_version_id
     JOIN legal_documents d ON d.id = v.document_id
     WHERE a.user_id = $1
     ORDER BY a.accepted_at DESC`,
    [userId]
  );
  return rows;
}

async function countAcceptancesByVersion(versionId) {
  const { rows } = await db.query(
    `SELECT COUNT(*)::int AS count FROM user_legal_acceptances WHERE document_version_id = $1`,
    [versionId]
  );
  return rows[0].count;
}

async function listAcceptancesByDocument(documentId, { limit, offset }) {
  const { rows } = await db.query(
    `SELECT a.id, a.accepted_at, a.ip_address, u.id AS user_id, u.name AS user_name, u.phone AS user_phone, v.version
     FROM user_legal_acceptances a
     JOIN legal_document_versions v ON v.id = a.document_version_id
     JOIN users u ON u.id = a.user_id
     WHERE v.document_id = $1
     ORDER BY a.accepted_at DESC
     LIMIT $2 OFFSET $3`,
    [documentId, limit, offset]
  );
  return rows;
}

// --- Cookies ---

async function getCookiePreferences(userId) {
  const { rows } = await db.query(`SELECT * FROM cookie_preferences WHERE user_id = $1`, [userId]);
  return rows[0] || null;
}

async function upsertCookiePreferences(userId, { preferences, analytics, advertising }) {
  const { rows } = await db.query(
    `INSERT INTO cookie_preferences (user_id, preferences, analytics, advertising)
     VALUES ($1, $2, $3, $4)
     ON CONFLICT (user_id) DO UPDATE SET
        preferences = EXCLUDED.preferences,
        analytics = EXCLUDED.analytics,
        advertising = EXCLUDED.advertising,
        updated_at = now()
     RETURNING *`,
    [userId, !!preferences, !!analytics, !!advertising]
  );
  return rows[0];
}

// --- Central de Reclamações (legal_requests) ---

async function createLegalRequest({ userId, category, description }) {
  const { rows } = await db.query(
    `INSERT INTO legal_requests (user_id, category, description)
     VALUES ($1, $2, $3)
     RETURNING *`,
    [userId, category, description]
  );
  return rows[0];
}

async function listLegalRequestsByUser(userId) {
  const { rows } = await db.query(
    `SELECT * FROM legal_requests WHERE user_id = $1 ORDER BY created_at DESC`,
    [userId]
  );
  return rows;
}

async function listLegalRequestsAdmin({ status, limit, offset }) {
  const params = [];
  let where = '';
  if (status) {
    params.push(status);
    where = `WHERE r.status = $${params.length}`;
  }
  params.push(limit, offset);
  const { rows } = await db.query(
    `SELECT r.*, u.name AS user_name, u.phone AS user_phone
     FROM legal_requests r
     JOIN users u ON u.id = r.user_id
     ${where}
     ORDER BY r.created_at DESC
     LIMIT $${params.length - 1} OFFSET $${params.length}`,
    params
  );
  return rows;
}

async function findLegalRequestById(id) {
  const { rows } = await db.query(
    `SELECT r.*, u.name AS user_name, u.phone AS user_phone
     FROM legal_requests r
     JOIN users u ON u.id = r.user_id
     WHERE r.id = $1`,
    [id]
  );
  return rows[0] || null;
}

async function updateLegalRequest(id, { status, response, responsibleAdminId }) {
  const { rows } = await db.query(
    `UPDATE legal_requests
     SET status = $2, response = COALESCE($3, response), responsible_admin_id = COALESCE($4, responsible_admin_id)
     WHERE id = $1
     RETURNING *`,
    [id, status, response || null, responsibleAdminId || null]
  );
  return rows[0];
}

// --- Sistema de Recursos e Contestação (legal_appeals) ---

async function createAppeal({ userId, relatedAction, description, protocol }) {
  const { rows } = await db.query(
    `INSERT INTO legal_appeals (protocol, user_id, related_action, description)
     VALUES ($1, $2, $3, $4)
     RETURNING *`,
    [protocol, userId, relatedAction, description]
  );
  return rows[0];
}

async function listAppealsByUser(userId) {
  const { rows } = await db.query(
    `SELECT * FROM legal_appeals WHERE user_id = $1 ORDER BY created_at DESC`,
    [userId]
  );
  return rows;
}

async function listAppealsAdmin({ status, limit, offset }) {
  const params = [];
  let where = '';
  if (status) {
    params.push(status);
    where = `WHERE a.status = $${params.length}`;
  }
  params.push(limit, offset);
  const { rows } = await db.query(
    `SELECT a.*, u.name AS user_name, u.phone AS user_phone
     FROM legal_appeals a
     JOIN users u ON u.id = a.user_id
     ${where}
     ORDER BY a.created_at DESC
     LIMIT $${params.length - 1} OFFSET $${params.length}`,
    params
  );
  return rows;
}

async function findAppealById(id) {
  const { rows } = await db.query(
    `SELECT a.*, u.name AS user_name, u.phone AS user_phone
     FROM legal_appeals a
     JOIN users u ON u.id = a.user_id
     WHERE a.id = $1`,
    [id]
  );
  return rows[0] || null;
}

async function decideAppeal(id, { status, decision, decidedBy }) {
  const { rows } = await db.query(
    `UPDATE legal_appeals
     SET status = $2, decision = $3, decided_by = $4, decided_at = now()
     WHERE id = $1
     RETURNING *`,
    [id, status, decision, decidedBy]
  );
  return rows[0];
}

async function countAppealsByProtocolPrefix(prefix) {
  const { rows } = await db.query(
    `SELECT COUNT(*)::int AS count FROM legal_appeals WHERE protocol LIKE $1`,
    [`${prefix}%`]
  );
  return rows[0].count;
}

module.exports = {
  listDocumentsWithCurrentVersion,
  findDocumentByType,
  listMandatoryDocumentsWithCurrentVersion,
  listAllDocumentsAdmin,
  listVersionsByDocument,
  findDocumentById,
  findVersionById,
  createVersion,
  publishVersion,
  archiveDocument,
  findPendingMandatoryAcceptances,
  recordAcceptance,
  listAcceptancesByUser,
  countAcceptancesByVersion,
  listAcceptancesByDocument,
  getCookiePreferences,
  upsertCookiePreferences,
  createLegalRequest,
  listLegalRequestsByUser,
  listLegalRequestsAdmin,
  findLegalRequestById,
  updateLegalRequest,
  createAppeal,
  listAppealsByUser,
  listAppealsAdmin,
  findAppealById,
  decideAppeal,
  countAppealsByProtocolPrefix,
};
