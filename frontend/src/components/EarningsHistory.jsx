import { useEffect, useState } from 'react';
import { Card } from './Card';
import { walletApi } from '../api/gameplayApi';
import { transactionInfo, isEarningSource } from '../lib/walletLabels';

const PAGE_SIZE = 10;

function mzn(v) {
  return `${Number(v).toLocaleString('pt-PT', { minimumFractionDigits: 2, maximumFractionDigits: 2 })} MZN`;
}

/**
 * Histórico de ganhos no Perfil: só créditos de missões, boas-vindas, streak e conversão de pontos,
 * lidos do livro-razão (`GET /wallet/transactions`). Somente leitura — não mexe
 * em saldo nem em regras de dinheiro.
 */
export function EarningsHistory() {
  const [items, setItems] = useState(null);
  const [visible, setVisible] = useState(PAGE_SIZE);

  useEffect(() => {
    walletApi.getRecentTransactions()
      .then((res) => {
        const earnings = (res.data || [])
          .filter((t) => t.type === 'credit' && isEarningSource(t.source))
          .map((t) => ({ ...t, info: transactionInfo(t.source) }));
        setItems(earnings);
      })
      .catch(() => setItems([]));
  }, []);

  if (items === null) return null;

  return (
    <section className="space-y-2">
      <h2 className="font-display text-h2 text-text">Histórico de ganhos</h2>
      {items.length === 0 ? (
        <Card><p className="text-body text-text-secondary">Nenhum ganho ainda. Complete missões para começar.</p></Card>
      ) : (
        <>
          <div className="space-y-2">
            {items.slice(0, visible).map((t) => (
              <Card key={t.id} className="flex items-center justify-between !py-3">
                <div>
                  <p className="text-body text-text">{t.info.label}</p>
                  <p className="text-caption text-text-secondary">
                    {t.info.kind} · {new Date(t.createdAt).toLocaleDateString('pt-PT')}
                  </p>
                </div>
                <span className="font-display font-semibold text-success">+{mzn(t.amountMzn)}</span>
              </Card>
            ))}
          </div>
          {items.length > visible && (
            <button
              type="button"
              onClick={() => setVisible((v) => v + PAGE_SIZE)}
              className="w-full text-caption font-semibold text-primary py-2"
            >
              Ver mais
            </button>
          )}
        </>
      )}
    </section>
  );
}
