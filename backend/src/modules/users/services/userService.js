const repository = require('../repositories/userRepository');
const legalService = require('../../legal/services/legalService');
const userCache = require('../../../common/cache/userCache');
const { NotFoundError } = require('../../../common/errors/AppError');

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
    memberSince: profile.created_at,
    // Cosméticos equipados (Loja de Pontos) — o frontend usa isso para
    // renderizar a moldura de perfil e aplicar o tema de cor globalmente.
    equippedAvatarFrame: profile.equipped_avatar_frame,
    equippedTheme: profile.equipped_theme,
  };
}

module.exports = { getProfile };
