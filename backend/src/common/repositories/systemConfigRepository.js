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

// Cache curto SÓ para chaves do caminho quente do quiz (lidas a cada resposta: pontos por dificuldade, teto diário de
// pontos e passo de nível). Cada leitura custa uma ida e volta ao banco (~0,13 s Render Oregon -> Neon Londres).
// O código nunca escreve em system_config (as regras mudam-se no banco), por isso um valor alterado passa a valer em
// até CONFIG_CACHE_TTL_MS (60 s por omissão). NÃO usar para chaves de dinheiro (carteira, saque, conversão): essas
// continuam a ler sempre do banco. Nos testes (NODE_ENV=test) o cache fica desligado, salvo se o teste pedir.
const cache = new Map();

function defaultTtlMs() {
  if (process.env.CONFIG_CACHE_TTL_MS !== undefined) return Number(process.env.CONFIG_CACHE_TTL_MS);
  return process.env.NODE_ENV === 'test' ? 0 : 60000;
}

async function getConfigValueCached(key, executor = db, ttlMs = defaultTtlMs()) {
  const now = Date.now();
  const hit = cache.get(key);
  if (ttlMs > 0 && hit && hit.expiresAt > now) return hit.value;
  const value = await getConfigValue(key, executor);
  if (ttlMs > 0) cache.set(key, { value, expiresAt: now + ttlMs });
  return value;
}

function clearConfigCache() {
  cache.clear();
}

module.exports = { getConfigValue, getConfigValues, getConfigValueCached, clearConfigCache };
