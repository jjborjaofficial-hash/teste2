/**
 * Locais (slots) de anúncio da plataforma e o formato que cabe em cada um. O frontend usa estas mesmas chaves
 * (frontend/src/ads/adConfig.js: dashboard, content, wallet, quizResult, video, popunder, inPagePush).
 */
const SLOTS = [
  { key: 'dashboard', label: 'Início (Painel)', where: 'Ecrã inicial, por baixo do resumo', format: 'banner', size: '300x100' },
  { key: 'content', label: 'Hub de Estudos', where: 'Entre as categorias de estudo', format: 'banner', size: '250x250' },
  { key: 'wallet', label: 'Carteira', where: 'Ecrã da carteira', format: 'banner', size: '300x100' },
  { key: 'quizResult', label: 'Resultado do quiz', where: 'Ao terminar uma rodada (tela cheia, no máximo 1 a cada 90 s)', format: 'interstitial', size: 'tela cheia' },
  { key: 'video', label: 'Vídeo (recompensa)', where: 'Botão "Assistir anúncio" (ainda sem crédito automático)', format: 'video', size: 'vídeo' },
  { key: 'popunder', label: 'Pop-under', where: 'Janela por trás da página (desligado por padrão)', format: 'popunder', size: 'janela' },
  { key: 'inPagePush', label: 'In-page push', where: 'Aviso dentro da página (desligado por padrão)', format: 'inpagepush', size: 'aviso' },
];

// Função do aclib que o código colado tem de chamar, por formato.
const FORMAT_FN = {
  banner: 'runBanner',
  interstitial: 'runInterstitial',
  video: 'runVideoSlider',
  popunder: 'runPop',
  inpagepush: 'runInPagePush',
};

const FORMAT_LABEL = {
  banner: 'Banner',
  interstitial: 'Intersticial (tela cheia)',
  video: 'Vídeo',
  popunder: 'Pop-under',
  inpagepush: 'In-page push',
};

module.exports = { SLOTS, FORMAT_FN, FORMAT_LABEL };
