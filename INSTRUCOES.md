# INSTRUÇÕES — leia isto primeiro

Este ficheiro é o ponto de partida para quem (pessoa ou IA) vai trabalhar neste repositório.
O dono do projeto (Borja) só precisa de enviar o **link do repositório**: tudo o que está
por fazer fica escrito aqui e nos ficheiros `PENDENTE.md` de cada área.

> ## PRÓXIMO PASSO AGORA
> **Atualizado em 15/10 e verificado de forma independente.** O conteúdo do **Quiz v2 está COMPLETO**: reconstruindo a base do
> zero com todas as migrations, as 5 categorias têm **100% das explicações (1.641 perguntas ativas)**, o validador reprova **0** e a
> correta é a mais longa em **20,4%** (era 90,8%; meta <= 35% por grupo). Os 48 grupos de testes do backend passam (767 testes).
> **Não há mais lotes de alternativas nem de explicações por fazer: não abrir lotes nem reservas novas.** Qualquer texto de
> "RESERVADO" ou "PRÓXIMO lote" que ainda apareça no `backend/PENDENTE.md` é histórico; confira sempre pelas migrations em
> `backend/database/migrations/` antes de agir (esse texto antigo já enganou uma sessão).
>
> **O que falta agora (nada disto é conteúdo do quiz):**
> 1. **Anúncios (Adcash).** Nos prints do dono de 13/10 apareceram anúncios de conteúdo adulto e um aviso falso de "Flash Player" por cima
>    das perguntas. O código já foi corrigido (commit `3ceb5e7`: script do Interstitial retirado do resultado do quiz), mas o **dono tem de
>    refazer o deploy do frontend** no Render, **configurar as restrições de categoria nas 4 zonas do Adcash** (separador *Restrictions*) e
>    denunciar o anúncio falso ao suporte. Interruptor geral de emergência: `VITE_ADS_ENABLED=false`.
> 2. **Capacidade.** No plano gratuito aguenta cerca de 50 a 100 pessoas ao mesmo tempo (cada consulta custa ~0,13 s entre o Render em
>    Oregon e o Neon em Londres; pool de 20 ligações; quota do Neon de 100 CU-horas/mês). Melhoria mais barata: servidor e base na **mesma
>    região**. Antes de lançar: plano pago, worker no Render e teste de carga.
> 3. **Decisões do dono** (secção "Ideias ainda NÃO aprovadas", no fim): teto diário vs pedidos simultâneos (dinheiro), verificação por
>    SMS, economia vs receita real do Adcash, testes + deploy automático, e o destino da branch `feat/quiz-aprendizagem` (abaixo).
>    **Não implementar sem aprovação.**
> 4. O dono conferir os rascunhos em `docs/quiz-lotes-alternativas/`.

- **Vulnerabilidades de dependências (npm audit, 2026-10-09):** o `npm audit fix` seguro já foi aplicado (saiu a crítica `proxy-addr` e a alta `compression`; backend 19 → 12). **`bcrypt` 5 → 6 FEITO em 14/10 (aprovado pelo dono; testes verdes no ramo à parte e no main; backend publicado).** **`firebase-admin` 12 → 14 FEITO em 15/10 (pedido do dono; `pushService.js` passou à API modular `firebase-admin/app` e `/messaging`) e `firebase` (frontend) 10 → 13; `uuid` (não usado) removido.** Em produção (`npm audit --omit=dev`) sobram no backend 2 moderadas (`uuid` dentro do `gaxios`, sem uso do caminho afetado) e no frontend 6 (`react-router`, `@grpc/grpc-js`/firestore que o projeto não importa). O resto são ferramentas de desenvolvimento (`jest`, `nodemon`, `vite`, `tailwindcss`), que não vão para produção; só trocar com o dono. O `firebase-messaging-sw.js` continua a usar o `firebase` 10.13 compat via CDN (independente do pacote).

