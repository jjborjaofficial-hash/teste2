/**
 * CRON Job: recalcula o ranking semanal (Doc. Mestre Seção 9 | Manual Parte 3).
 * Frequência recomendada: a cada hora (o ranking não precisa ser em tempo real,
 * mas deve refletir a atividade recente com razoável frescor).
 *
 * Uso manual: node src/cron/jobs/recomputeWeeklyRanking.js
 * Uso agendado: configurar no agendador do ambiente de produção (ex: cron do Render,
 * ou um scheduler como node-cron/BullMQ quando o módulo de Filas for implementado).
 */
require('dotenv').config();
const logger = require('../../common/logger');
const rankingService = require('../../modules/ranking/services/rankingService');
const { pool } = require('../../config/database');

async function run() {
  logger.info('CRON: iniciando recálculo do ranking semanal');
  const result = await rankingService.recomputeCurrentWeek();
  logger.info('CRON: ranking semanal recalculado', result);
}

run()
  .catch((err) => {
    logger.error('CRON: falha ao recalcular ranking semanal', { error: err.message });
    process.exitCode = 1;
  })
  .finally(() => pool.end());
