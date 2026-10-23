import { useEffect, useState } from 'react';
import { api } from '../api/client';
import { adConfig } from './adConfig';

/**
 * Configuração dos anúncios vinda do painel admin (GET /ads/config, pública): interruptor geral e Zone ID por local.
 * Quando carrega, passa a mandar sobre as variáveis de ambiente (que ficam só como reserva se o pedido falhar).
 * VITE_ADS_ENABLED=false continua a ser o interruptor de emergência: desliga tudo, seja o que for que o painel diga.
 */
const SLOT_FORMAT = {
  dashboard: 'display',
  content: 'display',
  wallet: 'display',
  quizResult: 'interstitial',
  video: 'video',
  popunder: 'popunder',
  inPagePush: 'inPagePush',
};

let loaded = false;
const listeners = new Set();

function apply(data) {
  const killSwitch = import.meta.env.VITE_ADS_ENABLED === 'false';
  adConfig.adsEnabled = !killSwitch && data.masterEnabled === true;
  adConfig.zones = { ...data.zones };
  const hasZone = (fmt) => Object.keys(SLOT_FORMAT).some((k) => SLOT_FORMAT[k] === fmt && data.zones[k]);
  Object.keys(adConfig.formats).forEach((fmt) => {
    adConfig.formats[fmt] = hasZone(fmt);
  });
  loaded = true;
  listeners.forEach((fn) => fn());
}

export const adsConfigReady = new Promise((resolve) => {
  api
    .get('/ads/config', { auth: false })
    .then((res) => apply(res.data))
    .catch(() => {
      // Sem resposta: ficam as variáveis de ambiente (por padrão, anúncios desligados).
    })
    .finally(resolve);
});

/** Faz o componente voltar a desenhar quando a configuração chega. */
export function useAdsRemoteConfig() {
  const [, setTick] = useState(0);
  useEffect(() => {
    if (loaded) setTick((t) => t + 1);
    const fn = () => setTick((t) => t + 1);
    listeners.add(fn);
    return () => listeners.delete(fn);
  }, []);
  return loaded;
}