>
> **Atenção — branch paralela do quiz.** Existe no GitHub a branch `feat/quiz-aprendizagem` com
> OUTRA implementação das rodadas do quiz (feita antes de se seguir a linha do `main`). Os números
> das migrations colidem com os do `main` (107, 108 e 109 existem nos dois com conteúdos
> diferentes). **Não fazer merge dessa branch no `main`** e não copiar migrations dela sem o dono
> decidir; o trabalho do quiz continua no `main`, como descrito na secção do Quiz v2.
>
> **Testes automáticos.** A cada push o GitHub roda `.github/workflows/testes.yml` (migrations
> num banco novo, testes do backend e build do frontend); o resultado fica na aba **Actions** e ao
> lado de cada commit. Serve para confirmar os testes mesmo quando o ambiente da sessão não
> consegue rodar `npm install`. Não faz deploy (o deploy no Render continua manual). Se ficar
> vermelho, leia o relatório antes de continuar.
>
> **Decisão do dono (2026-10-04):** o anúncio intersticial continua com a mesma lógica de antes
> (`InterstitialAds`, 5 segundos, mesma frequência); não alterar.
>
> **Tarefas automáticas SEM worker pago (2026-10-11, pedido do dono: sem dinheiro para o worker).** As 11 tarefas de
> `backend/src/cron/jobs/` correm agora dentro do backend: um agendador externo gratuito chama `POST /internal/cron/tick`
> a cada 5 minutos, e qualquer acesso real é rede de segurança. Como ligar, conferir e desligar (se um dia houver
> worker): `docs/agendador-sem-worker.md`. **Não criar o worker pago e o agendador ao mesmo tempo.**

## Como funciona (protocolo)

1. **Clonar e ler.** Ao receber o link: clone o repositório e leia este ficheiro e todos os
   `PENDENTE.md` (`find . -name PENDENTE.md -not -path "*/node_modules/*"`).
2. **Resumir ao dono.** Diga, em poucas linhas, o que está pendente em cada área. O quiz tem
   uma secção própria com a ordem de execução: **"Quiz v2 — estado e próximos passos"** (abaixo).
3. **Executar só o que o dono pedir.** Tudo o que está nos `PENDENTE.md` é real e foi
   decidido pelo dono, mas a ordem e o momento são dele. Se ele disser "faz tudo", faça por
   ordem de ID. Dúvida em regra de negócio, dinheiro, segurança ou apagar dados: **pergunte antes**.
4. **Testar de verdade.** Rode os testes (`backend`: `npm test`, precisa de PostgreSQL e Redis;
   `frontend`: `npm run build`) e, quando mexer em regra de dinheiro, teste com dados reais.
5. **Apagar a instrução concluída.** Quando uma tarefa estiver feita e testada, **remova-a do
   `PENDENTE.md` no mesmo commit** que a implementa. Não deixe histórico de tarefas feitas
   nos ficheiros: o histórico é o `git log`. A mensagem do commit cita o ID (ex.: `BE-003`).
6. **Se ficar vazio**, mantenha o cabeçalho do ficheiro e a linha "Nenhuma instrução pendente.".
7. **Publicar.** O `git push` precisa de um token do GitHub que o dono cria só para isso
   (Fine-grained, só este repositório, **Contents: Read and write**, validade curta) e apaga
   depois. O token **nunca** é escrito neste repositório.
8. **Push por checkpoint, nunca com código quebrado.** Faça commit e `git push` quando uma
   funcionalidade importante ou uma etapa estrutural fechar (testada), ou a cada ~5
   alterações significativas (testar, ver erros, revisar o diff, commit, push, continuar).
   Nunca acumule trabalho para publicar tudo no fim e nunca publique código quebrado só para
   "chegar a 5": a qualidade vem primeiro. Motivo: se a sessão acabar ou o limite for
   atingido a meio, o que já foi concluído já está no GitHub e o que falta continua escrito
   nos `PENDENTE.md`. Antes de cada push: `git status`, branch certa, `git diff`, testes e
   nenhum segredo. Depois, relate: CHECKPOINT, IMPLEMENTADO, TESTADO, COMMIT, PUSH, PRÓXIMO
   BLOCO. Mensagens de commit descritivas (nada de "update" ou "fix" soltos).

## Onde ficam as instruções

| Área | Ficheiro | Prefixo |
|---|---|---|
| Geral / vários módulos | `INSTRUCOES.md` (este, secção abaixo) | GER- |
| Backend (API, regras, base de dados) | `backend/PENDENTE.md` | BE- |
| Frontend (telas e componentes) | `frontend/PENDENTE.md` | FE- |
| Anúncios (Adcash) | `frontend/src/ads/PENDENTE.md` | ADS- |

