# PENDENTE — Frontend (FE-)

Instruções reais, decididas pelo dono do projeto. Leia primeiro o `INSTRUCOES.md` da raiz
(protocolo, formato e regras fixas). Ao concluir e testar uma tarefa, **apague-a daqui no
mesmo commit** que a implementa.

## FE-002 — Revisar visibilidade de outros botões de ação
- Pedido: o dono achou que os botões de ação em geral precisam ficar mais visíveis. Verificar
  o "Continuar" do fim do quiz (`pages/QuizResult.jsx`, hoje mostra "Continuar em Ns" /
  "Você já pode continuar"), o "Continuar"/"Começar" do `pages/Onboarding.jsx` e os botões do
  Dashboard.
- Onde mexer: `frontend/src/pages/QuizResult.jsx`, `Onboarding.jsx`, `Dashboard.jsx`,
  `components/Button.jsx`.
- Pronto quando: ação principal de cada tela é um `PrimaryButton` (azul cheio) e as secundárias
  não competem com ela; o dono confirma por captura de tela no celular.
- Cuidados: pedir ao dono uma captura de tela do quiz antes de mexer, para não mudar o que já
  está bom. `SecondaryButton` (só borda) é fraco em tela de celular ao sol.
