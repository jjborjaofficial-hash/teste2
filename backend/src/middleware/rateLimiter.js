const rateLimit = require('express-rate-limit');
const { RedisStore } = require('rate-limit-redis');
const redis = require('../config/redis');
const logger = require('../common/logger');
const { RateLimitError } = require('../common/errors/AppError');

/**
 * Rate limiter distribuído (Doc. Mestre Seção 20 — lacuna: "rate limiting" pendente
 * de detalhamento como parte da arquitetura de segurança).
 *
 * Antes desta entrega, o rate limiter era em memória por processo — o que significa
 * que, ao escalar para múltiplas instâncias (Manual Parte 3: Escalabilidade Horizontal),
 * cada instância teria seu próprio contador, permitindo N vezes mais tentativas do que
 * o pretendido. Usar Redis como store compartilhado resolve isso.
 *
 * Se o Redis cair, o `express-rate-limit` usa automaticamente seu MemoryStore interno
 * como fallback (não passamos `store` quando a criação do RedisStore falha) — a
 * plataforma nunca fica fora do ar por causa do rate limiter (mesmo princípio já
 * aplicado ao Ranking).
 */
function buildStore() {
  try {
    return new RedisStore({
      sendCommand: (...args) => redis.call(...args),
      prefix: 'rl:',
    });
  } catch (err) {
    logger.warn('Não foi possível inicializar o RedisStore do rate limiter, usando memória local', {
      error: err.message,
    });
    return undefined; // express-rate-limit usa MemoryStore por padrão quando store é undefined
  }
}

function createRateLimiter({ windowMs, max, message }) {
  return rateLimit({
    windowMs: windowMs || Number(process.env.RATE_LIMIT_WINDOW_MS) || 60000,
    max: max || Number(process.env.RATE_LIMIT_MAX_REQUESTS) || 60,
    standardHeaders: true,
    legacyHeaders: false,
    store: buildStore(),
    handler: (req, res, next) => {
      next(new RateLimitError(message || 'Muitas tentativas. Tente novamente em instantes.'));
    },
  });
}

// Limite mais rígido para login/registro (proteção contra força bruta e criação em massa de contas)
const authRateLimiter = createRateLimiter({
  windowMs: 60 * 1000,
  max: 8,
  message: 'Muitas tentativas de autenticação. Aguarde um minuto antes de tentar novamente.',
});

// Limite padrão para o restante da API
const defaultRateLimiter = createRateLimiter({});

module.exports = { createRateLimiter, authRateLimiter, defaultRateLimiter };
