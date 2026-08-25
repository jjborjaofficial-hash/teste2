/**
 * Runner de migrations (Manual Parte 4: Migrações e Versionamento).
 * Toda alteração de schema ocorre via arquivo .sql versionado em /database/migrations,
 * nunca diretamente em produção.
 *
 * Uso:
 *   node src/database/migrate.js up     -> aplica migrations pendentes, em ordem
 *   node src/database/migrate.js status -> lista o que já foi aplicado
 */
require('dotenv').config();
const fs = require('fs');
const path = require('path');
const { Pool } = require('pg');

const MIGRATIONS_DIR = path.join(__dirname, '..', '..', 'database', 'migrations');

async function ensureMigrationsTable(pool) {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS schema_migrations (
      id SERIAL PRIMARY KEY,
      filename VARCHAR(255) NOT NULL UNIQUE,
      applied_at TIMESTAMPTZ NOT NULL DEFAULT now()
    );
  `);
}

async function getAppliedMigrations(pool) {
  const { rows } = await pool.query('SELECT filename FROM schema_migrations ORDER BY id;');
  return new Set(rows.map((r) => r.filename));
}

async function up() {
  const pool = new Pool({ connectionString: process.env.DATABASE_URL });
  try {
    await ensureMigrationsTable(pool);
    const applied = await getAppliedMigrations(pool);

    const files = fs
      .readdirSync(MIGRATIONS_DIR)
      .filter((f) => f.endsWith('.sql'))
      .sort();

    let appliedCount = 0;
    for (const file of files) {
      if (applied.has(file)) continue;

      const sql = fs.readFileSync(path.join(MIGRATIONS_DIR, file), 'utf-8');
      const client = await pool.connect();
      try {
        await client.query('BEGIN');
        await client.query(sql);
        await client.query('INSERT INTO schema_migrations (filename) VALUES ($1);', [file]);
        await client.query('COMMIT');
        console.log(`✓ Migration aplicada: ${file}`);
        appliedCount += 1;
      } catch (err) {
        await client.query('ROLLBACK');
        console.error(`✗ Falha na migration ${file}:`, err.message);
        throw err;
      } finally {
        client.release();
      }
    }

    if (appliedCount === 0) {
      console.log('Nenhuma migration pendente. Banco já está atualizado.');
    }
  } finally {
    await pool.end();
  }
}

async function status() {
  const pool = new Pool({ connectionString: process.env.DATABASE_URL });
  try {
    await ensureMigrationsTable(pool);
    const applied = await getAppliedMigrations(pool);
    const files = fs.readdirSync(MIGRATIONS_DIR).filter((f) => f.endsWith('.sql')).sort();

    files.forEach((f) => {
      console.log(`${applied.has(f) ? '✓ aplicada  ' : '  pendente '} ${f}`);
    });
  } finally {
    await pool.end();
  }
}

const command = process.argv[2];

if (command === 'up') {
  up().catch((err) => {
    console.error('Erro ao rodar migrations:', err);
    process.exit(1);
  });
} else if (command === 'status') {
  status().catch((err) => {
    console.error('Erro ao consultar status:', err);
    process.exit(1);
  });
} else if (command === 'down') {
  console.log(
    'Rollback automático não é suportado por design: migrations destrutivas exigem ' +
    'revisão manual (Manual Parte 4). Restaure a partir de backup se necessário.'
  );
} else {
  console.log('Uso: node migrate.js [up|status|down]');
}
