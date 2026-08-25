import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { notificationsApi } from '../api/gameplayApi';
import { Card } from '../components/Card';
import { NotificationIcon } from '../icons';

export function Notifications() {
  const [notifications, setNotifications] = useState([]);
  const [loading, setLoading] = useState(true);

  async function load() {
    const res = await notificationsApi.list();
    setNotifications(res.data);
  }

  useEffect(() => {
    load().finally(() => setLoading(false));
  }, []);

  async function handleOpen(notification) {
    if (!notification.read) {
      await notificationsApi.markAsRead(notification.id);
      setNotifications((prev) =>
        prev.map((n) => (n.id === notification.id ? { ...n, read: true } : n))
      );
    }
  }

  return (
    <div className="space-y-4 pb-4">
      <header className="pt-2 flex items-center gap-2">
        <NotificationIcon className="w-7 h-7 text-primary" />
        <h1 className="font-display text-h1 text-text">Notificações</h1>
      </header>

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
            <p className="text-caption text-text-secondary mt-1">
              {new Date(n.createdAt).toLocaleString('pt-MZ')}
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
