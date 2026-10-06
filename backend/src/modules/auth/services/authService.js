const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const { OAuth2Client } = require('google-auth-library');
const repository = require('../repositories/authRepository');
const referralsService = require('../../referrals/services/referralsService');
const legalService = require('../../legal/services/legalService');
const missionsService = require('../../missions/services/missionsService');
const logger = require('../../../common/logger');
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

// Tolerância para renovações simultâneas do mesmo cookie (F5, várias abas). Ver authRepository.
const REFRESH_GRACE_SECONDS = 15;

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

/**
 * Conta o acesso de hoje para a missão \"Entrar na plataforma\". Melhor esforço:
 * uma falha aqui NUNCA pode impedir o login do utilizador.
 */
async function markDailyPresence(userId, { once = false } = {}) {
  try {
    if (once) await missionsService.registerPresenceOncePerDay(userId);
    else await missionsService.registerPresence(userId);
  } catch (err) {
    logger.warn(`Falha ao registrar a missão de login (user ${userId}): ${err.message}`);
  }
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
  await markDailyPresence(user.id);

  return { user: sanitizeUser(user), ...tokens };
}

/**
 * Login/Cadastro via Google (Doc. Mestre Seção 17, variante sem telefone no
 * primeiro passo). O backend NUNCA confia em dados enviados pelo cliente
 * sobre quem é o usuário do Google — o idToken é verificado diretamente
 * junto aos servidores do Google antes de qualquer decisão.
 *
 * Conta nova entra sem telefone (status 'pending_verification'); o
 * controller sinaliza isso ao frontend via needsPhone para redirecionar à
 * tela de completar perfil antes de liberar o resto do app.
 */
async function loginWithGoogle({ idToken }, context) {
  const clientId = process.env.GOOGLE_CLIENT_ID;
  if (!clientId) {
    logger.warn('Login com Google chamado sem GOOGLE_CLIENT_ID configurado no servidor.');
    throw new ForbiddenError('Login com Google não está disponível no momento.');
  }

  const googleClient = new OAuth2Client(clientId);
  let payload;
  try {
    const ticket = await googleClient.verifyIdToken({ idToken, audience: clientId });
    payload = ticket.getPayload();
  } catch (err) {
    throw new UnauthorizedError('Não foi possível verificar o login com o Google.');
  }

  if (!payload?.sub || !payload?.email) {
    throw new UnauthorizedError('Resposta do Google incompleta.');
  }

  const googleId = payload.sub;
  const email = payload.email.toLowerCase();
  const name = payload.name || email.split('@')[0];
  const avatarUrl = payload.picture || null;

  let user = await repository.findUserByGoogleId(googleId);

  if (!user) {
    // Pode já existir uma conta com esse e-mail (cadastrada por telefone
    // normalmente, que também guardou o e-mail depois) — nesse caso, apenas
    // vincula o Google a ela em vez de criar uma conta duplicada.
    const existingByEmail = await repository.findUserByEmail(email);
    if (existingByEmail) {
      user = await repository.linkGoogleToUser(existingByEmail.id, { googleId, avatarUrl });
    } else {
      user = await repository.createUserFromGoogle({ name, email, googleId, avatarUrl });
      await repository.createStreakRow(user.id);
    }

    await repository.insertAuditLog({
      userId: user.id,
      action: 'user.registered_google',
      entity: 'users',
      entityId: user.id,
      metadata: { email },
      ipAddress: context.ipAddress,
    });
  }

  if (user.status === 'banned' || user.status === 'suspended') {
    throw new ForbiddenError('Esta conta está inativa. Contate o suporte.');
  }

  await repository.touchLastLogin(user.id);
  await repository.insertAuditLog({
    userId: user.id,
    action: 'user.login_google',
    entity: 'users',
    entityId: user.id,
    ipAddress: context.ipAddress,
  });

  const tokens = await issueTokenPair(user, context);
  if (user.phone) {
    await markDailyPresence(user.id);
  }

  return { user: sanitizeUser(user), ...tokens };
}

/**
 * Completa o perfil de uma conta criada via Google: telefone (M-Pesa/e-Mola)
 * + check-in jurídico (maioridade + Termos), espelhando as exigências do
 * cadastro normal (Seção 16.1 e 17 do Doc. Mestre), só que em dois passos.
 */
async function completeProfile(userId, { phone, isAdultDeclared }, context) {
  const existingPhone = await repository.findUserByPhone(phone);
  if (existingPhone && existingPhone.id !== userId) {
    throw new ConflictError('Já existe uma conta cadastrada com este número de telefone.');
  }

  const phoneProvider = detectPhoneProvider(phone);
  const user = await repository.completeGoogleProfile(userId, { phone, phoneProvider, isAdultDeclared });
  if (!user) {
    throw new UnauthorizedError('Usuário não encontrado.');
  }

  await repository.createStreakRow(user.id);

  const acceptedDocs = await legalService.acceptMandatoryDocuments(user.id, {
    ipAddress: context.ipAddress,
    userAgent: context.userAgent,
  });
  const termosAceito = acceptedDocs.find((d) => d.type === 'termos');
  if (termosAceito) {
    await repository.acceptTerms(user.id, termosAceito.version);
  }

  await repository.insertAuditLog({
    userId: user.id,
    action: 'user.completed_google_profile',
    entity: 'users',
    entityId: user.id,
    metadata: { phoneProvider },
    ipAddress: context.ipAddress,
  });

  await userCache.invalidateProfile(user.id);
  await markDailyPresence(user.id, { once: true });

  return sanitizeUser(user);
}

async function refresh({ refreshToken }, context) {
  const tokenHash = hashToken(refreshToken);
  const stored = await repository.findValidRefreshToken(tokenHash, { graceSeconds: REFRESH_GRACE_SECONDS });

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
  // Sessão restaurada (ex.: abriu o app com o login ainda válido) também conta como entrar hoje.
  await markDailyPresence(user.id, { once: true });

  return { user: sanitizeUser(user), ...tokens };
}

async function logout({ refreshToken }) {
  await repository.revokeRefreshToken(hashToken(refreshToken), { logout: true });
}

function sanitizeUser(user) {
  return {
    id: user.id,
    name: user.name,
    phone: user.phone,
    email: user.email || null,
    avatarUrl: user.avatar_url || null,
    role: user.role || 'user',
    trustScore: user.trust_score,
    status: user.status,
    xpTotal: Number(user.xp_total || 0),
    pointsBalance: Number(user.points_balance || 0),
    walletBalanceMzn: Number(user.wallet_balance_mzn || 0),
    // Conta criada via Google ainda sem telefone — frontend usa isto para
    // redirecionar a /completar-perfil antes de liberar o resto do app
    // (mesmo mecanismo que needsTermsReacceptance já usa no ProtectedRoute).
    needsPhone: !user.phone,
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

module.exports = {
  hashToken,
  register,
  login,
  loginWithGoogle,
  completeProfile,
  refresh,
  logout,
  acceptTerms,
};
