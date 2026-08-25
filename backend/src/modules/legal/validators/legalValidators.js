const { z } = require('zod');

const LEGAL_CATEGORIES = [
  'saques',
  'recompensas',
  'conta_bloqueada',
  'privacidade',
  'publicidade',
  'problemas_tecnicos',
  'conteudo',
];

const APPEAL_ACTIONS = [
  'conta_suspensa',
  'conta_banida',
  'recompensa_removida',
  'saque_rejeitado',
  'trust_score_reduzido',
];

const acceptMandatorySchema = z.object({}).optional();

const cookiePreferencesSchema = z.object({
  preferences: z.boolean().default(false),
  analytics: z.boolean().default(false),
  advertising: z.boolean().default(false),
});

const createLegalRequestSchema = z.object({
  category: z.enum(LEGAL_CATEGORIES, { errorMap: () => ({ message: 'Categoria inválida.' }) }),
  description: z.string().trim().min(10, 'Descreva sua solicitação com no mínimo 10 caracteres.').max(2000),
});

const respondLegalRequestSchema = z.object({
  status: z.enum(['em_analise', 'aguardando_usuario', 'resolvida', 'encerrada'], {
    errorMap: () => ({ message: 'Status inválido.' }),
  }),
  response: z.string().trim().max(2000).optional(),
});

const createAppealSchema = z.object({
  relatedAction: z.enum(APPEAL_ACTIONS, { errorMap: () => ({ message: 'Ação relacionada inválida.' }) }),
  description: z.string().trim().min(10, 'Descreva o motivo do recurso com no mínimo 10 caracteres.').max(2000),
});

const decideAppealSchema = z.object({
  status: z.enum(['deferido', 'indeferido'], { errorMap: () => ({ message: 'Decisão deve ser "deferido" ou "indeferido".' }) }),
  decision: z.string().trim().min(3, 'Justifique a decisão.').max(2000),
});

const createVersionSchema = z.object({
  version: z.string().trim().min(1).max(10),
  content: z.string().trim().min(10, 'Conteúdo do documento é obrigatório.'),
  effectiveDate: z.string().trim().optional(),
});

module.exports = {
  acceptMandatorySchema,
  cookiePreferencesSchema,
  createLegalRequestSchema,
  respondLegalRequestSchema,
  createAppealSchema,
  decideAppealSchema,
  createVersionSchema,
  LEGAL_CATEGORIES,
  APPEAL_ACTIONS,
};
