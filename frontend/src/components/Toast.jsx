import { createContext, useContext, useState, useCallback, useRef } from 'react';
import { CheckIcon, CloseIcon } from '../icons';

/**
 * Toast / Notificação Rápida (Doc. Mestre Seção 13.4).
 * Sucesso: barra lateral --success, ícone de check, desliza de cima.
 * Erro (suave): barra lateral --danger, tom encorajador (nunca alarmista).
 * Duração 4s + 0.3s fade-out; pausa em hover/foco.
 */
const ToastContext = createContext(null);

export function ToastProvider({ children }) {
  const [toasts, setToasts] = useState([]);
  const timers = useRef({});

  const dismiss = useCallback((id) => {
    setToasts((prev) => prev.filter((t) => t.id !== id));
    clearTimeout(timers.current[id]);
    delete timers.current[id];
  }, []);

  const showToast = useCallback((message, variant = 'success') => {
    const id = Math.random().toString(36).slice(2);
    setToasts((prev) => [...prev, { id, message, variant }]);
    timers.current[id] = setTimeout(() => dismiss(id), 4000);
    return id;
  }, [dismiss]);

  const pause = (id) => clearTimeout(timers.current[id]);
  const resume = (id) => {
    timers.current[id] = setTimeout(() => dismiss(id), 1500);
  };

  return (
    <ToastContext.Provider value={{ showToast }}>
      {children}
      <div className="fixed top-4 left-0 right-0 z-50 flex flex-col items-center gap-2 px-4 pointer-events-none">
        {toasts.map((toast) => (
          <div
            key={toast.id}
            onMouseEnter={() => pause(toast.id)}
            onMouseLeave={() => resume(toast.id)}
            className={`
              pointer-events-auto w-full max-w-sm bg-surface rounded-card shadow-lg
              border-l-4 p-4 flex items-start gap-3 animate-[slideDown_0.3s_ease-out]
              ${toast.variant === 'success' ? 'border-success' : 'border-danger'}
            `}
          >
            <span className={toast.variant === 'success' ? 'text-success' : 'text-danger'}>
              {toast.variant === 'success' ? (
                <CheckIcon className="w-5 h-5" />
              ) : (
                <CloseIcon className="w-5 h-5" />
              )}
            </span>
            <p className="text-body text-text flex-1">{toast.message}</p>
          </div>
        ))}
      </div>
    </ToastContext.Provider>
  );
}

export function useToast() {
  const ctx = useContext(ToastContext);
  if (!ctx) throw new Error('useToast deve ser usado dentro de um ToastProvider.');
  return ctx;
}
