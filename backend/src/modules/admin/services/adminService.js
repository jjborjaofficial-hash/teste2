const db = require('../../../config/database');
const repository = require('../repositories/adminRepository');
const auditLogRepository = require('../../../common/repositories/auditLogRepository');
const trustScoreService = require('../../trustscore/services/trustScoreService');
const notificationsService = require('../../notifications/services/notificationsService');
const userCache = require('../../../common/cache/userCache');
const { NotFoundError, ConflictError, BusinessRuleError } = require('../../../common/errors/AppError');

/**
 * Service do Painel Administrativo (Manual Parte 3 — módulo oficial).
 * Toda ação administrativa é auditada em audit_logs, sem exceção (Manual Parte 4).
 *
 * Fluxo de saque alinhado ao documento "Sistema de Saques v1.0":
 *   pending_review -> approved -> paid             (caminho feliz)
 *   pending_review -> rejected                      (recusado, estorna)
 *   pending_review -> suspended_for_review -> ...    (suspeita de fraude, aguarda investigação)
 *   pending_review / suspended_for_review / approved -> cancelled (cancelado, estorna)
 */

function mapWithdrawal(r) {
  return {
    id: r.id,
    userId: r.user_id,
    userName: r.user_name,
    userPhone: r.user_phone,
    amountMzn: Number(r.amount_mzn),
    method: r.method,
    status: r.status,
    trustScoreAtRequest: r.trust_score_at_request,
    requestedAt: r.requested_at,
    resolvedAt: r.resolved_at,
    resolvedByAdminId: r.resolved_by_admin_id,
  };
}

async function listWithdrawals(status, pagination) {
  const rows = await repository.listWithdrawals({ status, ...pagination });
  return rows.map(mapWithdrawal);
}

/**
 * Dossiê completo do pedido (documento "Sistema de Saques v1.0", Seção 5:
 * "Informações Disponíveis ao Administrador").
 */
async function getWithdrawalDetail(withdrawalId) {
  const detail = await repository.getWithdrawalDetail(withdrawalId);
  if (!detail) throw new NotFoundError('Solicitação de saque não encontrada.');

  return {
    id: detail.id,
    amountMzn: Number(detail.amount_mzn),
    method: detail.method,
    status: detail.status,
    trustScoreAtRequest: detail.trust_score_at_request,
    requestedAt: detail.requested_at,
    resolvedAt: detail.resolved_at,
    rejectionReason: detail.rejection_reason,
    resolvedByAdminId: detail.resolved_by_admin_id,
    resolvedByAdminName: detail.resolved_by_admin_name,
    user: {
      id: detail.user_id,
      name: detail.user_name,
      phone: detail.user_phone,
      email: detail.user_email,
      walletBalanceMzn: Number(detail.wallet_balance_mzn),
      trustScore: detail.trust_score,
      accountStatus: detail.account_status,
      accountCreatedAt: detail.account_created_at,
      lastLoginAt: detail.last_login_at,
      alertsCount: detail.alerts_count,
    },
    withdrawalHistory: detail.withdrawal_history.map((h) => ({
      id: h.id,
      amountMzn: Number(h.amount_mzn),
      method: h.method,
      status: h.status,
      requestedAt: h.requested_at,
      resolvedAt: h.resolved_at,
    })),
  };
}

