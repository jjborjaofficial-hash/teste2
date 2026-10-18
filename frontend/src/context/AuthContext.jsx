import { createContext, useContext, useState, useEffect, useCallback, useMemo, useRef } from 'react';
import { authApi } from '../api/authApi';
import { setTokens, clearTokens, ApiError } from '../api/client';
import { usersApi } from '../api/profileApi';
import { shopApi } from '../api/shopApi';
import { syncPushToken } from '../lib/pushNotifications';

const AuthContext = createContext(null);

// Estado "sem oferta" usado quando o perfil não consegue dizer nada sobre o empréstimo do Tema Noite
// (nunca prender o utilizador à espera disso).
const TRIAL_UNAVAILABLE = { status: 'unavailable', endsAt: null, secondsLeft: 0, serverNow: null, introSeen: true, durationSeconds: 600 };

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  // Tema Noite emprestado por 10 minutos (GER-002). Quem manda no tempo é o servidor: o perfil traz `endsAt` e
  // `serverNow`; aqui só se converte o fim para o relógio deste aparelho (endsAt - diferença entre os relógios).
  const trialEndsAtLocal = useMemo(() => {
    const t = user?.themeTrial;
    if (!t || t.status !== 'active' || !t.endsAt || !t.serverNow) return null;
    return Date.parse(t.endsAt) - (Date.parse(t.serverNow) - Date.now());
  }, [user?.themeTrial]);
  const [, forceTick] = useState(0);
  const [trialEnded, setTrialEnded] = useState(false);
  const trialEndedNotified = useRef(null);
  const trialActive = trialEndsAtLocal !== null && Date.now() < trialEndsAtLocal;

  // Na hora exata do fim volta ao tema claro sozinho (sem recarregar) e avisa uma vez. Os navegadores atrasam
  // temporizadores de separadores em segundo plano; por isso também se confere ao voltar ao separador.
  useEffect(() => {
    if (trialEndsAtLocal === null) return undefined;
    let timer;
    const check = () => {
      clearTimeout(timer);
      const left = trialEndsAtLocal - Date.now();
      if (left > 0) {
        timer = setTimeout(check, Math.min(left + 20, 60000));
        return;
      }
      forceTick((n) => n + 1);
      if (trialEndedNotified.current !== trialEndsAtLocal) {
        trialEndedNotified.current = trialEndsAtLocal;
        setTrialEnded(true);
      }
    };
    check();
    document.addEventListener('visibilitychange', check);
    return () => {
      clearTimeout(timer);
      document.removeEventListener('visibilitychange', check);
    };
  }, [trialEndsAtLocal]);

  // Aplica o Tema Noite globalmente: comprado e equipado na Loja (item cosmético) OU emprestado e ainda dentro
  // dos 10 minutos. Troca só as variáveis CSS (ver index.css), nenhum componente precisa saber disso.
  const nightTheme = user?.equippedTheme === 'theme_night' || trialActive;
  useEffect(() => {
    const root = document.documentElement;
    if (nightTheme) {
      root.setAttribute('data-theme', 'night');
    } else {
      root.removeAttribute('data-theme');
    }
  }, [nightTheme]);

  // Quem entrou por cadastro/login recebe do servidor só um resumo do utilizador (sem `themeTrial`):
  // busca o perfil completo uma vez. Se falhar, segue sem a oferta em vez de prender o utilizador.
  useEffect(() => {
    if (!user || user.themeTrial !== undefined) return undefined;
    let cancelled = false;
    usersApi.me()
      .then((profile) => {
        if (cancelled) return;
        setUser((u) => (u && u.id === profile.data.id ? { ...u, ...profile.data, themeTrial: profile.data.themeTrial ?? TRIAL_UNAVAILABLE } : u));
      })
      .catch(() => {
        if (!cancelled) setUser((u) => (u ? { ...u, themeTrial: TRIAL_UNAVAILABLE } : u));
      });
    return () => {
      cancelled = true;
    };
  }, [user]);

  // Push: cada vez que uma conta fica com a sessão aberta, liga o aparelho a ela (sem pedir
  // permissão). Resolve o caso de trocar de conta no mesmo navegador, em que o "Ativado" ficava
  // a valer mas o aparelho continuava ligado à conta anterior.
  const userId = user?.id;
  useEffect(() => {
    if (userId) syncPushToken();
  }, [userId]);

  // Ao carregar o app, sempre tenta restaurar a sessão buscando o perfil. Não
  // há mais como checar de antemão se existe um refresh token — ele vive num
  // cookie httpOnly, ilegível para o JS. Se não houver cookie válido, o 401
  // do /me acontece, o client.js tenta /auth/refresh (que também falha sem
  // cookie) e caímos no catch normalmente, sem sessão restaurada.
  // Falha passageira (servidor a acordar — o plano gratuito do Render dorme —, rede fraca,
  // erro 5xx) NÃO significa "sem sessão": tenta de novo uns segundos depois, mantendo a tela
  // de carregamento. Só um 401/403 (cookie ausente ou inválido) encerra como "sem sessão".
  useEffect(() => {
    let cancelled = false;
    const wait = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

    async function restoreSession() {
      const delays = [0, 3000, 6000, 10000];
      for (let attempt = 0; attempt < delays.length; attempt += 1) {
        if (delays[attempt]) await wait(delays[attempt]);
        if (cancelled) return;
        try {
          const profile = await usersApi.me();
          if (cancelled) return;
          setUser(profile.data);
          break;
        } catch (err) {
          const definitive = err instanceof ApiError && err.status >= 400 && err.status < 500;
          if (definitive || attempt === delays.length - 1) {
            clearTokens();
            break;
          }
        }
      }
      if (!cancelled) setLoading(false);
    }
    restoreSession();
    return () => {
      cancelled = true;
    };
  }, []);

  const register = useCallback(async (formData) => {
    const result = await authApi.register(formData);
    setTokens(result.data);
    setUser(result.data.user);
    return result.data.user;
  }, []);

  const login = useCallback(async (formData) => {
    const result = await authApi.login(formData);
    setTokens(result.data);
    setUser(result.data.user);
    return result.data.user;
  }, []);

  const loginWithGoogle = useCallback(async (idToken, referralCode) => {
    const result = await authApi.loginWithGoogle(idToken, referralCode);
    setTokens(result.data);
    setUser(result.data.user);
    return result.data.user;
  }, []);

  const recoverWithGoogle = useCallback(async (idToken, newPassword) => {
    const result = await authApi.recoverWithGoogle(idToken, newPassword);
    setTokens(result.data);
    setUser(result.data.user);
    return result.data.user;
  }, []);

  // Pedida logo após o primeiro login via Google (conta nasce sem telefone);
  // atualiza o user em memória para refletir needsPhone: false imediatamente.
  const completeProfile = useCallback(async (formData) => {
    const result = await authApi.completeProfile(formData);
    setUser(result.data.user);
    return result.data.user;
  }, []);

  const logout = useCallback(async () => {
    clearTokens();
    setUser(null);
    setTrialEnded(false);
    try {
      // O backend lê o refresh token do próprio cookie httpOnly e o revoga;
      // também limpa o cookie na resposta.
      await authApi.logout();
    } catch {
      // Mesmo se a chamada falhar, a sessão local já foi encerrada.
    }
  }, []);

  const refreshProfile = useCallback(async () => {
    const profile = await usersApi.me();
    setUser(profile.data);
    return profile.data;
  }, []);

  // "Modo escuro" no ecrã de escolha (ou no cartão da Loja/Configurações): o servidor regista o início e o
  // perfil em memória passa a mostrar o empréstimo ativo.
  const startThemeTrial = useCallback(async () => {
    const result = await shopApi.startThemeTrial();
    setTrialEnded(false);
    setUser((u) => (u ? { ...u, themeTrial: result.data } : u));
    return result.data;
  }, []);

  // "Modo claro": só deixa de mostrar os ecrãs; a oferta continua disponível uma vez.
  const dismissThemeTrialIntro = useCallback(async () => {
    const result = await shopApi.dismissThemeTrialIntro();
    setUser((u) => (u ? { ...u, themeTrial: result.data } : u));
    return result.data;
  }, []);

  const dismissTrialEnded = useCallback(() => setTrialEnded(false), []);

  return (
    <AuthContext.Provider
      value={{
        user, loading, register, login, loginWithGoogle, recoverWithGoogle, completeProfile, logout, refreshProfile,
        themeTrial: { active: trialActive, endsAtLocal: trialEndsAtLocal, ended: trialEnded },
        startThemeTrial, dismissThemeTrialIntro, dismissTrialEnded,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth deve ser usado dentro de um AuthProvider.');
  return ctx;
}
