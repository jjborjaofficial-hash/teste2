const { z } = require('zod');
const { phoneRegex } = require('../auth/validators/authValidators');

const updateProfileSchema = z
  .object({
    name: z.string().trim().min(2, 'Nome muito curto').max(120).optional(),
    // Só links https (a plataforma não guarda ficheiros). null remove a foto.
    avatarUrl: z
      .union([
        z.string().trim().url('Link da foto inválido').max(500).refine((u) => u.startsWith('https://'), 'A foto tem de ser um link https.'),
        z.null(),
      ])
      .optional(),
  })
  .refine((v) => v.name !== undefined || v.avatarUrl !== undefined, { message: 'Nada para alterar.' });

const changePaymentPhoneSchema = z.object({
  phone: z.string().trim().regex(phoneRegex, 'Número inválido. Use um número M-Pesa (84/85) ou e-Mola (86/87).'),
  password: z.string().max(72).optional(),
});

const changePasswordSchema = z.object({
  // Conta só-Google ainda não tem senha: nesse caso não há senha atual.
  currentPassword: z.string().max(72).optional(),
  newPassword: z.string().min(8, 'A senha deve ter no mínimo 8 caracteres').max(72, 'A senha deve ter no máximo 72 caracteres'),
});

const deleteAccountSchema = z.object({
  password: z.string().max(72).optional(),
  confirmation: z.literal('ELIMINAR', { errorMap: () => ({ message: 'Escreva ELIMINAR para confirmar.' }) }),
  // Só é obrigatório se ainda houver saldo: o utilizador aceita perdê-lo.
  acceptLoseBalance: z.boolean().optional(),
});

module.exports = { changePasswordSchema, updateProfileSchema, changePaymentPhoneSchema, deleteAccountSchema };
