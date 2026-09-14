-- Migration 027: notificação de teto de ganho diário atingido
-- Referência: docs/reaceite-termos-e-correcao-regras-saque.md, seção
-- "Limitações que continuam" — "Não há alerta automático se o teto de ganho
-- diário for atingido... Poderia virar uma notificação futura." Esta
-- migration + o gancho em walletService.creditReward fecham essa pendência.

ALTER TABLE notifications DROP CONSTRAINT IF EXISTS notifications_type_check;

ALTER TABLE notifications
    ADD CONSTRAINT notifications_type_check
        CHECK (type IN (
            'streak_at_risk', 'mission_completed', 'milestone_reached',
            'withdrawal_status', 'weekly_ranking', 'system',
            'withdrawal_requested', 'withdrawal_new_admin',
            'daily_earning_cap_reached'
        ));
