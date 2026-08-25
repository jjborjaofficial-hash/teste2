const { Router } = require('express');
const controller = require('../controllers/referralsController');
const authenticate = require('../../../middleware/authenticate');

const router = Router();

router.get('/me/code', authenticate, controller.myCode);
router.get('/me', authenticate, controller.myReferrals);

module.exports = router;
