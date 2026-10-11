/**
 * Consumidor da fila de push/SMS DENTRO do backend, para a fila não crescer sem fim no Redis quando não
 * existe o serviço "worker" (pago). Se um dia o worker existir, os dois podem coexistir: o BullMQ nunca
 * entrega o mesmo trabalho a dois consumidores.
 */
const { Worker } = require('bullmq');
const connection = require('./connection');
const logger = require('../common/logger');
const { QUEUE_NAME } = require('./deliveryQueue');
const { processDeliveryJob } = require('./deliveryHandler');

function startInProcessDelivery() {
  const worker = new Worker(QUEUE_NAME, (job) => processDeliveryJob(job, 'WEB'), { connection, concurrency: 2 });
  worker.on('failed', (job, err) => {
    logger.error(`WEB: entrega "${job?.name}" falhou`, { error: err.message, attempt: job?.attemptsMade });
  });
  worker.on('error', (err) => logger.error('WEB: erro no consumidor de entregas', { error: err.message }));
  return worker;
}

module.exports = { startInProcessDelivery };
