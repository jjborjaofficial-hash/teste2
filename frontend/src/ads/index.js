/**
 * AdManager — ponto único de entrada do módulo de anúncios.
 *
 *   AdManager
 *   ├── DisplayAds       (Banner — Dashboard, Hub de Estudos, Carteira)
 *   ├── VideoAds         (Video Slider — "assistir para recompensa", desativado por padrão)
 *   ├── InterstitialAds  (Tela Cheia — só no Resultado do Quiz)
 *   ├── PopUnderAds      (desativado por padrão)
 *   └── InPagePushAds    (desativado por padrão)
 *
 * Isolado de propósito: nada aqui dentro importa ou mexe em lógica de
 * autenticação, quiz, XP, Pontos ou saldo MZN — só o backend, via
 * regras explícitas e validadas, pode alterar saldo/recompensas. Ver
 * adConfig.js para ativar/desativar cada formato e cada local.
 */
export { DisplayAds } from './DisplayAds';
export { VideoAds } from './VideoAds';
export { InterstitialAds } from './InterstitialAds';
export { PopUnderAds } from './PopUnderAds';
export { InPagePushAds } from './InPagePushAds';
export { adConfig, isFormatActive } from './adConfig';
export { hasAdvertisingConsent } from './adConsent';
