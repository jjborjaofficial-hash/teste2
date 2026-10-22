const jwt = require('jsonwebtoken');
const db = require('../config/database');
const { ForbiddenError } = require('../common/errors/AppError');

/**
 * Exige o token de acesso de administrador (cabeçalho X-Admin-Access, emitido por /admin-access/unlock) nas rotas
 * /admin/*, mas só quando a conta já definiu a senha de administrador (admin_password_hash). Assim contas admin
 * ainda sem senha própria (e os testes) continuam a funcionar como antes; o ecrã obriga a criar a senha na 1.ª vez.
 * Corre depois de `authenticate`.
 */
async function requireAdminAccess(req, res, next) {
  try {
    if (!req.user) return next(new ForbiddenError('Acesso restrito.'));
    const { rows } = await db.query('SELECT admin_password_hash IS NOT NULL AS has_pw FROM users WHERE id = $1', [
      req.user.id,
    ]);
    if (!rows[0] || !rows[0].has_pw) return next();

    const token = req.headers['x-admin-access'];
    if (!token) return next(new ForbiddenError('Confirme o acesso de administrador.'));
    const payload = jwt.verify(token, process.env.JWT_ACCESS_SECRET);
    if (payload.purpose !== 'admin-access' || payload.sub !== req.user.id) {
      return next(new ForbiddenError('Confirme o acesso de administrador.'));
    }
    return next();
  } catch {
    return next(new ForbiddenError('Acesso de administrador expirado. Confirme novamente.'));
  }
}

module.exports = requireAdminAccess;
