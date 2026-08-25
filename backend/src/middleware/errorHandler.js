const logger = require('../common/logger');
const { AppError } = require('../common/errors/AppError');

/**
 * Handler central de erros (Manual Parte 5).
 * Formato de resposta padronizado: { status, message, errors }.
 * Nenhum erro interno expõe stack trace ou detalhes técnicos ao usuário final.
 */
// eslint-disable-next-line no-unused-vars
function errorHandler(err, req, res, next) {
  const isAppError = err instanceof AppError;
  const statusCode = isAppError ? err.statusCode : 500;

  if (!isAppError || statusCode >= 500) {
    logger.error('Erro não tratado ou erro de sistema', {
      message: err.message,
      stack: err.stack,
      path: req.path,
      method: req.method,
      userId: req.user ? req.user.id : null,
    });
  }

  res.status(statusCode).json({
    status: 'error',
    message: isAppError ? err.message : 'Erro interno do servidor. Tente novamente mais tarde.',
    code: isAppError ? err.code : 'INTERNAL_ERROR',
    errors: isAppError ? err.details : null,
  });
}

module.exports = errorHandler;
