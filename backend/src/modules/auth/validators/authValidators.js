const { z } = require('zod');

/**
 * Validação de entrada isolada da lógica de negócio (Manual Parte 5).
 * Regras alinhadas à Seção 16.1 (Elegibilidade) e Seção 17 (Check-in Jurídico) do Doc. Mestre.
 */

// Telefone moçambicano: M-Pesa (84/85) ou e-Mola (86/87)
const phoneRegex = /^8[4-7][0-9]{7}$/;

const registerSchema = z.object({
  name: z.string().trim().min(2, 'Nome muito curto').max(120),
  phone: z
    .string()
    .trim()
    .regex(phoneRegex, 'Número de telefone inválido. Use um número M-Pesa (84/85) ou e-Mola (86/87).'),
  password: z
    .string()
    .min(8, 'A senha deve ter no mínimo 8 caracteres')
    .max(72, 'A senha deve ter no máximo 72 caracteres'),
  isAdultDeclared: z.literal(true, {
    errorMap: () => ({ message: 'É necessário declarar maioridade para se cadastrar.' }),
  }),
  termsAccepted: z.literal(true, {
    errorMap: () => ({ message: 'É necessário aceitar os Termos de Uso e a Política de Privacidade.' }),
  }),
  referralCode: z.string().trim().max(12).optional(),
});

const loginSchema = z.object({
  phone: z.string().trim().regex(phoneRegex, 'Número de telefone inválido'),
  password: z.string().min(1, 'Senha é obrigatória'),
});

// O refresh token deixou de vir no corpo da requisição — agora viaja em
// cookie httpOnly (ver refreshCookie.js) e é lido de req.cookies no controller.

module.exports = { registerSchema, loginSchema, phoneRegex };
