const db = require('../../config/database');

/**
 * Acesso à tabela system_config, compartilhado entre módulos (Manual Parte 4).
 * Permite ajustar regras de negócio (teto de saque, marcos de streak, etc.)
 * sem necessidade de deploy de código.
 */

async function getConfigValue(key, executor = db) {
  const { rows } = await executor.query(
    'SELECT value FROM system_config WHERE key = $1',
    [key]
  );
  if (!rows[0]) return null;
  return rows[0].value;
}

async function getConfigValues(keys, executor = db) {
  const { rows } = await executor.query(
    'SELECT key, value FROM system_config WHERE key = ANY($1::varchar[])',
    [keys]
  );
  const map = {};
  rows.forEach((r) => {
    map[r.key] = r.value;
  });
  return map;
}

module.exports = { getConfigValue, getConfigValues };
