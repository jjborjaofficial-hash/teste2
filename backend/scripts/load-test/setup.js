// Cria N utilizadores de teste direto na base de testes LOCAL (nunca produção).
const { Client } = require('pg');
const bcrypt = require('bcrypt');
(async () => {
  const N = Number(process.argv[2] || 150);
  const c = new Client({ connectionString: 'postgres://postgres:postgres@localhost:5432/teste' });
  await c.connect();
  const hash = await bcrypt.hash('Teste12345', 12);
  const phones = [];
  for (let i = 0; i < N; i++) {
    const phone = `84${String(9100000 + i)}`;
    const ex = await c.query('SELECT id FROM users WHERE phone = $1 AND deleted_at IS NULL', [phone]);
    let r;
    if (ex.rows.length) {
      r = await c.query(`UPDATE users SET password_hash = $2, status = 'active' WHERE id = $1 RETURNING id`, [ex.rows[0].id, hash]);
    } else {
      r = await c.query(
        `INSERT INTO users (name, phone, password_hash, phone_provider, status, terms_accepted_at, is_adult_declared)
         VALUES ($1, $2, $3, 'mpesa', 'active', now(), true) RETURNING id`,
        [`LOAD ${i}`, phone, hash]
      );
    }
    await c.query('INSERT INTO streaks (user_id) VALUES ($1) ON CONFLICT DO NOTHING', [r.rows[0].id]);
    phones.push(phone);
  }
  require('fs').writeFileSync('phones.json', JSON.stringify(phones));
  console.log('utilizadores:', phones.length);
  await c.end();
})();
