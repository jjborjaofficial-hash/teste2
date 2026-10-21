/**
 * Executor das tarefas agendadas DENTRO do backend (alternativa gratuita ao serviço "worker" do Render,
 * que é pago). Cada chamada ("tick") corre as tarefas devidas, uma de cada vez, e guarda o resultado no Redis.
 *
 *  - Cadeado global no Redis: dois ticks ao mesmo tempo (agendador externo + acesso de utilizador) nunca
 *    correm a mesma tarefa em paralelo.
 *  - Cada ocorrência corre no máximo MAX_ATTEMPTS vezes; depois é dada como feita para não ficar em loop.
 *  - Os handlers são os `run()` que já existiam em src/cron/jobs/*.js: nenhuma regra de negócio foi duplicada.
 */
const path = require('path');
const crypto = require('crypto');
const redis = require('../../config/redis');
const logger = require('../../common/logger');
const { JOB_DEFINITIONS, TZ } = require('../../queue/definitions');
const { evaluateJob, nextOccurrence } = require('./dueJobs');

const LOCK_MS = 10 * 60 * 1000;
const MAX_ATTEMPTS = 3;
const KEEP_SECONDS = 7 * 24 * 3600;

function resolveHandler(job) {
  // eslint-disable-next-line global-require
  return require(path.resolve(__dirname, '../../queue', job.handlerPath));
}

async function runDueJobs({
  now = new Date(),
  jobs = JOB_DEFINITIONS,
  // `handlerPath` em definitions.js é relativo a src/queue (onde o worker o carrega), não a esta pasta.
  getHandler = resolveHandler,
  client = redis,
  prefix = 'cron:',
} = {}) {
  const lockKey = `${prefix}tick:lock`;
  const token = crypto.randomUUID();
  const locked = await client.set(lockKey, token, 'PX', LOCK_MS, 'NX');
  if (!locked) return { skipped: 'lock', results: [] };

  const results = [];
  try {
    for (const job of jobs) {
      const lastKey = `${prefix}last:${job.name}`;
      const errKey = `${prefix}err:${job.name}`;
      const lastRaw = await client.get(lastKey);
      const ev = evaluateJob(job, lastRaw === null ? null : Number(lastRaw), now);

      if (ev.state === 'not_due') {
        results.push({ name: job.name, state: 'not_due' });
        continue;
      }
      if (ev.state === 'too_late') {
        await client.set(lastKey, ev.scheduledMs);
        logger.warn(`CRON-TICK: "${job.name}" saltada (atraso de ${Math.round(ev.lateBy / 60000)} min, fora do limite)`);
        results.push({ name: job.name, state: 'skipped_late' });
        continue;
      }

      const attemptsKey = `${prefix}attempts:${job.name}:${ev.scheduledMs}`;
      const attempts = await client.incr(attemptsKey);
      await client.expire(attemptsKey, 2 * 24 * 3600);
      const started = Date.now();
      try {
        logger.info(`CRON-TICK: a correr "${job.name}" (agendada para ${new Date(ev.scheduledMs).toISOString()})`);
        await getHandler(job)();
        await client.set(lastKey, ev.scheduledMs);
        await client.del(errKey);
        results.push({ name: job.name, state: 'ran', ms: Date.now() - started });
      } catch (err) {
        logger.error(`CRON-TICK: "${job.name}" falhou (tentativa ${attempts}/${MAX_ATTEMPTS})`, { error: err.message });
        await client.set(
          errKey,
          JSON.stringify({ at: new Date().toISOString(), scheduledMs: ev.scheduledMs, attempts, message: err.message }),
          'EX',
          KEEP_SECONDS
        );
        if (attempts >= MAX_ATTEMPTS) {
          await client.set(lastKey, ev.scheduledMs); // desiste desta ocorrência; a próxima corre normalmente
          results.push({ name: job.name, state: 'gave_up' });
        } else {
          results.push({ name: job.name, state: 'failed' });
        }
      }
    }
  } finally {
    if ((await client.get(lockKey)) === token) await client.del(lockKey);
  }
  return { skipped: null, results };
}

/** Estado legível das tarefas (para conferir, sem abrir o servidor, que estão a correr). */
async function getStatus({ now = new Date(), jobs = JOB_DEFINITIONS, client = redis, prefix = 'cron:' } = {}) {
  const out = [];
  for (const job of jobs) {
    const lastRaw = await client.get(`${prefix}last:${job.name}`);
    const errRaw = await client.get(`${prefix}err:${job.name}`);
    const ev = evaluateJob(job, lastRaw === null ? null : Number(lastRaw), now);
    out.push({
      name: job.name,
      pattern: job.pattern,
      lastRunScheduledAt: lastRaw === null ? null : new Date(Number(lastRaw)).toISOString(),
      state: ev.state,
      nextRunAt: nextOccurrence(job.pattern, now).toISOString(),
      lastError: errRaw ? JSON.parse(errRaw) : null,
    });
  }
  return { timezone: TZ, now: now.toISOString(), jobs: out };
}

module.exports = { runDueJobs, getStatus, resolveHandler, MAX_ATTEMPTS };