Se uma tarefa nova não encaixar em nenhuma área, crie um `PENDENTE.md` na pasta certa
(por exemplo `backend/src/modules/wallet/PENDENTE.md`) e acrescente-o a esta tabela.

## Formato de cada instrução

```
## BE-001 — Título curto
- Pedido: o que o dono quer, nas palavras dele.
- Onde mexer: caminhos prováveis.
- Pronto quando: como saber que está certo (critérios que dá para testar).
- Cuidados: dinheiro, segurança, migrations, o que NÃO misturar.
```

## Regras fixas do projeto (não quebrar sem o dono pedir)

- **Teto de ganho diário: 7,20 MZN, só das missões** (o utilizador só chega a 7,20 se completar as 6 missões; o valor não é garantido). Prémios de streak em dinheiro e conversão de Pontos em MZN ficam **fora** do teto. Chave `daily_earning_cap_mzn` em `system_config`. Lógica do dono: quem acumula muitos Pontos passou muito tempo na plataforma e viu muitos anúncios, então a receita de anúncios cobre a conversão; por isso ela não tem teto em MZN (o limite é o teto diário de Pontos, `daily_points_cap` = 5000).
- **Bónus de convite: 20% do MZN que cada convidado ganha nas MISSÕES DIÁRIAS, para sempre (regra do dono, 12/10; migration 720, `backend/src/modules/referrals/services/referralBonusService.js`, `tests/referral-bonus.test.js`).** É um extra pago pela plataforma a quem convidou: nada é tirado ao convidado (ele recebe o valor inteiro) e o bónus fica FORA do teto de 7,20 MZN de quem convida (fonte própria `referral_bonus`; o teto só soma `mission_reward`). É 20% do valor REALMENTE creditado ao convidado (se o teto cortar o convidado, o bónus acompanha o corte). Só conta com o convite já qualificado (status `rewarded`) e só em missões `daily` (semanais, especiais, streak e boas-vindas não geram bónus). A percentagem está em `system_config.referral_bonus_percent` (20; 0 desliga). O resgate da missão e o bónus correm na mesma transação, por isso nunca há bónus em duplicado. Aparece no histórico da carteira como "Bónus de convite" e no cartão de convites do Perfil. **Risco conhecido:** convidar contas falsas (a própria pessoa) rende mais 20% por cima do que já se podia farmar; a verificação do telefone por SMS (ideia GER 3) e o saque só pelo número do operador são as defesas principais.
- **Missões diárias:** 6 por dia, 1,20 MZN cada (login, 12 minutos ativos e 4 desafios de quiz).
  O tempo ativo é medido só pelo servidor (heartbeat); o cliente nunca envia tempo.
- **Quiz:** 50 segundos por pergunta (era 30; decisão do dono em 11/10, migration 600), barra fina horizontal.
- **Streak:** quebra de verdade quando o utilizador falta um dia. O item de proteção (marco de 15 dias) perdoa **um único dia perdido, uma só vez**; faltando 2 dias ou mais, o streak quebra e o item continua guardado. Os prémios de streak são um mecanismo de **retenção**: pagam **sempre** que o marco (7, 15, 30, 60, 100 dias) é atingido de novo, sem limite de uma vez por utilizador.
- **Tema Noite emprestado (12/10, decisão do dono):** contas novas recebem 10 minutos de Tema Noite logo depois do cadastro (ecrã de informação e depois "Modo escuro / Modo claro"); o servidor manda no tempo (`users.theme_trial_*`, migration 605, rotas `/shop/theme-trial`), é uma vez por conta e não é compra (não entra no inventário). Escolher "Modo claro" não gasta a oferta (fica um cartão na Loja e nas Configurações). Contas antigas não recebem. O Tema Noite continua à venda na Loja.
- **Bónus de boas-vindas:** calendário de 7 dias, dia 1 = 2,00 MZN, cada dia só é coletado no
  próprio dia, dia perdido fica bloqueado. Valores em `system_config` (`welcome_rewards_mzn`).
  Fica fora do teto diário e é independente de missões e streak. **Não misturar** as duas coisas.
