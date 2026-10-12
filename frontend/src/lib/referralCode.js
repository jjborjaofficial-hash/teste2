// Guarda o código do link de convite (ex.: /cadastro?ref=A1B2C3D4) para sobreviver até ao fim do cadastro,
// inclusive pelo botão "Continuar com Google", que não passa pelo formulário que tem o campo do código.
const KEY = 'referral_code';

// Mesma forma que o servidor aceita: até 12 letras ou números.
export function sanitizeReferralCode(value) {
  const code = String(value || '').toUpperCase().replace(/[^A-Z0-9]/g, '').slice(0, 12);
  return code || null;
}

export function rememberReferralCode(value) {
  const code = sanitizeReferralCode(value);
  if (!code) return null;
  try { localStorage.setItem(KEY, code); } catch { /* navegação privada: segue sem guardar */ }
  return code;
}

export function getRememberedReferralCode() {
  try { return sanitizeReferralCode(localStorage.getItem(KEY)); } catch { return null; }
}

export function clearReferralCode() {
  try { localStorage.removeItem(KEY); } catch { /* sem efeito */ }
}
