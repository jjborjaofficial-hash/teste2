-- Migration 011: Papel de Usuário (role) — base do Painel Administrativo
-- Referência: Manual Parte 3 (módulo "Painel Administrativo") e Parte 5 (autorização)

ALTER TABLE users
    ADD COLUMN IF NOT EXISTS role VARCHAR(20) NOT NULL DEFAULT 'user'
        CHECK (role IN ('user', 'admin'));

CREATE INDEX IF NOT EXISTS idx_users_role ON users (role) WHERE role != 'user';

-- Nenhum usuário é promovido a admin automaticamente por esta migration.
-- Promoção deve ser feita manualmente no banco (ou por outro admin já existente):
--   UPDATE users SET role = 'admin' WHERE phone = '84XXXXXXX';