- **Saque mínimo:** 100 MZN (configuração `withdrawal_min_mzn`). O utilizador nunca deposita, só levanta o que ganhou.
  O servidor devolve o valor em `GET /wallet` (`withdrawalMinMzn`) e a Carteira e as Configurações já o leem de lá. **Ficam fixos, de propósito, por serem texto legal publicado:** `frontend/src/pages/Legal.jsx` (Termos, linha ~245, e FAQ, linha ~308) e os documentos em `docs/`. **Se o dono mudar o mínimo**, é preciso atualizar esses textos à mão e decidir, com o dono, se sobe `TERMS_VERSION` (o que obriga todos a reaceitar os Termos, ver `docs/reaceite-termos-e-correcao-regras-saque.md`).
- **Deploys no Render são manuais**: o auto-deploy está ligado, mas na prática nenhum push
  dispara deploy sozinho (todos os deploys recentes foram manuais). Depois de dar push, é preciso
  fazer o deploy de `teste2-backend` e `teste2-frontend`.
- **Deploy de 11/10/2026 (feito por um chat com o conector do Render, a pedido e com aprovação do dono):** backend
  `srv-da6pe0h42hec73dskbs0` e frontend `srv-da6u5461egvs73er3m20` (workspace "My Workspace"), commit `1fd29c7`, os dois
  "live". O backend aplicou as migrations 268, 269, 522 a 525 e 600 sem erros. Quando há o conector, um chat pode fazer deploy
  (`trigger_deploy`, backend primeiro, conferir os logs, depois o frontend); sem ele, continua a ser o dono. Achados da
  configuração real, **ambos RESOLVIDOS pelo dono no painel em 11/10**: `healthCheckPath` do backend agora `/health`; Redis
  (`teste2-redis`, Valkey 8, plano gratuito de 25 MB, ~3,3 MB em uso) passou de `allkeys-lru` para `noeviction` (o BullMQ exige). O reinício do
  Redis causou ~30 s de erros de ligação e recuperou sozinho. **Latência do banco (diagnosticada e corrigida em 11/10):** o banco é um Neon em Londres (`eu-west-2`, projeto `aprenda-e-ganhe`) e o backend corre no Render em Oregon. O Postgres executa as queries em ~2 ms (tabelas minúsculas), o tempo perdia-se na rede: a sonda `DB_LATENCY_PROBE` mediu **~1,6 s para abrir uma ligação nova** e **~0,13 s por query numa ligação aberta**. O pool fechava as ligações paradas após 30 s, por isso quase todos os pedidos pagavam uma ligação nova (~0,9 s por query nos logs). Correção: `idleTimeoutMillis` 30 s -> 5 min + `keepAlive` (commit `37eed6d`). Resultado: sem avisos de \"Query lenta\" nos ciclos de 15:45 e 15:50 (antes 934 ms). **Não fazer pings periódicos ao banco para o manter acordado**: gastam a quota de horas de computação do plano gratuito da Neon. **Menos idas ao banco (12/10, commit `c414fd4`, no ar):** cada resposta certa do quiz fazia ~21 queries em sequência (medido); agora são 5 a menos: cache de 60 s só das chaves `quiz_points_reward_*`, `daily_points_cap` e `level_xp_step` (o código nunca escreve em `system_config`, as regras mudam-se no banco e passam a valer em até 60 s; as chaves de dinheiro da carteira NÃO usam cache) e pergunta+alternativas numa só query. Teste `quiz-hot-path-queries.test.js`. **Capacidade estimada (por cálculo, não medida com carga real):** ~50 a 100 jogadores em simultâneo no estado gratuito. Limites: pool de 20 ligações; ~0,13 s por query; limite por IP de 60 pedidos/min e 8 logins/min (redes móveis e turmas partilham IP); bcrypt custo 12 com 0,1 CPU; servidor gratuito adormece após 15 min; quota da Neon (100 CU-horas/mês no plano gratuito, banco suspenso se acabar). Mudar para Frankfurt é grátis mas exige: backend novo (a região não muda), trocar o Redis gratuito (só 1 por workspace) e desligar o backend antigo (750 h grátis por mês). **Limites de pedidos (12/10, commit `c64a3cb`, no ar):** o limite geral (60/min) passou a contar **por utilizador autenticado** (token verificado; um token falso cai no IP), com teto de 600/min por IP (`IP_FLOOD_MAX_REQUESTS`); login e Google passaram de 8 para 30/min por IP (a proteção contra adivinhar senhas é o bloqueio por telefone do `authService`, que não depende do IP); o cadastro tem limite próprio de 15/min por IP. Motivo: internet móvel, turmas e campus partilham IP. Testes `rate-limit-per-user` e `auth-rate-limit-isolation`. **Convite pelo Google (12/10, commit `a09d444`, no ar):** `POST /auth/google` aceita `referralCode` e liga o convite só quando a conta Google é **nova** (quem já tinha conta não pode ser convidado depois); o frontend envia o código vindo de `?ref=` ou do campo do cadastro. Teste `google-login-referral` (provado: falha sem a correção). **Ainda sem proteção** contra contas falsas para ganhar convites (a missão de convidar paga dinheiro, migration 603). **Anti-duplicação de identidades (14/10, migration 606, no ar):** ao eliminar uma conta, o hash (HMAC-SHA256, chave secreta) do telefone, e-mail e Google fica em `used_identities`; quem volta com a mesma identidade pode usar a plataforma mas a conta fica `identity_recycled` e **não recebe o bónus de boas-vindas (até 12 MZN) nem convites**. O e-mail do Gmail ignora pontos e `+tag`: `users.email_normalized`, único por conta ativa. Telefone duplicado já era recusado em todos os caminhos (cadastro, completar perfil Google, mudar número) e pelo índice único. **Definir `IDENTITY_HASH_SECRET` no Render e NUNCA a mudar** (sem ela usa `JWT_ACCESS_SECRET`; mudar qualquer das duas faz o sistema esquecer as identidades guardadas). Não há como reconhecer uma pessoa com vários telefones/Gmails diferentes sem verificar o número por SMS. **Logos das operadoras (14/10):** o campo do número mostra o logo da Vodacom (84/85) ou da Movitel (86/87/88), componente `OperatorLogo`, imagens em `frontend/src/assets/operators`. **Resta (opcional, definitivo):** a distância custa ~0,13 s por query e ~1,6 s numa ligação nova após 5 min parado; mover o backend e o Redis para Frankfurt (região do Render mais perto de Londres e de Moçambique) reduz isso a poucos ms.
