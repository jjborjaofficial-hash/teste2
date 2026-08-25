/**
 * Card (Doc. Mestre Seção 13.4).
 * Normal: fundo --surface, borda 1px --border, radius 14px, padding 16px.
 * Hover: elevação leve + borda --primary a 30%. Concluído: borda --success + check.
 * Bloqueado: overlay cinza translúcido + cadeado (omitido aqui — nenhuma tela usa
 * conteúdo bloqueado por enquanto; adicionar variante `locked` quando necessário).
 */
export function Card({ children, status = 'normal', onClick, className = '' }) {
  const statusClasses = {
    normal: 'border-border hover:border-primary/30 hover:shadow-sm',
    completed: 'border-success',
  };

  return (
    <div
      onClick={onClick}
      className={`
        bg-surface border rounded-card p-4 transition-all duration-micro
        ${statusClasses[status] || statusClasses.normal}
        ${onClick ? 'cursor-pointer' : ''}
        ${className}
      `}
    >
      {children}
    </div>
  );
}
