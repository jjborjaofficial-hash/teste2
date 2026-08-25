import { useEffect, useState } from 'react';

/**
 * Contagem regressiva "Meus Recursos" (spec Seção 38): a fonte de verdade é
 * sempre `expiresAt`, um timestamp absoluto vindo do servidor. O componente
 * só faz a subtração local (expiresAt - agora) a cada segundo para exibição
 * — nunca decide sozinho se o item ainda é válido (isso é sempre revalidado
 * pelo backend na hora de ativar/usar). Continua contando corretamente
 * mesmo que o usuário feche e reabra a aba, porque não depende de nenhum
 * estado local persistido — só do timestamp absoluto (spec Seção 39).
 */
export function CountdownTimer({ expiresAt, onExpire, className = '' }) {
  const [remainingMs, setRemainingMs] = useState(() => new Date(expiresAt).getTime() - Date.now());

  useEffect(() => {
    const target = new Date(expiresAt).getTime();
    const tick = () => {
      const remaining = target - Date.now();
      setRemainingMs(remaining);
      if (remaining <= 0) {
        onExpire?.();
      }
    };
    tick();
    const interval = setInterval(tick, 1000);
    return () => clearInterval(interval);
  }, [expiresAt, onExpire]);

  if (remainingMs <= 0) {
    return <span className={`text-text-secondary ${className}`}>Expirado</span>;
  }

  const totalSeconds = Math.floor(remainingMs / 1000);
  const hours = Math.floor(totalSeconds / 3600);
  const minutes = Math.floor((totalSeconds % 3600) / 60);
  const seconds = totalSeconds % 60;

  const label =
    hours > 0
      ? `${hours}h ${String(minutes).padStart(2, '0')}m restantes`
      : `${minutes}m ${String(seconds).padStart(2, '0')}s restantes`;

  return <span className={`font-display font-semibold text-warning ${className}`}>{label}</span>;
}
