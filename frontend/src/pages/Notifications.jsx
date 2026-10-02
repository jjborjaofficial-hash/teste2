import { useEffect, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { notificationsApi } from '../api/gameplayApi';
import { Card } from '../components/Card';
import { PrimaryButton } from '../components/Button';
import { useToast } from '../components/Toast';
import { NotificationIcon } from '../icons';
import { requestPushPermission } from '../lib/pushNotifications';
import { notificationRoute } from '../lib/notificationRoute';

const PUSH_STATUS_MESSAGES = {
  unsupported: 'Seu navegador não suporta notificações push.',
  unconfigured: 'Notificações push ainda não estão disponíveis nesta plataforma.',
  denied: 'Permissão de notificações negada. Você pode ativar depois nas configurações do navegador.',
  registered: 'Notificações push ativadas neste dispositivo!',
};

export function Notifications() {
  const { showToast } = useToast();
  const navigate = useNavigate();
  const [notifications, setNotifications] = useState([]);
  const [loading, setLoading] = useState(true);
  const [pushLoading, setPushLoading] = useState(false);

  async function load() {
    const res = await notificationsApi.list();
    setNotifications(res.data);
  }

  useEffect(() => {
    load().finally(() => setLoading(false));
  }, []);

  async function handleOpen(notification) {
    const destination = notificationRoute(notification);

    if (!notification.read) {
      // Marca como lida sem bloquear a navegação: se falhar, o utilizador ainda chega ao destino.
      try {
        await notificationsApi.markAsRead(notification.id);
        setNotifications((prev) =>
          prev.map((n) => (n.id === notification.id ? { ...n, read: true } : n))
        );
      } catch {
        /* segue para o destino mesmo assim */
      }
    }

    if (destination) navigate(destination);
  }

  async function handleEnablePush() {
    setPushLoading(true);
    const result = await requestPushPermission();
    showToast(PUSH_STATUS_MESSAGES[result], result === 'registered' ? 'success' : 'info');
    setPushLoading(false);
  }

  return (
    <div className="space-y-4 pb-4">
      <header className="pt-2 flex items-center gap-2">
        <NotificationIcon className="w-7 h-7 text-primary" />
        <h1 className="font-display text-h1 text-text">Notificações</h1>
      </header>

      <Card className="flex items-center justify-between gap-3">
        <div>
          <p className="text-body font-semibold text-text">Notificações no celular</p>
          <p className="text-caption text-text-secondary">Receba avisos mesmo com o app fechado.</p>
        </div>
        <PrimaryButton onClick={handleEnablePush} loading={pushLoading} className="!py-2 !px-3 text-caption shrink-0">
          Ativar
        </PrimaryButton>
      </Card>

      {loading && <p className="text-caption text-text-secondary">Carregando...</p>}
      {!loading && notifications.length === 0 && (
        <Card><p className="text-body text-text-secondary">Nenhuma notificação ainda.</p></Card>
      )}

      <div className="space-y-2">
        {notifications.map((n) => (
          <Card key={n.id} onClick={() => handleOpen(n)} className={n.read ? 'opacity-70' : ''}>
            <div className="flex items-start justify-between gap-2">
              <p className="text-body font-semibold text-text">{n.title}</p>
              {!n.read && <span className="w-2 h-2 rounded-full bg-primary mt-1.5 shrink-0" />}
            </div>
            <p className="text-caption text-text-secondary mt-0.5">{n.body}</p>
            <p className="text-caption text-text-secondary mt-1 flex items-center justify-between gap-2">
              <span>{new Date(n.createdAt).toLocaleString('pt-MZ')}</span>
              {notificationRoute(n) && <span className="text-primary font-semibold">Ver ›</span>}
            </p>
          </Card>
        ))}
      </div>

      <Link to="/dashboard" className="block text-center text-caption text-primary font-semibold pt-2">
        Voltar ao Painel
      </Link>
    </div>
  );
}
