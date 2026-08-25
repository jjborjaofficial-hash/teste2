const rankingService = require('../services/rankingService');

async function topRanking(req, res, next) {
  try {
    const limit = Math.min(Number(req.query.limit) || 20, 50);
    const ranking = await rankingService.getTopRanking(limit);
    return res.status(200).json({ status: 'success', message: null, data: ranking });
  } catch (err) {
    return next(err);
  }
}

async function myPosition(req, res, next) {
  try {
    const position = await rankingService.getMyPosition(req.user.id);
    return res.status(200).json({ status: 'success', message: null, data: position });
  } catch (err) {
    return next(err);
  }
}

module.exports = { topRanking, myPosition };
