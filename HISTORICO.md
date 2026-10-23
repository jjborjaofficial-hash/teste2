# HISTÓRICO (o que já foi feito)

Só para consulta. **Nada aqui é instrução.** O que falta fazer está em `INSTRUCOES.md`; as regras e decisões fixas estão em `REGRAS.md`.
Alguns textos descrevem cenários antigos (Londres/Oregon, auto-deploy, etc.); confie no `REGRAS.md` para o estado atual.

## Mudança para Frankfurt (17 a 21/10/2026)

- **Já arrumado (18/10):** Redis antigo apagado; `healthCheckPath` = `/health` no serviço novo.
- **Latência: de ~130 ms para ~2 ms** por consulta; dados copiados e conferidos (linhas iguais) antes de trocar o site.

## Caixa "PRÓXIMO PASSO AGORA" de 15/10 (arquivada)

**Atualizado em 15/10 e verificado de forma independente.** O conteúdo do **Quiz v2 está COMPLETO**: reconstruindo a base do
zero com todas as migrations, as 5 categorias têm **100% das explicações (1.641 perguntas ativas)**, o validador reprova **0** e a
correta é a mais longa em **20,4%** (era 90,8%; meta <= 35% por grupo). Os 48 grupos de testes do backend passam (767 testes).
**Não há mais lotes de alternativas nem de explicações por fazer: não abrir lotes nem reservas novas.** Qualquer texto de
"RESERVADO" ou "PRÓXIMO lote" que ainda apareça no `backend/PENDENTE.md` é histórico; confira sempre pelas migrations em
`backend/database/migrations/` antes de agir (esse texto antigo já enganou uma sessão).

**O que falta agora (nada disto é conteúdo do quiz):**
1. **Anúncios (Adcash).** Nos prints do dono de 13/10 apareceram anúncios de conteúdo adulto e um aviso falso de "Flash Player" por cima
   das perguntas. O código já foi corrigido (commit `3ceb5e7`: script do Interstitial retirado do resultado do quiz), mas o **dono tem de
   refazer o deploy do frontend** no Render, **configurar as restrições de categoria nas 4 zonas do Adcash** (separador *Restrictions*) e
   denunciar o anúncio falso ao suporte. Interruptor geral de emergência: `VITE_ADS_ENABLED=false`.
2. **Capacidade.** No plano gratuito aguenta cerca de 50 a 100 pessoas ao mesmo tempo (cada consulta custa ~0,13 s entre o Render em
   Oregon e o Neon em Londres; pool de 20 ligações; quota do Neon de 100 CU-horas/mês). Melhoria mais barata: servidor e base na **mesma
   região**. Antes de lançar: plano pago, worker no Render e teste de carga.
3. **Decisões do dono** (secção "Ideias ainda NÃO aprovadas", no fim): teto diário vs pedidos simultâneos (dinheiro), verificação por
   SMS, economia vs receita real do Adcash, testes + deploy automático, e o destino da branch `feat/quiz-aprendizagem` (abaixo).
   **Não implementar sem aprovação.**
4. O dono conferir os rascunhos em `docs/quiz-lotes-alternativas/`.

## Vulnerabilidades de dependências (npm audit, 09 a 15/10/2026)

- **Vulnerabilidades de dependências (npm audit, 2026-10-09):** o `npm audit fix` seguro já foi aplicado (saiu a crítica `proxy-addr` e a alta `compression`; backend 19 → 12). **`bcrypt` 5 → 6 FEITO em 14/10 (aprovado pelo dono; testes verdes no ramo à parte e no main; backend publicado).** **`firebase-admin` 12 → 14 FEITO em 15/10 (pedido do dono; `pushService.js` passou à API modular `firebase-admin/app` e `/messaging`) e `firebase` (frontend) 10 → 13; `uuid` (não usado) removido.** Em produção (`npm audit --omit=dev`) sobram no backend 2 moderadas (`uuid` dentro do `gaxios`, sem uso do caminho afetado) e no frontend 6 (`react-router`, `@grpc/grpc-js`/firestore que o projeto não importa). O resto são ferramentas de desenvolvimento (`jest`, `nodemon`, `vite`, `tailwindcss`), que não vão para produção; só trocar com o dono. O `firebase-messaging-sw.js` continua a usar o `firebase` 10.13 compat via CDN (independente do pacote).

