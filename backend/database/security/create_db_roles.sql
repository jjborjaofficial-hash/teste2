-- Provisionamento de Usuários do Banco com Privilégio Mínimo
-- Referência: "Gestão de Credenciais do Banco de Dados e Rotação de Segurança", Seções 6 e 7.
--
-- ⚠️ Este script é executado MANUALMENTE por quem administra o Postgres
-- (ex: via psql, ou o console do provedor — Render, Supabase, etc.), usando o
-- usuário administrador do banco. NÃO faz parte do pipeline de migrations
-- (backend/database/migrate.js), porque as migrations em si (DDL: CREATE
-- TABLE, ALTER TABLE) continuam exigindo o papel "database_admin" — rodar
-- migrations exige mais privilégio do que a aplicação precisa no dia a dia.
--
-- Ordem recomendada de uso:
--   1. Crie o banco com o usuário administrador do provedor (ex: "usuario" no
--      docker-compose.yml local, ou o superusuário criado automaticamente
--      pelo Render/Supabase em produção). Esse usuário = database_admin.
--   2. Rode as migrations com esse usuário administrador:
--        DATABASE_URL=<url_do_admin> npm run migrate:up
--   3. Rode este script (também com o usuário administrador) para criar
--      database_api e database_readonly.
--   4. A partir daí, o backend em produção deve usar DATABASE_URL apontando
--      para database_api — NUNCA para o usuário administrador — no dia a dia.
--   5. Ferramentas de relatório/BI (se existirem) devem usar database_readonly.

-- ============================================================
-- database_api — usado pelo backend Node.js/Express em produção
-- ============================================================
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'database_api') THEN
    CREATE ROLE database_api WITH LOGIN PASSWORD 'TROQUE_ESTA_SENHA_ANTES_DE_USAR';
  END IF;
END
$$;

-- Operações normais da aplicação: ler e escrever dados, mas nunca alterar
-- estrutura (sem CREATE/ALTER/DROP TABLE). Isso limita o dano de uma eventual
-- vulnerabilidade de injeção de SQL — mesmo explorada, não conseguiria
-- derrubar ou alterar o schema.
GRANT CONNECT ON DATABASE aprenda_e_ganhe TO database_api;
GRANT USAGE ON SCHEMA public TO database_api;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO database_api;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO database_api;
-- Tabelas/sequências criadas por migrations FUTURAS também devem herdar isso
-- automaticamente, sem precisar rodar este script de novo a cada migration:
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO database_api;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT USAGE, SELECT ON SEQUENCES TO database_api;

-- Reforço extra: mesmo com INSERT/UPDATE/DELETE liberados, a aplicação nunca
-- deve conseguir mexer na estrutura das tabelas de auditoria/consentimento.
-- Os triggers prevent_audit_mutation() (audit_logs) e o trigger equivalente em
-- user_legal_acceptances já bloqueiam UPDATE/DELETE a nível de linha — isto
-- aqui é a segunda camada, a nível de permissão de banco.
REVOKE CREATE, ALTER, DROP ON ALL TABLES IN SCHEMA public FROM database_api;

-- ============================================================
-- database_readonly — para relatórios, dashboards e análises
-- ============================================================
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'database_readonly') THEN
    CREATE ROLE database_readonly WITH LOGIN PASSWORD 'TROQUE_ESTA_SENHA_ANTES_DE_USAR';
  END IF;
END
$$;

GRANT CONNECT ON DATABASE aprenda_e_ganhe TO database_readonly;
GRANT USAGE ON SCHEMA public TO database_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO database_readonly;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT SELECT ON TABLES TO database_readonly;

-- ============================================================
-- Verificação rápida (rode manualmente para confirmar o resultado)
-- ============================================================
-- \du                         -- lista os papéis criados
-- \dp legal_documents         -- confere os privilégios de uma tabela específica
