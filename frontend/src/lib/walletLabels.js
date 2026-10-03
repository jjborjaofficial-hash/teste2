/**
 * Rótulos amigáveis para as origens (`wallet_transactions.source`) mostradas ao
 * utilizador. Antes a Carteira exibia o nome técnico ("mission reward",
 * "streak milestone 7"). Usado na Carteira e no Histórico de ganhos do Perfil.
 */
const KNOWN = {
  mission_reward: { label: 'Missão diária', kind: 'Missões' },
  welcome_reward: { label: 'Bónus de boas-vindas', kind: 'Boas-vindas' },
  points_conversion: { label: 'Conversão de pontos', kind: 'Pontos' },
  withdrawal_request: { label: 'Saque', kind: 'Saque' },
  shop_purchase: { label: 'Compra na loja', kind: 'Loja' },
  shop: { label: 'Compra na loja', kind: 'Loja' },
};

export function transactionInfo(source) {
  if (KNOWN[source]) return KNOWN[source];
  const streak = /^streak_milestone_(\d+)$/.exec(source || '');
  if (streak) return { label: `Streak de ${streak[1]} dias`, kind: 'Streak' };
  const text = String(source || 'Movimento').replace(/_/g, ' ');
  return { label: text.charAt(0).toUpperCase() + text.slice(1), kind: 'Outros' };
}

/** Origens que contam como "ganho" no Histórico de ganhos do Perfil. */
export function isEarningSource(source) {
  const kind = transactionInfo(source).kind;
  return kind === 'Missões' || kind === 'Boas-vindas' || kind === 'Streak' || kind === 'Pontos';
}
