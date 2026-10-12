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

const deleteAccountSchema = z.object({
  password: z.string().max(72).optional(),
  confirmation: z.literal('ELIMINAR', { errorMap: () => ({ message: 'Escreva ELIMINAR para confirmar.' }) }),
  // Só é obrigatório se ainda houver saldo: o utilizador aceita perdê-lo.
  acceptLoseBalance: z.boolean().optional(),
});

module.exports = { updateProfileSchema, changePaymentPhoneSchema, deleteAccountSchema };
