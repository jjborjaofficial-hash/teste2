const { z } = require('zod');

// responseTimeMs deixou de ser aceito do cliente (era a falha antifraude
// crítica: o backend confiava cegamente no valor informado pelo usuário).
// O tempo de resposta agora é medido inteiramente pelo servidor — ver
// quizTimerService.consumeElapsedMs.
const submitAnswerSchema = z.object({
  questionId: z.string().uuid('ID de pergunta inválido'),
  alternativeId: z.string().uuid('ID de alternativa inválido'),
});

module.exports = { submitAnswerSchema };
