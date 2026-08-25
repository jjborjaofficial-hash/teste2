const db = require('../../../config/database');
const repository = require('../repositories/inventoryRepository');
const gamificationRepository = require('../../gamification/repositories/gamificationRepository');
const { NotFoundError, BusinessRuleError } = require('../../../common/errors/AppError');

/**
 * Service do Inventário ("Meus Recursos", spec Seções 34-60).
 *
 * REGRA DE OURO (spec Seção 55, 41): a validade de qualquer item nunca é
 * decidida pelo frontend. O contador regressivo na tela é só exibição —
 * quem decide se um item pode ser ativado/usado/efetivo é sempre uma
 * consulta ao servidor no momento da ação, usando o relógio do Postgres
 * (`now()`), nunca `Date.now()` do processo Node nem nada vindo do cliente.
 */

function mapEntry(row) {
  return {
    id: row.id,
    key: row.key,
    category: row.category,
    name: row.name,
    description: row.description,
    status: row.status, // já é o status EFETIVO (effective_inventory_status)
    quantity: row.quantity,
    isConsumable: row.is_consumable,
    durationSeconds: row.duration_seconds,
    source: row.source,
    acquiredAt: row.acquired_at,
    activatedAt: row.activated_at,
    expiresAt: row.expires_at,
    usedAt: row.used_at,
    // Segundos restantes calculados NO SERVIDOR, no instante da resposta —
    // o frontend soma isso à hora local só para exibir a contagem regressiva
    // sem precisar bater no servidor a cada segundo; nunca é usado para
    // decidir se o item ainda é válido (isso o backend sempre recalcula).
    secondsRemaining:
      row.status === 'active' && row.expires_at
        ? Math.max(0, Math.round((new Date(row.expires_at).getTime() - Date.now()) / 1000))
        : null,
  };
}

async function listInventory(userId) {
  const rows = await repository.listForUser(userId);
  return rows.map(mapEntry);
}

async function activateItem(userId, inventoryId) {
  const client = await db.getClient();
  try {
    await client.query('BEGIN');

    const row = await repository.findByIdForUser(inventoryId, userId, client);
    if (!row) throw new NotFoundError('Item não encontrado no seu inventário.');
    if (row.duration_seconds === null) {
      throw new BusinessRuleError('Este item não é temporário e não precisa ser ativado.');
    }
    if (row.status !== 'owned') {
      throw new BusinessRuleError('Este item já foi ativado, expirou ou já foi usado.');
    }

    const activated = await repository.activate(client, inventoryId, row.duration_seconds);
    await client.query('COMMIT');
    return mapEntry({ ...activated, key: row.key, category: row.category, name: row.name, is_consumable: row.is_consumable, duration_seconds: row.duration_seconds });
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}

/**
 * Usar um consumível (ex.: Streak Shield). Aplica o efeito de verdade e
 * decrementa a quantidade — nunca só "marca como usado" sem efeito real.
 */
async function useItem(userId, inventoryId) {
  const client = await db.getClient();
  try {
    await client.query('BEGIN');

    const row = await repository.findByIdForUser(inventoryId, userId, client);
    if (!row) throw new NotFoundError('Item não encontrado no seu inventário.');
    if (!row.is_consumable) {
      throw new BusinessRuleError('Este item não é consumível.');
    }
    if (row.status !== 'owned' || row.quantity <= 0) {
      throw new BusinessRuleError('Este item expirou e não pode mais ser utilizado.');
    }

    // Efeito real do consumível — reaproveita a mesma lógica de streak já
    // testada na Loja (setProtectionActive), em vez de duplicar regra.
    if (row.effect_key === 'streak_protection') {
      const streak = await gamificationRepository.getStreak(userId, client);
      if (!streak) throw new NotFoundError('Streak do usuário não encontrado.');
      if (streak.protection_active) {
        throw new BusinessRuleError('Você já tem uma proteção de streak ativa — guarde este item para depois.');
      }
      await gamificationRepository.setProtectionActive(client, userId);
    }

    const updated = await repository.consumeOne(client, inventoryId);
    await client.query('COMMIT');
    return mapEntry({ ...updated, key: row.key, category: row.category, name: row.name, is_consumable: row.is_consumable, duration_seconds: row.duration_seconds });
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}

module.exports = { listInventory, activateItem, useItem };
