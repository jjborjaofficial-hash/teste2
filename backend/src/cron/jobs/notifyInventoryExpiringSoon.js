/**
 * CRON Job: avisa o usuário quando um item ativo do inventário ("Meus
 * Recursos") está prestes a expirar (spec Seção 50).
 *
 * Janela de aviso: 15 minutos antes de `expires_at`. Cada item só gera UM
 * alerta (`expiry_alert_sent`), mesmo rodando este job a cada poucos
 * minutos — a spec é clara: o alerta é conveniência, não deve ser repetido,
 * e a contagem/expiração em si nunca depende do usuário ter visto o aviso.
 *
 * Frequência recomendada: a cada 5 minutos (mesma cadência de
 * expireInventoryItems.js, já que ambos leem a mesma tabela por expires_at).
 * Uso manual: node src/cron/jobs/notifyInventoryExpiringSoon.js
 */
require('dotenv').config();
const logger = require('../../common/logger');
const db = require('../../config/database');
const { pool } = require('../../config/database');
const inventoryRepository = require('../../modules/shop/repositories/inventoryRepository');
const notificationsService = require('../../modules/notifications/services/notificationsService');

const WARNING_WINDOW_MINUTES = 15;

async function run() {
  logger.info('CRON: verificando itens de inventário prestes a expirar');

  const expiringSoon = await inventoryRepository.findExpiringSoon(WARNING_WINDOW_MINUTES, db);

  for (const item of expiringSoon) {
    const minutesRemaining = Math.max(
      1,
      Math.round((new Date(item.expires_at).getTime() - Date.now()) / 60000)
    );
    await notificationsService.notifyItemExpiringSoon(db, item.user_id, {
      itemName: item.name,
      minutesRemaining,
    });
    await inventoryRepository.markExpiryAlertSent(item.id, db);
  }

  logger.info(`CRON: ${expiringSoon.length} alerta(s) de expiração enviado(s)`);
}

module.exports = run;

if (require.main === module) {
  run()
    .catch((err) => {
      logger.error('CRON: falha ao verificar itens prestes a expirar', { error: err.message });
      process.exitCode = 1;
    })
    .finally(() => pool.end());
}
