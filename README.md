# Aprenda e Ganhe — Projeto Completo (Backend + Frontend)

Este repositório contém a plataforma **Aprenda e Ganhe** de ponta a ponta:
- `backend/` — API Node.js/Express + PostgreSQL (ver `backend/README.md`)
- `frontend/` — Interface web React + Vite + Tailwind (ver `frontend/README.md`)

Construído em conformidade com:
- `Documento Mestre Consolidado v1.0`
- `Manual Oficial do Desenvolvedor v1.0`

## Como rodar tudo localmente

```bash
# 1. Banco de dados e cache
docker compose up -d

# 2. Backend
cd backend
npm install
cp .env.example .env   # edite os segredos JWT
npm run migrate:up
npm run dev             # roda em http://localhost:3000

# 3. Frontend (em outro terminal)
cd frontend
npm install
cp .env.example .env
npm run dev              # roda em http://localhost:5173
```

Abra `http://localhost:5173` no navegador (ou no celular, se estiver na mesma rede
— lembre de trocar `VITE_API_URL` para o IP da máquina em vez de `localhost`).

---

# Backend — detalhes

## O que já está implementado nesta entrega

✅ Arquitetura em camadas (rota → controller → service → repository → banco)
✅ Banco de dados PostgreSQL: schema inicial via migrations versionadas
✅ Módulo **Autenticação** completo: registro, login, refresh token (rotação), logout
✅ Módulo **Usuários** (endpoint `/me`)
✅ Módulo **Gamificação**: XP, Nível, Streak com marcos de recompensa (Seção 5)
✅ Módulo **Quiz** ("Coração do Sistema"): categorias, perguntas, submissão de resposta
  com validação antifraude de cronômetro no backend
✅ Módulo **Missões**: atribuição, progresso automático via Quiz, resgate de recompensa
✅ Módulo **Trust Score**: histórico auditável, selo qualitativo (nunca expõe valor exato)
✅ Módulo **Carteira**: saldo, histórico (livro-razão), solicitação de saque com validação
  de teto diário e Trust Score mínimo
✅ Módulo **Ranking Semanal**: leaderboard com cache Redis (cache-aside)
✅ Módulo **Notificações**: streak em risco, missão concluída, marco atingido
✅ **Push e SMS reais — infraestrutura pronta, falta só a credencial**: fila
  de entrega (BullMQ), tabela de tokens, service worker web, botão de opt-in
  no app; ativa sozinho assim que as variáveis `FIREBASE_*`/`TWILIO_*`
  forem preenchidas — passo a passo completo em
  `docs/notificacoes-push-sms.md`
✅ Módulo **Convites/Indicações**: código único por usuário, qualificação automática
✅ **CRON Jobs**: recálculo de ranking semanal, alerta de streak em risco, atribuição
  diária de missões (em lote, escalável), expiração de missões vencidas
✅ Módulo **Admin (base)**: aprovar/rejeitar/marcar-como-pago saques (fluxo manual
  completo, sem gateway automático), ajuste manual de Trust Score,
  suspensão/banimento de usuário, consulta de logs de auditoria
✅ **Permissões granulares de admin**: `admin_master` (total), `admin_financeiro`
  (só saques), `admin_suporte` (só usuários/Trust Score)
✅ **Painel Administrativo — interface visual** (React), em `/admin`, com
  navegação condicionada ao papel do admin logado
✅ **Notificações do fluxo de saque**: usuário recebe confirmação imediata
  ("até 24h") ao solicitar; admin financeiro recebe alerta de novo pedido;
  usuário recebe aviso quando o pagamento manual é concluído
✅ **Regras econômicas corrigidas**: saque mínimo **100 MZN** (sem teto diário de
  saque); teto de **ganho** diário 7,20 MZN via missões/streak (aplicado
  automaticamente em `walletService.creditReward`); usuário nunca deposita,
  plataforma nunca cobra — reforçado em Cadastro, Carteira e páginas legais
