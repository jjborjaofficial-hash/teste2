import { useEffect, useState } from 'react';
import { useAuth } from '../../context/AuthContext';
import { adminApi } from '../../api/adminApi';
import { useToast } from '../../components/Toast';
import { Card } from '../../components/Card';
import { PrimaryButton, SecondaryButton } from '../../components/Button';
import { ApiError } from '../../api/client';

const ROLE_OPTIONS = ['user', 'admin_master', 'admin_financeiro', 'admin_suporte'];

export function AdminUsers() {
  const { user: currentAdmin } = useAuth();
  const { showToast } = useToast();
  const [search, setSearch] = useState('');
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [editingId, setEditingId] = useState(null);
  const [delta, setDelta] = useState('');
  const [reason, setReason] = useState('');
  const [busyId, setBusyId] = useState(null);

  const isMaster = currentAdmin?.role === 'admin_master';

  async function load() {
    setLoading(true);
    try {
      const res = await adminApi.listUsers(search);
      setUsers(res.data);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => { load(); }, []); // eslint-disable-line react-hooks/exhaustive-deps

  async function handleSearch(e) {
    e.preventDefault();
    await load();
  }

  async function handleAdjustTrustScore(userId) {
    const numericDelta = Number(delta);
    if (!numericDelta || !reason.trim()) {
      showToast('Informe o ajuste (número) e o motivo.', 'error');
      return;
    }
    setBusyId(userId);
    try {
      await adminApi.adjustTrustScore(userId, { delta: numericDelta, reason });
      showToast('Trust Score ajustado.', 'success');
      setEditingId(null);
      setDelta('');
      setReason('');
      await load();
    } catch (err) {
      showToast(err instanceof ApiError ? err.message : 'Não foi possível ajustar.', 'error');
    } finally {
      setBusyId(null);
    }
  }

  async function handleStatusChange(userId, status) {
    setBusyId(userId);
    try {
      await adminApi.setUserStatus(userId, status);
      showToast('Status atualizado.', 'success');
      await load();
    } catch (err) {
      showToast(err instanceof ApiError ? err.message : 'Não foi possível atualizar o status.', 'error');
    } finally {
      setBusyId(null);
    }
  }

  async function handleRoleChange(userId, role) {
    setBusyId(userId);
    try {
      await adminApi.setUserRole(userId, role);
      showToast('Papel administrativo atualizado.', 'success');
      await load();
    } catch (err) {
      showToast(err instanceof ApiError ? err.message : 'Não foi possível atualizar o papel.', 'error');
    } finally {
      setBusyId(null);
    }
  }

  return (
    <div className="space-y-4">
      <h1 className="font-display text-h1 text-text">Usuários</h1>

      <form onSubmit={handleSearch} className="flex gap-2">
        <input
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder="Buscar por nome ou telefone"
          className="flex-1 rounded-button border border-border bg-surface px-4 py-2 text-body text-text focus:border-primary outline-none"
        />
        <SecondaryButton type="submit">Buscar</SecondaryButton>
      </form>

      {loading && <p className="text-caption text-text-secondary">Carregando...</p>}

      <div className="space-y-3">
        {users.map((u) => (
          <Card key={u.id}>
            <div className="flex justify-between items-start mb-2">
              <div>
                <p className="text-body font-semibold text-text">{u.name}</p>
                <p className="text-caption text-text-secondary">{u.phone}</p>
              </div>
              <div className="text-right">
                <p className="text-caption text-text-secondary">Trust Score</p>
                <p className="font-display font-semibold text-primary">{u.trustScore}</p>
              </div>
            </div>

            <div className="flex flex-wrap gap-2 mb-3">
              <span className="text-caption bg-border/40 rounded-full px-2 py-1">Status: {u.status}</span>
              <span className="text-caption bg-border/40 rounded-full px-2 py-1">Papel: {u.role}</span>
              <span className="text-caption bg-border/40 rounded-full px-2 py-1">
                Saldo: {u.walletBalanceMzn.toFixed(2)} MZN
              </span>
            </div>

            <div className="flex flex-wrap gap-2 mb-2">
              {['active', 'suspended', 'banned'].map((s) => (
                <button
                  key={s}
                  onClick={() => handleStatusChange(u.id, s)}
                  disabled={busyId === u.id || u.status === s}
                  className="text-caption rounded-button border border-border px-3 py-1.5 disabled:opacity-40"
                >
                  {s}
                </button>
              ))}
            </div>

            {isMaster && (
              <select
                value={u.role}
                onChange={(e) => handleRoleChange(u.id, e.target.value)}
                disabled={busyId === u.id}
                className="w-full rounded-button border border-border bg-surface px-3 py-2 text-caption text-text mb-2"
              >
                {ROLE_OPTIONS.map((r) => (
                  <option key={r} value={r}>{r}</option>
                ))}
              </select>
            )}

            {editingId === u.id ? (
              <div className="space-y-2 mt-2">
                <input
                  type="number"
                  value={delta}
                  onChange={(e) => setDelta(e.target.value)}
                  placeholder="Ajuste (ex: -10 ou 5)"
                  className="w-full rounded-button border border-border bg-surface px-3 py-2 text-body text-text focus:border-primary outline-none"
                />
                <input
                  value={reason}
                  onChange={(e) => setReason(e.target.value)}
                  placeholder="Motivo (obrigatório)"
                  className="w-full rounded-button border border-border bg-surface px-3 py-2 text-body text-text focus:border-primary outline-none"
                />
                <div className="flex gap-2">
                  <SecondaryButton onClick={() => setEditingId(null)} className="flex-1">Cancelar</SecondaryButton>
                  <PrimaryButton onClick={() => handleAdjustTrustScore(u.id)} loading={busyId === u.id} className="flex-1">
                    Confirmar
                  </PrimaryButton>
                </div>
              </div>
            ) : (
              <SecondaryButton onClick={() => setEditingId(u.id)} className="w-full mt-1">
                Ajustar Trust Score
              </SecondaryButton>
            )}
          </Card>
        ))}
      </div>
    </div>
  );
}
