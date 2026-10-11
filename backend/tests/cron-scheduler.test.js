/**
 * Agendador sem worker: (1) quando uma tarefa está "devida", com horas reais de Moçambique;
 * (2) o executor, com Redis de verdade e cada teste num prefixo próprio.
 */
const crypto = require('crypto');
const redis = require('../src/config/redis');
const { evaluateJob, previousOccurrence, nextOccurrence } = require('../src/cron/scheduler/dueJobs');
const { runDueJobs, getStatus, resolveHandler, MAX_ATTEMPTS } = require('../src/cron/scheduler/runDueJobs');
const { JOB_DEFINITIONS } = require('../src/queue/definitions');

afterAll(async () => {
  await redis.quit();
});

// Moçambique = UTC+2, sem horário de verão: 06:00 em Maputo = 04:00 UTC.
const at = (hhmm, day = '2026-10-11') => new Date(`${day}T${hhmm}:00+02:00`);

describe('quando uma tarefa está devida', () => {
  const daily6 = { name: 'generate-daily-report', pattern: '0 6 * * *' };

  test('a ocorrência anterior de "todo dia às 06:00" é calculada no fuso de Maputo', () => {
    expect(previousOccurrence(daily6.pattern, at('08:07')).toISOString()).toBe(at('06:00').toISOString());
    expect(previousOccurrence(daily6.pattern, at('05:59')).toISOString()).toBe(at('06:00', '2026-10-10').toISOString());
    expect(nextOccurrence(daily6.pattern, at('08:07')).toISOString()).toBe(at('06:00', '2026-10-12').toISOString());
  });

  test('nunca correu: está devida (recuperação)', () => {
    expect(evaluateJob(daily6, null, at('08:07')).state).toBe('due');
  });

  test('já correu a ocorrência de hoje: não está devida; a de ontem: está', () => {
    expect(evaluateJob(daily6, at('06:00').getTime(), at('23:00')).state).toBe('not_due');
    expect(evaluateJob(daily6, at('06:00', '2026-10-10').getTime(), at('08:07')).state).toBe('due');
  });

  test('várias ocorrências perdidas contam como UMA só (corre uma vez)', () => {
    const everyFive = { name: 'expire-inventory-items', pattern: '*/5 * * * *' };
    const ev = evaluateJob(everyFive, at('02:00').getTime(), at('09:03'));
    expect(ev.state).toBe('due');
    expect(ev.scheduledMs).toBe(at('09:00').getTime());
  });

  test('aviso das 20:00 enviado com muito atraso é saltado; com pouco atraso corre', () => {
    const streak = { name: 'notify-streaks-at-risk', pattern: '0 20 * * *' };
    expect(evaluateJob(streak, at('20:00', '2026-10-10').getTime(), at('21:30')).state).toBe('due');
    expect(evaluateJob(streak, at('20:00', '2026-10-10').getTime(), at('23:30')).state).toBe('too_late');
  });
});

describe('executor', () => {
  let prefix;
  beforeEach(() => {
    prefix = `test:${crypto.randomUUID()}:`;
  });

  const job = (name, pattern, fn) => ({ def: { name, pattern, handlerPath: name }, fn });
  const run = (list, extra = {}) =>
    runDueJobs({
      jobs: list.map((j) => j.def),
      getHandler: (d) => list.find((j) => j.def.name === d.name).fn,
      prefix,
      ...extra,
    });

  test('corre a tarefa devida uma vez e, no mesmo minuto, não repete', async () => {
    const fn = jest.fn().mockResolvedValue();
    const list = [job('a', '* * * * *', fn)];
    const now = at('10:00');
    const r1 = await run(list, { now });
    expect(r1.results[0].state).toBe('ran');
    const r2 = await run(list, { now });
    expect(r2.results[0].state).toBe('not_due');
    expect(fn).toHaveBeenCalledTimes(1);
  });

  test('um tick novo, no minuto seguinte, volta a correr uma tarefa de "todo minuto"', async () => {
    const fn = jest.fn().mockResolvedValue();
    const list = [job('a', '* * * * *', fn)];
    await run(list, { now: at('10:00') });
    await run(list, { now: at('10:01') });
    expect(fn).toHaveBeenCalledTimes(2);
  });

  test('falha: tenta de novo nos ticks seguintes e desiste ao fim de MAX_ATTEMPTS, sem travar as outras', async () => {
    const bad = jest.fn().mockRejectedValue(new Error('boom'));
    const good = jest.fn().mockResolvedValue();
    const list = [job('bad', '0 6 * * *', bad), job('good', '0 6 * * *', good)];
    const now = at('08:00');
    const states = [];
    for (let i = 0; i < MAX_ATTEMPTS + 1; i += 1) {
      const r = await run(list, { now });
      states.push(r.results.find((x) => x.name === 'bad').state);
    }
    expect(states).toEqual(['failed', 'failed', 'gave_up', 'not_due']);
    expect(bad).toHaveBeenCalledTimes(MAX_ATTEMPTS);
    expect(good).toHaveBeenCalledTimes(1); // a boa correu uma vez e não foi afetada
    const status = await getStatus({ jobs: list.map((j) => j.def), prefix, now });
    expect(status.jobs.find((j) => j.name === 'bad').lastError.message).toBe('boom');
  });

  test('dois ticks ao mesmo tempo: só um corre as tarefas (cadeado)', async () => {
    let release;
    const gate = new Promise((resolve) => {
      release = resolve;
    });
    const slow = jest.fn(() => gate);
    const list = [job('slow', '0 6 * * *', slow)];
    const now = at('08:00');
    const first = run(list, { now });
    await new Promise((r) => setTimeout(r, 100));
    const second = await run(list, { now });
    expect(second.skipped).toBe('lock');
    release();
    await first;
    expect(slow).toHaveBeenCalledTimes(1);
  });

  test('aviso muito atrasado é saltado e marcado como feito', async () => {
    const fn = jest.fn().mockResolvedValue();
    const list = [job('notify-streaks-at-risk', '0 20 * * *', fn)];
    const r = await run(list, { now: at('23:50') });
    expect(r.results[0].state).toBe('skipped_late');
    expect(fn).not.toHaveBeenCalled();
    const again = await run(list, { now: at('23:55') });
    expect(again.results[0].state).toBe('not_due');
  });

  test('todas as 11 tarefas reais têm agenda válida e um handler que exporta uma função', () => {
    expect(JOB_DEFINITIONS).toHaveLength(11);
    for (const def of JOB_DEFINITIONS) {
      expect(() => nextOccurrence(def.pattern, at('10:00'))).not.toThrow();
      expect(typeof resolveHandler(def)).toBe('function'); // o MESMO caminho que o executor usa em produção
    }
  });
});
