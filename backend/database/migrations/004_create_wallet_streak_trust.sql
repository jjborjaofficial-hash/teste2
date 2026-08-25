-- Migration 004: Carteira (ledger imutável), Streak e Histórico de Trust Score
-- Referência: Doc. Mestre Seção 11 (Transações), Seção 5 (Streak), Seção 7 (Trust Score)
-- Manual Parte 4: histórico financeiro deve ser imutável (append-only / livro-razão)

CREATE TABLE IF NOT EXISTS wallet_transactions (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    type            VARCHAR(20) NOT NULL CHECK (type IN ('credit', 'debit')),
    source          VARCHAR(40) NOT NULL, -- ex: 'mission_reward', 'streak_bonus', 'withdrawal'
    amount_mzn      NUMERIC(12,2) NOT NULL CHECK (amount_mzn > 0),
    balance_after   NUMERIC(12,2) NOT NULL CHECK (balance_after >= 0),
    status          VARCHAR(20) NOT NULL DEFAULT 'pending'
                    CHECK (status IN ('pending', 'confirmed', 'rejected', 'reversed')),
    reference_id    UUID, -- ex: id da missão, id do saque
    metadata        JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
    -- Sem updated_at / sem deleted_at de propósito: ledger é append-only.
);

CREATE INDEX IF NOT EXISTS idx_wallet_tx_user ON wallet_transactions (user_id, created_at);
CREATE INDEX IF NOT EXISTS idx_wallet_tx_status_pending ON wallet_transactions (status) WHERE status = 'pending';

CREATE OR REPLACE FUNCTION prevent_ledger_mutation()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'wallet_transactions é um livro-razão imutável: % não é permitido', TG_OP;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_wallet_tx_no_update
    BEFORE UPDATE OR DELETE ON wallet_transactions
    FOR EACH ROW EXECUTE FUNCTION prevent_ledger_mutation();

-- Streak (Ofensiva) — Seção 5 do Doc. Mestre
CREATE TABLE IF NOT EXISTS streaks (
    user_id             UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    current_streak_days INTEGER NOT NULL DEFAULT 0 CHECK (current_streak_days >= 0),
    longest_streak_days INTEGER NOT NULL DEFAULT 0 CHECK (longest_streak_days >= 0),
    last_activity_date  DATE,
    protection_active   BOOLEAN NOT NULL DEFAULT FALSE, -- item de proteção (marco 15 dias)
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_streaks_updated_at
    BEFORE UPDATE ON streaks
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Histórico de Trust Score — auditável, com motivo (Manual Parte 4)
CREATE TABLE IF NOT EXISTS trust_score_history (
    id              BIGSERIAL PRIMARY KEY,
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    previous_score  SMALLINT NOT NULL,
    new_score       SMALLINT NOT NULL,
    reason          VARCHAR(120) NOT NULL,
    metadata        JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_trust_history_user ON trust_score_history (user_id, created_at);
