/**
 * Raridade dos itens da Loja/Inventário (spec "Meus Recursos" Seção 57).
 *
 * DECISÃO DE NEGÓCIO — aprovada explicitamente pelo proprietário do projeto
 * (não inventada): a raridade é CALCULADA a partir de dois dados que já
 * existem em `shop_items` (preço em Pontos e a existência de um requisito de
 * jogo para comprar), em vez de um campo manual por item. Vantagem: todo
 * item novo criado pelo Painel Admin já nasce com raridade correta, sem
 * ninguém precisar lembrar de classificá-lo à mão.
 *
 * Faixas aprovadas (em Pontos):
 *   < 100                          → Comum
 *   100 a 199                      → Raro
 *   200 a 499, OU tem eligibility_rule → Épico
 *   >= 500                         → Lendário (sempre, mesmo com eligibility_rule)
 *
 * Validado manualmente contra todo o catálogo seedado até a migration 026:
 * Streak Shield (60) e Proteção de Streak (80) → Comum; Coin Boost (100) e
 * as 5 molduras por categoria (120) e Moldura de Chama (150) → Raro; Tema
 * Noite (200), Recuperar Streak (200), Moldura de Campeão (250) e Selo Top
 * 10 (300, com eligibility_rule) → Épico; Selo Lenda dos 100 Dias (500, com
 * eligibility_rule) → Lendário — que é literalmente descrito no seed como
 * "o selo mais raro da plataforma".
 */

const RARITY_TIERS = {
  comum: { key: 'comum', label: 'Comum', order: 0, colorToken: 'text-secondary' },
  raro: { key: 'raro', label: 'Raro', order: 1, colorToken: 'info' },
  epico: { key: 'epico', label: 'Épico', order: 2, colorToken: 'primary' },
  lendario: { key: 'lendario', label: 'Lendário', order: 3, colorToken: 'gold' },
};

function resolveRarity(pricePoints, eligibilityRule) {
  const price = Number(pricePoints) || 0;

  if (price >= 500) return RARITY_TIERS.lendario;
  if (eligibilityRule) return RARITY_TIERS.epico;
  if (price >= 200) return RARITY_TIERS.epico;
  if (price >= 100) return RARITY_TIERS.raro;
  return RARITY_TIERS.comum;
}

module.exports = { resolveRarity, RARITY_TIERS };
