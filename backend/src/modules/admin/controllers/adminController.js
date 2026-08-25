const adminService = require('../services/adminService');

function ctx(req) {
  return { adminUserId: req.user.id, ipAddress: req.ip };
}

async function listWithdrawals(req, res, next) {
  try {
    const limit = Math.min(Number(req.query.limit) || 20, 100);
    const offset = Number(req.query.offset) || 0;
    const status = req.query.status || 'pending_review';
    const withdrawals = await adminService.listWithdrawals(status, { limit, offset });
    return res.status(200).json({ status: 'success', message: null, data: withdrawals });
  } catch (err) {
    return next(err);
  }
}

async function getWithdrawalDetail(req, res, next) {
  try {
    const detail = await adminService.getWithdrawalDetail(req.params.withdrawalId);
    return res.status(200).json({ status: 'success', message: null, data: detail });
  } catch (err) {
    return next(err);
  }
}

async function markWithdrawalAsPaid(req, res, next) {
  try {
    const result = await adminService.markWithdrawalAsPaid(req.params.withdrawalId, ctx(req));
    return res.status(200).json({ status: 'success', message: 'Saque marcado como pago.', data: result });
  } catch (err) {
    return next(err);
  }
}

async function suspendWithdrawalForReview(req, res, next) {
  try {
    const reason = req.validatedBody?.reason;
    const result = await adminService.suspendForReview(req.params.withdrawalId, { ...ctx(req), reason });
    return res.status(200).json({ status: 'success', message: 'Saque suspenso para revisão manual.', data: result });
  } catch (err) {
    return next(err);
  }
}

async function cancelWithdrawal(req, res, next) {
  try {
    const reason = req.validatedBody?.reason;
    const result = await adminService.cancelWithdrawal(req.params.withdrawalId, { ...ctx(req), reason });
    return res.status(200).json({ status: 'success', message: 'Saque cancelado e valor estornado.', data: result });
  } catch (err) {
    return next(err);
  }
}

async function approveWithdrawal(req, res, next) {
  try {
    const result = await adminService.approveWithdrawal(req.params.withdrawalId, ctx(req));
    return res.status(200).json({ status: 'success', message: 'Saque aprovado.', data: result });
  } catch (err) {
    return next(err);
  }
}

async function rejectWithdrawal(req, res, next) {
  try {
    const { reason } = req.validatedBody;
    const result = await adminService.rejectWithdrawal(req.params.withdrawalId, { ...ctx(req), reason });
    return res.status(200).json({ status: 'success', message: 'Saque rejeitado e valor estornado.', data: result });
  } catch (err) {
    return next(err);
  }
}

async function adjustTrustScore(req, res, next) {
  try {
    const { delta, reason } = req.validatedBody;
    const result = await adminService.adjustTrustScore({
      targetUserId: req.params.userId,
      delta,
      reason,
      ...ctx(req),
    });
    return res.status(200).json({ status: 'success', message: 'Trust Score ajustado.', data: result });
  } catch (err) {
    return next(err);
  }
}

async function setUserStatus(req, res, next) {
  try {
    const { status } = req.validatedBody;
    const result = await adminService.setUserStatus({
      targetUserId: req.params.userId,
      status,
      ...ctx(req),
    });
    return res.status(200).json({ status: 'success', message: 'Status do usuário atualizado.', data: result });
  } catch (err) {
    return next(err);
  }
}

async function setUserRole(req, res, next) {
  try {
    const { role } = req.validatedBody;
    const result = await adminService.setUserRole({
      targetUserId: req.params.userId,
      role,
      ...ctx(req),
    });
    return res.status(200).json({ status: 'success', message: 'Papel administrativo atualizado.', data: result });
  } catch (err) {
    return next(err);
  }
}

async function listUsers(req, res, next) {
  try {
    const limit = Math.min(Number(req.query.limit) || 20, 100);
    const offset = Number(req.query.offset) || 0;
    const users = await adminService.listUsers({ search: req.query.search, limit, offset });
    return res.status(200).json({ status: 'success', message: null, data: users });
  } catch (err) {
    return next(err);
  }
}

async function listAuditLogs(req, res, next) {
  try {
    const limit = Math.min(Number(req.query.limit) || 50, 200);
    const offset = Number(req.query.offset) || 0;
    const logs = await adminService.listAuditLogs({ userId: req.query.userId, limit, offset });
    return res.status(200).json({ status: 'success', message: null, data: logs });
  } catch (err) {
    return next(err);
  }
}

const reportsService = require('../../reports/services/reportsService');

async function listDailyReports(req, res, next) {
  try {
    const limit = Math.min(Number(req.query.limit) || 30, 90);
    const offset = Number(req.query.offset) || 0;
    const reports = await reportsService.listReports({ limit, offset });
    return res.status(200).json({ status: 'success', message: null, data: reports });
  } catch (err) {
    return next(err);
  }
}

module.exports = {
  listWithdrawals,
  getWithdrawalDetail,
  approveWithdrawal,
  rejectWithdrawal,
  suspendWithdrawalForReview,
  cancelWithdrawal,
  markWithdrawalAsPaid,
  adjustTrustScore,
  setUserStatus,
  setUserRole,
  listUsers,
  listAuditLogs,
  listDailyReports,
};
