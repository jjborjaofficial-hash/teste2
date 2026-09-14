const platformStatsService = require('../services/platformStatsService');

async function getPublicStats(req, res, next) {
  try {
    const stats = await platformStatsService.getPlatformStats();
    return res.status(200).json({ status: 'success', message: null, data: stats });
  } catch (err) {
    return next(err);
  }
}

module.exports = { getPublicStats };
