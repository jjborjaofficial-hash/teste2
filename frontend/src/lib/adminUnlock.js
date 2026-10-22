/**
 * Acesso ao Painel Administrativo: o servidor emite um token de acesso de admin (30 min) depois de o administrador
 * confirmar número ou email + a SENHA DE ADMINISTRADOR (diferente da senha de login). Fica em sessionStorage (só
 * neste separador) e vai no cabeçalho X-Admin-Access das chamadas /admin/* (ver api/client.js).
 */
const KEY = 'adminAccessToken';
const KEY_UNTIL = 'adminAccessUntil';

export function isAdminRole(user) {
  return Boolean(user?.role && user.role.startsWith('admin_'));
}

export function unlockAdmin({ adminAccessToken, expiresInMinutes = 30 }) {
  try {
    sessionStorage.setItem(KEY, adminAccessToken);
    sessionStorage.setItem(KEY_UNTIL, String(Date.now() + expiresInMinutes * 60 * 1000));
  } catch {
    // sem sessionStorage: o acesso não persiste
  }
}

export function lockAdmin() {
  try {
    sessionStorage.removeItem(KEY);
    sessionStorage.removeItem(KEY_UNTIL);
  } catch {
    // ignorar
  }
}

export function getAdminAccessToken() {
  try {
    if (Number(sessionStorage.getItem(KEY_UNTIL) || 0) <= Date.now()) return null;
    return sessionStorage.getItem(KEY);
  } catch {
    return null;
  }
}

export function isAdminUnlocked() {
  return Boolean(getAdminAccessToken());
}
