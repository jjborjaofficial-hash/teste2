/**
 * Botão Primário (Doc. Mestre Seção 13.4).
 * Normal: fundo --primary, texto branco, radius 10px, padding 12px 20px.
 * Hover: escurece + elevação leve, transição 0.15s. Ativo: escala 0.97.
 * Desabilitado: opacidade 45%. Foco: outline 2px --primary, offset 2px (global em index.css).
 */
export function PrimaryButton({ children, onClick, type = 'button', disabled = false, loading = false, className = '' }) {
  return (
    <button
      type={type}
      onClick={onClick}
      disabled={disabled || loading}
      className={`
        bg-primary text-white rounded-button px-5 py-3 text-button font-sans font-semibold
        transition-all duration-micro ease-out
        hover:brightness-[0.92] hover:shadow-md
        active:scale-[0.97]
        disabled:opacity-45 disabled:pointer-events-none
        ${className}
      `}
    >
      {loading ? 'Carregando...' : children}
    </button>
  );
}

export function SecondaryButton({ children, onClick, type = 'button', disabled = false, loading = false, className = '' }) {
  return (
    <button
      type={type}
      onClick={onClick}
      disabled={disabled || loading}
      className={`
        bg-transparent text-primary border-2 border-primary rounded-button px-5 py-3
        text-button font-sans font-semibold transition-all duration-micro ease-out
        hover:bg-primary/5 active:scale-[0.97] disabled:opacity-45 disabled:pointer-events-none
        ${className}
      `}
    >
      {loading ? 'Carregando...' : children}
    </button>
  );
}
