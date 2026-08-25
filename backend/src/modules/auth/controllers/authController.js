const authService = require('../services/authService');
const {
  setRefreshTokenCookie,
  clearRefreshTokenCookie,
  readRefreshTokenCookie,
} = require('../services/refreshCookie');
const { UnauthorizedError } = require('../../../common/errors/AppError');

/**
 * Controller: camada fina, sem regra de negócio (Manual Parte 5).
 * Apenas traduz HTTP <-> Service e formata a resposta padronizada.
 *
 * O refresh token NUNCA é devolvido no corpo JSON — viaja só em cookie
 * httpOnly (ver refreshCookie.js), inacessível a JavaScript no navegador.
 */

function buildContext(req) {
  return {
    ipAddress: req.ip,
    userAgent: req.headers['user-agent'],
  };
}

function sanitizeAuthResult(result) {
  const { refreshToken, ...rest } = result;
  return rest;
}

async function register(req, res, next) {
  try {
    const { name, phone, password, isAdultDeclared } = req.validatedBody;
    const result = await authService.register(
      { name, phone, password, isAdultDeclared },
      buildContext(req)
    );

    setRefreshTokenCookie(res, result.refreshToken);

    return res.status(201).json({
      status: 'success',
      message: 'Conta criada com sucesso.',
      data: sanitizeAuthResult(result),
    });
  } catch (err) {
    return next(err);
  }
}

async function login(req, res, next) {
  try {
    const { phone, password } = req.validatedBody;
    const result = await authService.login({ phone, password }, buildContext(req));

    setRefreshTokenCookie(res, result.refreshToken);

    return res.status(200).json({
      status: 'success',
      message: 'Login realizado com sucesso.',
      data: sanitizeAuthResult(result),
    });
  } catch (err) {
    return next(err);
  }
}

async function refresh(req, res, next) {
  try {
    const refreshToken = readRefreshTokenCookie(req);
    if (!refreshToken) {
      throw new UnauthorizedError('Sessão não encontrada. Faça login novamente.');
    }

    const result = await authService.refresh({ refreshToken }, buildContext(req));

    setRefreshTokenCookie(res, result.refreshToken);

    return res.status(200).json({
      status: 'success',
      message: 'Token renovado com sucesso.',
      data: sanitizeAuthResult(result),
    });
  } catch (err) {
    clearRefreshTokenCookie(res);
    return next(err);
  }
}

async function logout(req, res, next) {
  try {
    const refreshToken = readRefreshTokenCookie(req);
    if (refreshToken) {
      await authService.logout({ refreshToken });
    }
    clearRefreshTokenCookie(res);

    return res.status(200).json({
      status: 'success',
      message: 'Logout realizado com sucesso.',
      data: null,
    });
  } catch (err) {
    return next(err);
  }
}

async function acceptTerms(req, res, next) {
  try {
    const result = await authService.acceptTerms(req.user.id, buildContext(req));
    return res.status(200).json({
      status: 'success',
      message: 'Termos aceitos com sucesso.',
      data: result,
    });
  } catch (err) {
    return next(err);
  }
}

module.exports = { register, login, refresh, logout, acceptTerms };
