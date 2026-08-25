# Módulos: Ranking Semanal, Notificações, Convites/Indicações e CRON Jobs

**Status:** ✅ Concluído (v1.0)
**Referências:** Doc. Mestre Seções 9, 15 | Manual Parte 3 (Camada de Cache, CRON Jobs, módulos oficiais)

## Ranking Semanal

- `GET /api/v1/ranking/weekly?limit=20` — top N do ranking da semana corrente.
- `GET /api/v1/ranking/weekly/me` — posição e XP ganho do usuário autenticado na semana.
- **Cache-aside com Redis**: o top ranking é cacheado por 5 minutos
  (`ranking:weekly:<semana>:top`). Se o Redis estiver indisponível, a consulta cai
  automaticamente para o banco — a plataforma nunca fica fora do ar por causa do cache
  (Manual Parte 3: "Caso uma API/infra fique indisponível, a plataforma deve continuar
  funcionando sempre que possível").
- O ranking é **materializado** na tabela `weekly_rankings`, recalculado pelo CRON job
  `src/cron/jobs/recomputeWeeklyRanking.js` a partir de `quiz_attempts` corretos da semana.
  Isso evita agregações pesadas em toda leitura (decisão de escalabilidade — Manual Parte 3).

## Notificações

- `GET /api/v1/notifications` — lista (paginada, filtro `?unreadOnly=true` opcional).
- `GET /api/v1/notifications/unread-count` — contador para badge de UI.
- `POST /api/v1/notifications/:id/read` — marca como lida.
- Outros módulos (Gamificação/Streak, Missões) geram notificações automaticamente
  dentro das mesmas transações de negócio, usando os textos humanizados especificados
  na Seção 6 e 9 do Doc. Mestre (ex.: "Quase lá! Sua ocorrência de X dias está em risco...").
- **Envio push/SMS real ainda não implementado** — hoje as notificações só existem no
  banco de dados, para exibição in-app. Integração com um provedor de push (ex: FCM)
  é um próximo passo.

## Convites/Indicações

- `GET /api/v1/referrals/me/code` — retorna (e cria, se necessário) o código único do usuário.
- `GET /api/v1/referrals/me` — lista indicações feitas e seus status.
- Fluxo: o novo usuário informa `referralCode` opcionalmente no `POST /auth/register`.
  O vínculo é criado como `pending`. Quando o indicado completa um número mínimo de
  quizzes corretos (`system_config.referral_qualification_quiz_count`, placeholder = 5),
  o indicador recebe pontos automaticamente (`system_config.referral_reward_points`,
  placeholder = 100) — verificado a cada resposta correta de quiz do indicado.
- ⚠️ Valores de recompensa e critério de qualificação são **placeholders técnicos**,
  pendentes de aprovação do negócio (mesma ressalva já feita para Streak — Seção 23.1.5).

## Camada de Cache (Redis)

Referência: docx "IMPLANTAÇÃO OFICIAL — REDIS CACHE E CRON JOBS".

Helper genérico em `src/common/cache/cacheService.js` (cache-aside com
degradação graciosa — se o Redis cair, tudo continua funcionando direto no
banco). Wrappers tipados em `src/common/cache/userCache.js`:

| Dado | Chave | TTL | Onde é lido | Onde é invalidado |
|---|---|---|---|---|
| Ranking semanal (top N) | `ranking:weekly:{semana}:top` | 5 min | `GET /ranking` | CRON `recomputeWeeklyRanking.js` |
| Perfil básico (nome, nível, pontos, saldo, status, último acesso) | `user:profile:{userId}` | 10 min | `GET /users/me` | XP/Pontos (`xpService`), Carteira (`walletService`), Trust Score (`trustScoreService`), status/role (`adminService`), reaceite de termos (`authService`) |
| Streak (dias, proteção) | `user:streak:{userId}` | 10 min | `GET /gamification/me` | `streakService.registerDailyActivity`, CRON `enforceStreakExpiry.js` |

**Por que TTL curto + invalidação ativa, e não só TTL longo:** XP, pontos e
saldo mudam a cada resposta de quiz. Confiar só no TTL de 5-15 min pedido na
especificação faria o usuário ver o próprio saldo desatualizado por até 15
minutos depois de jogar — regressão real de UX. Por isso todo módulo que
escreve um desses campos invalida o cache no mesmo instante; o TTL é rede de
segurança, não o mecanismo principal de frescor. Imagens/fotos nunca são
cacheadas (regra explícita da especificação).

## CRON Jobs

Scripts standalone em `src/cron/jobs/`, prontos para serem agendados (Render Cron Jobs,
`node-cron`, ou qualquer scheduler externo). Nenhum scheduler automático está configurado
nesta entrega — os scripts precisam ser chamados por algo externo.

| Script | Frequência sugerida | O que faz |
|---|---|---|
| `recomputeWeeklyRanking.js` | A cada hora | Recalcula `weekly_rankings` e invalida o cache |
| `notifyStreaksAtRisk.js` | 1x/dia, fim da tarde | Notifica quem ainda não jogou hoje mas jogou ontem |
| `assignDailyMissions.js` | 1x/dia, madrugada | Atribui as missões diárias a todos os usuários ativos |
| `expireMissions.js` | 1x/dia, madrugada | Marca `user_missions` vencidas como `expired` |
| `enforceStreakExpiry.js` | Todos os dias às 00:00 | Reconcilia streaks quebrados/protegidos proativamente (ver nota abaixo) |
| `revalidateWithdrawals.js` | A cada 15 min | Revalida saques pendentes contra status/Trust Score atual; alerta SLA de 24h |
| `cleanupExpiredData.js` | Todos os dias às 03:00 | Remove refresh tokens expirados, login_attempts e notificações antigas |
| `generateDailyReport.js` | Todos os dias às 06:00 | Gera o snapshot de `admin_daily_reports` do dia anterior |

Exemplo de execução manual:
```bash
node src/cron/jobs/recomputeWeeklyRanking.js
node src/cron/jobs/notifyStreaksAtRisk.js
node src/cron/jobs/enforceStreakExpiry.js
node src/cron/jobs/revalidateWithdrawals.js
node src/cron/jobs/cleanupExpiredData.js
node src/cron/jobs/generateDailyReport.js
```

### Adaptações deliberadas em relação à especificação original de CRON

A especificação "REDIS CACHE E CRON JOBS" foi escrita de forma genérica e
alguns pontos foram adaptados às regras de negócio já confirmadas para este
projeto:

- **"Bônus diário" virou "reconciliação de streak" (`enforceStreakExpiry.js`)**:
  este projeto não paga por login — só por atividade educacional real (Doc.
  Mestre Seção 5; Aviso Legal). O job não credita nada; ele corrige a exibição
  de streaks já quebrados que só seriam recalculados na próxima atividade do
  usuário, preservando corretamente o item de proteção do marco de 15 dias.
- **"Processamento de saques" nunca aprova/paga automaticamente**: o
  pagamento continua 100% manual (decisão explícita do proprietário do
  projeto). O CRON só revalida requisitos que podem ter mudado depois do
  pedido, e alerta o admin quando o SLA de 24h é ultrapassado.
- **"Limpeza" nunca toca livros-razão append-only**: `audit_logs`,
  `user_legal_acceptances` e `wallet_transactions` nunca são apagados — são
  exigidos para auditoria jurídica e financeira (Manual Parte 4; docx
  jurídico, Parte 13). Códigos OTP ainda não existem no projeto (ver README);
  o passo de limpeza correspondente já está preparado, comentado, para quando
  esse módulo existir.
- **"Receita de publicidade" no relatório fica `null`** até existir integração
  real com AdSense/AdCash — o CRON não inventa um número.

### Pendente (próximos passos)
- Configuração de um scheduler real em produção (nenhum dos scripts acima roda sozinho).
- Conectar o alerta de SLA de saque e o de falha de conexão do banco a um canal
  externo (e-mail/Slack), hoje só vão para o log.
