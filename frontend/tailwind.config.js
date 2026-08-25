/**
 * Tailwind mapeado 1:1 com o Design System oficial (Doc. Mestre Seção 13).
 * Nenhum valor aqui foi inventado — todos vêm diretamente da especificação:
 * 13.1 Cores, 13.2 Tipografia, 13.3 Grid e Espaçamento.
 *
 * Cores usam variáveis CSS (ver src/index.css) em vez de hex fixo, para
 * suportar o item "Tema Noite" da Loja (docx "SISTEMA DE ECONOMIA E
 * RECOMPENSAS" — loja de personalização) sem duplicar nenhuma classe: trocar
 * o tema é só alternar as variáveis via `[data-theme="night"]`. O formato
 * `rgb(var(--x) / <alpha-value>)` preserva os modificadores de opacidade já
 * usados no código (`bg-gold/10`, `border-primary/30` etc.) — Tailwind
 * substitui `<alpha-value>` automaticamente.
 */
function withOpacity(variable) {
  return `rgb(var(${variable}) / <alpha-value>)`;
}

export default {
  content: ['./index.html', './src/**/*.{js,jsx}'],
  theme: {
    screens: {
      // 13.3: Smartphone até 767px (base), Tablet 768-1023px, Desktop >=1024px
      sm: '768px',
      lg: '1024px',
    },
    extend: {
      colors: {
        primary: withOpacity('--color-primary'),
        secondary: withOpacity('--color-secondary'),
        gold: withOpacity('--color-gold'),
        success: withOpacity('--color-success'),
        danger: withOpacity('--color-danger'),
        warning: withOpacity('--color-warning'),
        info: withOpacity('--color-info'),
        background: withOpacity('--color-background'),
        surface: withOpacity('--color-surface'),
        text: withOpacity('--color-text'),
        'text-secondary': withOpacity('--color-text-secondary'),
        border: withOpacity('--color-border'),
      },
      fontFamily: {
        // 13.2: Inter = fonte principal, Poppins = fonte secundária/display
        sans: ['Inter', 'system-ui', 'sans-serif'],
        display: ['Poppins', 'system-ui', 'sans-serif'],
      },
      fontSize: {
        // 13.2: Escala tipográfica oficial
        caption: ['12px', { lineHeight: '16px', fontWeight: '400' }],
        body: ['14px', { lineHeight: '20px', fontWeight: '400' }],
        button: ['14px', { lineHeight: '20px', fontWeight: '600' }],
        h2: ['19px', { lineHeight: '24px', fontWeight: '600' }],
        h1: ['26px', { lineHeight: '32px', fontWeight: '700' }],
        highlight: ['36px', { lineHeight: '40px', fontWeight: '700' }],
      },
      spacing: {
        // 13.3: escala de espaçamento base 8px
        xs: '4px',
        sm: '8px',
        md: '16px',
        lg: '24px',
        xl: '32px',
        '2xl': '48px',
      },
      borderRadius: {
        button: '10px',
        card: '14px',
      },
      transitionDuration: {
        micro: '150ms',
        xp: '600ms',
      },
    },
  },
  plugins: [],
};
