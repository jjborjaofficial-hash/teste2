-- Migration 013: Novos tipos de notificação para o fluxo de saque
-- Referência: decisão do proprietário do projeto sobre o fluxo manual de pagamento —
-- o usuário recebe confirmação imediata (SLA de 24h), e o admin financeiro recebe
-- um alerta para processar a transferência manual (M-Pesa/e-Mola) para o número
-- de telefone já cadastrado na conta do usuário (Seção 16.1 do Doc. Mestre).

ALTER TABLE notifications DROP CONSTRAINT IF EXISTS notifications_type_check;

ALTER TABLE notifications
    ADD CONSTRAINT notifications_type_check
        CHECK (type IN (
            'streak_at_risk', 'mission_completed', 'milestone_reached',
            'withdrawal_status', 'weekly_ranking', 'system',
            'withdrawal_requested',      -- ao próprio usuário, na hora do pedido
            'withdrawal_new_admin'       -- ao(s) admin(s) financeiro, alerta de novo pedido
        ));
