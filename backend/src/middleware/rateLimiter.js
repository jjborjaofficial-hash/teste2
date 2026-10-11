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
function buildStore(name) {
  try {
    return new RedisStore({
      sendCommand: (...args) => redis.call(...args),
      // Prefixo próprio por limitador: com o mesmo prefixo, todos somavam no mesmo
      // contador por IP e as chamadas normais da API gastavam a cota do login.
      prefix: `rl:${name}:`,
    });
  } catch (err) {
    logger.warn('Não foi possível inicializar o RedisStore do rate limiter, usando memória local', {
      error: err.message,
    });
    return undefined; // express-rate-limit usa MemoryStore por padrão quando store é undefined
  }
}

let limiterSeq = 0;

function createRateLimiter({ windowMs, max, message, name }) {
  const storeName = name || `l${limiterSeq++}`;
  return rateLimit({
    windowMs: windowMs || Number(process.env.RATE_LIMIT_WINDOW_MS) || 60000,
    max: max || Number(process.env.RATE_LIMIT_MAX_REQUESTS) || 60,
    standardHeaders: true,
    legacyHeaders: false,
    store: buildStore(storeName),
    handler: (req, res, next) => {
      next(new RateLimitError(message || 'Muitas tentativas. Tente novamente em instantes.'));
    },
  });
}

// Limite mais rígido para login/registro (proteção contra força bruta e criação em massa de contas)
const authRateLimiter = createRateLimiter({
  name: 'auth',
  windowMs: 60 * 1000,
  max: 8,
  message: 'Muitas tentativas de autenticação. Aguarde um minuto antes de tentar novamente.',
});

// Renovar a sessão acontece em segundo plano a cada visita: não pode gastar a cota do login
const refreshRateLimiter = createRateLimiter({
  name: 'refresh',
  windowMs: 60 * 1000,
  max: 30,
  message: 'Muitas renovações de sessão. Aguarde um minuto.',
});

// Limite padrão para o restante da API
const defaultRateLimiter = createRateLimiter({ name: 'default' });

module.exports = { createRateLimiter, authRateLimiter, refreshRateLimiter, defaultRateLimiter };
