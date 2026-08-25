const { Router } = require('express');
const controller = require('../controllers/adminLegalController');
const authenticate = require('../../../middleware/authenticate');
const requireRole = require('../../../middleware/requireRole');
const validate = require('../../../middleware/validate');
const {
  createVersionSchema,
  respondLegalRequestSchema,
  decideAppealSchema,
} = require('../validators/legalValidators');

const router = Router();

// Painel Administrativo — Módulo Jurídico e Compliance (docx Parte 11).
// Exclusivo de admin_juridico (admin_master sempre tem acesso, via requireRole).
router.use(authenticate);
router.use(requireRole('admin_juridico'));

// --- Gestão de Documentos Jurídicos (docx Parte 11.1) ---
router.get('/documents', controller.listDocuments);
router.get('/documents/:documentId/versions', controller.listVersions);
router.post('/documents/:documentId/versions', validate(createVersionSchema), controller.createVersion);
router.post('/documents/:documentId/versions/:versionId/publish', controller.publishVersion);

// --- Gestão de Aceitações dos Usuários (docx Parte 11.2) ---
router.get('/documents/:documentId/acceptance-stats', controller.getAcceptanceStats);
router.get('/documents/:documentId/acceptances', controller.listAcceptances);

// --- Gestão de Reclamações (docx Parte 11.4) ---
router.get('/requests', controller.listRequests);
router.post('/requests/:requestId/respond', validate(respondLegalRequestSchema), controller.respondRequest);

// --- Sistema de Recursos e Contestação (docx Parte 12) ---
router.get('/appeals', controller.listAppeals);
router.post('/appeals/:appealId/decide', validate(decideAppealSchema), controller.decideAppeal);

module.exports = router;