✅ **Módulo Jurídico e Compliance completo**: 6 documentos oficiais versionados
  (Termos, Privacidade, Cookies, Recompensas, Comunidade, Aviso Legal) geridos
  pelo Painel Administrativo sem precisar de deploy; consentimento append-only
  por documento; reaceite automático quando qualquer documento obrigatório
  muda de versão (`needsTermsReacceptance` agora vem do Módulo Jurídico, não
  de uma constante fixa); Central de Reclamações e Sistema de Recursos com
  protocolo — ver `docs/` (busque por "jurídico")
✅ **Segurança de credenciais do banco**: falha alto se `DATABASE_URL` não
  estiver definida, log estruturado de `DATABASE_CONNECTION_SUCCESS/FAILED`,
  alerta automático em falhas consecutivas, script de papéis com privilégio
  mínimo (`database_api`/`database_readonly`) — ver
  `docs/seguranca-credenciais-banco-de-dados.md`
✅ **Cache Redis com invalidação ativa**: perfil (10 min), streak (10 min) e
  ranking (5 min) — TTL como rede de segurança, invalidação imediata a cada
  escrita relevante (XP, saldo, Trust Score, status, streak) para nunca mostrar
  dado desatualizado ao usuário; ranking agora inclui o campo `level` — ver
  `docs/modulo-ranking-notificacoes-convites-cron.md`
✅ **4 novos CRON Jobs**: reconciliação de streaks expirados (00:00),
  revalidação de saques pendentes com alerta de SLA (a cada 15 min), limpeza
  de dados temporários (03:00) e relatório administrativo diário (06:00) —
  nenhum aprova/paga saques automaticamente nem cria bônus por login, ver a
  seção "Adaptações deliberadas" no doc acima
✅ **Painel de saques com fluxo completo de 6 estados**: pendente → aprovado →
  pago, além de suspender-para-revisão e cancelar, com dossiê completo do
  usuário para o admin (saldo, Trust Score, histórico, último acesso, alertas)
✅ **Animações de ícones (Seção 13.6)**: as 10 animações da tabela oficial
  ligadas a lugares reais do app — XP pulsando/girando ao subir de nível
  (com dado novo do backend), check/X desenhando o traço, confete + brilho
  em conquistas, chama do streak em loop, sino balançando com não lidas,
  impulso na carteira ao receber dinheiro, missão pulsando, ranking com
  barras em stagger, Trust Score preenchendo por faixa (nunca o valor exato)
✅ **Correção: visibilidade dos Pontos** — a moeda "Pontos" (Seção 5, diferente
  de XP) existia no banco/API desde o início mas nunca aparecia em nenhuma
  tela; agora tem ícone próprio (`PointsIcon`) e saldo visível no Dashboard
  e na Tela de Resultados
✅ **Ícone de Conquistas/Medalhas** — faltava na ficha técnica da Seção 13.5
  (11 de 12 famílias existiam); criado com a animação de confete + brilho
  já especificada na Seção 13.6
✅ **Rate limiting distribuído** via Redis (antes era em memória por processo, não
  escalava para múltiplas instâncias)
✅ **Frontend web completo** (React + Vite + Tailwind), cobrindo todo o Sitemap da
  Seção 19: Onboarding, Login/Cadastro, Dashboard, Hub de Estudos, Quiz Ativo,
  Resultados, Carteira, Perfil, Ranking — ver `frontend/README.md` para detalhes
✅ Segurança: hash de senha (bcrypt), JWT (access + refresh), rate limiting, proteção
  contra força bruta, helmet, CORS
