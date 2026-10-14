/**
 * ÚNICA fonte da regra dos números de Moçambique aceites (carteira móvel).
 * O operador (e, por isso, o método de pagamento) deduz-se SEMPRE do prefixo:
 *   Vodacom (M-Pesa): 84, 85
 *   Movitel (e-Mola): 86, 87, 88
 * Para aceitar um prefixo novo, acrescente-o aqui — validação, deteção do operador e mensagens seguem sozinhas.
 */
const PREFIXES = {
  mpesa: ['84', '85'],
  emola: ['86', '87', '88'],
};

const ALL_PREFIXES = Object.values(PREFIXES).flat();
const phoneRegex = new RegExp(`^(${ALL_PREFIXES.join('|')})[0-9]{7}$`);
const PHONE_HELP = `Use um número M-Pesa (${PREFIXES.mpesa.join('/')}) ou e-Mola (${PREFIXES.emola.join('/')}).`;

function detectPhoneProvider(phone) {
  const prefix = String(phone || '').slice(0, 2);
  for (const [provider, list] of Object.entries(PREFIXES)) {
    if (list.includes(prefix)) return provider;
  }
  return null;
}

module.exports = { PREFIXES, phoneRegex, PHONE_HELP, detectPhoneProvider };
