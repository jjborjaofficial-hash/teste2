-- Migration 002: Autenticação (Refresh Tokens + Tentativas de Login)
-- Referência: Manual Parte 3 (Módulo Autenticação) e Parte 5 (Padrões de API)

CREATE TABLE IF NOT EXISTS refresh_tokens (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash      TEXT NOT NULL,
    user_agent      TEXT,
    ip_address      VARCHAR(45),
    expires_at      TIMESTAMPTZ NOT NULL,
    revoked_at      TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user ON refresh_tokens (user_id);
CREATE UNIQUE INDEX IF NOT EXISTS uq_refresh_tokens_hash ON refresh_tokens (token_hash);

-- Proteção contra força bruta (Seção 12 do Doc. Mestre — Módulo /auth)
CREATE TABLE IF NOT EXISTS login_attempts (
    id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone           VARCHAR(20) NOT NULL,
    ip_address      VARCHAR(45) NOT NULL,
    success         BOOLEAN NOT NULL,
    attempted_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_login_attempts_phone_time ON login_attempts (phone, attempted_at);
CREATE INDEX IF NOT EXISTS idx_login_attempts_ip_time ON login_attempts (ip_address, attempted_at);
