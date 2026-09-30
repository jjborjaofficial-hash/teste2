const gamificationService = require('../services/gamificationService');
const welcomeBonusService = require('../services/welcomeBonusService');

async function myStatus(req, res, next) {
  try {
    const data = await gamificationService.getMyStatus(req.user.id);
    return res.status(200).json({ status: 'success', message: null, data });
  } catch (err) {
    return next(err);
  }
}

async function welcomeBonus(req, res, next) {
  try {
    const data = await welcomeBonusService.getStatus(req.user.id);
    return res.status(200).json({ status: 'success', message: null, data });
  } catch (err) {
    return next(err);
  }
}

async function claimWelcomeBonus(req, res, next) {
  try {
    const data = await welcomeBonusService.claimToday(req.user.id);
    return res.status(200).json({ status: 'success', message: null, data });
  } catch (err) {
    return next(err);
  }
}

module.exports = { myStatus, welcomeBonus, claimWelcomeBonus };
