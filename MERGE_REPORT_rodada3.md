# Relatório de Fusão — Rodada 3 (3.zip + 4.zip + 5.zip)

## Resultado

Nenhum dos 3 tinha conteúdo genuinamente novo em relação à base já
consolidada (Rodada 2). Todos são snapshots mais antigos:

- `3.zip`: 64 seeds (base tem 66) — só README/status doc desatualizados
- `4.zip`: **é a minha própria entrega da Rodada 1** (identificado pelo
  `render.yaml` com apenas 5 seeds e pelo `MERGE_REPORT.md` idêntico)
- `5.zip`: 44 seeds — mesma situação, só documentação desatualizada

## Erro meu, corrigido nesta rodada

Ao montar a Rodada 2, copiei `render.yaml`/`.gitignore`/`deploy-render.md`
da Rodada 1 para a nova base, mas **esqueci de trazer o
`MERGE_REPORT.md` da Rodada 1 junto**. `4.zip` (sendo a própria entrega da
Rodada 1) permitiu recuperar esse arquivo, renomeado para
`MERGE_REPORT_rodada1.md` para não colidir com `MERGE_REPORT_rodada2.md`.

## Achado técnico (sem impacto na base atual, já estava corrigido)

A versão de `003_tecnologia_facil.sql` no `4.zip` (Rodada 1) usa
`CREATE TEMP TABLE ... AS INSERT INTO ... RETURNING ...` sem envolver num
`WITH ... AS (...)` — isso **não é sintaxe válida em PostgreSQL**
(`CREATE TABLE AS` só aceita SELECT/TABLE/VALUES/EXECUTE, não INSERT
diretamente). A base atual já usa o padrão correto
(`WITH inserted AS (INSERT ... RETURNING ...) SELECT * FROM inserted`) em
todos os 66 seeds — confirmado por varredura em todos os arquivos, não só
nos 3 que apareceram na comparação.

## Validação
- Sintaxe (`node --check`): sem erros
- Migrations: 001 a 031, sem lacuna
