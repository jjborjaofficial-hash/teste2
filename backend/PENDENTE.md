# PENDENTE — Backend (BE-)

Instruções reais, decididas pelo dono do projeto. Leia primeiro o `INSTRUCOES.md` da raiz
(protocolo, formato e regras fixas). Ao concluir e testar uma tarefa, **apague-a daqui no
mesmo commit** que a implementa.

## BE-001 — Investigar missão "Entrar na plataforma" aparecendo 0/1
- Pedido: numa captura de tela da aba Missões (2026-10-04), com o usuário logado, a missão
  "Entrar na plataforma" ("Faça login hoje.") aparecia em 0/1 (0%). Descobrir se é bug de
  contagem ou comportamento esperado (ex.: só conta no login e não ao restaurar a sessão).
- Onde mexer: `backend/src/modules/missions/` (progresso e atribuição) e o ponto onde o login
  registra progresso (`backend/src/modules/auth/`).
- Pronto quando: causa explicada ao dono; se for bug, corrigido com teste (`npm test`); se
  for esperado, o texto da missão no frontend deixa isso claro.
- Cuidados: envolve dinheiro (1,20 MZN por missão e teto de 7,20 MZN/dia). Não creditar duas
  vezes. Crédito sempre via `walletService.creditReward`. Dúvida de regra: perguntar ao dono.
