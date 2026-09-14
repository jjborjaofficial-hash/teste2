# Changelog — Rodada 3 de consolidação (c__1_, c__2_, c__3_)

## Resultado: nenhuma mudança de código nesta rodada

Das 3 partes enviadas:

- **`c__1_.zip`** e **`c__3_.zip`**: confirmadas, função por função e
  arquivo por arquivo, como **fotos mais antigas da mesma linhagem** já
  consolidada aqui. Checagem feita em todos os módulos com arquivos
  divergentes (`quiz`, `shop`, `wallet`, `notifications`, cron jobs,
  frontend) comparando funções exportadas (todas as sintaxes: `function`,
  `const x = () =>`, `exports.x`) — **zero função existe nessas duas partes
  que não exista também na mainline**. Onde os arquivos diferiam em
  tamanho, a mainline era sempre igual ou maior (exemplos: `Wallet.jsx`
  236×154 linhas, `MeusRecursos.jsx` 408×194 linhas, `package.json` com
  `bullmq`/fila de trabalho que essas partes não tinham). Nada foi
  incorporado por não haver nada de novo a incorporar.

- **`c__2_.zip`**: veio corrompida (mesmo arquivo, mesmo ponto de corte, já
  visto e reparado no início deste projeto de consolidação). Reparada com
  sucesso (199/199 arquivos recuperados), mas confirmada como pertencente a
  uma **linhagem arquiteturalmente incompatível** — schema de banco
  diferente (sem coluna `source`, sem pasta `docs/`), seeds em formato CTE
  em vez de blocos `DO $$`. Não é uma versão "atrás", é uma ramificação
  paralela que nunca convergiu com a linhagem principal.

  A única funcionalidade exclusiva dessa linhagem identificada até agora —
  "Tentativa Extra" (limite diário de tentativas do Quiz + item de loja
  para liberar mais uma tentativa) — foi **explicitamente descartada** a
  pedido do proprietário do projeto nesta rodada. Não foi recriada na
  mainline.

## Estado da árvore consolidada

Sem alterações de código ou de banco de perguntas nesta rodada. Segue em
1.566 perguntas, 64 arquivos de seed, mesma estrutura de módulos já
documentada nos changelogs anteriores.
