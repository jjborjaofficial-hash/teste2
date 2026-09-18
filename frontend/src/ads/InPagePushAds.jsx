import { useEffect } from 'react';
import { adConfig, isFormatActive } from './adConfig';
import { hasAdvertisingConsent } from './adConsent';
import { loadAclib } from './adcashLoader';

/**
 * InPagePushAds — Adcash In-Page Push (API confirmada no código-fonte
 * da biblioteca: aclib.runInPagePush({ zoneId, refreshRate, delay,
 * maxAds, renderPosDesktop, renderPosMobile, offsetTop })).
 *
 * DESATIVADO por padrão (VITE_ADS_INPAGEPUSH_ENABLED=false), por
 * decisão explícita do produto: "até definirmos exatamente a
 * finalidade e o local de utilização". Os parâmetros de renderPos e
 * offsetTop abaixo são valores de exemplo razoáveis (canto inferior,
 * sem sobrepor a navegação inferior fixa da plataforma) — ajustar
 * quando o formato for de fato ativado.
 */
export function InPagePushAds() {
  useEffect(() => {
    if (!isFormatActive('inPagePush') || !hasAdvertisingConsent()) return undefined;

    const zoneId = adConfig.zones.inPagePush;
    if (!zoneId) return undefined;

    let cancelled = false;
    loadAclib()
      .then((aclib) => {
        if (cancelled) return;
        aclib.runInPagePush({
          zoneId,
          renderPosDesktop: 'bottom-right',
          renderPosMobile: 'bottom-right',
          offsetTop: 0,
          maxAds: 1,
        });
      })
      .catch(() => {});

    return () => {
      cancelled = true;
    };
  }, []);

  return null;
}
