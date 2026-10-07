const { z } = require('zod');

// responseTimeMs deixou de ser aceito do cliente (era a falha antifraude
// crítica: o backend confiava cegamente no valor informado pelo usuário).
// O tempo de resposta agora é medido inteiramente pelo servidor — ver
// quizTimerService.consumeElapsedMs.
const submitAnswerSchema = z.object({
  questionId: z.string().uuid('ID de pergunta inválido'),
  alternativeId: z.string().uuid('ID de alternativa inválido'),
  // Quiz v2: quando a resposta pertence a uma rodada, o servidor valida que é a pergunta atual.
  roundId: z.string().uuid('ID de rodada inválido').optional(),
});

const startRoundSchema = z.object({
  categoryId: z.string().uuid('ID de categoria inválido'),
});

// BE-005 c: parâmetros das rotas de revisão (um roundId inválido não pode chegar ao banco como erro 500).
const roundIdParamSchema = z.object({ roundId: z.string().uuid('ID de rodada inválido') });

const recommendationsQuerySchema = z.object({
  categoryId: z.string().uuid('ID de categoria inválido').optional(),
  limit: z.coerce.number().int().min(1).max(20).default(10),
});

module.exports = { submitAnswerSchema, startRoundSchema, roundIdParamSchema, recommendationsQuerySchema };
