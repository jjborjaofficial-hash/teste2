const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const repository = require('../repositories/authRepository');
const referralsService = require('../../referrals/services/referralsService');
const legalService = require('../../legal/services/legalService');
const userCache = require('../../../common/cache/userCache');
const {
  ConflictError,
  UnauthorizedError,
  ForbiddenError,
} = require('../../../common/errors/AppError');

// Versionamento dos Termos deixou de ser uma constante fixa: agora vive no
// Módulo Jurídico (legal_documents / legal_document_versions), gerenciável
// pelo Painel Administrativo sem precisar de deploy (docx "final jur..",
// Partes 6 e 11.1). users.terms_version é mantido apenas como cache de leitura
// rápida, sincronizado a cada aceite.

/**
 * Service: toda a regra de negócio do módulo de Autenticação (Manual Parte 5).
 * O backend é sempre a autoridade final — nenhuma regra é confiada ao cliente.
 */

function detectPhoneProvider(phone) {
  const prefix = phone.slice(0, 2);
  if (['84', '85'].includes(prefix)) return 'mpesa';
  if (['86', '87'].includes(prefix)) return 'emola';
  return null; // já barrado pela validação de entrada, mas defensivo
}

function hashToken(token) {
  return crypto.createHash('sha256').update(token).digest('hex');
}

function generateAccessToken(user) {
  return jwt.sign(
    { sub: user.id, trustScore: user.trust_score, status: user.status, role: user.role || 'user' },
    process.env.JWT_ACCESS_SECRET,
    { expiresIn: process.env.JWT_ACCESS_EXPIRES_IN || '15m' }
  );
}

function generateRefreshToken() {
  // Refresh token opaco (não-JWT), armazenado como hash — reduz superfície de ataque.
  return crypto.randomBytes(48).toString('hex');
}

function refreshExpiryDate() {
  const days = parseInt((process.env.JWT_REFRESH_EXPIRES_IN || '30d').replace('d', ''), 10) || 30;
  return new Date(Date.now() + days * 24 * 60 * 60 * 1000);
}

async function issueTokenPair(user, { userAgent, ipAddress }) {
  const accessToken = generateAccessToken(user);
  const refreshToken = generateRefreshToken();

  await repository.storeRefreshToken({
    userId: user.id,
    tokenHash: hashToken(refreshToken),
    userAgent,
    ipAddress,
    expiresAt: refreshExpiryDate(),
  });

  return { accessToken, refreshToken };
}

async function register({ name, phone, password, isAdultDeclared, referralCode }, context) {
  const phoneProvider = detectPhoneProvider(phone);

  const existing = await repository.findUserByPhone(phone);
  if (existing) {
    // Regra Seção 16.1: um telefone = uma conta
    throw new ConflictError('Já existe uma conta cadastrada com este número de telefone.');
  }

  const passwordHash = await bcrypt.hash(password, Number(process.env.BCRYPT_SALT_ROUNDS) || 12);

  const user = await repository.createUser({
    name,
    phone,
    phoneProvider,
    passwordHash,
    isAdultDeclared,
    termsVersion: null, // definido logo abaixo, a partir do Módulo Jurídico
  });

  await repository.createStreakRow(user.id);

  // Registro de Consentimento (docx Parte 5): grava o aceite de TODOS os
  // documentos obrigatórios vigentes (Termos + Privacidade) de uma vez só,
  // correspondendo ao checkbox único do cadastro.
  const acceptedDocs = await legalService.acceptMandatoryDocuments(user.id, {
    ipAddress: context.ipAddress,
    userAgent: context.userAgent,
  });
  const termosAceito = acceptedDocs.find((d) => d.type === 'termos');
  if (termosAceito) {
    await repository.acceptTerms(user.id, termosAceito.version);
  }

  // Vínculo de indicação (Manual Parte 3 — módulo Convites/Indicações).
  // Falha ao vincular a indicação nunca deve impedir o cadastro do usuário.
  if (referralCode) {
    try {
      await referralsService.linkReferral(undefined, { referralCode, referredUserId: user.id });
    } catch (err) {
      // Não propaga: indicação é um bônus, não um requisito de cadastro.
    }
  }

  await repository.insertAuditLog({
    userId: user.id,
    action: 'user.registered',
    entity: 'users',
    entityId: user.id,
    metadata: { phoneProvider },
    ipAddress: context.ipAddress,
  });

  const tokens = await issueTokenPair(user, context);

  return { user: sanitizeUser(user), ...tokens };
}

