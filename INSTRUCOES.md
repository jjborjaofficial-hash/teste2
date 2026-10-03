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
8. **Um push por tarefa concluída.** Assim que UMA tarefa estiver feita e testada, faça o
   commit e o `git push` dela, antes de começar a seguinte. Nunca acumule várias tarefas para
   publicar tudo no fim. Motivo: se a sessão acabar ou o limite de uso for atingido a meio, o
   que já foi concluído já está no GitHub (e pode ser testado ao vivo), e o que falta continua
   escrito no `PENDENTE.md` para a próxima sessão retomar sem o dono explicar de novo.

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

- **Teto de ganho diário: 7,20 MZN** (missões + streak). Chave `daily_earning_cap_mzn` em `system_config`.
- **Missões diárias:** 6 por dia, 1,20 MZN cada (login, 12 minutos ativos e 4 desafios de quiz).
  O tempo ativo é medido só pelo servidor (heartbeat); o cliente nunca envia tempo.
- **Quiz:** 30 segundos por pergunta, barra fina horizontal.
- **Streak:** quebra de verdade quando o utilizador falta um dia (o item de proteção perdoa um dia).
- **Bónus de boas-vindas:** calendário de 7 dias, dia 1 = 2,00 MZN, cada dia só é coletado no
  próprio dia, dia perdido fica bloqueado. Valores em `system_config` (`welcome_rewards_mzn`).
  Fica fora do teto diário e é independente de missões e streak. **Não misturar** as duas coisas.
- **Saque mínimo:** 100 MZN. O utilizador nunca deposita, só levanta o que ganhou.
- **Migrations não correm sozinhas no deploy** (Render): depois de publicar código que traz uma
  migration nova, rodar `npm run migrate:up` no backend (ver `docs/deploy-render.md`).
- Dinheiro creditado passa sempre por `walletService.creditReward` (promoções únicas usam
  `ignoreDailyCap`).
- Este repositório é **público**: nunca escrever senhas, chaves ou tokens em nenhum ficheiro.

## Pendente — geral (GER-)

Nenhuma instrução pendente.

## Ideias ainda NÃO decididas (não implementar até o dono pedir)

Isto não são instruções: são pontos já conversados que o dono ainda não aprovou.
Quando ele aprovar um, passa a ser uma instrução na área certa.

- Editar nome, foto e provedor de pagamento (M-Pesa / e-Mola) no perfil — precisa de endpoint novo e regras de segurança, porque o provedor define para onde o dinheiro vai.
- Eliminar a conta do utilizador.
- Conferir se os valores do calendário de boas-vindas (total 12,00 MZN por utilizador) cabem na receita real do Adcash.
