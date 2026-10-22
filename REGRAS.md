# REGRAS E DECISÕES FIXAS

Isto são as regras do projeto e as decisões já tomadas pelo dono (Borja). **Não mudam sem ele pedir** e não se voltam a propor.
O que falta fazer está em `INSTRUCOES.md`; o que já foi feito está em `HISTORICO.md`.

## 1. Decisões do dono (não reabrir)

- **DECISÃO DO DONO (21/10/2026): sem verificação por SMS** (custo; mais contas = mais anúncios vistos = mais receita). Não propor de novo. O ponto de atenção que ele conhece: contas repetidas só compensam se o que se paga em prémios (boas-vindas, saques) for menor que a receita dos anúncios dessas contas.
- **DECISÃO DO DONO (21/10/2026):** não trocar já a chave do Firebase nem as passwords do Neon, e não apagar/suspender o que é antigo. Fica assim até ele pedir; não insistir. (Risco conhecido: a chave do Firebase e as passwords passaram por conversas.) Push confirmado a funcionar em 21/10 (`sent: 1`).
- **Modo noite (17/10):** fica só o empréstimo de 10 minutos para contas novas; NÃO criar modo escuro grátis nas Configurações (ver `frontend/PENDENTE.md`).
- **Anúncio intersticial (2026-10-04):** continua com a mesma lógica de antes (`InterstitialAds`, 5 segundos, mesma frequência); não alterar.
- **Tarefas automáticas SEM worker pago (2026-10-11, pedido do dono: sem dinheiro para o worker).** As 11 tarefas de `backend/src/cron/jobs/` correm dentro do backend: um agendador externo gratuito (cron-job.org) chama `POST /internal/cron/tick`, e qualquer acesso real é rede de segurança. Como ligar, conferir e desligar: `docs/agendador-sem-worker.md`. **Não criar o worker pago e o agendador ao mesmo tempo.**
- **Branch paralela do quiz:** existe no GitHub a branch `feat/quiz-aprendizagem` com OUTRA implementação das rodadas (migrations 107, 108 e 109 colidem com as do `main`). **Não fazer merge no `main`** nem copiar migrations dela sem o dono decidir.
- **Quiz v2: conteúdo COMPLETO** (15/10: 1.641 perguntas ativas, 100% com explicação, validador reprova 0). **Não abrir lotes de alternativas nem de explicações novos.** Texto de "RESERVADO" ou "PRÓXIMO lote" no `backend/PENDENTE.md` é histórico; confirmar sempre pelas migrations em `backend/database/migrations/`.

## 2. Infraestrutura atual (Frankfurt, desde 17/10/2026) e como publicar

- **Onde está agora:** backend `teste2-backend-fra` (id `srv-db9qbdnavr4c73f1opt0`, Render **Frankfurt**, `https://teste2-backend-fra.onrender.com`);
  base Neon `aprenda-e-ganhe-frankfurt` (id `ancient-bar-90010031`); Redis `teste2-redis-fra`. Dados copiados e conferidos (linhas iguais);
  latência da base passou de ~130 ms para ~2 ms. O frontend aponta para o backend novo (`VITE_API_URL`) e o cron-job.org também.
- **ATENÇÃO, deploy MANUAL:** o serviço novo tem auto-deploy **desligado**. Depois de cada commit no `main` é preciso mandar publicar
  (Claude usa `trigger_deploy` no `srv-db9qbdnavr4c73f1opt0`; o frontend é `srv-da6u5461egvs73er3m20`). Não assumir "automático".
- **Configuração que o serviço novo EXIGE (fora do repositório, na Render):** `DATABASE_URL` (Neon Frankfurt, ligação direta, com
  `sslmode=require`), `DATABASE_SSL=true`, `REDIS_URL` (endereço interno do Redis `teste2-redis-fra`, id `red-db9r388m7kps73eeb700`; ver a página do Redis na Render),
  `COOKIE_SAMESITE=none`, mais as `FIREBASE_*` (ver "Notificações push"). Num backend novo copiar todas as variáveis do anterior.
