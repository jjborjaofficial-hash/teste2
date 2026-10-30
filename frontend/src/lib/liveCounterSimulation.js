/**
 * Simulação do contador "a estudar agora" (SÓ no modo demonstração da prova social; não são dados reais).
 * Pedido do dono (30/10): o número fica parado cerca de 30 segundos e, quando muda, muda só 1 ou 2 (nunca salta).
 * Quase sempre sobe e por vezes desce um pouco, para alternar à volta do meio da faixa entre `min` e `max`.
 * Função pura (o "rand" é injetável) para se poder testar a distribuição sem o navegador.
 */
export const LIVE_DEMO_DEFAULTS = { min: 400, max: 1200 };

// Tempo parado entre uma mudança e a seguinte: cerca de 30 s (28 a 32 s).
export const LIVE_DEMO_INTERVAL_MS = { base: 28000, extra: 4000 };

const inteiro = (rand, de, ate) => de + Math.floor(rand() * (ate - de + 1));

export function nextLiveStep(current, { min, max } = LIVE_DEMO_DEFAULTS, rand = Math.random) {
  const pos = (current - min) / (max - min);
  // Probabilidade de subir: 50% no ponto de equilíbrio (60% da faixa); abaixo desse ponto sobe mais, acima desce mais.
  // Assim o número alterna à volta do meio da faixa em vez de encostar ao topo ou ao fundo.
  const probSubir = Math.min(0.9, Math.max(0.1, 0.5 + 0.8 * (0.6 - pos)));
  const passo = inteiro(rand, 1, 2); // só +1/-1 ou +2/-2
  return rand() < probSubir ? Math.min(max, current + passo) : Math.max(min, current - passo);
}

/** Valor inicial a meio da faixa (entre 20% e 80%), para ter espaço de subir e descer. */
export function initialLiveValue({ min, max } = LIVE_DEMO_DEFAULTS, rand = Math.random) {
  return Math.round(min + (max - min) * (0.2 + rand() * 0.6));
}
