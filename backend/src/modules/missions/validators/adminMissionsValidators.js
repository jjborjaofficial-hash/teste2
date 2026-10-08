const { z } = require('zod');

const ROUND_MONEY_MESSAGE =
  'Missões de "completar rodada" não podem pagar dinheiro: a rodada conta mesmo sem acertos. Use XP e Pontos, ou uma missão de quizzes (que só conta respostas certas).';

const createMissionSchema = z.object({
  title: z.string().trim().min(3).max(120),
  description: z.string().trim().max(500).optional(),
  type: z.enum(['daily', 'weekly', 'special', 'sponsored']).default('daily'),
  categoryId: z.string().uuid().optional(),
  // Só tipos com lógica de progresso real e criáveis pelo admin (login, tempo ativo etc. vêm das migrations).
  activityType: z.enum(['quiz_count', 'round_complete']).default('quiz_count'),
  targetQuizCount: z.number().int().positive().default(1),
  xpReward: z.number().int().min(0).default(0),
  pointsReward: z.number().int().min(0).default(0),
  moneyRewardMzn: z.number().min(0).default(0),
  startsAt: z.string().datetime().optional(),
  endsAt: z.string().datetime().optional(),
}).refine((d) => !(d.activityType === 'round_complete' && d.moneyRewardMzn > 0), {
  // Uma rodada conta mesmo sem acertar nada: pagar dinheiro por ela premiaria responder ao acaso.
  message: ROUND_MONEY_MESSAGE,
  path: ['moneyRewardMzn'],
});

const updateMissionSchema = z.object({
  title: z.string().trim().min(3).max(120).optional(),
  description: z.string().trim().max(500).optional(),
  targetQuizCount: z.number().int().positive().optional(),
  xpReward: z.number().int().min(0).optional(),
  pointsReward: z.number().int().min(0).optional(),
  moneyRewardMzn: z.number().min(0).optional(),
  isActive: z.boolean().optional(),
  startsAt: z.string().datetime().optional(),
  endsAt: z.string().datetime().optional(),
});

module.exports = { createMissionSchema, updateMissionSchema, ROUND_MONEY_MESSAGE };
