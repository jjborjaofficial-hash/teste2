-- Migration 722: notificação do bónus de convite (pedido do dono, 21/10/2026).
-- Cada vez que um convidado resgata uma missão diária, quem o convidou recebe o bónus (migration 720) e agora
-- também uma notificação: "Recebeste 0,24 MZN pela comissão do convite, utilizador [nome]".
-- A lista abaixo é a da migration 030 mais o tipo novo (a tabela só aceita tipos registados).

BEGIN;

ALTER TABLE notifications DROP CONSTRAINT IF EXISTS notifications_type_check;
ALTER TABLE notifications
    ADD CONSTRAINT notifications_type_check
        CHECK (type IN (
            'streak_at_risk', 'mission_completed', 'milestone_reached',
            'withdrawal_status', 'weekly_ranking', 'system',
            'withdrawal_requested', 'withdrawal_new_admin', 'withdrawal_sla_risk',
            'daily_earning_cap_reached', 'points_converted', 'item_expiring_soon',
            'referral_bonus_received'
        ));

COMMIT;