async function login({ phone, password }, context) {
  // Antifraude / força bruta (Seção 7 e 12 do Doc. Mestre)
  const recentFailures = await repository.countRecentFailedAttempts(phone);
  if (recentFailures >= 5) {
    throw new ForbiddenError('Muitas tentativas falhas recentes. Tente novamente mais tarde.');
  }

  const user = await repository.findUserByPhone(phone);

  if (!user || !user.password_hash) {
    await repository.recordLoginAttempt({ phone, ipAddress: context.ipAddress, success: false });
    throw new UnauthorizedError('Telefone ou senha incorretos.');
  }

  const passwordMatches = await bcrypt.compare(password, user.password_hash);
  if (!passwordMatches) {
    await repository.recordLoginAttempt({ phone, ipAddress: context.ipAddress, success: false });
    throw new UnauthorizedError('Telefone ou senha incorretos.');
  }

  if (user.status === 'banned' || user.status === 'suspended') {
    throw new ForbiddenError('Esta conta está inativa. Contate o suporte.');
  }

  await repository.recordLoginAttempt({ phone, ipAddress: context.ipAddress, success: true });
  await repository.touchLastLogin(user.id);
  await repository.insertAuditLog({
    userId: user.id,
    action: 'user.login',
    entity: 'users',
    entityId: user.id,
    ipAddress: context.ipAddress,
  });

  const tokens = await issueTokenPair(user, context);

  return { user: sanitizeUser(user), ...tokens };
}

async function refresh({ refreshToken }, context) {
  const tokenHash = hashToken(refreshToken);
  const stored = await repository.findValidRefreshToken(tokenHash);

  if (!stored) {
    throw new UnauthorizedError('Refresh token inválido ou expirado.');
  }

  const user = await repository.findUserById(stored.user_id);
  if (!user) {
    throw new UnauthorizedError('Usuário não encontrado.');
  }

  // Rotação de refresh token: revoga o antigo e emite um novo par (mitiga replay)
  await repository.revokeRefreshToken(tokenHash);
  const tokens = await issueTokenPair(user, context);

  return { user: sanitizeUser(user), ...tokens };
}

async function logout({ refreshToken }) {
  await repository.revokeRefreshToken(hashToken(refreshToken));
}

function sanitizeUser(user) {
  return {
    id: user.id,
    name: user.name,
    phone: user.phone,
    role: user.role || 'user',
    trustScore: user.trust_score,
    status: user.status,
    xpTotal: Number(user.xp_total || 0),
    pointsBalance: Number(user.points_balance || 0),
    walletBalanceMzn: Number(user.wallet_balance_mzn || 0),
  };
}

/**
 * Reaceite de Termos (Doc. Mestre Seção 17, fluxo estendido). Aceita todos os
 * documentos obrigatórios pendentes de uma vez — cobre o caso de mais de um
 * documento (ex: Termos E Privacidade) terem sido atualizados juntos.
 */
async function acceptTerms(userId, context = {}) {
  const accepted = await legalService.acceptMandatoryDocuments(userId, context);
  const termosAceito = accepted.find((d) => d.type === 'termos');
  if (termosAceito) {
    await repository.acceptTerms(userId, termosAceito.version);
  }
  await userCache.invalidateProfile(userId);
  return { accepted };
}

module.exports = { register, login, refresh, logout, acceptTerms };
