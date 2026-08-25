/**
 * Sistema de Ícones (Doc. Mestre Seção 13.5 + 13.6).
 * Regras de construção seguidas à risca: SVG inline; apenas
 * path/circle/rect/line/polyline/polygon; stroke 5-6; linecap e linejoin round;
 * viewBox 64; sem preenchimento por padrão. Cor e escala (hover/ativo) são
 * controladas via `className` pelo componente pai.
 *
 * Cada ícone abaixo aceita props opcionais que ligam a animação específica da
 * Seção 13.6 (tabela "Animações com Significado") — desligada por padrão onde
 * faz sentido ser condicional (ex: só anima quando algo realmente aconteceu),
 * e sempre ativa onde a tabela pede loop contínuo (ex: chama do streak).
 */
const base = {
  viewBox: '0 0 64 64',
  fill: 'none',
  strokeWidth: 5.5,
  strokeLinecap: 'round',
  strokeLinejoin: 'round',
};

export function HomeIcon({ className = '' }) {
  return (
    <svg {...base} className={className} stroke="currentColor">
      <polyline points="10,30 32,12 54,30" />
      <path d="M16,26 V52 H48 V26" />
      <line x1="28" y1="52" x2="28" y2="38" />
      <line x1="36" y1="52" x2="36" y2="38" />
      <line x1="28" y1="45" x2="36" y2="45" />
    </svg>
  );
}

export function ProfileIcon({ className = '' }) {
  return (
    <svg {...base} className={className} stroke="currentColor">
      <circle cx="32" cy="24" r="12" />
      <path d="M10,54 C10,40 20,34 32,34 C44,34 54,40 54,54" />
    </svg>
  );
}

export function QuizIcon({ className = '' }) {
  return (
    <svg {...base} className={className} stroke="currentColor">
      <rect x="10" y="10" width="44" height="44" rx="10" />
      <path d="M25,26 a7,7 0 1 1 9,7 c-2,1.5 -2,3 -2,5" />
      <line x1="32" y1="44" x2="32" y2="44.5" />
    </svg>
  );
}

/**
 * XP: "Preenchimento sobe ao ganhar XP; rotação ao completar nível" (13.6).
 * `pulse` = acabou de ganhar XP (pulso curto). `levelUp` = subiu de nível
 * (rotação completa). As duas nunca tocam ao mesmo tempo por padrão de uso.
 */
export function XpIcon({ className = '', pulse = false, levelUp = false }) {
  const animClass = levelUp ? 'animate-level-up' : pulse ? 'animate-xp-gain' : '';
  return (
    <svg {...base} className={`${className} ${animClass}`} stroke="currentColor">
      <polygon points="32,8 39,25 58,25 43,36 49,54 32,43 15,54 21,36 6,25 25,25" />
    </svg>
  );
}

/**
 * Ranking: "Barras crescem em stagger ao abrir" (13.6). Sempre ativo ao montar
 * — o pódio "abrindo" é o próprio carregamento da tela de Ranking.
 */
export function RankingIcon({ className = '', animateIn = true }) {
  return (
    <svg
      {...base}
      className={`${className} ${animateIn ? 'animate-bar-grow' : ''}`}
      stroke="currentColor"
    >
      <rect x="8" y="34" width="14" height="20" />
      <rect x="25" y="20" width="14" height="34" />
      <rect x="42" y="28" width="14" height="26" />
    </svg>
  );
}

/**
 * Carteira: "Impulso (scale) ao receber novo valor" (13.6). `impulse=true`
 * quando o componente pai acabou de detectar um crédito novo.
 */
export function WalletIcon({ className = '', impulse = false }) {
  return (
    <svg
      {...base}
      className={`${className} ${impulse ? 'animate-wallet-impulse' : ''}`}
      stroke="currentColor"
    >
      <rect x="8" y="16" width="48" height="34" rx="6" />
      <path d="M8,26 H56" />
      <circle cx="42" cy="38" r="4" />
    </svg>
  );
}

/**
 * Missões: "Pulso leve quando há missão nova" (13.6). `hasNew` liga um pulso
 * suave em loop enquanto houver missão pendente de atenção.
 */
