const { Queue } = require('bullmq');
const connection = require('./connection');
const { JOB_DEFINITIONS, TZ } = require('./definitions');

const QUEUE_NAME = 'aprenda-e-ganhe-cron';

const cronQueue = new Queue(QUEUE_NAME, { connection });

/**
 * Registra todos os jobs como "repeatable" no BullMQ. Idempotente: o BullMQ
 * identifica um repeatable job pelo par (nome, padrão de cron) e não duplica
 * o agendamento se ele já existir — então isso pode (e deve) rodar toda vez
 * que o worker sobe, sem se preocupar em checar antes se já existia.
 */
async function scheduleAllJobs() {
  for (const job of JOB_DEFINITIONS) {
    await cronQueue.add(
      job.name,
      {},
      {
        repeat: { pattern: job.pattern, tz: TZ },
        removeOnComplete: { count: 50 },
        removeOnFail: { count: 100 },
        attempts: 3,
        backoff: { type: 'exponential', delay: 30_000 }, // 30s, 60s, 120s
      }
    );
  }
}

module.exports = { cronQueue, scheduleAllJobs, QUEUE_NAME };
