import { useEffect, useState } from 'react';
import { platformStatsApi } from '../api/platformStatsApi';
import { maisDe } from '../lib/socialProofMilestones';
import { socialProofConfig } from '../config/socialProofConfig';

/**
 * Prova social do Onboarding e do Dashboard: SÓ dados reais (GET /platform-stats, cache de 2 min no servidor).
 * Mostra "Mais de X", com X = o maior marco (10, 20, 50, 100...) que o valor real já ultrapassou; por isso o texto
 * é sempre verdadeiro e só muda quando a plataforma passa um marco. Substitui os números fixos e o contador
 * simulado de antes (decisão do dono, 22/10).
 *
 * MODO DEMONSTRAÇÃO (pedido do dono, 22/10, projeto ainda não lançado): com VITE_PROVA_SOCIAL_DEMO=true as duas
 * primeiras linhas mostram os números de demonstração de socialProofConfig (pessoas e MZN), só para ver como fica.
 * NÃO são dados reais. ANTES DO LANÇAMENTO: apagar/pôr a false essa variável no Render (frontend) e fazer deploy;
 * a partir daí volta a mostrar só dados reais.
 */
const MODO_DEMO = import.meta.env.VITE_PROVA_SOCIAL_DEMO === 'true';

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

  const pessoas = MODO_DEMO ? socialProofConfig.demoPessoas : maisDe(stats.activeUsersCount ?? 0);
  const mzn = MODO_DEMO ? socialProofConfig.demoMzn : maisDe(Math.floor(stats.totalRewardsDistributedMzn ?? 0));
  const ligados = maisDe(stats.onlineNowCount ?? 0);
  const novos = maisDe(stats.newUsers7dCount ?? 0);
  if (pessoas === null && mzn === null) {
    return <p className="text-body text-gold font-semibold">Plataforma em lançamento</p>;
  }

  // Ponto de milhares sempre (6.000, 22.000): o toLocaleString('pt-MZ') não agrupa os números de 4 dígitos e usa espaço nos maiores.
  const fmt = (n) => String(Math.trunc(n)).replace(/\B(?=(\d{3})+(?!\d))/g, '.');
  const LiveDot = !MODO_DEMO && ligados !== null && (
    <span className="relative inline-flex h-2 w-2 mr-1.5">
      <span className="animate-live-pulse inline-flex rounded-full h-2 w-2 bg-success" />
    </span>
  );
  const linhaPessoas = pessoas !== null && `Mais de ${fmt(pessoas)} moçambicanos ligados no Aprenda e Ganha`;
  const linhaMzn = mzn !== null && `Mais de ${fmt(mzn)} MZN já distribuídos em recompensas`;
  // Terceira linha sempre verdadeira: gente a estudar agora, ou (se ainda há pouca) quantos entraram esta semana.
  // Em modo demonstração a terceira linha mostra os "novos esta semana" de demonstração (não reais).
  const linhaAgora = MODO_DEMO
    ? `Mais de ${fmt(socialProofConfig.demoNovosSemana)} novos esta semana`
    : ligados !== null
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
