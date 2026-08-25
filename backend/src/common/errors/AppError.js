/**
 * Erro padronizado da aplicação (Manual Parte 5: Tratamento de Erros).
 * Toda rota deve lançar AppError (ou subclasses) em vez de erros genéricos,
 * garantindo que nenhum detalhe técnico interno vaze para o usuário final.
 */
class AppError extends Error {
  constructor(message, statusCode = 500, code = 'INTERNAL_ERROR', details = null) {
    super(message);
    this.name = this.constructor.name;
    this.statusCode = statusCode;
    this.code = code;
    this.details = details;
    this.isOperational = true; // erro esperado/tratado, não um bug de sistema
    Error.captureStackTrace(this, this.constructor);
  }
}

class ValidationError extends AppError {
  constructor(message = 'Dados inválidos', details = null) {
    super(message, 400, 'VALIDATION_ERROR', details);
  }
}

class UnauthorizedError extends AppError {
  constructor(message = 'Não autenticado') {
    super(message, 401, 'UNAUTHORIZED');
  }
}

class ForbiddenError extends AppError {
  constructor(message = 'Não autorizado') {
    super(message, 403, 'FORBIDDEN');
  }
}

class NotFoundError extends AppError {
  constructor(message = 'Recurso não encontrado') {
    super(message, 404, 'NOT_FOUND');
  }
}

class ConflictError extends AppError {
  constructor(message = 'Conflito de dados') {
    super(message, 409, 'CONFLICT');
  }
}

class BusinessRuleError extends AppError {
  constructor(message = 'Regra de negócio violada', details = null) {
    super(message, 422, 'BUSINESS_RULE_VIOLATION', details);
  }
}

class RateLimitError extends AppError {
  constructor(message = 'Limite de requisições excedido') {
    super(message, 429, 'RATE_LIMIT_EXCEEDED');
  }
}

module.exports = {
  AppError,
  ValidationError,
  UnauthorizedError,
  ForbiddenError,
  NotFoundError,
  ConflictError,
  BusinessRuleError,
  RateLimitError,
};
