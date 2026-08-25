-- Seed de exemplo: promove um usuário existente a um papel administrativo.
-- Substitua o número de telefone pelo usuário de teste que você quer usar.
--
-- Papéis disponíveis (migration 012):
--   admin_master      -- acesso total ao Painel Administrativo
--   admin_financeiro  -- só saques (aprovar/rejeitar)
--   admin_suporte     -- só usuários e Trust Score
--
-- Uso: psql $DATABASE_URL -f database/seeds/002_promote_admin.sql

UPDATE users SET role = 'admin_master' WHERE phone = '841234567';

-- Exemplos de outros papéis (descomente e ajuste o telefone conforme necessário):
-- UPDATE users SET role = 'admin_financeiro' WHERE phone = '850000001';
-- UPDATE users SET role = 'admin_suporte' WHERE phone = '850000002';
