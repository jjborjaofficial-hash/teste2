import { useEffect, useRef, useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { ApiError } from '../api/client';

const GSI_SCRIPT_SRC = 'https://accounts.google.com/gsi/client';
const GOOGLE_CLIENT_ID = import.meta.env.VITE_GOOGLE_CLIENT_ID;

/**
 * Botão "Continuar com Google" (Doc. Mestre Seção 17, variante Google).
 * Usa o Google Identity Services oficial — o botão em si é desenhado e
 * controlado pelo próprio Google (requisito de segurança e de conformidade
 * das políticas do Google, não dá para "fingir" o botão com CSS próprio).
 *
 * Fluxo: Google devolve um idToken assinado -> enviamos ao backend em
 * POST /auth/google, que verifica a assinatura e decide se é login ou
 * cadastro. Se a conta for nova, ainda não tem telefone: redirecionamos
 * para /completar-perfil antes do dashboard.
 */
function loadGsiScript() {
  if (window.google?.accounts?.id) return Promise.resolve();
  return new Promise((resolve, reject) => {
    const existing = document.querySelector(`script[src="${GSI_SCRIPT_SRC}"]`);
    if (existing) {
      existing.addEventListener('load', () => resolve());
      existing.addEventListener('error', () => reject(new Error('Falha ao carregar o script do Google.')));
      return;
    }
    const script = document.createElement('script');
    script.src = GSI_SCRIPT_SRC;
    script.async = true;
    script.defer = true;
    script.onload = () => resolve();
    script.onerror = () => reject(new Error('Falha ao carregar o script do Google.'));
    document.head.appendChild(script);
  });
}

export function GoogleLoginButton() {
  const { loginWithGoogle } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  const containerRef = useRef(null);
  const [error, setError] = useState(null);
  const [unavailable, setUnavailable] = useState(false);

  useEffect(() => {
    if (!GOOGLE_CLIENT_ID) {
      // Sem Client ID configurado (.env), simplesmente não mostra o botão —
      // o login por telefone continua funcionando normalmente.
      setUnavailable(true);
      return;
    }

    let cancelled = false;

    async function handleCredentialResponse(response) {
      setError(null);
      try {
        const user = await loginWithGoogle(response.credential);
        const redirectTo = user.needsPhone
          ? '/completar-perfil'
          : location.state?.from?.pathname || '/dashboard';
        navigate(redirectTo, { replace: true });
      } catch (err) {
        setError(err instanceof ApiError ? err.message : 'Não foi possível entrar com o Google.');
      }
    }

    loadGsiScript()
      .then(() => {
        if (cancelled || !containerRef.current) return;
        window.google.accounts.id.initialize({
          client_id: GOOGLE_CLIENT_ID,
          callback: handleCredentialResponse,
        });
        window.google.accounts.id.renderButton(containerRef.current, {
          type: 'standard',
          theme: 'outline',
          size: 'large',
          shape: 'pill',
          text: 'continue_with',
          logo_alignment: 'center',
          width: 360,
        });
      })
      .catch(() => {
        if (!cancelled) setUnavailable(true);
      });

    return () => {
      cancelled = true;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  if (unavailable) return null;

  return (
    <div className="w-full">
      <div className="flex items-center gap-3 my-5">
        <div className="h-px bg-border flex-1" />
        <span className="text-caption text-text-secondary">ou</span>
        <div className="h-px bg-border flex-1" />
      </div>
      <div ref={containerRef} className="flex justify-center" />
      {error && <p className="text-danger text-caption text-center mt-2">{error}</p>}
    </div>
  );
}
