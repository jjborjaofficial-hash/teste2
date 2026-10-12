-- Convites: defesas contra contas falsas (a missão "Convide um amigo" paga dinheiro real, migration 603).
--
-- A regra antiga bastava com 5 respostas certas de qualquer tipo, sem limite de convites por pessoa.
-- Passa a exigir, além das 5 certas (referral_qualification_quiz_count, já existente):
--   1) que o convidado tenha CONCLUÍDO pelo menos N rodadas (custa mais esforço a uma conta falsa);
--   2) que o Trust Score do convidado seja pelo menos o mínimo (quem responde depressa demais perde confiança);
--   3) um limite de convites recompensados por convidador, por dia (calendário de Maputo).
-- Quando uma defesa impede, o convite fica PENDENTE e volta a ser avaliado mais tarde (nada se perde).
-- Valores iniciais prudentes; o dono pode ajustar em system_config sem mexer no código.

INSERT INTO system_config (key, value, description) VALUES
    ('referral_min_completed_rounds', '1',
     'Convites: rodadas completas que o convidado precisa ter para o convite qualificar (além das respostas certas).'),
    ('referral_min_trust_score', '60',
     'Convites: Trust Score mínimo do convidado para o convite qualificar (igual ao mínimo da conversão de Pontos).'),
    ('referral_max_rewards_per_referrer_per_day', '5',
     'Convites: máximo de convites recompensados por convidador em cada dia (calendário de Maputo). Acima disso o convite fica pendente.')
ON CONFLICT (key) DO NOTHING;
