import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { shopApi } from '../api/shopApi';
import { Card } from '../components/Card';
import { PrimaryButton, SecondaryButton } from '../components/Button';
import { useToast } from '../components/Toast';
import { ApiError } from '../api/client';
import { PointsIcon, ShopIcon, CheckIcon } from '../icons';

/**
 * Loja de Pontos (docx "SISTEMA DE ECONOMIA E RECOMPENSAS", Seção 3 — "sink de
 * economia"). Antes desta tela, Pontos eram acumulados sem nenhum destino de
 * uso. Catálogo definido em conversa com o proprietário do projeto: itens
 * funcionais (reaproveitam mecânicas já existentes), cosméticos (identidade
 * visual) e de prestígio (status, com pré-requisito) — nunca nada que acelere
 * XP ou dinheiro real diretamente.
 */

const CATEGORY_LABELS = {
  functional: 'Benefícios',
  cosmetic: 'Personalização',
  prestige: 'Prestígio',
};

const CATEGORY_ORDER = ['functional', 'cosmetic', 'prestige'];

function ItemCard({ item, equippedKeys, onChanged }) {
  const { showToast } = useToast();
  const { refreshProfile } = useAuth();
  const [loading, setLoading] = useState(false);

  const isOwned = !!item.owned;
  const isEquipped = equippedKeys.includes(item.key);
  const isBlocked = item.eligible === false;

  async function handlePurchase() {
    setLoading(true);
    try {
      const res = await shopApi.purchase(item.key);
      showToast(`${item.name} adquirido! Você ficou com ${res.data.newPointsBalance} Pontos.`, 'success');
      await refreshProfile();
      onChanged?.();
    } catch (err) {
      showToast(err instanceof ApiError ? err.message : 'Não foi possível concluir a compra.', 'error');
    } finally {
      setLoading(false);
    }
  }

  async function handleEquipToggle() {
    setLoading(true);
    try {
      if (isEquipped) {
        const slot = item.key.startsWith('theme_') ? 'theme' : 'frame';
        await shopApi.unequip(slot);
        showToast('Item removido.', 'success');
      } else {
        await shopApi.equip(item.key);
        showToast(`${item.name} equipado!`, 'success');
      }
      await refreshProfile();
      onChanged?.();
    } catch (err) {
      showToast(err instanceof ApiError ? err.message : 'Não foi possível atualizar.', 'error');
    } finally {
      setLoading(false);
    }
  }

  return (
    <Card status={isEquipped ? 'completed' : 'normal'} className="space-y-2">
      <div className="flex items-start justify-between gap-2">
        <div className="flex-1">
          <p className="text-body font-semibold text-text">{item.name}</p>
          {item.description && <p className="text-caption text-text-secondary mt-0.5">{item.description}</p>}
        </div>
        {isEquipped && <CheckIcon className="w-5 h-5 text-success shrink-0" />}
      </div>

      <div className="flex items-center justify-between pt-1">
        <span className="flex items-center gap-1 text-caption font-semibold text-gold">
          <PointsIcon className="w-4 h-4" />
          {item.pricePoints} Pontos
        </span>

        {item.category === 'functional' && (
          <PrimaryButton onClick={handlePurchase} loading={loading} disabled={isBlocked} className="!py-1.5 !px-4 text-caption">
            Comprar
          </PrimaryButton>
        )}

        {(item.category === 'cosmetic') && (
          isOwned ? (
            <SecondaryButton onClick={handleEquipToggle} loading={loading} className="!py-1.5 !px-4 text-caption">
              {isEquipped ? 'Remover' : 'Equipar'}
            </SecondaryButton>
          ) : (
            <PrimaryButton onClick={handlePurchase} loading={loading} disabled={isBlocked} className="!py-1.5 !px-4 text-caption">
              Comprar
            </PrimaryButton>
          )
        )}

        {item.category === 'prestige' && (
          isOwned ? (
            <span className="text-caption text-success font-semibold">Adquirido</span>
          ) : (
            <PrimaryButton onClick={handlePurchase} loading={loading} disabled={isBlocked} className="!py-1.5 !px-4 text-caption">
              Comprar
            </PrimaryButton>
          )
        )}
      </div>

      {isBlocked && item.eligibilityReason && (
        <p className="text-caption text-warning">{item.eligibilityReason}</p>
      )}
    </Card>
  );
}

