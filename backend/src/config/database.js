const { Pool, Client } = require('pg');
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
  // Diagnóstico de 11/10: abrir uma ligação nova do Render (Oregon) ao Neon (Londres) custa ~0,8 a 1,6 s, e uma query
  // numa ligação já aberta custa ~0,13 s. Com 30 s de espera o pool fechava as ligações entre pedidos e quase todos os
  // pedidos pagavam a ligação. 5 min mantém as ligações abertas durante uma sessão de jogo. NÃO usar pings periódicos
  // para as manter acordadas: gastariam a quota de horas de computação do plano gratuito da Neon, que suspende o banco
  // sozinha quando não há atividade (e o pool descarta as ligações mortas sem erro para quem pede a query).
  idleTimeoutMillis: 300000,
  keepAlive: true,
  keepAliveInitialDelayMillis: 10000,
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

// Diagnóstico de latência (11/10): quantas ligações novas o pool abriu desde o arranque. Se este número
// sobe a cada pedido, a lentidão vem de abrir ligações (TCP + TLS + autenticação) e não das queries.
let newConnections = 0;

pool.on('connect', () => {
  consecutiveConnectionErrors = 0;
  newConnections += 1;
});

/** Estado do pool, para os logs de diagnóstico. */
function poolStats() {
  return {
    poolTotal: pool.totalCount,
    poolIdle: pool.idleCount,
    poolWaiting: pool.waitingCount,
    novasLigacoes: newConnections,
  };
}

/**
 * Sonda de latência: abre UMA ligação nova (mede o custo de ligar) e faz algumas queries `SELECT 1`
 * em sequência nela (mede o custo de cada ida e volta ao banco). Num banco local dá poucos ms;
 * entre regiões diferentes (ex.: Render Oregon -> Neon Londres) mostra a distância real.
 * Só lê, não altera nada. Usa uma ligação própria (não mexe no pool).
 */
async function probeLatency(samples = 5) {
  const client = new Client({
    connectionString: process.env.DATABASE_URL,
    ssl: process.env.DATABASE_SSL === 'true' ? { rejectUnauthorized: false } : undefined,
    connectionTimeoutMillis: 15000,
  });
  const t0 = Date.now();
  await client.connect();
  const connectMs = Date.now() - t0;
  const queryMs = [];
  try {
    for (let i = 0; i < samples; i += 1) {
      const t = Date.now();
      await client.query('SELECT 1');
      queryMs.push(Date.now() - t);
    }
  } finally {
    await client.end().catch(() => {});
  }
  const sorted = [...queryMs].sort((a, b) => a - b);
  return { connectMs, queryMs, medianMs: sorted[Math.floor(sorted.length / 2)] };
}

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
    if (process.env.NODE_ENV !== 'test' && process.env.DB_LATENCY_PROBE !== 'off') {
      probeLatency()
        .then((r) => logger.info('DB_LATENCY_PROBE', r))
        .catch((err) => logger.warn('DB_LATENCY_PROBE_FAILED', { error: err.message }));
    }
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
    logger.warn('Query lenta detectada', { text, duration, ...poolStats() });
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

module.exports = { pool, query, getClient, verifyConnection, probeLatency, poolStats };
