const db = require('../../config/database');
const { normalizeEmail, identityHash } = require('../utils/identity');

/** Lista as identidades de uma conta no formato guardado: [{ kind, value }]. */
function identitiesOf({ phone, email, googleId }) {
  const list = [];
  if (phone) list.push({ kind: 'phone', value: String(phone) });
  if (email) list.push({ kind: 'email', value: normalizeEmail(email) });
  if (googleId) list.push({ kind: 'google', value: String(googleId) });
  return list;
}

/** Guarda o hash das identidades de uma conta que vai ser eliminada. Não guarda os dados em claro. */
async function releaseIdentities(executor = db, account) {
  for (const { kind, value } of identitiesOf(account)) {
    await executor.query(
      'INSERT INTO used_identities (kind, identity_hash) VALUES ($1, $2) ON CONFLICT (kind, identity_hash) DO NOTHING',
      [kind, identityHash(kind, value)]
    );
  }
}

/** True se alguma destas identidades já pertenceu a uma conta eliminada. */
async function anyReleased(executor = db, account) {
  const list = identitiesOf(account);
  if (list.length === 0) return false;
  const { rows } = await executor.query(
    `SELECT 1 FROM used_identities WHERE (kind, identity_hash) IN (${list.map((_, i) => `($${i * 2 + 1}, $${i * 2 + 2})`).join(', ')}) LIMIT 1`,
    list.flatMap(({ kind, value }) => [kind, identityHash(kind, value)])
  );
  return rows.length > 0;
}

/** Marca a conta nova como "reciclada" se alguma identidade já foi usada antes. Devolve true se marcou. */
async function markIfRecycled(executor = db, userId, account) {
  if (!(await anyReleased(executor, account))) return false;
  await executor.query('UPDATE users SET identity_recycled = TRUE WHERE id = $1', [userId]);
  return true;
}

module.exports = { releaseIdentities, anyReleased, markIfRecycled, identitiesOf };
