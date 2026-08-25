import { useEffect, useState } from 'react';
import { notificationsApi } from '../../api/gameplayApi';
import { Card } from '../../components/Card';

export function AdminNotifications() {
  const [notifications, setNotifications] = useState([]);
  const [loading, setLoading] = useState(true);

  async function load() {
    const res = await notificationsApi.list();
    setNotifications(res.data);
  }

  useEffect(() => { load().finally(() => setLoading(false)); }, []);

  async function handleOpen(n) {
    if (!n.read) {
      await notificationsApi.markAsRead(n.id);
      setNotifications((prev) => prev.map((x) => (x.id === n.id ? { ...x, read: true } : x)));
    }
  }

  return (
    <div className="space-y-4">
      <h1 className="font-display text-h1 text-text">Notificações</h1>

      {loading && <p className="text-caption text-text-secondary">Carregando...</p>}
      {!loading && notifications.length === 0 && (
        <Card><p className="text-body text-text-secondary">Nenhuma notificação.</p></Card>
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
    </div>
  );
}
