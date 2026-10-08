import { createContext, useContext, useState, useEffect, useCallback } from 'react';
import { authApi } from '../api/authApi';
import { setTokens, clearTokens, ApiError } from '../api/client';
import { usersApi } from '../api/profileApi';

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  // Aplica o Tema Noite (item cosmético da Loja) globalmente sempre que o
  // perfil carregado/atualizado indicar que ele está equipado — troca só as
  // variáveis CSS (ver index.css), nenhum componente precisa saber disso.
  useEffect(() => {
    const root = document.documentElement;
    if (user?.equippedTheme === 'theme_night') {
      root.setAttribute('data-theme', 'night');
    } else {
      root.removeAttribute('data-theme');
    }
  }, [user?.equippedTheme]);

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

  const loginWithGoogle = useCallback(async (idToken) => {
    const result = await authApi.loginWithGoogle(idToken);
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

  return (
    <AuthContext.Provider
      value={{ user, loading, register, login, loginWithGoogle, completeProfile, logout, refreshProfile }}
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
