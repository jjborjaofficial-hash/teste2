/** Gatilho por acesso: só em produção, e no máximo uma vez por janela. */
jest.mock('../src/config/redis', () => ({ set: jest.fn() }));
jest.mock('../src/cron/scheduler/runDueJobs', () => ({ runDueJobs: jest.fn().mockResolvedValue({}) }));

const flush = () => new Promise((r) => setImmediate(r));

function load(env) {
  jest.resetModules();
  Object.assign(process.env, env);
  // eslint-disable-next-line global-require
  return { mod: require('../src/cron/scheduler/tickOnAccess'), redis: require('../src/config/redis'), runner: require('../src/cron/scheduler/runDueJobs') };
}

const OLD = { ...process.env };
afterEach(() => {
  process.env = { ...OLD };
});

test('fora de produção não faz nada', async () => {
  const { mod, redis } = load({ NODE_ENV: 'test' });
  const next = jest.fn();
  mod.tickOnAccess({}, {}, next);
  await flush();
  expect(next).toHaveBeenCalled();
  expect(redis.set).not.toHaveBeenCalled();
});

test('em produção, o primeiro acesso dispara as tarefas; o seguinte, logo a seguir, não', async () => {
  const { mod, redis, runner } = load({ NODE_ENV: 'production', CRON_ON_ACCESS: '' });
  redis.set.mockResolvedValue('OK');
  mod.tickOnAccess({}, {}, jest.fn());
  mod.tickOnAccess({}, {}, jest.fn());
  await flush();
  expect(redis.set).toHaveBeenCalledTimes(1);
  expect(runner.runDueJobs).toHaveBeenCalledTimes(1);
});

test('se outro processo já pegou a janela (Redis devolve null), não corre', async () => {
  const { mod, redis, runner } = load({ NODE_ENV: 'production', CRON_ON_ACCESS: '' });
  redis.set.mockResolvedValue(null);
  mod.tickOnAccess({}, {}, jest.fn());
  await flush();
  expect(runner.runDueJobs).not.toHaveBeenCalled();
});

test('CRON_ON_ACCESS=false desliga mesmo em produção', async () => {
  const { mod, redis } = load({ NODE_ENV: 'production', CRON_ON_ACCESS: 'false' });
  mod.tickOnAccess({}, {}, jest.fn());
  await flush();
  expect(redis.set).not.toHaveBeenCalled();
});
