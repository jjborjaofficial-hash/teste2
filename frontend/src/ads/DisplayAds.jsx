import { useEffect, useRef } from 'react';
import { adConfig, isFormatActive } from './adConfig';
import { hasAdvertisingConsent } from './adConsent';
import { loadAclib } from './adcashLoader';

/**
 * DisplayAds — banner/display do Adcash (API confirmada:
 * aclib.runBanner({ zoneId, id })). Usado nas localizações "dashboard",
 * "content" (Hub de Estudos) e "wallet".
 *
 * Se ads estiverem desativados globalmente, o formato "display"
 * estiver desativado, o usuário não tiver consentido cookies de
 * publicidade, ou não houver Zone ID configurado para esta localização
 * — não renderiza nada (sem erro, sem espaço vazio estranho).
 */
export function DisplayAds({ location, className = '' }) {
  const containerRef = useRef(null);
  const containerId = `aeg-display-ad-${location}`;

  useEffect(() => {
    if (!isFormatActive('display')) return;
    if (!hasAdvertisingConsent()) return;

    const zoneId = adConfig.zones[location];
    if (!zoneId) return;

    let cancelled = false;
    loadAclib()
      .then((aclib) => {
        if (cancelled || !aclib) return;
        aclib.runBanner({ zoneId, id: containerId });
      })
      .catch(() => {
        // Falha ao carregar o anúncio nunca deve quebrar a página —
        // o usuário só não vê o banner, e a plataforma segue normal.
      });

    return () => {
      cancelled = true;
    };
  }, [location, containerId]);

  if (!isFormatActive('display') || !adConfig.zones[location]) return null;

  return <div id={containerId} ref={containerRef} className={className} />;
}
