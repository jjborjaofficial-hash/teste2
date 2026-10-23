import { notificationsApi } from '../api/gameplayApi';

/**
 * Push web via Firebase Cloud Messaging.
 *
 * DEGRADAÇÃO GRACIOSA: sem VITE_FIREBASE_* preenchido (ver .env.example), ou
 * se o pacote `firebase` ainda não foi instalado, ou se o navegador não
 * suporta Service Worker/Notification API, esta função simplesmente não faz
 * nada — nunca lança erro, nunca trava o app. Mesmo princípio do backend
 * (src/common/notifications/pushService.js).
 *
 * NO DIA QUE HOUVER CREDENCIAL:
 * 1. `npm install firebase` (já está no package.json).
 * 2. Preencher as variáveis VITE_FIREBASE_* no .env.
 * 3. Preencher o mesmo firebaseConfig em public/firebase-messaging-sw.js
 *    (Service Workers não recebem variáveis de ambiente do Vite — é por
 *    isso que o config aparece duplicado nos dois arquivos).
 * 4. Chamar `requestPushPermission()` em algum ponto do app (ex: depois do
 *    login, ou num botão em Configurações) — ainda não é chamado automaticamente
 *    em lugar nenhum, para não pedir permissão sem o usuário esperar por isso.
 */

const firebaseConfig = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY,
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN,
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID,
  messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID,
  appId: import.meta.env.VITE_FIREBASE_APP_ID,
};

const VAPID_KEY = import.meta.env.VITE_FIREBASE_VAPID_KEY;

// Mesma chave que a página de Notificações usa para lembrar que este navegador ativou o push.
export const PUSH_FLAG = 'push_enabled';

function isConfigured() {
  return Boolean(firebaseConfig.apiKey && firebaseConfig.projectId && VAPID_KEY);
}

/**
 * Liga o aparelho (token) à conta que está com a sessão aberta, SEM pedir permissão.
 *
 * Porquê: o "Ativado" é lembrado por navegador, mas o token de push tem de pertencer à conta
 * certa. Se alguém entrar com outra conta no mesmo navegador, o site mostrava "Ativado" e o
 * aparelho continuava ligado à conta anterior (a nova não recebia avisos). O servidor já move o
 * token para a conta nova (upsert), por isso basta voltar a registá-lo depois de cada início de
 * sessão. Só age se o navegador já tinha ativado e a permissão continua concedida; nunca lança
 * erro. Devolve true se registou.
 */
export async function syncPushToken() {
  try {
    if (!('Notification' in window) || !('serviceWorker' in navigator)) return false;
    if (!isConfigured() || Notification.permission !== 'granted') return false;
    if (localStorage.getItem(PUSH_FLAG) !== '1') return false;

    const registration = await ensureServiceWorkerReady();
    const { messaging, getToken } = await loadFirebase();
    const token = await getToken(messaging, { vapidKey: VAPID_KEY, serviceWorkerRegistration: registration });
    if (!token) return false;
    await notificationsApi.registerPushToken(token, 'web');
    return true;
  } catch {
    return false;
  }
}

// Service worker pronto (registado E ativo). Guardado para não repetir o trabalho: o getToken do Firebase falha
// com "no active Service Worker" se for pedido antes de o service worker estar ativo, o que acontecia na 1.ª ativação.
let swReadyPromise = null;
function ensureServiceWorkerReady() {
  if (!swReadyPromise) {
    swReadyPromise = navigator.serviceWorker
      .register('/firebase-messaging-sw.js')
      .then(() => navigator.serviceWorker.ready)
      .catch((err) => {
        swReadyPromise = null; // deixa tentar de novo
        throw err;
      });
  }
  return swReadyPromise;
}

async function loadFirebase() {
  const { initializeApp, getApps, getApp } = await import('firebase/app');
  const { getMessaging, getToken } = await import('firebase/messaging');
  const app = getApps().length ? getApp() : initializeApp(firebaseConfig);
  return { messaging: getMessaging(app), getToken };
}

/**
 * Aquece o push SEM pedir permissão: carrega o Firebase e deixa o service worker pronto. A página de Notificações
 * chama isto ao abrir, para que o 1.º toque em "Ativar" já encontre tudo pronto (era isto que fazia falhar à primeira).
 * Nunca lança erro.
 */
export async function prewarmPush() {
  try {
    if (!('Notification' in window) || !('serviceWorker' in navigator) || !isConfigured()) return;
    await Promise.all([ensureServiceWorkerReady(), loadFirebase()]);
  } catch {
    /* só falhou o aquecimento; o toque em "Ativar" tenta outra vez */
  }
}

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

/**
 * Pede permissão de notificação ao usuário e, se concedida, registra o token do dispositivo no backend.
 * Retorna 'unsupported' | 'unconfigured' | 'denied' | 'registered' | 'failed'.
 * 'failed' = a permissão foi dada mas o registo falhou mesmo depois de 3 tentativas (rede, servidor a acordar).
 * Só 'unconfigured' quando faltam mesmo as chaves do Firebase.
 */
export async function requestPushPermission() {
  if (!('Notification' in window) || !('serviceWorker' in navigator)) {
    return 'unsupported';
  }
  if (!isConfigured()) {
    return 'unconfigured';
  }

  try {
    // A permissão é pedida logo de início (o Chrome exige que seja a partir do toque do utilizador).
    const permission = await Notification.requestPermission();
    if (permission !== 'granted') return 'denied';
  } catch {
    return 'failed';
  }

  // 3 tentativas, com pausa curta: na 1.ª ativação o service worker e o Firebase ainda estão a arrancar e o servidor
  // pode estar a acordar (plano gratuito). Só mostra erro se falharem as três.
  const waits = [0, 800, 2000];
  for (let attempt = 0; attempt < waits.length; attempt += 1) {
    if (waits[attempt]) await sleep(waits[attempt]);
    try {
      const registration = await ensureServiceWorkerReady();
      const { messaging, getToken } = await loadFirebase();
      const token = await getToken(messaging, { vapidKey: VAPID_KEY, serviceWorkerRegistration: registration });
      if (token) {
        await notificationsApi.registerPushToken(token, 'web');
        return 'registered';
      }
    } catch {
      /* tenta outra vez */
    }
  }
  return 'failed';
}
