/**
 * Segundo passo de acesso ao Painel Administrativo: depois de entrar na conta normal, o administrador volta a
 * escrever o número e a senha no ecrã "Acesso de administrador". O desbloqueio vale 30 minutos, só neste separador
 * (sessionStorage). É uma barreira extra de uso; a segurança verdadeira continua no servidor (o papel vai no token).
 */
const KEY = 'adminUnlockedUntil';
const DURATION_MS = 30 * 60 * 1000;

export function isAdminRole(user) {
  return Boolean(user?.role && user.role.startsWith('admin_'));
}

export function unlockAdmin() {
  try {
    sessionStorage.setItem(KEY, String(Date.now() + DURATION_MS));
  } catch {
    // sem sessionStorage: o desbloqueio simplesmente não persiste
  }
}

export function lockAdmin() {
  try {
    sessionStorage.removeItem(KEY);
  } catch {
    // ignorar
  }
}

export function isAdminUnlocked() {
  try {
    return Number(sessionStorage.getItem(KEY) || 0) > Date.now();
  } catch {
    return false;
  }
}
