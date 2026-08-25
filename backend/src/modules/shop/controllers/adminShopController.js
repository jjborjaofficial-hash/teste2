const shopService = require('../services/shopService');

async function listItems(req, res, next) {
  try {
    const items = await shopService.listItemsAdmin();
    return res.status(200).json({ status: 'success', message: null, data: items });
  } catch (err) {
    return next(err);
  }
}

async function createItem(req, res, next) {
  try {
    const created = await shopService.createItem(req.validatedBody);
    return res.status(201).json({ status: 'success', message: 'Item criado.', data: created });
  } catch (err) {
    return next(err);
  }
}

async function updateItem(req, res, next) {
  try {
    const updated = await shopService.updateItem(req.params.itemId, req.validatedBody);
    return res.status(200).json({ status: 'success', message: 'Item atualizado.', data: updated });
  } catch (err) {
    return next(err);
  }
}

async function listPurchases(req, res, next) {
  try {
    const limit = Math.min(Number(req.query.limit) || 50, 200);
    const offset = Number(req.query.offset) || 0;
    const purchases = await shopService.listPurchasesAdmin({ limit, offset });
    return res.status(200).json({ status: 'success', message: null, data: purchases });
  } catch (err) {
    return next(err);
  }
}

module.exports = { listItems, createItem, updateItem, listPurchases };
