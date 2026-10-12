import { Navigate, useLocation } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { ThemeTrialWelcome } from '../components/ThemeTrialWelcome';

export function ProtectedRoute({ children }) {
  const { user, loading } = useAuth();
  const location = useLocation();

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-background">
        <p className="text-text-secondary text-body">Carregando...</p>
      </div>
    );
  }

  if (!user) {
    return <Navigate to="/entrar" state={{ from: location }} replace />;
  }

  // Conta criada via Google ainda sem telefone: app inteiro fica bloqueado
  // até completar o perfil (telefone + check-in jurídico), antes de
  // qualquer outra tela — mesmo mecanismo do reaceite de Termos abaixo.
  if (user.needsPhone && location.pathname !== '/completar-perfil') {
    return <Navigate to="/completar-perfil" replace />;
  }

  // Mecanismo de reaceite de Termos: se os Termos mudaram de versão desde o
  // último aceite do usuário, o app inteiro fica bloqueado até ele confirmar
  // novamente (checkbox), antes de liberar qualquer outra tela.
  if (user.needsTermsReacceptance && location.pathname !== '/reaceitar-termos') {
    return <Navigate to="/reaceitar-termos" replace />;
  }

  // Tema Noite emprestado por 10 minutos (GER-002): o perfil completo ainda está a chegar (cadastro/login só
  // devolvem um resumo) — espera um instante em vez de piscar o Painel antes dos ecrãs de boas-vindas.
  if (user.themeTrial === undefined) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-background">
        <p className="text-text-secondary text-body">Carregando...</p>
      </div>
    );
  }

  // Conta nova que ainda não viu a oferta: ecrã de informação + escolha "Modo escuro / Modo claro" (uma só vez).
  // Só depois de completar o telefone e de aceitar os Termos, para não aparecer antes desses passos.
  if (!user.needsPhone && !user.needsTermsReacceptance && user.themeTrial.status === 'available' && !user.themeTrial.introSeen) {
    return <ThemeTrialWelcome />;
  }

  return children;
}
