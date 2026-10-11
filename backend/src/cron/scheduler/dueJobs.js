/**
 * Decide, SEM worker e SEM relógio próprio, se uma tarefa agendada está "devida".
 *
 * Cada tarefa tem uma agenda (`pattern`, em src/queue/definitions.js). Em vez de depender de um processo
 * sempre ligado, guardamos no Redis a última ocorrência JÁ executada e, a cada "tick", comparamos com a
 * ocorrência mais recente que deveria ter corrido até agora. Se ficou para trás, corre UMA vez (recuperação),
 * mesmo que várias ocorrências se tenham perdido (ex.: o servidor gratuito estava a dormir).
 */
const parser = require('cron-parser');
const { TZ } = require('../../queue/definitions');

// Algumas tarefas só fazem sentido perto da hora marcada: um aviso das 20:00 enviado às 02:00 incomoda.
// Passado este atraso, a ocorrência é dada como "perdida" e saltada (a próxima corre normalmente).
const MAX_LATENESS_MS = {
  'notify-streaks-at-risk': 3 * 60 * 60 * 1000,
  'notify-inventory-expiring-soon': 30 * 60 * 1000,
};

/** Ocorrência mais recente da agenda que já deveria ter corrido (inclui o instante exato). */
function previousOccurrence(pattern, now = new Date(), tz = TZ) {
  return parser.parseExpression(pattern, { currentDate: new Date(now.getTime() + 1000), tz }).prev().toDate();
}

function nextOccurrence(pattern, now = new Date(), tz = TZ) {
  return parser.parseExpression(pattern, { currentDate: now, tz }).next().toDate();
}

/**
 * @param {{name: string, pattern: string}} job
 * @param {number|null} lastScheduledMs última ocorrência JÁ executada (instante agendado, não o real)
 * @returns {{state: 'not_due'|'due'|'too_late', scheduledMs: number, lateBy: number}}
 */
function evaluateJob(job, lastScheduledMs, now = new Date()) {
  const scheduledMs = previousOccurrence(job.pattern, now).getTime();
  const lateBy = now.getTime() - scheduledMs;
  const last = Number.isFinite(lastScheduledMs) ? lastScheduledMs : null;
  if (last !== null && last >= scheduledMs) return { state: 'not_due', scheduledMs, lateBy };
  const maxLate = MAX_LATENESS_MS[job.name];
  if (maxLate !== undefined && lateBy > maxLate) return { state: 'too_late', scheduledMs, lateBy };
  return { state: 'due', scheduledMs, lateBy };
}

module.exports = { evaluateJob, previousOccurrence, nextOccurrence, MAX_LATENESS_MS };
