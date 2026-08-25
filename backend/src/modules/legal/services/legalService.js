const db = require('../../../config/database');
const repository = require('../repositories/legalRepository');
const auditLogRepository = require('../../../common/repositories/auditLogRepository');
const { NotFoundError, ConflictError, BusinessRuleError } = require('../../../common/errors/AppError');

/**
 * Service: regras de negócio do Módulo Jurídico (docx "final jur.." Partes 5-24).
 * A camada jurídica é funcional, não apenas informativa — integra-se ao cadastro,
 * consentimento, cookies, recompensas/saques e ao Painel Administrativo.
 */

// Eventos de auditoria oficiais (docx Parte 13)
const AUDIT_EVENTS = {
  TERMS_ACCEPTED: 'USER_ACCEPTED_TERMS',
  PRIVACY_ACCEPTED: 'PRIVACY_ACCEPTED',
  COOKIES_CHANGED: 'COOKIE_SETTINGS_CHANGED',
  DOCUMENT_UPDATED: 'LEGAL_DOCUMENT_UPDATED',
  APPEAL_CREATED: 'USER_APPEAL_CREATED',
  APPEAL_DECIDED: 'USER_APPEAL_DECIDED',
  REQUEST_CREATED: 'LEGAL_REQUEST_CREATED',
  REQUEST_UPDATED: 'LEGAL_REQUEST_UPDATED',
};

function mapDocumentSummary(d) {
  return {
    id: d.id,
    type: d.type,
    title: d.title,
    requiresAcceptance: d.requires_acceptance,
    status: d.status,
    version: d.version || null,
    effectiveDate: d.effective_date || null,
    publishedAt: d.published_at || null,
  };
}

async function listDocuments() {
  const rows = await repository.listDocumentsWithCurrentVersion();
  return rows.map(mapDocumentSummary);
}

async function getDocumentByType(type) {
  const doc = await repository.findDocumentByType(type);
  if (!doc || !doc.version_id) {
    throw new NotFoundError('Documento jurídico não encontrado ou ainda sem versão publicada.');
  }
  return {
    ...mapDocumentSummary(doc),
    content: doc.content,
  };
}

/**
 * Retorna os documentos obrigatórios ainda não aceitos na versão vigente pelo
 * usuário — usado tanto para bloquear o cadastro/uso quanto para a tela de
 * reaceite (docx Parte 5 e 17 do Doc. Mestre — "Fluxo de Criação de Conta").
 */
async function getPendingMandatoryAcceptances(userId) {
  return repository.findPendingMandatoryAcceptances(userId);
}

async function hasPendingMandatoryAcceptance(userId) {
  const pending = await repository.findPendingMandatoryAcceptances(userId);
  return pending.length > 0;
}

/**
 * Registra o aceite de TODOS os documentos obrigatórios vigentes para um
 * usuário de uma só vez — corresponde ao checkbox único do cadastro
 * ("Declaro que sou maior de idade, li e concordo com os Termos de Uso e a
 * Política de Privacidade") e também é reutilizado no reaceite pós-atualização.
 */
async function acceptMandatoryDocuments(userId, { ipAddress, userAgent }, executor = db) {
  const mandatory = await repository.listMandatoryDocumentsWithCurrentVersion();
  if (mandatory.length === 0) {
    throw new BusinessRuleError('Nenhum documento obrigatório configurado.');
  }

  for (const doc of mandatory) {
    await repository.recordAcceptance(executor, {
      userId,
      documentVersionId: doc.version_id,
      ipAddress,
      userAgent,
    });

    await auditLogRepository.insertAuditLog(executor, {
      userId,
      action: doc.type === 'privacidade' ? AUDIT_EVENTS.PRIVACY_ACCEPTED : AUDIT_EVENTS.TERMS_ACCEPTED,
      entity: 'legal_document_versions',
      entityId: doc.version_id,
      metadata: { type: doc.type, version: doc.version },
      ipAddress,
    });
  }

  return mandatory.map((d) => ({ type: d.type, version: d.version }));
}

async function getMyAcceptances(userId) {
  return repository.listAcceptancesByUser(userId);
}

// --- Cookies (docx Parte 8) ---

async function getCookiePreferences(userId) {
  const prefs = await repository.getCookiePreferences(userId);
  if (!prefs) {
    return { essential: true, preferences: false, analytics: false, advertising: false, configured: false };
  }
  return {
    essential: true,
    preferences: prefs.preferences,
    analytics: prefs.analytics,
    advertising: prefs.advertising,
    configured: true,
    updatedAt: prefs.updated_at,
  };
}

