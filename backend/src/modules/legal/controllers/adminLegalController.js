const legalService = require('../services/legalService');

/**
 * Controller: endpoints do Painel Administrativo — Módulo Jurídico e Compliance
 * (docx Parte 11). Acesso restrito via requireRole('admin_juridico') nas rotas.
 */

function ctx(req) {
  return { adminUserId: req.user.id, ipAddress: req.ip };
}

// GET /admin/legal/documents
async function listDocuments(req, res, next) {
  try {
    const documents = await legalService.listDocumentsAdmin();
    return res.status(200).json({ status: 'success', message: null, data: documents });
  } catch (err) {
    return next(err);
  }
}

// GET /admin/legal/documents/:documentId/versions
async function listVersions(req, res, next) {
  try {
    const versions = await legalService.listVersions(req.params.documentId);
    return res.status(200).json({ status: 'success', message: null, data: versions });
  } catch (err) {
    return next(err);
  }
}

// POST /admin/legal/documents/:documentId/versions — cria versão em rascunho
async function createVersion(req, res, next) {
  try {
    const created = await legalService.createDraftVersion(req.params.documentId, req.validatedBody, ctx(req));
    return res.status(201).json({ status: 'success', message: 'Nova versão criada como rascunho.', data: created });
  } catch (err) {
    return next(err);
  }
}

// POST /admin/legal/documents/:documentId/versions/:versionId/publish
async function publishVersion(req, res, next) {
  try {
    const published = await legalService.publishVersion(req.params.documentId, req.params.versionId, ctx(req));
    return res.status(200).json({ status: 'success', message: 'Versão publicada como vigente.', data: published });
  } catch (err) {
    return next(err);
  }
}

// GET /admin/legal/documents/:documentId/acceptance-stats
async function getAcceptanceStats(req, res, next) {
  try {
    const stats = await legalService.getAcceptanceStats(req.params.documentId);
    return res.status(200).json({ status: 'success', message: null, data: stats });
  } catch (err) {
    return next(err);
  }
}

// GET /admin/legal/documents/:documentId/acceptances
async function listAcceptances(req, res, next) {
  try {
    const limit = Math.min(Number(req.query.limit) || 50, 200);
    const offset = Number(req.query.offset) || 0;
    const rows = await legalService.listAcceptancesByDocument(req.params.documentId, { limit, offset });
    return res.status(200).json({ status: 'success', message: null, data: rows });
  } catch (err) {
    return next(err);
  }
}

// GET /admin/legal/requests — Central de Reclamações (visão admin)
async function listRequests(req, res, next) {
  try {
    const limit = Math.min(Number(req.query.limit) || 20, 100);
    const offset = Number(req.query.offset) || 0;
    const status = req.query.status;
    const requests = await legalService.listLegalRequestsAdmin({ status, limit, offset });
    return res.status(200).json({ status: 'success', message: null, data: requests });
  } catch (err) {
    return next(err);
  }
}

// POST /admin/legal/requests/:requestId/respond
async function respondRequest(req, res, next) {
  try {
    const updated = await legalService.respondLegalRequest(req.params.requestId, req.validatedBody, ctx(req));
    return res.status(200).json({ status: 'success', message: 'Reclamação atualizada.', data: updated });
  } catch (err) {
    return next(err);
  }
}

// GET /admin/legal/appeals — Sistema de Recursos (visão admin)
async function listAppeals(req, res, next) {
  try {
    const limit = Math.min(Number(req.query.limit) || 20, 100);
    const offset = Number(req.query.offset) || 0;
    const status = req.query.status;
    const appeals = await legalService.listAppealsAdmin({ status, limit, offset });
    return res.status(200).json({ status: 'success', message: null, data: appeals });
  } catch (err) {
    return next(err);
  }
}

// POST /admin/legal/appeals/:appealId/decide
async function decideAppeal(req, res, next) {
  try {
    const decided = await legalService.decideAppeal(req.params.appealId, req.validatedBody, ctx(req));
    return res.status(200).json({ status: 'success', message: 'Recurso decidido.', data: decided });
  } catch (err) {
    return next(err);
  }
}

module.exports = {
  listDocuments,
  listVersions,
  createVersion,
  publishVersion,
  getAcceptanceStats,
  listAcceptances,
  listRequests,
  respondRequest,
  listAppeals,
  decideAppeal,
};