## Deploy de 11/10/2026, latência, limites de pedidos, convite Google, anti-duplicação

- **Deploy de 11/10/2026 (feito por um chat com o conector do Render, a pedido e com aprovação do dono):** backend
  `srv-da6pe0h42hec73dskbs0` e frontend `srv-da6u5461egvs73er3m20` (workspace "My Workspace"), commit `1fd29c7`, os dois
  "live". O backend aplicou as migrations 268, 269, 522 a 525 e 600 sem erros. Quando há o conector, um chat pode fazer deploy
  (`trigger_deploy`, backend primeiro, conferir os logs, depois o frontend); sem ele, continua a ser o dono. Achados da
  configuração real, **ambos RESOLVIDOS pelo dono no painel em 11/10**: `healthCheckPath` do backend agora `/health`; Redis
  (`teste2-redis`, Valkey 8, plano gratuito de 25 MB, ~3,3 MB em uso) passou de `allkeys-lru` para `noeviction` (o BullMQ exige). O reinício do
  Redis causou ~30 s de erros de ligação e recuperou sozinho. **Latência do banco (diagnosticada e corrigida em 11/10; desde 17/10 o banco e o backend estão em Frankfurt, ~2 ms, ver bloco "FEITO em 17/10" no topo — o texto abaixo descreve o cenário antigo Londres/Oregon):** o banco é um Neon em Londres (`eu-west-2`, projeto `aprenda-e-ganhe`) e o backend corre no Render em Oregon. O Postgres executa as queries em ~2 ms (tabelas minúsculas), o tempo perdia-se na rede: a sonda `DB_LATENCY_PROBE` mediu **~1,6 s para abrir uma ligação nova** e **~0,13 s por query numa ligação aberta**. O pool fechava as ligações paradas após 30 s, por isso quase todos os pedidos pagavam uma ligação nova (~0,9 s por query nos logs). Correção: `idleTimeoutMillis` 30 s -> 5 min + `keepAlive` (commit `37eed6d`). Resultado: sem avisos de \"Query lenta\" nos ciclos de 15:45 e 15:50 (antes 934 ms). **Não fazer pings periódicos ao banco para o manter acordado**: gastam a quota de horas de computação do plano gratuito da Neon. **Menos idas ao banco (12/10, commit `c414fd4`, no ar):** cada resposta certa do quiz fazia ~21 queries em sequência (medido); agora são 5 a menos: cache de 60 s só das chaves `quiz_points_reward_*`, `daily_points_cap` e `level_xp_step` (o código nunca escreve em `system_config`, as regras mudam-se no banco e passam a valer em até 60 s; as chaves de dinheiro da carteira NÃO usam cache) e pergunta+alternativas numa só query. Teste `quiz-hot-path-queries.test.js`. **Capacidade estimada (por cálculo, não medida com carga real):** ~50 a 100 jogadores em simultâneo no estado gratuito. Limites: pool de 20 ligações; ~0,13 s por query; limite por IP de 60 pedidos/min e 8 logins/min (redes móveis e turmas partilham IP); bcrypt custo 12 com 0,1 CPU; servidor gratuito adormece após 15 min; quota da Neon (100 CU-horas/mês no plano gratuito, banco suspenso se acabar). Mudar para Frankfurt é grátis mas exige: backend novo (a região não muda), trocar o Redis gratuito (só 1 por workspace) e desligar o backend antigo (750 h grátis por mês). **Limites de pedidos (12/10, commit `c64a3cb`, no ar):** o limite geral (60/min) passou a contar **por utilizador autenticado** (token verificado; um token falso cai no IP), com teto de 600/min por IP (`IP_FLOOD_MAX_REQUESTS`); login e Google passaram de 8 para 30/min por IP (a proteção contra adivinhar senhas é o bloqueio por telefone do `authService`, que não depende do IP); o cadastro tem limite próprio de 15/min por IP. Motivo: internet móvel, turmas e campus partilham IP. Testes `rate-limit-per-user` e `auth-rate-limit-isolation`. **Convite pelo Google (12/10, commit `a09d444`, no ar):** `POST /auth/google` aceita `referralCode` e liga o convite só quando a conta Google é **nova** (quem já tinha conta não pode ser convidado depois); o frontend envia o código vindo de `?ref=` ou do campo do cadastro. Teste `google-login-referral` (provado: falha sem a correção). **Ainda sem proteção** contra contas falsas para ganhar convites (a missão de convidar paga dinheiro, migration 603). **Anti-duplicação de identidades (14/10, migration 606, no ar):** ao eliminar uma conta, o hash (HMAC-SHA256, chave secreta) do telefone, e-mail e Google fica em `used_identities`; quem volta com a mesma identidade pode usar a plataforma mas a conta fica `identity_recycled` e **não recebe o bónus de boas-vindas (até 12 MZN) nem convites**. O e-mail do Gmail ignora pontos e `+tag`: `users.email_normalized`, único por conta ativa. Telefone duplicado já era recusado em todos os caminhos (cadastro, completar perfil Google, mudar número) e pelo índice único. **Definir `IDENTITY_HASH_SECRET` no Render e NUNCA a mudar** (sem ela usa `JWT_ACCESS_SECRET`; mudar qualquer das duas faz o sistema esquecer as identidades guardadas). Não há como reconhecer uma pessoa com vários telefones/Gmails diferentes sem verificar o número por SMS. **Logos das operadoras (14/10):** o campo do número mostra o logo da Vodacom (84/85) ou da Movitel (86/87/88), componente `OperatorLogo`, imagens em `frontend/src/assets/operators`. **Resta (opcional, definitivo):** a distância custa ~0,13 s por query e ~1,6 s numa ligação nova após 5 min parado; mover o backend e o Redis para Frankfurt (região do Render mais perto de Londres e de Moçambique) reduz isso a poucos ms.

