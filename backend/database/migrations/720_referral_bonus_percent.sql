-- Migration 720: bónus de convite — 20% do que o convidado ganha nas missões diárias.
-- Regra decidida pelo dono em 2026-10-12: quem convida recebe, PARA SEMPRE, 20% do valor em MZN que cada
-- convidado ganha nas MISSÕES DIÁRIAS. É um extra pago pela plataforma (não sai da conta do convidado) e fica
-- FORA do teto diário de 7,20 MZN de quem convida (o teto só soma `mission_reward`; o bónus usa a fonte
-- `referral_bonus`). Só conta depois de o convite estar qualificado (status 'rewarded', ou seja, o convidado
-- já respondeu o número de quizzes pedido), para não pagar por contas que nunca chegam a estudar.
-- A percentagem fica em system_config para poder mudar sem alterar código (0 desliga o bónus).

INSERT INTO system_config (key, value, description) VALUES
    ('referral_bonus_percent', '20',
     'Percentagem (do MZN que o convidado ganha nas missões diárias) paga como bónus a quem o convidou. 0 desliga.')
ON CONFLICT (key) DO NOTHING;
