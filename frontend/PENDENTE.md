# PENDENTE — Frontend (FE-)

Instruções reais, decididas pelo dono do projeto. Leia primeiro o `INSTRUCOES.md` da raiz
(protocolo, formato e regras fixas). Ao concluir e testar uma tarefa, **apague-a daqui no
mesmo commit** que a implementa.

## FE-003 — Feedback pedagógico depois de cada resposta (quiz v2)

Especificação completa: `docs/quiz-v2-rodadas-e-feedback.md`. Depende de BE-004 (explicações).
Já feito: contador n/10 vindo do servidor, recuperar a rodada ao recarregar, resumo só da 10.ª
e só daquela rodada, com exatamente 3 botões (Painel inicial, Escolher novamente uma categoria,
Ver missões em andamento), nenhum iniciando rodada sozinho. Feito (junto com BE-004): o ecrã de resultado mostra o feedback vindo do servidor — acerto:
"Você identificou a resposta certa." + "Para complementar"; erro: "Resposta correta" + "Por quê?";
sem explicação escrita, só a resposta correta. Falta: "Aprenda"/"O que aprender" e dica opcional como
campos próprios (ver BE-004) e a profundidade por dificuldade quando houver explicações médias e difíceis.
