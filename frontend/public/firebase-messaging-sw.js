/* eslint-disable no-undef */
// Service Worker do Firebase Cloud Messaging — precisa estar na raiz pública
// (não em /src) porque o navegador só permite escopo de Service Worker até
// onde o arquivo está servido. Sem isso, notificações push NUNCA aparecem
// quando o navegador/aba está em segundo plano (só com o app aberto e em foco).
//
// ⚠️ PREENCHER MANUALMENTE no dia da credencial — Service Workers não
// recebem variáveis de ambiente do Vite (VITE_*), por isso os valores não
// podem vir de import.meta.env aqui. Copie os MESMOS valores usados em
// src/lib/pushNotifications.js / .env (VITE_FIREBASE_*).
importScripts('https://www.gstatic.com/firebasejs/10.13.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.13.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'PREENCHER',
  authDomain: 'PREENCHER',
  projectId: 'PREENCHER',
  messagingSenderId: 'PREENCHER',
  appId: 'PREENCHER',
});

const messaging = firebase.messaging();

// Notificação recebida com o app em segundo plano (aba fechada/minimizada).
// Com o app em primeiro plano, o SDK entrega via evento 'onMessage' no app
// normal, não aqui — por isso não há duplicação de notificação.
messaging.onBackgroundMessage((payload) => {
  const { title, body } = payload.notification || {};
  self.registration.showNotification(title || 'Aprenda e Ganhe', {
    body: body || '',
    icon: '/icon-192.png',
    data: payload.data,
  });
});
