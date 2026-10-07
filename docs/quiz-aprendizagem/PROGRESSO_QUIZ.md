# Progresso da atualização do Quiz

Instrução completa: [`INSTRUCAO_QUIZ.md`](./INSTRUCAO_QUIZ.md).
Este ficheiro é atualizado **a cada checkpoint** (~5 alterações, fim de secção ou fim da feature).

Branch de trabalho: `feat/quiz-aprendizagem`

---

## Leia primeiro (nota de 2026-10-04, atualizada)

- **Próximo pedaço a fazer: P8** (o primeiro `[ ]` da lista abaixo): integração do quiz com as missões (a rodada concluída atualiza `/missoes` sem duplicar progresso nem recompensa). Só ele, depois commit + push.
- **Atenção, junção com o `main`**: o `main` andou muito (explicações das perguntas de Finanças, feedback pedagógico, login com Google) e um merge de teste da branch do quiz dá conflito em `Quiz.jsx`, `QuizResult.jsx` e `quizRound.js`, além de migrações com o mesmo prefixo (108, 109, 110). Fazer a junção como passo próprio, com a suíte completa a correr, antes de pedir merge.
- **Teste obrigatório antes de qualquer código do quiz** (o cronómetro é antifraude, mexe em dinheiro).
  Para correr os testes de verdade numa sessão onde `npm install` e `apt` funcionem:
  1. `apt-get update && apt-get install -y postgresql redis-server`; `service postgresql start`;
     `redis-server --daemonize yes` (use `redis-cli config set dir /tmp` para o Redis não largar `dump.rdb` no repositório).
  2. Criar um banco **descartável** de teste (ex.: utilizador e banco `aprenda_test`) e correr `npm run migrate:up` no `backend/`
     com `DATABASE_URL`, `DATABASE_SSL=false`, `REDIS_URL`, `JWT_ACCESS_SECRET` e `JWT_REFRESH_SECRET` (32+ caracteres) definidos.
  3. `RUN_DB_TESTS=1 npx jest --runInBand --forceExit --testTimeout=30000` (liga também os testes de integração do quiz).
  4. Entre execuções seguidas, `redis-cli flushall`: o limitador de pedidos guarda contadores no Redis e, sem limpar, o `auth.test.js`
     e outros passam a receber 429.
  Em 2026-10-05 a suíte completa passou: 18 conjuntos, 125 testes (com `RUN_DB_TESTS=1`). Uma sessão anterior teve `npm install` e `apt-get`
  **bloqueados (erro 403)**; nesse caso NÃO implemente código do quiz sem poder testar: faça só documentação.
- Decisões do proprietário em [`INSTRUCAO_QUIZ.md`](./INSTRUCAO_QUIZ.md) ("Decisões do proprietário"):
  intersticial inalterado, reescrita das perguntas em lotes pequenos, e atualizar este
  ficheiro e subir a cada pedaço.

## Estado atual (versão 2 da instrução)

Feito e enviado: análise (cp. 0), feedback pedagógico no servidor e no ecrã (cp. 1),
rodada de 10 persistente com checkpoint dos 5 e resumo da rodada (cp. 2).

## Próximos pedaços (um por vez; commit + push a cada um)

Marcar `[x]` ao concluir e enviar. Pegar sempre o primeiro `[ ]`.

**Resumo e navegação**
- [x] P1. Resumo da rodada com os 3 botões exatos: Painel inicial (`/dashboard`), Escolher novamente uma categoria (`/hub-estudos`), Ver missões em andamento (`/missoes`). Verificado por build e leitura do código (o frontend não tem executor de testes; falta ver no navegador, P18).
- [x] P2. Ecrã de resultado da 10.ª pergunta: depois do feedback o único caminho é "Ver resumo da rodada" (sem atalho para o Painel).
- [x] P3a. Rótulos do feedback com os dados atuais: "Correto!" + "Você identificou a resposta certa." + "Para complementar:" / "Resposta incorreta." + "Resposta correta:" + "Por quê?".
- [x] P3b. Campos próprios `learn_point` ("Aprenda:" / "O que aprender:") e `memory_tip` ("Dica:", só ao errar): migration 108, repositório e serviço (estes três já tinham entrado no commit `a8dd5f8`, junto com a documentação) e agora também o ecrã de resultado. Testes: 23 unitários e 4 com banco real passam; build do frontend passa. As colunas continuam vazias até ao conteúdo (P15).

