const { Router } = require('express');
const controller = require('../controllers/userController');
const authenticate = require('../../../middleware/authenticate');
const validate = require('../../../middleware/validate');
const { changePasswordSchema, updateProfileSchema, changePaymentPhoneSchema, deleteAccountSchema } = require('../validators');
const { createRateLimiter } = require('../../../middleware/rateLimiter');

const router = Router();

// Operações sensíveis (pedem senha): limite próprio contra tentativas em massa.
const sensitiveLimiter = createRateLimiter({ windowMs: 60 * 1000, max: Number(process.env.USERS_SENSITIVE_MAX) || 10, name: 'users-sensitive', message: 'Muitas tentativas. Aguarde 1 minuto.' });

router.get('/me', authenticate, controller.me);
router.patch('/me', authenticate, validate(updateProfileSchema), controller.updateMe);
router.put('/me/password', authenticate, sensitiveLimiter, validate(changePasswordSchema), controller.changePassword);
router.put('/me/payment-phone', authenticate, sensitiveLimiter, validate(changePaymentPhoneSchema), controller.changePaymentPhone);
router.get('/me/export', authenticate, sensitiveLimiter, controller.exportMe);
router.delete('/me', authenticate, sensitiveLimiter, validate(deleteAccountSchema), controller.deleteMe);

module.exports = router;
