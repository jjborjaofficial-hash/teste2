import { Navigate, useLocation } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

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

  // Mecanismo de reaceite de Termos: se os Termos mudaram de versão desde o
  // último aceite do usuário, o app inteiro fica bloqueado até ele confirmar
  // novamente (checkbox), antes de liberar qualquer outra tela.
  if (user.needsTermsReacceptance && location.pathname !== '/reaceitar-termos') {
    return <Navigate to="/reaceitar-termos" replace />;
  }

  return children;
}
