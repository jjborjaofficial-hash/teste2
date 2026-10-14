const repository = require('../repositories/userRepository');
const legalService = require('../../legal/services/legalService');
const userCache = require('../../../common/cache/userCache');
const { computeTrial } = require('../../shop/themeTrial');
const bcrypt = require('bcrypt');
const { detectPhoneProvider } = require('../../../common/phone');
const crypto = require('crypto');
const db = require('../../../config/database');
const auditLogRepository = require('../../../common/repositories/auditLogRepository');
const {
  NotFoundError, UnauthorizedError, ConflictError, BusinessRuleError,
} = require('../../../common/errors/AppError');

const PHONE_CHANGE_COOLDOWN_DAYS = Number(process.env.PHONE_CHANGE_COOLDOWN_DAYS) || 30;

const providerOf = detectPhoneProvider;

// Operações sensíveis pedem a senha. Contas só-Google não têm senha: a sessão
// ativa vale como prova (não há outra forma de confirmar).
async function assertPassword(sec, password) {
  if (!sec.password_hash) return;
  if (!password || !(await bcrypt.compare(password, sec.password_hash))) {
    throw new UnauthorizedError('Senha incorreta.');
  }
}

async function updateProfile(userId, { name, avatarUrl }, context = {}) {
  await repository.updateNameAvatar(userId, { name, avatarUrl });
  await userCache.invalidateProfile(userId);
  await auditLogRepository.insertAuditLog(db, {
    userId, action: 'user.profile_updated', entity: 'users', entityId: userId,
    metadata: { name: name !== undefined, avatar: avatarUrl !== undefined }, ipAddress: context.ipAddress,
  });
  return getProfile(userId);
}

// O número M-Pesa/e-Mola é para onde vai o dinheiro; o operador é sempre
// deduzido do próprio número, nunca escolhido à mão.
async function changePaymentPhone(userId, { phone, password }, context = {}) {
  const sec = await repository.findSecurityById(userId);
  if (!sec) throw new NotFoundError('Perfil não encontrado.');
  await assertPassword(sec, password);
  if (sec.phone === phone) throw new BusinessRuleError('Este já é o seu número de pagamento.');
  if (await repository.hasActiveWithdrawal(userId)) {
    throw new BusinessRuleError('Tem um saque em andamento. Só pode mudar o número depois de ele terminar.');
  }
  const last = await repository.lastPaymentPhoneChange(userId);
  if (last && Date.now() - new Date(last).getTime() < PHONE_CHANGE_COOLDOWN_DAYS * 86400000) {
    throw new BusinessRuleError(`O número só pode ser mudado uma vez a cada ${PHONE_CHANGE_COOLDOWN_DAYS} dias.`);
  }
  if (await repository.phoneInUse(phone, userId)) {
    throw new ConflictError('Já existe uma conta com este número de telefone.');
  }
  const provider = providerOf(phone);
  try {
    await repository.updatePhone(userId, phone, provider);
  } catch (err) {
    if (err.code === '23505') throw new ConflictError('Já existe uma conta com este número de telefone.');
    throw err;
  }
  await userCache.invalidateProfile(userId);
  await auditLogRepository.insertAuditLog(db, {
    userId, action: 'user.payment_phone_changed', entity: 'users', entityId: userId,
    metadata: { oldProvider: sec.phone_provider, newProvider: provider, oldPhoneEnd: (sec.phone || '').slice(-3), newPhoneEnd: phone.slice(-3) },
    ipAddress: context.ipAddress,
  });
  return getProfile(userId);
}

// Trocar a senha pede a senha atual. Conta criada pelo Google (sem senha) pode DEFINIR uma,
// para também entrar com telefone + senha. As outras sessões são terminadas.
async function changePassword(userId, { currentPassword, newPassword }, context = {}) {
  const sec = await repository.findSecurityById(userId);
  if (!sec) throw new NotFoundError('Perfil não encontrado.');
  if (sec.password_hash) {
    if (!currentPassword || !(await bcrypt.compare(currentPassword, sec.password_hash))) {
      throw new UnauthorizedError('Senha atual incorreta.');
    }
    if (await bcrypt.compare(newPassword, sec.password_hash)) {
      throw new BusinessRuleError('A nova senha tem de ser diferente da atual.');
    }
  }
  const hash = await bcrypt.hash(newPassword, Number(process.env.BCRYPT_SALT_ROUNDS) || 12);
  await repository.updatePassword(userId, hash);
  const keep = context.refreshToken ? crypto.createHash('sha256').update(context.refreshToken).digest('hex') : null;
  await repository.revokeOtherSessions(userId, keep);
  await userCache.invalidateProfile(userId);
  await auditLogRepository.insertAuditLog(db, {
    userId, action: sec.password_hash ? 'user.password_changed' : 'user.password_set', entity: 'users', entityId: userId,
    metadata: {}, ipAddress: context.ipAddress,
  });
  return { changed: true, hadPassword: Boolean(sec.password_hash) };
}

