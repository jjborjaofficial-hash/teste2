# PENDENTE — Backend (BE-)

Instruções reais, decididas pelo dono do projeto. Leia primeiro o `INSTRUCOES.md` da raiz
(protocolo, formato e regras fixas). Ao concluir e testar uma tarefa, **apague-a daqui no
mesmo commit** que a implementa.

## BE-001 — Teto de 7,20 MZN só para as missões
- Pedido: o teto diário de 7,20 MZN vale só para as missões. Prémios de streak em dinheiro e conversão de Pontos em MZN ficam fora do teto. O 7,20 não é garantido: depende das missões que o utilizador completar.
- Onde mexer: `backend/src/modules/wallet/repositories/walletRepository.js` (`sumEarningsToday`: somar só `mission_reward`), `walletService.js` (`convertPointsToMoney`: remover a checagem do teto; `creditReward`), `gamification/services/streakService.js` (`grantMilestoneReward`: creditar com `ignoreDailyCap: true`), mensagens/notificações do teto e testes.
- Pronto quando: converter Pontos funciona mesmo com as 6 missões feitas no dia; prémio de streak em dinheiro paga o valor inteiro; missões continuam limitadas a 7,20 por dia; teste cobrindo os três casos.
- Cuidados: mexe em regra de dinheiro. Não misturar com o bónus de boas-vindas. Rodar `npm test` com PostgreSQL e Redis.

