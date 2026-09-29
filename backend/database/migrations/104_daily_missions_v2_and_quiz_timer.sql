-- Migration 104: Missões diárias v2 (6 missões x 1,20 MZN = teto 7,20 MZN/dia),
-- tempo de 30 segundos por pergunta e suporte a "minutos ativos" (heartbeat).
--
-- Regras (notas do proprietário):
--  * 6 missões diárias, cada uma paga 1,20 MZN (6 x 1,20 = 7,20 = daily_earning_cap_mzn).
--  * 2 de retenção: fazer login e ficar 12 minutos ativo na plataforma.
--  * 4 dependem de completar 3 quizzes (uma por categoria).
--  * 30 segundos para responder cada pergunta.

-- 1) Tempo ativo real: o servidor soma os segundos entre heartbeats consecutivos
--    (o cliente nunca envia um valor de tempo, então não dá para adulterar).
ALTER TABLE user_missions
  ADD COLUMN IF NOT EXISTS active_seconds INTEGER NOT NULL DEFAULT 0 CHECK (active_seconds >= 0),
  ADD COLUMN IF NOT EXISTS last_heartbeat_at TIMESTAMPTZ;

-- 2) 30 segundos por pergunta (default + todas as perguntas existentes).
ALTER TABLE questions ALTER COLUMN time_limit_seconds SET DEFAULT 30;
UPDATE questions SET time_limit_seconds = 30 WHERE time_limit_seconds <> 30;

-- 3) Substitui o catálogo diário antigo (4 missões com recompensa 0 MZN) pelo novo.
UPDATE missions
SET is_active = FALSE
WHERE type = 'daily'
  AND title IN ('Acesso Diário', 'Quiz de Finanças', 'Quiz de Tecnologia', 'Explorador do Dia');

INSERT INTO missions (title, description, type, category_id, target_quiz_count, activity_type,
                      xp_reward, points_reward, money_reward_mzn, is_active)
SELECT v.title, v.description, 'daily', (SELECT id FROM categories WHERE slug = v.slug),
       v.target, v.activity_type, v.xp, v.points, 1.20, TRUE
FROM (VALUES
  ('Entrar na plataforma',  'Faça login hoje.',                                   NULL::text,          1,  'login',               10, 5),
  ('12 minutos de estudo',  'Fique 12 minutos ativo na plataforma hoje.',         NULL::text,          12, 'time_active_minutes', 15, 5),
  ('3 quizzes de Finanças', 'Acerte 3 quizzes de Finanças hoje.',                 'financas',          3,  'quiz_count',          20, 10),
  ('3 quizzes de Tecnologia','Acerte 3 quizzes de Tecnologia hoje.',              'tecnologia',        3,  'quiz_count',          20, 10),
  ('3 quizzes de Marketing Digital','Acerte 3 quizzes de Marketing Digital hoje.','marketing-digital', 3,  'quiz_count',          20, 10),
  ('3 quizzes de Produtividade','Acerte 3 quizzes de Produtividade hoje.',        'produtividade',     3,  'quiz_count',          20, 10)
) AS v(title, description, slug, target, activity_type, xp, points)
WHERE NOT EXISTS (SELECT 1 FROM missions m WHERE m.title = v.title AND m.type = 'daily');
