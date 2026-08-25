const jwt = require('jsonwebtoken');
const { UnauthorizedError } = require('../common/errors/AppError');

/**
 * Middleware transversal de autenticação (Manual Parte 5).
 * Extrai e valida o Bearer token, injetando req.user = { id, trustScore, status }.
 */
function authenticate(req, res, next) {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return next(new UnauthorizedError('Token de acesso não fornecido'));
  }

  const token = authHeader.split(' ')[1];

  try {
    const payload = jwt.verify(token, process.env.JWT_ACCESS_SECRET);
    req.user = { id: payload.sub, trustScore: payload.trustScore, status: payload.status, role: payload.role || 'user' };
    return next();
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      return next(new UnauthorizedError('Token de acesso expirado'));
    }
    return next(new UnauthorizedError('Token de acesso inválido'));
  }
}

module.exports = authenticate;
