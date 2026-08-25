import { useEffect, useState } from 'react';
import { adminApi } from '../../api/adminApi';
import { Card } from '../../components/Card';

export function AdminAuditLogs() {
  const [logs, setLogs] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    adminApi.listAuditLogs().then((res) => setLogs(res.data)).finally(() => setLoading(false));
  }, []);

  return (
    <div className="space-y-4">
      <h1 className="font-display text-h1 text-text">Logs de Auditoria</h1>

      {loading && <p className="text-caption text-text-secondary">Carregando...</p>}
      {!loading && logs.length === 0 && (
        <Card><p className="text-body text-text-secondary">Nenhum log registrado ainda.</p></Card>
      )}

      <div className="space-y-2">
        {logs.map((log) => (
          <Card key={log.id} className="!py-3">
            <div className="flex justify-between items-start">
              <p className="text-body font-semibold text-text">{log.action}</p>
              <p className="text-caption text-text-secondary">
                {new Date(log.createdAt).toLocaleString('pt-MZ')}
              </p>
            </div>
            <p className="text-caption text-text-secondary">
              {log.entity}{log.entityId ? ` · ${log.entityId}` : ''}
            </p>
            {log.metadata && Object.keys(log.metadata).length > 0 && (
              <pre className="text-[11px] text-text-secondary bg-background rounded-button p-2 mt-1 overflow-x-auto">
                {JSON.stringify(log.metadata, null, 2)}
              </pre>
            )}
          </Card>
        ))}
      </div>
    </div>
  );
}
