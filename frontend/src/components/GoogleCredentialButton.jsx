import { useEffect, useRef, useState } from 'react';
import { loadGsiScript } from './GoogleLoginButton';

const GOOGLE_CLIENT_ID = import.meta.env.VITE_GOOGLE_CLIENT_ID;

/**
 * Botão oficial do Google que só devolve o idToken a quem o usa (onCredential).
 * Serve para ligar o Google à conta e para recuperar a senha. Quem decide o que fazer
 * com o token é o ecrã; a confirmação real é sempre feita pelo servidor junto da Google.
 */
export function GoogleCredentialButton({ onCredential, text = 'continue_with' }) {
  const containerRef = useRef(null);
  const callbackRef = useRef(onCredential);
  callbackRef.current = onCredential;
  const [unavailable, setUnavailable] = useState(false);

  useEffect(() => {
    if (!GOOGLE_CLIENT_ID) {
      setUnavailable(true);
      return undefined;
    }
    let cancelled = false;
    loadGsiScript()
      .then(() => {
        if (cancelled || !containerRef.current) return;
        window.google.accounts.id.initialize({
          client_id: GOOGLE_CLIENT_ID,
          callback: (response) => callbackRef.current?.(response.credential),
        });
        window.google.accounts.id.renderButton(containerRef.current, {
          type: 'standard',
          theme: 'outline',
          size: 'large',
          shape: 'pill',
          text,
          logo_alignment: 'center',
          width: 320,
        });
      })
      .catch(() => {
        if (!cancelled) setUnavailable(true);
      });
    return () => {
      cancelled = true;
    };
  }, [text]);

  if (unavailable) {
    return <p className="text-caption text-text-secondary text-center">O Google não está disponível neste momento.</p>;
  }
  return <div ref={containerRef} className="flex justify-center" />;
}
