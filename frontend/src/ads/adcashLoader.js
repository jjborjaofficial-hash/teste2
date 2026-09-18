/**
 * Carregador do script `aclib` do Adcash. Injeta a tag <script> uma
 * única vez na página (idempotente — vários componentes de anúncio
 * podem chamar isto, só a primeira chamada efetivamente adiciona o
 * script), e devolve uma Promise que resolve quando `window.aclib`
 * estiver disponível para uso.
 *
 * API confirmada do Adcash (suporte oficial, formatos Banner e
 * Pop-Under): window.aclib.runBanner({ zoneId }) e
 * window.aclib.runPop({ zoneId }). Para Interstitial/Video/In-Page
 * Push, a Adcash fornece o nome exato da função e o Zone ID quando a
 * zona correspondente é criada no painel — ver comentário em cada
 * componente desse formato.
 */
const ACLIB_SRC = 'https://acscdn.com/script/aclib.js';

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
    const existing = document.querySelector(`script[src="${ACLIB_SRC}"]`);
    if (existing) {
      existing.addEventListener('load', () => resolve(window.aclib));
      existing.addEventListener('error', () => reject(new Error('Falha ao carregar o script do Adcash.')));
      return;
    }

    const script = document.createElement('script');
    script.src = ACLIB_SRC;
    script.async = true;
    script.onload = () => resolve(window.aclib);
    script.onerror = () => reject(new Error('Falha ao carregar o script do Adcash.'));
    document.head.appendChild(script);
  });

  return loadPromise;
}
