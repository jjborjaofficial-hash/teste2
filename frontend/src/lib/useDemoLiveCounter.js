import { useEffect, useRef, useState } from 'react';
import { initialLiveValue, nextLiveStep, LIVE_DEMO_INTERVAL_MS } from './liveCounterSimulation';

/**
 * Contador "ao vivo" de DEMONSTRAÇÃO. Só corre com `ativo` = true; senão devolve null e não cria timers.
 * A cada ~30 s decide o próximo valor (nextLiveStep, só ±1 ou ±2) e o número "conta" até lá em ~0,8 s (sem saltar),
 * a não ser que a pessoa tenha pedido menos movimento no telemóvel (prefers-reduced-motion).
 */
export function useDemoLiveCounter(ativo, { min, max }) {
  const [valor, setValor] = useState(null);
  const alvo = useRef(null);

  useEffect(() => {
    if (!ativo) return undefined;
    const reduzMovimento = typeof window !== 'undefined'
      && window.matchMedia?.('(prefers-reduced-motion: reduce)').matches;
    let parado = false;
    let timer = null;
    let raf = null;

    alvo.current = initialLiveValue({ min, max });
    setValor(alvo.current);

    const animarAte = (de, para) => {
      if (reduzMovimento || de === para) {
        setValor(para);
        return;
      }
      const inicio = performance.now();
      const duracao = 800;
      const tick = (agora) => {
        if (parado) return;
        const t = Math.min(1, (agora - inicio) / duracao);
        setValor(Math.round(de + (para - de) * t));
        if (t < 1) raf = requestAnimationFrame(tick);
      };
      raf = requestAnimationFrame(tick);
    };

    const agendar = () => {
      timer = setTimeout(() => {
        if (parado) return;
        const de = alvo.current;
        alvo.current = nextLiveStep(de, { min, max });
        animarAte(de, alvo.current);
        agendar();
      }, LIVE_DEMO_INTERVAL_MS.base + Math.random() * LIVE_DEMO_INTERVAL_MS.extra);
    };
    agendar();

    return () => {
      parado = true;
      clearTimeout(timer);
      if (raf) cancelAnimationFrame(raf);
    };
  }, [ativo, min, max]);

  return ativo ? valor : null;
}
