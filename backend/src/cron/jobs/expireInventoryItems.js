/**
 * CRON Job: expira itens temporários vencidos do inventário ("Meus Recursos"
 * — spec Seções 34-60).
 *
 * Não é estritamente necessário para a validade do item (a leitura via
 * `effective_inventory_status()` já trata como expirado qualquer linha
 * 'active' com expires_at vencido, mesmo antes deste job rodar — defesa em
 * profundidade), mas mantém o dado em repouso consistente com o que a
 * leitura mostra, e evita acumular lixo de estado "active-mas-vencido" que
 * um índice parcial (idx_user_inventory_expiry) espera não conter.
 *
 * Frequência recomendada: a cada poucos minutos (não precisa ser diário —
 * itens temporários podem expirar a qualquer hora do dia, diferente de
 * missões que resetam à meia-noite).
 * Uso manual: node src/cron/jobs/expireInventoryItems.js
 */
require('dotenv').config();
const logger = require('../../common/logger');
const db = require('../../config/database');
const { pool } = require('../../config/database');
const inventoryRepository = require('../../modules/shop/repositories/inventoryRepository');

async function run() {
  logger.info('CRON: expirando itens de inventário vencidos');
  const count = await inventoryRepository.expireOverdue(db);
  logger.info(`CRON: ${count} item(ns) de inventário marcado(s) como expirado(s)`);
}

run()
  .catch((err) => {
    logger.error('CRON: falha ao expirar itens de inventário', { error: err.message });
    process.exitCode = 1;
  })
  .finally(() => pool.end());
