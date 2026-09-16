import { useEffect, useRef, useState } from 'react';
import { socialProofConfig as cfg } from '../config/socialProofConfig';

function randomBetween(min, max) {
  return Math.random() * (max - min) + min;
}

function clamp(value, min, max) {
  return Math.min(Math.max(value, min), max);
}

function easeOutCubic(t) {
  return 1 - (1 - t) ** 3;
}

/**
 * Escolhe o próximo passo do contador com viés de tendência positiva
 * (ver comentário em socialProofConfig.js): a maioria dos passos sobe
 * ou fica estável; quando desce, desce pouco. Isso evita a sensação de
 * "a comunidade está encolhendo", que desmotivaria quem vê a tela.
 */
function proximoPasso() {
  const range = cfg.valorMaximo - cfg.valorMinimo;
  const passoMax = range * cfg.passoMaximoPercentual;
  const isPositivo = Math.random() < cfg.chanceDePassoPositivo;

  if (isPositivo) {
    return randomBetween(0, passoMax);
  }
  return -randomBetween(0, passoMax * cfg.passoNegativoFatorReducao);
}

/**
 * Anima suavemente de `from` até `to` ao longo de `durationMs`,
 * chamando `onUpdate` a cada frame — efeito de "contador subindo/descendo",
 * como visto em dashboards ao vivo reais, em vez de o número trocar de
 * repente. Cancela sozinho se o componente desmontar a meio.
 */
function animateCount(from, to, durationMs, onUpdate) {
  const start = performance.now();
  let frameId;

  function step(now) {
    const elapsed = now - start;
    const t = clamp(elapsed / durationMs, 0, 1);
    const eased = easeOutCubic(t);
    const current = Math.round(from + (to - from) * eased);
    onUpdate(current);

    if (t < 1) {
      frameId = requestAnimationFrame(step);
    }
  }

  frameId = requestAnimationFrame(step);
  return () => cancelAnimationFrame(frameId);
}

/**
 * SocialProofActivity — prova social do Onboarding (tela pós-"Começar")
 * e do Dashboard.
 *
 * Mantém as duas linhas fixas do produto ("12.000+ moçambicanos ativos",
 * "+46.000 MZN distribuídos") e adiciona uma terceira linha com um
 * contador de "ativos agora" que varia de forma convincente: passos
 * pequenos e frequentes (não saltos grandes e raros), com viés de
 * tendência positiva, e uma animação real de contagem (o número sobe/desce
 * visivelmente dígito a dígito, não troca de repente) — pensado para não
 * parecer nem robótico nem "baralhado".
 */
export function SocialProofActivity({ variant = 'card' }) {
  const [displayedCount, setDisplayedCount] = useState(cfg.valorInicial);
  const targetRef = useRef(cfg.valorInicial);
  const timeoutRef = useRef(null);
  const cancelAnimRef = useRef(null);

  useEffect(() => {
    if (!cfg.ativacaoVariacao) return undefined;

    function scheduleNextTick() {
      const delay = randomBetween(cfg.intervaloAtualizacaoMsMin, cfg.intervaloAtualizacaoMsMax);
      timeoutRef.current = setTimeout(() => {
        const novoAlvo = Math.round(
          clamp(targetRef.current + proximoPasso(), cfg.valorMinimo, cfg.valorMaximo)
        );
        const valorAnterior = targetRef.current;
        targetRef.current = novoAlvo;

        if (cancelAnimRef.current) cancelAnimRef.current();
        cancelAnimRef.current = animateCount(valorAnterior, novoAlvo, cfg.duracaoTransicaoMs, setDisplayedCount);

        scheduleNextTick();
      }, delay);
    }

    scheduleNextTick();
    return () => {
      clearTimeout(timeoutRef.current);
      if (cancelAnimRef.current) cancelAnimRef.current();
    };
  }, []);

  const LiveDot = (
    <span className="relative inline-flex h-2 w-2 mr-1.5">
      <span className="animate-live-pulse inline-flex rounded-full h-2 w-2 bg-success" />
    </span>
  );

  const liveCountFormatted = displayedCount.toLocaleString('pt-MZ');

  if (variant === 'compact') {
    return (
      <div className="space-y-0.5">
        <p className="text-body text-gold font-semibold">
          {cfg.totalAtivosTexto}+ ativos • +{cfg.totalRecompensasTexto} distribuídos
        </p>
        <p className="text-caption text-text-secondary flex items-center">
          {LiveDot}
          {liveCountFormatted} utilizadores ativos agora
        </p>
      </div>
    );
  }

  return (
    <>
      <p className="text-body text-gold font-semibold">Mais de {cfg.totalAtivosTexto} moçambicanos ativos</p>
      <p className="text-caption text-gold mb-1.5">+{cfg.totalRecompensasTexto} já distribuídos em recompensas</p>
      <p className="text-caption text-text-secondary flex items-center justify-center">
        {LiveDot}
        {liveCountFormatted} utilizadores ativos agora
      </p>
    </>
  );
}
