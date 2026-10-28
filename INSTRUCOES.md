# INSTRUÇÕES — leia isto primeiro

Ponto de partida para quem (pessoa ou IA) vai trabalhar neste repositório. O dono (Borja) só precisa de enviar o
**link do repositório**. A informação está separada em três ficheiros, por tipo:

| Ficheiro | O que tem | Quando ler |
|---|---|---|
| **`INSTRUCOES.md`** (este) | **O que falta fazer**, como, e quem faz (dono ou Claude); o protocolo de trabalho | Sempre, primeiro |
| **`REGRAS.md`** | Regras de negócio, decisões do dono (não reabrir) e a infraestrutura atual (Frankfurt, deploy manual, push) | Antes de mexer em dinheiro, regras ou deploy |
| **`HISTORICO.md`** | O que já foi feito (Quiz v2, conta do utilizador, F5, Frankfurt, etc.). **Não é instrução** | Só para consultar |

Mais os `PENDENTE.md` de cada área (BE-, FE-, ADS-), com instruções técnicas detalhadas.

## O que falta fazer

**Estado em 21/10/2026:** Frankfurt concluído, push a funcionar, quiz completo. Nada abaixo bloqueia o site; é crescimento e arrumação.

### A0. Endereço novo do site (24 a 28/10, feito, falta a Adcash)
O site passou a `https://aprendaeganha.onrender.com` (site Render `aprendaeganha`, `srv-dbe557ks728c7396qr9g`; detalhes em `REGRAS.md`, secção 2). Login normal e login com Google confirmados pelo dono em 28/10. **Falta:** na Adcash, registar o endereço novo e criar as zonas de novo (as atuais estão ligadas ao endereço antigo) e colá-las no painel de anúncios; depois decidir apagar o site antigo `teste2-frontend`.

### A. Anúncios (Adcash): o que paga os saques
O dinheiro dos saques (mínimo 100 MZN, cerca de 2 semanas de uso) tem de sair da receita dos anúncios. O dono vai pôr mais anúncios, "de boa forma".
- **Dono, na conta Adcash:** bloquear a categoria Adulto nas 4 zonas (separador *Restrictions*); pedir ao suporte o bloqueio de anúncios enganosos (falso "Flash Player", "vírus"); limitar o intersticial a 1 a cada 10 minutos; confirmar "Disable interstitial countdown" desligado. Interruptor geral de emergência: `VITE_ADS_ENABLED=false` (exige novo deploy do frontend).
- **Claude, quando o dono disser os sítios:** encaixar os anúncios nos pontos escolhidos (pausas naturais: entre quizzes, depois de uma missão, na carteira), nunca a cobrir botões de resposta ou de levantar nem perto de cliques acidentais. Um sítio de cada vez, comparando receita e retorno de utilizadores entre mudanças. **Nunca pedir cliques** em troca de pontos.
- **Claude (proposto, não aprovado):** guardar uma contagem simples por utilizador e por dia de anúncios vistos (sem dados pessoais) para cruzar com o relatório da Adcash e saber se o custo por conta fica abaixo da receita. Primeiro ver no código o que já existe.

### A2. Painel de administração (22 e 23/10, feito)
- **Acesso:** a conta tem o papel `admin_master` (só a do dono). No Perfil aparece o escudo no canto de cima à esquerda (só para papéis `admin_*`); leva a `/admin/acesso`, onde se confirma número ou Gmail da conta + a **senha de administrador** (própria, diferente da de login; na 1.ª vez cria-se; migration 740, `users.admin_password_hash`). Vale 30 min (token `X-Admin-Access`); o servidor só o exige a quem já criou essa senha. **Falta:** botões de trocar e de recuperar a senha de admin (hoje, se esquecer, limpa-se `admin_password_hash` na base).
- **Visão geral** (`/admin`, `GET /admin/overview`), menu em painel que sobe de baixo e barra de 6 botões. Papéis: `admin_master`, `admin_financeiro`, `admin_suporte`, `admin_juridico`.
- **Anúncios** (`/admin/anuncios`, só `admin_master`; migration 741, tabela `ad_slots`; `GET /ads/config` pública): um campo por local (Início, Hub de Estudos, Carteira, Resultado do quiz, Vídeo, Pop-under, In-page push). Só aceita código Adcash (`aclib.run...({ zoneId })`, validado; nunca se executa script arbitrário). Interruptor geral começa DESLIGADO. `VITE_ADS_ENABLED=false` seria o interruptor de emergência (hoje está `true`).
- **Prova social:** só dados reais ("Mais de X", por marcos 5, 10, 20, 50, 100...). Os números fixos 12.000/46.000 e o contador simulado foram retirados (decisão de honestidade com quem se regista; não voltar a pôr).
- **Ainda por fazer no painel:** Regras do jogo (bónus, taxa dos Pontos, teto, saque mínimo), Alertas de risco (contas repetidas), Receita dos anúncios vs prémios.

