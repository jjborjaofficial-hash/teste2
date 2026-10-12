-- Catálogo diário novo (pedido do dono, 11/10). 6 missões ativas:
--   1 Entrar na plataforma (login)                      1,20 MZN  (já existia)
--   2 20 minutos de estudo (antes 12)                   1,20 MZN
--   3 Acertar 50 perguntas, qualquer categoria (antes 10) 1,20 MZN
--   4 Acertar 30 perguntas em pelo menos 3 categorias (NOVA) 1,20 MZN
--   5 Convidar 1 utilizador novo por link (NOVA)        0 MZN (só XP e pontos: ver nota)
--   6 Explorador: 3 categorias diferentes               1,20 MZN  (já existia)
-- As outras missões diárias ficam desativadas (a lógica delas continua no código).
-- Nota da missão 5: um convite pago em dinheiro todos os dias podia ser explorado com contas
-- falsas; por isso não paga MZN. O dono pode mudar o valor no painel de admin.

ALTER TABLE missions ADD COLUMN IF NOT EXISTS min_distinct_categories INTEGER NOT NULL DEFAULT 1
  CHECK (min_distinct_categories >= 1);

ALTER TABLE missions DROP CONSTRAINT IF EXISTS missions_activity_type_check;
ALTER TABLE missions ADD CONSTRAINT missions_activity_type_check CHECK (activity_type::text = ANY (ARRAY[
  'login','time_active_minutes','lesson_complete','quiz_count','category_exploration','challenge','round_complete','referral'
]::text[]));

-- Desativa todas as diárias antigas; as 3 que se mantêm são reativadas abaixo.
UPDATE missions SET is_active = FALSE WHERE type = 'daily' AND is_active = TRUE;

-- 1) login: mantém
UPDATE missions SET is_active = TRUE, title = 'Fazer login', description = 'Entre na plataforma hoje.'
 WHERE type = 'daily' AND activity_type = 'login' AND title = 'Entrar na plataforma';

-- 2) 20 minutos
UPDATE missions SET is_active = TRUE, target_quiz_count = 20, title = '20 minutos de estudo',
       description = 'Fique 20 minutos ativo na plataforma hoje.'
 WHERE type = 'daily' AND activity_type = 'time_active_minutes' AND title = '12 minutos de estudo';

-- 3) 50 acertos (a antiga "Maratona")
UPDATE missions SET is_active = TRUE, target_quiz_count = 50, title = 'Acerte 50 perguntas',
       description = 'Acerte 50 perguntas hoje, em qualquer categoria.'
 WHERE type = 'daily' AND activity_type = 'quiz_count' AND category_id IS NULL AND title = 'Maratona';

-- 6) Explorador: mantém
UPDATE missions SET is_active = TRUE
 WHERE type = 'daily' AND activity_type = 'category_exploration' AND title = 'Explorador';

-- 4) 30 acertos em pelo menos 3 categorias (NOVA)
INSERT INTO missions (title, description, type, category_id, target_quiz_count, xp_reward, points_reward,
                      money_reward_mzn, is_active, activity_type, min_distinct_categories)
SELECT 'Acerte 30 em 3 categorias', 'Acerte 30 perguntas hoje, em pelo menos 3 categorias diferentes.',
       'daily', NULL, 30, 30, 15, 1.20, TRUE, 'quiz_count', 3
WHERE NOT EXISTS (SELECT 1 FROM missions WHERE title = 'Acerte 30 em 3 categorias');

-- 5) Convidar 1 utilizador novo (NOVA)
INSERT INTO missions (title, description, type, category_id, target_quiz_count, xp_reward, points_reward,
                      money_reward_mzn, is_active, activity_type)
SELECT 'Convide um amigo', 'Convide 1 pessoa nova pelo seu link. Conta quando ela responder aos primeiros quizzes.',
       'daily', NULL, 1, 30, 15, 0, TRUE, 'referral'
WHERE NOT EXISTS (SELECT 1 FROM missions WHERE title = 'Convide um amigo');
