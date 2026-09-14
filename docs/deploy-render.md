# Deploy Gratuito no Render — Guia Passo a Passo

Este guia assume que você **não tem servidor nem domínio próprio ainda** — vamos
usar o subdomínio gratuito que o Render dá (`algo.onrender.com`).

---

## Parte 1 — Preparar o código no GitHub

O Render faz deploy a partir de um repositório Git — não aceita ZIP direto.

1. Crie uma conta grátis em **github.com** (se ainda não tiver).
2. Crie um repositório novo (pode ser privado ou público) — ex: `aprenda-e-ganhe`.
3. Suba o conteúdo da pasta `aprenda-e-ganhe/` (a que contém `backend/`,
   `frontend/`, `render.yaml`, `docs/`) para esse repositório.

⚠️ **Importante**: confirme que o arquivo `render.yaml` ficou na **raiz** do
repositório (mesmo nível de `backend/` e `frontend/`), não dentro de uma
subpasta.

---

## Parte 2 — Criar o Blueprint no Render

1. Crie uma conta grátis em **render.com** (pode entrar direto com GitHub).
2. No painel, clique **New** → **Blueprint**.
3. Conecte o repositório `aprenda-e-ganhe` que você acabou de criar.
4. O Render vai ler o `render.yaml` sozinho e mostrar uma prévia com 5 recursos:
   - `aprenda-e-ganhe-db` (PostgreSQL)
   - `aprenda-e-ganhe-redis` (Key Value / Redis)
   - `aprenda-e-ganhe-backend` (Web Service)
   - `aprenda-e-ganhe-worker` (Background Worker — agenda e roda os CRON Jobs:
     missões diárias/semanais, ranking, expiração de itens, saques, relatório
     diário. **Sem este serviço rodando, nada disso acontece sozinho.**)
   - `aprenda-e-ganhe-frontend` (Site estático)
5. Clique **Apply** / **Deploy Blueprint**.

---

## Parte 3 — Rodar as migrations e provisionar os papéis de banco (uma única vez)

O banco começa vazio.

1. No painel do Render, abra o serviço **aprenda-e-ganhe-backend** → aba **Shell**.
2. Rode as migrations (schema completo, com o usuário admin do banco):
   ```bash
   npm run migrate:up
   ```
3. **Novo, desde a entrega de segurança de credenciais**: provisione os papéis
   de privilégio mínimo do banco (`database_api`, `database_readonly`):
   ```bash
   psql $DATABASE_URL -f database/security/create_db_roles.sql
   ```
   Depois disso, troque a senha padrão do script (`TROQUE_ESTA_SENHA_ANTES_DE_USAR`)
   e considere apontar `DATABASE_URL` do backend para o usuário `database_api`
   em vez do superusuário — ver `docs/seguranca-credenciais-banco-de-dados.md`.
4. Rode o seed opcional de conteúdo de exemplo (perguntas de teste):
   ```bash
   psql $DATABASE_URL -f database/seeds/001_sample_content.sql
   ```
   (As 5 categorias oficiais já vêm garantidas pela migration 021, mesmo sem
   rodar este seed — só as perguntas de exemplo dependem dele.)

---

## Parte 4 — Promover seu usuário a admin

1. Cadastre-se normalmente pelo app (frontend já publicado).
2. Volte no Shell do backend e rode, trocando o telefone pelo seu:
   ```bash
   psql $DATABASE_URL -c "UPDATE users SET role = 'admin_master' WHERE phone = '84XXXXXXX';"
   ```
3. Faça logout e login de novo no app (o papel só é aplicado em um token novo).

---

## Parte 5 — Testar

1. Abra a URL do **aprenda-e-ganhe-frontend**.
2. Teste o fluxo: Onboarding → Cadastro → Dashboard → Hub de Estudos → Quiz →
   Resultado → Carteira → solicitar saque.
3. Acesse `/admin` logado com o usuário promovido.
4. Confira se o worker está de fato rodando: aba **Logs** do serviço
   `aprenda-e-ganhe-worker` — deve aparecer `WORKER: N job(s) agendado(s)` logo
   na inicialização.

⚠️ **Lembrete sobre o plano grátis**: o backend "dorme" depois de 15 minutos
sem uso (primeira requisição demora 30-60s). O banco de dados grátis expira
em 30 dias.

---

## Se algo der errado

- **Build do backend falhou**: veja os logs na aba **Logs** do serviço.
- **Frontend carrega mas não conecta na API**: confira `VITE_API_URL` (aba
  Environment do frontend) — deve terminar em `/api/v1`.
- **Erro de conexão com banco**: confira `DATABASE_URL` e se as migrations
  já rodaram.
- **Frontend carrega, API responde no Postman, mas o navegador dá erro de
  CORS**: confira `CORS_ALLOWED_ORIGINS` (aba Environment do
  **aprenda-e-ganhe-backend**) — precisa ser a URL completa e exata do
  frontend, com `https://`. Se você renomeou o serviço do frontend ou usa
  domínio próprio, o valor padrão do `render.yaml` não vai bater.
