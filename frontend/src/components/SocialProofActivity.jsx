import { useEffect, useRef, useState } from 'react';
import { socialProofConfig as cfg } from '../config/socialProofConfig';

function randomBetween(min, max) {
  return Math.random() * (max - min) + min;
}

function clamp(value, min, max) {
  return Math.min(Math.max(value, min), max);
}

/**
 * SocialProofActivity — prova social do Onboarding (tela pós-"Começar")
 * e do Dashboard.
 *
 * Mantém as duas linhas fixas do produto ("12.000+ moçambicanos ativos",
 * "+46.000 MZN distribuídos") e adiciona uma terceira linha com um
 * contador de "ativos agora" que varia suavemente dentro dos limites de
 * socialProofConfig.js, com um indicador pulsante ao lado — sensação de
 * atividade contínua. Nesta primeira versão o número é simulado
 * localmente (ver comentário em socialProofConfig.js sobre a conexão
 * futura com dados reais).
 */
export function SocialProofActivity({ variant = 'card' }) {
  const [liveCount, setLiveCount] = useState(cfg.valorInicial);
  const timeoutRef = useRef(null);

  useEffect(() => {
    if (!cfg.ativacaoVariacao) return undefined;

    function scheduleNextTick() {
      const delay = randomBetween(cfg.intervaloAtualizacaoMsMin, cfg.intervaloAtualizacaoMsMax);
      timeoutRef.current = setTimeout(() => {
        setLiveCount((prev) => {
          const range = cfg.valorMaximo - cfg.valorMinimo;
          const maxStep = range * cfg.passoMaximoPercentual;
          const step = randomBetween(-maxStep, maxStep);
          return Math.round(clamp(prev + step, cfg.valorMinimo, cfg.valorMaximo));
        });
        scheduleNextTick();
      }, delay);
    }

    scheduleNextTick();
    return () => clearTimeout(timeoutRef.current);
  }, []);

  const LiveDot = (
    <span className="relative inline-flex h-2 w-2 mr-1.5">
      <span className="animate-live-pulse inline-flex rounded-full h-2 w-2 bg-success" />
    </span>
  );

  const liveCountFormatted = liveCount.toLocaleString('pt-MZ');

  if (variant === 'compact') {
    return (
      <div className="space-y-0.5">
        <p className="text-body text-gold font-semibold">
          {cfg.totalAtivosTexto}+ ativos • +{cfg.totalRecompensasTexto} distribuídos
        </p>
        <p
          className="text-caption text-text-secondary flex items-center transition-opacity"
          style={{ transitionDuration: `${cfg.duracaoTransicaoMs}ms` }}
        >
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
      <p
        className="text-caption text-text-secondary flex items-center justify-center transition-opacity"
        style={{ transitionDuration: `${cfg.duracaoTransicaoMs}ms` }}
      >
        {LiveDot}
        {liveCountFormatted} utilizadores ativos agora
      </p>
    </>
  );
}
