const shopService = require('../services/shopService');

async function listItems(req, res, next) {
  try {
    const items = await shopService.listItems(req.user.id);
    return res.status(200).json({ status: 'success', message: null, data: items });
  } catch (err) {
    return next(err);
  }
}

async function purchase(req, res, next) {
  try {
    const result = await shopService.purchase(req.user.id, req.validatedBody.itemKey, { ipAddress: req.ip });
    return res.status(201).json({ status: 'success', message: `${result.item.name} adquirido com sucesso!`, data: result });
  } catch (err) {
    return next(err);
  }
}

async function equip(req, res, next) {
  try {
    const result = await shopService.equip(req.user.id, req.validatedBody.itemKey);
    return res.status(200).json({ status: 'success', message: 'Item equipado.', data: result });
  } catch (err) {
    return next(err);
  }
}

async function unequip(req, res, next) {
  try {
    const result = await shopService.unequip(req.user.id, req.validatedBody.slot);
    return res.status(200).json({ status: 'success', message: 'Item removido.', data: result });
  } catch (err) {
    return next(err);
  }
}

async function getMyInventory(req, res, next) {
  try {
    const inventory = await shopService.getMyInventory(req.user.id);
    return res.status(200).json({ status: 'success', message: null, data: inventory });
  } catch (err) {
    return next(err);
  }
}

async function getMyPointsLedger(req, res, next) {
  try {
    const limit = Math.min(Number(req.query.limit) || 30, 100);
    const offset = Number(req.query.offset) || 0;
    const rows = await shopService.getMyPointsLedger(req.user.id, { limit, offset });
    return res.status(200).json({ status: 'success', message: null, data: rows });
  } catch (err) {
    return next(err);
  }
}

module.exports = { listItems, purchase, equip, unequip, getMyInventory, getMyPointsLedger };
