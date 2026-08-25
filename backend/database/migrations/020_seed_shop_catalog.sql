-- Migration 020: Seed do catálogo inicial da Loja de Pontos
-- Catálogo definido em conversa com o proprietário do projeto: itens
-- funcionais (reaproveitam mecânicas já existentes), cosméticos (identidade
-- visual, sem risco à economia) e de prestígio (status, com pré-requisito).
--
-- Preços são intencionalmente moderados: hoje Pontos só vêm de missões
-- (variável), marcos de streak (50 a 500) e indicações (100) — não de cada
-- quiz respondido. Preços altos demais tornariam a loja inacessível e
-- "sobrecarregariam" o usuário (frustração), o oposto do pedido.
-- Todos os preços podem ser ajustados depois pelo Painel Administrativo, sem
-- precisar de deploy.

INSERT INTO shop_items (key, category, name, description, price_points, effect_key, eligibility_rule) VALUES
    (
        'streak_protection', 'functional', 'Proteção de Streak',
        'Protege sua sequência atual: se você faltar um dia, o streak não quebra. Efeito imediato, dura até ser usado.',
        80, 'streak_protection', NULL
    ),
    (
        'streak_recovery', 'functional', 'Recuperar Streak',
        'Restaura uma sequência quebrada recentemente. Só funciona até 24h depois de quebrar — não é possível recuperar streaks mais antigos.',
        200, 'streak_recovery', NULL
    ),
    (
        'frame_streak', 'cosmetic', 'Moldura de Chama',
        'Uma moldura dourada com efeito de chama ao redor da sua foto de perfil, para quem leva o streak a sério.',
        150, NULL, NULL
    ),
    (
        'frame_champion', 'cosmetic', 'Moldura de Campeão',
        'Moldura exclusiva com estrelas, para destacar seu nível na plataforma.',
        250, NULL, NULL
    ),
    (
        'theme_night', 'cosmetic', 'Tema Noite',
        'Muda as cores do aplicativo inteiro para um visual escuro, mantendo o contraste de acessibilidade (WCAG AA).',
        200, NULL, NULL
    ),
    (
        'badge_top10', 'prestige', 'Selo Top 10 do Ranking',
        'Um selo exclusivo no seu perfil e no ranking. Só pode ser comprado enquanto você estiver entre os 10 primeiros do ranking semanal.',
        300, NULL, 'top10_ranking'
    )
ON CONFLICT (key) DO NOTHING;
