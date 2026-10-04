# PENDENTE — Frontend (FE-)

Instruções reais, decididas pelo dono do projeto. Leia primeiro o `INSTRUCOES.md` da raiz
(protocolo, formato e regras fixas). Ao concluir e testar uma tarefa, **apague-a daqui no
mesmo commit** que a implementa.

## FE-003 — Tela da rodada, feedback e resumo (quiz v2)

Especificação completa: `docs/quiz-v2-rodadas-e-feedback.md`. Depende de BE-002 e BE-004.
Contador 1/10 a 10/10; feedback de acerto e de erro (confirmação + complemento / correção +
explicação + o que aprender + dica) depois de cada uma das 10; sem resumo antes da 10.ª;
resumo só daquela rodada com exatamente 3 botões (Painel inicial, Escolher novamente uma
categoria, Ver missões em andamento), nenhum iniciando rodada sozinho; recuperar o estado ao
recarregar. Sem emojis, design atual, `prefers-reduced-motion`. Substituir a contagem local de
`frontend/src/lib/quizRound.js` pela rodada do servidor.