async function approveWithdrawal(withdrawalId, { adminUserId, ipAddress }) {
  const client = await db.getClient();
  try {
    await client.query('BEGIN');

    const withdrawal = await repository.getWithdrawalForUpdate(withdrawalId, client);
    if (!withdrawal) throw new NotFoundError('Solicitação de saque não encontrada.');
    if (withdrawal.status !== 'pending_review') {
      throw new ConflictError(`Esta solicitação já está com status "${withdrawal.status}".`);
    }

    await repository.setWithdrawalStatus(client, {
      withdrawalId,
      status: 'approved',
      resolvedByAdminId: adminUserId,
    });
    await repository.confirmLedgerEntry(client, withdrawal.wallet_transaction_id);

    await notificationsService.notifyWithdrawalStatus(
      client,
      withdrawal.user_id,
      'approved',
      Number(withdrawal.amount_mzn)
    );

    await auditLogRepository.insertAuditLog(client, {
      userId: adminUserId,
      action: 'admin.withdrawal.approved',
      entity: 'withdrawal_requests',
      entityId: withdrawalId,
      metadata: { targetUserId: withdrawal.user_id, amountMzn: Number(withdrawal.amount_mzn) },
      ipAddress,
    });

    await client.query('COMMIT');
    return { id: withdrawalId, status: 'approved' };
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}

async function rejectWithdrawal(withdrawalId, { adminUserId, ipAddress, reason }) {
  if (!reason || !reason.trim()) {
    throw new BusinessRuleError('É obrigatório informar o motivo da rejeição.');
  }

  const client = await db.getClient();
  try {
    await client.query('BEGIN');

    const withdrawal = await repository.getWithdrawalForUpdate(withdrawalId, client);
    if (!withdrawal) throw new NotFoundError('Solicitação de saque não encontrada.');
    if (!['pending_review', 'suspended_for_review'].includes(withdrawal.status)) {
      throw new ConflictError(`Esta solicitação já está com status "${withdrawal.status}".`);
    }

    await repository.setWithdrawalStatus(client, {
      withdrawalId,
      status: 'rejected',
      rejectionReason: reason,
      resolvedByAdminId: adminUserId,
    });
    await repository.reverseLedgerEntry(client, withdrawal.wallet_transaction_id);

    await repository.refundWallet(client, {
      userId: withdrawal.user_id,
      amountMzn: Number(withdrawal.amount_mzn),
      referenceId: withdrawalId,
    });

    await notificationsService.notifyWithdrawalStatus(
      client,
      withdrawal.user_id,
      'rejected',
      Number(withdrawal.amount_mzn)
    );

    await auditLogRepository.insertAuditLog(client, {
      userId: adminUserId,
      action: 'admin.withdrawal.rejected',
      entity: 'withdrawal_requests',
      entityId: withdrawalId,
      metadata: { targetUserId: withdrawal.user_id, amountMzn: Number(withdrawal.amount_mzn), reason },
      ipAddress,
    });

    await client.query('COMMIT');
    await userCache.invalidateProfile(withdrawal.user_id);
    return { id: withdrawalId, status: 'rejected' };
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}

/**
 * Suspende o pedido para investigação manual mais aprofundada (documento
 * "Sistema de Saques v1.0", ação do admin: "Bloquear temporariamente a
 * solicitação em caso de suspeita de fraude"). O valor permanece retido
 * (não é estornado) até o admin decidir aprovar, rejeitar ou cancelar depois.
 */
async function suspendForReview(withdrawalId, { adminUserId, ipAddress, reason }) {
  const client = await db.getClient();
  try {
    await client.query('BEGIN');

    const withdrawal = await repository.getWithdrawalForUpdate(withdrawalId, client);
    if (!withdrawal) throw new NotFoundError('Solicitação de saque não encontrada.');
    if (withdrawal.status !== 'pending_review') {
      throw new ConflictError(`Só é possível suspender um pedido pendente (status atual: "${withdrawal.status}").`);
    }

    await repository.setWithdrawalStatus(client, {
      withdrawalId,
      status: 'suspended_for_review',
      rejectionReason: reason || null,
      resolvedByAdminId: adminUserId,
    });

    await auditLogRepository.insertAuditLog(client, {
      userId: adminUserId,
      action: 'admin.withdrawal.suspended_for_review',
      entity: 'withdrawal_requests',
      entityId: withdrawalId,
      metadata: { targetUserId: withdrawal.user_id, reason },
      ipAddress,
    });

    await client.query('COMMIT');
    return { id: withdrawalId, status: 'suspended_for_review' };
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}

/**
 * Cancela um pedido (documento: status "Cancelado" — diferente de "Rejeitado":
 * aqui não há necessariamente violação de política, pode ser a pedido do
 * próprio usuário via suporte, por exemplo). Estorna o valor, como na rejeição.
 */
async function cancelWithdrawal(withdrawalId, { adminUserId, ipAddress, reason }) {
  const client = await db.getClient();
  try {
    await client.query('BEGIN');

    const withdrawal = await repository.getWithdrawalForUpdate(withdrawalId, client);
    if (!withdrawal) throw new NotFoundError('Solicitação de saque não encontrada.');
    if (!['pending_review', 'suspended_for_review', 'approved'].includes(withdrawal.status)) {
      throw new ConflictError(`Não é possível cancelar um pedido com status "${withdrawal.status}".`);
    }

    await repository.setWithdrawalStatus(client, {
      withdrawalId,
      status: 'cancelled',
      rejectionReason: reason || null,
      resolvedByAdminId: adminUserId,
    });

    await repository.reverseLedgerEntry(client, withdrawal.wallet_transaction_id);

    await repository.refundWallet(client, {
      userId: withdrawal.user_id,
      amountMzn: Number(withdrawal.amount_mzn),
      referenceId: withdrawalId,
    });

    await auditLogRepository.insertAuditLog(client, {
      userId: adminUserId,
      action: 'admin.withdrawal.cancelled',
      entity: 'withdrawal_requests',
      entityId: withdrawalId,
      metadata: { targetUserId: withdrawal.user_id, amountMzn: Number(withdrawal.amount_mzn), reason },
      ipAddress,
    });

    await client.query('COMMIT');
    await userCache.invalidateProfile(withdrawal.user_id);
    return { id: withdrawalId, status: 'cancelled' };
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}

/**
 * Marca um saque já aprovado como pago, depois que o admin financeiro realiza a
 * transferência manual (M-Pesa/e-Mola) para o número já cadastrado do usuário
 * (Seção 16.1 do Doc. Mestre). Fecha o ciclo: pending_review -> approved -> paid.
 */
async function markWithdrawalAsPaid(withdrawalId, { adminUserId, ipAddress }) {
  const client = await db.getClient();
  try {
    await client.query('BEGIN');

    const withdrawal = await repository.getWithdrawalForUpdate(withdrawalId, client);
    if (!withdrawal) throw new NotFoundError('Solicitação de saque não encontrada.');
    if (withdrawal.status !== 'approved') {
      throw new ConflictError(
        `Só é possível marcar como pago um saque já aprovado (status atual: "${withdrawal.status}").`
      );
    }

    await repository.setWithdrawalStatus(client, {
      withdrawalId,
      status: 'paid',
      resolvedByAdminId: adminUserId,
    });

    await notificationsService.notifyWithdrawalStatus(
      client,
      withdrawal.user_id,
      'paid',
      Number(withdrawal.amount_mzn)
    );

    await auditLogRepository.insertAuditLog(client, {
      userId: adminUserId,
      action: 'admin.withdrawal.marked_paid',
      entity: 'withdrawal_requests',
      entityId: withdrawalId,
      metadata: { targetUserId: withdrawal.user_id, amountMzn: Number(withdrawal.amount_mzn) },
      ipAddress,
    });

    await client.query('COMMIT');
    return { id: withdrawalId, status: 'paid' };
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}

async function adjustTrustScore({ targetUserId, delta, reason, adminUserId, ipAddress }) {
  const client = await db.getClient();
  try {
    await client.query('BEGIN');

    const result = await trustScoreService.adjust(client, {
      userId: targetUserId,
      delta,
      reason: trustScoreService.REASONS.MANUAL_ADMIN_ADJUSTMENT,
      metadata: { note: reason, adjustedBy: adminUserId },
    });

    await auditLogRepository.insertAuditLog(client, {
      userId: adminUserId,
      action: 'admin.trust_score.adjusted',
      entity: 'users',
      entityId: targetUserId,
      metadata: { delta, reason, ...result },
      ipAddress,
    });

    await client.query('COMMIT');
    return result;
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}

async function setUserStatus({ targetUserId, status, adminUserId, ipAddress }) {
  const client = await db.getClient();
  try {
    await client.query('BEGIN');

    const updated = await repository.setUserStatus(client, { userId: targetUserId, status });
    if (!updated) throw new NotFoundError('Usuário não encontrado.');

    await auditLogRepository.insertAuditLog(client, {
      userId: adminUserId,
      action: `admin.user.status_changed`,
      entity: 'users',
      entityId: targetUserId,
      metadata: { newStatus: status },
      ipAddress,
    });

    await client.query('COMMIT');
    await userCache.invalidateProfile(targetUserId);
    return updated;
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}

async function setUserRole({ targetUserId, role, adminUserId, ipAddress }) {
  if (targetUserId === adminUserId && role !== 'admin_master') {
    throw new BusinessRuleError('Você não pode remover seu próprio acesso de admin_master.');
  }

  const client = await db.getClient();
  try {
    await client.query('BEGIN');

    const updated = await repository.setUserRole(client, { userId: targetUserId, role });
    if (!updated) throw new NotFoundError('Usuário não encontrado.');

    await auditLogRepository.insertAuditLog(client, {
      userId: adminUserId,
      action: 'admin.user.role_changed',
      entity: 'users',
      entityId: targetUserId,
      metadata: { newRole: role },
      ipAddress,
    });

    await client.query('COMMIT');
    return updated;
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}

async function listUsers(pagination) {
  const rows = await repository.listUsers(pagination);
  return rows.map((u) => ({
    id: u.id,
    name: u.name,
    phone: u.phone,
    status: u.status,
    role: u.role,
    trustScore: u.trust_score,
    walletBalanceMzn: Number(u.wallet_balance_mzn),
    createdAt: u.created_at,
  }));
}

async function listAuditLogs(pagination) {
  const rows = await repository.listAuditLogs(pagination);
  return rows.map((r) => ({
    id: r.id,
    userId: r.user_id,
    action: r.action,
    entity: r.entity,
    entityId: r.entity_id,
    metadata: r.metadata,
    ipAddress: r.ip_address,
    createdAt: r.created_at,
  }));
}

module.exports = {
  listWithdrawals,
  getWithdrawalDetail,
  approveWithdrawal,
  rejectWithdrawal,
  suspendForReview,
  cancelWithdrawal,
  markWithdrawalAsPaid,
  adjustTrustScore,
  setUserStatus,
  setUserRole,
  listUsers,
  listAuditLogs,
};
