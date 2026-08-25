const { ForbiddenError } = require('../common/errors/AppError');

/**
 * Middleware de autorização granular (substitui o requireAdmin binário da v1).
 * Papéis oficiais (migration 012): 'user', 'admin_master', 'admin_financeiro',
 * 'admin_suporte'. `admin_master` tem acesso total a qualquer rota que exija
 * um papel admin_* — não precisa ser listado explicitamente em cada rota.
 *
 * Uso: router.get('/withdrawals', requireRole('admin_financeiro'), ...)
 *      router.get('/audit-logs', requireRole('admin_financeiro', 'admin_suporte'), ...)
 */
function requireRole(...allowedRoles) {
  return (req, res, next) => {
    if (!req.user) {
      return next(new ForbiddenError('Acesso restrito.'));
    }
    if (req.user.role === 'admin_master') {
      return next(); // acesso total, sempre permitido em rotas admin_*
    }
    if (!allowedRoles.includes(req.user.role)) {
      return next(new ForbiddenError('Você não tem permissão para acessar este recurso.'));
    }
    return next();
  };
}

module.exports = requireRole;