- **O site e a API passaram a ser do MESMO endereço (18/10):** no `teste2-frontend` (Render, Redirects/Rewrites) a regra **`/api/*` →
  `https://teste2-backend-fra.onrender.com/api/*` (Rewrite)** tem de ficar **ACIMA** de `/*` → `/index.html` (Rewrite), e
  `VITE_API_URL=https://teste2-frontend.onrender.com/api/v1`. As variáveis `VITE_*` entram na compilação: depois de mudar uma, é preciso
  **novo deploy do frontend** (`trigger_deploy`). Se um dia o backend mudar de endereço, só se altera o destino dessa regra.
- **IP do cliente — RESOLVIDO em 21/10/2026 (aprovado pelo dono em 2026-10-21):** o backend lia o endereço interno da Render (10.x) em vez do
  IP do utilizador, por isso o limitador de pedidos e os registos de auditoria não viam a pessoa real. Medido com um log temporário nos
  pedidos reais pelo site: a cadeia `X-Forwarded-For` tem sempre **6 endereços** (utilizador, Cloudflare duas vezes, proxy da Render, Cloudflare,
  balanceador interno) e o IP do utilizador é o primeiro; conferido com o IP real do dono. Na Render, no `teste2-backend-fra`, a variável
  **`TRUST_PROXY_HOPS=6`** (antes 1, por omissão) faz `req.ip` ser o IP real; verificado em 6 pedidos (login Google, refresh, quiz).
  **Não apagar essa variável.** Contar a partir da direita ignora o que o cliente escreva à esquerda do cabeçalho, mas o 6 é fixo: se a Render
  mudar o número de intermediários, ou se alguém chamar o backend diretamente (cadeia mais curta), o IP lido pode sair errado ou ser forjado.
  Se algo mudar, repetir a medição (log temporário que mostre `req.ip`, `X-Forwarded-For` e o endereço da ligação, ligado por variável).
- **Testes automáticos:** a cada push o GitHub corre `.github/workflows/testes.yml` (migrations num banco novo, testes do backend e build do frontend); o resultado fica na aba **Actions**. Não faz deploy. Se ficar vermelho, ler o relatório antes de continuar.
- **Migrations rodam sozinhas no deploy do backend:** o comando de início é `npm run migrate:up && npm start`. Não é preciso rodar migrations à mão (ver `docs/deploy-render.md`).
- **Do histórico, mas ainda válido:** (1) `IDENTITY_HASH_SECRET` define-se na Render e **nunca se muda** (mudar faz o sistema esquecer as identidades guardadas); (2) não fazer pings periódicos ao banco para o manter acordado (gastam as horas grátis do Neon); (3) limites de pedidos: 60/min por utilizador autenticado, teto de 600/min por IP; login/Google 30/min por IP; cadastro 15/min por IP. O detalhe e a medição estão no `HISTORICO.md` (secção "Deploy de 11/10").

## 3. Regras de negócio

- **DECISÃO DO DONO (21/10/2026): conversão de Pontos = 1.000 Pontos = 5,00 MZN** (era 10,00; migration 721, chave `points_conversion_rate_mzn`). Motivo: com o teto de 5.000 Pontos por dia, fora do teto de 7,20 MZN, dava para chegar aos 100 MZN do saque em ~2 dias; agora o máximo por conversão é 25 MZN por dia. Cada resposta certa vale 10/25/50 Pontos (fácil/médio/difícil), ou seja 0,05/0,125/0,25 MZN. Errar não dá Pontos. Pontos já acumulados convertem à taxa nova. A taxa é lida do servidor (Carteira, "Taxa atual"): não há valor escrito à mão no app. Não reabrir sem o dono.
- **Teto de ganho diário: 7,20 MZN, só das missões** (o utilizador só chega a 7,20 se completar as 6 missões; o valor não é garantido). Prémios de streak em dinheiro e conversão de Pontos em MZN ficam **fora** do teto. Chave `daily_earning_cap_mzn` em `system_config`. Lógica do dono: quem acumula muitos Pontos passou muito tempo na plataforma e viu muitos anúncios, então a receita de anúncios cobre a conversão; por isso ela não tem teto em MZN (o limite é o teto diário de Pontos, `daily_points_cap` = 5000).
- **Bónus de convite: 20% do MZN que cada convidado ganha nas MISSÕES DIÁRIAS, para sempre (regra do dono, 12/10; migration 720, `backend/src/modules/referrals/services/referralBonusService.js`, `tests/referral-bonus.test.js`).** É um extra pago pela plataforma a quem convidou: nada é tirado ao convidado (ele recebe o valor inteiro) e o bónus fica FORA do teto de 7,20 MZN de quem convida (fonte própria `referral_bonus`; o teto só soma `mission_reward`). É 20% do valor REALMENTE creditado ao convidado (se o teto cortar o convidado, o bónus acompanha o corte). Só conta com o convite já qualificado (status `rewarded`) e só em missões `daily` (semanais, especiais, streak e boas-vindas não geram bónus). A percentagem está em `system_config.referral_bonus_percent` (20; 0 desliga). O resgate da missão e o bónus correm na mesma transação, por isso nunca há bónus em duplicado. Aparece no histórico da carteira como "Bónus de convite" e no cartão de convites do Perfil. **Risco conhecido:** convidar contas falsas (a própria pessoa) rende mais 20% por cima do que já se podia farmar; a verificação do telefone por SMS (ideia GER 3) e o saque só pelo número do operador são as defesas principais.
- **Missões diárias:** 6 por dia, 1,20 MZN cada (login, 12 minutos ativos e 4 desafios de quiz).
  O tempo ativo é medido só pelo servidor (heartbeat); o cliente nunca envia tempo.