async function exportMyData(userId, context = {}) {
  const data = await repository.exportData(userId);
  await auditLogRepository.insertAuditLog(db, {
    userId, action: 'user.data_exported', entity: 'users', entityId: userId, metadata: {}, ipAddress: context.ipAddress,
  });
  return { exportedAt: new Date().toISOString(), ...data };
}

async function deleteAccount(userId, { password, acceptLoseBalance }, context = {}) {
  const client = await db.getClient();
  try {
    await client.query('BEGIN');
    const sec = await repository.findSecurityById(userId, client);
    if (!sec) throw new NotFoundError('Perfil não encontrado.');
    if (sec.role !== 'user') {
      throw new BusinessRuleError('Contas de administração não podem ser eliminadas aqui.');
    }
    await assertPassword(sec, password);
    if (await repository.hasActiveWithdrawal(userId, client)) {
      throw new BusinessRuleError('Tem um saque em andamento. Espere ele terminar para eliminar a conta.');
    }
    const balance = Number(sec.wallet_balance_mzn);
    if (balance > 0 && !acceptLoseBalance) {
      throw new BusinessRuleError(
        `Ainda tem ${balance.toFixed(2)} MZN na carteira. Levante o saldo antes, ou confirme que aceita perdê-lo.`
      );
    }
    await auditLogRepository.insertAuditLog(client, {
      userId, action: 'user.account_deleted', entity: 'users', entityId: userId,
      metadata: { forfeitedBalanceMzn: balance }, ipAddress: context.ipAddress,
    });
    await repository.anonymize(userId, client);
    await client.query('COMMIT');
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
  await userCache.invalidateProfile(userId);
  return { deleted: true };
}

async function getProfile(userId) {
  // Cache-aside (docx "REDIS CACHE E CRON JOBS", Seção 2 — Perfil básico do
  // usuário). O aceite jurídico NUNCA é cacheado aqui: precisa refletir o
  // estado mais recente dos documentos obrigatórios a cada chamada, mesmo que
  // o resto do perfil venha do cache (ver comentário em userCache.js).
  const profile = await userCache.getOrSetProfile(userId, () => repository.findProfileById(userId));
  if (!profile) {
    throw new NotFoundError('Perfil não encontrado.');
  }

  // Fonte da verdade agora é o Módulo Jurídico: cobre qualquer documento
  // obrigatório (não só Termos) que tenha sido atualizado e ainda não aceito
  // pelo usuário na versão vigente (docx Parte 7: "Alterações Jurídicas").
  const needsLegalReacceptance = await legalService.hasPendingMandatoryAcceptance(userId);

  return {
    id: profile.id,
    name: profile.name,
    phone: profile.phone,
    phoneProvider: profile.phone_provider,
    email: profile.email,
    hasPassword: Boolean(profile.has_password),
    avatarUrl: profile.avatar_url,
    country: profile.country,
    locale: profile.locale,
    currency: profile.currency,
    xpTotal: Number(profile.xp_total),
    pointsBalance: Number(profile.points_balance),
    walletBalanceMzn: Number(profile.wallet_balance_mzn),
    trustScore: profile.trust_score,
    status: profile.status,
    role: profile.role,
    termsVersion: profile.terms_version,
    termsAcceptedAt: profile.terms_accepted_at,
    // Se algum documento obrigatório (Termos ou Privacidade) tiver versão mais
    // recente ainda não aceita, o frontend deve bloquear a navegação e pedir
    // reaceite antes de liberar o resto do app.
    needsTermsReacceptance: needsLegalReacceptance,
    // Conta criada via login com Google ainda sem telefone (Google não
    // fornece) — o frontend bloqueia a navegação e pede o telefone
    // M-Pesa/e-Mola antes de liberar o resto do app (ver ProtectedRoute).
    needsPhone: !profile.phone,
    memberSince: profile.created_at,
    // Cosméticos equipados (Loja de Pontos) — o frontend usa isso para
    // renderizar a moldura de perfil e aplicar o tema de cor globalmente.
    equippedAvatarFrame: profile.equipped_avatar_frame,
    equippedTheme: profile.equipped_theme,
    // Tema Noite emprestado por 10 minutos (GER-002). Calculado na hora (o perfil em cache só guarda as datas),
    // para o tempo restante nunca ficar desatualizado.
    themeTrial: computeTrial({
      eligible: profile.theme_trial_eligible,
      startedAt: profile.theme_trial_started_at,
      introSeenAt: profile.theme_trial_intro_seen_at,
      equippedTheme: profile.equipped_theme,
    }, new Date()),
  };
}

module.exports = { getProfile, updateProfile, changePassword, changePaymentPhone, exportMyData, deleteAccount };
