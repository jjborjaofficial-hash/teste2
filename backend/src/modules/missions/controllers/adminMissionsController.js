const service = require('../services/adminMissionsService');

async function listMissions(req, res, next) {
  try {
    const missions = await service.listMissions();
    return res.status(200).json({ status: 'success', message: null, data: missions });
  } catch (err) {
    return next(err);
  }
}

async function createMission(req, res, next) {
  try {
    const created = await service.createMission(req.validatedBody);
    return res.status(201).json({ status: 'success', message: 'Missão criada.', data: created });
  } catch (err) {
    return next(err);
  }
}

async function updateMission(req, res, next) {
  try {
    const updated = await service.updateMission(req.params.missionId, req.validatedBody);
    return res.status(200).json({ status: 'success', message: 'Missão atualizada.', data: updated });
  } catch (err) {
    return next(err);
  }
}

module.exports = { listMissions, createMission, updateMission };
