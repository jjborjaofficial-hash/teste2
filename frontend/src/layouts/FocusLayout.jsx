import { Outlet } from 'react-router-dom';

/**
 * Layout de foco absoluto (Doc. Mestre Seção 19.4: "Esta página deve ter foco
 * absoluto. O usuário não pode se distrair aqui."). Sem BottomNav, sem Rodapé,
 * sem qualquer elemento que não seja a pergunta atual.
 */
export function FocusLayout() {
  return (
    <div className="min-h-screen bg-background flex flex-col">
      <main className="flex-1 max-w-md mx-auto w-full px-4 py-6 flex flex-col">
        <Outlet />
      </main>
    </div>
  );
}
