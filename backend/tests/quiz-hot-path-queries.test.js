// Caminho quente do quiz (11/10): menos idas ao banco por resposta. Cada ida custa ~0,13 s entre o Render (Oregon) e o
// Neon (Londres). Este teste garante que a otimização NÃO muda os resultados e que o número de queries não volta a subir.
process.env.CONFIG_CACHE_TTL_MS = '60000'; // liga o cache (nos testes fica desligado por omissão)
const pg = require('pg');
const db = require('../src/config/database');
const configRepository = require('../src/common/repositories/systemConfigRepository');
const quizRepository = require('../src/modules/quiz/repositories/quizRepository');
const quizService = require('../src/modules/quiz/services/quizService');

let counting = false;
let queryTexts = [];
const originalQuery = pg.Client.prototype.query;
pg.Client.prototype.query = function patched(...args) {
  if (counting) queryTexts.push((typeof args[0] === 'string' ? args[0] : args[0].text).replace(/\s+/g, ' ').trim());
  return originalQuery.apply(this, args);
};

let userId;
let categoryId;

beforeAll(async () => {
  const phone = `84${Math.floor(1000000 + Math.random() * 8999999)}`;
  const { rows } = await db.query(
    `INSERT INTO users (name, phone, password_hash, phone_provider, status) VALUES ('Teste Caminho Quente', $1, 'x', 'mpesa', 'active') RETURNING id`,
    [phone]
  );
  userId = rows[0].id;
  await db.query('INSERT INTO streaks (user_id) VALUES ($1) ON CONFLICT DO NOTHING', [userId]);
  categoryId = (await db.query('SELECT id FROM categories WHERE is_active ORDER BY name LIMIT 1')).rows[0].id;
});

afterAll(async () => {
  pg.Client.prototype.query = originalQuery;
  await db.query('DELETE FROM quiz_attempts WHERE user_id = $1', [userId]);
  await db.query('DELETE FROM quiz_rounds WHERE user_id = $1', [userId]);
  await db.pool.end();
});

describe('cache de configuração do caminho quente', () => {
  beforeEach(() => configRepository.clearConfigCache());

  it('só vai ao banco uma vez dentro do tempo, e outra vez depois de expirar', async () => {
    const executor = { query: jest.fn().mockResolvedValue({ rows: [{ value: '42' }] }) };
    expect(await configRepository.getConfigValueCached('chave_x', executor, 20)).toBe('42');
    expect(await configRepository.getConfigValueCached('chave_x', executor, 20)).toBe('42');
    expect(executor.query).toHaveBeenCalledTimes(1); // segunda leitura veio da memória
    await new Promise((r) => setTimeout(r, 40)); // passa o tempo de vida
    await configRepository.getConfigValueCached('chave_x', executor, 20);
    expect(executor.query).toHaveBeenCalledTimes(2);
  });

  it('com ttl 0 nunca guarda (comportamento igual ao anterior)', async () => {
    const executor = { query: jest.fn().mockResolvedValue({ rows: [{ value: '1' }] }) };
    await configRepository.getConfigValueCached('chave_y', executor, 0);
    await configRepository.getConfigValueCached('chave_y', executor, 0);
    expect(executor.query).toHaveBeenCalledTimes(2);
  });

  it('chave inexistente devolve null (e usa o valor por omissão de quem chama)', async () => {
    const executor = { query: jest.fn().mockResolvedValue({ rows: [] }) };
    expect(await configRepository.getConfigValueCached('nao_existe', executor, 1000)).toBeNull();
  });

  it('as chaves de dinheiro da carteira continuam a ler sempre do banco', () => {
    const fs = require('fs');
    const wallet = fs.readFileSync(require.resolve('../src/modules/wallet/services/walletService.js'), 'utf8');
    expect(wallet).not.toMatch(/getConfigValueCached/);
  });
});

describe('pergunta + alternativas numa só query', () => {
  it('devolve os mesmos campos e as mesmas alternativas que as duas queries antigas', async () => {
    const { rows: qs } = await db.query('SELECT id FROM questions WHERE is_active = TRUE ORDER BY id LIMIT 5');
    for (const { id } of qs) {
      const novo = await quizRepository.getQuestionWithCorrectAlternative(id);
      const q = (await db.query('SELECT id, category_id, time_limit_seconds, xp_reward, difficulty, explanation FROM questions WHERE id = $1', [id])).rows[0];
      const alts = (await db.query('SELECT id, label, is_correct FROM question_alternatives WHERE question_id = $1', [id])).rows;
      const { alternatives, ...campos } = novo;
      expect(campos).toEqual(q);
      const norm = (l) => [...l].sort((a, b) => a.id.localeCompare(b.id));
      expect(norm(alternatives)).toEqual(norm(alts));
      expect(alternatives).toHaveLength(4);
    }
  });

  it('pergunta inativa ou inexistente devolve null', async () => {
    expect(await quizRepository.getQuestionWithCorrectAlternative('00000000-0000-0000-0000-000000000000')).toBeNull();
  });
});

describe('queries eliminadas do caminho da resposta certa', () => {
  async function answerAndCollect() {
    const round = await quizService.startRound({ userId, categoryId });
    const q = await quizService.getRoundQuestion({ userId, roundId: round.id });
    const alt = (await db.query('SELECT id FROM question_alternatives WHERE question_id = $1 AND is_correct = TRUE LIMIT 1', [q.id])).rows[0].id;
    queryTexts = [];
    counting = true;
    await quizService.submitAnswer({ userId, questionId: q.id, alternativeId: alt, roundId: round.id });
    counting = false;
    return queryTexts;
  }

  it('com a configuração em cache, a resposta certa já não lê system_config', async () => {
    configRepository.clearConfigCache();
    const fria = await answerAndCollect(); // aquece o cache
    const quente = await answerAndCollect();
    expect(fria.filter((t) => t.includes('FROM system_config')).length).toBeGreaterThan(0);
    expect(quente.filter((t) => t.includes('FROM system_config'))).toEqual([]);
  });

  it('a pergunta e as alternativas vêm numa só query (já não há a query separada de alternativas)', async () => {
    const textos = await answerAndCollect();
    expect(textos.filter((t) => /^SELECT id, label, is_correct FROM question_alternatives/.test(t))).toEqual([]);
    expect(textos.filter((t) => t.includes('FROM questions q') && t.includes('question_alternatives a')).length).toBe(1);
  });
});
