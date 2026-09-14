# Changelog — Finanças Difícil (extra) + Produtividade/IA (deduplicado)

## O que mudou

4 novos arquivos de seed em `backend/database/seeds/` (053 a 056):

| Arquivo | Categoria · Dificuldade | Perguntas |
|---|---|---|
| 053_financas_dificil_5.sql | Finanças · Difícil | 1 |
| 054_produtividade_facil_3.sql | Produtividade · Fácil | 13 |
| 055_ia_facil_5.sql | Inteligência Artificial · Fácil | 2 |
| 056_ia_medio_4.sql | Inteligência Artificial · Médio | 1 |

**Total: 17 perguntas novas inseridas.**

## Origem de cada lote

- **053**: pergunta fornecida pelo proprietário do projeto ("Uma pessoa
  possui uma dívida de 50.000 MZN com juros compostos de 10% ao ano...").
  Finanças Difícil já havia sido fechado em 100 perguntas pelo seed 045
  (pergunta "O que é due diligence financeira?", diferente desta). O
  proprietário confirmou explicitamente que quer esta pergunta adicionada
  **mesmo excedendo a meta** — Finanças Difícil fica com 101, não 100.
  Cálculo conferido de forma independente: 50.000 × (1,10)² = 60.500 MZN,
  bate com a alternativa C informada.

- **054/055/056**: lote misto fornecido pelo proprietário do projeto —
  "PRODUTIVIDADE — FÁCIL (20)" + "FINANÇAS — FÁCIL (1)" +
  "INTELIGÊNCIA ARTIFICIAL — FÁCIL (4)" +
  "INTELIGÊNCIA ARTIFICIAL — MÉDIO (1)", 26 perguntas ao todo.

## Deduplicação aplicada

Das 26 perguntas do lote misto, **9 eram duplicatas exatas** (texto
idêntico a perguntas já existentes) e **1 era quase-duplicata** (mesmo
conceito, redação diferente):

| Categoria | Enviadas | Descartadas | Inseridas |
|---|---|---|---|
| Produtividade · Fácil | 20 | 7 (exatas) | 13 → seed 054 |
| Finanças · Fácil | 1 | 1 (quase-duplicata da 034, "O que é orçamento pessoal?" — confirmado com o proprietário do projeto) | 0 |
| Inteligência Artificial · Fácil | 4 | 2 (exatas) | 2 → seed 055 |
| Inteligência Artificial · Médio | 1 | 0 | 1 → seed 056 |

Duplicatas exatas descartadas (Produtividade Fácil): "O que significa
priorizar tarefas?", "O que é procrastinação?", "O que é uma tarefa?", "O
que significa delegar uma tarefa?", "Qual é uma vantagem de criar uma lista
de tarefas?", "O que é uma rotina?", "O que significa ser produtivo?" — já
presentes nos seeds 012, 021 ou 022.

Duplicatas exatas descartadas (IA Fácil): "O que é Inteligência
Artificial?" e "O que é um chatbot?" — já presentes no seed 010.

## Correção de qualidade (mesma dos lotes anteriores)

Nas sobreviventes, o viés não era o clássico "sempre A", mas ainda assim
decodável:
- Produtividade Fácil (13 sobreviventes): nunca caía em D (0 de 13) e
  pendia fortemente para B (7 de 13).
- IA Fácil (2 sobreviventes): as duas eram A.

Posições redistribuídas com seed fixa própria por arquivo (92 para o 054,
93 para o 055, 94 para o 056 — sequência distinta das seeds 42 a 91 já
usadas), com distribuição controlada entre A/B/C/D via amostragem sem
reposição das posições restantes (evita reproduzir viés mesmo em lotes
pequenos, incluindo o de 1 pergunta só). Conteúdo pedagógico inalterado —
só a ordem de exibição mudou. Verificado programaticamente: 0
divergências entre o conjunto de alternativas/resposta original e o
inserido nos 3 arquivos.

## Estado atual do banco de perguntas (após 053–056)

| Categoria | Fácil | Médio | Difícil | Total |
|---|---|---|---|---|
| Tecnologia | 100 | 124 | 100 | 324 |
| Marketing Digital | 100 | 100 | 106 | 306 |
| Finanças | 99 | 100 | 101 | 300 |
| Produtividade | 50 | 78 | 99 | 227 |
| Inteligência Artificial | 98 | 99 | 136 | 333 |
| **TOTAL** | | | | **1.490** |

Produtividade Fácil (50) continua a célula mais abaixo da meta implícita
de ~100 no banco inteiro.