## Regra antiga (obsoleta): "Deploys manuais no Render"

- **Deploys no Render são manuais**: o auto-deploy está ligado, mas na prática nenhum push
  dispara deploy sozinho (todos os deploys recentes foram manuais). Depois de dar push, é preciso
  fazer o deploy de `teste2-backend` e `teste2-frontend`.

## GER-001 — Sessão não se perde ao atualizar a página (F5) — CONFIRMADO em produção pelo dono em 2026-10-11
- Pedido: o bug mais importante apontado pelo dono e por um amigo testador: depois do login,
  ao atualizar a página (F5), o app voltava para "Iniciar sessão".
- Já feito (não repetir): causa = cookie do refresh token com `SameSite=strict` enquanto
  frontend e backend ficam em subdomínios diferentes de `onrender.com`. Corrigido com
  `COOKIE_SAMESITE=none` no `render.yaml` (commit `4fc79ad`), nota em `docs/deploy-render.md`,
  e a variável já foi aplicada no serviço `teste2-backend` do Render (deploy Live).
- 2.ª causa achada (2026-10-06, relato do dono: "repete quando atualizo 2 ou 3 vezes"): ao dar F5
  vários pedidos recebem 401 juntos e cada um renovava o token com o MESMO cookie; só o primeiro
  ganhava e a sessão caía. Corrigido em duas frentes: frontend com renovação única compartilhada
  (`refreshSession` em `frontend/src/api/client.js`) e backend com janela de tolerância de 15 s
  para token recém-rodado (`authRepository.findValidRefreshToken`, `REFRESH_GRACE_SECONDS`;
  logout grava data antiga e nunca renova). Teste: `backend/tests/auth-refresh-race.test.js`.
  **Exige deploy manual do backend E do frontend no Render.**
