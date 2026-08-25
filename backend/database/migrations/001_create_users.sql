-- Migration 001: Extensões e Usuários
-- Referência: Documento Mestre Seção 11 | Manual Parte 4

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS users (
    id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name                VARCHAR(120) NOT NULL,
    phone               VARCHAR(20)  NOT NULL,
    phone_provider      VARCHAR(10)  NOT NULL CHECK (phone_provider IN ('mpesa', 'emola')),
    email               VARCHAR(160),
    password_hash       TEXT,
    google_id           VARCHAR(120),
    avatar_url          TEXT,
    country             VARCHAR(2)  NOT NULL DEFAULT 'MZ',
    locale              VARCHAR(10) NOT NULL DEFAULT 'pt-MZ',
    currency            VARCHAR(3)  NOT NULL DEFAULT 'MZN',

    -- Economia (Seção 5 e 11 do Doc. Mestre)
    xp_total            BIGINT NOT NULL DEFAULT 0 CHECK (xp_total >= 0),
    points_balance       BIGINT NOT NULL DEFAULT 0 CHECK (points_balance >= 0),
    wallet_balance_mzn  NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (wallet_balance_mzn >= 0),

    -- Trust Score (Seção 7)
    trust_score         SMALLINT NOT NULL DEFAULT 100 CHECK (trust_score BETWEEN 0 AND 100),

    -- Jurídico (Seção 17 — Check-in Jurídico)
    terms_accepted_at   TIMESTAMPTZ,
    terms_version       VARCHAR(10),
    is_adult_declared   BOOLEAN NOT NULL DEFAULT FALSE,

    -- Controle de conta
    status              VARCHAR(20) NOT NULL DEFAULT 'active'
                         CHECK (status IN ('active', 'suspended', 'banned', 'pending_verification')),
    email_verified_at   TIMESTAMPTZ,
    phone_verified_at   TIMESTAMPTZ,

    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    deleted_at          TIMESTAMPTZ -- soft delete: nunca excluir fisicamente (regra financeira)
);

-- Regra de negócio: 1 telefone = 1 conta (Seção 16.1 do Doc. Mestre)
CREATE UNIQUE INDEX IF NOT EXISTS uq_users_phone_active
    ON users (phone) WHERE deleted_at IS NULL;

CREATE UNIQUE INDEX IF NOT EXISTS uq_users_email_active
    ON users (email) WHERE deleted_at IS NULL AND email IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_users_trust_score ON users (trust_score);
CREATE INDEX IF NOT EXISTS idx_users_status ON users (status);

-- Trigger genérico de updated_at (reutilizado por outras tabelas)
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