✅ Tratamento de erros padronizado (nunca vaza detalhes internos)
✅ Logs estruturados (Winston) e logs de auditoria append-only no banco
✅ Livro-razão imutável para a Carteira (`wallet_transactions`) e histórico de Trust Score
✅ Testes de integração básicos (Jest + Supertest)
✅ `docker-compose.yml` para rodar Postgres + Redis localmente
✅ **Fila real + Scheduler automático (BullMQ/Redis)**: `npm run worker` agenda os 9
  CRON Jobs existentes automaticamente, com retry e backoff — não depende mais de
  registro manual em cron externo (Render Cron Jobs) — ver `CHANGELOG_organizacao_expansao.md`
✅ **Economia de Pontos ativada de ponta a ponta**: Quiz agora concede Pontos por
  dificuldade (fácil=10/médio=25/difícil=50, Seção 5.9-B), além de XP — antes só dava
  XP; Loja de Pontos com itens funcionais/cosméticos/prestígio; conversão
  Pontos → MZN (100 Pontos = 1 MZN, mesmo teto diário do saque); página "Meus Recursos"
  unificando itens temporários e permanentes com raridade automática (Comum/Raro/
  Épico/Lendário) — ver `docs/modulo-gamificacao-quiz-missoes-carteira-trustscore.md`,
  `CHANGELOG_meus_recursos_completo.md` e `CHANGELOG_raridade.md`
✅ **Banco de perguntas ampliado — 1.614 perguntas** em `database/seeds/` (66 arquivos,
  rodar manualmente e em ordem numérica). Distribuição atual:

  | Categoria | Fácil | Médio | Difícil | Total |
  |---|---|---|---|---|
  | Inteligência Artificial | 100 | 100 | 136 | 336 |
  | Tecnologia | 100 | 124 | 100 | 324 |
  | Marketing Digital | 100 | 100 | 106 | 306 |
  | Finanças | 100 | 100 | 101 | 301 |
  | Produtividade | 148 | 100 | 99 | 347 |

  Praticamente todo lote recebido tinha a mesma falha de qualidade no material
  original (resposta certa sempre na alternativa "A") — corrigida em cada
  arquivo com posições redistribuídas de forma reprodutível (seeds sequenciais
  42 a 89, uma por arquivo, documentadas no cabeçalho de cada seed).

  ⚠️ **Nota de reconciliação (arquivo 051)**: dois lotes de Inteligência
  Artificial/Difícil foram enviados em sessões diferentes de trabalho no mesmo
  período — `050_ia_dificil.sql` (49 perguntas, temática Transformers/RLHF) e
  `051_ia_dificil_2.sql` (87 perguntas, temática fundamentos de ML + tópicos
  avançados). Antes de gerar o `051`, foi feita deduplicação de texto contra
  as 1.325 perguntas já existentes em TODO o banco (não só a mesma categoria),
  removendo 13 repetições — incluindo 1 pergunta que já vinha do próprio `050`
  ("O que é RAG..."). Os dois arquivos são complementares, não duplicados.

  ⚠️ **Bug de sintaxe SQL corrigido** (arquivos 003, 004, 005): usavam
  `CREATE TEMP TABLE x AS INSERT ... RETURNING`, sintaxe inválida no
  PostgreSQL (`CREATE TABLE AS` só aceita SELECT/TABLE/VALUES). Corrigido para
  `CREATE TEMP TABLE x AS WITH inserted AS (INSERT ... RETURNING ...) SELECT * FROM inserted`,
  padrão usado em todos os seeds a partir do 006.

## O que ainda NÃO está implementado (próximas entregas)

Conforme a metodologia do Manual (Parte 2), cada módulo será entregue completo, testado
e documentado antes de avançar para o próximo. Pendentes:
- Módulos: Publicidade/Webhooks de anúncios, IA/Personalização
- Cache Redis aplicado apenas ao Ranking por enquanto (perfil e streak ainda não usam cache)
- Login social via Google e validação OTP por SMS (frontend e backend)
- Integração real de anúncios (AdSense/AdCash/efficientcpmnetwork) — hoje são placeholders visuais no frontend
- App Mobile nativo (o frontend web é responsivo mobile-first, mas não é um app instalável de loja)
- Integração automática de pagamento M-Pesa/e-Mola — o saque é 100% manual (ver `docs/fluxo-saque-manual-permissoes-admin-ui.md`)
- Campanha de Boas-vindas (Jornada Inicial de 7 dias) — nenhuma tabela, migration ou
  tipo de missão criada ainda; dias 4–7 também não têm valores de exemplo definidos
  em nenhum documento oficial, então dependem de decisão do proprietário do projeto
  antes de qualquer implementação
