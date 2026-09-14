const { Router } = require('express');
const controller = require('../controllers/walletController');
const authenticate = require('../../../middleware/authenticate');
const validate = require('../../../middleware/validate');
const { withdrawalSchema, conversionSchema } = require('../validators/walletValidators');

const router = Router();

router.get('/', authenticate, controller.getBalance);
router.get('/transactions', authenticate, controller.getHistory);
router.post('/withdrawals', authenticate, validate(withdrawalSchema), controller.requestWithdrawal);
router.get('/convert-points/rate', authenticate, controller.getConversionRate);
router.post('/convert-points', authenticate, validate(conversionSchema), controller.convertPoints);

module.exports = router;
