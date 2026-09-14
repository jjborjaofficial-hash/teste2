/**
 * Cliente HTTP central para consumir o backend (Manual Parte 3: Camada de Apresentação
 * nunca deve conter regra de negócio — este arquivo só fala com a API, nada de decisão
 * de negócio aqui).
 *
 * O refresh token NUNCA passa por aqui: ele vive em um cookie httpOnly que o
 * navegador anexa sozinho às requisições para a API (correção de segurança —
 * antes ficava em `localStorage`, legível por qualquer script na página, ou
 * seja, roubável via XSS). Por isso toda chamada usa `credentials: 'include'`.
 */

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000/api/v1';

let accessToken = null;

function setTokens({ accessToken: newAccess }) {
  accessToken = newAccess || null;
}

function clearTokens() {
  accessToken = null;
}

class ApiError extends Error {
  constructor(message, status, code, details) {
    super(message);
    this.status = status;
    this.code = code;
    this.details = details;
  }
}

async function rawRequest(path, { method = 'GET', body, auth = true } = {}) {
  const headers = { 'Content-Type': 'application/json' };
  if (auth && accessToken) {
    headers.Authorization = `Bearer ${accessToken}`;
  }

  const res = await fetch(`${API_BASE_URL}${path}`, {
    method,
    headers,
    credentials: 'include', // envia/recebe o cookie httpOnly do refresh token
    body: body ? JSON.stringify(body) : undefined,
  });

  let payload = null;
  try {
    payload = await res.json();
  } catch {
    payload = null;
  }

  if (!res.ok) {
    throw new ApiError(
      payload?.message || 'Algo deu errado. Tente novamente.',
      res.status,
      payload?.code,
      payload?.errors
    );
  }

  return payload;
}

/**
 * Tenta renovar o access token uma única vez em caso de 401, e repete a requisição
 * original. Se a renovação falhar, propaga o erro (o AuthContext trata isso como
 * sessão expirada e desloga o usuário).
 */
async function request(path, options = {}) {
  try {
    return await rawRequest(path, options);
  } catch (err) {
    // Em 401, tenta renovar via cookie httpOnly (o navegador o envia sozinho
    // para /auth/refresh — não precisamos, e não conseguimos, lê-lo aqui).
    if (err.status === 401 && options.auth !== false && path !== '/auth/refresh') {
      try {
        const refreshResult = await rawRequest('/auth/refresh', {
          method: 'POST',
          auth: false,
        });
        setTokens(refreshResult.data);
        return await rawRequest(path, options);
      } catch (refreshErr) {
        clearTokens();
        throw refreshErr;
      }
    }
    throw err;
  }
}

export const api = {
  get: (path, options = {}) => request(path, { method: 'GET', ...options }),
  post: (path, body, options = {}) => request(path, { method: 'POST', body, ...options }),
  delete: (path, body, options = {}) => request(path, { method: 'DELETE', body, ...options }),
};

export { setTokens, clearTokens, ApiError };
