const referralsRepository = require('../repositories/referralsRepository');
const walletService = require('../../wallet/services/walletService');
const configRepository = require('../../../common/repositories/systemConfigRepository');

/**
 * Bónus de convite (regra do dono, 2026-10-12): quando um convidado recebe dinheiro de uma MISSÃO DIÁRIA, quem o
 * convidou recebe 20% desse valor, para sempre, como extra pago pela plataforma.
 *   - 20% do valor REALMENTE creditado ao convidado (se o teto de 7,20 MZN cortou, o bónus acompanha o corte).
 *   - Nada é tirado ao convidado: ele recebe o valor inteiro, o bónus é um crédito separado para quem convidou.
 *   - Fora do teto diário de quem convida: fonte própria `referral_bonus` (o teto só soma `mission_reward`).
 *   - Só se o convite já estiver qualificado (status 'rewarded'); convites 'pending' não geram bónus.
 *   - Corre dentro da MESMA transação do resgate da missão: ou tudo é gravado, ou nada. Como o resgate só
 *     acontece uma vez por missão (a linha fica bloqueada e passa a 'reward_claimed'), o bónus nunca é pago em duplicado.
 * Não importa referralsService nem missionsService (que se importam um ao outro) para não criar dependência circular.
 */
async function payInviterBonus(executor, { referredUserId, creditedMzn, userMissionId, missionTitle }) {
  const percent = Number((await configRepository.getConfigValue('referral_bonus_percent', executor)) ?? 20);
  if (!(percent > 0) || !(Number(creditedMzn) > 0)) return null;

  const referral = await referralsRepository.findRewardedReferralByReferred(referredUserId, executor);
  if (!referral) return null;

  // Em cêntimos, para não acumular ruído de vírgula flutuante (ex.: 20% de 1,20 = 0,24 exato).
  const bonusMzn = Math.round(Number(creditedMzn) * percent) / 100;
  if (!(bonusMzn > 0)) return null;

  const credit = await walletService.creditReward(
    {
      userId: referral.referrer_user_id,
      amountMzn: bonusMzn,
      source: 'referral_bonus',
      referenceId: userMissionId,
      metadata: {
        referralId: referral.id,
        referredUserId,
        missionTitle,
        percent,
        baseAmountMzn: Number(creditedMzn),
      },
      ignoreDailyCap: true,
    },
    executor
  );

  return credit
    ? { referrerUserId: referral.referrer_user_id, bonusMzn, referredName: referral.referred_name }
    : null;
}

module.exports = { payInviterBonus };
