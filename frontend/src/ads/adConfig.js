/**
 * Configuração central do AdManager (Adcash — modo "manage ad formats
 * manually", não Autotag, por decisão explícita do produto: controle
 * total de onde cada formato aparece, para não interferir na
 * experiência de aprendizagem/quiz).
 *
 * Tudo aqui vem de variáveis de ambiente (VITE_*, ver .env.example),
 * então ativar/desativar um formato ou trocar um Zone ID não exige
 * mexer em código — só mudar a env var no painel do Render e fazer
 * novo deploy (Vite "queima" essas variáveis no build, mesmo padrão já
 * usado por VITE_API_URL e VITE_FIREBASE_*).
 *
 * Estado inicial (conforme especificação do produto):
 *   - Display: ativo (Dashboard, Hub de Estudos, Carteira)
 *   - Interstitial: ativo, só na tela de Resultado do Quiz
 *   - Video: infraestrutura pronta, mas SEM crédito automático de MZN —
 *     ver nota em VideoAds.jsx
 *   - Pop-Under: DESATIVADO por padrão
 *   - In-Page Push: DESATIVADO por padrão
 *
 * Sem Zone ID configurado para uma localização = essa localização não
 * mostra anúncio nenhum (nunca tenta chamar o Adcash com ID vazio).
 */

function envFlag(value, defaultValue) {
  if (value === undefined || value === '') return defaultValue;
  return value === 'true';
}

export const adConfig = {
  // Interruptor geral — desligar isto desliga tudo, em qualquer formato/local.
  adsEnabled: envFlag(import.meta.env.VITE_ADS_ENABLED, false),

  formats: {
    display: envFlag(import.meta.env.VITE_ADS_DISPLAY_ENABLED, true),
    video: envFlag(import.meta.env.VITE_ADS_VIDEO_ENABLED, false),
    interstitial: envFlag(import.meta.env.VITE_ADS_INTERSTITIAL_ENABLED, true),
    popunder: envFlag(import.meta.env.VITE_ADS_POPUNDER_ENABLED, false),
    inPagePush: envFlag(import.meta.env.VITE_ADS_INPAGEPUSH_ENABLED, false),
  },

  // Zone ID do Adcash por localização. Cada zona criada no painel do
  // Adcash tem o seu próprio ID — nunca reutilizar o mesmo ID em dois
  // locais diferentes (o Adcash usa isso para reportar métricas
  // separadas por posição no site).
  zones: {
    dashboard: import.meta.env.VITE_ADCASH_ZONE_DASHBOARD || '',
    content: import.meta.env.VITE_ADCASH_ZONE_CONTENT || '', // Hub de Estudos (Feed Ad)
    quizResult: import.meta.env.VITE_ADCASH_ZONE_QUIZRESULT || '', // Interstitial
    wallet: import.meta.env.VITE_ADCASH_ZONE_WALLET || '',
    video: import.meta.env.VITE_ADCASH_ZONE_VIDEO || '',
    popunder: import.meta.env.VITE_ADCASH_ZONE_POPUNDER || '',
    inPagePush: import.meta.env.VITE_ADCASH_ZONE_INPAGEPUSH || '',
  },

  // Trava simples contra "mostrar anúncios repetidamente a cada clique"
  // (regra explícita do produto) — aplica-se ao Interstitial, que é o
  // único formato que pode repetir por ação do usuário (terminar vários
  // quizzes seguidos). Tempo mínimo entre dois interstitials, mesmo que
  // o usuário termine quizzes muito rápido um atrás do outro.
  minMsBetweenInterstitials: 90 * 1000,
};

export function isFormatActive(formatKey) {
  return adConfig.adsEnabled && adConfig.formats[formatKey] === true;
}
