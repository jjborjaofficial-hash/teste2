const { z } = require('zod');

const createMissionSchema = z.object({
  title: z.string().trim().min(3).max(120),
  description: z.string().trim().max(500).optional(),
  type: z.enum(['daily', 'weekly', 'special', 'sponsored']).default('daily'),
  categoryId: z.string().uuid().optional(),
  targetQuizCount: z.number().int().positive().default(1),
  xpReward: z.number().int().min(0).default(0),
  pointsReward: z.number().int().min(0).default(0),
  moneyRewardMzn: z.number().min(0).default(0),
  startsAt: z.string().datetime().optional(),
  endsAt: z.string().datetime().optional(),
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

module.exports = { createMissionSchema, updateMissionSchema };
