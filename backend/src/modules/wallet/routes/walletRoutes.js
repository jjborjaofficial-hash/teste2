const { Router } = require('express');
const controller = require('../controllers/walletController');
const authenticate = require('../../../middleware/authenticate');
const validate = require('../../../middleware/validate');
const { withdrawalSchema } = require('../validators/walletValidators');

const router = Router();

router.get('/', authenticate, controller.getBalance);
router.get('/transactions', authenticate, controller.getHistory);
router.post('/withdrawals', authenticate, validate(withdrawalSchema), controller.requestWithdrawal);

module.exports = router;
