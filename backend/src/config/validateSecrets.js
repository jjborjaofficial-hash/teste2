/**
 * Validação dos segredos JWT no arranque (só em produção).
 *
 * O `.env.example` traz um valor de teste ("troque_este_valor...") e o repositório
 * é público: se esse valor, ou um segredo vazio/curto, for parar em produção,
 * qualquer pessoa consegue forjar logins. Por isso, em produção o servidor se
 * recusa a arrancar nessa situação. Fora de produção (dev/teste) nada é exigido.
 */
const MIN_SECRET_LENGTH = 32;
const PLACEHOLDER_HINTS = ['troque_este_valor', 'change_me', 'changeme', 'your_secret', 'secret_here'];

function problemWithSecret(name, value) {
  if (!value || !String(value).trim()) return `${name} está vazio.`;
  const lower = String(value).toLowerCase();
  if (PLACEHOLDER_HINTS.some((hint) => lower.includes(hint))) {
    return `${name} ainda tem o valor de exemplo do .env.example.`;
  }
  if (String(value).length < MIN_SECRET_LENGTH) {
    return `${name} é curto demais (mínimo ${MIN_SECRET_LENGTH} caracteres).`;
  }
  return null;
}

/** Devolve a lista de problemas (vazia = tudo certo). Só valida em produção. */
function findJwtSecretProblems(env = process.env) {
  if (env.NODE_ENV !== 'production') return [];
  const problems = [
    problemWithSecret('JWT_ACCESS_SECRET', env.JWT_ACCESS_SECRET),
    problemWithSecret('JWT_REFRESH_SECRET', env.JWT_REFRESH_SECRET),
  ].filter(Boolean);
  if (
    env.JWT_ACCESS_SECRET &&
    env.JWT_REFRESH_SECRET &&
    env.JWT_ACCESS_SECRET === env.JWT_REFRESH_SECRET
  ) {
    problems.push('JWT_ACCESS_SECRET e JWT_REFRESH_SECRET não podem ser iguais.');
  }
  return problems;
}

module.exports = { findJwtSecretProblems, MIN_SECRET_LENGTH };
