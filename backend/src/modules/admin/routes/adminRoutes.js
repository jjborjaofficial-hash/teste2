const { Router } = require('express');
const controller = require('../controllers/adminController');
const authenticate = require('../../../middleware/authenticate');
const requireRole = require('../../../middleware/requireRole');
const validate = require('../../../middleware/validate');
const {
  rejectWithdrawalSchema,
  suspendWithdrawalSchema,
  cancelWithdrawalSchema,
  adjustTrustScoreSchema,
  setUserStatusSchema,
  setUserRoleSchema,
} = require('../validators/adminValidators');

const router = Router();

// Toda rota deste módulo exige autenticação. A autorização granular (quem pode
// fazer o quê) é decidida rota a rota via requireRole (Manual Parte 5: autorização
// é responsabilidade de middleware transversal, não duplicada em cada controller).
router.use(authenticate);

// --- Saques: exclusivo de admin_financeiro (admin_master sempre tem acesso) ---
router.get('/withdrawals', requireRole('admin_financeiro'), controller.listWithdrawals);
router.get('/withdrawals/:withdrawalId', requireRole('admin_financeiro'), controller.getWithdrawalDetail);
router.post(
  '/withdrawals/:withdrawalId/approve',
  requireRole('admin_financeiro'),
  controller.approveWithdrawal
);
router.post(
  '/withdrawals/:withdrawalId/reject',
  requireRole('admin_financeiro'),
  validate(rejectWithdrawalSchema),
  controller.rejectWithdrawal
);
router.post(
  '/withdrawals/:withdrawalId/suspend-for-review',
  requireRole('admin_financeiro'),
  validate(suspendWithdrawalSchema),
  controller.suspendWithdrawalForReview
);
router.post(
  '/withdrawals/:withdrawalId/cancel',
  requireRole('admin_financeiro'),
  validate(cancelWithdrawalSchema),
  controller.cancelWithdrawal
);
router.post(
  '/withdrawals/:withdrawalId/mark-paid',
  requireRole('admin_financeiro'),
  controller.markWithdrawalAsPaid
);

// --- Usuários e Trust Score: exclusivo de admin_suporte ---
router.get('/users', requireRole('admin_suporte'), controller.listUsers);
router.post(
  '/users/:userId/trust-score/adjust',
  requireRole('admin_suporte'),
  validate(adjustTrustScoreSchema),
  controller.adjustTrustScore
);
router.post(
  '/users/:userId/status',
  requireRole('admin_suporte'),
  validate(setUserStatusSchema),
  controller.setUserStatus
);

// --- Gestão de papéis administrativos: exclusivo de admin_master ---
router.post(
  '/users/:userId/role',
  requireRole(), // sem papéis extras: só admin_master passa (regra do requireRole)
  validate(setUserRoleSchema),
  controller.setUserRole
);

// --- Auditoria: leitura liberada para qualquer papel admin_* ---
router.get('/audit-logs', requireRole('admin_financeiro', 'admin_suporte'), controller.listAuditLogs);
router.get('/reports/daily', requireRole('admin_financeiro'), controller.listDailyReports);

module.exports = router;
