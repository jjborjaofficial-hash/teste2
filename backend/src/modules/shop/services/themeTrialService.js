const db = require('../../../config/database');
const userCache = require('../../../common/cache/userCache');
const { ConflictError, ForbiddenError, NotFoundError } = require('../../../common/errors/AppError');
const { computeTrial } = require('../themeTrial');

/**
 * Tema Noite emprestado por 10 minutos (GER-002). O empréstimo não é compra: não toca em inventário,
 * Pontos, dinheiro nem em equipped_theme. Uma vez por conta; só contas novas (theme_trial_eligible).
 */

const COLUMNS = `theme_trial_eligible AS eligible, theme_trial_started_at AS "startedAt",
                 theme_trial_intro_seen_at AS "introSeenAt", equipped_theme AS "equippedTheme"`;

async function readRow(userId) {
  const { rows } = await db.query(
    `SELECT ${COLUMNS} FROM users WHERE id = $1 AND deleted_at IS NULL`,
    [userId]
  );
  return rows[0] || null;
}

async function getState(userId, now = new Date()) {
  const row = await readRow(userId);
  if (!row) throw new NotFoundError('Perfil não encontrado.');
  return computeTrial(row, now);
}

/**
 * Começa o empréstimo. Idempotente: durante o empréstimo devolve o estado atual (não reinicia nem prolonga);
 * depois de usado devolve 409; conta sem direito devolve 403.
 */
async function start(userId, now = new Date()) {
  const { rows } = await db.query(
    `UPDATE users
        SET theme_trial_started_at = $2,
            theme_trial_intro_seen_at = COALESCE(theme_trial_intro_seen_at, $2),
            updated_at = now()
      WHERE id = $1 AND deleted_at IS NULL
        AND theme_trial_eligible = TRUE
        AND theme_trial_started_at IS NULL
        AND COALESCE(equipped_theme, '') <> 'theme_night'
      RETURNING ${COLUMNS}`,
    [userId, now]
  );
  if (rows[0]) {
    await userCache.invalidateProfile(userId);
    return computeTrial(rows[0], now);
  }

  const current = await readRow(userId);
  if (!current) throw new NotFoundError('Perfil não encontrado.');
  if (current.startedAt) {
    const state = computeTrial(current, now);
    if (state.status === 'active') return state;
    throw new ConflictError('Você já usou o empréstimo do Tema Noite.');
  }
  if (current.equippedTheme === 'theme_night') throw new ConflictError('Você já tem o Tema Noite.');
  throw new ForbiddenError('O empréstimo do Tema Noite não está disponível nesta conta.');
}

/** O utilizador viu os ecrãs e escolheu "Modo claro": não gasta a oferta, só deixa de mostrar os ecrãs. */
async function dismissIntro(userId, now = new Date()) {
  await db.query(
    `UPDATE users SET theme_trial_intro_seen_at = COALESCE(theme_trial_intro_seen_at, $2), updated_at = now()
      WHERE id = $1 AND deleted_at IS NULL AND theme_trial_eligible = TRUE`,
    [userId, now]
  );
  await userCache.invalidateProfile(userId);
  return getState(userId, now);
}

module.exports = { getState, start, dismissIntro };
