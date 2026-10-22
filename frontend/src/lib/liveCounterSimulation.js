/**
 * Simulação do contador "a estudar agora" (SÓ no modo demonstração da prova social; não são dados reais).
 * Pedido do dono (22/10): número entre `min` e `max` que alterna com moderação, nunca salta do nada:
 * passos pequenos e frequentes, quase sempre a subir (+1 a +3), por vezes +10, e de vez em quando a descer (-2, -4).
 * Função pura (o "rand" é injetável) para se poder testar a distribuição sem o navegador.
 */
export const LIVE_DEMO_DEFAULTS = { min: 400, max: 1200 };

const inteiro = (rand, de, ate) => de + Math.floor(rand() * (ate - de + 1));

export function nextLiveStep(current, { min, max } = LIVE_DEMO_DEFAULTS, rand = Math.random) {
  const pos = (current - min) / (max - min);
  // Probabilidade de subir: ~43% no ponto de equilíbrio (60% da faixa), porque as subidas são um pouco maiores que
  // as descidas; abaixo desse ponto sobe mais, acima desce mais. Assim o número alterna à volta do meio da faixa
  // em vez de encostar ao topo ou ao fundo.
  const probSubir = Math.min(0.9, Math.max(0.1, 0.43 + 0.6 * (0.6 - pos)));

  const sobe = rand() < probSubir;
  const r = rand();
  let passo;
  if (sobe) {
    if (r < 0.7) passo = inteiro(rand, 1, 3); // o mais comum: +1, +2, +3
    else if (r < 0.9) passo = inteiro(rand, 4, 6);
    else passo = inteiro(rand, 7, 10); // raro: +10
    return Math.min(max, current + passo);
  }
  passo = r < 0.65 ? inteiro(rand, 1, 2) : inteiro(rand, 3, 4); // descidas pequenas: -1 a -4
  return Math.max(min, current - passo);
}

/** Valor inicial a meio da faixa (entre 20% e 80%), para ter espaço de subir e descer. */
export function initialLiveValue({ min, max } = LIVE_DEMO_DEFAULTS, rand = Math.random) {
  return Math.round(min + (max - min) * (0.2 + rand() * 0.6));
}