const SOURCE_LABELS = {
  mission_reward: 'Recompensa de missão',
  streak_milestone_7: 'Marco de streak: 7 dias',
  streak_milestone_15: 'Marco de streak: 15 dias',
  streak_milestone_30: 'Marco de streak: 30 dias',
  streak_milestone_100: 'Marco de streak: 100 dias',
  referral_reward: 'Indicação qualificada',
  shop_purchase: 'Compra na Loja',
};

function LedgerEntry({ entry }) {
  const isCredit = entry.type === 'credit';
  return (
    <div className="flex items-center justify-between py-2 border-b border-border last:border-0">
      <div>
        <p className="text-body text-text">{SOURCE_LABELS[entry.source] || entry.source}</p>
        <p className="text-caption text-text-secondary">
          {new Date(entry.createdAt).toLocaleDateString('pt-MZ', { day: '2-digit', month: 'short', hour: '2-digit', minute: '2-digit' })}
        </p>
      </div>
      <span className={`font-display font-semibold ${isCredit ? 'text-success' : 'text-danger'}`}>
        {isCredit ? '+' : '−'}{entry.amountPoints}
      </span>
    </div>
  );
}

function PointsLedger() {
  const [ledger, setLedger] = useState(null);

  useEffect(() => {
    shopApi.getPointsLedger().then((res) => setLedger(res.data)).catch(() => setLedger([]));
  }, []);

  if (ledger === null) return <p className="text-caption text-text-secondary">Carregando extrato...</p>;
  if (ledger.length === 0) return <Card><p className="text-body text-text-secondary">Nenhuma movimentação de Pontos ainda.</p></Card>;

  return (
    <Card>
      {ledger.map((entry) => <LedgerEntry key={entry.id} entry={entry} />)}
    </Card>
  );
}

export function Shop() {
  const { user } = useAuth();
  const [items, setItems] = useState(null);
  const [inventory, setInventory] = useState(null);
  const [error, setError] = useState(false);
  const [tab, setTab] = useState('loja');

  function load() {
    shopApi.listItems().then((res) => setItems(res.data)).catch(() => setError(true));
    shopApi.getInventory().then((res) => setInventory(res.data)).catch(() => {});
  }

  useEffect(load, []);

  const equippedKeys = [inventory?.equippedAvatarFrame, inventory?.equippedTheme].filter(Boolean);

  return (
    <div className="space-y-4 pb-4">
      <header className="pt-2 flex items-center justify-between">
        <div className="flex items-center gap-2">
          <ShopIcon className="w-6 h-6 text-primary" />
          <h1 className="font-display text-h1 text-text">Loja</h1>
        </div>
        <span className="flex items-center gap-1.5 bg-gold/10 text-gold font-semibold px-3 py-1.5 rounded-full text-caption">
          <PointsIcon className="w-4 h-4" />
          {user?.pointsBalance ?? 0} Pontos
        </span>
      </header>

      <div className="flex gap-2">
        {[{ key: 'loja', label: 'Loja' }, { key: 'extrato', label: 'Extrato de Pontos' }].map((t) => (
          <button
            key={t.key}
            onClick={() => setTab(t.key)}
            className={`px-3 py-1.5 rounded-full text-caption font-semibold transition-colors duration-micro ${
              tab === t.key ? 'bg-primary text-white' : 'bg-surface border border-border text-text-secondary'
            }`}
          >
            {t.label}
          </button>
        ))}
      </div>

      {tab === 'loja' && (
        <>
          {error && <p className="text-danger text-body">Não foi possível carregar a loja agora.</p>}
          {!error && items === null && <p className="text-caption text-text-secondary">Carregando itens...</p>}

          {CATEGORY_ORDER.map((category) => {
            const categoryItems = items?.filter((i) => i.category === category) ?? [];
            if (categoryItems.length === 0) return null;
            return (
              <div key={category} className="space-y-2">
                <h2 className="text-caption font-semibold text-text-secondary uppercase tracking-wide">
                  {CATEGORY_LABELS[category]}
                </h2>
                <div className="space-y-3">
                  {categoryItems.map((item) => (
                    <ItemCard key={item.key} item={item} equippedKeys={equippedKeys} onChanged={load} />
                  ))}
                </div>
              </div>
            );
          })}
        </>
      )}

      {tab === 'extrato' && <PointsLedger />}

      <Link to="/perfil" className="block text-center text-caption text-primary font-semibold pt-2">
        ← Voltar ao Perfil
      </Link>
    </div>
  );
}
