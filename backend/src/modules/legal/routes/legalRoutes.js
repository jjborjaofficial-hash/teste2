const { Router } = require('express');
const controller = require('../controllers/legalController');
const authenticate = require('../../../middleware/authenticate');
const validate = require('../../../middleware/validate');
const {
  cookiePreferencesSchema,
  createLegalRequestSchema,
  createAppealSchema,
} = require('../validators/legalValidators');

const router = Router();

// --- Central Jurídica: pública, sem necessidade de login (docx Parte 3) ---
router.get('/documents', controller.listDocuments);
router.get('/documents/:type', controller.getDocument);

// --- Consentimento: exige login (docx Parte 5) ---
router.get('/pending', authenticate, controller.getPending);
router.post('/accept', authenticate, controller.acceptMandatory);
router.get('/my-acceptances', authenticate, controller.getMyAcceptances);

// --- Cookies (docx Parte 8) ---
router.get('/cookies', authenticate, controller.getCookiePreferences);
router.post('/cookies', authenticate, validate(cookiePreferencesSchema), controller.setCookiePreferences);

// --- Central de Reclamações (docx Parte 11.4) ---
router.post('/requests', authenticate, validate(createLegalRequestSchema), controller.createRequest);
router.get('/requests', authenticate, controller.listMyRequests);

// --- Sistema de Recursos e Contestação (docx Parte 12) ---
router.post('/appeals', authenticate, validate(createAppealSchema), controller.createAppeal);
router.get('/appeals', authenticate, controller.listMyAppeals);

module.exports = router;
