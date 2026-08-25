-- Migration 007: Saques, Ranking Semanal e Configurações do Sistema
-- Referência: Doc. Mestre Seção 16.3 (teto de saque), 9 (Ranking Semanal) | Manual Parte 4

-- Configurações do sistema — permite ajustar regras (ex: teto de saque) sem deploy de código
CREATE TABLE IF NOT EXISTS system_config (
    key             VARCHAR(60) PRIMARY KEY,
    value           JSONB NOT NULL,
    description     TEXT,
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_system_config_updated_at
    BEFORE UPDATE ON system_config
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Valor inicial: teto de saque diário/mínimo citado na Seção 16.3 do Doc. Mestre (7,20 MZN)
INSERT INTO system_config (key, value, description) VALUES
    ('withdrawal_min_mzn', '7.20', 'Valor mínimo de saque em MZN (Seção 16.3 do Doc. Mestre)'),
    ('withdrawal_daily_cap_mzn', '7.20', 'Teto diário de saque por usuário em MZN'),
    ('min_trust_score_for_withdrawal', '60', 'Trust Score mínimo exigido para liberar saque')
ON CONFLICT (key) DO NOTHING;

-- Solicitações de saque (o crédito em si já existe como wallet_transactions type=debit,
-- esta tabela controla o ciclo de vida do pedido perante o Trust Score e o gateway de pagamento)
CREATE TABLE IF NOT EXISTS withdrawal_requests (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    amount_mzn          NUMERIC(12,2) NOT NULL CHECK (amount_mzn > 0),
    method              VARCHAR(10) NOT NULL CHECK (method IN ('mpesa', 'emola')),
    status              VARCHAR(20) NOT NULL DEFAULT 'pending_review'
                        CHECK (status IN ('pending_review', 'approved', 'rejected', 'paid', 'failed')),
    trust_score_at_request SMALLINT NOT NULL,
    wallet_transaction_id UUID REFERENCES wallet_transactions(id),
    rejection_reason     TEXT,
    requested_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    resolved_at          TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_withdrawals_user ON withdrawal_requests (user_id, requested_at);
CREATE INDEX IF NOT EXISTS idx_withdrawals_status ON withdrawal_requests (status);

-- Ranking semanal (materializado periodicamente por CRON job — Parte 3 do Manual)
CREATE TABLE IF NOT EXISTS weekly_rankings (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    week_start_date DATE NOT NULL,
    xp_earned       BIGINT NOT NULL DEFAULT 0,
    position        INTEGER,
    computed_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_weekly_ranking_user_week
    ON weekly_rankings (user_id, week_start_date);
CREATE INDEX IF NOT EXISTS idx_weekly_rankings_week_position
    ON weekly_rankings (week_start_date, position);
