const { z } = require('zod');

const createCategorySchema = z.object({
  name: z.string().trim().min(2).max(60),
  description: z.string().trim().max(500).optional(),
  iconKey: z.string().trim().max(40).optional(),
});

const updateCategorySchema = z.object({
  name: z.string().trim().min(2).max(60).optional(),
  description: z.string().trim().max(500).optional(),
  iconKey: z.string().trim().max(40).optional(),
  isActive: z.boolean().optional(),
});

const alternativeSchema = z.object({
  label: z.string().trim().min(1).max(300),
  isCorrect: z.boolean(),
});

const createQuestionSchema = z.object({
  categoryId: z.string().uuid(),
  difficulty: z.enum(['easy', 'medium', 'hard']).default('medium'),
  statement: z.string().trim().min(5).max(500),
  timeLimitSeconds: z.number().int().positive().max(120).default(15),
  xpReward: z.number().int().min(0).default(10),
  alternatives: z.array(alternativeSchema).min(2).max(6),
});

const updateQuestionSchema = z.object({
  statement: z.string().trim().min(5).max(500).optional(),
  difficulty: z.enum(['easy', 'medium', 'hard']).optional(),
  timeLimitSeconds: z.number().int().positive().max(120).optional(),
  xpReward: z.number().int().min(0).optional(),
  isActive: z.boolean().optional(),
  alternatives: z.array(alternativeSchema).min(2).max(6).optional(),
});

module.exports = { createCategorySchema, updateCategorySchema, createQuestionSchema, updateQuestionSchema };
