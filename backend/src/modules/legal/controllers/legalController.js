const legalService = require('../services/legalService');

/**
 * Controller: camada fina, sem regra de negócio (Manual Parte 5).
 * Endpoints públicos e de usuário autenticado do Módulo Jurídico.
 */

function ctx(req) {
  return { ipAddress: req.ip, userAgent: req.headers['user-agent'] };
}

// GET /legal/documents — lista os 6 documentos da Central Jurídica com metadados
async function listDocuments(req, res, next) {
  try {
    const documents = await legalService.listDocuments();
    return res.status(200).json({ status: 'success', message: null, data: documents });
  } catch (err) {
    return next(err);
  }
}

// GET /legal/documents/:type — conteúdo completo de um documento
async function getDocument(req, res, next) {
  try {
    const document = await legalService.getDocumentByType(req.params.type);
    return res.status(200).json({ status: 'success', message: null, data: document });
  } catch (err) {
    return next(err);
  }
}

// GET /legal/pending — documentos obrigatórios ainda não aceitos pelo usuário logado
async function getPending(req, res, next) {
  try {
    const pending = await legalService.getPendingMandatoryAcceptances(req.user.id);
    return res.status(200).json({ status: 'success', message: null, data: pending });
  } catch (err) {
    return next(err);
  }
}

// POST /legal/accept — aceita todos os documentos obrigatórios vigentes (reaceite)
async function acceptMandatory(req, res, next) {
  try {
    const accepted = await legalService.acceptMandatoryDocuments(req.user.id, ctx(req));
    return res.status(200).json({ status: 'success', message: 'Documentos aceitos com sucesso.', data: accepted });
  } catch (err) {
    return next(err);
  }
}

// GET /legal/my-acceptances — histórico de consentimento do próprio usuário
async function getMyAcceptances(req, res, next) {
  try {
    const rows = await legalService.getMyAcceptances(req.user.id);
    return res.status(200).json({ status: 'success', message: null, data: rows });
  } catch (err) {
    return next(err);
  }
}

// GET /legal/cookies
async function getCookiePreferences(req, res, next) {
  try {
    const prefs = await legalService.getCookiePreferences(req.user.id);
    return res.status(200).json({ status: 'success', message: null, data: prefs });
  } catch (err) {
    return next(err);
  }
}

// POST /legal/cookies
async function setCookiePreferences(req, res, next) {
  try {
    const saved = await legalService.setCookiePreferences(req.user.id, req.validatedBody, ctx(req));
    return res.status(200).json({ status: 'success', message: 'Preferências de cookies salvas.', data: saved });
  } catch (err) {
    return next(err);
  }
}

// POST /legal/requests — Central de Reclamações
async function createRequest(req, res, next) {
  try {
    const request = await legalService.createLegalRequest(req.user.id, req.validatedBody, ctx(req));
    return res.status(201).json({ status: 'success', message: 'Reclamação registrada com sucesso.', data: request });
  } catch (err) {
    return next(err);
  }
}

// GET /legal/requests — minhas reclamações
async function listMyRequests(req, res, next) {
  try {
    const requests = await legalService.listMyLegalRequests(req.user.id);
    return res.status(200).json({ status: 'success', message: null, data: requests });
  } catch (err) {
    return next(err);
  }
}

// POST /legal/appeals — Sistema de Recursos e Contestação
async function createAppeal(req, res, next) {
  try {
    const appeal = await legalService.createAppeal(req.user.id, req.validatedBody, ctx(req));
    return res.status(201).json({ status: 'success', message: 'Recurso registrado. Guarde o protocolo.', data: appeal });
  } catch (err) {
    return next(err);
  }
}

// GET /legal/appeals — meus recursos
async function listMyAppeals(req, res, next) {
  try {
    const appeals = await legalService.listMyAppeals(req.user.id);
    return res.status(200).json({ status: 'success', message: null, data: appeals });
  } catch (err) {
    return next(err);
  }
}

module.exports = {
  listDocuments,
  getDocument,
  getPending,
  acceptMandatory,
  getMyAcceptances,
  getCookiePreferences,
  setCookiePreferences,
  createRequest,
  listMyRequests,
  createAppeal,
  listMyAppeals,
};
