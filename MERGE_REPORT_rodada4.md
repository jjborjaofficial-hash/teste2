# Relatório de Fusão — Rodada 4 (1.zip + 2.zip + aprenda-e-ganhe.zip)

## Resultado

Dos 3 arquivos desta rodada, 2 eram puro histórico (nada novo em relação à
base já consolidada, Rodada 3):

- `1.zip`: apenas 2 seeds (`001`/`002`) — é a versão inicial mais antiga
  vista até agora no projeto (inclusive com as pastas-lixo literais
  `{controllers,services,...}` de um `mkdir -p` quebrado, já removidas em
  todas as versões posteriores).
- `2.zip`: 64 seeds — idêntico à base consolidada da Rodada 3 menos os 2
  últimos itens dela (`031_remove_duplicate_questions.sql` e
  `065_tecnologia_facil_3.sql`). Snapshot ligeiramente anterior.
- `aprenda-e-ganhe.zip`: **é a própria base consolidada da Rodada 3**
  (reconhecida pelos arquivos `MERGE_REPORT_rodada1/2/3.md` idênticos),
  já com 66 seeds, `render.yaml`, `deploy-render.md` e o doc de status
  atualizado. Usada como base desta rodada.

## Conteúdo novo incorporado

Fora desta rodada, eu (em outra sessão de trabalho, processando lotes
enviados diretamente antes desta reconciliação) já tinha produzido uma
seed exclusiva ainda não vista por esta ramificação:

- **`067_produtividade_medio_6.sql`** — 48 perguntas de Produtividade/Médio
  (continuação "questões 51-100" do mesmo documento que originou o
  `052_produtividade_medio_3.sql`, nível confirmado com o proprietário do
  projeto). Conferidas de novo agora contra as 1.614 perguntas desta
  árvore — zero duplicatas. `source` original (`seed_produtividade_medio_v4`)
  colidia com o `058` desta árvore; renomeado para `v6` (próxima versão
  livre — `v5` já usada no `060`).

## Estado após esta rodada

67 arquivos de seed. Total de perguntas: 1.614 (base, conforme
`docs/banco-de-perguntas-status.md`) + 48 (novo) = **1.662**.
