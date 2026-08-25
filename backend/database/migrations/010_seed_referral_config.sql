-- Migration 010: Configuração de Recompensa de Indicação
-- Referência: Manual Parte 3 (módulo Convites/Indicações) — regras de valor ainda
-- não formalizadas oficialmente (mesma situação da Seção 23.1.5 do Doc. Mestre).

INSERT INTO system_config (key, value, description) VALUES
    ('referral_reward_points', '100',
     'Placeholder: pontos concedidos ao indicador quando o indicado completa a qualificação. Pendente de aprovação.'),
    ('referral_qualification_quiz_count', '5',
     'Placeholder: número de quizzes que o indicado deve completar para qualificar a indicação. Pendente de aprovação.')
ON CONFLICT (key) DO NOTHING;
