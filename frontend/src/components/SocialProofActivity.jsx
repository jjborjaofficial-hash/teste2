import { useEffect, useState } from 'react';
import { platformStatsApi } from '../api/platformStatsApi';
import { maisDe } from '../lib/socialProofMilestones';

/**
 * Prova social do Onboarding e do Dashboard: SÓ dados reais (GET /platform-stats, cache de 2 min no servidor).
 * Mostra "Mais de X", com X = o maior marco (10, 20, 50, 100...) que o valor real já ultrapassou; por isso o texto
 * é sempre verdadeiro e só muda quando a plataforma passa um marco. Substitui os números fixos e o contador
 * simulado de antes (decisão do dono, 22/10).
 */
export function SocialProofActivity({ variant = 'card' }) {
  const [stats, setStats] = useState(null);

  useEffect(() => {
    let cancelled = false;
    platformStatsApi
      .getStats()
      .then((res) => {
        if (!cancelled) setStats(res.data);
      })
      .catch(() => {
        // Prova social é decorativa: se falhar, não aparece nada em vez de mostrar números errados.
      });
    return () => {
      cancelled = true;
    };
  }, []);

  if (!stats) return null;

  const pessoas = maisDe(stats.activeUsersCount ?? 0);
  const mzn = maisDe(Math.floor(stats.totalRewardsDistributedMzn ?? 0));
  const ligados = maisDe(stats.onlineNowCount ?? 0);
  const novos = maisDe(stats.newUsers7dCount ?? 0);
  if (pessoas === null && mzn === null) {
    return <p className="text-body text-gold font-semibold">Plataforma em lançamento</p>;
  }

  const fmt = (n) => n.toLocaleString('pt-MZ');
  const LiveDot = ligados !== null && (
    <span className="relative inline-flex h-2 w-2 mr-1.5">
      <span className="animate-live-pulse inline-flex rounded-full h-2 w-2 bg-success" />
    </span>
  );
  const linhaPessoas = pessoas !== null && `Mais de ${fmt(pessoas)} moçambicanos ligados no Aprenda e Ganha`;
  const linhaMzn = mzn !== null && `Mais de ${fmt(mzn)} MZN já distribuídos em recompensas`;
  // Terceira linha sempre verdadeira: gente a estudar agora, ou (se ainda há pouca) quantos entraram esta semana.
  const linhaAgora = ligados !== null
    ? `Mais de ${fmt(ligados)} a estudar agora`
    : novos !== null && `Mais de ${fmt(novos)} novos esta semana`;

  if (variant === 'compact') {
    return (
      <div className="space-y-0.5">
        {linhaPessoas && <p className="text-body text-gold font-semibold">{linhaPessoas}</p>}
        {linhaMzn && <p className="text-caption text-gold">{linhaMzn}</p>}
        {linhaAgora && (
          <p className="text-caption text-text-secondary flex items-center justify-center">
            {LiveDot}
            {linhaAgora}
          </p>
        )}
      </div>
    );
  }

  return (
    <>
      {linhaPessoas && <p className="text-body text-gold font-semibold">{linhaPessoas}</p>}
      {linhaMzn && <p className="text-caption text-gold mb-1.5">{linhaMzn}</p>}
      {linhaAgora && (
        <p className="text-caption text-text-secondary flex items-center justify-center">
          {LiveDot}
          {linhaAgora}
        </p>
      )}
    </>
  );
}