- SOP formal de exclusão/portabilidade de dados (LGPD, Seção 16.4) — hoje só existe
  como categoria genérica na Central de Reclamações, sem prazo/processo documentado
- Endpoint público genérico de `system_config` — hoje cada valor exposto ao frontend
  (ex.: taxa de conversão de Pontos) precisou de uma rota dedicada; `WITHDRAWAL_MIN_MZN`
  em `Wallet.jsx` continua fixo no frontend, não vindo da API

## Requisitos

- Node.js ≥ 18
- Docker + Docker Compose (para rodar Postgres/Redis localmente)

## Como rodar localmente

```bash
# 1. Subir banco de dados e cache
docker compose up -d

# 2. Instalar dependências do backend
cd backend
npm install

# 3. Configurar variáveis de ambiente
cp .env.example .env
# edite o .env e gere segredos JWT fortes:
openssl rand -base64 64

# 4. Aplicar as migrations
npm run migrate:up

# 5. Rodar o servidor em modo desenvolvimento
npm run dev
```

O servidor sobe em `http://localhost:3000`. Teste com:

```bash
curl http://localhost:3000/health
```

## Rodando os testes

Os testes de integração precisam de um banco de teste com as migrations aplicadas
(pode ser o mesmo `docker compose up -d`, apontando `DATABASE_URL` para um banco de teste).

```bash
cd backend
npm test
```

## Deploy em produção (Render, conforme Seção 3 e 14 do Documento Mestre)

1. Suba este repositório no GitHub.
2. Crie um serviço PostgreSQL no Render (ou outro provedor) e copie a `DATABASE_URL`.
3. Crie um serviço Web (Node) apontando para a pasta `backend/`.
4. Configure as variáveis de ambiente do `.env.example` no painel do Render
   (gere segredos JWT novos e fortes — nunca reutilize os de desenvolvimento).
5. Defina o comando de build: `npm install` e o comando de start: `npm start`.
6. Rode as migrations uma vez, manualmente, contra o banco de produção:
   `DATABASE_URL=<url_producao> npm run migrate:up`
7. Ative backups diários automáticos do Postgres (Render oferece isso no plano pago).

⚠️ **Importante**: a rotação de credenciais expostas (Seção 23.2.1 do Documento
Mestre) agora tem processo, script e checklist completos em
`docs/seguranca-credenciais-banco-de-dados.md`. Antes de qualquer deploy real,
siga esse runbook para gerar credenciais novas e nunca reutilizar segredos
antigos que possam ter sido expostos.

## Endpoints disponíveis nesta entrega

