# Progresso da atualização do Quiz

Instrução completa: [`INSTRUCAO_QUIZ.md`](./INSTRUCAO_QUIZ.md).
Este ficheiro é atualizado **a cada checkpoint** (~5 alterações, fim de secção ou fim da feature).

Branch de trabalho: `feat/quiz-aprendizagem`

---

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
- [ ] P4. Migration: guardar as 10 perguntas da rodada e a posição atual (`quiz_round_questions`).
- [ ] P5. Selecionar as 10 perguntas ao iniciar a rodada (variedade de dificuldade; evitar as vistas recentemente pelo utilizador).
- [ ] P6. `next-question` serve a pergunta pela posição guardada; testes de recarregar/duplicar resposta.
- [ ] P7. Histórico da rodada: tempo total, XP e recompensas guardados na rodada.

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
- [ ] P15. Piloto: 25 perguntas (alternativas equilibradas + explicações) e validar com o validador.
- [ ] P16 em diante. Restantes lotes por categoria e dificuldade (1.659 perguntas; ~66 lotes de 25).

**Acabamento**
- [ ] P17. Acessibilidade: `prefers-reduced-motion` e navegação por teclado nas alternativas.
- [ ] P18. Teste manual no navegador e relatório final.

## Matriz dos 16 testes obrigatórios (estado real)

Legenda: OK = testado e a passar; PARCIAL = parte feita; PENDENTE = por fazer.
"Não visto no navegador" = o frontend só foi compilado (sem executor de testes), ver P18.

| # | Teste | Estado |
|---|---|---|
| 1 | Entrar na categoria inicia rodada de 10 | PARCIAL: a rodada abre (integração OK), mas as 10 perguntas ainda não são selecionadas de uma vez (P4 a P6) |
| 2 | Acerto: confirmação + complemento | OK (unitário); explicações ainda vazias no banco (P15) |
| 3 | Erro: correção + explicação + aprendizagem | OK (unitário); idem |
| 4 | Na 5.ª continua, sem resumo | OK (integração: checkpoint só na 5.ª, sem resumo); não visto no navegador |
| 5 | 10.ª: feedback, conclusão, resumo | OK (integração); não visto no navegador |
| 6 | Resumo só daquela rodada | OK (integração: 80% em 10) |
| 7 | Painel inicial | PARCIAL: botão feito (P1), não visto no navegador |
| 8 | Escolher novamente uma categoria | PARCIAL: botão feito (P1), não visto no navegador |
| 9 | Ver missões em andamento | PARCIAL: botão feito (P1); progresso atualizado por testar (P8) |
| 10 | Nova categoria -> nova rodada, 10 novas perguntas | PARCIAL: nova rodada abre ao entrar (OK); seleção das 10 pendente (P5) |
| 11 | Correta muito maior detetada | PENDENTE (P10) |
| 12 | Correta muito menor detetada | PENDENTE (P10) |
| 13 | Alternativas duplicadas rejeitadas | PENDENTE (P9) |
| 14 | Posição da correta sem padrão | PENDENTE: distribuição atual ~25% por posição; falta teste automático (P12) |
| 15 | Recarregar a meio da rodada | OK (integração); não visto no navegador |
| 16 | Rodada atualiza missão sem duplicar | PENDENTE (P8) |

## Decisões e pontos em aberto

- **Resolvido:** cada rodada é independente; sem quiz completo e sem resumo final (briefing 3).
- **Anúncio intersticial:** passou a aparecer ao avançar, depois do feedback (cp. 1). Confirmar
  com o proprietário, por afetar a monetização.
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
