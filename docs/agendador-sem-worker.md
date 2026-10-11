# Agendador sem worker (tarefas automáticas grátis)

O projeto tem 11 tarefas automáticas (revalidar saques, ranking semanal, relatório diário, missões, streaks,
avisos...). Em `render.yaml` elas dependem de um serviço **worker**, que no Render é **pago** (cerca de US$ 7 por mês).
Este agendador faz o mesmo **sem worker e sem custo**, de dentro do próprio backend.

## Como funciona

1. **Executor** (`backend/src/cron/scheduler/runDueJobs.js`): a cada "tick" olha para a agenda das 11 tarefas
   (`backend/src/queue/definitions.js`, fuso de Maputo) e corre as que estão **atrasadas**. Guarda no Redis a última
   ocorrência executada (`cron:last:<tarefa>`). Se o servidor dormiu e perdeu várias ocorrências, corre **uma vez**
   (recuperação). Um cadeado no Redis impede dois ticks ao mesmo tempo. Cada ocorrência tenta no máximo 3 vezes.
2. **Tick por agendador externo** (principal): um serviço grátis chama `POST /internal/cron/tick` a cada 5 minutos.
   Isso também **acorda** o backend gratuito do Render, que adormece após 15 minutos sem visitas.
3. **Tick por acesso** (rede de segurança): se o agendador externo falhar, qualquer acesso real ao backend (no
   máximo 1 vez a cada 2 minutos) dispara as tarefas devidas em segundo plano. Só em produção.
4. **Fila de push/SMS**: os avisos eram colocados numa fila que só o worker esvaziava. O backend passa a esvaziá-la
   também (`backend/src/queue/inProcessDelivery.js`), para ela não crescer sem fim no Redis.

Tarefas de aviso só fazem sentido perto da hora marcada: o aviso das 20:00 é saltado se o tick só chegar depois das
23:00, e o aviso de itens a vencer se o atraso passar de 30 minutos. Estão em `MAX_LATENESS_MS` (`dueJobs.js`).

## Ligar (uma vez)

1. **Render, serviço `teste2-backend`, Environment:** criar `CRON_SECRET` com uma senha longa (24 ou mais caracteres).
   Sem esta variável as rotas internas ficam desligadas (404).
2. **Agendador externo grátis** (por exemplo `cron-job.org`, conta gratuita): criar um trabalho com
   - URL: `https://teste2-backend.onrender.com/internal/cron/tick`
   - Método: `POST`
   - Cabeçalho (header): `x-cron-secret` = o mesmo valor de `CRON_SECRET`
   - Agenda: a cada 5 minutos
   O servidor responde logo `202` e corre as tarefas em segundo plano. A primeira chamada, com o servidor a dormir,
   pode demorar até um minuto a responder; o agendador pode marcar uma falha nessa vez, mas o servidor acorda.
3. **Conferir:** um segundo trabalho `GET /internal/cron/status` com o mesmo cabeçalho; o histórico mostra, para cada
   tarefa, a última execução, a próxima e o último erro. `POST /internal/cron/tick?wait=1` espera e devolve o resultado.

## Se um dia o worker pago existir

Os dois não devem correr as tarefas ao mesmo tempo. Nesse dia: pôr `CRON_ON_ACCESS=false` no backend, apagar
`CRON_SECRET` e o trabalho do agendador externo. O consumidor da fila de push/SMS pode ficar: o BullMQ nunca entrega o
mesmo trabalho a dois consumidores.

## Limites a conhecer

- Execução **aproximada**: as tarefas de 5 e 15 minutos correm com a cadência do agendador (5 minutos), não ao
  segundo. Para este projeto basta: as tarefas leem estado e recuperam sozinhas o que ficou para trás.
- O plano grátis do Render dá 750 horas por mês; manter um único serviço web sempre acordado cabe (cerca de 744 h).
- A fila de push/SMS continua sem entregar nada enquanto o Firebase (push) e o Twilio (SMS) não estiverem configurados.
