const db = require('../../../config/database');
const repository = require('../repositories/shopRepository');
const inventoryRepository = require('../repositories/inventoryRepository');
const pointsLedgerRepository = require('../../gamification/repositories/pointsLedgerRepository');
const gamificationRepository = require('../../gamification/repositories/gamificationRepository');
const rankingRepository = require('../../ranking/repositories/rankingRepository');
const userCache = require('../../../common/cache/userCache');
const { BusinessRuleError, ForbiddenError, NotFoundError, ConflictError } = require('../../../common/errors/AppError');

/**
 * Service da Loja de Pontos (docx "SISTEMA DE ECONOMIA E RECOMPENSAS", Seção 3
 * — sink de economia). Único lugar da plataforma onde Pontos são gastos —
 * por decisão explícita do proprietário do projeto, missões nunca custam
 * Pontos, só a Loja.
 */

const RECOVERY_WINDOW_HOURS = 24;

function mapItem(item) {
  return {
    id: item.id,
    key: item.key,
    category: item.category,
    name: item.name,
    description: item.description,
    pricePoints: item.price_points,
  };
}

async function listItems(userId) {
  const items = await repository.listActiveItems();
  const ownedKeys = userId ? await repository.listOwnedCosmeticKeys(userId) : [];

  let currentPosition = null;
  if (userId && items.some((i) => i.eligibility_rule === 'top10_ranking')) {
    const weekStart = rankingRepository.currentWeekStartDate();
    const position = await rankingRepository.getUserPosition(userId, weekStart);
    currentPosition = position?.position ?? null;
  }

  let streakState = null;
  if (userId && items.some((i) => i.effect_key || i.eligibility_rule === 'streak_100_days')) {
    streakState = await gamificationRepository.getStreak(userId, db);
  }

  return items.map((item) => {
    const mapped = mapItem(item);

    if (item.category === 'cosmetic' || item.category === 'prestige') {
      mapped.owned = ownedKeys.includes(item.key);
    }

    if (item.eligibility_rule === 'top10_ranking') {
      mapped.eligible = currentPosition !== null && currentPosition <= 10;
      mapped.eligibilityReason = mapped.eligible
        ? null
        : 'Disponível apenas para quem está no Top 10 do ranking semanal atual.';
    }

    if (item.eligibility_rule === 'streak_100_days') {
      mapped.eligible = !!streakState && streakState.longest_streak_days >= 100;
      mapped.eligibilityReason = mapped.eligible
        ? null
        : 'Disponível apenas para quem já alcançou 100 dias de streak (Ofensiva) alguma vez.';
    }

    if (item.effect_key === 'streak_protection' && streakState) {
      mapped.eligible = !streakState.protection_active;
      mapped.eligibilityReason = mapped.eligible ? null : 'Você já tem uma proteção de streak ativa.';
    }

    if (item.effect_key === 'streak_recovery' && streakState) {
      const withinWindow =
        streakState.broken_at &&
        Date.now() - new Date(streakState.broken_at).getTime() <= RECOVERY_WINDOW_HOURS * 3600000;
      mapped.eligible = !!withinWindow;
      mapped.eligibilityReason = withinWindow
        ? null
        : 'Só é possível recuperar um streak quebrado há menos de 24 horas.';
    }

    return mapped;
  });
}

/**
 * Efetua a compra de um item: debita Pontos, aplica o efeito (se funcional),
 * registra a compra — tudo em uma única transação.
 */