### B. Decisões do dono (não implementar sem ele aprovar)
1. **Economia:** conferir se o bónus de boas-vindas (até 10 MZN em 7 dias: 2/1/1/1/1,5/1,5/2; eram 12 até 21/10) e a conversão de Pontos (até ~25 MZN/dia no teto de 5.000 Pontos; 1.000 Pontos = 5 MZN desde 21/10) cabem na receita real da Adcash. Se não cabem, ajusta-se o bónus (chave `welcome_rewards_mzn` em `system_config`); não se acrescenta verificação por SMS (decidido: sem SMS).
2. **Regra "Porque" do validador do quiz:** aceitar ou não perguntas cuja explicação não começa assim.
3. **Pedir a ativação do push** logo após o 1.º login ou a 1.ª missão (cartão "Quer receber avisos?"), para subir a adesão. Só recebe push quem tocar em "Ativar".

### C. Dono: testar e conferir (5 min cada)
- Definições em produção: funcionalidades novas, prefixo 88 e campo de telefone de 9 dígitos.
- No cron-job.org, conferir o intervalo do agendador (5 ou 15 minutos; 15 poupa as horas grátis do Neon).

### D. Segurança e arrumação: ADIADO por decisão do dono (21/10); só fazer quando ele pedir
Risco conhecido: a chave do Firebase e as passwords das bases passaram por conversas.
1. Trocar a chave do servidor do Firebase: Firebase > Configurações do projeto > Contas de serviço > Gerar nova chave privada; colar `private_key` e `client_email` só na Render (`teste2-backend-fra` > Environment), sem passar pelo chat; apagar as chaves antigas em Google Cloud > IAM > Contas de serviço > `firebase-adminsdk-fbsvc` > Chaves; apagar o `.json` do telemóvel.
2. Trocar as passwords do Neon (Roles > Reset password) e atualizar o `DATABASE_URL` do backend novo na Render.
3. Apagar no GitHub os secrets `OLD_DATABASE_URL` e `NEW_DATABASE_URL` e o token pessoal que foi colado.
4. Servidor antigo `teste2-backend` (Oregon, `srv-da6pe0h42hec73dskbs0`): parado e sem tráfego desde 18/10. Se quiser, suspender (não apagar) e, mais tarde, apagar a base Neon de Londres (`summer-glitter-52566854`).
**Nunca escrever endereços nem passwords em ficheiros do repositório.**

### E. Técnico (Claude faz quando o dono pedir)
- **Capacidade (medido em 24/10, `docs/teste-de-carga-2026-10.md`):** confortável com ~30 a 50 pessoas ativas ao mesmo tempo; com 100 o painel fica lento (5 a 8 s). O maior risco são os **logins/registos** (bcrypt 12 = 258 ms de CPU, ~23 por minuto na Render gratuita). Melhorias possíveis, por decidir com o dono: bcrypt 12 → 10/11 (decisão de segurança), otimizar `GET /missions`, reduzir o gasto do servidor parado (16% do orçamento), plano pago da Render (~5x).
- **Auditoria do quiz no GitHub:** pôr `npm run quiz:audit` nos testes automáticos. Precisa de permissão `workflow` no token.
- **Aviso duplicado no Chrome:** o teste do Firebase apareceu duas vezes (título e texto genérico). Provável: `notification` + `data` na mesma mensagem. Ver se acontece com avisos reais; se sim, enviar só `data` e deixar o service worker (`frontend/public/firebase-messaging-sw.js`) mostrar.
- **Contas Google novas** precisam de telefone e de aceitar documentos (fricção no cadastro, decisão de produto, não é erro).
- **Arrumar `backend/PENDENTE.md`** (207 linhas, com blocos já concluídos).
- **Auto-deploy:** o serviço novo é manual por escolha; só mudar se o dono pedir.