**Seleção e persistência da rodada**
- [x] P4. Migration 109 `quiz_round_questions` (rodada, posição 1..N, pergunta): posição única e a mesma pergunta nunca duas vezes na rodada; índice por pergunta para o histórico recente (P5). Testado no banco real (restrições de posição repetida, pergunta repetida e posição 0). Ainda não é usada pelo serviço (P5 e P6).
- [x] P5a. Lógica pura de seleção `roundQuestionPicker` (10 únicas, mistura 4 fáceis / 4 médias / 2 difíceis, prefere as não vistas nos últimos 14 dias e depois as vistas há mais tempo, completa com outras dificuldades, ordem do fácil ao difícil). 10 testes unitários passam. Ainda não ligada ao serviço.
- [x] P5b. Seleção ligada ao banco: ao iniciar a rodada, as 10 perguntas são escolhidas (preferindo as que o utilizador não respondeu nos últimos 14 dias) e gravadas em `quiz_round_questions`, com a rodada bloqueada (`FOR UPDATE`); recarregar não troca as perguntas; rodadas antigas já começadas seguem o caminho anterior. Testes: 37 unitários e 9 de integração com banco real (posições 1..10, mistura 4/4/2, do fácil ao difícil, duas chamadas simultâneas, 2.ª rodada sem repetir a 1.ª). Ainda não é a pergunta servida: ver P6.
- [x] P6a. Cronómetro antifraude: `markQuestionIssued(..., { keepExisting: true })` mantém a emissão ORIGINAL quando a mesma pergunta é servida outra vez (recarregar não dá tempo grátis para pesquisar a resposta; uma resposta fora do tempo conta como esgotada). TTL longo (12 h) só nesse modo; o modo normal fica igual. 5 testes com Redis falso passam. Ainda não é usado (P6b).
- [x] P6b. `next-question` serve a pergunta pela posição guardada (a primeira ainda não respondida; sem perguntas guardadas, mantém o caminho antigo), com `keepExisting` e devolvendo `time_remaining_seconds` (tempo RESTANTE). Testado no banco real (Postgres + Redis): serve na ordem das posições; recarregar devolve a mesma pergunta, mantém o relógio original e não duplica respostas; tempo já esgotado ao recarregar = 0 s e a resposta conta como tempo esgotado; rodada antiga sem perguntas guardadas continua aleatória. O frontend ainda não usa o campo novo (P6c).
- [x] P6c. Frontend (`Quiz.jsx`): o contador regressivo parte de `time_remaining_seconds` (cai para `time_limit_seconds` se o campo não vier). Recarregar a página já não devolve o tempo todo; se já esgotou, o contador começa em 0 e envia a resposta de tempo esgotado como antes (efeito já existente). Compila sem erro; falta só a prova no navegador (P18).
- [x] P7. Histórico da rodada: ao concluir, o servidor grava na própria rodada `correct_count`, `total_response_ms`, `xp_total` e `points_total` (migração `110_quiz_round_totals.sql`, aditiva, colunas opcionais). O resumo usa esses totais e passou a devolver `totalSeconds` (tempo total); rodadas antigas sem totais continuam calculadas pelas tentativas. Pontos = valor bruto por dificuldade (o líquido creditado continua em `points_ledger`). Recompensas de missões NÃO são guardadas aqui: pertencem ao P8. Aviso para a junção com o `main`: o prefixo 110 também existe lá (`110_explicacoes_financas_facil_lote02.sql`); o executor regista por NOME de ficheiro, então não colide, mas confirmar na junção.

