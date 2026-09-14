import { useEffect, useState } from 'react';
import { platformStatsApi } from '../api/platformStatsApi';

/**
 * Prova Social — Doc. Mestre Seção 19.1/19.2.
 *
 * Correção: os números eram fixos no JSX ("12.000+ ativos • 46.000+ MZN
 * distribuídos"), sem relação nenhuma com dados reais. Isso conflita
 * diretamente com a Seção 23 do documento jurídico ("evitar promessas
 * não cumpridas, informações confusas") — a plataforma ainda em fase
 * de teste não tem 12.000 usuários reais.
 *
 * Este componente busca os números reais do backend (GET
 * /platform-stats, cacheado por 2min no Redis) e mostra um indicador
 * pulsante ao lado — não para fingir um número maior, mas para dar a
 * sensação de "isto está vivo e sendo medido agora", que era a intenção
 * original do card. Anima só o ponto (não o número), respeitando
 * prefers-reduced-motion (já tratado globalmente em index.css).
 *
 * Enquanto os números reais ainda são pequenos (plataforma em teste),
 * isso é o esperado e correto — vão crescer organicamente com o uso
 * real, em vez de mostrar uma meta fixa e não verificável.
 */
export function LivePlatformStats({ variant = 'card' }) {
  const [stats, setStats] = useState(null);

  useEffect(() => {
    let cancelled = false;

    platformStatsApi
      .getStats()
      .then((res) => {
        if (!cancelled) setStats(res.data);
      })
      .catch(() => {
        // Falha silenciosa: prova social é decorativa, não deve travar a tela
        // de onboarding/dashboard se o backend estiver indisponível.
      });

    return () => {
      cancelled = true;
    };
  }, []);

  if (!stats) return null;

  const LiveDot = (
    <span className="relative inline-flex h-2 w-2 mr-1.5 align-middle">
      <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-success opacity-75" />
      <span className="relative inline-flex rounded-full h-2 w-2 bg-success" />
    </span>
  );

  const usersFormatted = stats.activeUsersCount.toLocaleString('pt-MZ');
  const rewardsFormatted = stats.totalRewardsDistributedMzn.toLocaleString('pt-MZ');

  if (variant === 'compact') {
    return (
      <p className="text-body text-gold font-semibold">
        {LiveDot}
        {usersFormatted}+ ativos • {rewardsFormatted}+ MZN distribuídos
      </p>
    );
  }

  return (
    <>
      <p className="text-body text-gold font-semibold flex items-center justify-center">
        {LiveDot}
        Mais de {usersFormatted} moçambicanos ativos
      </p>
      <p className="text-caption text-gold">+{rewardsFormatted} MZN já distribuídos em recompensas</p>
    </>
  );
}