- 3.ª e 4.ª causas achadas (2026-10-08, o dono reportou que o bug continuava): (3) o backend trocava o
  cookie em TODO F5; com o servidor lento (consultas ao banco de ~1 s) o navegador abandonava a resposta, ficava
  com o cookie antigo já revogado e, passados os 15 s de tolerância, a sessão caía. Agora o cookie só é trocado
  quando tem mais de 12 h (`REFRESH_ROTATE_AFTER_HOURS`, `authService.refresh`); um F5 só devolve novo token de
  acesso. (4) `authController.refresh` apagava o cookie em QUALQUER erro, até num erro passageiro do servidor
  (banco lento, reinício); agora só apaga em 401. E `AuthContext.restoreSession` tratava qualquer falha (servidor
  a acordar no plano gratuito, rede fraca, 5xx) como "sem sessão"; agora repete 4 vezes (0, 3, 6 e 10 s) e só um
  401/403 encerra. Testes em `auth-refresh-race.test.js`. **Exige deploy manual dos dois serviços.**
- **Causa de fundo RESOLVIDA em 18/10/2026** (confirmado pelo dono: "o bug de F5 já está feito"): com a mudança para Frankfurt o F5 voltou a
  perder a sessão; `COOKIE_SAMESITE=none` sozinho não chegou. Corrigido tornando a API do MESMO endereço do site (regra `/api/*` da Render +
  `VITE_API_URL`, ver a caixa "FEITO em 17/10/2026" no topo). O texto abaixo fica como histórico.
- (Histórico) Causa de fundo: frontend e backend estão em `teste2-frontend.onrender.com` e
  `teste2-backend.onrender.com`; `onrender.com` é um sufixo público, logo o cookie é de terceiros. Safari/iPhone,
  Firefox, Brave e o modo anónimo do Chrome bloqueiam-no mesmo com `SameSite=None`. Só um domínio próprio com os
  dois no mesmo site (ou o site a encaminhar `/api` para o backend) resolve de vez. Decisão do dono.
- **CONFIRMADO em produção pelo dono (2026-10-11):** depois dos deploys, o F5 já não derruba a sessão. As correções do cookie, da renovação em paralelo, do rodízio do cookie, dos erros passageiros e do limitador de pedidos (`cff7855`) resolveram o caso testado. Não investigar de novo; reabrir só se alguém voltar a reportar. Por confirmar (não foi dito se foi testado): Safari/iPhone e o amigo testador — se cair só aí, ver a causa de fundo abaixo (domínio próprio).
- Se ainda cair no login só no Safari/iPhone: navegadores bloqueiam cookies entre sites mesmo
  com `none`. Solução definitiva = domínio próprio com frontend e API no mesmo site (ex.:
  `app.dominio.com` e `api.dominio.com`) e `COOKIE_SAMESITE=lax`/`strict`. Explicar o passo a
  passo ao dono antes de mexer em DNS ou serviços.
- Cuidados: nunca escrever tokens neste repositório. Os nomes dos serviços reais no Render são
  `teste2-backend` e `teste2-frontend` (diferentes dos do `render.yaml`); confira
  `CORS_ALLOWED_ORIGINS` no painel antes de supor algo.


## Achados de 18 a 21/10/2026 já resolvidos

- **Missão "Explorador" nunca avançava — CORRIGIDO em 21/10/2026 (aprovado pelo dono, commit `b1a4e68`).** `missionProgressService.updateAfterCategoryExploration`
  existia, mas nada a chamava (dia 19/10 tinha jogado 2 categorias e ficou 0/3). Agora `quizService.startRound` chama
  `missionsService.recordCategoryExploration` ao CRIAR uma rodada (não ao retomar a que estava em andamento); categorias repetidas no dia não
  somam; à 3.ª categoria a missão conclui e avisa. Teste: `backend/tests/missions-explorer.test.js` (precisa de PostgreSQL+Redis; corre no
  GitHub Actions). Quem já jogou antes do deploy não recebe retroativo.
- **Conta de teste:** durante os testes de push o progresso de algumas missões da conta BORJA OFICIAL foi adiantado à mão na tabela `user_missions` (só `progress_count`/`active_seconds`/`visited_categories`). Não é bug; não repetir em contas reais.

## Quiz v2 — histórico e estado (o estado ATUAL está na caixa "PRÓXIMO PASSO AGORA", no topo)

