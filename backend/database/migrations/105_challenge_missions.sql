-- Migration 105: 4 missões-desafio diárias (substituem as "3 quizzes por categoria").
-- Cada uma testa um objetivo diferente do utilizador.
UPDATE missions
SET is_active = FALSE
WHERE type = 'daily'
  AND title IN ('3 quizzes de Finanças', '3 quizzes de Tecnologia',
                '3 quizzes de Marketing Digital', '3 quizzes de Produtividade');

INSERT INTO missions (title, description, type, category_id, target_quiz_count, activity_type,
                      xp_reward, points_reward, money_reward_mzn, is_active)
SELECT v.title, v.description, 'daily', (SELECT id FROM categories WHERE slug = v.slug),
       v.target, v.activity_type, v.xp, v.points, 1.20, TRUE
FROM (VALUES
  ('Aquecimento',     'Acerte 3 perguntas em qualquer categoria.',                   NULL::text, 3,  'quiz_count',           20, 10),
  ('Explorador',      'Experimente 3 categorias diferentes hoje.',                   NULL::text, 3,  'category_exploration', 25, 10),
  ('Foco em Finanças','Acerte 3 perguntas de Finanças e reforce a sua educação financeira.', 'financas', 3, 'quiz_count',     25, 10),
  ('Maratona',        'O grande desafio do dia: acerte 10 perguntas.',               NULL::text, 10, 'quiz_count',           40, 20)
) AS v(title, description, slug, target, activity_type, xp, points)
WHERE NOT EXISTS (SELECT 1 FROM missions m WHERE m.title = v.title AND m.type = 'daily');
