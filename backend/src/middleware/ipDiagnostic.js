// DIAGNÓSTICO TEMPORÁRIO (remover depois de ler o resultado nos logs da Render).
// Só liga se IP_DIAGNOSTIC=1. Regista, para os primeiros pedidos a /api, de onde o backend acha que vêm:
// o IP que usa (req.ip), a lista X-Forwarded-For e o endereço da ligação direta. Só endereços de rede e o
// caminho sem query: nunca cookies, tokens, telefones nem o corpo do pedido.
const logger = require('../common/logger');

const MAX_LOGS = Number(process.env.IP_DIAGNOSTIC_MAX) || 40;
let logged = 0;

const cut = (v) => (v === undefined ? null : String(v).slice(0, 200));

function ipDiagnostic(req, res, next) {
  if (process.env.IP_DIAGNOSTIC === '1' && logged < MAX_LOGS && req.path.startsWith('/api/')) {
    logged += 1;
    logger.info('IP-DIAGNOSTICO', {
      n: logged,
      path: req.path,
      reqIp: req.ip,
      reqIps: req.ips,
      trustProxy: req.app.get('trust proxy'),
      xForwardedFor: cut(req.headers['x-forwarded-for']),
      xRealIp: cut(req.headers['x-real-ip']),
      cfConnectingIp: cut(req.headers['cf-connecting-ip']),
      trueClientIp: cut(req.headers['true-client-ip']),
      socketAddress: req.socket && req.socket.remoteAddress,
    });
  }
  next();
}

module.exports = ipDiagnostic;