export function MissionsIcon({ className = '', hasNew = false }) {
  return (
    <svg
      {...base}
      className={`${className} ${hasNew ? 'animate-mission-pulse' : ''}`}
      stroke="currentColor"
    >
      <line x1="16" y1="8" x2="16" y2="56" />
      <path d="M16,10 H46 L38,20 L46,30 H16" />
    </svg>
  );
}

/**
 * Notificações: "Balanço leve + badge pop-in" (13.6). `hasUnread` liga o
 * balanço (reaproveita .animate-swing); o badge pop-in fica a cargo de quem
 * desenha o pontinho de contagem (ver Dashboard.jsx e AdminLayout.jsx).
 */
export function NotificationIcon({ className = '', hasUnread = false }) {
  return (
    <svg
      {...base}
      className={`${className} ${hasUnread ? 'animate-swing' : ''}`}
      stroke="currentColor"
    >
      <path d="M18,28 a14,14 0 0 1 28,0 c0,12 5,16 5,16 h-38 s5,-4 5,-16" />
      <path d="M27,50 a5,5 0 0 0 10,0" />
    </svg>
  );
}

/**
 * Trust Score: "Preenchimento sobe conforme score; transição sempre suave"
 * (13.6). Como a Seção 13.5 proíbe expor o valor exato publicamente, o
 * preenchimento aqui reflete a FAIXA qualitativa (badge), não o número —
 * mesmo princípio já aplicado em TrustScoreController.scoreToBadge no backend.
 */
const TRUST_FILL_BY_BADGE = {
  restricted: 0.15,
  under_review: 0.45,
  in_good_standing: 0.75,
  verified_trusted: 1,
};

export function TrustShieldIcon({ className = '', badge = null }) {
  const fillRatio = badge ? TRUST_FILL_BY_BADGE[badge] ?? 0 : 0;
  return (
    <svg {...base} className={className} stroke="currentColor">
      <path d="M32,8 L54,16 V30 C54,44 44,52 32,56 C20,52 10,44 10,30 V16 Z" />
      {badge && (
        <path
          className="trust-fill-transition"
          d="M32,8 L54,16 V30 C54,44 44,52 32,56 C20,52 10,44 10,30 V16 Z"
          fill="currentColor"
          fillOpacity="0.18"
          stroke="none"
          style={{
            clipPath: `inset(${(1 - fillRatio) * 100}% 0 0 0)`,
          }}
        />
      )}
      <polyline points="23,32 29,38 41,24" />
    </svg>
  );
}

/**
 * Pontos: Doc. Mestre Seção 5 — "Economia de Duas Moedas": Pontos (moeda soft,
 * uso corriqueiro) é DIFERENTE de XP (experiência que define nível). Antes
 * desta correção, Pontos não tinha nenhuma identidade visual própria no app,
 * apesar de existir no banco de dados e na API desde o início.
 * Desenho: moeda com aro interno e uma marca central — deliberadamente
 * diferente do raio/estrela do XpIcon, para não serem confundidos.
 */
export function PointsIcon({ className = '', pulse = false }) {
  return (
    <svg
      {...base}
      className={`${className} ${pulse ? 'animate-xp-gain' : ''}`}
      stroke="currentColor"
    >
      <circle cx="32" cy="32" r="22" />
      <circle cx="32" cy="32" r="14" />
      <path d="M32,24 L36,32 L32,40 L28,32 Z" />
    </svg>
  );
}

/**
 * Conquistas/Medalhas: ficha técnica da Seção 13.5 ("Medalha com fita"),
 * que faltava — as outras 11 famílias de ícone já existiam, esta não.
 * Animação (Seção 13.6): "Confete leve + brilho pulsante" — reaproveita as
 * mesmas classes CSS já usadas em RewardBadge, agora também disponíveis
 * diretamente no ícone quando ele é exibido sozinho (fora do badge de texto).
 */
export function AchievementIcon({ className = '', isNew = false }) {
  return (
    <svg
      {...base}
      className={`${className} ${isNew ? 'animate-pop-in animate-glow-pulse' : ''}`}
      stroke="currentColor"
    >
      <path d="M22,8 H42 L38,24 H26 Z" />
      <circle cx="32" cy="38" r="16" />
      <polygon points="32,29 35,36 42,36 36,40 38,47 32,43 26,47 28,40 22,36 29,36" />
    </svg>
  );
}

