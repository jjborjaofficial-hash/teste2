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

// SameSite do cookie: 'strict' (padrão) quando frontend e backend estão no mesmo
// site. Se estiverem em endereços diferentes (ex.: dois subdomínios de
// onrender.com, que o navegador trata como sites distintos), o cookie não seria
// enviado e a sessão se perderia ao recarregar a página: nesse caso defina
// COOKIE_SAMESITE=none (o cookie continua httpOnly e, com 'none', sempre Secure).
function resolveSameSite() {
  const value = String(process.env.COOKIE_SAMESITE || 'strict').toLowerCase();
  return ['strict', 'lax', 'none'].includes(value) ? value : 'strict';
}

function cookieOptions() {
  const sameSite = resolveSameSite();
  return {
    httpOnly: true,
    // exige HTTPS em produção; SameSite=None só é aceito pelo navegador com Secure
    secure: process.env.NODE_ENV === 'production' || sameSite === 'none',
    sameSite,
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
