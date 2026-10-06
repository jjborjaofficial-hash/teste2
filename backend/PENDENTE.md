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
- Finanças fácil (seeds 045 → 064 → 068 → 094 → 099): **feito** o seed 045 inteiro (33 perguntas;
  migrations 109 a 113) e as 52 primeiras do seed 064 (migrations 113 a 118) — 85 explicações escritas
  até aqui. **Próximo:** seed 064 a partir da 53.ª pergunta ("O que é uma fonte de renda?"; source
  `seed_financas_facil_v2`, 59 perguntas, faltam 7), depois 068, 094 e 099.
- Finanças médio (seeds 046 → 065 → 069 → 100): pendente.
- Finanças difícil (seeds 047 → 073 → 074 → 075 → 083): pendente.
- IA, Marketing Digital, Produtividade, Tecnologia: pendentes (ordem a decidir pelo dono).

Parte técnica **feita**: `submitAnswer` já devolve `feedback` ({ correctAlternativeId,
correctAlternativeLabel, explanation }) depois de responder, só se a pergunta foi entregue ao
utilizador (senão `null`, para ninguém colher respostas por id), e a tela de resultado mostra-o.
`explanation` é `null` nas perguntas ainda sem texto: aí a tela mostra só a resposta correta.
Decisão do dono: um único texto de explicação serve para acerto ("Para complementar") e erro
("Por quê?"). Falta, só se o dono quiser: "O que aprender" e "Dica" como campos próprios (exigiria
colunas novas e reescrever as explicações já feitas).
