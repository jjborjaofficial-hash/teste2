/**
 * Regra única dos números de Moçambique no frontend (igual a backend/src/common/phone.js).
 * Vodacom (M-Pesa): 84, 85 · Movitel (e-Mola): 86, 87, 88.
 */
export const OPERATOR_PREFIXES = {
  vodacom: ['84', '85'],
  movitel: ['86', '87', '88'],
};

export const PHONE_PREFIX_HINT = 'M-Pesa 84/85 ou e-Mola 86/87/88';

/**
 * 'vodacom' | 'movitel' | null. Vale igual para as duas operadoras:
 * null enquanto faltam os 2 primeiros dígitos, se o prefixo não existe, ou se passar de 9 dígitos
 * (número a mais = deixa de reconhecer e o logo some).
 */
export function operatorOf(phone) {
  const digits = String(phone || '').replace(/\D/g, '');
  if (digits.length > 9) return null;
  const prefix = digits.slice(0, 2);
  for (const [operator, list] of Object.entries(OPERATOR_PREFIXES)) {
    if (list.includes(prefix)) return operator;
  }
  return null;
}

/** Número completo válido (9 dígitos, prefixo conhecido). */
export function isValidPhone(phone) {
  return /^\d{9}$/.test(phone) && operatorOf(phone) !== null;
}

/**
 * Limpa o que a pessoa escreve ou cola: só dígitos, sem o +258/258 do país, no máximo 9 dígitos.
 * Ex.: "+258 84 123 4567" -> "841234567".
 */
export function cleanPhone(value) {
  let digits = String(value || '').replace(/\D/g, '');
  if (digits.startsWith('258') && digits.length > 9) digits = digits.slice(3);
  return digits.slice(0, 9);
}
