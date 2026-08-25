const logger = require('../common/logger');
const { ForbiddenError } = require('../common/errors/AppError');

/**
 * Configuração de CORS (Manual Parte 3: Security by Design).
 *
 * ANTES: `cors()` sem opções liberava QUALQUER origem a fazer requisições
 * autenticadas à API — qualquer site na internet podia embutir chamadas com
 * o token Bearer do usuário (se conseguisse obtê-lo) ou explorar o endpoint
 * de refresh via cookie (ver correção do refresh token em cookie httpOnly).
 *
 * AGORA: só as origens explicitamente listadas em CORS_ALLOWED_ORIGINS podem
 * chamar a API. Em produção isso deve ser o domínio oficial do frontend web
 * (e do painel administrativo, se estiver em subdomínio separado) — nunca "*".
 */

const allowedOrigins = (process.env.CORS_ALLOWED_ORIGINS || 'http://localhost:5173')
  .split(',')
  .map((origin) => origin.trim())
  .filter(Boolean);

const corsOptions = {
  origin(origin, callback) {
    // Requisições sem header Origin (ex.: healthcheck, chamadas server-to-server,
    // curl) não são bloqueadas por CORS — CORS é uma proteção de navegador.
    if (!origin) return callback(null, true);

    if (allowedOrigins.includes(origin)) {
      return callback(null, true);
    }

    logger.warn('Requisição bloqueada por CORS: origem não autorizada', { origin });
    // ForbiddenError (não Error genérico): garante 403 limpo via errorHandler,
    // em vez de cair como 500 "erro de sistema" e poluir os logs de erro para
    // algo que é, na verdade, o CORS funcionando como esperado.
    return callback(new ForbiddenError('Origem não autorizada.'));
  },
  credentials: true, // necessário para o cookie httpOnly do refresh token
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
};

module.exports = corsOptions;