**Missões**
- [ ] P8. Analisar a integração atual do quiz com missões; testar que a rodada concluída atualiza `/missoes` sem duplicar progresso nem recompensa (teste 16).

**Validador de perguntas (16 controlos)**
- [ ] P9. Módulo validador: contagem, uma só correta, duplicadas e quase iguais (controlos 1 a 5) + testes.
- [ ] P10. Validador de tamanho (caracteres e palavras) (controlo 6): correta muito MAIOR (teste 11) e muito MENOR (teste 12).
- [ ] P11. Validador de estrutura e pistas (controlos 7 a 9, 11, 12): pontuação, termos técnicos, absolutos, explicação embutida.
- [ ] P12. Validador de posição (controlo 10; teste 14 com várias perguntas seguidas), explicação presente e coerente (13, 14), categoria e dificuldade (15, 16).
- [ ] P13. Script de auditoria do banco com relatório de viés por categoria e dificuldade.
- [ ] P14. Gancho do validador nos pontos de entrada de novas perguntas (importação/admin, se existirem).

**Conteúdo (por lotes pequenos, uma migration de UPDATE por lote, com revisão humana recomendada)**
- [x] P15. Piloto (lote 01): Finanças / difícil, 25 perguntas, migration `111_content_financas_dificil_lote_01.sql`. Antes: a correta era a mais longa em 25 de 25 (99% na categoria) e as erradas eram absurdas. Depois: a correta é a mais longa em 6 de 25 (24%), razão média correta/erradas 1,02 (entre 0,91 e 1,10), sem alternativas quase iguais e sem palavras absolutas só nas erradas; erradas plausíveis; cada pergunta com explicação, "Aprenda" e "Dica". Verificado no banco: mesmos IDs de alternativa, mesma posição da correta e mesmo `is_correct`; rodar de novo não altera nada (idempotente, só preenche perguntas sem explicação). Viés da categoria: 99% -> 80% (restam 76 perguntas). **Revisão humana do texto recomendada.** Medido só com scripts próprios: o validador (P9 a P12) ainda não existe, por isso o P15 não foi "validado com o validador" e deve ser reconferido quando ele existir.
- [ ] P16. Restantes lotes, um por vez (de 25), na mesma receita. Próximo: Finanças / difícil (76 restantes), depois Marketing Digital / difícil (98%), Finanças / médio (97%), IA / difícil (97%).

**Receita de um lote (P16)** — cada lote = 1 migration `NNN_content_<categoria>_<dificuldade>_lote_NN.sql`:
1. Escolher 25 perguntas ativas sem `explanation`, das mais enviesadas: `correta / média das erradas` por pergunta, ordem decrescente.
2. Para cada uma, escrever 4 alternativas (a correta em primeiro na lista de trabalho; no SQL cada texto vai para o `display_order` que a alternativa já tinha) e `explanation`, `learn_point`, `memory_tip`. Manter enunciado, dificuldade e significado da correta; distratores plausíveis (confusões reais, conceito vizinho), nunca absurdos.
3. Metas medidas por script antes de gerar: correta estritamente a mais longa em cerca de 25% do lote (não em 0%: ser sempre a mais curta também denuncia); razão correta/erradas entre 0,8 e 1,2; sem alternativas com similaridade > 0,8; sem absolutos (sempre, nunca, apenas, todos...) só nas erradas.
4. Gerar o SQL com `UPDATE ... FROM (VALUES ...)` das alternativas e das perguntas, ambos protegidos por `explanation IS NULL`; aplicar no banco de teste e comparar antes/depois (IDs, posições, `is_correct` inalterados; segunda execução não altera nada).
5. Testes do quiz, commit, push. Texto em português do projeto (ortografia já usada no banco: "econômica", "planejamento", "controle").

