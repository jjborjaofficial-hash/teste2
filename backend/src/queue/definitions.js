/**
 * Registro central dos jobs agendados (Manual Parte 3 — "CRON Jobs" e
 * "Filas"). Cada entrada aqui corresponde a um script que já existia em
 * `src/cron/jobs/` e que ANTES só rodava se alguém configurasse manualmente
 * um agendador externo (Render Cron Jobs, crontab do sistema, etc.) — a
 * lacuna que o Doc. Mestre Seção 20 registrava como "Scheduler automático
 * em produção: nenhum dos scripts de CRON roda sozinho".
 *
 * Agora, rodando `npm run worker` (um único processo Node), o próprio
 * BullMQ passa a agendar e executar todos eles internamente, com fila,
 * retries e backoff — sem precisar de nenhum agendador externo. Continua
 * sendo possível rodar qualquer job manualmente via linha de comando
 * (`node src/cron/jobs/x.js`), para depuração local, sem tocar na fila.
 *
 * As frequências abaixo foram extraídas literalmente do comentário
 * "Frequência recomendada" que já existia em cada arquivo de job — nenhum
 * valor novo foi inventado aqui, só centralizado.
 *
 * O fuso ('Africa/Maputo') garante que os horários batem com o horário real
 * de Moçambique, independente de onde o processo Node estiver hospedado.
 */
const TZ = 'Africa/Maputo';

const JOB_DEFINITIONS = [
  {
    name: 'assign-daily-missions',
    handlerPath: '../cron/jobs/assignDailyMissions',
    pattern: '0 0 * * *', // 00:00 diário
  },
  {
    name: 'assign-weekly-missions',
    handlerPath: '../cron/jobs/assignWeeklyMissions',
    pattern: '10 0 * * 0', // 00:10 todo domingo (10 min depois da atribuição diária)
  },
  {
    name: 'expire-missions',
    handlerPath: '../cron/jobs/expireMissions',
    pattern: '5 0 * * *', // logo após a atribuição diária, conforme o próprio job recomenda
  },
  {
    name: 'enforce-streak-expiry',
    handlerPath: '../cron/jobs/enforceStreakExpiry',
    pattern: '0 0 * * *', // 00:00 diário
  },
  {
    name: 'notify-streaks-at-risk',
    handlerPath: '../cron/jobs/notifyStreaksAtRisk',
    pattern: '0 20 * * *', // 20:00 diário (fim da tarde/noite)
  },
  {
    name: 'recompute-weekly-ranking',
    handlerPath: '../cron/jobs/recomputeWeeklyRanking',
    pattern: '0 * * * *', // a cada hora
  },
  {
    name: 'revalidate-withdrawals',
    handlerPath: '../cron/jobs/revalidateWithdrawals',
    pattern: '*/15 * * * *', // a cada 15 minutos
  },
  {
    name: 'expire-inventory-items',
    handlerPath: '../cron/jobs/expireInventoryItems',
    pattern: '*/5 * * * *', // a cada poucos minutos
  },
  {
    name: 'notify-inventory-expiring-soon',
    handlerPath: '../cron/jobs/notifyInventoryExpiringSoon',
    pattern: '*/5 * * * *', // mesma cadência de expireInventoryItems (lê a mesma janela de tempo)
  },
  {
    name: 'cleanup-expired-data',
    handlerPath: '../cron/jobs/cleanupExpiredData',
    pattern: '0 3 * * *', // 03:00 diário
  },
  {
    name: 'generate-daily-report',
    handlerPath: '../cron/jobs/generateDailyReport',
    pattern: '0 6 * * *', // 06:00 diário
  },
];

module.exports = { JOB_DEFINITIONS, TZ };
