const crypto = require('crypto');

/**
 * Forma única de um e-mail. O Gmail (e googlemail.com) ignora os pontos e tudo depois de "+": joao.jose+x@gmail.com e
 * joaojose@gmail.com são a MESMA caixa. Outros domínios só passam a minúsculas (não se sabe se ignoram "+").
 * Tem de dar o mesmo resultado que o SQL da migration 606 (há um teste que compara os dois).
 */
function normalizeEmail(email) {
  if (!email) return null;
  const lower = String(email).trim().toLowerCase();
  const at = lower.lastIndexOf('@');
  if (at < 1) return lower;
  const local = lower.slice(0, at);
  const domain = lower.slice(at + 1);
  if (domain === 'gmail.com' || domain === 'googlemail.com') {
    return `${local.split('+')[0].replace(/\./g, '')}@gmail.com`;
  }
  return lower;
}

/**
 * Hash (HMAC-SHA256) de uma identidade libertada. Um telefone tem só ~9 dígitos: um hash simples seria desfeito por
 * força bruta, por isso usa uma chave secreta do servidor. Definir IDENTITY_HASH_SECRET no Render e NUNCA a mudar
 * (mudá-la faz o sistema "esquecer" as identidades já guardadas). Sem ela usa JWT_ACCESS_SECRET.
 */
function identityHash(kind, value) {
  const secret = process.env.IDENTITY_HASH_SECRET || process.env.JWT_ACCESS_SECRET || 'dev-sem-segredo';
  return crypto.createHmac('sha256', secret).update(`${kind}:${value}`).digest('hex');
}

module.exports = { normalizeEmail, identityHash };
