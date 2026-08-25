const missionsService = require('../services/missionsService');

async function listMine(req, res, next) {
  try {
    const missions = await missionsService.listMyMissions(req.user.id);
    return res.status(200).json({ status: 'success', message: null, data: missions });
  } catch (err) {
    return next(err);
  }
}

async function claimReward(req, res, next) {
  try {
    const result = await missionsService.claimReward(req.user.id, req.params.userMissionId);
    return res.status(200).json({
      status: 'success',
      message: 'Recompensa resgatada com sucesso.',
      data: result,
    });
  } catch (err) {
    return next(err);
  }
}

module.exports = { listMine, claimReward };
