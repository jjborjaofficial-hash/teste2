-- Migration 108: Permite cadastro apenas com Google (sem telefone no momento do registo)
-- Contexto: login/cadastro via Google (OAuth) cria a conta imediatamente; o
-- telefone (M-Pesa/e-Mola), obrigatório para a carteira, é pedido logo a
-- seguir numa tela de "completar perfil". Até lá, phone/phone_provider ficam
-- temporariamente nulos. O índice único uq_users_phone_active já convive bem
-- com múltiplos NULLs (índice parcial padrão do Postgres), nenhuma mudança
-- necessária nele.

ALTER TABLE users ALTER COLUMN phone DROP NOT NULL;
ALTER TABLE users ALTER COLUMN phone_provider DROP NOT NULL;
