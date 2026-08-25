const crypto = require('crypto');
const db = require('../../../config/database');
const repository = require('../repositories/referralsRepository');
const xpService = require('../../gamification/services/xpService');
const configRepository = require('../../../common/repositories/systemConfigRepository');

/**
 * Service de Convites/Indicações (Manual Parte 3 — módulo oficial listado na arquitetura).
 * Regra de qualificação: o indicado precisa completar N quizzes corretos para que o
 * indicador receba a recompensa (evita fraude de auto-indicação com conta vazia,
 * alinhado ao espírito da Seção 16.2 — Tolerância Zero).
 */

function generateCode() {
  return crypto.randomBytes(4).toString('hex').toUpperCase(); // ex: "A1B2C3D4"
}

async function getOrCreateMyCode(userId) {
  let code = await repository.getCodeForUser(userId);
  if (code) return code;

  // Tenta algumas vezes em caso de colisão (extremamente improvável, mas o código é curto)
  for (let attempt = 0; attempt < 5; attempt += 1) {
    code = generateCode();
    try {
      await repository.createCodeForUser(db, userId, code);
      return code;
    } catch (err) {
      if (err.code !== '23505') throw err; // não é violação de unicidade, propaga
    }
  }
  throw new Error('Não foi possível gerar um código de indicação único. Tente novamente.');
}

/**
 * Vincula um novo usuário a quem o indicou. Chamado pelo módulo de Autenticação
 * durante o registro (Seção 17), de forma desacoplada via injeção do código.
 */
async function linkReferral(executor = db, { referralCode, referredUserId }) {
  if (!referralCode) return null;

  const referrerUserId = await repository.findUserIdByCode(referralCode, executor);
  if (!referrerUserId || referrerUserId === referredUserId) return null; // código inválido ou auto-indicação

  return repository.createReferral(executor, { referrerUserId, referredUserId });
}

/**
 * Verifica se alguma indicação pendente relacionada a este usuário já qualificou
 * (atingiu o número mínimo de quizzes corretos) e credita a recompensa ao indicador.
 * Chamado a partir do Quiz após uma resposta correta (mesmo padrão de baixo
 * acoplamento usado com o módulo de Missões).
 */
async function checkAndRewardQualification(executor, referredUserId) {
  const pending = await repository.getPendingReferralsForUser(referredUserId, executor);
  if (pending.length === 0) return null;

  const requiredCount = Number(
    (await configRepository.getConfigValue('referral_qualification_quiz_count', executor)) ?? 5
  );
  const rewardPoints = Number(
    (await configRepository.getConfigValue('referral_reward_points', executor)) ?? 100
  );

  const activityCount = await repository.countQualifyingActivity(referredUserId, executor);
  if (activityCount < requiredCount) return null;

  const referral = pending[0];
  await xpService.addXpAndPoints(executor, {
    userId: referral.referrer_user_id,
    xpDelta: 0,
    pointsDelta: rewardPoints,
    pointsSource: 'referral_reward',
    pointsReferenceId: referral.id,
  });
  await repository.markQualifiedAndRewarded(executor, referral.id);

  return { referralId: referral.id, referrerUserId: referral.referrer_user_id, rewardPoints };
}

async function listMyReferrals(userId) {
  const rows = await repository.listMyReferrals(userId);
  return rows.map((r) => ({
    id: r.id,
    referredName: r.referred_name,
    status: r.status,
    createdAt: r.created_at,
    rewardGrantedAt: r.reward_granted_at,
  }));
}

module.exports = { getOrCreateMyCode, linkReferral, checkAndRewardQualification, listMyReferrals };
