const walletService = require('../services/walletService');

async function getBalance(req, res, next) {
  try {
    const balance = await walletService.getBalance(req.user.id);
    return res.status(200).json({ status: 'success', message: null, data: balance });
  } catch (err) {
    return next(err);
  }
}

async function getHistory(req, res, next) {
  try {
    const limit = Math.min(Number(req.query.limit) || 20, 100);
    const offset = Number(req.query.offset) || 0;
    const history = await walletService.getHistory(req.user.id, { limit, offset });
    return res.status(200).json({ status: 'success', message: null, data: history });
  } catch (err) {
    return next(err);
  }
}

async function requestWithdrawal(req, res, next) {
  try {
    const { amountMzn, method } = req.validatedBody;
    const result = await walletService.requestWithdrawal({ userId: req.user.id, amountMzn, method });
    return res.status(201).json({
      status: 'success',
      message: 'Solicitação de saque recebida e está em análise.',
      data: result,
    });
  } catch (err) {
    return next(err);
  }
}

async function getConversionRate(req, res, next) {
  try {
    const rate = await walletService.getConversionRate();
    return res.status(200).json({ status: 'success', message: null, data: rate });
  } catch (err) {
    return next(err);
  }
}

async function convertPoints(req, res, next) {
  try {
    const { pointsAmount } = req.validatedBody;
    const result = await walletService.convertPointsToMoney({ userId: req.user.id, pointsAmount });
    return res.status(201).json({
      status: 'success',
      message: `Conversão realizada: ${result.pointsConverted} Pontos -> ${result.amountMzn.toFixed(2)} MZN.`,
      data: result,
    });
  } catch (err) {
    return next(err);
  }
}

module.exports = { getBalance, getHistory, requestWithdrawal, getConversionRate, convertPoints };