**Acabamento**
- [x] P17. Acessibilidade. Já existia (global, `index.css`): `prefers-reduced-motion` (cobre a barra do cronómetro, a única animação do quiz) e foco visível `:focus-visible`; confirmado. Acrescentado: atalhos de teclado **1 a 4** para as alternativas (`aria-keyshortcuts`), alternativas agrupadas e ligadas ao enunciado (`role="group"`), barra do tempo com nome e valor, aviso do tempo ao leitor de ecrã só nos momentos-chave (30 %, 10 s, 5 s e fim, em vez de todos os segundos) e foco automático no enunciado / no resultado / no resumo. Verificado só por build e leitura do código: **não** testado com leitor de ecrã nem no navegador (fica no P18).
- [ ] P18. Teste manual no navegador e relatório final.

## Matriz dos 16 testes obrigatórios (estado real)

Legenda: OK = testado e a passar; PARCIAL = parte feita; PENDENTE = por fazer.
"Não visto no navegador" = o frontend só foi compilado (sem executor de testes), ver P18.

| # | Teste | Estado |
|---|---|---|
| 1 | Entrar na categoria inicia rodada de 10 | PARCIAL: a rodada abre e as 10 perguntas são escolhidas e guardadas (integração OK); falta servir por essa ordem (P6) |
| 2 | Acerto: confirmação + complemento | OK (unitário); explicações ainda vazias no banco (P15) |
| 3 | Erro: correção + explicação + aprendizagem | OK (unitário); idem |
| 4 | Na 5.ª continua, sem resumo | OK (integração: checkpoint só na 5.ª, sem resumo); não visto no navegador |
| 5 | 10.ª: feedback, conclusão, resumo | OK (integração); não visto no navegador |
| 6 | Resumo só daquela rodada | OK (integração: 80% em 10) |
| 7 | Painel inicial | PARCIAL: botão feito (P1), não visto no navegador |
| 8 | Escolher novamente uma categoria | PARCIAL: botão feito (P1), não visto no navegador |
| 9 | Ver missões em andamento | PARCIAL: botão feito (P1); progresso atualizado por testar (P8) |
| 10 | Nova categoria -> nova rodada, 10 novas perguntas | PARCIAL: nova rodada escolhe 10 perguntas, preferindo as não vistas (integração OK); falta servir por essa ordem (P6) |
| 11 | Correta muito maior detetada | PENDENTE (P10) |
| 12 | Correta muito menor detetada | PENDENTE (P10) |
| 13 | Alternativas duplicadas rejeitadas | PENDENTE (P9) |
| 14 | Posição da correta sem padrão | PENDENTE: distribuição atual ~25% por posição; falta teste automático (P12) |
| 15 | Recarregar a meio da rodada | OK (integração); não visto no navegador |
| 16 | Rodada atualiza missão sem duplicar | PENDENTE (P8) |

## Decisões e pontos em aberto

- **Resolvido:** cada rodada é independente; sem quiz completo e sem resumo final (briefing 3).
- **Anúncio intersticial:** RESOLVIDO (2026-10-04). O proprietário confirmou que continua com
  a mesma lógica de antes. Não alterar `InterstitialAds` nem a contagem de 5 s.
- **Reescrita das perguntas (P15 em diante):** confirmado pelo proprietário que é pedaço por
  pedaço (lotes de 25, um por vez, com revisão humana).
- **Risco conhecido:** errar de propósito revela a resposta correta de uma pergunta que pode
  voltar a sair. É inerente a um feedback que ensina; evitar repetições reduz o efeito (P5).
- O briefing 3 foi recebido completo (16 testes e 22 critérios); ver a matriz abaixo.

---

## Achados da análise (checkpoint 0)

**Arquitetura do quiz**

- Backend: `backend/src/modules/quiz/` (rotas, controller, `quizService`, `quizRepository`,
  `quizTimerService`, validadores). Rotas: `GET /quiz/categories`,
  `GET /quiz/categories/:id/next-question`, `POST /quiz/answers`.
- Frontend: `frontend/src/pages/Quiz.jsx`, `QuizResult.jsx`, `lib/quizRound.js`,
  `api/quizApi.js`. Rotas `/quiz/:categoryId` e `/quiz/:categoryId/resultado`.
