import { useEffect, useState } from 'react';
import { adminShopApi } from '../../api/adminApi';
import { Card } from '../../components/Card';
import { PrimaryButton, SecondaryButton } from '../../components/Button';
import { useToast } from '../../components/Toast';
import { ApiError } from '../../api/client';

const CATEGORY_LABELS = { functional: 'Benefício', cosmetic: 'Cosmético', prestige: 'Prestígio' };

/**
 * Painel Administrativo — Loja de Pontos (docx "SISTEMA DE ECONOMIA E
 * RECOMPENSAS", Seção 14: "Moedas: Criar recompensas; Criar loja; Controlar
 * economia"). Preços e status podem ser ajustados aqui sem precisar de deploy.
 */
function ItemRow({ item, onUpdated }) {
  const { showToast } = useToast();
  const [editing, setEditing] = useState(false);
  const [price, setPrice] = useState(item.pricePoints);
  const [loading, setLoading] = useState(false);

  async function handleSavePrice() {
    setLoading(true);
    try {
      await adminShopApi.updateItem(item.id, { pricePoints: Number(price) });
      showToast('Preço atualizado.', 'success');
      setEditing(false);
      onUpdated?.();
    } catch (err) {
      showToast(err instanceof ApiError ? err.message : 'Não foi possível atualizar o preço.', 'error');
    } finally {
      setLoading(false);
    }
  }

  async function handleToggleActive() {
    setLoading(true);
    try {
      await adminShopApi.updateItem(item.id, { isActive: !item.isActive });
      showToast(item.isActive ? 'Item desativado.' : 'Item ativado.', 'success');
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
        <div>
          <p className="text-body font-semibold text-text">{item.name}</p>
          <p className="text-caption text-text-secondary">
            {CATEGORY_LABELS[item.category]} · {item.purchasesCount} compra{item.purchasesCount !== 1 ? 's' : ''}
            {!item.isActive && <span className="text-danger font-semibold"> · Inativo</span>}
          </p>
        </div>
      </div>

      {item.description && <p className="text-caption text-text-secondary">{item.description}</p>}

      <div className="flex items-center gap-2 pt-1">
        {editing ? (
          <>
            <input
              type="number"
              value={price}
              onChange={(e) => setPrice(e.target.value)}
              className="w-24 rounded-button border border-border bg-background px-2 py-1.5 text-body text-text"
            />
            <PrimaryButton onClick={handleSavePrice} loading={loading} className="!py-1.5 !px-3 text-caption">
              Salvar
            </PrimaryButton>
            <SecondaryButton onClick={() => setEditing(false)} className="!py-1.5 !px-3 text-caption">
              Cancelar
            </SecondaryButton>
          </>
        ) : (
          <>
            <span className="text-caption text-gold font-semibold">{item.pricePoints} Pontos</span>
            <SecondaryButton onClick={() => setEditing(true)} className="!py-1.5 !px-3 text-caption">
              Editar preço
            </SecondaryButton>
            <SecondaryButton onClick={handleToggleActive} loading={loading} className="!py-1.5 !px-3 text-caption">
              {item.isActive ? 'Desativar' : 'Ativar'}
            </SecondaryButton>
          </>
        )}
      </div>
    </Card>
  );
}

export function AdminShop() {
  const [items, setItems] = useState(null);
  const [purchases, setPurchases] = useState(null);
  const [tab, setTab] = useState('items');

  function load() {
    adminShopApi.listItems().then((res) => setItems(res.data));
    adminShopApi.listPurchases().then((res) => setPurchases(res.data));
  }

  useEffect(load, []);

  return (
    <div className="space-y-4">
      <h1 className="font-display text-h1 text-text">Loja de Pontos</h1>

      <div className="flex gap-2">
        {[{ key: 'items', label: 'Catálogo' }, { key: 'purchases', label: 'Compras' }].map((t) => (
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

      {tab === 'items' && (
        <div className="space-y-3">
          {!items && <p className="text-caption text-text-secondary">Carregando...</p>}
          {items?.map((item) => <ItemRow key={item.id} item={item} onUpdated={load} />)}
        </div>
      )}

      {tab === 'purchases' && (
        <div className="space-y-2">
          {!purchases && <p className="text-caption text-text-secondary">Carregando...</p>}
          {purchases?.length === 0 && <Card><p className="text-body text-text-secondary">Nenhuma compra ainda.</p></Card>}
          {purchases?.map((p) => (
            <Card key={p.id} className="flex items-center justify-between">
              <div>
                <p className="text-body font-semibold text-text">{p.itemName}</p>
                <p className="text-caption text-text-secondary">{p.userName} · {p.userPhone}</p>
              </div>
              <span className="text-caption text-gold font-semibold">{p.pricePaidPoints} Pontos</span>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
