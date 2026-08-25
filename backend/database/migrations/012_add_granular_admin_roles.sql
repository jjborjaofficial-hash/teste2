-- Migration 012: Papéis Granulares de Admin
-- Referência: decisão do proprietário do projeto, em resposta à lacuna registrada
-- na migration 011 (papel binário user/admin não cobria separação de responsabilidades).
--
-- Papéis definidos:
--   'user'            — usuário comum da plataforma (padrão)
--   'admin_master'    — acesso total ao Painel Administrativo
--   'admin_financeiro' — só saques (aprovar/rejeitar)
--   'admin_suporte'    — só usuários e Trust Score (suspender/banir, ajustar confiança)
-- Logs de auditoria (somente leitura) são acessíveis a qualquer papel admin_*.

ALTER TABLE users DROP CONSTRAINT IF EXISTS users_role_check;

-- Migra dados existentes: quem já era 'admin' vira 'admin_master' (acesso total),
-- preservando o comportamento anterior sem perder acesso de ninguém na transição.
UPDATE users SET role = 'admin_master' WHERE role = 'admin';

ALTER TABLE users
    ADD CONSTRAINT users_role_check
        CHECK (role IN ('user', 'admin_master', 'admin_financeiro', 'admin_suporte'));
