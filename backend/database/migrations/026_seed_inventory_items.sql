-- Migration 026: primeiros itens do inventário — 1 consumível, 1 temporário.
--
-- Coin Boost multiplica só PONTOS (moeda soft), nunca XP — decisão que
-- resolve o conflito da spec original (que usava "XP Boost" como exemplo)
-- com o princípio já estabelecido nas migrations 020/023 de nunca acelerar
-- XP nem dinheiro real diretamente. XP alimenta nível/ranking/prestígio;
-- Pontos são só a moeda de troca da Loja — multiplicar Pontos não dá
-- vantagem competitiva a ninguém, só acelera o acesso a mais itens da loja.

INSERT INTO shop_items (key, category, name, description, price_points, effect_key, is_consumable, duration_seconds) VALUES
    (
        'streak_shield', 'functional', 'Streak Shield',
        'Protege sua sequência: se você faltar um dia, o streak não quebra. Fica guardado no seu inventário até você decidir usar.',
        60, 'streak_protection', TRUE, NULL
    ),
    (
        'coin_boost_2x', 'functional', 'Coin Boost 2x',
        'Ativa por 2 horas: todo Ponto que você ganhar em quizzes e missões nesse período vem em dobro. Não afeta XP nem ranking — só Pontos.',
        100, 'points_multiplier_2x', FALSE, 7200
    )
ON CONFLICT (key) DO NOTHING;
