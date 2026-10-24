# Teste de carga (local, nunca contra produção)

Mede o custo por pedido e simula muitos utilizadores com o servidor limitado a 10% de um núcleo (como a Render gratuita, 0,1 CPU).
Resultados e conclusões: `docs/teste-de-carga-2026-10.md`.

1. Ter PostgreSQL e Redis de TESTE locais com as migrations (`npm run migrate`).
2. `./startserver.sh` (arranca o backend na porta 3300).
3. `node setup.js 150` (cria 150 utilizadores `LOAD n` na base de testes).
4. `node cpu.js` (CPU por pedido, sem limite).
5. `node loadtest.js <utilizadores> <segundos> usage` (uso normal) ou `node loadtest.js <n> 0 rush` (logins ao mesmo tempo). O limite de CPU usa `throttle.py` (SIGSTOP/SIGCONT, como o `cpulimit`).
6. Parar o servidor: `kill $(cat server.pid)`.

Limitações: o CPU deste teste é o da máquina onde corre, não o da Render; o limite por SIGSTOP/SIGCONT deixa vários fios trabalharem ao mesmo tempo dentro da janela, por isso os resultados são, no máximo, cerca de 2x mais optimistas do que na Render. A base é local (0,2 ms por consulta); no Neon de Frankfurt são ~2 ms.
