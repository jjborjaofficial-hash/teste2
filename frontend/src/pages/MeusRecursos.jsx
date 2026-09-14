import { useEffect, useState, useCallback, useMemo } from 'react';
import { Link } from 'react-router-dom';
import { inventoryApi } from '../api/inventoryApi';
import { shopApi } from '../api/shopApi';
import { Card } from '../components/Card';
import { PrimaryButton, SecondaryButton } from '../components/Button';
import { useToast } from '../components/Toast';
import { CountdownTimer } from '../components/CountdownTimer';
import { ApiError } from '../api/client';
import { PointsIcon, ChevronRightIcon, BoostIcon, TrustShieldIcon, PaletteIcon, AchievementIcon, GiftIcon } from '../icons';

/**
 * "Meus Recursos" (spec Seções 34-60) — inventário unificado de TUDO que o
 * usuário possui: consumíveis (estoque), temporários (contagem regressiva
 * server-authoritative) E itens permanentes equipáveis (molduras, temas,
 * selos de prestígio) — spec Seção 34: "a página não deve mostrar apenas os
 * itens comprados na Loja".
 */

const STATUS_FILTERS = [
  { key: 'all', label: 'Todos' },
  { key: 'active', label: 'Ativos' },
  { key: 'available', label: 'Disponíveis' },
  { key: 'history', label: 'Histórico' },
];

// Filtros por tipo/categoria (spec Seção 48: "TODOS, ATIVOS, PERMANENTES,
// TEMPORÁRIOS, BOOSTS, PROTEÇÃO, PERSONALIZAÇÃO, COMPETIÇÃO, EVENTOS").
// Antes só existiam como agrupamento visual (ordenar por categoria) — o
// usuário conseguia VER tudo organizado, mas não conseguia ISOLAR uma
// categoria específica. Agora são filtros reais, na mesma barra.
const TYPE_FILTERS = [
  { key: 'permanent', label: 'Permanentes' },
  { key: 'temporary', label: 'Temporários' },
];

const CATEGORY_ICONS = {
  boosts: BoostIcon,
  protecao: TrustShieldIcon,
  personalizacao: PaletteIcon,
  competicao: AchievementIcon,
  eventos: GiftIcon,
};

const CATEGORY_FILTERS = [
  { key: 'boosts', label: 'Boosts' },
  { key: 'protecao', label: 'Proteção' },
  { key: 'personalizacao', label: 'Personalização' },
  { key: 'competicao', label: 'Competição' },
  { key: 'eventos', label: 'Eventos' },
];

const ALL_FILTERS = [...STATUS_FILTERS, ...TYPE_FILTERS, ...CATEGORY_FILTERS];

function isTemporaryEntry(entry) {
  return entry.itemType !== 'permanent' && entry.durationSeconds !== null;
}

const SORT_OPTIONS = [
  { key: 'expiry', label: 'Expiração mais próxima' },
  { key: 'recent', label: 'Mais recentes' },
  { key: 'category', label: 'Categoria' },
  { key: 'rarity', label: 'Raridade' },
  { key: 'name', label: 'Nome' },
];

const RARITY_CLASSNAMES = {
  comum: 'bg-text-secondary/12 text-text-secondary',
  raro: 'bg-info/12 text-info',
  epico: 'bg-primary/12 text-primary',
  lendario: 'bg-gold/12 text-gold',
};

function rarityBadge(rarity) {
  if (!rarity) return null;
  return (
    <span className={`text-caption font-semibold px-2 py-0.5 rounded-pill ${RARITY_CLASSNAMES[rarity.key] || RARITY_CLASSNAMES.comum}`}>
      {rarity.label}
    </span>
  );
}

const ORIGIN_LABELS = {
  shop: 'Loja',
  mission: 'Missão',
  quiz: 'Quiz',
  event: 'Evento',
  campaign: 'Campanha',
  reward: 'Recompensa',
  admin: 'Administração',
  system: 'Sistema',
};

function statusBadge(status) {
  const map = {
    active: { label: 'Ativo', className: 'bg-success/12 text-success' },
    owned: { label: 'Disponível', className: 'bg-info/12 text-info' },
    equipped: { label: 'Equipado', className: 'bg-primary/12 text-primary' },
    unequipped: { label: 'Não equipado', className: 'bg-text-secondary/12 text-text-secondary' },
    expired: { label: 'Expirado', className: 'bg-text-secondary/12 text-text-secondary' },
    used: { label: 'Usado', className: 'bg-text-secondary/12 text-text-secondary' },
  };
  const cfg = map[status] || map.owned;
  return <span className={`text-caption font-semibold px-2 py-0.5 rounded-pill ${cfg.className}`}>{cfg.label}</span>;
}

function formatDateTime(iso) {
  if (!iso) return null;
  return new Date(iso).toLocaleString('pt-MZ', { dateStyle: 'short', timeStyle: 'short' });
}