- **Quiz:** 50 segundos por pergunta (era 30; decisão do dono em 11/10, migration 600), barra fina horizontal.
- **Streak:** quebra de verdade quando o utilizador falta um dia. O item de proteção (marco de 15 dias) perdoa **um único dia perdido, uma só vez**; faltando 2 dias ou mais, o streak quebra e o item continua guardado. Os prémios de streak são um mecanismo de **retenção**: pagam **sempre** que o marco (7, 15, 30, 60, 100 dias) é atingido de novo, sem limite de uma vez por utilizador.
- **Tema Noite emprestado (12/10, decisão do dono):** contas novas recebem 10 minutos de Tema Noite logo depois do cadastro (ecrã de informação e depois "Modo escuro / Modo claro"); o servidor manda no tempo (`users.theme_trial_*`, migration 605, rotas `/shop/theme-trial`), é uma vez por conta e não é compra (não entra no inventário). Escolher "Modo claro" não gasta a oferta (fica um cartão na Loja e nas Configurações). Contas antigas não recebem. O Tema Noite continua à venda na Loja.
- **Bónus de boas-vindas:** calendário de 7 dias, dia 1 = 2,00 MZN, cada dia só é coletado no
  próprio dia, dia perdido fica bloqueado. Valores em `system_config` (`welcome_rewards_mzn`).
  Fica fora do teto diário e é independente de missões e streak. **Não misturar** as duas coisas.
- **Saque mínimo:** 100 MZN (configuração `withdrawal_min_mzn`). O utilizador nunca deposita, só levanta o que ganhou.
  O servidor devolve o valor em `GET /wallet` (`withdrawalMinMzn`) e a Carteira e as Configurações já o leem de lá. **Ficam fixos, de propósito, por serem texto legal publicado:** `frontend/src/pages/Legal.jsx` (Termos, linha ~245, e FAQ, linha ~308) e os documentos em `docs/`. **Se o dono mudar o mínimo**, é preciso atualizar esses textos à mão e decidir, com o dono, se sobe `TERMS_VERSION` (o que obriga todos a reaceitar os Termos, ver `docs/reaceite-termos-e-correcao-regras-saque.md`).
- Dinheiro creditado passa sempre por `walletService.creditReward` (promoções únicas usam `ignoreDailyCap`).
- **Prefixos dos números:** Vodacom (M-Pesa) 84, 85 · Movitel (e-Mola) 86, 87, 88. A regra vive só em `backend/src/common/phone.js` e `frontend/src/lib/phone.js`; para um prefixo novo mude só esses dois ficheiros e os textos de ajuda (Register, CompleteProfile, Legal). Teste: `phone-prefixes.test.js`.
- **Conta do utilizador:** o saque só aceita o método do operador do número registado. Rotas e regras de perfil/senha/eliminar conta estão no `HISTORICO.md` ("Conta do utilizador").
- Este repositório é **público**: nunca escrever senhas, chaves, tokens nem endereços de base de dados em nenhum ficheiro.

