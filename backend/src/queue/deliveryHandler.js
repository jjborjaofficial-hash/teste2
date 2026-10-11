/**
 * Entrega de push/SMS (fila `aprenda-e-ganhe-delivery`). Extraído do worker para poder ser usado também
 * pelo consumidor DENTRO do backend (src/queue/inProcessDelivery.js), sem duplicar a lógica.
 */
const logger = require('../common/logger');
const pushService = require('../common/notifications/pushService');
const smsService = require('../common/notifications/smsService');
const pushTokensRepository = require('../modules/notifications/repositories/pushTokensRepository');

async function processDeliveryJob(job, label = 'WORKER') {
  if (job.name === 'push') {
    const { userId, payload } = job.data;
    const result = await pushService.sendToUser(userId, payload, pushTokensRepository);
    if (!result.skipped) logger.info(`${label}: push processado`, { userId, sent: result.sent });
  } else if (job.name === 'sms') {
    const { phone, message } = job.data;
    const result = await smsService.sendSms(phone, message);
    if (!result.skipped) logger.info(`${label}: sms processado`, { sent: result.sent });
  } else {
    throw new Error(`Job de entrega desconhecido: "${job.name}"`);
  }
}

module.exports = { processDeliveryJob };
