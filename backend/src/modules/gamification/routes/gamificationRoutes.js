const { Router } = require('express');
const controller = require('../controllers/gamificationController');
const authenticate = require('../../../middleware/authenticate');

const router = Router();

router.get('/me', authenticate, controller.myStatus);
router.get('/welcome-bonus', authenticate, controller.welcomeBonus);

module.exports = router;
