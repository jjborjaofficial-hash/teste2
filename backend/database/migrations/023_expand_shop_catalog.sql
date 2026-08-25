-- Migration 023: Expansão do catálogo da Loja — itens de valor real dentro
-- da economia da plataforma, sem violar a regra de não acelerar XP nem
-- dinheiro real diretamente (mesmo princípio da migration 020).
--
-- MOLDURAS POR CATEGORIA: recompensa de identidade visual para quem se
-- aprofunda numa área específica das 5 categorias oficiais (Doc. Mestre
-- Seção 5) — hoje a única forma de "flexar" progresso é o streak; isso dá
-- um caminho de personalização para quem prefere estudar fundo uma área em
-- vez de manter sequência diária.
--
-- SELO DE 100 DIAS: o Doc. Mestre já prevê o marco de 100 dias de streak
-- como "Grande prêmio financeiro e posição de destaque na comunidade"
-- (Seção 5), mas nunca virou um item comprável de fato — corrigido aqui.
-- eligibility_rule = 'streak_100_days' checa longest_streak_days >= 100
-- (não current_streak_days: é uma conquista permanente, não deve desaparecer
-- do catálogo elegível só porque o usuário faltou um dia depois de alcançá-la).

INSERT INTO shop_items (key, category, name, description, price_points, effect_key, eligibility_rule) VALUES
    (
        'frame_financas', 'cosmetic', 'Moldura Financista',
        'Moldura verde-esmeralda com ícone de moeda, para quem domina Finanças.',
        120, NULL, NULL
    ),
    (
        'frame_tecnologia', 'cosmetic', 'Moldura Tech',
        'Moldura azul-circuito para especialistas em Tecnologia.',
        120, NULL, NULL
    ),
    (
        'frame_ia', 'cosmetic', 'Moldura IA',
        'Moldura roxa com padrão de rede neural, para quem manda bem em Inteligência Artificial.',
        120, NULL, NULL
    ),
    (
        'frame_marketing', 'cosmetic', 'Moldura Growth',
        'Moldura rosa-vibrante para quem se destaca em Marketing Digital.',
        120, NULL, NULL
    ),
    (
        'frame_produtividade', 'cosmetic', 'Moldura Foco',
        'Moldura âmbar minimalista para quem domina Produtividade.',
        120, NULL, NULL
    ),
    (
        'badge_streak_100', 'prestige', 'Selo Lenda dos 100 Dias',
        'O selo mais raro da plataforma — só pode ser comprado por quem já alcançou 100 dias de streak (Doc. Mestre, marco de Ofensiva). Fica no perfil para sempre.',
        500, NULL, 'streak_100_days'
    )
ON CONFLICT (key) DO NOTHING;
