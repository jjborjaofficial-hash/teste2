-- Migration 018: Relatórios Administrativos Diários + tipo de notificação de SLA de saque
-- Referência: docx "IMPLANTAÇÃO OFICIAL — REDIS CACHE E CRON JOBS", Cron Job 3 e 5.

ALTER TABLE notifications DROP CONSTRAINT IF EXISTS notifications_type_check;

ALTER TABLE notifications
    ADD CONSTRAINT notifications_type_check
        CHECK (type IN (
            'streak_at_risk', 'mission_completed', 'milestone_reached',
            'withdrawal_status', 'weekly_ranking', 'system',
            'withdrawal_requested', 'withdrawal_new_admin',
            'withdrawal_sla_risk' -- CRON: saque pendente há muito tempo, alerta o admin financeiro
        ));

-- Relatórios administrativos diários (Cron Job 5). Uma linha por dia — o CRON
-- roda uma vez às 06:00 e faz UPSERT, então rodar duas vezes no mesmo dia por
-- engano nunca duplica o relatório, apenas recalcula.
CREATE TABLE IF NOT EXISTS admin_daily_reports (
    id                          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    report_date                 DATE NOT NULL UNIQUE,
    new_users_count             INTEGER NOT NULL DEFAULT 0,
    active_users_count          INTEGER NOT NULL DEFAULT 0,
    -- Ad revenue: ainda não há integração real de anúncios (AdSense/AdCash) —
    -- ver README, seção "O que ainda não está implementado". Fica em NULL até
    -- essa integração existir, para não fingir um número que não é real.
    ad_revenue_mzn              NUMERIC(12,2),
    total_rewards_distributed_mzn NUMERIC(12,2) NOT NULL DEFAULT 0,
    total_withdrawals_count     INTEGER NOT NULL DEFAULT 0,
    total_withdrawals_amount_mzn NUMERIC(12,2) NOT NULL DEFAULT 0,
    suspicious_activity_count   INTEGER NOT NULL DEFAULT 0,
    generated_at                TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_admin_daily_reports_date ON admin_daily_reports (report_date DESC);
