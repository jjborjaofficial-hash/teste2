import { useEffect, useState, useCallback } from 'react';
import { Link } from 'react-router-dom';
import { inventoryApi } from '../api/inventoryApi';
import { Card } from '../components/Card';
import { PrimaryButton, SecondaryButton } from '../components/Button';
import { useToast } from '../components/Toast';
import { CountdownTimer } from '../components/CountdownTimer';
import { ApiError } from '../api/client';
import { PointsIcon, ChevronRightIcon } from '../icons';

/**
 * "Meus Recursos" (spec Seções 34-60) — inventário de itens consumíveis
 * (estoque, ex.: Streak Shield) e temporários (contagem regressiva
 * server-authoritative, ex.: Coin Boost). Itens permanentes equipáveis
 * (molduras, selos de prestígio) continuam na Loja/Perfil — este inventário
 * é especificamente para o que tem estoque ou prazo.
 */

const FILTERS = [
  { key: 'all', label: 'Todos' },
  { key: 'active', label: 'Ativos' },
  { key: 'owned', label: 'Disponíveis' },
  { key: 'history', label: 'Histórico' },
];

function statusBadge(status) {
  const map = {
    active: { label: 'Ativo', className: 'bg-success/12 text-success' },
    owned: { label: 'Disponível', className: 'bg-info/12 text-info' },
    expired: { label: 'Expirado', className: 'bg-text-secondary/12 text-text-secondary' },
    used: { label: 'Usado', className: 'bg-text-secondary/12 text-text-secondary' },
  };
  const cfg = map[status] || map.owned;
  return <span className={`text-caption font-semibold px-2 py-0.5 rounded-pill ${cfg.className}`}>{cfg.label}</span>;
}

function ResourceCard({ entry, onChanged }) {
  const { showToast } = useToast();
  const [loading, setLoading] = useState(false);

  async function handleActivate() {
    setLoading(true);
    try {
      const res = await inventoryApi.activate(entry.id);
      showToast(`${res.data.name} ativado! Contagem regressiva iniciada.`, 'success');
      onChanged();
    } catch (err) {
      showToast(err instanceof ApiError ? err.message : 'Não foi possível ativar este item.', 'error');
    } finally {
      setLoading(false);
    }
  }

  async function handleUse() {
    setLoading(true);
    try {
      const res = await inventoryApi.use(entry.id);
      showToast(`${res.data.name} utilizado com sucesso!`, 'success');
      onChanged();
    } catch (err) {
      showToast(err instanceof ApiError ? err.message : 'Não foi possível utilizar este item.', 'error');
    } finally {
      setLoading(false);
    }
  }

  const isTemporary = entry.durationSeconds !== null;
  const isExpiredOrUsed = entry.status === 'expired' || entry.status === 'used';

  return (
    <Card status={entry.status === 'active' ? 'completed' : 'normal'} className={isExpiredOrUsed ? 'opacity-60' : ''}>
      <div className="flex items-start justify-between gap-3">
        <div className="min-w-0">
          <div className="flex items-center gap-2 flex-wrap mb-1">
            <h3 className="text-body font-sans font-semibold text-text truncate">{entry.name}</h3>
            {statusBadge(entry.status)}
          </div>
          <p className="text-caption text-text-secondary mb-2">{entry.description}</p>

          {entry.isConsumable && (
            <p className="text-caption text-text-secondary">
              Quantidade em estoque: <span className="font-semibold text-text">{entry.quantity}</span>
            </p>
          )}

          {isTemporary && entry.status === 'active' && entry.expiresAt && (
            <CountdownTimer expiresAt={entry.expiresAt} onExpire={onChanged} />
          )}

          {isTemporary && entry.status === 'owned' && (
            <p className="text-caption text-text-secondary">
              Dura {Math.round(entry.durationSeconds / 3600)}h a partir da ativação — corre mesmo offline.
            </p>
          )}

          <p className="text-caption text-text-secondary mt-2">
            Origem: {{ shop: 'Loja', mission: 'Missão', event: 'Evento', admin: 'Administração', system: 'Sistema' }[entry.source] || entry.source}
          </p>
        </div>

        <div className="flex-shrink-0">
          {entry.isConsumable && entry.status === 'owned' && entry.quantity > 0 && (
            <PrimaryButton onClick={handleUse} loading={loading}>Usar</PrimaryButton>
          )}
          {isTemporary && entry.status === 'owned' && (
            <PrimaryButton onClick={handleActivate} loading={loading}>Ativar</PrimaryButton>
          )}
        </div>
      </div>
    </Card>
  );
}

export function MeusRecursos() {
  const [entries, setEntries] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [filter, setFilter] = useState('all');
  const { showToast } = useToast();

  const load = useCallback(() => {
    setLoading(true);
    inventoryApi
      .list()
      .then((res) => setEntries(res.data))
      .catch((err) => {
        setError(err instanceof ApiError ? err.message : 'Não foi possível carregar seus recursos.');
      })
      .finally(() => setLoading(false));
  }, []);

  useEffect(() => {
    load();
  }, [load]);

  const filtered = entries.filter((e) => {
    if (filter === 'all') return true;
    if (filter === 'active') return e.status === 'active';
    if (filter === 'owned') return e.status === 'owned';
    if (filter === 'history') return e.status === 'expired' || e.status === 'used';
    return true;
  });

  return (
    <div className="max-w-2xl mx-auto px-4 py-6 pb-24">
      <div className="flex items-center justify-between mb-1">
        <h1 className="text-h1 font-display font-bold text-text">Meus Recursos</h1>
        <PointsIcon className="w-7 h-7" />
      </div>
      <p className="text-body text-text-secondary mb-4">
        Consumíveis e itens temporários que você já possui. Molduras e selos permanentes ficam no{' '}
        <Link to="/perfil" className="text-primary underline">seu Perfil</Link>.
      </p>

      <div className="flex gap-2 overflow-x-auto mb-5 pb-1">
        {FILTERS.map((f) => (
          <button
            key={f.key}
            onClick={() => setFilter(f.key)}
            className={`px-4 py-2 rounded-pill text-caption font-semibold whitespace-nowrap transition-colors ${
              filter === f.key ? 'bg-primary text-white' : 'bg-surface border border-border text-text-secondary'
            }`}
          >
            {f.label}
          </button>
        ))}
      </div>

      {loading && <p className="text-body text-text-secondary">Carregando...</p>}
      {error && <p className="text-body text-danger">{error}</p>}

      {!loading && !error && filtered.length === 0 && (
        <Card className="text-center py-8">
          <p className="text-body text-text-secondary mb-3">
            {filter === 'all'
              ? 'Você ainda não tem nenhum recurso. Que tal dar uma olhada na Loja?'
              : 'Nada por aqui neste filtro.'}
          </p>
          <Link to="/loja">
            <SecondaryButton>
              Ir para a Loja <ChevronRightIcon className="w-4 h-4 inline" />
            </SecondaryButton>
          </Link>
        </Card>
      )}

      <div className="flex flex-col gap-3">
        {filtered.map((entry) => (
          <ResourceCard key={entry.id} entry={entry} onChanged={load} />
        ))}
      </div>
    </div>
  );
}
