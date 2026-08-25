import { useEffect, useState } from 'react';
import { adminApi } from '../../api/adminApi';
import { useToast } from '../../components/Toast';
import { Card } from '../../components/Card';
import { PrimaryButton, SecondaryButton } from '../../components/Button';
import { ApiError } from '../../api/client';

const TABS = [
  { key: 'pending_review', label: 'Pendentes' },
  { key: 'suspended_for_review', label: 'Suspensos p/ revisão' },
  { key: 'approved', label: 'Aguardando transferência' },
  { key: 'paid', label: 'Pagos' },
  { key: 'rejected', label: 'Rejeitados' },
  { key: 'cancelled', label: 'Cancelados' },
];

const STATUS_LABELS = {
  pending_review: 'Em análise',
  approved: 'Aprovado',
  rejected: 'Rejeitado',
  paid: 'Pago',
  cancelled: 'Cancelado',
  suspended_for_review: 'Suspenso para verificação',
};

/**
 * Gestão de Saques (área do admin_financeiro), alinhada ao documento
 * "Sistema de Saques v1.0". Fluxo com 6 estados possíveis e dossiê completo
 * por pedido (Seção 5 do documento: nome, contato, saldo, trust score,
 * histórico de saques, alertas, data de criação da conta, último acesso).
 */