Especificação do dono: `docs/quiz-v2-rodadas-e-feedback.md` (ler primeiro). Detalhes de cada
tarefa nos `PENDENTE.md` (`BE-003`, `BE-004`, `BE-005`, `FE-003`). Trabalhar sobre o que já
existe, nunca do zero. Cada etapa: testar, commit descritivo, push e relatório (regra 8).

**Já feito e no GitHub (commits `beec9a1` e `91195e1`):** rodadas de 10 perguntas no servidor
(migration 107, `quiz_rounds`, `backend/src/modules/quiz/services/quizService.js` e
`roundSelection.js`); contador n/10; recuperar a rodada ao recarregar; resumo só da 10.ª e só
daquela rodada com os 3 botões. Testes: `backend/tests/quiz-rounds.test.js` e
`quiz-round-selection.test.js`. Depois de um push, o dono faz o deploy manual: **backend primeiro**
(aplica a migration), depois o frontend.

**A fazer, nesta ordem:**
1. **BE-004 + FE-003 — feedback pedagógico.** Devolver só depois de responder: correta, "Por quê?",
   "O que aprender", dica; mostrar no ecrã de resultado (acerto = confirmar + complementar; erro =
   corrigir + explicar). A coluna `questions.explanation` existe mas está vazia nas 1.659
   perguntas. Escrever as explicações **por categoria**, começando por uma. *Decisão do dono
   tomada: Finanças primeiro* (de 301 perguntas; as outras: IA 336, Marketing Digital 306,
   Produtividade 396, Tecnologia 320), ordem fácil → médio → difícil, em lotes de 10 (pedido do dono em 06/10) com commit e push
   a cada lote. O estado atual e o próximo lote estão em "Progresso das explicações" no BE-004 de
   `backend/PENDENTE.md` — atualizar lá a cada push. Sem explicação, usar um feedback genérico seguro.
2. **BE-003 — REGULARIZAR as alternativas e criar o validador.** Padrão a corrigir: a correta é a
   mais longa em 90,8% das perguntas (a posição já é equilibrada), o que permite acertar ~9 em 10
   só escolhendo a opção mais longa, num quiz que paga dinheiro real. Como regularizar: validador
   só de leitura; depois correção por lotes de 25 com revisão do dono (migrations que só mudam o
   texto das alternativas, sem apagar perguntas), na mesma ordem das explicações e junto com elas
   nas perguntas ainda sem explicação; relatório antes/depois a cada lote. Perguntas reprovadas
   continuam a ser servidas, marcadas para revisão, até serem corrigidas. Plano completo, critérios
   e progresso: `BE-003` em `backend/PENDENTE.md` — atualizar lá a cada push.
3. **BE-005 — sobras:** retirar o uso das rotas antigas sem rodada, tipo de missão "completar
   uma rodada" (hoje o progresso conta por resposta certa), conceitos errados por rodada.

