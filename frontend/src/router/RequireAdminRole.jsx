import { Navigate, useLocation } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

/**
 * Guarda de rota do Painel Admin. Diferente de ProtectedRoute (que só exige
 * login), esta exige que o usuário tenha um papel admin_* (Manual Parte 5:
 * autorização é responsabilidade de um guard/middleware, não de cada página).
 */
export function RequireAdminRole({ roles, children }) {
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

  const isAdmin = user.role && user.role.startsWith('admin_');
  if (!isAdmin) {
    return <Navigate to="/dashboard" replace />;
  }

  if (roles && user.role !== 'admin_master' && !roles.includes(user.role)) {
    return <Navigate to="/admin" replace />;
  }

  return children;
}
