const { Router } = require('express');
const controller = require('../controllers/shopController');
const authenticate = require('../../../middleware/authenticate');
const validate = require('../../../middleware/validate');
const { purchaseSchema, equipSchema, unequipSchema } = require('../validators/shopValidators');

const router = Router();

router.use(authenticate);

router.get('/items', controller.listItems);
router.post('/purchase', validate(purchaseSchema), controller.purchase);
router.post('/equip', validate(equipSchema), controller.equip);
router.post('/unequip', validate(unequipSchema), controller.unequip);
router.get('/inventory', controller.getMyInventory);
router.get('/points-ledger', controller.getMyPointsLedger);

module.exports = router;
