-- Migration 014: Fecha lacunas identificadas contra o documento oficial
-- "Sistema de Saques (Versão 1.0 – Processamento Manual)".

-- 1. Último acesso (documento pede isso no dossiê do administrador)
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_login_at TIMESTAMPTZ;

-- 2. Status faltantes: 'cancelled' e 'suspended_for_review'
--    (documento: "Cancelado" e "Suspenso para verificação")
ALTER TABLE withdrawal_requests DROP CONSTRAINT IF EXISTS withdrawal_requests_status_check;
ALTER TABLE withdrawal_requests
    ADD CONSTRAINT withdrawal_requests_status_check
        CHECK (status IN ('pending_review', 'approved', 'rejected', 'paid', 'cancelled', 'suspended_for_review'));

-- 3. Administrador responsável registrado diretamente no pedido
--    (documento: "Administrador responsável pela aprovação" como campo do próprio registro)
ALTER TABLE withdrawal_requests ADD COLUMN IF NOT EXISTS resolved_by_admin_id UUID REFERENCES users(id);

-- 4. Anti-duplicidade: um usuário não pode ter mais de um pedido "vivo" ao mesmo tempo
--    (documento, Seção Segurança: "Impedir solicitações duplicadas")
CREATE UNIQUE INDEX IF NOT EXISTS uq_withdrawal_one_active_per_user
    ON withdrawal_requests (user_id)
    WHERE status IN ('pending_review', 'approved', 'suspended_for_review');
