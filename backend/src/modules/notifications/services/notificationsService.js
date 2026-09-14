const repository = require('../repositories/notificationsRepository');
const { enqueueSms } = require('../../../queue/deliveryQueue');
const db = require('../../../config/database');

/**
 * Service de Notificações (Doc. Mestre Seção 9 — Notificações Inteligentes, Seção 6 —
 * Comunicação Humanizada). Outros módulos chamam as funções `notifyX` para gerar
 * notificações consistentes, sem duplicar texto de UX em cada lugar do código.
 */

async function listMyNotifications(userId, pagination) {
  const rows = await repository.listForUser(userId, pagination);
  return rows.map((n) => ({
    id: n.id,
    type: n.type,
    title: n.title,
    body: n.body,
    metadata: n.metadata,
    read: !!n.read_at,
    createdAt: n.created_at,
  }));
}

async function markAsRead(userId, notificationId) {
  return repository.markAsRead(userId, notificationId);
}

async function getUnreadCount(userId) {
  return repository.countUnread(userId);
}

// --- Fábricas de notificação, usadas por outros módulos (gamificação, missões, carteira) ---

async function notifyStreakAtRisk(executor, userId, currentStreakDays) {
  return repository.create(executor, {
    userId,
    type: 'streak_at_risk',
    title: 'Sua ofensiva está em risco!',
    body: `Quase lá! Sua ocorrência de ${currentStreakDays} dias está em risco. Complete um quiz hoje para não perder o progresso.`,
    metadata: { currentStreakDays },
  });
}

async function notifyMilestoneReached(executor, userId, days, reward) {
  return repository.create(executor, {
    userId,
    type: 'milestone_reached',
    title: `Marco de ${days} dias alcançado!`,
    body: 'Parabéns! Você desbloqueou uma recompensa especial pela sua constância.',
    metadata: { days, reward },
  });
}

async function notifyMissionCompleted(executor, userId, missionTitle) {
  return repository.create(executor, {
    userId,
    type: 'mission_completed',
    title: 'Missão concluída!',
    body: `Você completou "${missionTitle}". Resgate sua recompensa na aba de Missões.`,
    metadata: { missionTitle },
  });
}

/**
 * Avisa o usuário quando ele atinge o teto de GANHO diário em dinheiro real
 * (não confundir com teto de saque — Doc. Mestre Seção 16.3, esclarecido em
 * docs/reaceite-termos-e-correcao-regras-saque.md). Antes desta função, o
 * próprio documento registrava essa ausência como limitação conhecida: o
 * usuário só percebia o teto olhando o histórico da Carteira.
 *
 * No máximo uma notificação deste tipo por dia por usuário — chamado a partir
 * de walletService.creditReward, que pode ser acionado várias vezes ao dia
 * pela mesma causa (várias missões/streak creditando na mesma janela).
 */
async function notifyDailyEarningCapReached(executor, userId, dailyCapMzn) {
  const alreadyNotifiedToday = await repository.existsTodayByType(
    userId,
    'daily_earning_cap_reached',
    executor
  );
  if (alreadyNotifiedToday) return null;

  return repository.create(executor, {
    userId,
    type: 'daily_earning_cap_reached',
    title: 'Você atingiu seu teto de ganho hoje',
    body: `Parabéns pelo progresso! Você já ganhou o máximo de ${dailyCapMzn.toFixed(2)} MZN permitido por dia. Volte amanhã para continuar ganhando.`,
    metadata: { dailyCapMzn },
  });
}

/**
 * Confirmação enviada ao usuário logo após converter Pontos em dinheiro real
 * (docx "SISTEMA DE ECONOMIA E RECOMPENSAS", Seção 6.1). Ao contrário do
 * saque, a conversão é instantânea — o dinheiro já cai na carteira na hora.
 */
async function notifyPointsConverted(executor, userId, { pointsAmount, amountMzn }) {
  return repository.create(executor, {
    userId,
    type: 'points_converted',
    title: 'Pontos convertidos em dinheiro!',
    body: `Você converteu ${pointsAmount} Pontos em ${amountMzn.toFixed(2)} MZN. O valor já está disponível na sua Carteira.`,
    metadata: { pointsAmount, amountMzn },
  });
}

/**
 * Aviso proativo de item prestes a expirar (spec "Meus Recursos" Seção 50:
 * "Seu XP Boost expira em 10 minutos"). A spec é explícita: este alerta é só
 * um aviso de conveniência — "não deve impedir o funcionamento da
 * contagem", a expiração acontece de qualquer forma no horário certo,
 * independente do usuário ter visto a notificação ou não.
 */
async function notifyItemExpiringSoon(executor, userId, { itemName, minutesRemaining }) {
  return repository.create(executor, {
    userId,
    type: 'item_expiring_soon',
    title: 'Um item seu está prestes a expirar',
    body: `Seu ${itemName} expira em cerca de ${minutesRemaining} minutos. Aproveite antes que o tempo acabe!`,
    metadata: { itemName, minutesRemaining },
  });
}

