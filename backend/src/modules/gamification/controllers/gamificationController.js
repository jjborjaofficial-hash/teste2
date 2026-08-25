const gamificationService = require('../services/gamificationService');

async function myStatus(req, res, next) {
  try {
    const data = await gamificationService.getMyStatus(req.user.id);
    return res.status(200).json({ status: 'success', message: null, data });
  } catch (err) {
    return next(err);
  }
}

module.exports = { myStatus };
