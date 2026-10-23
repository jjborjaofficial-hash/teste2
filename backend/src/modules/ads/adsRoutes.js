const { Router } = require('express');
const service = require('./adsService');

const router = Router();

// Pública: o site precisa disto antes do login para mostrar anúncios.
router.get('/config', async (req, res, next) => {
  try {
    res.set('Cache-Control', 'public, max-age=60');
    res.json({ success: true, data: await service.publicConfig() });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
