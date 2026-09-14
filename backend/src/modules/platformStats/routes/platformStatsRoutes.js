const { Router } = require('express');
const controller = require('../controllers/platformStatsController');

// Rota pública, propositalmente sem authenticate: precisa estar visível
// no Onboarding (Doc. Mestre Seção 19.1), que acontece ANTES do login.
// Protegida mesmo assim pelo defaultRateLimiter global (app.js).
const router = Router();

router.get('/', controller.getPublicStats);

module.exports = router;
