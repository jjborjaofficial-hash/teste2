const { Router } = require('express');
const controller = require('../controllers/authController');
const validate = require('../../../middleware/validate');
const authenticate = require('../../../middleware/authenticate');
const { authRateLimiter, refreshRateLimiter, registerRateLimiter } = require('../../../middleware/rateLimiter');
const {
  registerSchema,
  loginSchema,
  googleLoginSchema,
  linkGoogleSchema,
  recoverWithGoogleSchema,
  completeProfileSchema,
} = require('../validators/authValidators');

const router = Router();

// Todas as rotas de autenticação usam rate limiting rígido (Manual Parte 5: Middleware)
router.post('/register', registerRateLimiter, validate(registerSchema), controller.register);
router.post('/login', authRateLimiter, validate(loginSchema), controller.login);
router.post('/google', authRateLimiter, validate(googleLoginSchema), controller.googleLogin);
// Recuperação de conta sem SMS: o Google ligado antes prova quem é a pessoa.
router.post('/link-google', authenticate, authRateLimiter, validate(linkGoogleSchema), controller.linkGoogle);
router.post('/recover-with-google', authRateLimiter, validate(recoverWithGoogleSchema), controller.recoverWithGoogle);
// Pedida logo após o primeiro login via Google (conta nasce sem telefone).
router.post(
  '/complete-profile',
  authenticate,
  authRateLimiter,
  validate(completeProfileSchema),
  controller.completeProfile
);
// /refresh e /logout não recebem mais refreshToken no body — vem do cookie
// httpOnly (ver refreshCookie.js), lido direto no controller.
router.post('/refresh', refreshRateLimiter, controller.refresh);
router.post('/logout', controller.logout);
router.post('/accept-terms', authenticate, controller.acceptTerms);

module.exports = router;