export function ShopIcon({ className = '' }) {
  return (
    <svg {...base} className={className} stroke="currentColor">
      <path d="M16,22 H48 L45,54 H19 Z" />
      <path d="M24,22 C24,14 27,9 32,9 C37,9 40,14 40,22" />
    </svg>
  );
}

/**
 * Convites/Indicações: duas silhuetas ligadas por uma linha, representando o
 * vínculo entre quem indica e quem foi indicado (não fazia parte da ficha
 * técnica original de 12 ícones — adicionado seguindo as mesmas regras da
 * Seção 13.5: apenas path/circle, stroke 5-6, viewBox 64, sem preenchimento).
 */
export function InviteIcon({ className = '' }) {
  return (
    <svg {...base} className={className} stroke="currentColor">
      <circle cx="22" cy="20" r="8" />
      <path d="M10,50 C10,39 15,33 22,33 C29,33 34,39 34,50" />
      <circle cx="46" cy="26" r="6.5" />
      <path d="M36,50 C36,42 40,37 46,37 C52,37 56,42 56,48" />
    </svg>
  );
}

/**
 * Configurações: "Rotação suave só durante o toque, sem loop" (13.6).
 * `spinKey` deve mudar (ex: incrementar um contador) a cada toque, disparando
 * a animação de rotação uma única vez, sem loop contínuo.
 */
export function SettingsIcon({ className = '', spinKey = 0 }) {
  return (
    <svg
      key={spinKey}
      {...base}
      className={`${className} ${spinKey > 0 ? 'animate-rotate-once' : ''}`}
      stroke="currentColor"
    >
      <circle cx="32" cy="32" r="8" />
      <path d="M32,10 V16 M32,48 V54 M54,32 H48 M16,32 H10 M46,18 L42,22 M22,42 L18,46 M46,46 L42,42 M22,22 L18,18" />
    </svg>
  );
}

export function ChevronRightIcon({ className = '' }) {
  return (
    <svg {...base} className={className} stroke="currentColor">
      <polyline points="24,12 44,32 24,52" />
    </svg>
  );
}

export function CloseIcon({ className = '' }) {
  return (
    <svg {...base} className={className} stroke="currentColor">
      <line x1="16" y1="16" x2="48" y2="48" />
      <line x1="48" y1="16" x2="16" y2="48" />
    </svg>
  );
}

/**
 * Quiz: "Check desenha-se no acerto" (13.6). `animated` usa pathLength=1 para
 * que o traço sempre desenhe de 0% a 100%, independente da geometria real.
 */
export function CheckIcon({ className = '', animated = false }) {
  return (
    <svg {...base} className={className} stroke="currentColor">
      <polyline
        points="14,34 26,46 50,18"
        pathLength={animated ? 1 : undefined}
        className={animated ? 'animate-draw' : ''}
      />
    </svg>
  );
}

/**
 * Quiz: "X desenha-se em vermelho suave no erro" (13.6). A cor "vermelho
 * suave" é responsabilidade do `className` do chamador (usar text-danger,
 * nunca um vermelho puro — Seção 13.1: --danger é sempre suave).
 */
export function CloseDrawIcon({ className = '', animated = false }) {
  return (
    <svg {...base} className={className} stroke="currentColor">
      <line
        x1="16" y1="16" x2="48" y2="48"
        pathLength={animated ? 1 : undefined}
        className={animated ? 'animate-draw' : ''}
      />
      <line
        x1="48" y1="16" x2="16" y2="48"
        pathLength={animated ? 1 : undefined}
        className={animated ? 'animate-draw' : ''}
        style={animated ? { animationDelay: '0.15s' } : undefined}
      />
    </svg>
  );
}

/**
 * Streak (Ofensiva): "Chama oscila, loop suave" (13.6). Sempre ativo — é o
 * comportamento padrão do ícone sempre que ele está em tela.
 */
export function FireIcon({ className = '', animate = true }) {
  return (
    <svg
      {...base}
      className={`${className} ${animate ? 'animate-flame' : ''}`}
      stroke="currentColor"
    >
      <path d="M32,8 C40,20 46,26 46,36 A14,14 0 1 1 18,36 C18,32 20,30 22,28 C22,34 26,36 28,34 C24,26 28,16 32,8 Z" />
    </svg>
  );
}
