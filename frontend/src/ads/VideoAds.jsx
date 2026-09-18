import { useState } from 'react';
import { adConfig, isFormatActive } from './adConfig';
import { hasAdvertisingConsent } from './adConsent';
import { loadAclib } from './adcashLoader';

/**
 * VideoAds — "assistir anúncio para recompensa extra" (Adcash "Video
 * Slider"). Infraestrutura pronta, mas DESATIVADA por padrão
 * (VITE_ADS_VIDEO_ENABLED=false) até:
 *
 *   1) o Zone ID de Video Slider ser criado no painel do Adcash e o
 *      nome exato da função (provavelmente aclib.runVideoSlider, mas
 *      NÃO confirmado com a mesma certeza que runBanner/runPop/
 *      runInterstitial/runInPagePush — verificar o código que o
 *      Adcash fornecer ao criar essa zona específica);
 *   2) existir uma regra de recompensa EXPLÍCITA e validada no
 *      backend para converter "assistiu o anúncio" em algo de valor
 *      (XP, Pontos, ou MZN) — este componente propositalmente NÃO
 *      mexe em saldo/XP/Pontos sozinho. Ele só informa, via
 *      `onAdCompleted`, que o vídeo foi assistido até o fim; a tela
 *      que usa este componente decide o que fazer com essa informação,
 *      e qualquer crédito de MZN precisa passar por um endpoint do
 *      backend que valide a visualização (nunca confiar cegamente no
 *      callback do lado do cliente para dinheiro real — validação de
 *      só-cliente pode ser falsificada).
 *
 * Enquanto isso não existir, este componente não renderiza nada
 * (mesmo que ativado, sem callback de recompensa configurado no lugar
 * de uso, é só um botão que mostra um anúncio sem função).
 */
export function VideoAds({ location = 'video', label = 'Assistir anúncio', onAdCompleted, onAdFailed }) {
  const [loading, setLoading] = useState(false);

  if (!isFormatActive('video') || !adConfig.zones[location]) return null;

  function handleClick() {
    if (!hasAdvertisingConsent()) {
      onAdFailed?.('sem-consentimento');
      return;
    }

    setLoading(true);
    loadAclib()
      .then((aclib) => {
        if (typeof aclib.runVideoSlider !== 'function') {
          // Função ainda não confirmada/disponível para este formato —
          // falhar de forma segura em vez de quebrar a tela.
          onAdFailed?.('formato-indisponivel');
          return;
        }
        aclib.runVideoSlider({
          zoneId: adConfig.zones[location],
          onComplete: () => onAdCompleted?.(),
          onError: () => onAdFailed?.('erro-adcash'),
        });
      })
      .catch(() => onAdFailed?.('falha-carregamento'))
      .finally(() => setLoading(false));
  }

  return (
    <button
      type="button"
      onClick={handleClick}
      disabled={loading}
      className="text-caption text-primary underline disabled:opacity-50"
    >
      {loading ? 'Carregando...' : label}
    </button>
  );
}
