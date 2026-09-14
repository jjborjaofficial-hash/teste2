require('dotenv').config();
const { Worker } = require('bullmq');
const connection = require('./connection');
const { cronQueue, scheduleAllJobs, QUEUE_NAME } = require('./cronQueue');
const { QUEUE_NAME: DELIVERY_QUEUE_NAME } = require('./deliveryQueue');
const { JOB_DEFINITIONS } = require('./definitions');
const { pool, verifyConnection } = require('../config/database');
const logger = require('../common/logger');
const pushService = require('../common/notifications/pushService');
const smsService = require('../common/notifications/smsService');
const pushTokensRepository = require('../modules/notifications/repositories/pushTokensRepository');

/**
 * Processo separado do servidor web (`npm run worker`, em produção: um
 * segundo serviço no Render/provedor, ao lado do serviço web). Isso segue
 * o mesmo princípio já usado no resto do projeto (ex.: rate limiter com
 * Redis) de não bloquear a experiência do usuário com tarefas pesadas
 * (Manual Parte 3: "Nenhuma tarefa pesada deverá bloquear a experiência
 * do usuário").
 *
 * Cada handler é o `run()` já existente em `src/cron/jobs/*.js` — nenhuma
 * lógica de negócio foi duplicada aqui, só orquestração de fila.
 */
const handlersByName = new Map(
  JOB_DEFINITIONS.map((job) => [job.name, require(job.handlerPath)])
);

async function main() {
  const dbOk = await verifyConnection();
  if (!dbOk) {
    logger.error('WORKER: não foi possível conectar ao banco de dados. Encerrando.');
    process.exit(1);
  }

  await scheduleAllJobs();
  logger.info(`WORKER: ${JOB_DEFINITIONS.length} job(s) agendado(s) na fila "${QUEUE_NAME}"`);
  logger.info(`WORKER: escutando fila de entrega "${DELIVERY_QUEUE_NAME}" (push/SMS)`);

  const worker = new Worker(
    QUEUE_NAME,
    async (job) => {
      const handler = handlersByName.get(job.name);
      if (!handler) {
        throw new Error(`Nenhum handler registrado para o job "${job.name}"`);
      }
      logger.info(`WORKER: iniciando job "${job.name}"`);
      await handler();
      logger.info(`WORKER: job "${job.name}" concluído`);
    },
    {
      connection,
      concurrency: 3, // até 3 jobs em paralelo — os jobs são independentes entre si
    }
  );

  worker.on('failed', (job, err) => {
    logger.error(`WORKER: job "${job?.name}" falhou`, { error: err.message, attempt: job?.attemptsMade });
  });

  // Segunda fila, mesmo processo: entrega de push/SMS (avulsa, não repetível
  // — ver src/queue/deliveryQueue.js). Compartilha a mesma conexão Redis e o
  // mesmo `npm run worker`, sem exigir um terceiro serviço no provedor.
  const deliveryWorker = new Worker(
    DELIVERY_QUEUE_NAME,
    async (job) => {
      if (job.name === 'push') {
        const { userId, payload } = job.data;
        const result = await pushService.sendToUser(userId, payload, pushTokensRepository);
        if (!result.skipped) {
          logger.info('WORKER: push processado', { userId, sent: result.sent });
        }
      } else if (job.name === 'sms') {
        const { phone, message } = job.data;
        const result = await smsService.sendSms(phone, message);
        if (!result.skipped) {
          logger.info('WORKER: sms processado', { sent: result.sent });
        }
      } else {
        throw new Error(`Job de entrega desconhecido: "${job.name}"`);
      }
    },
    { connection, concurrency: 5 }
  );

  deliveryWorker.on('failed', (job, err) => {
    logger.error(`WORKER: entrega "${job?.name}" falhou`, { error: err.message, attempt: job?.attemptsMade });
  });

  const shutdown = async (signal) => {
    logger.info(`WORKER: recebido ${signal}, encerrando com segurança...`);
    await worker.close();
    await deliveryWorker.close();
    await cronQueue.close();
    await connection.quit();
    await pool.end();
    process.exit(0);
  };
  process.on('SIGTERM', () => shutdown('SIGTERM'));
  process.on('SIGINT', () => shutdown('SIGINT'));
}

main().catch((err) => {
  logger.error('WORKER: falha fatal ao iniciar', { error: err.message });
  process.exit(1);
});