- Tabelas: `questions` (com coluna `explanation`, `tags`, `source`), `question_alternatives`
  (`is_correct`, `display_order`), `quiz_attempts`. Índice único garante 1 correta por pergunta.

**O que já está bom (não mexer sem necessidade)**

- A pergunta enviada ao cliente não traz `is_correct`. A validação é 100% no servidor.
- O tempo de resposta é medido no servidor (Redis); o cliente não envia tempo.
- A posição da correta já está equilibrada (~25% por posição).

**Lacunas**

- `submitAnswer` não devolve a alternativa correta nem a explicação.
- **Nenhuma pergunta tem `explanation` preenchida** (nenhuma seed usa a coluna).
- A rodada de 10 existe só no `location.state` do React (não persiste no servidor; perde-se
  com certas navegações). Não há checkpoint técnico nem resumo por categoria/conceito.
- `ORDER BY random()` pode repetir perguntas na mesma rodada.
- No timeout o cliente submete `alternatives[0]` automaticamente.
- Intersticial de 5 s antes do resultado (ver decisões em aberto).
- O banco só tem dificuldades `easy`, `medium`, `hard`.
- Testes existentes do quiz só verificam 401 (sem cobertura do `submitAnswer`).

**Auditoria das alternativas** (1.659 perguntas únicas, todas com 4 alternativas)

| Métrica | Resultado | Esperado ao acaso |
|---|---|---|
| Correta é a mais longa (em caracteres) | 89,4% | ~25% |
| Correta tem pelo menos 1,5x o tamanho médio das erradas | 83,0% | baixo |
| Correta tem pelo menos 2x o tamanho médio das erradas | 66,1% | baixo |
| Posição da correta (1.ª / 2.ª / 3.ª / 4.ª) | 25,7 / 25,5 / 24,9 / 23,9% | 25% cada |

Piores grupos (correta mais longa): finanças difícil 98%, IA difícil 97%, marketing
digital difícil 97%, tecnologia médio 94%.

---

## Registo de checkpoints

### Checkpoint 0: documentação e análise

- **Implementado:** instrução mestre e este registo guardados no repositório; análise do
  quiz (backend, frontend, schema) e auditoria das alternativas.
- **Testado:** auditoria por script sobre as migrations de seed (parser de SQL). Nenhum
  código de produção foi alterado.
- **Commit / Push:** `61306ba`, enviado com sucesso.
- **Próximo bloco:** checkpoint 1.

### Checkpoint 1: feedback pedagógico (5 alterações)

- **Implementado:**
  1. `quizRepository`: devolve `explanation` e o texto das alternativas ao validar a resposta.
  2. `quizService.submitAnswer`: devolve `correctAlternative`, `chosenAlternativeId`,
     `explanation`, `difficulty` e `categoryId` só depois de registar a resposta. Anti-colheita:
     não revela a correta se a pergunta não foi entregue ao utilizador (sem registo do cronómetro).
  3. `quizController`: mensagens passam a "Correto!" e "Resposta incorreta.".
  4. Frontend: ecrã de resultado com o feedback (resposta escolhida, resposta correta,
     explicação), tom sem humilhação; `Quiz.jsx` passa o texto da pergunta ao resultado.
  5. Anúncio intersticial movido para o momento de avançar. Pergunta sem explicação mostra
     só a resposta correta (nada é inventado).
- **Testado:**
  - Novo `backend/tests/quiz-feedback.test.js` (8 testes, passam): acerto, erro, tempo esgotado,
    anti-colheita, sem explicação, explicação vazia, alternativa inválida, e a pergunta enviada
    ao cliente sem `is_correct`/`explanation`. Teste `login-mission` continua a passar.
  - `npm run build` do frontend passa.
  - **Não executado:** o teste supertest existente (`quiz-wallet-ranking`) precisa de Redis,
    que não existe neste ambiente. Não foi feito teste manual no navegador nem com banco real.
  - O repositório não tem configuração do ESLint, por isso não houve lint.
