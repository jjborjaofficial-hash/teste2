import { Component } from 'react';

/**
 * Rede de segurança: se qualquer ecrã rebentar ao desenhar, mostra uma mensagem em vez de
 * deixar a página toda branca (antes não havia nada: um erro num ecrã deixava o site em branco,
 * sem pista do que se passou). Usa estilos em linha de propósito, para continuar legível mesmo
 * que o CSS ou o tema falhem.
 *
 * "Limpar dados e recarregar" apaga o que este navegador guardou do site (dados locais, caches e
 * service workers). Resolve o caso de dados antigos de uma versão ou conta anterior a estragar o
 * site. A sessão no servidor não é apagada: só terá de entrar de novo.
 */
export class ErrorBoundary extends Component {
  constructor(props) {
    super(props);
    this.state = { error: null, cleaning: false };
    this.handleReload = this.handleReload.bind(this);
    this.handleClean = this.handleClean.bind(this);
  }

  static getDerivedStateFromError(error) {
    return { error };
  }

  componentDidCatch(error, info) {
    // Fica no console do navegador para quem estiver a depurar (nunca envia nada para fora).
    // eslint-disable-next-line no-console
    console.error('Erro ao desenhar o ecrã:', error, info?.componentStack);
  }

  handleReload() {
    window.location.reload();
  }

  async handleClean() {
    this.setState({ cleaning: true });
    try {
      try { localStorage.clear(); } catch { /* sem acesso: segue */ }
      try { sessionStorage.clear(); } catch { /* sem acesso: segue */ }
      if ('serviceWorker' in navigator) {
        const registrations = await navigator.serviceWorker.getRegistrations();
        await Promise.all(registrations.map((r) => r.unregister()));
      }
      if (window.caches) {
        const keys = await window.caches.keys();
        await Promise.all(keys.map((k) => window.caches.delete(k)));
      }
    } catch {
      /* mesmo que algo falhe, recarrega na mesma */
    }
    window.location.assign('/');
  }

  render() {
    const { error, cleaning } = this.state;
    if (!error) return this.props.children;

    const detail = String(error?.message || error).slice(0, 200);
    const box = {
      minHeight: '100vh',
      display: 'flex',
      flexDirection: 'column',
      justifyContent: 'center',
      padding: '24px',
      background: '#f5f7fa',
      color: '#111827',
      fontFamily: 'system-ui, -apple-system, Segoe UI, Roboto, sans-serif',
    };
    const button = (primary) => ({
      width: '100%',
      padding: '14px',
      marginTop: '12px',
      borderRadius: '12px',
      fontSize: '16px',
      fontWeight: 600,
      cursor: 'pointer',
      border: primary ? 'none' : '2px solid #2563eb',
      background: primary ? '#2563eb' : '#ffffff',
      color: primary ? '#ffffff' : '#2563eb',
    });

    return (
      <div style={box} role="alert">
        <div style={{ maxWidth: '420px', margin: '0 auto', width: '100%' }}>
          <h1 style={{ fontSize: '24px', margin: '0 0 8px' }}>Algo correu mal</h1>
          <p style={{ margin: '0 0 8px', lineHeight: 1.5 }}>
            Não foi possível mostrar esta página. Tente carregar de novo. Se continuar assim,
            toque em &quot;Limpar dados e recarregar&quot; (terá de entrar outra vez).
          </p>
          <p style={{ margin: '0', fontSize: '12px', color: '#6b7280', wordBreak: 'break-word' }}>
            Detalhe: {detail}
          </p>
          <button type="button" style={button(true)} onClick={this.handleReload}>
            Recarregar
          </button>
          <button type="button" style={button(false)} onClick={this.handleClean} disabled={cleaning}>
            {cleaning ? 'A limpar...' : 'Limpar dados e recarregar'}
          </button>
        </div>
      </div>
    );
  }
}
