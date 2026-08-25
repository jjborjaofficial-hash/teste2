const { Router } = require('express');
const controller = require('../controllers/notificationsController');
const authenticate = require('../../../middleware/authenticate');

const router = Router();

router.get('/', authenticate, controller.listMine);
router.get('/unread-count', authenticate, controller.unreadCount);
router.post('/:notificationId/read', authenticate, controller.markAsRead);

module.exports = router;
