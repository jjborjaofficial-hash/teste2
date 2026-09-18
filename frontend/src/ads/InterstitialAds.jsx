import { useEffect, useState } from 'react';
import { adConfig, isFormatActive } from './adConfig';
import { hasAdvertisingConsent } from './adConsent';
import { loadAclib } from './adcashLoader';

/**
 * InterstitialAds — anúncio de tela cheia do Adcash (API confirmada no
 * próprio código-fonte da biblioteca: aclib.runInterstitial({ zoneId })).
 *
 * Regra de negócio explícita: só na tela de Resultado do Quiz (nunca
 * durante a pergunta, nunca sobre o cronômetro ou botão de resposta —
 * este componente só é montado depois que o quiz já foi enviado). E
 * nunca repetir a cada clique: usa `adConfig.minMsBetweenInterstitials`
 * para garantir um intervalo mínimo real entre duas exibições, mesmo
 * que o usuário termine vários quizzes rapidamente em sequência.
 *
 * `onReady`/`onDone` avisam a tela chamadora quando pode liberar o
 * botão de continuar — mas a tela SEMPRE tem seu próprio timeout de
 * segurança (ver QuizResult.jsx), então mesmo que o Adcash falhe ou
 * demore, o usuário nunca fica travado esperando um anúncio.
 */
const LAST_SHOWN_KEY = 'aeg_last_interstitial_at';

function canShowNow() {
  const last = Number(localStorage.getItem(LAST_SHOWN_KEY) || 0);
  return Date.now() - last >= adConfig.minMsBetweenInterstitials;
}

export function InterstitialAds({ onDone }) {
  const [attempted, setAttempted] = useState(false);

  useEffect(() => {
    if (attempted) return;
    setAttempted(true);

    if (!isFormatActive('interstitial') || !hasAdvertisingConsent() || !canShowNow()) {
      onDone?.();
      return;
    }

    const zoneId = adConfig.zones.quizResult;
    if (!zoneId) {
      onDone?.();
      return;
    }

    loadAclib()
      .then((aclib) => {
        localStorage.setItem(LAST_SHOWN_KEY, String(Date.now()));
        aclib.runInterstitial({ zoneId });
      })
      .catch(() => {
        // Sem anúncio, mas o usuário segue normalmente — nunca travar o fluxo.
      })
      .finally(() => {
        onDone?.();
      });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [attempted]);

  return null; // não renderiza nada visível — o Adcash controla a própria UI de tela cheia
}
