const db = require('../../../config/database');
const { dateInPlatformTz } = require('../../../common/time/platformTimezone');
const { enqueuePush } = require('../../../queue/deliveryQueue');

async function create(executor, { userId, type, title, body, metadata }) {
  const { rows } = await executor.query(
    `INSERT INTO notifications (user_id, type, title, body, metadata)
     VALUES ($1, $2, $3, $4, $5)
     RETURNING id, created_at`,
    [userId, type, title, body, JSON.stringify(metadata || {})]
  );

  // Toda notificação também tenta push, automaticamente — sem precisar
  // alterar os ~10 lugares do projeto que já chamam esta função (missões,
  // streak, saques, ranking, etc.). Best-effort: se push não estiver
  // configurado (ver pushService.js) ou a fila falhar, a notificação em si
  // já está salva acima — nada se perde.
  await enqueuePush(userId, { title, body, data: { type, notificationId: rows[0].id } });

  return rows[0];
}

/**
 * Verifica se já existe uma notificação de um tipo específico criada "hoje"
 * (no fuso oficial da plataforma — ver common/time/platformTimezone.js).
 * Usado para eventos que podem ser disparados várias vezes ao dia pela mesma
 * causa (ex.: cada missão/streak que credita a Carteira chama creditReward),
 * mas que só devem gerar UMA notificação por dia para o usuário.
 */
async function existsTodayByType(userId, type, executor = db) {
  const { rows } = await executor.query(
    `SELECT 1 FROM notifications
     WHERE user_id = $1 AND type = $2 AND ${dateInPlatformTz('created_at')} = ${dateInPlatformTz('now()')}
     LIMIT 1`,
    [userId, type]
  );
  return rows.length > 0;
}

async function listForUser(userId, { limit = 20, offset = 0, unreadOnly = false } = {}, executor = db) {
  const { rows } = await executor.query(
    `SELECT id, type, title, body, metadata, read_at, created_at
     FROM notifications
     WHERE user_id = $1 ${unreadOnly ? 'AND read_at IS NULL' : ''}
     ORDER BY created_at DESC
     LIMIT $2 OFFSET $3`,
    [userId, limit, offset]
  );
  return rows;
}

async function markAsRead(userId, notificationId, executor = db) {
  const { rows } = await executor.query(
    `UPDATE notifications SET read_at = now()
     WHERE id = $1 AND user_id = $2 AND read_at IS NULL
     RETURNING id`,
    [notificationId, userId]
  );
  return rows[0] || null;
}

async function countUnread(userId, executor = db) {
  const { rows } = await executor.query(
    `SELECT COUNT(*)::int AS count FROM notifications WHERE user_id = $1 AND read_at IS NULL`,
    [userId]
  );
  return rows[0].count;
}

/**
 * Lista os IDs de usuários com algum dos papéis administrativos informados.
 * Usada para notificar, por exemplo, todos os admin_master + admin_financeiro
 * quando um novo saque é solicitado (Manual Parte 3: módulo de Notificações
 * como consumidor de outros módulos, aqui o inverso — outro módulo consome este).
 */
async function listUserIdsByRoles(roles, executor = db) {
  const { rows } = await executor.query(
    `SELECT id FROM users WHERE role = ANY($1::varchar[]) AND deleted_at IS NULL`,
    [roles]
  );
  return rows.map((r) => r.id);
}

module.exports = { create, listForUser, markAsRead, countUnread, listUserIdsByRoles, existsTodayByType };