async function setCookiePreferences(userId, choices, { ipAddress } = {}) {
  const saved = await repository.upsertCookiePreferences(userId, choices);
  await auditLogRepository.insertAuditLog(db, {
    userId,
    action: AUDIT_EVENTS.COOKIES_CHANGED,
    entity: 'cookie_preferences',
    entityId: null,
    metadata: { preferences: saved.preferences, analytics: saved.analytics, advertising: saved.advertising },
    ipAddress,
  });
  return { essential: true, preferences: saved.preferences, analytics: saved.analytics, advertising: saved.advertising };
}

// --- Central de Reclamações (docx Parte 11.4) ---

async function createLegalRequest(userId, { category, description }, { ipAddress } = {}) {
  const request = await repository.createLegalRequest({ userId, category, description });
  await auditLogRepository.insertAuditLog(db, {
    userId,
    action: AUDIT_EVENTS.REQUEST_CREATED,
    entity: 'legal_requests',
    entityId: request.id,
    metadata: { category },
    ipAddress,
  });
  return mapRequest(request);
}

function mapRequest(r) {
  return {
    id: r.id,
    category: r.category,
    description: r.description,
    status: r.status,
    response: r.response,
    createdAt: r.created_at,
    updatedAt: r.updated_at,
    userName: r.user_name,
    userPhone: r.user_phone,
  };
}

async function listMyLegalRequests(userId) {
  const rows = await repository.listLegalRequestsByUser(userId);
  return rows.map(mapRequest);
}

async function listLegalRequestsAdmin({ status, limit = 20, offset = 0 }) {
  const rows = await repository.listLegalRequestsAdmin({ status, limit, offset });
  return rows.map(mapRequest);
}

async function respondLegalRequest(requestId, { status, response }, { adminUserId, ipAddress }) {
  const existing = await repository.findLegalRequestById(requestId);
  if (!existing) throw new NotFoundError('Reclamação não encontrada.');

  const updated = await repository.updateLegalRequest(requestId, {
    status,
    response,
    responsibleAdminId: adminUserId,
  });

  await auditLogRepository.insertAuditLog(db, {
    userId: adminUserId,
    action: AUDIT_EVENTS.REQUEST_UPDATED,
    entity: 'legal_requests',
    entityId: requestId,
    metadata: { targetUserId: existing.user_id, status },
    ipAddress,
  });

  return mapRequest(updated);
}

// --- Sistema de Recursos e Contestação (docx Parte 12) ---

function generateProtocol(prefix, sequence) {
  const year = new Date().getFullYear();
  return `${prefix}-${year}-${String(sequence + 1).padStart(5, '0')}`;
}

async function createAppeal(userId, { relatedAction, description }, { ipAddress } = {}) {
  const sequence = await repository.countAppealsByProtocolPrefix('REC-');
  const protocol = generateProtocol('REC', sequence);

  const appeal = await repository.createAppeal({ userId, relatedAction, description, protocol });

  await auditLogRepository.insertAuditLog(db, {
    userId,
    action: AUDIT_EVENTS.APPEAL_CREATED,
    entity: 'legal_appeals',
    entityId: appeal.id,
    metadata: { relatedAction, protocol },
    ipAddress,
  });

  return mapAppeal(appeal);
}

function mapAppeal(a) {
  return {
    id: a.id,
    protocol: a.protocol,
    relatedAction: a.related_action,
    description: a.description,
    status: a.status,
    decision: a.decision,
    createdAt: a.created_at,
    decidedAt: a.decided_at,
    userName: a.user_name,
    userPhone: a.user_phone,
  };
}

async function listMyAppeals(userId) {
  const rows = await repository.listAppealsByUser(userId);
  return rows.map(mapAppeal);
}

async function listAppealsAdmin({ status, limit = 20, offset = 0 }) {
  const rows = await repository.listAppealsAdmin({ status, limit, offset });
  return rows.map(mapAppeal);
}

async function decideAppeal(appealId, { status, decision }, { adminUserId, ipAddress }) {
  const existing = await repository.findAppealById(appealId);
  if (!existing) throw new NotFoundError('Recurso não encontrado.');
  if (existing.status !== 'aberto' && existing.status !== 'em_analise') {
    throw new ConflictError(`Este recurso já foi decidido (status "${existing.status}").`);
  }

  const updated = await repository.decideAppeal(appealId, { status, decision, decidedBy: adminUserId });

  await auditLogRepository.insertAuditLog(db, {
    userId: adminUserId,
    action: AUDIT_EVENTS.APPEAL_DECIDED,
    entity: 'legal_appeals',
    entityId: appealId,
    metadata: { targetUserId: existing.user_id, status, protocol: existing.protocol },
    ipAddress,
  });

  return mapAppeal(updated);
}

