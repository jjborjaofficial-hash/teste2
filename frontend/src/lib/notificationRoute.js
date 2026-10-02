/**
 * Para onde levar o utilizador ao tocar numa notificação: o ecrã onde a coisa
 * acontece ou se coleta. Devolve null quando não há destino útil (a notificação
 * só é marcada como lida).
 */
export function notificationRoute(notification) {
  if (!notification) return null;
  const { type, metadata } = notification;

  // Bónus de boas-vindas (guardado como 'system' com metadata.welcomeReward):
  // o valor já foi creditado, então o destino é a carteira.
  if (type === 'system' && metadata?.welcomeReward) return '/carteira';

  switch (type) {
    case 'mission_completed':
      return '/missoes'; // é lá que se resgata a recompensa
    case 'streak_at_risk':
      return '/hub-estudos'; // responder uma pergunta mantém a ofensiva
    case 'milestone_reached':
      return '/perfil'; // resumo da ofensiva
    case 'daily_earning_cap_reached':
    case 'points_converted':
    case 'credit':
    case 'debit':
    case 'withdrawal_requested':
    case 'withdrawal_status':
      return '/carteira';
    case 'item_expiring_soon':
      return '/meus-recursos';
    case 'withdrawal_new_admin':
    case 'withdrawal_sla_risk':
      return '/admin/saques';
    default:
      return null;
  }
}
