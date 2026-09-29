-- Migration 105: Bónus de boas-vindas (primeiros 7 dias) + 4 missões-desafio.
--
-- BÓNUS DE BOAS-VINDAS
--  * Janela: os 7 primeiros dias corridos da conta (fuso de Moçambique).
--  * Cada dia em que o utilizador ACERTA ao menos uma pergunta (estudo real,
--    não apenas abrir o app) paga o bónus do dia: 0,50 MZN.
--  * Estudando em 5 dos 7 dias, paga ainda o bónus de conclusão: 3,50 MZN.
--  * Máximo: 7 x 0,50 + 3,50 = 7,00 MZN por conta, uma única vez.
--  * Não conta no teto diário de 7,20 MZN (é promoção única, não missão/streak),
--    e por isso o utilizador nunca perde o bónus só porque já bateu o teto.
--  * Idempotente por construção: PRIMARY KEY (user_id, day_index) impede pagar
--    duas vezes o mesmo dia, mesmo com pedidos simultâneos.
CREATE TABLE IF NOT EXISTS welcome_bonus_days (
    user_id      UUID          NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    -- 0..6 = dia de estudo dentro da janela; 7 = conclusão da semana (bónus extra)
    day_index    SMALLINT      NOT NULL CHECK (day_index BETWEEN 0 AND 7),
    credited_mzn NUMERIC(10,2) NOT NULL CHECK (credited_mzn >= 0),
    created_at   TIMESTAMPTZ   NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, day_index)
);

INSERT INTO system_config (key, value, description) VALUES
  ('welcome_bonus_enabled',       'true',  'Liga/desliga o bónus de boas-vindas dos 7 primeiros dias'),
  ('welcome_bonus_daily_mzn',     '0.50',  'MZN pagos por cada dia de estudo dentro dos 7 primeiros dias da conta'),
  ('welcome_bonus_completion_mzn','3.50',  'MZN extra ao estudar o mínimo de dias da semana de boas-vindas'),
  ('welcome_bonus_required_days', '5',     'Dias de estudo (de 7) necessários para o bónus de conclusão')
ON CONFLICT (key) DO NOTHING;

-- MISSÕES-DESAFIO: substituem as 4 missões "3 quizzes por categoria" por desafios
-- com objetivos diferentes (cada uma testa uma coisa distinta do utilizador).
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
