const rateLimit = require('express-rate-limit');
const jwt = require('jsonwebtoken');
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

function createRateLimiter({ windowMs, max, message, name, keyGenerator }) {
  const storeName = name || `l${limiterSeq++}`;
  return rateLimit({
    ...(keyGenerator ? { keyGenerator } : {}),
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

// Chave do limite geral: o UTILIZADOR autenticado (token verificado) e, sem token válido, o IP.
// Na internet móvel de Moçambique, e em turmas ou campus, muita gente partilha o mesmo IP: contar só por IP fazia
// com que 60 pedidos por minuto fossem divididos entre todos. O token tem de ser VÁLIDO (assinatura verificada):
// um token falso cai na chave do IP, por isso não dá um contador novo a quem tenta fugir ao limite.
function userOrIpKey(req) {
  const header = req.headers.authorization;
  if (header && header.startsWith('Bearer ')) {
    try {
      const payload = jwt.verify(header.slice(7), process.env.JWT_ACCESS_SECRET);
      if (payload && payload.sub) return `u:${payload.sub}`;
    } catch (err) {
      // token inválido ou expirado: cai no IP
    }
  }
  return req.ip;
}

// Login e Google: por IP. O que protege uma conta de quem tenta adivinhar a senha é o bloqueio por telefone do próprio
// authService (tentativas falhadas recentes), que não depende do IP; por isso o limite por IP pode ser folgado
// (era 8/min, o que bloqueava uma turma ou uma rede móvel partilhada).
const authRateLimiter = createRateLimiter({
  name: 'auth',
  windowMs: 60 * 1000,
  max: 30,
  message: 'Muitas tentativas de autenticação. Aguarde um minuto antes de tentar novamente.',
});

// Cadastro: mais rígido que o login (limita criação em massa de contas e convites falsos), mas permite uma turma.
const registerRateLimiter = createRateLimiter({
  name: 'register',
  windowMs: 60 * 1000,
  max: 15,
  message: 'Muitos cadastros a partir desta rede. Aguarde um minuto antes de tentar novamente.',
});

// Renovar a sessão acontece em segundo plano a cada visita: não pode gastar a cota do login
const refreshRateLimiter = createRateLimiter({
  name: 'refresh',
  windowMs: 60 * 1000,
  max: 30,
  message: 'Muitas renovações de sessão. Aguarde um minuto.',
});

// Limite geral da API: (1) teto por IP contra inundações, folgado para redes partilhadas; (2) cota por utilizador.
const ipFloodLimiter = createRateLimiter({
  name: 'ipflood',
  windowMs: 60 * 1000,
  max: Number(process.env.IP_FLOOD_MAX_REQUESTS) || 600,
  message: 'Demasiados pedidos a partir desta rede. Tente novamente em instantes.',
});
const perUserLimiter = createRateLimiter({ name: 'default', keyGenerator: userOrIpKey });
const defaultRateLimiter = (req, res, next) =>
  ipFloodLimiter(req, res, (err) => (err ? next(err) : perUserLimiter(req, res, next)));

module.exports = {
  createRateLimiter,
  userOrIpKey,
  authRateLimiter,
  registerRateLimiter,
  refreshRateLimiter,
  defaultRateLimiter,
};
