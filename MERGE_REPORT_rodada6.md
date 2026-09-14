# Relatório de Fusão — Rodada 6 (aprenda-e-ganhe.zip + y.zip)

## Contexto

O proprietário do projeto enviou 2 arquivos (confirmou que eram os únicos,
não 3 como mencionado inicialmente) pedindo uma versão única e coerente,
baseada apenas neles.

## Comparação entre os 2 arquivos

- `aprenda-e-ganhe.zip` e `y.zip` têm os mesmos 67 arquivos de seed
  (`001`–`067`), byte a byte idênticos em 65 deles.
- Diferem em apenas 2 arquivos: `005_tecnologia_facil_2.sql` e
  `docs/banco-de-perguntas-status.md`.
- `aprenda-e-ganhe.zip` já continha a correção real de uma sobreposição
  (3 perguntas de `005` com o mesmo enunciado de `003`) — removida na
  fonte, 50 → 47 perguntas. `y.zip` só sinalizava o problema num comentário,
  sem aplicar a correção (inseria as 50, com aviso).
- `aprenda-e-ganhe.zip` também trazia consigo `MERGE_REPORT_rodada5.md`,
  de uma consolidação anterior (3 outros zips: `aprenda-.zip`, `g.zip`,
  `aprenda-e-ganhe.zip` antigo) que já validou a base contra um PostgreSQL
  real.

**Conclusão:** `aprenda-e-ganhe.zip` é um superconjunto estrito de `y.zip`
— nada exclusivo de `y.zip` precisou ser recuperado. Usei
`aprenda-e-ganhe.zip` como base.

## Bug real encontrado nesta rodada (não estava em nenhum relatório anterior)

Todas as auditorias de duplicata documentadas até aqui (rodadas 1–5, e a
migration `031_remove_duplicate_questions.sql`) comparavam enunciados só
**dentro da mesma categoria+dificuldade**. Uma auditoria própria cobrindo o
banco inteiro (qualquer categoria, qualquer dificuldade) encontrou **16
perguntas com o mesmo enunciado inserido em duas combinações
categoria×dificuldade diferentes** — nenhuma delas coincidindo com as 3 já
conhecidas de `003`/`005`. Lista completa e decisão de qual ocorrência
manter: ver `docs/banco-de-perguntas-status.md`, seção "Auditoria de
duplicatas CRUZADAS".

**Correção:** as 16 perguntas foram removidas dos arquivos mais recentes
(`004`, `007`, `010`, `034`, `035`), mantendo sempre a ocorrência no arquivo
de número mais baixo. Cada arquivo alterado tem uma nota no próprio
cabeçalho SQL. Nenhuma pergunta nova foi adicionada para compensar.

## Verificação (script próprio, independente dos relatórios anteriores)

- 0 perguntas com número de alternativas diferente de 4
- 0 perguntas com número de alternativas corretas diferente de 1
- 0 duplicatas dentro da mesma categoria+dificuldade
- 0 duplicatas entre categorias/dificuldades diferentes (verificação nova
  desta rodada)

## Estado final

67 arquivos de seed. **1.646 perguntas de produção** (1.662 da rodada 5,
menos as 16 duplicatas cruzadas removidas nesta rodada). Ver
`docs/banco-de-perguntas-status.md` para a tabela completa por categoria e
dificuldade.
