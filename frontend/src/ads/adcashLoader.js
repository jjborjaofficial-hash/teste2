/**
 * Carregador do script `aclib` do Adcash — equivalente funcional de:
 *
 *   <script id="aclib" type="text/javascript" src="//acscdn.com/script/aclib.js"></script>
 *
 * colocado uma única vez no <head>. Aqui a mesma garantia de "só uma
 * vez" é feita via JavaScript (idempotente — vários componentes de
 * anúncio podem chamar isto, só a primeira chamada efetivamente
 * adiciona o script) em vez de uma tag estática, de propósito: assim
 * o script de terceiros só é solicitado quando um anúncio realmente
 * vai aparecer E o usuário já consentiu cookies de publicidade — nunca
 * antes disso, para todo visitante, como uma tag fixa no HTML faria.
 *
 * Devolve uma Promise que resolve quando `window.aclib` estiver
 * disponível para uso.
 *
 * API confirmada do Adcash (suporte oficial, formatos Banner, Pop-Under,
 * Interstitial e In-Page Push): window.aclib.runBanner({ zoneId }),
 * window.aclib.runPop({ zoneId }), window.aclib.runInterstitial({ zoneId }),
 * window.aclib.runInPagePush({ zoneId, ... }).
 */
const ACLIB_SRC = '//acscdn.com/script/aclib.js';

let loadPromise = null;

export function loadAclib() {
  if (typeof window === 'undefined') {
    return Promise.reject(new Error('loadAclib só funciona no navegador'));
  }

  if (window.aclib) {
    return Promise.resolve(window.aclib);
  }

  if (loadPromise) {
    return loadPromise;
  }

  loadPromise = new Promise((resolve, reject) => {
    const existing = document.getElementById('aclib');
    if (existing) {
      existing.addEventListener('load', () => resolve(window.aclib));
      existing.addEventListener('error', () => reject(new Error('Falha ao carregar o script do Adcash.')));
      return;
    }

    const script = document.createElement('script');
    script.id = 'aclib';
    script.type = 'text/javascript';
    script.src = ACLIB_SRC;
    script.async = true;
    script.onload = () => resolve(window.aclib);
    script.onerror = () => reject(new Error('Falha ao carregar o script do Adcash.'));
    document.head.appendChild(script);
  });

  return loadPromise;
}
