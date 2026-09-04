-- Migration 027: Seed de Missões Diárias Oficiais
-- Referência: Doc. Mestre Seção 5, 6 e 8 (Painel Principal — "Missões
-- Diárias: lista rápida, ex.: 'Complete 1 Quiz de Finanças hoje'").
--
-- DIAGNÓSTICO: assim como a migration 021 resolveu o Hub de Estudos vazio
-- (categorias existiam só num seed manual de desenvolvimento), este é o
-- mesmo problema aplicado a Missões. O motor de auto-atribuição já existe
-- e funciona (missionsService.listMyMissions -> repository.
-- assignMissionIfNotPresent, chamado a cada GET /missions), mas não havia
-- NENHUMA linha na tabela `missions` para atribuir — um banco criado do
-- zero (`npm run migrate:up`) sempre mostraria "Nenhuma missão disponível",
-- em qualquer ambiente, para todo usuário, indefinidamente.
--
-- Esta migration garante missões diárias oficiais sempre presentes,
-- usando apenas activity_type já implementados no motor de progresso
-- (missionProgressService.js): 'login', 'quiz_count' e
-- 'category_exploration'. Não usa 'lesson_complete' nem
-- 'time_active_minutes' propositalmente — esses ainda não têm lógica de
-- progresso real (dependem de módulos que não existem: microaulas e
-- heartbeat de atividade), e uma missão que nunca pode ser concluída seria
-- pior do que nenhuma missão.
--
-- is_active = TRUE e starts_at/ends_at NULL = sempre disponíveis (a rotação
-- diária em si já é garantida pela UNIQUE(user_id, mission_id, period_date)
-- da migration 022: cada usuário recebe uma atribuição nova por dia).

INSERT INTO missions (title, description, type, category_id, target_quiz_count, activity_type, xp_reward, points_reward, money_reward_mzn, is_active)
VALUES
    (
        'Acesso Diário',
        'Entre na plataforma hoje para manter sua ofensiva viva.',
        'daily',
        NULL,
        1,
        'login',
        10,
        5,
        0,
        TRUE
    ),
    (
        'Quiz de Finanças',
        'Complete 1 quiz de Finanças hoje.',
        'daily',
        (SELECT id FROM categories WHERE slug = 'financas'),
        1,
        'quiz_count',
        20,
        10,
        0,
        TRUE
    ),
    (
        'Quiz de Tecnologia',
        'Complete 1 quiz de Tecnologia hoje.',
        'daily',
        (SELECT id FROM categories WHERE slug = 'tecnologia'),
        1,
        'quiz_count',
        20,
        10,
        0,
        TRUE
    ),
    (
        'Explorador do Dia',
        'Experimente 2 categorias diferentes hoje.',
        'daily',
        NULL,
        2,
        'category_exploration',
        15,
        10,
        0,
        TRUE
    )
ON CONFLICT DO NOTHING;
