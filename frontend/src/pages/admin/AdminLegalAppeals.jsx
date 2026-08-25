import { useEffect, useState } from 'react';
import { adminLegalApi } from '../../api/adminApi';
import { Card } from '../../components/Card';
import { PrimaryButton, SecondaryButton } from '../../components/Button';
import { useToast } from '../../components/Toast';
import { ApiError } from '../../api/client';

const ACTION_LABELS = {
  conta_suspensa: 'Conta suspensa',
  conta_banida: 'Conta banida',
  recompensa_removida: 'Recompensa removida',
  saque_rejeitado: 'Saque rejeitado',
  trust_score_reduzido: 'Trust Score reduzido',
};

const STATUS_LABELS = {
  aberto: 'Aberto',
  em_analise: 'Em análise',
  deferido: 'Deferido',
  indeferido: 'Indeferido',
};

/**
 * Painel Administrativo — Sistema de Recursos e Contestação (docx Parte 12).
 * Uma vez decidido (deferido/indeferido), o recurso não pode ser reaberto por
 * esta tela — reflete a regra de negócio do backend (ConflictError).
 */
function AppealCard({ appeal, onDecided }) {
  const { showToast } = useToast();
  const [decision, setDecision] = useState('');
  const [loading, setLoading] = useState(null);

  async function handleDecide(status) {
    if (decision.trim().length < 3) {
      showToast('Escreva uma justificativa para a decisão.', 'error');
      return;
    }
    setLoading(status);
    try {
      await adminLegalApi.decideAppeal(appeal.id, { status, decision });
      showToast('Recurso decidido.', 'success');
      onDecided?.();
    } catch (err) {
      showToast(err instanceof ApiError ? err.message : 'Não foi possível decidir o recurso.', 'error');
    } finally {
      setLoading(null);
    }
  }

  const isFinal = appeal.status === 'deferido' || appeal.status === 'indeferido';

  return (
    <Card className="space-y-2">
      <div className="flex items-center justify-between">
        <span className="text-body font-semibold text-text">{ACTION_LABELS[appeal.relatedAction]}</span>
        <span className="text-caption text-primary font-semibold">{STATUS_LABELS[appeal.status]}</span>
      </div>
      <p className="text-caption text-text-secondary">
        {appeal.userName} · {appeal.userPhone} · Protocolo {appeal.protocol}
      </p>
      <p className="text-body text-text">{appeal.description}</p>

      {isFinal ? (
        <p className="text-caption text-text-secondary border-t border-border pt-2">
          <strong>Decisão:</strong> {appeal.decision}
        </p>
      ) : (
        <div className="border-t border-border pt-2 space-y-2">
          <textarea
            value={decision}
            onChange={(e) => setDecision(e.target.value)}
            rows={3}
            placeholder="Justificativa da decisão"
            className="w-full rounded-button border border-border bg-background px-3 py-2 text-body text-text"
          />
          <div className="flex gap-2">
            <SecondaryButton
              onClick={() => handleDecide('indeferido')}
              loading={loading === 'indeferido'}
              className="flex-1 !py-2 text-caption"
            >
              Indeferir
            </SecondaryButton>
            <PrimaryButton
              onClick={() => handleDecide('deferido')}
              loading={loading === 'deferido'}
              className="flex-1 !py-2 text-caption"
            >
              Deferir
            </PrimaryButton>
          </div>
        </div>
      )}
    </Card>
  );
}

export function AdminLegalAppeals() {
  const [appeals, setAppeals] = useState(null);
  const [filter, setFilter] = useState('');

  function load() {
    adminLegalApi.listAppeals(filter || undefined).then((res) => setAppeals(res.data));
  }

  useEffect(load, [filter]);

  return (
    <div className="space-y-4">
      <h1 className="font-display text-h1 text-text">Sistema de Recursos e Contestação</h1>

      <select
        value={filter}
        onChange={(e) => setFilter(e.target.value)}
        className="rounded-button border border-border bg-surface px-3 py-2 text-body text-text"
      >
        <option value="">Todos</option>
        {Object.entries(STATUS_LABELS).map(([value, label]) => (
          <option key={value} value={value}>{label}</option>
        ))}
      </select>

      {!appeals && <p className="text-caption text-text-secondary">Carregando...</p>}
      {appeals?.length === 0 && <Card><p className="text-body text-text-secondary">Nenhum recurso encontrado.</p></Card>}

      <div className="space-y-3">
        {appeals?.map((a) => <AppealCard key={a.id} appeal={a} onDecided={load} />)}
      </div>
    </div>
  );
}
