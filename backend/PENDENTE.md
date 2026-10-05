# PENDENTE — Backend (BE-)

Instruções reais, decididas pelo dono do projeto. Leia primeiro o `INSTRUCOES.md` da raiz
(protocolo, formato e regras fixas). Ao concluir e testar uma tarefa, **apague-a daqui no
mesmo commit** que a implementa.

## BE-005 — Sobras das rodadas do quiz v2

BE-002 (rodadas no servidor: migration 107, `quiz_rounds`, seleção das 10, retomar ao recarregar,
resumo só da rodada) já foi feito e testado. Sobram: (a) a rota antiga
`GET /quiz/categories/:id/next-question` + `POST /quiz/answers` sem `roundId` continua a servir
perguntas fora de rodada; o frontend já não os usa (usa só `/quiz/rounds`); decidir se o servidor passa a
exigir `roundId` e remover `nextQuestion` de `frontend/src/api/quizApi.js`; (b) não existe tipo de missão "completar uma rodada" (hoje o progresso das
missões conta por resposta certa); (c) guardar os conceitos errados por rodada para
recomendações (hoje só há `reviewStatements` no resumo).

## BE-003 — Qualidade das alternativas e validador de perguntas (quiz v2)

Medido no banco real (1.659 perguntas, migrations 001–106): a alternativa correta é a **mais
longa em 90,8%** das perguntas e a mais curta em só 3,7%; a posição já é equilibrada (~25% em
cada). Criar o validador (tamanho em caracteres/palavras, estrutura, detalhe, duplicadas/quase
iguais, só uma correta, categoria/dificuldade) com fila de revisão: reprovadas não são servidas
automaticamente. Embaralhar a ordem das alternativas por apresentação sem quebrar a validação no
backend. Decisão do dono pendente: o que fazer com as perguntas já existentes que reprovarem
(ver a mensagem do dono no chat; não apagar nada sem aprovação).

## BE-004 — Feedback pedagógico: explicação em cada pergunta (quiz v2)

A coluna `questions.explanation` existe (migration 022) mas está vazia nas 1.659 perguntas, e a
resposta do quiz não a devolve. Devolver, só depois de responder: resposta correta, "Por quê?",
"O que aprender" e dica opcional, adaptados à dificuldade. Conteúdo: escrever as explicações
por categoria, começando por uma (decisão do dono pendente: qual primeiro). Sem explicação, usar
um feedback genérico seguro enquanto o conteúdo não existir.

**Progresso das explicações (atualizar a cada push).** Decisão do dono: começar por Finanças; ordem
fácil → médio → difícil; lotes de 5 perguntas, e cada lote = migration + testes + commit + push +
esta atualização. Dentro de cada dificuldade segue-se a ordem dos seeds e, em cada seed, a ordem das
perguntas no ficheiro. A explicação é o "Por quê?" (coluna `questions.explanation`), curta e em
linguagem simples nas fáceis.
- Finanças fácil (seeds 045 → 064 → 068 → 094 → 099): **feito** lote 01 = perguntas 1 a 5 do seed 045
  (migration 109), lote 02 = perguntas 6 a 10 (migration 110) e lote 03 = perguntas 11 a 15
  (migration 111). **Próximo:** lote 04 = perguntas 16 a 20 do seed 045 (começa em "O que é uma
  compra planejada?").
- Finanças médio (seeds 046 → 065 → 069 → 100): pendente.
- Finanças difícil (seeds 047 → 073 → 074 → 075 → 083): pendente.
- IA, Marketing Digital, Produtividade, Tecnologia: pendentes (ordem a decidir pelo dono).

Nota: até a parte técnica (devolver a explicação na resposta + mostrá-la no ecrã, FE-003) estar feita,
estas migrations só preenchem o texto; o jogador ainda não o vê.
