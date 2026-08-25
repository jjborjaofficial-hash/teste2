const { Router } = require('express');
const controller = require('../controllers/userController');
const authenticate = require('../../../middleware/authenticate');

const router = Router();

router.get('/me', authenticate, controller.me);

module.exports = router;
