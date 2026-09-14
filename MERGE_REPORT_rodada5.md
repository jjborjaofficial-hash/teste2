# Relatório de Fusão — Rodada 5 (aprenda-.zip + g.zip + aprenda-e-ganhe.zip)

## Contexto

O proprietário do projeto enviou 3 zips simultaneamente pedindo uma versão
única, coerente, baseada apenas nesses 3 arquivos (sem misturar com
qualquer estado anterior fora deles).

## Comparação entre os 3 arquivos

- `aprenda-.zip`: 67 arquivos de seed (até `067_produtividade_medio_6.sql`),
  contém os relatórios `MERGE_REPORT_rodada1/2/3/4.md`. É a Rodada 4 já
  consolidada por outra sessão de trabalho.
- `g.zip`: 66 arquivos de seed (até `066`), contém `MERGE_REPORT_rodada1/2/3.md`.
  Idêntico à Rodada 3 (um passo atrás de `aprenda-.zip`).
- `aprenda-e-ganhe.zip`: idêntico a `g.zip`, com 2 arquivos-lixo duplicados
  (`Card (2).jsx`, `Toast (2).jsx` — cópias byte-a-byte de `Card.jsx` e
  `Toast.jsx`, artefato do zip, sem conteúdo novo) e nada mais de diferente.

**Diff binário confirmado:** os seeds `001` a `066` são byte-a-byte
idênticos nos 3 arquivos. `g.zip` e `aprenda-e-ganhe.zip` são idênticos em
TODOS os outros arquivos também (exceto os 2 arquivos-lixo). `aprenda-.zip`
é a única com conteúdo genuinamente adicional: o seed `067`, o
`MERGE_REPORT_rodada4.md`, e uma versão diferente de
`docs/banco-de-perguntas-status.md` refletindo esse conteúdo extra.

**Conclusão:** `aprenda-.zip` já era um superconjunto estrito dos outros
dois. Não havia peças exclusivas em `g.zip` ou `aprenda-e-ganhe.zip` para
recuperar — a fusão, neste caso, foi validar e corrigir essa base, não
combinar partes divergentes.

## Bug real encontrado e corrigido (não estava em nenhum relatório anterior)

Testei a base completa do zero contra um PostgreSQL real (migrations +
67 seeds). A migration `031_remove_duplicate_questions.sql` roda durante
`migrate up`, **antes** de qualquer seed inserir dados — então, no fluxo
normal de deploy, ela nunca encontra as 3 duplicatas de Tecnologia Fácil
que só passam a existir depois, quando os seeds `003`/`005` rodam. A
suposição registrada em `docs/banco-de-perguntas-status.md` (de que a
migration removia as 3 duplicatas em tempo de execução) não se confirmava
na prática.

**Correção:** as 3 perguntas duplicadas foram removidas diretamente de
`005_tecnologia_facil_2.sql` (na fonte). Arquivo passa de 50 para 47
perguntas. `docs/banco-de-perguntas-status.md` atualizado para refletir a
causa raiz e a correção real, não mais a suposição antiga.

## Verificação (Postgres real, do zero, duas vezes)

- 30 migrations aplicadas sem erro
- 67 seeds aplicados sem erro
- 0 perguntas com número de alternativas diferente de 4
- 0 perguntas com número de alternativas corretas diferente de 1
- 0 duplicatas (texto normalizado, mesma categoria+dificuldade) — antes da
  correção eram 3; confirmado voltar a 0 após a correção
- Idempotência: reexecução completa dos 67 seeds não altera nenhuma
  contagem de produção (só o seed de exemplo `001`, não-idempotente por
  design, adiciona +2 como já documentado)

## Estado final

67 arquivos de seed. **1.662 perguntas de produção**, 0 duplicatas reais,
100% íntegras. Ver `docs/banco-de-perguntas-status.md` para a tabela
completa por categoria e dificuldade.