**Testes da especificação:** ainda por confirmar no ecrã, com o site no ar: 9 (botão "Ver missões em
andamento" abre as Missões com o progresso certo) e 16 (rodada que atualiza uma missão). Já verificados
no servidor e por HTTP: 1, 2 (contagem), 4, 5, 6, 10 e 15. Cobertos por testes automáticos do
validador (`backend/tests/quiz-alternatives-validator`, `quiz-bias-detector`, `quiz-duplicate-questions`,
`quiz-position-analysis`, `quiz-new-question-gate`): 11 (correta muito maior), 12 (correta muito menor,
critério `correta_muito_mais_curta`), 13 (duplicadas) e 14 (posição da correta).

## Conta do utilizador (feito)

- **Recuperar a conta sem SMS (feito em 15/10, pedido do dono; o Twilio não está disponível):** quem ligou o Google à conta (Definições, "Recuperar a conta", `POST /auth/link-google`) pode, no login, tocar em "Esqueci a senha" (`/recuperar-senha`), escolher a senha nova e confirmar com esse Google (`POST /auth/recover-with-google`). O servidor confirma o token junto da Google, termina TODAS as sessões antigas e regista `user.password_recovered_google`. **Limite:** só recupera quem ligou o Google ANTES; quem não ligou fica sem recuperação automática (suporte manual). O mesmo Google não liga a duas contas. Teste: `backend/tests/google-recovery.test.js`. Pendente (só se o dono pedir): lembrar quem ainda não ligou o Google (cartão no Dashboard/Carteira) e aviso dentro da app quando a senha for redefinida (exige migration porque `notifications.type` tem CHECK).

- `PUT /users/me/password` (senha atual + nova, mínimo 8; termina as outras sessões; conta criada pelo Google, sem senha, pode DEFINIR uma sem senha atual; o e-mail do Google não muda), `PATCH /users/me` (nome, foto https), `PUT /users/me/payment-phone` (pede senha; operador deduzido do número; 1 mudança a cada 30 dias; bloqueado com saque em andamento; registado em `audit_logs`), `GET /users/me/export` (cópia dos dados), `DELETE /users/me` (pede senha + escrever ELIMINAR; anonimiza, nunca apaga; bloqueado com saque em andamento; saldo restante só se o utilizador aceitar perdê-lo).
- O saque só aceita o método do operador do número registado.
- Saque mínimo: sempre vindo de `GET /wallet` (`withdrawalMinMzn`); o texto fixo "100 MZN" saiu de `Legal.jsx`. O texto jurídico guardado na base (migration 017) ainda cita 100 MZN: mudar só com o dono, porque exige novo aceite.

## Notificações push — o que se resolveu pelo caminho

- **O site abre em branco / erros de ecrã (18/10):** (a) `ProtectedRoute` mandava as contas Google novas (que têm "falta telefone" E "falta aceitar documentos") de `/completar-perfil` para `/reaceitar-termos` e de volta, sem parar; agora o reaceite só é pedido depois do telefone (`!user.needsPhone`), porque "Completar perfil" já regista o aceite. (b) `ErrorBoundary` (`frontend/src/components/ErrorBoundary.jsx`, em `main.jsx`) mostra "Algo correu mal" com "Recarregar" e "Limpar dados e recarregar" em vez de página branca. (c) `ReacceptTerms.jsx` já não finge lista vazia: mostra erro + "Tentar de novo" e links fixos para Termos e Privacidade, e só confirma com a caixa marcada.

## Ideias já feitas (antiga lista "não aprovadas")

1. Teto diário das missões com pedidos simultâneos: **FEITO em 17/10 (aprovado pelo dono):** `walletService.creditReward` bloqueia a linha do utilizador (`walletRepository.lockUserForEarnings`) antes de somar os ganhos do dia; teste `tests/earning-cap-concurrency.test.js` (4 resgates de 3 MZN ao mesmo tempo: sem o bloqueio pagava 12,00, com ele 7,20).
2. Testes para boas-vindas e carteira: **FEITO em 17/10 (`tests/welcome-wallet-money.test.js`, 11 testes com banco real: bónus por dia, cliques simultâneos, dia 8, conta reciclada, saque mínimo/saldo/método/pedido ativo/2 pedidos simultâneos; o código já estava correto).** O `healthCheckPath` `/health` já está posto (18/10).

## Ecrã animado ao subir de nível (FE-007, feito em 21/10/2026)
- Componente `frontend/src/components/LevelUpCelebration.jsx`, ligado em `QuizResult.jsx`: aparece depois do anúncio do resultado, **uma vez por conta e por nível** (guardado em `localStorage` como `levelup_seen:<conta>:<nível>`). Raios dourados, medalha com o número do nível, confetes, brilhos, marca "Aprenda e Ganhe" e a identidade do utilizador (foto `avatarUrl` ou ícone, moldura equipada e primeiro nome). Fecha com o botão, Escape ou toque fora. Com "reduzir movimento" fica estático. É só apresentação (não dá dinheiro nem Pontos). Aparece quando o XP vem de uma resposta do quiz ou do resgate de uma missão (23/10: `POST /missions/:id/claim` passou a devolver `leveledUp` e `newLevel`; página `Missões.jsx`; teste `backend/tests/missions-claim-levelup.test.js`). Não há outra fonte de XP (convites e streak dão só Pontos).
