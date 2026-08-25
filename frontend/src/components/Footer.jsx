/**
 * Rodapé (Doc. Mestre Seção 18). Presente em todas as páginas, EXCETO durante a
 * tela de quiz ativo (para não distrair o usuário — mesma regra do BottomNav).
 * Texto e estrutura seguem exatamente o "Modelo de Layout do Rodapé" da Seção 18.
 */
export function Footer() {
  return (
    <footer className="bg-surface border-t border-border px-4 py-6 pb-24 text-caption text-text-secondary">
      <div className="max-w-md mx-auto space-y-4">
        <div>
          <p className="font-display font-semibold text-text text-body">Aprenda e Ganhe</p>
          <p>Transformando o progresso de sua aprendizagem em recompensas reais.</p>
        </div>

        <div className="flex flex-wrap gap-x-3 gap-y-1">
          <span>Navegação</span>
          <span>·</span>
          <a href="/dashboard" className="hover:text-primary">Painel de Controle</a>
          <span>·</span>
          <a href="/como-funciona" className="hover:text-primary">Como Funciona</a>
          <span>·</span>
          <a href="/suporte" className="hover:text-primary">Suporte e FAQ</a>
        </div>

        <div className="flex flex-wrap gap-x-3 gap-y-1">
          <span>Legal e Segurança</span>
          <span>·</span>
          <a href="/legal" className="hover:text-primary">Central Jurídica</a>
          <span>·</span>
          <a href="/termos" className="hover:text-primary">Termos de Uso</a>
          <span>·</span>
          <a href="/privacidade" className="hover:text-primary">Política de Privacidade</a>
          <span>·</span>
          <a href="/recompensas" className="hover:text-primary">Política de Recompensas</a>
          <span>·</span>
          <a href="/legal/cookies" className="hover:text-primary">Cookies</a>
          <span>·</span>
          <a href="/legal/comunidade" className="hover:text-primary">Comunidade</a>
          <span>·</span>
          <a href="/legal/aviso_legal" className="hover:text-primary">Aviso Legal</a>
        </div>

        <p className="text-[11px] leading-4">
          Aviso de Isenção: O Aprenda e Ganhe é uma plataforma de tecnologia educacional e
          mídia. As recompensas financeiras são oferecidas como incentivo à gamificação e
          dependentes do cumprimento de missões, não constituindo promessa de renda.
        </p>

        <p className="text-[11px]">© {new Date().getFullYear()} Plataforma Aprenda e Ganhe. Todos os direitos reservados.</p>
      </div>
    </footer>
  );
}