## Como funciona (protocolo)

1. **Clonar e ler.** Ao receber o link: clone o repositório e leia este ficheiro e todos os
   `PENDENTE.md` (`find . -name PENDENTE.md -not -path "*/node_modules/*"`).
2. **Resumir ao dono.** Diga, em poucas linhas, o que está pendente em cada área. O quiz tem
   uma secção própria com a ordem de execução: **"Quiz v2 — estado e próximos passos"** (abaixo).
3. **Executar só o que o dono pedir.** Tudo o que está nos `PENDENTE.md` é real e foi
   decidido pelo dono, mas a ordem e o momento são dele. Se ele disser "faz tudo", faça por
   ordem de ID. Dúvida em regra de negócio, dinheiro, segurança ou apagar dados: **pergunte antes**.
4. **Testar de verdade.** Rode os testes (`backend`: `npm test`, precisa de PostgreSQL e Redis;
   `frontend`: `npm run build`) e, quando mexer em regra de dinheiro, teste com dados reais.
5. **Apagar a instrução concluída.** Quando uma tarefa estiver feita e testada, **remova-a do
   `PENDENTE.md` e deste ficheiro no mesmo commit** que a implementa. Se vale a pena lembrar como
   foi feita, escreva uma linha em `HISTORICO.md`; o resto fica no `git log`. A mensagem do commit cita o ID (ex.: `BE-003`).
6. **Se ficar vazio**, mantenha o cabeçalho do ficheiro e a linha "Nenhuma instrução pendente.".
7. **Publicar.** O `git push` precisa de um token do GitHub que o dono cria só para isso
   (Fine-grained, só este repositório, **Contents: Read and write**, validade curta) e apaga
   depois. O token **nunca** é escrito neste repositório.
8. **Push por checkpoint, nunca com código quebrado.** Faça commit e `git push` quando uma
   funcionalidade importante ou uma etapa estrutural fechar (testada), ou a cada ~5
   alterações significativas (testar, ver erros, revisar o diff, commit, push, continuar).
   Nunca acumule trabalho para publicar tudo no fim e nunca publique código quebrado só para
   "chegar a 5": a qualidade vem primeiro. Motivo: se a sessão acabar ou o limite for
   atingido a meio, o que já foi concluído já está no GitHub e o que falta continua escrito
   nos `PENDENTE.md`. Antes de cada push: `git status`, branch certa, `git diff`, testes e
   nenhum segredo. Depois, relate: CHECKPOINT, IMPLEMENTADO, TESTADO, COMMIT, PUSH, PRÓXIMO
   BLOCO. Mensagens de commit descritivas (nada de "update" ou "fix" soltos).

## Onde ficam as instruções

| Área | Ficheiro | Prefixo |
|---|---|---|
| Geral / vários módulos | `INSTRUCOES.md` (este, secção "O que falta fazer") | GER- |
| Backend (API, regras, base de dados) | `backend/PENDENTE.md` | BE- |
| Frontend (telas e componentes) | `frontend/PENDENTE.md` | FE- |
| Anúncios (Adcash) | `frontend/src/ads/PENDENTE.md` | ADS- |

Se uma tarefa nova não encaixar em nenhuma área, crie um `PENDENTE.md` na pasta certa
(por exemplo `backend/src/modules/wallet/PENDENTE.md`) e acrescente-o a esta tabela.

## Formato de cada instrução

```
## BE-001 — Título curto
- Pedido: o que o dono quer, nas palavras dele.
- Onde mexer: caminhos prováveis.
- Pronto quando: como saber que está certo (critérios que dá para testar).
- Cuidados: dinheiro, segurança, migrations, o que NÃO misturar.
```
