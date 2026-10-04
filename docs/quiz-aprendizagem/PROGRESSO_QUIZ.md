# Progresso da atualização do Quiz

Instrução completa: [`INSTRUCAO_QUIZ.md`](./INSTRUCAO_QUIZ.md).
Este ficheiro é atualizado **a cada checkpoint** (~5 alterações, fim de secção ou fim da feature).

Branch de trabalho: `feat/quiz-aprendizagem`

---

## Estado atual

| Fase | Descrição | Estado |
|---|---|---|
| 1 | Analisar o projeto existente | Concluída (checkpoint 0) |
| 2 | Identificar ficheiros a modificar | Concluída (checkpoint 0) |
| 3 | Feedback pedagógico (certo/errado) | Concluída no código (checkpoint 1). Falta o conteúdo das explicações (fase 10) |
| 4 | Checkpoint técnico de 5 perguntas | Concluída (checkpoint 2) |
| 5 | Rodada de 10 + resumo da rodada | Concluída (checkpoint 2) |
| 6 | Persistência/recuperação do estado | Concluída (checkpoint 2), testada com banco real |
| 7 | Resumo final do quiz | Pendente |
| 8 | Auditar alternativas | Auditoria feita (ver abaixo); correção pendente |
| 9 | Validador de viés (comprimento/estilo/posição) | Pendente |
| 10 | Conteúdo: corrigir alternativas e escrever explicações | Pendente |
| 11 | Testes | Pendente |
| 12 | Relatório final | Pendente |

## Próximo bloco (checkpoint 3): validador de alternativas + resumo final

1. Módulo validador (`quizQuestionValidator`) com os 12 controlos da secção 7: nº de
   alternativas, uma só correta, duplicadas/quase iguais, comprimento (caracteres e palavras),
   estrutura, palavras absolutas, posição da correta. Resultado: aprovada / rever / rejeitada.
2. Script de auditoria do banco (relatório de viés por categoria/dificuldade) usando o validador.
3. Testes do validador: caso 7 (correta muito maior), 8 (posição previsível), 9 (duplicadas).
4. Gancho nos pontos de entrada de novas perguntas (seeds/importação/admin, se existirem).
5. Resumo final do quiz (depende da decisão em aberto sobre "quiz completo", abaixo).

Depois: fase 10 (conteúdo): reescrever alternativas enviesadas e escrever explicações, por lotes.

## Decisões em aberto (confirmar com o proprietário)

- **O que é o "quiz completo" e a rodada seguinte?** Hoje cada categoria é um banco de perguntas
  aleatórias, sem um quiz fechado de 30 perguntas. Implementado: a rodada de 10 termina no
  resumo, e o utilizador volta ao Hub de Estudos (comportamento que já existia). Abrir a
  categoria de novo começa uma rodada nova. Para o "resumo final consolidado de todas as
  rodadas" é preciso definir o que agrupa as rodadas (por exemplo, o dia, uma sessão, ou um
  quiz de N rodadas). Sem essa definição, o resumo final (checkpoint 3) fica por fazer.

- **Anúncio intersticial:** passou a aparecer ao avançar (depois do feedback), em vez de antes
  do resultado (implementado no checkpoint 1 seguindo a proposta). Confirmar se o proprietário
  concorda, por afetar a monetização.
- **Risco conhecido:** errar de propósito revela a resposta correta de uma pergunta que pode
  voltar a sair. É inerente ao feedback que ensina; a rodada sem repetição (checkpoint 2) reduz isto.
- **Conteúdo:** 1.659 perguntas precisam de explicação e de reescrita das alternativas.
  Será feito por lotes, em migrations; recomenda-se revisão humana.

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
- **Próximo bloco:** checkpoint 3 (ver acima).
