const { Router } = require('express');
const controller = require('../controllers/adminShopController');
const authenticate = require('../../../middleware/authenticate');
const requireRole = require('../../../middleware/requireRole');
const validate = require('../../../middleware/validate');
const { createItemSchema, updateItemSchema } = require('../validators/shopValidators');

const router = Router();

// Painel Administrativo — Moedas: "Criar recompensas; Criar loja; Controlar
// economia" (docx "SISTEMA DE ECONOMIA E RECOMPENSAS", Seção 14).
router.use(authenticate);
router.use(requireRole('admin_financeiro'));

router.get('/items', controller.listItems);
router.post('/items', validate(createItemSchema), controller.createItem);
router.post('/items/:itemId', validate(updateItemSchema), controller.updateItem);
router.get('/purchases', controller.listPurchases);

module.exports = router;
