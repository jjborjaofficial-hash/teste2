# INSTRUÇÕES — leia isto primeiro

Este ficheiro é o ponto de partida para quem (pessoa ou IA) vai trabalhar neste repositório.
O dono do projeto (Borja) só precisa de enviar o **link do repositório**: tudo o que está
por fazer fica escrito aqui e nos ficheiros `PENDENTE.md` de cada área.

## Como funciona (protocolo)

1. **Clonar e ler.** Ao receber o link: clone o repositório e leia este ficheiro e todos os
   `PENDENTE.md` (`find . -name PENDENTE.md -not -path "*/node_modules/*"`).
2. **Resumir ao dono.** Diga, em poucas linhas, o que está pendente em cada área.
3. **Executar só o que o dono pedir.** Tudo o que está nos `PENDENTE.md` é real e foi
   decidido pelo dono, mas a ordem e o momento são dele. Se ele disser "faz tudo", faça por
   ordem de ID. Dúvida em regra de negócio, dinheiro, segurança ou apagar dados: **pergunte antes**.
4. **Testar de verdade.** Rode os testes (`backend`: `npm test`, precisa de PostgreSQL e Redis;
   `frontend`: `npm run build`) e, quando mexer em regra de dinheiro, teste com dados reais.
5. **Apagar a instrução concluída.** Quando uma tarefa estiver feita e testada, **remova-a do
   `PENDENTE.md` no mesmo commit** que a implementa. Não deixe histórico de tarefas feitas
   nos ficheiros: o histórico é o `git log`. A mensagem do commit cita o ID (ex.: `BE-003`).
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
| Geral / vários módulos | `INSTRUCOES.md` (este, secção abaixo) | GER- |
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

## Regras fixas do projeto (não quebrar sem o dono pedir)

- **Teto de ganho diário: 7,20 MZN, só das missões** (o utilizador só chega a 7,20 se completar as 6 missões; o valor não é garantido). Prémios de streak em dinheiro e conversão de Pontos em MZN ficam **fora** do teto. Chave `daily_earning_cap_mzn` em `system_config`. Lógica do dono: quem acumula muitos Pontos passou muito tempo na plataforma e viu muitos anúncios, então a receita de anúncios cobre a conversão; por isso ela não tem teto em MZN (o limite é o teto diário de Pontos, `daily_points_cap` = 5000).
- **Missões diárias:** 6 por dia, 1,20 MZN cada (login, 12 minutos ativos e 4 desafios de quiz).
  O tempo ativo é medido só pelo servidor (heartbeat); o cliente nunca envia tempo.
- **Quiz:** 30 segundos por pergunta, barra fina horizontal.
- **Streak:** quebra de verdade quando o utilizador falta um dia. O item de proteção (marco de 15 dias) perdoa **um único dia perdido, uma só vez**; faltando 2 dias ou mais, o streak quebra e o item continua guardado. Os prémios de streak são um mecanismo de **retenção**: pagam **sempre** que o marco (7, 15, 30, 60, 100 dias) é atingido de novo, sem limite de uma vez por utilizador.
- **Bónus de boas-vindas:** calendário de 7 dias, dia 1 = 2,00 MZN, cada dia só é coletado no
  próprio dia, dia perdido fica bloqueado. Valores em `system_config` (`welcome_rewards_mzn`).
  Fica fora do teto diário e é independente de missões e streak. **Não misturar** as duas coisas.
- **Saque mínimo:** 100 MZN. O utilizador nunca deposita, só levanta o que ganhou.
- **Deploys no Render são manuais**: o auto-deploy está ligado, mas na prática nenhum push
  dispara deploy sozinho (todos os deploys recentes foram manuais). Depois de dar push, é preciso
  fazer o deploy de `teste2-backend` e `teste2-frontend`.
- **Migrations rodam sozinhas no deploy do backend**: o comando de início do `teste2-backend` é
  `npm run migrate:up && npm start`. Não é preciso rodar migrations à mão (ver `docs/deploy-render.md`).
- Dinheiro creditado passa sempre por `walletService.creditReward` (promoções únicas usam
  `ignoreDailyCap`).
- Este repositório é **público**: nunca escrever senhas, chaves ou tokens em nenhum ficheiro.

## Pendente — geral (GER-)

## GER-001 — Confirmar em produção que a sessão não se perde ao atualizar a página (F5)
- Pedido: o bug mais importante apontado pelo dono e por um amigo testador: depois do login,
  ao atualizar a página (F5), o app voltava para "Iniciar sessão".
- Já feito (não repetir): causa = cookie do refresh token com `SameSite=strict` enquanto
  frontend e backend ficam em subdomínios diferentes de `onrender.com`. Corrigido com
  `COOKIE_SAMESITE=none` no `render.yaml` (commit `4fc79ad`), nota em `docs/deploy-render.md`,
  e a variável já foi aplicada no serviço `teste2-backend` do Render (deploy Live).
- Falta: o dono (e o amigo) confirmarem no ar: sair, entrar de novo (obrigatório, cookie
  antigo), atualizar a página em várias telas e continuar logado.
- Se ainda cair no login só no Safari/iPhone: navegadores bloqueiam cookies entre sites mesmo
  com `none`. Solução definitiva = domínio próprio com frontend e API no mesmo site (ex.:
  `app.dominio.com` e `api.dominio.com`) e `COOKIE_SAMESITE=lax`/`strict`. Explicar o passo a
  passo ao dono antes de mexer em DNS ou serviços.
- Cuidados: nunca escrever tokens neste repositório. Os nomes dos serviços reais no Render são
  `teste2-backend` e `teste2-frontend` (diferentes dos do `render.yaml`); confira
  `CORS_ALLOWED_ORIGINS` no painel antes de supor algo.

## Próximos passos sugeridos (ainda NÃO decididos — não implementar até o dono pedir)

Isto não são instruções: são pontos já conversados que o dono ainda não aprovou, na
ordem de prioridade sugerida. Quando ele aprovar um, passa a ser uma instrução na área certa
(`BE-`, `FE-`, `ADS-` ou `GER-`) e sai desta lista.

1. Teto diário das missões: bloquear a linha do utilizador antes de somar os ganhos do dia, para dois pedidos simultâneos não furarem o teto (dinheiro).
2. Carteira/Legal: ler o saque mínimo da API (`withdrawal_min_mzn`) em vez de fixar 100 MZN no código.
3. Cadastro: verificar o telefone por SMS (Twilio já está nas dependências) para evitar contas falsas.
4. Economia: conferir se o bónus de boas-vindas (12,00 MZN por utilizador) e a conversão de Pontos (até ~50 MZN/dia por utilizador no teto de 5.000 Pontos) cabem na receita real de anúncios (Adcash).
5. Testes para boas-vindas e carteira; fazer o push disparar o deploy sozinho (hoje é manual) e pôr um `healthCheckPath` no backend.
6. Editar nome, foto e provedor de pagamento (M-Pesa / e-Mola) no perfil — precisa de endpoint novo e regras de segurança, porque o provedor define para onde o dinheiro vai.
7. Eliminar a conta do utilizador.
