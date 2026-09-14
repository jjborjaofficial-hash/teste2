# Changelog — Rodada de Organização e Expansão
### (Google Login, M-Pesa e e-Mola deliberadamente fora do escopo — o proprietário do projeto assumirá essas integrações)

## 1. Fila real + Scheduler automático (fecha 2 lacunas da Seção 20 do Doc. Mestre)

**Antes:** os 9 jobs em `src/cron/jobs/` eram scripts standalone. Precisavam
ser registrados manualmente num agendador externo (Render Cron Jobs, crontab),
e não havia fila de mensagens nenhuma — as duas lacunas que o próprio projeto
já documentava em `docs/modulo-admin-e-lacunas-secao20.md`.

**Agora:** `npm run worker` sobe um processo BullMQ (Redis) que:
- agenda todos os 9 jobs existentes + 1 novo (ver item 2) com a frequência que
  já estava documentada em cada arquivo de job (nenhum horário foi inventado);
- roda 3 jobs em paralelo, com 3 tentativas e backoff exponencial em caso de falha;
- não duplica lógica de negócio — cada handler É o `run()` que já existia,
  só reexportado (`module.exports = run`) em vez de fechar o pool de conexão
  ao rodar (agora só fecha o pool quando chamado via CLI direto, não via worker).

Arquivos novos: `src/queue/connection.js`, `cronQueue.js`, `definitions.js`, `worker.js`.
Scripts novos: `npm run worker`, `npm run worker:dev`.
Dependência nova: `bullmq`.

**Continua precisando de ação operacional:** rodar `npm run worker` como um
segundo serviço (ao lado do serviço web) no provedor de hospedagem — isso
não roda sozinho dentro do serviço web existente.

## 2. Job de missões semanais (pendência que o próprio código documentava)

`assignDailyMissions.js` já tinha um comentário `PENDÊNCIA:` avisando que
missões do tipo `weekly` nunca eram atribuídas a ninguém. Criado
`assignWeeklyMissions.js`, reaproveitando `currentWeekStartDate()` do módulo
Ranking (mesma definição de "início de semana" usada no ranking semanal e na
Loja, para as três coisas nunca divergirem). Idempotente via a
UNIQUE(user_id, mission_id, period_date) que já existia (migration 022).

## 3. Notificação de teto de ganho diário atingido

Fecha a limitação documentada em
`docs/reaceite-termos-e-correcao-regras-saque.md` ("Não há alerta automático
se o teto de ganho diário for atingido"). Agora, quando `walletService.creditReward`
reduz ou zera um crédito por causa do teto diário de 7,20 MZN, o usuário
recebe uma notificação (no máximo 1x por dia, mesmo que várias
missões/streak tentem creditar na mesma janela).

- Migration nova: `027_add_daily_earning_cap_notification.sql`
- `notificationsRepository.existsTodayByType()` — novo helper genérico,
  reutilizável por qualquer notificação futura que precise da mesma regra
  de "no máximo 1x por dia"
- `notificationsService.notifyDailyEarningCapReached()`
- Gancho em `walletService.creditReward`

## 4. Testes expandidos

Antes: só Auth, Admin (controle de acesso) e Quiz/Wallet/Ranking (só guarda
de autenticação) tinham teste. Adicionados, seguindo exatamente o mesmo
estilo dos testes existentes (integração real via supertest, sem mocks):

- `tests/legal.test.js` — documentos públicos + rotas autenticadas + painel admin_juridico
- `tests/shop.test.js` — Loja, Inventário ("Meus Recursos") e painel admin_financeiro
- `tests/trustscore.test.js` — status do usuário + ajuste administrativo
- `tests/referrals.test.js` — código e lista de indicados
- `tests/missions.test.js` — minhas missões + painel admin_suporte

**Limitação honesta:** os testes novos cobrem controle de acesso e validação
(o que dá pra testar sem depender de estado específico do banco), não o
fluxo de negócio completo fim-a-fim (comprar item → ver saldo debitado, por
exemplo). Isso exigiria fixtures/seeds de teste dedicados, que não existiam
antes e não foram criados agora — ficaria bom como próximo passo.

## 5. Documentação corrigida (achados da auditoria anterior)

- `docs/modulo-admin-e-lacunas-secao20.md`: removidas as duas afirmações que
  não eram mais verdade (papéis granulares "não implementados" — na verdade
  existem desde a migration 012; painel admin "sem interface visual" — na
  verdade existem ~1.700 linhas de UI em React). Mantidas riscadas no
  documento, não apagadas, para rastreabilidade.
- `docs/politicas-plataforma-organizadas.md`: item 8.3 atualizado (o reaceite
  de termos existe, ao contrário do que o texto antigo dizia) + corrigida uma
  numeração duplicada real na Seção 6 (dois itens "6.2" e dois "6.3" — agora
  6.1 a 6.7 sequenciais, sem duplicar número nem perder conteúdo).

## O que continua de fora, por decisão sua nesta rodada
- Login social via Google
- Integração real de pagamento M-Pesa
- Integração real de pagamento e-Mola
- OTP por SMS (também depende de um gateway externo, mesma categoria das anteriores)

## O que ainda fica pendente para uma próxima rodada
- Revisão jurídica formal dos textos por advogado moçambicano
- Fixtures/seeds de teste dedicados para testes de fluxo completo (não só controle de acesso)
- Separação física de bancos staging/produção (ação operacional)
- Backups automáticos ativados no provedor (ação operacional)