function ResourceCard({ entry, onChanged, onOpenDetail }) {
  const { showToast } = useToast();
  const [loading, setLoading] = useState(false);

  async function runAction(action, successMessage) {
    setLoading(true);
    try {
      const res = await action();
      showToast(res?.data?.name ? `${res.data.name}: ${successMessage}` : successMessage, 'success');
      onChanged();
    } catch (err) {
      showToast(err instanceof ApiError ? err.message : 'Não foi possível concluir a ação.', 'error');
    } finally {
      setLoading(false);
    }
  }

  const isTemporary = isTemporaryEntry(entry);
  const isExpiredOrUsed = entry.status === 'expired' || entry.status === 'used';

  return (
    <Card status={entry.status === 'active' || entry.status === 'equipped' ? 'completed' : 'normal'} className={isExpiredOrUsed ? 'opacity-60' : ''}>
      <button className="w-full text-left" onClick={() => onOpenDetail(entry)}>
        <div className="flex items-start justify-between gap-3">
          <div className="min-w-0">
            <div className="flex items-center gap-2 flex-wrap mb-1">
              <h3 className="text-body font-sans font-semibold text-text truncate">{entry.name}</h3>
              {statusBadge(entry.status)}
              {rarityBadge(entry.rarity)}
              {entry.itemType === 'permanent' && entry.slot === null && (
                <span className="text-caption font-semibold px-2 py-0.5 rounded-pill bg-gold/12 text-gold">Permanente</span>
              )}
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
              Origem: {ORIGIN_LABELS[entry.source] || entry.source}
            </p>
          </div>
        </div>
      </button>

      <div className="flex justify-end mt-2">
        {entry.isConsumable && entry.status === 'owned' && entry.quantity > 0 && (
          <PrimaryButton onClick={() => runAction(() => inventoryApi.use(entry.id), 'utilizado com sucesso!')} loading={loading}>
            Usar
          </PrimaryButton>
        )}
        {isTemporary && entry.status === 'owned' && (
          <PrimaryButton onClick={() => runAction(() => inventoryApi.activate(entry.id), 'ativado! Contagem regressiva iniciada.')} loading={loading}>
            Ativar
          </PrimaryButton>
        )}
        {entry.itemType === 'permanent' && entry.slot !== null && entry.status === 'unequipped' && (
          <PrimaryButton onClick={() => runAction(() => shopApi.equip(entry.key), 'equipado!')} loading={loading}>
            Equipar
          </PrimaryButton>
        )}
        {entry.itemType === 'permanent' && entry.slot !== null && entry.status === 'equipped' && (
          <SecondaryButton onClick={() => runAction(() => shopApi.unequip(entry.slot), 'removido.')} loading={loading}>
            Desequipar
          </SecondaryButton>
        )}
      </div>
    </Card>
  );
}

function DetailModal({ entry, onClose }) {
  if (!entry) return null;
  const CategoryIcon = CATEGORY_ICONS[entry.displayCategory.key];
  return (
    <div className="fixed inset-0 bg-text/40 z-50 flex items-end sm:items-center justify-center p-4" onClick={onClose}>
      <div className="bg-surface rounded-card p-5 w-full max-w-sm space-y-3" onClick={(e) => e.stopPropagation()}>
        <div className="flex items-center justify-between">
          <h2 className="font-display text-h2 text-text">{entry.name}</h2>
          <div className="flex items-center gap-1.5">
            {rarityBadge(entry.rarity)}
            {statusBadge(entry.status)}
          </div>
        </div>
        <p className="text-body text-text-secondary">{entry.description}</p>

        <dl className="text-caption space-y-1.5 pt-2 border-t border-border">
          <div className="flex justify-between">
            <dt className="text-text-secondary">Categoria</dt>
            <dd className="text-text font-semibold flex items-center gap-1.5">
              {CategoryIcon && <CategoryIcon className="w-4 h-4" />}
              {entry.displayCategory.label}
            </dd>
          </div>
          <div className="flex justify-between">
            <dt className="text-text-secondary">Origem</dt>
            <dd className="text-text font-semibold">{ORIGIN_LABELS[entry.source] || entry.source}</dd>
          </div>
          {entry.activatedAt && (
            <div className="flex justify-between">
              <dt className="text-text-secondary">Ativado em</dt>
              <dd className="text-text font-semibold">{formatDateTime(entry.activatedAt)}</dd>
            </div>
          )}
          {entry.expiresAt && (
            <div className="flex justify-between">
              <dt className="text-text-secondary">Expira em</dt>
              <dd className="text-text font-semibold">{formatDateTime(entry.expiresAt)}</dd>
            </div>
          )}
          {entry.usedAt && (
            <div className="flex justify-between">
              <dt className="text-text-secondary">Usado em</dt>
              <dd className="text-text font-semibold">{formatDateTime(entry.usedAt)}</dd>
            </div>
          )}
          {entry.isConsumable && (
            <div className="flex justify-between">
              <dt className="text-text-secondary">Quantidade</dt>
              <dd className="text-text font-semibold">{entry.quantity}</dd>
            </div>
          )}
        </dl>

        <SecondaryButton onClick={onClose} className="w-full">Fechar</SecondaryButton>
      </div>
    </div>
  );
}