## 4. Notificações push (Firebase): configuração e diagnóstico

- **Projeto Firebase:** `aprenda-e-ganhe-3b646` (só app **Web**; Analytics e Gemini desligados). Quando houver app Android, adiciona-se no mesmo projeto.
- **Frontend (Render, variáveis públicas):** `VITE_FIREBASE_API_KEY`, `_AUTH_DOMAIN`, `_PROJECT_ID`, `_MESSAGING_SENDER_ID`, `_APP_ID` e `_VAPID_KEY`. O mesmo config público está em `frontend/public/firebase-messaging-sw.js` (o service worker não lê variáveis do Vite; se o projeto mudar, atualizar os dois sítios).
- **Backend (Render, SECRETAS):** `FIREBASE_PROJECT_ID`, `FIREBASE_CLIENT_EMAIL`, `FIREBASE_PRIVATE_KEY` (com `\n` literais; o `pushService.js` converte). Sem elas o push fica desligado em silêncio. **Nunca** guardar estas chaves em ficheiros, no GitHub nem em chats.
- **Ativar no site:** página Notificações, botão "Ativar" (o botão passa a "✓ Ativado" depois de registar; flag local `push_enabled`). Se o utilizador bloquear, só desbloqueia nas definições do site no Chrome. Nenhum site consegue ativar sozinho: o Chrome exige o "Permitir" de cada pessoa em cada aparelho.
- **FUNCIONA DE PONTA A PONTA (confirmado pelo dono em 21/10/2026):** aviso "Missão concluída!" apareceu no topo do telemóvel. Pelo caminho resolveram-se estas causas, que convém conhecer se voltar a falhar:
  1. **Permissão na Google (a causa real).** A conta de serviço `firebase-adminsdk-fbsvc` estava SEM nenhum papel no projeto, e o envio falhava com `messaging/mismatched-credential` (mensagem enganadora; o texto completo dizia "Permission `cloudmessaging.messages.create` denied"). Corrigido em Google Cloud > IAM > Permitir acesso: principal `firebase-adminsdk-fbsvc@aprenda-e-ganhe-3b646.iam.gserviceaccount.com`, papel **"Administrador da API Firebase Cloud Messaging"** (`roles/firebasecloudmessaging.admin`). Demora 1 a 2 min a valer. Numa conta de serviço nova, repetir isto.
  2. **Conta certa no Google/Firebase:** os links abrem com a conta Google ativa no navegador; um 403 "Your client does not have permission" quer dizer conta errada (trocar na foto de perfil).
  3. **Chave VAPID:** em Firebase > Configurações do projeto > Cloud Messaging > Certificados push da Web há pares de chaves; o par "atual" tem de ser o de `VITE_FIREBASE_VAPID_KEY` (chave pública, não secreta). Hoje é a que começa por `BM9-2j9pm`.
  4. **O aparelho segue a conta com sessão aberta:** `syncPushToken()` (`frontend/src/lib/pushNotifications.js`, chamada pelo `AuthContext` ao iniciar sessão) volta a registar o token na conta atual sem pedir permissão (o servidor move o token no upsert). Sem isto, ao trocar de conta no mesmo navegador o "Ativado" ficava, mas o aviso ia para a conta anterior.
- **Diagnóstico nos logs do backend (Render > Logs):** `WEB: push processado` com `sent: 1` = entregue ao Firebase; `sent: 0` + `pushService: falha ao entregar a um dispositivo` traz `code`, `detail` (texto do erro, sem token) e `projectId` (commit `f936661`). Tokens de aparelhos mortos são apagados sozinhos só quando o erro é `registration-token-not-registered`/`invalid-registration-token`.
- **Onde o aviso aparece:** com o site ABERTO e à frente o Chrome entrega o aviso ao próprio site (não aparece no topo do telemóvel); no topo só aparece com o site fechado ou em segundo plano (uma aba anónima conta como "outro navegador" para este efeito). Ao testar, não concluir a missão com o site à frente.
- **Teste sem esforço:** às 20:00 (Maputo) o agendador envia "Sua ofensiva está em risco!" a quem ainda não fez quiz no dia; é o caso real de uso com o site fechado.
