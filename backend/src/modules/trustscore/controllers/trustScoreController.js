const trustScoreService = require('../services/trustScoreService');
const { NotFoundError } = require('../../../common/errors/AppError');

/**
 * Regra de UX (Seção 13.5 do Doc. Mestre — ficha técnica do ícone Trust Score):
 * "Não expor valor exato publicamente." Por isso o endpoint do próprio usuário
 * retorna um selo qualitativo, não o número bruto do banco.
 */
function scoreToBadge(score) {
  if (score >= 85) return 'verified_trusted';
  if (score >= 60) return 'in_good_standing';
  if (score >= 30) return 'under_review';
  return 'restricted';
}

async function myStatus(req, res, next) {
  try {
    const score = await trustScoreService.getCurrentScore(req.user.id);
    if (score === null) throw new NotFoundError('Usuário não encontrado.');

    return res.status(200).json({
      status: 'success',
      message: null,
      data: { badge: scoreToBadge(score) },
    });
  } catch (err) {
    return next(err);
  }
}

module.exports = { myStatus, scoreToBadge };
