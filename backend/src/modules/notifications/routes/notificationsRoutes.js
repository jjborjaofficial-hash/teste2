const { Router } = require('express');
const controller = require('../controllers/notificationsController');
const authenticate = require('../../../middleware/authenticate');
const validate = require('../../../middleware/validate');
const { z } = require('zod');

const router = Router();

const pushTokenSchema = z.object({
  token: z.string().trim().min(10),
  platform: z.enum(['web', 'android', 'ios']).default('web'),
});
const unregisterSchema = z.object({ token: z.string().trim().min(10) });

router.get('/', authenticate, controller.listMine);
router.get('/unread-count', authenticate, controller.unreadCount);
router.post('/:notificationId/read', authenticate, controller.markAsRead);

// Preparação para push real (ver docs/notificacoes-push-sms.md) — o frontend
// já chama isso hoje; só fica sem efeito prático até FIREBASE_* existir.
router.post('/push-tokens', authenticate, validate(pushTokenSchema), controller.registerPushToken);
router.delete('/push-tokens', authenticate, validate(unregisterSchema), controller.unregisterPushToken);

module.exports = router;