| Método | Rota | Autenticação | Descrição |
|---|---|---|---|
| GET | `/health` | Não | Healthcheck |
| POST | `/api/v1/auth/register` | Não | Cria conta (telefone M-Pesa/e-Mola + senha) |
| POST | `/api/v1/auth/login` | Não | Login, retorna access + refresh token |
| POST | `/api/v1/auth/refresh` | Não | Rotaciona refresh token, emite novo par |
| POST | `/api/v1/auth/logout` | Não | Revoga o refresh token |
| GET | `/api/v1/users/me` | Sim (Bearer) | Retorna perfil do usuário autenticado |
| GET | `/api/v1/gamification/me` | Sim | XP, nível, pontos e estado do streak |
| GET | `/api/v1/quiz/categories` | Sim | Lista categorias ativas |
| GET | `/api/v1/quiz/categories/:categoryId/next-question` | Sim | Próxima pergunta (sem revelar resposta) |
| POST | `/api/v1/quiz/answers` | Sim | Submete resposta (XP, streak, missões e trust score processados aqui) |
| GET | `/api/v1/missions` | Sim | Lista missões do usuário (auto-atribui as ativas) |
| POST | `/api/v1/missions/:userMissionId/claim` | Sim | Resgata recompensa de missão concluída |
| GET | `/api/v1/trust-score/me` | Sim | Selo qualitativo de confiança (nunca o valor exato) |
| GET | `/api/v1/wallet` | Sim | Saldo em MZN |
| GET | `/api/v1/wallet/transactions` | Sim | Histórico de transações (livro-razão) |
| POST | `/api/v1/wallet/withdrawals` | Sim | Solicita saque (M-Pesa/e-Mola) |
| GET | `/api/v1/ranking/weekly` | Sim | Top do ranking semanal (cacheado) |
| GET | `/api/v1/ranking/weekly/me` | Sim | Minha posição no ranking da semana |
| GET | `/api/v1/notifications` | Sim | Lista notificações |
| GET | `/api/v1/notifications/unread-count` | Sim | Contagem de não lidas |
| POST | `/api/v1/notifications/:id/read` | Sim | Marca notificação como lida |
| GET | `/api/v1/referrals/me/code` | Sim | Meu código de indicação |
| GET | `/api/v1/referrals/me` | Sim | Minhas indicações e status |
| GET | `/api/v1/admin/withdrawals` | Sim (admin) | Lista saques pendentes de revisão |
| POST | `/api/v1/admin/withdrawals/:id/approve` | Sim (admin) | Aprova saque |
| POST | `/api/v1/admin/withdrawals/:id/reject` | Sim (admin) | Rejeita saque e estorna o valor |
| GET | `/api/v1/admin/users` | Sim (admin) | Lista/busca usuários |
| POST | `/api/v1/admin/users/:id/trust-score/adjust` | Sim (admin) | Ajuste manual de Trust Score |
| POST | `/api/v1/admin/users/:id/status` | Sim (admin) | Suspende/bane/reativa usuário |
| GET | `/api/v1/admin/audit-logs` | Sim (admin) | Consulta logs de auditoria |

Documentação detalhada do módulo de autenticação em `docs/modulo-autenticacao.md`.

## Painel Administrativo — como testar

1. Registre um usuário normalmente via `POST /auth/register`.
2. Promova-o a admin diretamente no banco:
   ```bash
   psql $DATABASE_URL -f backend/database/seeds/002_promote_admin.sql
   ```
   (edite o arquivo para usar o telefone do seu usuário de teste)
3. Faça login novamente (o papel `admin` só é aplicado em um token novo).
4. Use o `accessToken` retornado como Bearer token nas rotas `/api/v1/admin/*`.

## CRON Jobs — como rodar

Nenhum scheduler roda sozinho nesta entrega. Em produção, registre estes comandos
como Cron Jobs do Render (ou equivalente):

```bash
node src/cron/jobs/assignDailyMissions.js   # diário, meia-noite
node src/cron/jobs/expireMissions.js        # diário, logo após o anterior
node src/cron/jobs/recomputeWeeklyRanking.js # a cada hora
node src/cron/jobs/notifyStreaksAtRisk.js   # 1x/dia, fim da tarde
```



```
backend/
  database/migrations/     -- schema SQL versionado
  src/
    config/                -- conexões (postgres, redis)
    common/                -- erros, logger, utilitários
    middleware/             -- autenticação, validação, rate limit, erros
    modules/
      auth/                -- controllers, services, repositories, routes, validators
      users/                -- idem
    app.js                  -- configuração do Express
    server.js                -- bootstrap + encerramento gracioso
  tests/                    -- testes de integração (Jest + Supertest)
docker-compose.yml           -- Postgres + Redis para desenvolvimento local
```
