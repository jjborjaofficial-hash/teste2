const { Router } = require('express');
const controller = require('../controllers/rankingController');
const authenticate = require('../../../middleware/authenticate');

const router = Router();

router.get('/weekly', authenticate, controller.topRanking);
router.get('/weekly/me', authenticate, controller.myPosition);

module.exports = router;
