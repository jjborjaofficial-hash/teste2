import { Outlet } from 'react-router-dom';
import { BottomNav } from '../components/BottomNav';
import { Footer } from '../components/Footer';

/**
 * Layout padrão (Doc. Mestre Seção 18 e 19): BottomNav + Rodapé presentes.
 * A Tela de Quiz Ativo usa `FocusLayout` em vez deste, para garantir foco absoluto.
 */
export function AppLayout() {
  return (
    <div className="min-h-screen flex flex-col bg-background">
      <main className="flex-1 max-w-md mx-auto w-full px-4 pt-4 pb-4">
        <Outlet />
      </main>
      <Footer />
      <BottomNav />
    </div>
  );
}
