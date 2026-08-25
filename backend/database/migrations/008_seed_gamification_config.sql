-- Migration 008: Configuração inicial de Gamificação e Streak
-- Referência: Doc. Mestre Seção 5 (Tabela de Marcos de Ofensiva) e Seção 23.1.5
-- (Economia da Plataforma — Status: Pendente. Fórmulas de conversão XP->MZN ainda
-- não formalizadas oficialmente pelo negócio).
--
-- IMPORTANTE: os valores abaixo são PLACEHOLDERS técnicos para permitir que o sistema
-- funcione de ponta a ponta em ambiente de desenvolvimento/teste. Eles NÃO substituem
-- a formalização oficial pendente na Seção 21 ("Documento Oficial da Economia").
-- Antes de produção, o proprietário do projeto deve revisar e aprovar estes valores.

INSERT INTO system_config (key, value, description) VALUES
    ('level_xp_step', '500',
     'XP necessário por nível (fórmula placeholder: nível = piso(xp_total / step) + 1). Pendente de aprovação oficial.'),

    ('streak_milestone_7_points', '50',
     'Placeholder: bônus de pontos ao atingir 7 dias de ofensiva (Seção 5). Pendente de aprovação.'),
    ('streak_milestone_15_points', '100',
     'Placeholder: bônus de pontos ao atingir 15 dias + item de proteção do streak. Pendente de aprovação.'),
    ('streak_milestone_30_points', '150',
     'Placeholder: bônus de pontos ao atingir 30 dias. Pendente de aprovação.'),
    ('streak_milestone_30_money_mzn', '2.00',
     'Placeholder: recompensa em dinheiro real ao atingir 30 dias. Pendente de aprovação.'),
    ('streak_milestone_60_money_mzn', '5.00',
     'Placeholder: recompensa em dinheiro real ao atingir 60 dias. Pendente de aprovação.'),
    ('streak_milestone_100_points', '500',
     'Placeholder: bônus de pontos ao atingir 100 dias. Pendente de aprovação.'),
    ('streak_milestone_100_money_mzn', '20.00',
     'Placeholder: grande prêmio financeiro ao atingir 100 dias. Pendente de aprovação.')
ON CONFLICT (key) DO NOTHING;
