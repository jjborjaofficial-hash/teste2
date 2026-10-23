/**
 * Loja de avatares (migration 730): imagem de perfil comprável com Pontos, no slot "avatar" ao lado de moldura
 * e tema. Teste de integração (PostgreSQL com as migrations). Os utilizadores de teste NÃO são apagados
 * (user_purchases e audit_logs são append-only e bloqueiam o DELETE em cascata).
 */
const fs = require('fs');
const path = require('path');
const db = require('../src/config/database');
const shopService = require('../src/modules/shop/services/shopService');
const userRepository = require('../src/modules/users/repositories/userRepository');
const rankingRepository = require('../src/modules/ranking/repositories/rankingRepository');
const { slotForKey, columnForSlot } = require('../src/modules/shop/slots');

async function makeUser(points) {
  const phone = `84${Math.floor(1000000 + Math.random() * 8999999)}`;
  const { rows } = await db.query(
    `INSERT INTO users (name, phone, password_hash, phone_provider, status, points_balance)
     VALUES ('Teste Avatar', $1, 'x', 'mpesa', 'active', $2) RETURNING id`,
    [phone, points]
  );
  await db.query('INSERT INTO streaks (user_id) VALUES ($1) ON CONFLICT DO NOTHING', [rows[0].id]);
  return rows[0].id;
}

afterAll(async () => {
  await db.pool.end();
});

describe('slots de cosméticos', () => {
  it('a chave decide o slot e cada slot tem a sua coluna', () => {
    expect(slotForKey('avatar_naruto')).toBe('avatar');
    expect(slotForKey('theme_night')).toBe('theme');
    expect(slotForKey('frame_champion')).toBe('frame');
    expect(columnForSlot('avatar')).toBe('equipped_avatar_image');
    expect(columnForSlot('frame')).toBe('equipped_avatar_frame');
    expect(columnForSlot('theme')).toBe('equipped_theme');
    expect(columnForSlot('constructor')).toBeNull();
    expect(columnForSlot('qualquer')).toBeNull();
  });
});

describe('avatar_naruto na Loja', () => {
  it('foi semeado como cosmético de 500 Pontos, ativo', async () => {
    const { rows } = await db.query(
      `SELECT category, price_points, is_active, effect_key FROM shop_items WHERE key = 'avatar_naruto'`
    );
    expect(rows).toHaveLength(1);
    expect(rows[0]).toMatchObject({ category: 'cosmetic', price_points: 500, is_active: true, effect_key: null });
  });

  it('compra por 500, equipa, aparece no perfil/inventário/ranking e remove — sem mexer na moldura nem no tema', async () => {
    const userId = await makeUser(600);

    await expect(shopService.equip(userId, 'avatar_naruto')).rejects.toThrow(/não possui/i);

    const res = await shopService.purchase(userId, 'avatar_naruto');
    expect(res.newPointsBalance).toBe(100);
    await expect(shopService.purchase(userId, 'avatar_naruto')).rejects.toThrow(/já possui/i);

    expect(await shopService.equip(userId, 'avatar_naruto')).toEqual({ slot: 'avatar', equippedKey: 'avatar_naruto' });

    const profile = await userRepository.findProfileById(userId);
    expect(profile.equipped_avatar_image).toBe('avatar_naruto');
    expect(profile.equipped_avatar_frame).toBeNull();
    expect(profile.equipped_theme).toBeNull();

    const inv = await shopService.getMyInventory(userId);
    expect(inv.equippedAvatarImage).toBe('avatar_naruto');
    expect(inv.equippedAvatarFrame).toBeNull();

    const rank = await rankingRepository.getTopRanking('1999-01-04', 5);
    expect(Array.isArray(rank)).toBe(true);

    expect(await shopService.unequip(userId, 'avatar')).toEqual({ slot: 'avatar', equippedKey: null });
    expect((await userRepository.findProfileById(userId)).equipped_avatar_image).toBeNull();
  });

  it('sem pontos suficientes não compra', async () => {
    const userId = await makeUser(499);
    await expect(shopService.purchase(userId, 'avatar_naruto')).rejects.toThrow();
    await expect(shopService.equip(userId, 'avatar_naruto')).rejects.toThrow(/não possui/i);
  });

  it('todo avatar ativo da Loja tem a imagem no frontend (nome do ficheiro = chave) e vice-versa', async () => {
    const dir = path.join(__dirname, '../../frontend/src/assets/avatars');
    const files = fs.readdirSync(dir).filter((f) => f.endsWith('.webp')).map((f) => f.replace(/\.webp$/, ''));
    const { rows } = await db.query(`SELECT key FROM shop_items WHERE key LIKE 'avatar\\_%' AND is_active = TRUE`);
    const keys = rows.map((r) => r.key);
    expect(keys.filter((k) => !files.includes(k))).toEqual([]); // item à venda sem imagem = cartão vazio
    expect(files.filter((f) => !keys.includes(f))).toEqual([]); // imagem sem item = ficheiro esquecido
    expect(keys.length).toBeGreaterThanOrEqual(25);
  });

  it('preços da coleção ficam nas faixas definidas (300, 400 ou 500) e todos são cosméticos', async () => {
    const { rows } = await db.query(`SELECT category, price_points FROM shop_items WHERE key LIKE 'avatar\\_%'`);
    expect(rows.every((r) => r.category === 'cosmetic' && [300, 400, 500].includes(r.price_points))).toBe(true);
  });
});
