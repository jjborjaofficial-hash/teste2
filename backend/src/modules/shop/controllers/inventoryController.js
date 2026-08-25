const inventoryService = require('../services/inventoryService');

async function listInventory(req, res, next) {
  try {
    const items = await inventoryService.listInventory(req.user.id);
    return res.status(200).json({ status: 'success', message: null, data: items });
  } catch (err) {
    return next(err);
  }
}

async function activate(req, res, next) {
  try {
    const result = await inventoryService.activateItem(req.user.id, req.params.id);
    return res.status(200).json({ status: 'success', message: `${result.name} ativado!`, data: result });
  } catch (err) {
    return next(err);
  }
}

async function use(req, res, next) {
  try {
    const result = await inventoryService.useItem(req.user.id, req.params.id);
    return res.status(200).json({ status: 'success', message: `${result.name} utilizado.`, data: result });
  } catch (err) {
    return next(err);
  }
}

module.exports = { listInventory, activate, use };
