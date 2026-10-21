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

### A. Anúncios (Adcash): o que paga os saques
O dinheiro dos saques (mínimo 100 MZN, cerca de 2 semanas de uso) tem de sair da receita dos anúncios. O dono vai pôr mais anúncios, "de boa forma".
- **Dono, na conta Adcash:** bloquear a categoria Adulto nas 4 zonas (separador *Restrictions*); pedir ao suporte o bloqueio de anúncios enganosos (falso "Flash Player", "vírus"); limitar o intersticial a 1 a cada 10 minutos; confirmar "Disable interstitial countdown" desligado. Interruptor geral de emergência: `VITE_ADS_ENABLED=false` (exige novo deploy do frontend).
- **Claude, quando o dono disser os sítios:** encaixar os anúncios nos pontos escolhidos (pausas naturais: entre quizzes, depois de uma missão, na carteira), nunca a cobrir botões de resposta ou de levantar nem perto de cliques acidentais. Um sítio de cada vez, comparando receita e retorno de utilizadores entre mudanças. **Nunca pedir cliques** em troca de pontos.
- **Claude (proposto, não aprovado):** guardar uma contagem simples por utilizador e por dia de anúncios vistos (sem dados pessoais) para cruzar com o relatório da Adcash e saber se o custo por conta fica abaixo da receita. Primeiro ver no código o que já existe.

### B. Decisões do dono (não implementar sem ele aprovar)
1. **Economia:** conferir se o bónus de boas-vindas (até 12 MZN em 7 dias: 2/1/1/1,5/1,5/2/3) e a conversão de Pontos (até ~50 MZN/dia no teto de 5.000 Pontos) cabem na receita real da Adcash. Se não cabem, ajusta-se o bónus (chave `welcome_rewards_mzn` em `system_config`); não se acrescenta verificação por SMS (decidido: sem SMS).
2. **Regra "Porque" do validador do quiz:** aceitar ou não perguntas cuja explicação não começa assim.
3. **Pedir a ativação do push** logo após o 1.º login ou a 1.ª missão (cartão "Quer receber avisos?"), para subir a adesão. Só recebe push quem tocar em "Ativar".

### B2. Pedido do dono, por fazer (design a confirmar)
- **FE-007 — Ecrã animado ao subir de nível**, com identidade visual. Detalhes e critérios em `frontend/PENDENTE.md`. Falta o dono confirmar o que é "identidade" (marca da plataforma ou dados do utilizador).

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
- **Capacidade:** no plano gratuito aguenta cerca de 50 a 100 pessoas em simultâneo. Antes de lançar a sério: plano pago, worker no Render e teste de carga. (A distância servidor/base já foi resolvida com Frankfurt.)
- **Auditoria do quiz no GitHub:** pôr `npm run quiz:audit` nos testes automáticos. Precisa de permissão `workflow` no token.
- **Aviso duplicado no Chrome:** o teste do Firebase apareceu duas vezes (título e texto genérico). Provável: `notification` + `data` na mesma mensagem. Ver se acontece com avisos reais; se sim, enviar só `data` e deixar o service worker (`frontend/public/firebase-messaging-sw.js`) mostrar.
- **Primeira ativação do push:** na 1.ª tentativa pode aparecer "ainda não estão disponíveis" e logo a seguir "✓ Ativado" (`requestPushPermission()` devolve `unconfigured` em qualquer erro); sugerir uma 2.ª tentativa automática.
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
