import { useEffect, useState } from 'react';
import { Link, Navigate } from 'react-router-dom';
import { adminApi } from '../../api/adminApi';
import { Card } from '../../components/Card';

function Stat({ label, value, hint, tone = 'text' }) {
  return (
    <Card className="!p-3">
      <p className="text-caption text-text-secondary">{label}</p>
      <p className={`font-display text-h2 text-${tone} leading-tight`}>{value}</p>
      {hint && <p className="text-caption text-text-secondary">{hint}</p>}
    </Card>
  );
}

const mzn = (n) => `${Number(n || 0).toLocaleString('pt-MZ', { minimumFractionDigits: 2, maximumFractionDigits: 2 })} MZN`;

/** Visão geral do painel: o que precisa de atenção hoje e os números principais. */
export function AdminOverview() {
  const [data, setData] = useState(null);
  const [error, setError] = useState(null);

  useEffect(() => {
    adminApi
      .getOverview()
      .then((res) => setData(res.data))
      .catch((err) => setError(err?.status === 403 ? 'forbidden' : 'Não foi possível carregar a visão geral.'));
  }, []);

  // Papéis sem acesso à visão geral (ex.: jurídico) vão direto à sua área.
  if (error === 'forbidden') return <Navigate to="/admin/legal/documentos" replace />;
  if (error) return <p className="text-danger text-body">{error}</p>;
  if (!data) return <p className="text-text-secondary text-body">Carregando...</p>;

  const pend = data.pendingWithdrawals;
  return (
    <div className="space-y-5">
      <h1 className="font-display text-h1 text-text">Visão geral</h1>

      {pend.count > 0 ? (
        <Link to="/admin/saques" className="block bg-warning/10 border border-warning/30 rounded-card p-4">
          <p className="text-body font-semibold text-warning">
            {pend.count} {pend.count === 1 ? 'saque à espera' : 'saques à espera'} de revisão ({mzn(pend.amountMzn)})
          </p>
          <p className="text-caption text-text-secondary">Toque para abrir os saques.</p>
        </Link>
      ) : (
        <div className="bg-success/10 border border-success/30 rounded-card p-4">
          <p className="text-body font-semibold text-success">Nenhum saque à espera.</p>
        </div>
      )}

      <section>
        <h2 className="font-display text-h2 text-text mb-2">Pessoas</h2>
        <div className="grid grid-cols-2 gap-2">
          <Stat label="Utilizadores" value={data.users.total} tone="primary" />
          <Stat label="Novos (24 h)" value={data.users.new24h} hint={`${data.users.new7d} nos últimos 7 dias`} />
          <Stat label="Ativos (24 h)" value={data.activity.active24h} hint="responderam a quizzes" />
          <Stat label="Respostas (24 h)" value={data.activity.answers24h} />
        </div>
      </section>

      <section>
        <h2 className="font-display text-h2 text-text mb-2">Dinheiro</h2>
        <div className="grid grid-cols-2 gap-2">
          <Stat label="Ganho pelos utilizadores" value={mzn(data.money.creditedMzn)} tone="gold" hint="total creditado" />
          <Stat label="Já pago em saques" value={mzn(data.money.paidMzn)} tone="success" />
          <Stat label="Em saldos (a pagar)" value={mzn(data.money.owedToUsersMzn)} tone="warning" hint="o que a plataforma deve" />
        </div>
      </section>

      <section>
        <h2 className="font-display text-h2 text-text mb-2">Conteúdo</h2>
        <div className="grid grid-cols-2 gap-2">
          <Stat label="Categorias ativas" value={data.content.categories} />
          <Stat label="Perguntas ativas" value={data.content.questions} />
        </div>
      </section>
    </div>
  );
}
