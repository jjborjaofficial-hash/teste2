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
sem explicação escrita, só a resposta correta. **DESCARTADO pelo dono (11/10):** "Aprenda"/"O que aprender" e dica como campos próprios, e mudar o ecrã conforme o nível (a profundidade fica só no texto de cada explicação). FE-003 não tem mais nada pendente.
## FE-006 — Configurações: conta (feito)
`Settings.jsx` com editar nome/foto, mudar número M-Pesa/e-Mola, descarregar dados e eliminar conta. Carteira fixa o método do saque ao operador do número. `Legal.jsx` sem "100 MZN" fixo.

Settings: secção 'Mudar senha / Criar senha' (conta Google); pedidos de senha só aparecem se `hasPassword`.
