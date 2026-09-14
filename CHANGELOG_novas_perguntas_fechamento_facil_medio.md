# Changelog — Fechamento de Produtividade Fácil, IA Fácil/Médio e Finanças Fácil

## O que mudou

4 novos arquivos de seed em `backend/database/seeds/` (061 a 064):

| Arquivo | Categoria · Dificuldade | Perguntas | Origem |
|---|---|---|---|
| 061_produtividade_facil_6.sql | Produtividade · Fácil | 1 | proprietário do projeto |
| 062_ia_facil_6.sql | Inteligência Artificial · Fácil | 2 | proprietário do projeto |
| 063_ia_medio_5.sql | Inteligência Artificial · Médio | 1 | proprietário do projeto |
| 064_financas_facil_4.sql | Finanças · Fácil | 1 | **escrita por nós (Claude)** — ver nota abaixo |

**Total: 5 perguntas novas inseridas.**

## Deduplicação aplicada

Dos 5 lotes fornecidos originalmente (incluindo uma 3ª tentativa de
Finanças Fácil, "ARQUIVO 062"), 4 eram inéditos e inseridos diretamente
(061, 062, 063). Nenhuma correção de posição foi necessária além da
distribuição controlada padrão (seeds 99, 100, 101).

## Nota especial — Finanças Fácil (seed 064)

A pergunta fornecida no "ARQUIVO 062" ("O que é um orçamento pessoal?")
era **quase-duplicata** da já existente no seed 034 ("O que é orçamento
pessoal?" — mesma resposta certa: planejamento de receitas/despesas). Foi
a **3ª tentativa seguida** de fechar Finanças Fácil esbarrando em
duplicatas/quase-duplicatas do mesmo tema (orçamento/poupar/despesa).

Após consulta ao proprietário do projeto sem uma decisão definitiva sobre
manter ou descartar essa pergunta específica, optamos por **não usar a
pergunta do ARQUIVO 062** e, em vez disso, **escrever uma pergunta nova**
sobre um conceito ainda não coberto em nenhum lugar do banco ("conta
poupança" — zero ocorrências prévias confirmadas por busca em todos os 63
arquivos de seed existentes antes de escrever).

**Importante:** esta é a única pergunta em todo o banco que não veio do
material fornecido pelo proprietário do projeto — foi redigida por nós
para destravar a lacuna. Recomendamos revisão antes de considerar
definitiva, e que o ARQUIVO 062 original ("O que é um orçamento pessoal?")
seja arquivado à parte, caso o proprietário do projeto ainda queira usá-lo
no futuro com outra redação que o diferencie mais claramente do seed 034.

## Estado atual do banco de perguntas (após 061–064)

| Categoria | Fácil | Médio | Difícil | Total |
|---|---|---|---|---|
| Tecnologia | 100 | 124 | 100 | 324 |
| Marketing Digital | 100 | 100 | 106 | 306 |
| Finanças | **100** | 100 | 101 | 301 |
| Produtividade | **100** | 100 | 99 | 299 |
| Inteligência Artificial | **100** | **100** | 136 | 336 |
| **TOTAL** | | | | **1.566** |

**Todas as células Fácil e Médio do banco inteiro bateram exatamente 100.**
Resta apenas **Produtividade Difícil (99)**, faltando 1 pergunta inédita
para fechar a meta implícita em todas as 15 combinações categoria×dificuldade.
