const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const db = require('../../config/database');
const logger = require('../../common/logger');
const { UnauthorizedError, ForbiddenError, BusinessRuleError } = require('../../common/errors/AppError');

/**
 * Acesso ao Painel Administrativo com SENHA PRÓPRIA do administrador (diferente da senha de login normal).
 * Fluxo: conta normal entra; no Perfil, o ícone de admin (só papéis admin_*) leva ao ecrã de acesso. Na 1.ª vez
 * cria a senha de admin (confirmando a senha normal); depois confirma número OU email da conta + senha de admin e
 * recebe um token de acesso de admin (30 min) que vai no cabeçalho X-Admin-Access das rotas /admin/*.
 */

const ACCESS_MINUTES = 30;
const MIN_ADMIN_PASSWORD = 10;
const PURPOSE = 'admin-access';

async function loadAdmin(userId) {
  const { rows } = await db.query(
    `SELECT id, phone, email, email_normalized, role, password_hash, admin_password_hash
     FROM users WHERE id = $1 AND deleted_at IS NULL`,
    [userId]
  );
  const user = rows[0];
  if (!user || !user.role || !user.role.startsWith('admin_')) {
    throw new ForbiddenError('Esta conta não é de administrador.');
  }
  return user;
}

function signAccessToken(userId) {
  return {
    adminAccessToken: jwt.sign({ sub: userId, purpose: PURPOSE }, process.env.JWT_ACCESS_SECRET, {
      expiresIn: `${ACCESS_MINUTES}m`,
    }),
    expiresInMinutes: ACCESS_MINUTES,
  };
}

function matchesIdentifier(user, identifier) {
  const raw = String(identifier || '').trim().toLowerCase();
  if (!raw) return false;
  if (raw.includes('@')) {
    const mail = (user.email_normalized || user.email || '').toLowerCase();
    return mail !== '' && raw === mail;
  }
  const digits = raw.replace(/\D/g, '').replace(/^258/, '');
  return digits !== '' && user.phone && digits === String(user.phone).replace(/\D/g, '').replace(/^258/, '');
}

async function getStatus(userId) {
  const user = await loadAdmin(userId);
  return { adminPasswordSet: Boolean(user.admin_password_hash) };
}

/** Cria a senha de admin (1.ª vez) ou troca-a (exige a senha de admin atual). Sempre confirma a senha NORMAL. */
async function setPassword(userId, { currentPassword, adminPassword, currentAdminPassword }) {
  const user = await loadAdmin(userId);
  if (!user.password_hash || !(await bcrypt.compare(String(currentPassword || ''), user.password_hash))) {
    throw new UnauthorizedError('A senha normal da conta não está correta.');
  }
  if (user.admin_password_hash) {
    if (!(await bcrypt.compare(String(currentAdminPassword || ''), user.admin_password_hash))) {
      throw new UnauthorizedError('A senha de administrador atual não está correta.');
    }
  }
  const next = String(adminPassword || '');
  if (next.length < MIN_ADMIN_PASSWORD) {
    throw new BusinessRuleError(`A senha de administrador precisa de pelo menos ${MIN_ADMIN_PASSWORD} caracteres.`);
  }
  if (await bcrypt.compare(next, user.password_hash)) {
    throw new BusinessRuleError('A senha de administrador tem de ser diferente da senha de login normal.');
  }
  const hash = await bcrypt.hash(next, 12);
  await db.query('UPDATE users SET admin_password_hash = $1 WHERE id = $2', [hash, userId]);
  logger.info('Senha de administrador definida', { userId });
  return signAccessToken(userId);
}

async function unlock(userId, { identifier, adminPassword }) {
  const user = await loadAdmin(userId);
  if (!user.admin_password_hash) {
    throw new BusinessRuleError('Ainda não definiu a senha de administrador.');
  }
  const idOk = matchesIdentifier(user, identifier);
  const pwOk = await bcrypt.compare(String(adminPassword || ''), user.admin_password_hash);
  if (!idOk || !pwOk) {
    logger.warn('Falha no acesso de administrador', { userId });
    throw new UnauthorizedError('Número/email ou senha de administrador incorretos.');
  }
  return signAccessToken(userId);
}

module.exports = { getStatus, setPassword, unlock, PURPOSE };
