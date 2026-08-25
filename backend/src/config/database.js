const { Pool } = require('pg');
const logger = require('../common/logger');

// Segurança de Credenciais (docs/seguranca-credenciais-banco-de-dados.md, Seção 2):
// a connectionString NUNCA é um valor fixo no código — vem de variável de
// ambiente. Falhar cedo e alto se estiver ausente, em vez de deixar o pool
// tentar se conectar a "undefined" silenciosamente.
if (!process.env.DATABASE_URL) {
  throw new Error(
    'DATABASE_URL não definida. Configure a variável de ambiente antes de iniciar o servidor ' +
      '(ver .env.example e docs/seguranca-credenciais-banco-de-dados.md).'
  );
}

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.DATABASE_SSL === 'true' ? { rejectUnauthorized: false } : false,
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 5000,
});

// Monitoramento de Acessos (Seção 10): falhas consecutivas de conexão podem
// indicar credencial revogada/rotacionada incorretamente, banco fora do ar, ou
// tentativa de acesso com origem inesperada. Não travamos o processo — apenas
// alertamos alto, pois um pico isolado de erro de rede não deve derrubar a API.
let consecutiveConnectionErrors = 0;
const CONSECUTIVE_ERROR_ALERT_THRESHOLD = 5;

pool.on('error', (err) => {
  consecutiveConnectionErrors += 1;
  logger.error('DATABASE_CONNECTION_FAILED', {
    error: err.message,
    consecutiveConnectionErrors,
  });

  if (consecutiveConnectionErrors >= CONSECUTIVE_ERROR_ALERT_THRESHOLD) {
    logger.error(
      'ALERTA DE SEGURANÇA: múltiplas falhas de conexão consecutivas ao banco de dados. ' +
        'Verifique se as credenciais foram rotacionadas/revogadas incorretamente ' +
        '(ver docs/seguranca-credenciais-banco-de-dados.md, Seção 10).',
      { consecutiveConnectionErrors }
    );
  }
});

pool.on('connect', () => {
  consecutiveConnectionErrors = 0;
});

/**
 * Testa a conectividade uma única vez, para uso no boot do servidor
 * (server.js) — garante que o processo só aceita tráfego depois de confirmar
 * que consegue falar com o banco, e registra o evento oficial de auditoria
 * (Seção 9: DATABASE_CONNECTION_SUCCESS / DATABASE_CONNECTION_FAILED).
 */
async function verifyConnection() {
  try {
    await pool.query('SELECT 1');
    consecutiveConnectionErrors = 0;
    logger.info('DATABASE_CONNECTION_SUCCESS', { database: maskConnectionString() });
    return true;
  } catch (err) {
    logger.error('DATABASE_CONNECTION_FAILED', {
      error: err.message,
      database: maskConnectionString(),
    });
    return false;
  }
}

// Nunca logar a connection string completa (ela contém a senha) — só o host/db,
// para diagnóstico, sem violar a Seção 8 (Proteção Contra Exposição).
function maskConnectionString() {
  try {
    const url = new URL(process.env.DATABASE_URL);
    return `${url.hostname}:${url.port || 5432}${url.pathname}`;
  } catch {
    return '(url inválida ou não-padrão)';
  }
}

/**
 * Executa uma query única. Para transações, use getClient().
 */
async function query(text, params) {
  const start = Date.now();
  const result = await pool.query(text, params);
  const duration = Date.now() - start;
  if (duration > 200) {
    logger.warn('Query lenta detectada', { text, duration });
  }
  return result;
}

/**
 * Obtém um client dedicado do pool para uso em transações (BEGIN/COMMIT/ROLLBACK).
 * Quem chamar é responsável por dar release() no client.
 */
async function getClient() {
  const client = await pool.connect();
  return client;
}

module.exports = { pool, query, getClient, verifyConnection };