- **Commit / Push:** ver histórico da branch (commit `feat(quiz): add pedagogical feedback ...`).
- **Próximo bloco:** checkpoint 2 (ver acima).

### Checkpoint 2: rodada de 10 persistente, checkpoint dos 5 e resumo da rodada

- **Implementado:**
  1. Migration `107_quiz_rounds.sql`: tabela `quiz_rounds` (estado, `checkpoint_at`,
     `completed_at`, `summary_shown_at`; uma rodada em andamento por utilizador e categoria) e
     coluna `quiz_attempts.round_id`. Aditiva; tentativas antigas ficam com `round_id` nulo.
  2. `quizRepository`: funções da rodada; `getRandomQuestion` exclui as já respondidas na
     rodada (só repete se o banco da categoria esgotar); `categoryExists`.
  3. `quizService`: `next-question` abre/retoma a rodada e devolve `question.round`
     (respondidas, acertos, alvo); `submitAnswer` liga a tentativa à rodada (com `FOR UPDATE`),
     devolve `round` com `checkpoint` (aos 5, sem resumo) e `completed` (aos 10); rodada parada
     há mais de 12 h é abandonada; categoria inválida dá 404.
  4. Novo `GET /api/v1/quiz/rounds/:roundId/summary` (acertos, erros, %, XP, pontos, tempo médio,
     por dificuldade, lista "para rever" com a resposta correta). Só para rodada concluída e do
     próprio utilizador. Tentativas feitas sem a pergunta ter sido entregue ficam fora da rodada
     (não permitem colher respostas pelo resumo).
  5. Frontend: contador "Pergunta N de 10" vindo do servidor, aviso de progresso guardado aos 5,
     botão "Ver resumo da rodada" na 10.ª, nova tela `QuizRoundSummary` (sem emojis, componentes
     existentes). Removido o estado de rodada do navegador.
- **Testado:**
  - Novo `quiz-rounds.test.js` (unitário, 13 testes) e `quiz-feedback.test.js` atualizado: passam.
  - Novo `quiz-rounds.integration.test.js` com **Postgres 16 e Redis reais** (ligado com
    `RUN_DB_TESTS=1`): rodada de 10 sem repetir perguntas, checkpoint só na 5.ª, conclusão só na
    10.ª, resumo com 80% (8 de 10), nova rodada depois de concluir, retomar após recarregar,
    resumo recusado em rodada em andamento e 404 para outro utilizador, e anti-colheita. Passa.
  - Migration 107 aplicada sobre as 106 anteriores sem erro. Os números da auditoria foram
    confirmados no banco real (1.659 perguntas, 0 explicações, 1.483 com a correta mais longa).
  - Suíte completa do backend: 14 de 15 ficheiros passam (83 testes), incluindo
    `quiz-wallet-ranking`, que antes não terminava sem Redis.
  - `auth.test.js` tem 3 falhas que **já existem no código original** (falham igual sem estas
    alterações); não foram investigadas por estarem fora do escopo.
  - `npm run build` do frontend passa.
  - **Não feito:** teste manual no navegador (a interface foi compilada, não vista a correr).
- **Ambiente de teste (para futuras sessões):** `apt-get update && apt-get install -y postgresql
  redis-server`; criar um banco descartável, aplicar `node src/database/migrate.js up` com um
  `DATABASE_URL`/`REDIS_URL` locais e correr os testes com `RUN_DB_TESTS=1`. Não pôr
  credenciais no repositório.
- **Commit / Push:** ver histórico da branch.
- **Próximo bloco:** ver "Próximos pedaços" (P1 em diante).

- [x] FIX-ANUNCIO. Restaurado o fluxo ORIGINAL do intersticial em `QuizResult.jsx` (5 s logo depois de responder, depois o resultado), como pediu o proprietário. A versão anterior, minha, mostrava o resultado primeiro e o anúncio só ao tocar num botão: era uma mudança indevida. Bloco do anúncio idêntico ao da base.
