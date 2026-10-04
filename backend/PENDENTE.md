# PENDENTE — Backend (BE-)

Instruções reais, decididas pelo dono do projeto. Leia primeiro o `INSTRUCOES.md` da raiz
(protocolo, formato e regras fixas). Ao concluir e testar uma tarefa, **apague-a daqui no
mesmo commit** que a implementa.

## BE-002 — Rodadas de 10 perguntas no servidor (quiz v2)

Especificação completa: `docs/quiz-v2-rodadas-e-feedback.md`. Hoje não existe conceito de rodada:
`getRandomQuestion` faz `ORDER BY random() LIMIT 1` (sem histórico, pode repetir) e a contagem de
10 é só no frontend (commit 43b1409, `frontend/src/lib/quizRound.js`). Falta: tabelas de rodada
(`quiz_rounds` + as 10 perguntas selecionadas + progresso/respostas), seleção das 10 respeitando
`quiz_attempts` (sem repetir na rodada nem as recentes, com mistura de dificuldades),
endpoint para iniciar rodada, recuperar a rodada ao recarregar (reaproveitar o `quizTimerService`
que já devolve a mesma pergunta), fechar a rodada na 10.ª resposta com o resumo só dela
(acertos, erros, %, XP, conceitos a rever), e ligar ao progresso das missões existente sem
duplicar recompensa. Registrar histórico por rodada. A correta nunca vai ao frontend antes de
responder (hoje já é assim; manter).

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
