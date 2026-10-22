const { Router } = require('express');
const authenticate = require('../../middleware/authenticate');
const { authRateLimiter } = require('../../middleware/rateLimiter');
const service = require('./adminAccessService');

const router = Router();
router.use(authenticate);

const wrap = (fn) => async (req, res, next) => {
  try {
    res.json({ success: true, data: await fn(req) });
  } catch (err) {
    next(err);
  }
};

router.get('/status', wrap((req) => service.getStatus(req.user.id)));
router.post('/set-password', authRateLimiter, wrap((req) => service.setPassword(req.user.id, req.body || {})));
router.post('/unlock', authRateLimiter, wrap((req) => service.unlock(req.user.id, req.body || {})));

module.exports = router;
