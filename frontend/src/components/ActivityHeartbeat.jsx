import { useEffect, useRef } from 'react';
import { missionsApi } from '../api/gameplayApi';
import { useToast } from './Toast';

const HEARTBEAT_INTERVAL_MS = 30000;

/**
 * Heartbeat de atividade para a missão "12 minutos de estudo".
 *
 * Só envia um sinal a cada 30s enquanto a aba está VISÍVEL. O tempo em si é
 * calculado pelo servidor (o cliente não manda nenhum valor de tempo), então
 * deixar a aba aberta em segundo plano ou adulterar o relógio não ajuda.
 * Quando a missão já foi concluída (ou não existe hoje), para de enviar até
 * o próximo dia / recarregamento da página.
 */
export function ActivityHeartbeat() {
  const { showToast } = useToast();
  const stoppedRef = useRef(false);

  useEffect(() => {
    let cancelled = false;

    async function beat() {
      if (stoppedRef.current || document.visibilityState !== 'visible') return;
      try {
        const res = await missionsApi.heartbeat();
        if (cancelled) return;
        if (res.data.justCompleted) {
          showToast('Missão concluída: 12 minutos de estudo! Resgate a recompensa em Missões.', 'success');
        }
        if (!res.data.tracking) stoppedRef.current = true;
      } catch {
        // Falha de rede não pode atrapalhar a experiência: tenta de novo no próximo ciclo.
      }
    }

    beat();
    const interval = setInterval(beat, HEARTBEAT_INTERVAL_MS);
    return () => {
      cancelled = true;
      clearInterval(interval);
    };
  }, [showToast]);

  return null;
}