export function AdminWithdrawals() {
  const { showToast } = useToast();
  const [tab, setTab] = useState('pending_review');
  const [withdrawals, setWithdrawals] = useState([]);
  const [loading, setLoading] = useState(true);
  const [busyId, setBusyId] = useState(null);

  const [expandedId, setExpandedId] = useState(null);
  const [detail, setDetail] = useState(null);
  const [detailLoading, setDetailLoading] = useState(false);

  const [actionModal, setActionModal] = useState(null); // { id, action } | null
  const [reason, setReason] = useState('');

  async function load(status = tab) {
    setLoading(true);
    try {
      const res = await adminApi.listWithdrawals(status);
      setWithdrawals(res.data);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => { load(tab); setExpandedId(null); }, [tab]); // eslint-disable-line react-hooks/exhaustive-deps

  async function toggleDetail(id) {
    if (expandedId === id) {
      setExpandedId(null);
      setDetail(null);
      return;
    }
    setExpandedId(id);
    setDetailLoading(true);
    try {
      const res = await adminApi.getWithdrawalDetail(id);
      setDetail(res.data);
    } catch (err) {
      showToast(err instanceof ApiError ? err.message : 'Não foi possível carregar os detalhes.', 'error');
      setExpandedId(null);
    } finally {
      setDetailLoading(false);
    }
  }

  async function runAction(id, action, extra) {
    setBusyId(id);
    try {
      if (action === 'approve') await adminApi.approveWithdrawal(id);
      if (action === 'reject') await adminApi.rejectWithdrawal(id, extra);
      if (action === 'suspend') await adminApi.suspendWithdrawalForReview(id, extra);
      if (action === 'cancel') await adminApi.cancelWithdrawal(id, extra);
      if (action === 'markPaid') await adminApi.markWithdrawalAsPaid(id);

      const messages = {
        approve: 'Saque aprovado. Agora é só transferir manualmente e marcar como pago.',
        reject: 'Saque rejeitado e valor estornado ao usuário.',
        suspend: 'Saque suspenso para revisão manual. O valor continua retido.',
        cancel: 'Saque cancelado e valor estornado ao usuário.',
        markPaid: 'Saque marcado como pago. Usuário notificado.',
      };
      showToast(messages[action], 'success');
      setActionModal(null);
      setReason('');
      await load();
    } catch (err) {
      showToast(err instanceof ApiError ? err.message : 'Não foi possível concluir a ação.', 'error');
    } finally {
      setBusyId(null);
    }
  }

  function openReasonModal(id, action) {
    setActionModal({ id, action });
    setReason('');
  }

  const reasonModalConfig = {
    reject: { title: 'Rejeitar saque', required: true, confirmLabel: 'Confirmar rejeição', danger: true },
    suspend: { title: 'Suspender para revisão', required: false, confirmLabel: 'Confirmar suspensão', danger: false },
    cancel: { title: 'Cancelar saque', required: false, confirmLabel: 'Confirmar cancelamento', danger: true },
  };

  return (
    <div className="space-y-4">
      <h1 className="font-display text-h1 text-text">Saques</h1>

      <div className="flex gap-2 overflow-x-auto pb-1">
        {TABS.map((t) => (
          <button
            key={t.key}
            onClick={() => setTab(t.key)}
            className={`shrink-0 text-caption rounded-button px-3 py-2 border transition-colors duration-micro ${
              tab === t.key ? 'border-primary bg-primary/10 text-primary' : 'border-border text-text-secondary'
            }`}
          >
            {t.label}
          </button>
        ))}
      </div>

      {loading && <p className="text-caption text-text-secondary">Carregando...</p>}
      {!loading && withdrawals.length === 0 && (
        <Card><p className="text-body text-text-secondary">Nenhum saque nesta lista.</p></Card>
      )}

      <div className="space-y-3">
        {withdrawals.map((w) => (
          <Card key={w.id}>
            <div className="flex justify-between items-start mb-2">
              <div>
                <p className="text-body font-semibold text-text">{w.userName}</p>
                <p className="text-caption text-text-secondary">{w.userPhone} · {w.method.toUpperCase()}</p>
              </div>
              <p className="font-display font-semibold text-gold">{w.amountMzn.toFixed(2)} MZN</p>
            </div>
            <p className="text-caption text-text-secondary mb-2">
              Trust Score no pedido: {w.trustScoreAtRequest} · Solicitado em{' '}
              {new Date(w.requestedAt).toLocaleString('pt-MZ')}
            </p>

            <button
              onClick={() => toggleDetail(w.id)}
              className="text-caption text-primary font-semibold mb-3"
            >
              {expandedId === w.id ? 'Ocultar dossiê' : 'Ver dossiê completo'}
            </button>

            {expandedId === w.id && (
              <div className="bg-background rounded-button p-3 mb-3 space-y-2 text-caption">
                {detailLoading && <p className="text-text-secondary">Carregando dossiê...</p>}
                {!detailLoading && detail && (
                  <>
                    <div className="grid grid-cols-2 gap-x-3 gap-y-1">
                      <span className="text-text-secondary">E-mail</span>
                      <span className="text-text">{detail.user.email || 'Não informado'}</span>

                      <span className="text-text-secondary">Saldo atual</span>
                      <span className="text-text">{detail.user.walletBalanceMzn.toFixed(2)} MZN</span>

                      <span className="text-text-secondary">Trust Score atual</span>
                      <span className="text-text">{detail.user.trustScore}</span>

                      <span className="text-text-secondary">Alertas/reduções de confiança</span>
                      <span className="text-text">{detail.user.alertsCount}</span>

                      <span className="text-text-secondary">Situação da conta</span>
                      <span className="text-text">{detail.user.accountStatus}</span>

                      <span className="text-text-secondary">Conta criada em</span>
                      <span className="text-text">
                        {new Date(detail.user.accountCreatedAt).toLocaleDateString('pt-MZ')}
                      </span>

                      <span className="text-text-secondary">Último acesso</span>
                      <span className="text-text">
                        {detail.user.lastLoginAt
                          ? new Date(detail.user.lastLoginAt).toLocaleString('pt-MZ')
                          : 'Nunca'}
                      </span>

                      {detail.resolvedByAdminName && (
                        <>
                          <span className="text-text-secondary">Resolvido por</span>
                          <span className="text-text">{detail.resolvedByAdminName}</span>
                        </>
                      )}

                      {detail.rejectionReason && (
                        <>
                          <span className="text-text-secondary">Motivo registrado</span>
                          <span className="text-text">{detail.rejectionReason}</span>
                        </>
                      )}
                    </div>

                    <div className="pt-2 border-t border-border">
                      <p className="text-text-secondary mb-1">Histórico de saques deste usuário</p>
                      {detail.withdrawalHistory.length === 0 && (
                        <p className="text-text-secondary">Nenhum saque anterior.</p>
                      )}
                      {detail.withdrawalHistory.map((h) => (
                        <div key={h.id} className="flex justify-between text-text">
                          <span>{STATUS_LABELS[h.status] || h.status}</span>
                          <span>{h.amountMzn.toFixed(2)} MZN · {new Date(h.requestedAt).toLocaleDateString('pt-MZ')}</span>
                        </div>
                      ))}
                    </div>
                  </>
                )}
              </div>
            )}

            {tab === 'pending_review' && (
              <div className="grid grid-cols-2 gap-2">
                <PrimaryButton onClick={() => runAction(w.id, 'approve')} loading={busyId === w.id}>
                  Aprovar
                </PrimaryButton>
                <SecondaryButton onClick={() => openReasonModal(w.id, 'reject')}>
                  Rejeitar
                </SecondaryButton>
                <SecondaryButton onClick={() => openReasonModal(w.id, 'suspend')}>
                  Suspender p/ revisão
                </SecondaryButton>
                <SecondaryButton onClick={() => openReasonModal(w.id, 'cancel')}>
                  Cancelar
                </SecondaryButton>
              </div>
            )}

            {tab === 'suspended_for_review' && (
              <div className="grid grid-cols-2 gap-2">
                <SecondaryButton onClick={() => openReasonModal(w.id, 'reject')}>
                  Rejeitar
                </SecondaryButton>
                <SecondaryButton onClick={() => openReasonModal(w.id, 'cancel')}>
                  Cancelar
                </SecondaryButton>
              </div>
            )}

            {tab === 'approved' && (
              <div className="space-y-2">
                <p className="text-caption text-warning bg-warning/10 rounded-button px-3 py-2">
                  Transfira {w.amountMzn.toFixed(2)} MZN manualmente para {w.userPhone} via{' '}
                  {w.method === 'mpesa' ? 'M-Pesa' : 'e-Mola'}. Depois, marque como pago.
                </p>
                <div className="grid grid-cols-2 gap-2">
                  <PrimaryButton onClick={() => runAction(w.id, 'markPaid')} loading={busyId === w.id}>
                    Marcar como pago
                  </PrimaryButton>
                  <SecondaryButton onClick={() => openReasonModal(w.id, 'cancel')}>
                    Cancelar
                  </SecondaryButton>
                </div>
              </div>
            )}

            {['paid', 'rejected', 'cancelled'].includes(tab) && (
              <p className="text-caption text-text-secondary">
                Situação final — nenhuma ação disponível.
              </p>
            )}
          </Card>
        ))}
      </div>

      {actionModal && (
        <div className="fixed inset-0 bg-text/40 z-50 flex items-end sm:items-center justify-center p-4">
          <div className="bg-surface rounded-card p-5 w-full max-w-sm space-y-3">
            <h2 className="font-display text-h2 text-text">{reasonModalConfig[actionModal.action].title}</h2>
            <textarea
              value={reason}
              onChange={(e) => setReason(e.target.value)}
              placeholder={
                reasonModalConfig[actionModal.action].required
                  ? 'Motivo (obrigatório)'
                  : 'Motivo (opcional)'
              }
              rows={3}
              className="w-full rounded-button border border-border bg-background px-3 py-2 text-body text-text focus:border-primary outline-none"
            />
            <div className="flex gap-2">
              <SecondaryButton onClick={() => setActionModal(null)} className="flex-1">
                Cancelar
              </SecondaryButton>
              <PrimaryButton
                onClick={() => {
                  if (reasonModalConfig[actionModal.action].required && !reason.trim()) {
                    showToast('Informe o motivo.', 'error');
                    return;
                  }
                  runAction(actionModal.id, actionModal.action, reason || undefined);
                }}
                loading={busyId === actionModal.id}
                className={`flex-1 ${reasonModalConfig[actionModal.action].danger ? '!bg-danger' : ''}`}
              >
                {reasonModalConfig[actionModal.action].confirmLabel}
              </PrimaryButton>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
