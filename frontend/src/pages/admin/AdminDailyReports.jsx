import { useEffect, useState } from 'react';
import { adminApi } from '../../api/adminApi';
import { Card } from '../../components/Card';

/**
 * Painel Administrativo — Relatórios Diários (docx "REDIS CACHE E CRON JOBS",
 * Cron Job 5). Cada linha é gerada automaticamente às 06:00 pelo
 * `generateDailyReport.js`, referente ao dia anterior.
 */
export function AdminDailyReports() {
  const [reports, setReports] = useState(null);

  useEffect(() => {
    adminApi.listDailyReports(30).then((res) => setReports(res.data));
  }, []);

  return (
    <div className="space-y-4">
      <h1 className="font-display text-h1 text-text">Relatórios Diários</h1>
      <p className="text-caption text-text-secondary">
        Gerado automaticamente todos os dias às 06:00, referente ao dia anterior.
      </p>

      {!reports && <p className="text-caption text-text-secondary">Carregando...</p>}
      {reports?.length === 0 && <Card><p className="text-body text-text-secondary">Nenhum relatório gerado ainda.</p></Card>}

      <div className="space-y-3">
        {reports?.map((r) => (
          <Card key={r.id} className="space-y-2">
            <p className="text-body font-semibold text-text">
              {new Date(r.reportDate).toLocaleDateString('pt-MZ', { day: '2-digit', month: 'long', year: 'numeric' })}
            </p>
            <div className="grid grid-cols-2 gap-2 text-caption text-text-secondary">
              <span>Novos usuários: <strong className="text-text">{r.newUsersCount}</strong></span>
              <span>Usuários ativos: <strong className="text-text">{r.activeUsersCount}</strong></span>
              <span>Recompensas distribuídas: <strong className="text-text">{r.totalRewardsDistributedMzn.toFixed(2)} MZN</strong></span>
              <span>Saques: <strong className="text-text">{r.totalWithdrawalsCount} ({r.totalWithdrawalsAmountMzn.toFixed(2)} MZN)</strong></span>
              <span>Atividades suspeitas: <strong className="text-text">{r.suspiciousActivityCount}</strong></span>
              <span>Receita de anúncios: <strong className="text-text">{r.adRevenueMzn === null ? 'Sem integração ainda' : `${r.adRevenueMzn.toFixed(2)} MZN`}</strong></span>
            </div>
          </Card>
        ))}
      </div>
    </div>
  );
}
