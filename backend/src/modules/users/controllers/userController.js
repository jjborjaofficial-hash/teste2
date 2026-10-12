const userService = require('../services/userService');
const { clearRefreshTokenCookie } = require('../../auth/services/refreshCookie');

const ok = (res, data, status = 200) => res.status(status).json({ status: 'success', message: null, data });
const ctx = (req) => ({ ipAddress: req.ip });

async function me(req, res, next) {
  try { return ok(res, await userService.getProfile(req.user.id)); } catch (e) { return next(e); }
}
async function updateMe(req, res, next) {
  try { return ok(res, await userService.updateProfile(req.user.id, req.validatedBody, ctx(req))); } catch (e) { return next(e); }
}
async function changePaymentPhone(req, res, next) {
  try { return ok(res, await userService.changePaymentPhone(req.user.id, req.validatedBody, ctx(req))); } catch (e) { return next(e); }
}
async function exportMe(req, res, next) {
  try {
    const data = await userService.exportMyData(req.user.id, ctx(req));
    res.setHeader('Content-Disposition', 'attachment; filename="meus-dados.json"');
    return ok(res, data);
  } catch (e) { return next(e); }
}
async function deleteMe(req, res, next) {
  try {
    const out = await userService.deleteAccount(req.user.id, req.validatedBody, ctx(req));
    clearRefreshTokenCookie(res);
    return ok(res, out);
  } catch (e) { return next(e); }
}

module.exports = { me, updateMe, changePaymentPhone, exportMe, deleteMe };
