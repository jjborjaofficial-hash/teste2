/**
 * Cookie httpOnly do refresh token (correção de segurança — antes o refresh
 * token de 30 dias era devolvido no corpo JSON e guardado em `localStorage`
 * pelo frontend, acessível a qualquer script rodando na página; um XSS,
 * mesmo pequeno, roubava uma sessão de longa duração inteira).
 *
 * Agora o refresh token nunca é exposto ao JavaScript do cliente: viaja só
 * dentro de um cookie httpOnly + Secure + SameSite, que o navegador anexa
 * automaticamente às requisições para a API e que nenhum script consegue ler.
 */

const COOKIE_NAME = 'aeg_refresh_token';

function refreshTokenMaxAgeMs() {
  const days = parseInt((process.env.JWT_REFRESH_EXPIRES_IN || '30d').replace('d', ''), 10) || 30;
  return days * 24 * 60 * 60 * 1000;
}

function cookieOptions() {
  return {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production', // exige HTTPS em produção
    sameSite: 'strict',
    domain: process.env.COOKIE_DOMAIN || undefined,
    path: '/api/v1/auth', // só é enviado para as próprias rotas de autenticação
    maxAge: refreshTokenMaxAgeMs(),
  };
}

function setRefreshTokenCookie(res, refreshToken) {
  res.cookie(COOKIE_NAME, refreshToken, cookieOptions());
}

function clearRefreshTokenCookie(res) {
  res.clearCookie(COOKIE_NAME, { ...cookieOptions(), maxAge: undefined });
}

function readRefreshTokenCookie(req) {
  return req.cookies ? req.cookies[COOKIE_NAME] : undefined;
}

module.exports = { COOKIE_NAME, setRefreshTokenCookie, clearRefreshTokenCookie, readRefreshTokenCookie };
