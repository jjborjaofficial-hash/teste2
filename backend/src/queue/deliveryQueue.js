const { Queue } = require('bullmq');
const connection = require('./connection');

/**
 * Fila separada da `cronQueue` (que é só para jobs REPETÍVEIS agendados).
 * Esta é para jobs AVULSOS, disparados no exato momento em que algo precisa
 * ser entregue (ex: uma notificação acabou de ser criada) — mesmo motivo já
 * documentado em connection.js: nunca bloquear a experiência do usuário
 * esperando uma chamada de rede para um provedor externo (FCM/Twilio)
 * terminar (Manual Parte 3).
 */

const QUEUE_NAME = 'aprenda-e-ganhe-delivery';

const deliveryQueue = new Queue(QUEUE_NAME, { connection });

const DEFAULT_JOB_OPTIONS = {
  attempts: 3,
  backoff: { type: 'exponential', delay: 10_000 }, // 10s, 20s, 40s
  removeOnComplete: { count: 200 },
  removeOnFail: { count: 500 },
};

async function enqueuePush(userId, payload) {
  // Nunca deixa uma falha ao ENFILEIRAR (ex: Redis fora do ar) derrubar quem
  // está criando a notificação — a notificação em si já está salva no banco,
  // o push é só um canal extra, best-effort.
  try {
    await deliveryQueue.add('push', { userId, payload }, DEFAULT_JOB_OPTIONS);
  } catch (err) {
    // eslint-disable-next-line global-require
    require('../common/logger').warn('deliveryQueue: falha ao enfileirar push', { error: err.message });
  }
}

async function enqueueSms(phone, message) {
  try {
    await deliveryQueue.add('sms', { phone, message }, DEFAULT_JOB_OPTIONS);
  } catch (err) {
    // eslint-disable-next-line global-require
    require('../common/logger').warn('deliveryQueue: falha ao enfileirar SMS', { error: err.message });
  }
}

module.exports = { deliveryQueue, QUEUE_NAME, enqueuePush, enqueueSms };
