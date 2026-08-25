/**
 * CRON Job: relatórios administrativos diários (docx "REDIS CACHE E CRON
 * JOBS", Cron Job 5). Gera o relatório referente ao dia ANTERIOR (o dia atual
 * ainda não terminou às 06:00, então os números seriam parciais e enganosos).
 *
 * ⚠️ Adaptação: "Receita de publicidade" fica como null neste relatório
 * enquanto não existir integração real com AdSense/AdCash (ver README) — o
 * job não inventa um número para preencher essa coluna.
 *
 * Frequência recomendada: todos os dias às 06:00 (GMT+2).
 * Uso manual: node src/cron/jobs/generateDailyReport.js
 */
require('dotenv').config();
const logger = require('../../common/logger');
const reportsService = require('../../modules/reports/services/reportsService');
const { pool } = require('../../config/database');
const { todayInPlatformTz } = require('../../common/time/platformTimezone');

// CORREÇÃO: calculava "ontem" a partir de UTC puro — deriva agora sempre do
// calendário oficial da plataforma (Moçambique) em vez do fuso do servidor.
function yesterdayDateOnly() {
  const todayStr = todayInPlatformTz();
  const [y, m, d] = todayStr.split('-').map(Number);
  const yesterday = new Date(Date.UTC(y, m - 1, d - 1));
  return yesterday.toISOString().slice(0, 10);
}

async function run() {
  const reportDate = yesterdayDateOnly();
  logger.info('CRON: gerando relatório administrativo diário', { reportDate });

  const report = await reportsService.generateReportForDate(reportDate);

  logger.info('CRON: relatório administrativo gerado', report);
}

run()
  .catch((err) => {
    logger.error('CRON: falha ao gerar relatório administrativo', { error: err.message });
    process.exitCode = 1;
  })
  .finally(() => pool.end());
