const { z } = require('zod');

const rejectWithdrawalSchema = z.object({
  reason: z.string().trim().min(3, 'Motivo obrigatório (mínimo 3 caracteres).').max(500),
});

const suspendWithdrawalSchema = z.object({
  reason: z.string().trim().max(500).optional(),
});

const cancelWithdrawalSchema = z.object({
  reason: z.string().trim().max(500).optional(),
});

const adjustTrustScoreSchema = z.object({
  delta: z.number().int().min(-100).max(100),
  reason: z.string().trim().min(3, 'Motivo obrigatório.').max(500),
});

const setUserStatusSchema = z.object({
  status: z.enum(['active', 'suspended', 'banned'], {
    errorMap: () => ({ message: 'Status deve ser "active", "suspended" ou "banned".' }),
  }),
});

const setUserRoleSchema = z.object({
  role: z.enum(['user', 'admin_master', 'admin_financeiro', 'admin_suporte', 'admin_juridico'], {
    errorMap: () => ({ message: 'Papel inválido.' }),
  }),
});

module.exports = {
  rejectWithdrawalSchema,
  suspendWithdrawalSchema,
  cancelWithdrawalSchema,
  adjustTrustScoreSchema,
  setUserStatusSchema,
  setUserRoleSchema,
};
