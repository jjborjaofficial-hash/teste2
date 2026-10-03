# PENDENTE — Frontend (FE-)

Instruções reais, decididas pelo dono do projeto. Leia primeiro o `INSTRUCOES.md` da raiz
(protocolo, formato e regras fixas). Ao concluir e testar uma tarefa, **apague-a daqui no
mesmo commit** que a implementa.

## FE-001 — Botões de ação visíveis nos cards de Missões
- Pedido: "os botões para ação precisam ser visíveis" ("Começar missão", "Continuar"). Hoje os
  cards de `pages/Missions.jsx` não têm botão de ação enquanto a missão está em andamento: só
  existe "Resgatar recompensa" (missão completa) e um link de texto pequeno para o Hub de
  Estudos no fim da página.
- Proposta apresentada ao dono (ele pediu para registrá-la como próximo passo):
  - Missão de quiz (ex.: "Maratona", "desafios de quiz"): botão `PrimaryButton` cheio, largura
    total. Texto "Começar missão" quando o progresso é 0 e "Continuar" quando já começou. Leva
    à escolha de categoria do quiz (`/hub-estudos`). Mostrar o que falta (ex.: "Faltam 10 acertos").
  - Missão de tempo ("12 minutos de estudo"): contagem é do servidor (heartbeat), sem botão de
    iniciar. Mostrar "Faltam X min" e um botão "Estudar agora" para `/hub-estudos`.
  - Missão de login ("Entrar na plataforma"): automática, sem botão.
  - Missão completa: "Resgatar recompensa" maior e em destaque.
  - Missão resgatada: sem botão, só selo "Concluída".
- Onde mexer: `frontend/src/pages/Missions.jsx` (cards), `frontend/src/components/Button.jsx`.
- Pronto quando: em tela de celular (largura ~360px) cada missão em andamento mostra um botão
  azul cheio e legível; o toque leva à tela certa; `npm run build` passa; tema Noite continua legível.
- Cuidados: não mudar regra de negócio nem valores de recompensa (frontend só apresenta). O
  tempo ativo continua medido só pelo servidor. Não criar botão que pareça "ganhar dinheiro
  clicando".

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
