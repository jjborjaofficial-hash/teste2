/**
 * Regra única dos números de Moçambique no frontend (igual a backend/src/common/phone.js).
 * Vodacom (M-Pesa): 84, 85 · Movitel (e-Mola): 86, 87, 88.
 */
export const OPERATOR_PREFIXES = {
  vodacom: ['84', '85'],
  movitel: ['86', '87', '88'],
};

export const PHONE_PREFIX_HINT = 'M-Pesa 84/85 ou e-Mola 86/87/88';

/** 'vodacom' | 'movitel' | null (null enquanto faltam os 2 primeiros dígitos ou se o prefixo não existe). */
export function operatorOf(phone) {
  const prefix = String(phone || '').replace(/\D/g, '').slice(0, 2);
  for (const [operator, list] of Object.entries(OPERATOR_PREFIXES)) {
    if (list.includes(prefix)) return operator;
  }
  return null;
}

/** Número completo válido (9 dígitos, prefixo conhecido). */
export function isValidPhone(phone) {
  return /^\d{9}$/.test(phone) && operatorOf(phone) !== null;
}