// --- Administração de Documentos (docx Parte 11.1) ---

async function listDocumentsAdmin() {
  const rows = await repository.listAllDocumentsAdmin();
  return rows.map((d) => ({ ...mapDocumentSummary(d), versionsCount: d.versions_count }));
}

async function listVersions(documentId) {
  const doc = await repository.findDocumentById(documentId);
  if (!doc) throw new NotFoundError('Documento não encontrado.');
  const versions = await repository.listVersionsByDocument(documentId);
  return versions.map((v) => ({
    id: v.id,
    version: v.version,
    effectiveDate: v.effective_date,
    publishedAt: v.published_at,
    createdAt: v.created_at,
    isCurrent: v.id === doc.current_version_id,
  }));
}

/**
 * Cria uma nova versão em rascunho (docx Parte 6: nunca substituir, sempre
 * versionar). A versão só passa a valer para os usuários após publishVersion.
 */
async function createDraftVersion(documentId, { version, content, effectiveDate }, { adminUserId }) {
  const doc = await repository.findDocumentById(documentId);
  if (!doc) throw new NotFoundError('Documento não encontrado.');

  const created = await repository.createVersion({
    documentId,
    version,
    content,
    effectiveDate,
    createdBy: adminUserId,
  });

  return { id: created.id, version: created.version, effectiveDate: created.effective_date };
}

/**
 * Publica uma versão como vigente (docx Parte 7: "Alterações Jurídicas" —
 * cria nova versão, publica, e usuários que aceitaram a versão anterior de um
 * documento obrigatório passarão a precisar reaceitar, via
 * getPendingMandatoryAcceptances).
 */
async function publishVersion(documentId, versionId, { adminUserId, ipAddress }) {
  const doc = await repository.findDocumentById(documentId);
  if (!doc) throw new NotFoundError('Documento não encontrado.');

  const version = await repository.findVersionById(versionId);
  if (!version || version.document_id !== documentId) {
    throw new NotFoundError('Versão não encontrada para este documento.');
  }

  const updated = await repository.publishVersion(documentId, versionId);

  await auditLogRepository.insertAuditLog(db, {
    userId: adminUserId,
    action: AUDIT_EVENTS.DOCUMENT_UPDATED,
    entity: 'legal_documents',
    entityId: documentId,
    metadata: { type: doc.type, version: version.version },
    ipAddress,
  });

  const refreshedVersion = await repository.findVersionById(versionId);
  return mapDocumentSummary({
    ...updated,
    version: refreshedVersion.version,
    effective_date: refreshedVersion.effective_date,
    published_at: refreshedVersion.published_at,
  });
}

async function getAcceptanceStats(documentId) {
  const doc = await repository.findDocumentById(documentId);
  if (!doc) throw new NotFoundError('Documento não encontrado.');
  if (!doc.current_version_id) return { totalAccepted: 0, versionId: null };

  const count = await repository.countAcceptancesByVersion(doc.current_version_id);
  return { totalAccepted: count, versionId: doc.current_version_id };
}

async function listAcceptancesByDocument(documentId, { limit = 50, offset = 0 } = {}) {
  const doc = await repository.findDocumentById(documentId);
  if (!doc) throw new NotFoundError('Documento não encontrado.');
  const rows = await repository.listAcceptancesByDocument(documentId, { limit, offset });
  return rows.map((r) => ({
    userId: r.user_id,
    userName: r.user_name,
    userPhone: r.user_phone,
    version: r.version,
    acceptedAt: r.accepted_at,
    ipAddress: r.ip_address,
  }));
}

module.exports = {
  listDocuments,
  getDocumentByType,
  getPendingMandatoryAcceptances,
  hasPendingMandatoryAcceptance,
  acceptMandatoryDocuments,
  getMyAcceptances,
  getCookiePreferences,
  setCookiePreferences,
  createLegalRequest,
  listMyLegalRequests,
  listLegalRequestsAdmin,
  respondLegalRequest,
  createAppeal,
  listMyAppeals,
  listAppealsAdmin,
  decideAppeal,
  listDocumentsAdmin,
  listVersions,
  createDraftVersion,
  publishVersion,
  getAcceptanceStats,
  listAcceptancesByDocument,
};
