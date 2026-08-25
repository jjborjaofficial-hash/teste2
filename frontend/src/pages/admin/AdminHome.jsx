import { Navigate } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';

export function AdminHome() {
  const { user } = useAuth();

  if (user?.role === 'admin_master' || user?.role === 'admin_financeiro') {
    return <Navigate to="/admin/saques" replace />;
  }
  if (user?.role === 'admin_suporte') {
    return <Navigate to="/admin/usuarios" replace />;
  }
  return <Navigate to="/admin/auditoria" replace />;
}
