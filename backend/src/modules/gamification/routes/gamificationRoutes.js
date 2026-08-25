const { Router } = require('express');
const controller = require('../controllers/gamificationController');
const authenticate = require('../../../middleware/authenticate');

const router = Router();

router.get('/me', authenticate, controller.myStatus);

module.exports = router;
