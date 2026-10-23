import { useEffect, useState } from 'react';
import { adminAdsApi } from '../../api/adminApi';
import { ApiError } from '../../api/client';

function Switch({ on, onChange, label, disabled }) {
  // O botão é só a área de toque (o site obriga a 44 px); a alavanca desenhada fica centrada lá dentro.
  return (
    <button
      type="button"
      role="switch"
      aria-checked={on}
      aria-label={label}
      disabled={disabled}
      onClick={() => onChange(!on)}
      style={{ width: 64, height: 44, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}
      className="disabled:opacity-50"
    >
      <span
        style={{ position: 'relative', display: 'block', width: 52, height: 30, borderRadius: 15, transition: 'background-color 0.18s ease' }}
        className={on ? 'bg-success' : 'bg-border'}
      >
        <span
          style={{
            position: 'absolute',
            top: 3,
            left: on ? 25 : 3,
            width: 24,
            height: 24,
            borderRadius: 12,
            background: '#fff',
            transition: 'left 0.18s ease',
            boxShadow: '0 1px 3px rgba(0,0,0,0.4)',
          }}
        />
      </span>
    </button>
  );
}

function SlotCard({ slot, onChanged }) {
  const [code, setCode] = useState('');
  const [busy, setBusy] = useState(false);
  const [msg, setMsg] = useState(null);

  async function run(fn, okText) {
    setBusy(true);
    setMsg(null);
    try {
      const res = await fn();
      onChanged(res.data);
      setMsg({ ok: true, text: okText });
      return true;
    } catch (err) {
      setMsg({ ok: false, text: err instanceof ApiError ? err.message : 'Não foi possível guardar.' });
      return false;
    } finally {
      setBusy(false);
    }
  }

  async function handleSave() {
    if (await run(() => adminAdsApi.save(slot.key, code), 'Guardado e integrado.')) setCode('');
  }

  const live = slot.integrated && slot.enabled;

  return (
    <div className={`bg-surface border rounded-card p-4 space-y-3 ${live ? 'border-success/50' : 'border-border'}`}>
      <div className="flex items-start justify-between gap-3">
        <div className="min-w-0">
          <p className="text-body font-semibold text-text">{slot.label}</p>
          <p className="text-caption text-text-secondary">{slot.where}</p>
        </div>
        <span
          className={`shrink-0 text-caption font-semibold rounded-full px-2.5 py-1 ${
            slot.integrated ? 'bg-success/15 text-success' : 'bg-border/60 text-text-secondary'
          }`}
        >
          {slot.integrated ? '● Integrado' : '○ Não integrado'}
        </span>
      </div>

      <p className="text-caption text-text-secondary">
        Cabe aqui: <span className="text-text font-semibold">{slot.formatLabel}</span> ({slot.size})
        {slot.integrated && <> · Zone ID <span className="text-text font-semibold">{slot.zoneId}</span></>}
      </p>

      <textarea
        value={code}
        onChange={(e) => setCode(e.target.value)}
        rows={3}
        placeholder={slot.integrated ? 'Cole um código novo para substituir o atual' : 'Cole aqui o código do anúncio (Adcash)'}
        className="w-full rounded-button border border-border bg-background px-3 py-2 text-caption text-text font-mono focus:border-primary outline-none"
      />

      {msg && <p className={`text-caption ${msg.ok ? 'text-success' : 'text-danger'}`}>{msg.text}</p>}

      <div className="flex items-center justify-between gap-2">
        <div className="flex gap-2">
          <button
            onClick={handleSave}
            disabled={busy || !code.trim()}
            className="bg-primary text-white text-button font-semibold rounded-button px-4 py-2 disabled:opacity-50"
          >
            Guardar
          </button>
          {slot.integrated && (
            <button
              onClick={() => run(() => adminAdsApi.remove(slot.key), 'Código removido.')}
              disabled={busy}
              className="border border-danger text-danger text-button font-semibold rounded-button px-4 py-2 disabled:opacity-50"
            >
              Remover
            </button>
          )}
        </div>
        {slot.integrated && (
          <label className="flex items-center gap-2 text-caption text-text-secondary">
            {slot.enabled ? 'Ligado' : 'Desligado'}
            <Switch
              on={slot.enabled}
              disabled={busy}
              label={`Ligar ou desligar ${slot.label}`}
              onChange={(v) => run(() => adminAdsApi.setEnabled(slot.key, v), v ? 'Ligado.' : 'Desligado.')}
            />
          </label>
        )}
      </div>
    </div>
  );
}

/** Anúncios por local: cada local mostra que formato cabe, aceita o código do Adcash e indica se está integrado. */
export function AdminAds() {
  const [data, setData] = useState(null);
  const [error, setError] = useState(null);
  const [masterBusy, setMasterBusy] = useState(false);

  useEffect(() => {
    adminAdsApi
      .list()
      .then((res) => setData(res.data))
      .catch((err) => setError(err instanceof ApiError ? err.message : 'Não foi possível carregar os anúncios.'));
  }, []);

  if (error) return <p className="text-danger text-body">{error}</p>;
  if (!data) return <p className="text-text-secondary text-body">Carregando...</p>;

  const integrated = data.slots.filter((s) => s.integrated).length;

  async function toggleMaster(v) {
    setMasterBusy(true);
    try {
      const res = await adminAdsApi.setMaster(v);
      setData(res.data);
    } finally {
      setMasterBusy(false);
    }
  }

  return (
    <div className="space-y-5">
      <header>
        <h1 className="font-display text-h1 text-text">Anúncios</h1>
        <p className="text-body text-text-secondary">
          Cole o código do Adcash no local certo. {integrated} de {data.slots.length} locais integrados.
        </p>
      </header>

      <div className={`flex items-center justify-between gap-3 rounded-card border p-4 ${data.masterEnabled ? 'bg-success/10 border-success/40' : 'bg-warning/10 border-warning/40'}`}>
        <div>
          <p className={`text-body font-semibold ${data.masterEnabled ? 'text-success' : 'text-warning'}`}>
            {data.masterEnabled ? 'Anúncios LIGADOS na plataforma' : 'Anúncios DESLIGADOS na plataforma'}
          </p>
          <p className="text-caption text-text-secondary">
            Interruptor geral. Só liga depois de bloqueares a categoria Adulto e os anúncios enganosos na Adcash.
          </p>
        </div>
        <Switch on={data.masterEnabled} disabled={masterBusy} onChange={toggleMaster} label="Interruptor geral dos anúncios" />
      </div>

      {data.slots.map((slot) => (
        <SlotCard key={slot.key} slot={slot} onChanged={setData} />
      ))}
    </div>
  );
}
