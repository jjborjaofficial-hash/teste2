const referralsService = require('../services/referralsService');

async function myCode(req, res, next) {
  try {
    const code = await referralsService.getOrCreateMyCode(req.user.id);
    return res.status(200).json({ status: 'success', message: null, data: { code } });
  } catch (err) {
    return next(err);
  }
}

async function myReferrals(req, res, next) {
  try {
    const referrals = await referralsService.listMyReferrals(req.user.id);
    return res.status(200).json({ status: 'success', message: null, data: referrals });
  } catch (err) {
    return next(err);
  }
}

module.exports = { myCode, myReferrals };
