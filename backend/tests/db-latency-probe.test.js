// Diagnóstico de latência do banco (11/10): a sonda e o estado do pool só leem e não alteram o comportamento das queries.
const { pool, query, probeLatency, poolStats } = require('../src/config/database');

describe('diagnóstico de latência do banco', () => {
  afterAll(async () => {
    await pool.end();
  });

  test('probeLatency mede a ligação e cada ida e volta, sem usar o pool', async () => {
    const antes = poolStats().poolTotal;
    const r = await probeLatency(3);
    expect(typeof r.connectMs).toBe('number');
    expect(r.queryMs).toHaveLength(3);
    r.queryMs.forEach((ms) => expect(ms).toBeGreaterThanOrEqual(0));
    expect(typeof r.medianMs).toBe('number');
    expect(poolStats().poolTotal).toBe(antes); // ligação própria: o pool não cresce
  });

  test('poolStats devolve o estado do pool e conta as ligações novas', async () => {
    const antes = poolStats().novasLigacoes;
    const res = await query('SELECT 1 AS ok');
    expect(res.rows[0].ok).toBe(1);
    const depois = poolStats();
    expect(depois).toEqual(
      expect.objectContaining({ poolTotal: expect.any(Number), poolIdle: expect.any(Number), poolWaiting: 0 })
    );
    expect(depois.novasLigacoes).toBeGreaterThanOrEqual(antes);
    expect(depois.novasLigacoes).toBeGreaterThanOrEqual(1);
  });
});
