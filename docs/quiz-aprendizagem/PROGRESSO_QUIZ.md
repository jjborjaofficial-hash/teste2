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
| 3 | Feedback pedagógico (certo/errado) | Pendente |
| 4 | Checkpoint técnico de 5 perguntas | Pendente |
| 5 | Rodada de 10 + resumo da rodada | Pendente |
| 6 | Persistência/recuperação do estado | Pendente |
| 7 | Resumo final do quiz | Pendente |
| 8 | Auditar alternativas | Auditoria feita (ver abaixo); correção pendente |
| 9 | Validador de viés (comprimento/estilo/posição) | Pendente |
| 10 | Conteúdo: corrigir alternativas e escrever explicações | Pendente |
| 11 | Testes | Pendente |
| 12 | Relatório final | Pendente |

## Próximo bloco (checkpoint 1)

1. Backend: `submitAnswer` passa a devolver `correctAlternativeId` e `explanation`
   (só depois de registar a resposta; a pergunta continua sem expor a correta).
2. Backend: devolver `difficulty` e `categoryId` no resultado para o feedback e o resumo.
3. Frontend: ecrã de resultado com feedback pedagógico (acerto: confirmação + complemento;
   erro: resposta correta + explicação + o que aprender + dica), destacando a alternativa
   correta e a escolhida.
4. Tratar pergunta sem explicação (fallback sem inventar texto).
5. Testes unitários do novo comportamento do `submitAnswer`.

## Decisões em aberto (confirmar com o proprietário)

- **Anúncio intersticial:** hoje aparece 5 s antes do resultado e esconderia a explicação.
  Proposta: mostrar primeiro o feedback e o anúncio depois (ao avançar). Ainda não confirmado.
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
- **Commit / Push:** ver histórico da branch `feat/quiz-aprendizagem`.
- **Próximo bloco:** checkpoint 1 (ver acima).
