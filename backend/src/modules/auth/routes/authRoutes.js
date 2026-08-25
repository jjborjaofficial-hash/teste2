const { Router } = require('express');
const controller = require('../controllers/authController');
const validate = require('../../../middleware/validate');
const authenticate = require('../../../middleware/authenticate');
const { authRateLimiter } = require('../../../middleware/rateLimiter');
const { registerSchema, loginSchema } = require('../validators/authValidators');

const router = Router();

// Todas as rotas de autenticação usam rate limiting rígido (Manual Parte 5: Middleware)
router.post('/register', authRateLimiter, validate(registerSchema), controller.register);
router.post('/login', authRateLimiter, validate(loginSchema), controller.login);
// /refresh e /logout não recebem mais refreshToken no body — vem do cookie
// httpOnly (ver refreshCookie.js), lido direto no controller.
router.post('/refresh', authRateLimiter, controller.refresh);
router.post('/logout', controller.logout);
router.post('/accept-terms', authenticate, controller.acceptTerms);

module.exports = router;