- **Migrations rodam sozinhas no deploy do backend**: o comando de início do `teste2-backend` é
  `npm run migrate:up && npm start`. Não é preciso rodar migrations à mão (ver `docs/deploy-render.md`).
- Dinheiro creditado passa sempre por `walletService.creditReward` (promoções únicas usam
  `ignoreDailyCap`).
- Este repositório é **público**: nunca escrever senhas, chaves ou tokens em nenhum ficheiro.

## Pendente — geral (GER-)

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
- Causa de fundo ainda aberta: frontend e backend estão em `teste2-frontend.onrender.com` e
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

## Ideias ainda NÃO aprovadas (NÃO implementar até o dono pedir)

Isto NÃO é o próximo passo e não são instruções: são pontos já conversados que o dono ainda não aprovou, na
ordem de prioridade sugerida. Quando ele aprovar um, passa a ser uma instrução na área certa
(`BE-`, `FE-`, `ADS-` ou `GER-`) e sai desta lista.

1. Teto diário das missões: bloquear a linha do utilizador antes de somar os ganhos do dia, para dois pedidos simultâneos não furarem o teto (dinheiro).
2. Cadastro: verificar o telefone por SMS (Twilio já está nas dependências) para evitar contas falsas.
3. Economia: conferir se o bónus de boas-vindas (12,00 MZN por utilizador) e a conversão de Pontos (até ~50 MZN/dia por utilizador no teto de 5.000 Pontos) cabem na receita real de anúncios (Adcash).
4. Testes para boas-vindas e carteira; fazer o push disparar o deploy sozinho (hoje é manual) e pôr um `healthCheckPath` no backend.

## Prefixos dos números (regra fixa)
Vodacom (M-Pesa): 84, 85 · Movitel (e-Mola): 86, 87, 88. A regra vive num só sítio: `backend/src/common/phone.js` (validação, operador, mensagens) e `frontend/src/lib/phone.js` (logo e aviso). Para um prefixo novo, mude só esses dois ficheiros e os textos de ajuda (Register, CompleteProfile, Legal). Teste: `phone-prefixes.test.js`.