async function notifyWithdrawalStatus(executor, userId, status, amountMzn) {
  // Texto de "paid" segue literalmente o documento "Sistema de Saques v1.0"
  // (Seção 9 — "Notificação de Pagamento").
  const messages = {
    approved: `Seu saque de ${amountMzn} MZN foi aprovado e está sendo processado.`,
    rejected: `Seu saque de ${amountMzn} MZN não pôde ser aprovado. Contate o suporte para mais detalhes.`,
    paid:
      `Seu saque no valor de ${amountMzn} MZN foi enviado para a conta cadastrada. ` +
      `Caso o valor não apareça imediatamente, aguarde o tempo de processamento da ` +
      `instituição financeira. Obrigado por utilizar o Aprenda e Ganha.`,
  };
  const titles = {
    approved: 'Atualização do seu saque',
    rejected: 'Atualização do seu saque',
    paid: 'Pagamento realizado com sucesso!',
  };
  const notification = await repository.create(executor, {
    userId,
    type: 'withdrawal_status',
    title: titles[status] || 'Atualização do seu saque',
    body: messages[status] || `Status do seu saque atualizado: ${status}.`,
    metadata: { status, amountMzn },
  });

  // SMS como canal extra só no evento de maior peso (dinheiro de verdade já
  // saiu da plataforma) — não em "approved"/"rejected", para não gastar
  // crédito de SMS em eventos menos críticos (o push+in-app já cobrem esses).
  if (status === 'paid') {
    const { rows } = await (executor || db).query('SELECT phone FROM users WHERE id = $1', [userId]);
    if (rows[0]?.phone) {
      await enqueueSms(rows[0].phone, messages.paid);
    }
  }

  return notification;
}

/**
 * Confirmação imediata ao usuário, no momento em que o saque é solicitado
 * (antes de qualquer aprovação). Texto alinhado literalmente ao documento
 * "Sistema de Saques v1.0" (Seção 2 — "Confirmação ao Usuário"), com o SLA
 * de 24h, já que o pagamento é processado manualmente por um admin.
 */
async function notifyWithdrawalRequested(executor, userId, { amountMzn, method }) {
  return repository.create(executor, {
    userId,
    type: 'withdrawal_requested',
    title: 'Solicitação enviada com sucesso!',
    body:
      `Recebemos seu pedido de saque e ele já está em análise pela nossa equipe. ` +
      `Se todas as informações estiverem corretas e sua solicitação atender às ` +
      `políticas da plataforma, o valor de ${amountMzn} MZN será transferido para a ` +
      `conta cadastrada em até 24 horas. Você poderá acompanhar o andamento na área ` +
      `Carteira > Histórico de Saques. Agradecemos por fazer parte da comunidade Aprenda e Ganha.`,
    metadata: { amountMzn, method },
  });
}

/**
 * Alerta para os admins responsáveis (admin_master + admin_financeiro) sempre
 * que um novo saque é solicitado, já que o pagamento é feito manualmente.
 * Formato alinhado ao documento "Sistema de Saques v1.0" (Seção 4 —
 * "Notificação para o Painel Administrativo").
 */
async function notifyAdminsNewWithdrawal(executor, { withdrawalId, userName, userPhone, amountMzn, method }) {
  const adminIds = await repository.listUserIdsByRoles(['admin_master', 'admin_financeiro'], executor);
  const methodLabel = method === 'mpesa' ? 'M-Pesa' : 'e-Mola';
  const now = new Date();
  const formattedDate = now.toLocaleDateString('pt-MZ');
  const formattedTime = now.toLocaleTimeString('pt-MZ', { hour: '2-digit', minute: '2-digit' });

  const results = [];
  for (const adminId of adminIds) {
    // eslint-disable-next-line no-await-in-loop
    const notification = await repository.create(executor, {
      userId: adminId,
      type: 'withdrawal_new_admin',
      title: 'Novo Pedido de Saque',
      body:
        `O usuário ${userName} (${userPhone}) solicitou um saque de ${amountMzn} MZN via ${methodLabel}. ` +
        `Data: ${formattedDate} às ${formattedTime}. Status: Aguardando análise.`,
      metadata: { withdrawalId, userName, userPhone, amountMzn, method },
    });
    results.push(notification);
  }
  return results;
}

/**
 * Alerta de SLA (docx "REDIS CACHE E CRON JOBS", Cron Job 3): disparado pelo
 * CRON de revalidação de saques quando um pedido pendente ultrapassa o prazo
 * de 24h prometido ao usuário em `notifyWithdrawalRequested`.
 */
async function notifyAdminsWithdrawalSlaRisk(executor, { withdrawalId, userName, userPhone, amountMzn, hoursPending }) {
  const adminIds = await repository.listUserIdsByRoles(['admin_master', 'admin_financeiro'], executor);

  const results = [];
  for (const adminId of adminIds) {
    // eslint-disable-next-line no-await-in-loop
    const notification = await repository.create(executor, {
      userId: adminId,
      type: 'withdrawal_sla_risk',
      title: 'Saque pendente há mais de 24h',
      body:
        `O saque de ${userName} (${userPhone}), no valor de ${amountMzn} MZN, está pendente há ` +
        `${hoursPending}h — acima do prazo de 24h prometido ao usuário. Verifique o quanto antes.`,
      metadata: { withdrawalId, userName, userPhone, amountMzn, hoursPending },
    });
    results.push(notification);
  }
  return results;
}

module.exports = {
  listMyNotifications,
  markAsRead,
  getUnreadCount,
  notifyStreakAtRisk,
  notifyMilestoneReached,
  notifyMissionCompleted,
  notifyWithdrawalStatus,
  notifyWithdrawalRequested,
  notifyAdminsNewWithdrawal,
  notifyAdminsWithdrawalSlaRisk,
  notifyDailyEarningCapReached,
  notifyPointsConverted,
  notifyItemExpiringSoon,
};