async function purchase(userId, itemKey, { ipAddress } = {}) {
  const client = await db.getClient();
  try {
    await client.query('BEGIN');

    const item = await repository.findItemByKey(itemKey, client);
    if (!item || !item.is_active) {
      throw new NotFoundError('Item não encontrado ou indisponível.');
    }

    if ((item.category === 'cosmetic' || item.category === 'prestige') && !item.is_consumable && item.duration_seconds === null) {
      const alreadyOwned = await repository.hasPurchased(userId, item.id, client);
      if (alreadyOwned) {
        throw new ConflictError('Você já possui este item.');
      }
    }

    if (item.eligibility_rule === 'top10_ranking') {
      const weekStart = rankingRepository.currentWeekStartDate();
      const position = await rankingRepository.getUserPosition(userId, weekStart, client);
      if (!position || position.position > 10) {
        throw new ForbiddenError('Este item só pode ser comprado por quem está no Top 10 do ranking semanal atual.');
      }
    }

    if (item.eligibility_rule === 'streak_100_days') {
      const streakForBadge = await gamificationRepository.getStreak(userId, client);
      if (!streakForBadge || streakForBadge.longest_streak_days < 100) {
        throw new ForbiddenError('Este selo só pode ser comprado por quem já alcançou 100 dias de streak.');
      }
    }

    let streak = null;
    // Itens consumíveis (ex.: Streak Shield) e temporários (ex.: Coin Boost)
    // vão para o inventário na compra — o efeito real só é aplicado no uso
    // (inventoryService.useItem) ou na ativação, nunca na hora da compra.
    // Por isso a checagem "já tem proteção ativa" só se aplica aos itens de
    // efeito INSTANTÂNEO (streak_protection/streak_recovery clássicos).
    if (item.effect_key && !item.is_consumable && item.duration_seconds === null) {
      streak = await gamificationRepository.getStreak(userId, client);
      if (!streak) throw new NotFoundError('Streak do usuário não encontrado.');

      if (item.effect_key === 'streak_protection' && streak.protection_active) {
        throw new BusinessRuleError('Você já tem uma proteção de streak ativa — não é possível comprar outra agora.');
      }

      if (item.effect_key === 'streak_recovery') {
        const withinWindow =
          streak.broken_at && Date.now() - new Date(streak.broken_at).getTime() <= RECOVERY_WINDOW_HOURS * 3600000;
        if (!withinWindow) {
          throw new BusinessRuleError('Só é possível recuperar um streak quebrado há menos de 24 horas.');
        }
      }
    }

    let ledgerEntry;
    try {
      ledgerEntry = await pointsLedgerRepository.debitPoints(client, {
        userId,
        amountPoints: item.price_points,
        source: 'shop_purchase',
        referenceId: item.id,
        metadata: { itemKey: item.key, itemName: item.name },
      });
    } catch (err) {
      if (err.code === 'INSUFFICIENT_BALANCE') {
        throw new BusinessRuleError(`Pontos insuficientes. Este item custa ${item.price_points} Pontos.`);
      }
      throw err;
    }

    if (item.effect_key === 'streak_protection' && !item.is_consumable && item.duration_seconds === null) {
      await gamificationRepository.setProtectionActive(client, userId);
    } else if (item.effect_key === 'streak_recovery') {
      await gamificationRepository.recoverStreak(client, userId);
    }

    const purchaseRecord = await repository.recordPurchase(client, {
      userId,
      shopItemId: item.id,
      pricePaidPoints: item.price_points,
      pointsLedgerId: ledgerEntry.id,
    });

    // Consumíveis e temporários vão para "Meus Recursos" na compra — o
    // efeito real só acontece ao usar/ativar (inventoryService), nunca aqui.
    if (item.is_consumable) {
      await inventoryRepository.grantConsumable(client, {
        userId,
        itemId: item.id,
        source: 'shop',
        referenceId: purchaseRecord.id,
      });
    } else if (item.duration_seconds !== null) {
      await inventoryRepository.grantTemporary(client, {
        userId,
        itemId: item.id,
        source: 'shop',
        referenceId: purchaseRecord.id,
      });
    }

    await client.query('COMMIT');

    await userCache.invalidateProfile(userId);
    if (item.effect_key) {
      await userCache.invalidateStreak(userId);
    }

    return {
      purchaseId: purchaseRecord.id,
      item: mapItem(item),
      pricePaidPoints: item.price_points,
      newPointsBalance: ledgerEntry.balanceAfter,
      purchasedAt: purchaseRecord.created_at,
    };
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}

/**
 * Equipa (ou remove) um cosmético já comprado. O "slot" é inferido pelo
 * prefixo da chave do item (`frame_...` → moldura, `theme_...` → tema) — não
 * precisamos de uma coluna extra de slot enquanto o catálogo for pequeno.
 */
async function equip(userId, itemKey) {
  const item = await repository.findItemByKey(itemKey);
  if (!item) throw new NotFoundError('Item não encontrado.');
  if (item.category !== 'cosmetic') {
    throw new BusinessRuleError('Apenas itens cosméticos podem ser equipados.');
  }

  const owned = await repository.hasPurchased(userId, item.id);
  if (!owned) throw new ForbiddenError('Você ainda não possui este item.');

  const slot = item.key.startsWith('theme_') ? 'theme' : 'frame';
  const column = slot === 'theme' ? 'equipped_theme' : 'equipped_avatar_frame';

  await db.query(`UPDATE users SET ${column} = $1 WHERE id = $2`, [item.key, userId]);
  await userCache.invalidateProfile(userId);

  return { slot, equippedKey: item.key };
}

async function unequip(userId, slot) {
  const column = slot === 'theme' ? 'equipped_theme' : slot === 'frame' ? 'equipped_avatar_frame' : null;
  if (!column) throw new BusinessRuleError('Slot inválido.');

  await db.query(`UPDATE users SET ${column} = NULL WHERE id = $1`, [userId]);
  await userCache.invalidateProfile(userId);

  return { slot, equippedKey: null };
}

async function getMyInventory(userId) {
  const purchases = await repository.listMyPurchases(userId);
  const { rows } = await db.query(
    `SELECT equipped_avatar_frame, equipped_theme FROM users WHERE id = $1`,
    [userId]
  );

  return {
    equippedAvatarFrame: rows[0]?.equipped_avatar_frame || null,
    equippedTheme: rows[0]?.equipped_theme || null,
    purchases: purchases.map((p) => ({
      id: p.id,
      key: p.key,
      category: p.category,
      name: p.name,
      pricePaidPoints: p.price_paid_points,
      purchasedAt: p.created_at,
    })),
  };
}

async function getMyPointsLedger(userId, pagination) {
  const rows = await pointsLedgerRepository.listLedger(userId, pagination);
  return rows.map((r) => ({
    id: r.id,
    type: r.type,
    source: r.source,
    amountPoints: r.amount_points,
    balanceAfter: r.balance_after,
    createdAt: r.created_at,
  }));
}

// --- Administração (docx Seção 14: "Moedas: Criar recompensas; Criar loja; Controlar economia") ---

async function listItemsAdmin() {
  const rows = await repository.listAllItemsAdmin();
  return rows.map((r) => ({ ...mapItem(r), isActive: r.is_active, effectKey: r.effect_key, eligibilityRule: r.eligibility_rule, purchasesCount: r.purchases_count }));
}

async function createItem(data) {
  const created = await repository.createItem(data);
  return mapItem(created);
}

async function updateItem(id, data) {
  const existing = await repository.findItemById(id);
  if (!existing) throw new NotFoundError('Item não encontrado.');
  const updated = await repository.updateItem(id, data);
  return { ...mapItem(updated), isActive: updated.is_active };
}

async function listPurchasesAdmin(pagination) {
  const rows = await repository.listPurchasesAdmin(pagination);
  return rows.map((r) => ({
    id: r.id,
    itemName: r.item_name,
    category: r.category,
    pricePaidPoints: r.price_paid_points,
    userName: r.user_name,
    userPhone: r.user_phone,
    purchasedAt: r.created_at,
  }));
}

module.exports = {
  listItems,
  purchase,
  equip,
  unequip,
  getMyInventory,
  getMyPointsLedger,
  listItemsAdmin,
  createItem,
  updateItem,
  listPurchasesAdmin,
};