export function MeusRecursos() {
  const [entries, setEntries] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [statusFilter, setStatusFilter] = useState('all');
  const [sort, setSort] = useState('expiry');
  const [detailEntry, setDetailEntry] = useState(null);

  const load = useCallback(() => {
    setLoading(true);
    inventoryApi
      .list(sort)
      .then((res) => setEntries(res.data))
      .catch((err) => {
        setError(err instanceof ApiError ? err.message : 'Não foi possível carregar seus recursos.');
      })
      .finally(() => setLoading(false));
  }, [sort]);

  useEffect(() => {
    load();
  }, [load]);

  const filtered = entries.filter((e) => {
    switch (statusFilter) {
      case 'all':
        return true;
      case 'active':
        return e.status === 'active' || e.status === 'equipped';
      case 'available':
        return e.status === 'owned' || e.status === 'unequipped';
      case 'history':
        return e.status === 'expired' || e.status === 'used';
      case 'permanent':
        return e.itemType === 'permanent';
      case 'temporary':
        return isTemporaryEntry(e);
      case 'boosts':
      case 'protecao':
      case 'personalizacao':
      case 'competicao':
      case 'eventos':
        return e.displayCategory.key === statusFilter;
      default:
        return true;
    }
  });

  // Agrupamento visual por categoria (spec Seção 35) — só faz sentido quando
  // a ordenação não é "expiração" (que já prioriza por urgência, não por grupo).
  const grouped = useMemo(() => {
    if (sort !== 'category') return null;
    const groups = new Map();
    for (const entry of filtered) {
      const key = entry.displayCategory.key;
      if (!groups.has(key)) groups.set(key, { meta: entry.displayCategory, items: [] });
      groups.get(key).items.push(entry);
    }
    return Array.from(groups.values());
  }, [filtered, sort]);

  return (
    <div className="max-w-2xl mx-auto px-4 py-6 pb-24">
      <div className="flex items-center justify-between mb-1">
        <h1 className="text-h1 font-display font-bold text-text">Meus Recursos</h1>
        <PointsIcon className="w-7 h-7" />
      </div>
      <p className="text-body text-text-secondary mb-4">
        Tudo que você já possui na plataforma: boosts, proteções, personalizações e conquistas —
        comprados, ganhos em missões ou eventos.
      </p>

      <div className="flex gap-2 overflow-x-auto mb-3 pb-1">
        {ALL_FILTERS.map((f) => {
          const Icon = CATEGORY_ICONS[f.key];
          return (
            <button
              key={f.key}
              onClick={() => setStatusFilter(f.key)}
              className={`flex items-center gap-1.5 px-4 py-2 rounded-pill text-caption font-semibold whitespace-nowrap transition-colors ${
                statusFilter === f.key ? 'bg-primary text-white' : 'bg-surface border border-border text-text-secondary'
              }`}
            >
              {Icon && <Icon className="w-4 h-4" />}
              {f.label}
            </button>
          );
        })}
      </div>

      <div className="flex items-center gap-2 mb-5">
        <label className="text-caption text-text-secondary">Ordenar por:</label>
        <select
          value={sort}
          onChange={(e) => setSort(e.target.value)}
          className="text-caption rounded-button border border-border bg-surface px-2 py-1.5 text-text"
        >
          {SORT_OPTIONS.map((opt) => (
            <option key={opt.key} value={opt.key}>{opt.label}</option>
          ))}
        </select>
      </div>

      {loading && <p className="text-body text-text-secondary">Carregando...</p>}
      {error && <p className="text-body text-danger">{error}</p>}

      {!loading && !error && filtered.length === 0 && (
        <Card className="text-center py-8">
          <p className="text-body text-text-secondary mb-3">
            {statusFilter === 'all'
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

      {!loading && !error && grouped && (
        <div className="flex flex-col gap-6">
          {grouped.map((group) => {
            const GroupIcon = CATEGORY_ICONS[group.meta.key];
            return (
              <div key={group.meta.key}>
                <h2 className="text-h2 font-display text-text mb-3 flex items-center gap-2">
                  {GroupIcon && <GroupIcon className="w-5 h-5 text-primary" />}
                  {group.meta.label}
                </h2>
                <div className="flex flex-col gap-3">
                  {group.items.map((entry) => (
                    <ResourceCard key={`${entry.itemType}-${entry.id}`} entry={entry} onChanged={load} onOpenDetail={setDetailEntry} />
                  ))}
                </div>
              </div>
            );
          })}
        </div>
      )}

      {!loading && !error && !grouped && (
        <div className="flex flex-col gap-3">
          {filtered.map((entry) => (
            <ResourceCard key={`${entry.itemType}-${entry.id}`} entry={entry} onChanged={load} onOpenDetail={setDetailEntry} />
          ))}
        </div>
      )}

      <DetailModal entry={detailEntry} onClose={() => setDetailEntry(null)} />
    </div>
  );
}
