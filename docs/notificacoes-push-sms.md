# Notificações Push e SMS — Guia de Ativação

## Status atual

✅ Infraestrutura pronta (backend + frontend + fila + documentação)
🔲 Credenciais reais (Firebase e Twilio) — dependem de você criar as contas

Até as credenciais existirem, a plataforma funciona 100% normalmente. Push e
SMS operam em **modo silencioso**: a notificação continua sendo salva em
`notifications` (aparece no sino do app) e nenhum erro aparece em lugar
nenhum — só não sai nada pelo canal externo.

## O que já está pronto

- **Fila de entrega** (`src/queue/deliveryQueue.js` + `deliveryWorker` em
  `src/queue/worker.js`): toda notificação já dispara uma tentativa de push
  automaticamente (via `notificationsRepository.create`), sem bloquear quem
  chamou. SMS é enviado especificamente na confirmação de saque pago
  (`notificationsService.notifyWithdrawalStatus`).
- **Tabela `push_tokens`** (migration 032): já recebe tokens quando o
  frontend chama `POST /notifications/push-tokens`. Tokens inválidos/expirados
  são removidos automaticamente pelo próprio `pushService` quando o FCM
  reportar isso.
- **Botão "Ativar" na tela de Notificações** (frontend): já chama
  `requestPushPermission()`, que pede permissão do navegador e registra o
  token — só não tem efeito prático até a Parte 2 abaixo estar preenchida.
- **`.env.example`** (backend e frontend): já lista exatamente quais
  variáveis faltam, com onde encontrar cada uma.

## O que fazer no dia da credencial

### Parte 1 — Firebase (push)

1. Criar um projeto em [console.firebase.google.com](https://console.firebase.google.com) (gratuito).
2. **Backend**: Configurações do Projeto → Contas de Serviço → "Gerar nova
   chave privada" → baixa um `.json`. Copiar `project_id`, `client_email` e
   `private_key` desse arquivo para `FIREBASE_PROJECT_ID`,
   `FIREBASE_CLIENT_EMAIL` e `FIREBASE_PRIVATE_KEY` no `.env` do backend.
3. **Frontend**: Configurações do Projeto → Geral → "Seus apps" → adicionar
   um app Web → copiar os valores para `VITE_FIREBASE_*` no `.env` do
   frontend.
4. **VAPID key**: Configurações do Projeto → Cloud Messaging → "Certificados
   push da Web" → gerar par de chaves → copiar para `VITE_FIREBASE_VAPID_KEY`.
5. Copiar os mesmos 5 valores do passo 3 para dentro de
   `frontend/public/firebase-messaging-sw.js` (Service Workers não recebem
   variáveis de ambiente do Vite — é por isso que aparece duplicado).
6. `cd backend && npm install` (instala `firebase-admin`, já no `package.json`).
7. `cd frontend && npm install` (instala `firebase`, já no `package.json`).
8. Reiniciar o backend e o `npm run worker`.

Pronto — a partir daqui, todo `notificationsRepository.create()` já dispara
push automaticamente para quem tiver token registrado.

### Parte 2 — Twilio (SMS)

1. Criar conta em [twilio.com](https://www.twilio.com) e comprar um número
   (ou usar o número de teste gratuito, que só envia para números
   verificados — ok para testar, não para produção).
2. Copiar `Account SID`, `Auth Token` e o número comprado para
   `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN` e `TWILIO_FROM_NUMBER` no `.env`
   do backend.
3. `npm install` (instala `twilio`, já no `package.json`).
4. Reiniciar o `npm run worker`.

## Testando

```bash
# Backend: confirma que as credenciais foram lidas corretamente
node -e "require('dotenv').config(); require('./src/common/notifications/pushService').sendToUser('SEU_USER_ID', {title:'Teste', body:'Funcionou!'}, require('./src/modules/notifications/repositories/pushTokensRepository')).then(console.log)"
```

Se aparecer `{ sent: 1, skipped: false }`, está funcionando. Se aparecer
`{ sent: 0, skipped: true }`, alguma variável de ambiente ainda está vazia.

## Próximos passos (fora do escopo desta preparação)

- **OTP por SMS no cadastro**: reaproveitaria exatamente `smsService.sendSms()`
  — falta só o fluxo de gerar/validar o código (tabela `otp_codes`, endpoint
  de verificação). Ver `docs/` sobre pendências gerais da plataforma.
- **Preferências de notificação por tipo** (deixar o usuário desligar só
  "streak em risco", por exemplo, mantendo o resto): hoje é tudo ou nada —
  se o token está registrado, todo tipo de notificação tenta push.
- **Push nativo (iOS/Android)**: a tabela `push_tokens` já tem a coluna
  `platform` pronta para isso; falta o app nativo em si, que está fora do
  escopo atual (plataforma é web/PWA).
