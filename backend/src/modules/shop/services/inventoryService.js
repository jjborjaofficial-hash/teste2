const db = require('../../../config/database');
const repository = require('../repositories/inventoryRepository');
const shopRepository = require('../repositories/shopRepository');
const gamificationRepository = require('../../gamification/repositories/gamificationRepository');
const { resolveRarity } = require('../rarity');
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

// Agrupamento visual (spec Seção 35: "⚡ Boosts", "🛡 Proteção", "🎨
// Personalização", "🏆 Competição", "🎁 Eventos"). `shop_items.category` só
// tem 3 valores técnicos (functional/cosmetic/prestige) — insuficiente para
// os 5 grupos visuais da spec, por isso a resolução usa também
// `effect_key`/`duration_seconds` e a ORIGEM do item (Eventos tem
// prioridade sobre a categoria técnica: um cosmético ganho de evento
// aparece em "Eventos", não em "Personalização").
const DISPLAY_CATEGORIES = {
  boosts: { key: 'boosts', label: 'Boosts', emoji: '⚡' },
  protecao: { key: 'protecao', label: 'Proteção', emoji: '🛡' },
  personalizacao: { key: 'personalizacao', label: 'Personalização', emoji: '🎨' },
  competicao: { key: 'competicao', label: 'Competição', emoji: '🏆' },
  eventos: { key: 'eventos', label: 'Eventos', emoji: '🎁' },
};

function resolveDisplayCategory({ source, category, effectKey }) {
  if (source === 'event' || source === 'campaign') return DISPLAY_CATEGORIES.eventos;
  if (effectKey === 'streak_protection' || effectKey === 'streak_recovery') return DISPLAY_CATEGORIES.protecao;
  if (category === 'prestige') return DISPLAY_CATEGORIES.competicao;
  if (category === 'cosmetic') return DISPLAY_CATEGORIES.personalizacao;
  return DISPLAY_CATEGORIES.boosts; // demais itens funcionais (ex.: Coin Boost)
}

function mapEntry(row) {
  const displayCategory = resolveDisplayCategory({
    source: row.source,
    category: row.category,
    effectKey: row.effect_key,
  });

  return {
    id: row.id,
    itemType: 'temporary_or_consumable',
    key: row.key,
    category: row.category,
    displayCategory,
    rarity: resolveRarity(row.price_points, row.eligibility_rule),
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

/**
 * Itens PERMANENTES (moldura, tema, selo) mapeados no mesmo formato dos
 * itens temporários/consumíveis, para entrarem juntos na mesma lista de
 * "Meus Recursos" (spec Seção 34 — "a página não deve mostrar apenas os
 * itens comprados na Loja" — e Seção 45 — itens permanentes equipáveis
 * fazem parte do inventário, não só do Perfil).
 */
function mapPermanentEntry(row) {
  const slot = row.key.startsWith('theme_') ? 'theme' : row.category === 'cosmetic' ? 'frame' : null;
  const equippedKey = slot === 'theme' ? row.equipped_theme : slot === 'frame' ? row.equipped_avatar_frame : null;
  const isEquipped = slot !== null && equippedKey === row.key;

  return {
    id: row.purchase_id,
    itemType: 'permanent',
    key: row.key,
    category: row.category,
    displayCategory: resolveDisplayCategory({ source: 'shop', category: row.category, effectKey: null }),
    rarity: resolveRarity(row.price_points, row.eligibility_rule),
    name: row.name,
    description: row.description,
    // Selos de prestígio não têm slot para equipar — ficam sempre "owned"
    // (só exibidos). Molduras/temas alternam entre equipped/unequipped.
    status: slot === null ? 'owned' : isEquipped ? 'equipped' : 'unequipped',
    slot,
    quantity: 1,
    isConsumable: false,
    durationSeconds: null,
    source: 'shop',
    acquiredAt: row.acquired_at,
    activatedAt: null,
    expiresAt: null,
    usedAt: null,
    secondsRemaining: null,
  };
}

const SORTERS = {
  // Padrão (spec Seção 49, recomendação): ativos com menor tempo restante
  // primeiro, para o usuário perceber o que precisa usar logo.
  expiry: (a, b) => {
    const rank = { active: 0, owned: 1, unequipped: 1, equipped: 1, expired: 2, used: 2 };
    const rankDiff = (rank[a.status] ?? 3) - (rank[b.status] ?? 3);
    if (rankDiff !== 0) return rankDiff;
    if (a.expiresAt && b.expiresAt) return new Date(a.expiresAt) - new Date(b.expiresAt);
    if (a.expiresAt) return -1;
    if (b.expiresAt) return 1;
    return new Date(b.acquiredAt) - new Date(a.acquiredAt);
  },
  recent: (a, b) => new Date(b.acquiredAt) - new Date(a.acquiredAt),
  category: (a, b) => a.displayCategory.label.localeCompare(b.displayCategory.label) || a.name.localeCompare(b.name),
  name: (a, b) => a.name.localeCompare(b.name),
  rarity: (a, b) => b.rarity.order - a.rarity.order || a.name.localeCompare(b.name),
};

async function listInventory(userId, { sort = 'expiry' } = {}) {
  const [temporaryRows, permanentRows] = await Promise.all([
    repository.listForUser(userId),
    shopRepository.listOwnedPermanentItemsForInventory(userId),
  ]);

  const merged = [...temporaryRows.map(mapEntry), ...permanentRows.map(mapPermanentEntry)];
  const sorter = SORTERS[sort] || SORTERS.expiry;
  return merged.sort(sorter);
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
