const { Router } = require('express');
const controller = require('../controllers/inventoryController');
const authenticate = require('../../../middleware/authenticate');

/**
 * Rotas de "Meus Recursos" (spec Seções 34-60) — consumíveis e itens
 * temporários com contagem regressiva. Montado em /api/v1/inventory,
 * separado de /api/v1/shop/inventory (que já existe e mostra histórico de
 * compras + itens permanentes equipados — propósito diferente, nomes
 * parecidos por coincidência).
 */

const router = Router();

router.use(authenticate);

router.get('/', controller.listInventory);
router.post('/:id/activate', controller.activate);
router.post('/:id/use', controller.use);

module.exports = router;
