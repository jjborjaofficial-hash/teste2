-- Seed de exemplo (NÃO é uma migration — rodar manualmente em dev/teste apenas).
-- Popula categorias, perguntas e uma missão diária para permitir testar o fluxo
-- completo do Quiz e Missões descrito nas Seções 5, 19.3 e 19.4 do Doc. Mestre.
--
-- Uso: psql $DATABASE_URL -f database/seeds/001_sample_content.sql

INSERT INTO categories (id, name, slug, description, icon_key) VALUES
    (uuid_generate_v4(), 'Finanças', 'financas', 'Educação financeira básica e avançada', 'wallet'),
    (uuid_generate_v4(), 'Tecnologia', 'tecnologia', 'Conceitos gerais de tecnologia', 'quiz'),
    (uuid_generate_v4(), 'Inteligência Artificial', 'inteligencia-artificial', 'Fundamentos de IA', 'quiz')
ON CONFLICT (slug) DO NOTHING;

-- Pergunta de exemplo na categoria Finanças
WITH cat AS (SELECT id FROM categories WHERE slug = 'financas' LIMIT 1),
     q AS (
        INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward)
        SELECT id, 'easy', 'O que significa "juros compostos"?', 15, 10 FROM cat
        RETURNING id
     )
INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
SELECT id, alt.label, alt.is_correct, alt.ord
FROM q, (VALUES
    ('Juros calculados apenas sobre o valor inicial', FALSE, 1),
    ('Juros calculados sobre o valor inicial mais os juros acumulados', TRUE, 2),
    ('Um tipo de imposto bancário', FALSE, 3),
    ('Uma taxa fixa cobrada uma única vez', FALSE, 4)
) AS alt(label, is_correct, ord);

-- Pergunta de exemplo na categoria Tecnologia
WITH cat AS (SELECT id FROM categories WHERE slug = 'tecnologia' LIMIT 1),
     q AS (
        INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward)
        SELECT id, 'easy', 'O que é a "nuvem" (cloud computing)?', 15, 10 FROM cat
        RETURNING id
     )
INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
SELECT id, alt.label, alt.is_correct, alt.ord
FROM q, (VALUES
    ('Um tipo de conexão Bluetooth', FALSE, 1),
    ('Armazenamento e processamento de dados via internet, em servidores remotos', TRUE, 2),
    ('Um vírus de computador', FALSE, 3),
    ('Uma marca de smartphone', FALSE, 4)
) AS alt(label, is_correct, ord);

-- Missão diária de exemplo (Seção 19.2: "Complete 1 Quiz de Finanças hoje")
WITH cat AS (SELECT id FROM categories WHERE slug = 'financas' LIMIT 1)
INSERT INTO missions (title, description, type, category_id, target_quiz_count, xp_reward, points_reward, money_reward_mzn)
SELECT 'Quiz Diário de Finanças', 'Complete 1 Quiz de Finanças hoje', 'daily', id, 1, 20, 10, 0
FROM cat;
