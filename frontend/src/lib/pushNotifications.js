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

function isConfigured() {
  return Boolean(firebaseConfig.apiKey && firebaseConfig.projectId && VAPID_KEY);
}

/**
 * Pede permissão de notificação ao usuário e, se concedida, registra o
 * token do dispositivo no backend. Retorna 'unsupported' | 'unconfigured' |
 * 'denied' | 'registered' — o chamador decide o que mostrar, se algo.
 */
export async function requestPushPermission() {
  if (!('Notification' in window) || !('serviceWorker' in navigator)) {
    return 'unsupported';
  }
  if (!isConfigured()) {
    return 'unconfigured';
  }

  try {
    const permission = await Notification.requestPermission();
    if (permission !== 'granted') return 'denied';

    // Imports dinâmicos: se `firebase` não estiver instalado ainda, o resto
    // do app continua funcionando — só esta função falha silenciosamente.
    const { initializeApp } = await import('firebase/app');
    const { getMessaging, getToken } = await import('firebase/messaging');

    const app = initializeApp(firebaseConfig);
    const messaging = getMessaging(app);
    const registration = await navigator.serviceWorker.register('/firebase-messaging-sw.js');
    const token = await getToken(messaging, { vapidKey: VAPID_KEY, serviceWorkerRegistration: registration });

    if (token) {
      await notificationsApi.registerPushToken(token, 'web');
      return 'registered';
    }
    return 'denied';
  } catch {
    // Pacote não instalado, Service Worker indisponível, rede falhou, etc.
    // — nunca deixa isso quebrar o restante do app.
    return 'unconfigured';
  }
}
