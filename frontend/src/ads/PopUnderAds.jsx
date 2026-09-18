import { useEffect } from 'react';
import { adConfig, isFormatActive } from './adConfig';
import { hasAdvertisingConsent } from './adConsent';
import { loadAclib } from './adcashLoader';

/**
 * PopUnderAds — Adcash Pop-Under (API confirmada: aclib.runPop({ zoneId })).
 *
 * DESATIVADO por padrão (VITE_ADS_POPUNDER_ENABLED=false), por decisão
 * explícita do produto: "só ativar posteriormente se houver uma razão
 * clara e se os testes mostrarem que não prejudica a experiência".
 * Montar este componente sem ativar o formato não faz nada — é seguro
 * deixar renderizado em qualquer tela sem efeito colateral.
 */
export function PopUnderAds() {
  useEffect(() => {
    if (!isFormatActive('popunder') || !hasAdvertisingConsent()) return undefined;

    const zoneId = adConfig.zones.popunder;
    if (!zoneId) return undefined;

    let cancelled = false;
    loadAclib()
      .then((aclib) => {
        if (!cancelled) aclib.runPop({ zoneId });
      })
      .catch(() => {});

    return () => {
      cancelled = true;
    };
  }, []);

  return null;
}
