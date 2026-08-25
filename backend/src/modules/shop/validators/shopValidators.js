const { z } = require('zod');

const purchaseSchema = z.object({
  itemKey: z.string().trim().min(1).max(40),
});

const equipSchema = z.object({
  itemKey: z.string().trim().min(1).max(40),
});

const unequipSchema = z.object({
  slot: z.enum(['frame', 'theme'], { errorMap: () => ({ message: 'Slot deve ser "frame" ou "theme".' }) }),
});

const createItemSchema = z.object({
  key: z.string().trim().min(1).max(40),
  category: z.enum(['functional', 'cosmetic', 'prestige']),
  name: z.string().trim().min(1).max(120),
  description: z.string().trim().max(500).optional(),
  pricePoints: z.number().int().positive(),
  effectKey: z.enum(['streak_protection', 'streak_recovery']).optional(),
  eligibilityRule: z.enum(['top10_ranking']).optional(),
});

const updateItemSchema = z.object({
  name: z.string().trim().min(1).max(120).optional(),
  description: z.string().trim().max(500).optional(),
  pricePoints: z.number().int().positive().optional(),
  isActive: z.boolean().optional(),
});

module.exports = { purchaseSchema, equipSchema, unequipSchema, createItemSchema, updateItemSchema };
