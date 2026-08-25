import { useEffect, useState } from 'react';
import { adminLegalApi } from '../../api/adminApi';
import { Card } from '../../components/Card';
import { PrimaryButton } from '../../components/Button';
import { useToast } from '../../components/Toast';
import { ApiError } from '../../api/client';

const CATEGORY_LABELS = {
  saques: 'Saques',
  recompensas: 'Recompensas',
  conta_bloqueada: 'Conta bloqueada',
  privacidade: 'Privacidade',
  publicidade: 'Publicidade',
  problemas_tecnicos: 'Problemas técnicos',
  conteudo: 'Conteúdo',
};

const STATUS_OPTIONS = ['em_analise', 'aguardando_usuario', 'resolvida', 'encerrada'];
const STATUS_LABELS = {
  aberta: 'Aberta',
  em_analise: 'Em análise',
  aguardando_usuario: 'Aguardando usuário',
  resolvida: 'Resolvida',
  encerrada: 'Encerrada',
};

function RequestCard({ request, onUpdated }) {
  const { showToast } = useToast();
  const [status, setStatus] = useState('em_analise');
  const [response, setResponse] = useState('');
  const [loading, setLoading] = useState(false);

  async function handleRespond() {
    setLoading(true);
    try {
      await adminLegalApi.respondRequest(request.id, { status, response: response || undefined });
      showToast('Reclamação atualizada.', 'success');
      onUpdated?.();
    } catch (err) {
      showToast(err instanceof ApiError ? err.message : 'Não foi possível atualizar.', 'error');
    } finally {
      setLoading(false);
    }
  }

  return (
    <Card className="space-y-2">
      <div className="flex items-center justify-between">
        <span className="text-body font-semibold text-text">{CATEGORY_LABELS[request.category]}</span>
        <span className="text-caption text-primary font-semibold">{STATUS_LABELS[request.status]}</span>
      </div>
      <p className="text-caption text-text-secondary">{request.userName} · {request.userPhone}</p>
      <p className="text-body text-text">{request.description}</p>

      <div className="border-t border-border pt-2 space-y-2">
        <select
          value={status}
          onChange={(e) => setStatus(e.target.value)}
          className="w-full rounded-button border border-border bg-background px-3 py-2 text-body text-text"
        >
          {STATUS_OPTIONS.map((s) => <option key={s} value={s}>{STATUS_LABELS[s]}</option>)}
        </select>
        <textarea
          value={response}
          onChange={(e) => setResponse(e.target.value)}
          rows={3}
          placeholder="Resposta ao usuário (opcional)"
          className="w-full rounded-button border border-border bg-background px-3 py-2 text-body text-text"
        />
        <PrimaryButton onClick={handleRespond} loading={loading} className="w-full !py-2 text-caption">
          Atualizar
        </PrimaryButton>
      </div>
    </Card>
  );
}

export function AdminLegalRequests() {
  const [requests, setRequests] = useState(null);
  const [filter, setFilter] = useState('');

  function load() {
    adminLegalApi.listRequests(filter || undefined).then((res) => setRequests(res.data));
  }

  useEffect(load, [filter]);

  return (
    <div className="space-y-4">
      <h1 className="font-display text-h1 text-text">Central de Reclamações</h1>

      <select
        value={filter}
        onChange={(e) => setFilter(e.target.value)}
        className="rounded-button border border-border bg-surface px-3 py-2 text-body text-text"
      >
        <option value="">Todas</option>
        {['aberta', ...STATUS_OPTIONS].map((s) => <option key={s} value={s}>{STATUS_LABELS[s]}</option>)}
      </select>

      {!requests && <p className="text-caption text-text-secondary">Carregando...</p>}
      {requests?.length === 0 && <Card><p className="text-body text-text-secondary">Nenhuma reclamação encontrada.</p></Card>}

      <div className="space-y-3">
        {requests?.map((r) => <RequestCard key={r.id} request={r} onUpdated={load} />)}
      </div>
    </div>
  );
}
