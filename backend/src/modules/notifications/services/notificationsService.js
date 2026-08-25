const repository = require('../repositories/notificationsRepository');

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
  return repository.create(executor, {
    userId,
    type: 'withdrawal_status',
    title: titles[status] || 'Atualização do seu saque',
    body: messages[status] || `Status do seu saque atualizado: ${status}.`,
    metadata: { status, amountMzn },
  });
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
};
