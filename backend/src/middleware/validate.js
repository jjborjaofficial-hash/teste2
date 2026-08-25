const { ValidationError } = require('../common/errors/AppError');

/**
 * Middleware transversal de validação (Manual Parte 5).
 * Recebe um schema Zod e valida req.body antes de qualquer processamento de negócio.
 */
function validate(schema) {
  return (req, res, next) => {
    const result = schema.safeParse(req.body);

    if (!result.success) {
      const details = result.error.issues.map((issue) => ({
        field: issue.path.join('.'),
        message: issue.message,
      }));
      return next(new ValidationError('Dados inválidos', details));
    }

    req.validatedBody = result.data;
    return next();
  };
}

module.exports = validate;
