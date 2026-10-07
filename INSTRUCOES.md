# INSTRUÇÕES — leia isto primeiro

Este ficheiro é o ponto de partida para quem (pessoa ou IA) vai trabalhar neste repositório.
O dono do projeto (Borja) só precisa de enviar o **link do repositório**: tudo o que está
por fazer fica escrito aqui e nos ficheiros `PENDENTE.md` de cada área.

> ## PRÓXIMO PASSO AGORA
> **O trabalho em andamento é o Quiz v2.** A ordem de execução está na secção
> **"Quiz v2 — estado e próximos passos"** (mais abaixo neste ficheiro). Resumo:
> 1. Feedback pedagógico depois de cada resposta (`BE-004` + `FE-003`). Finanças (fácil, médio, difícil) está
>    **concluída**; **ordem seguinte (decidida pelo dono em 2026-10-07):** 1.º Finanças só com a correção das alternativas (lotes de 25, com revisão do dono; regra: a certa e a explicação não mudam, só se ajustam as erradas; **Finanças fácil CONCLUÍDO (lotes 1 a 4, migrations 141 a 144); próximo: Finanças médio, lote 1, migration 145**), 2.º IA (explicações + alternativas juntas), 3.º Marketing, Produtividade e Tecnologia. Detalhe em `backend/PENDENTE.md` (BE-003/BE-004).
> 2. Validador de qualidade das alternativas (`BE-003`): validador **feito** (`npm run quiz:validate`, relatório no CI) e
>    ordem das opções já aleatória; padrão e modelos em `docs/quiz-v2-alternativas-padrao.md`; **próximo:** o dono ver o relatório e aprovar o 1.º lote de 25 correções.
> 3. Sobras das rodadas (`BE-005`).
>
> Os pontos da secção **"Ideias ainda NÃO aprovadas"** (fim do ficheiro) **não** são para
> implementar: só se o dono aprovar.
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
- **Missões diárias:** 6 por dia, 1,20 MZN cada (login, 12 minutos ativos e 4 desafios de quiz).
  O tempo ativo é medido só pelo servidor (heartbeat); o cliente nunca envia tempo.
- **Quiz:** 30 segundos por pergunta, barra fina horizontal.
- **Streak:** quebra de verdade quando o utilizador falta um dia. O item de proteção (marco de 15 dias) perdoa **um único dia perdido, uma só vez**; faltando 2 dias ou mais, o streak quebra e o item continua guardado. Os prémios de streak são um mecanismo de **retenção**: pagam **sempre** que o marco (7, 15, 30, 60, 100 dias) é atingido de novo, sem limite de uma vez por utilizador.
- **Bónus de boas-vindas:** calendário de 7 dias, dia 1 = 2,00 MZN, cada dia só é coletado no
  próprio dia, dia perdido fica bloqueado. Valores em `system_config` (`welcome_rewards_mzn`).
  Fica fora do teto diário e é independente de missões e streak. **Não misturar** as duas coisas.
- **Saque mínimo:** 100 MZN. O utilizador nunca deposita, só levanta o que ganhou.
- **Deploys no Render são manuais**: o auto-deploy está ligado, mas na prática nenhum push
  dispara deploy sozinho (todos os deploys recentes foram manuais). Depois de dar push, é preciso
  fazer o deploy de `teste2-backend` e `teste2-frontend`.
- **Migrations rodam sozinhas no deploy do backend**: o comando de início do `teste2-backend` é
  `npm run migrate:up && npm start`. Não é preciso rodar migrations à mão (ver `docs/deploy-render.md`).
- Dinheiro creditado passa sempre por `walletService.creditReward` (promoções únicas usam
  `ignoreDailyCap`).
- Este repositório é **público**: nunca escrever senhas, chaves ou tokens em nenhum ficheiro.

## Pendente — geral (GER-)

## GER-001 — Confirmar em produção que a sessão não se perde ao atualizar a página (F5)
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
- Falta: o dono (e o amigo) confirmarem no ar (depois do deploy dos dois): sair, entrar de novo
  (obrigatório, cookie antigo), atualizar a página várias vezes seguidas, em várias telas, e
  continuar logado.
- Se ainda cair no login só no Safari/iPhone: navegadores bloqueiam cookies entre sites mesmo
  com `none`. Solução definitiva = domínio próprio com frontend e API no mesmo site (ex.:
  `app.dominio.com` e `api.dominio.com`) e `COOKIE_SAMESITE=lax`/`strict`. Explicar o passo a
  passo ao dono antes de mexer em DNS ou serviços.
- Cuidados: nunca escrever tokens neste repositório. Os nomes dos serviços reais no Render são
  `teste2-backend` e `teste2-frontend` (diferentes dos do `render.yaml`); confira
  `CORS_ALLOWED_ORIGINS` no painel antes de supor algo.

## Quiz v2 — estado e próximos passos (ordem de execução) — ESTES SÃO OS PRÓXIMOS PASSOS

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
   Produtividade 396, Tecnologia 320), ordem fácil → médio → difícil, em lotes de 5 com commit e push
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

**Testes da especificação ainda por confirmar:** 9 (botão "Ver missões em andamento" abre as
Missões com o progresso certo), 11 a 14 (dependem do validador), 16 (rodada que atualiza uma
missão). Já verificados no servidor e por HTTP: 1, 2 (contagem), 4, 5, 6, 10 e 15.

## Ideias ainda NÃO aprovadas (NÃO implementar até o dono pedir)

Isto NÃO é o próximo passo e não são instruções: são pontos já conversados que o dono ainda não aprovou, na
ordem de prioridade sugerida. Quando ele aprovar um, passa a ser uma instrução na área certa
(`BE-`, `FE-`, `ADS-` ou `GER-`) e sai desta lista.

1. Teto diário das missões: bloquear a linha do utilizador antes de somar os ganhos do dia, para dois pedidos simultâneos não furarem o teto (dinheiro).
2. Carteira/Legal: ler o saque mínimo da API (`withdrawal_min_mzn`) em vez de fixar 100 MZN no código.
3. Cadastro: verificar o telefone por SMS (Twilio já está nas dependências) para evitar contas falsas.
4. Economia: conferir se o bónus de boas-vindas (12,00 MZN por utilizador) e a conversão de Pontos (até ~50 MZN/dia por utilizador no teto de 5.000 Pontos) cabem na receita real de anúncios (Adcash).
5. Testes para boas-vindas e carteira; fazer o push disparar o deploy sozinho (hoje é manual) e pôr um `healthCheckPath` no backend.
6. Editar nome, foto e provedor de pagamento (M-Pesa / e-Mola) no perfil — precisa de endpoint novo e regras de segurança, porque o provedor define para onde o dinheiro vai.
7. Eliminar a conta do utilizador.
