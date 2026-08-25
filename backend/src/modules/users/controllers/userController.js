const userService = require('../services/userService');

async function me(req, res, next) {
  try {
    const profile = await userService.getProfile(req.user.id);
    return res.status(200).json({ status: 'success', message: null, data: profile });
  } catch (err) {
    return next(err);
  }
}

module.exports = { me };
