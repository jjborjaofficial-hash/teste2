# Changelog — Produtividade (Fácil + Médio, lote 4) + Finanças Fácil (descartada)

## O que mudou

2 novos arquivos de seed em `backend/database/seeds/` (057 e 058):

| Arquivo | Categoria · Dificuldade | Perguntas |
|---|---|---|
| 057_produtividade_facil_4.sql | Produtividade · Fácil | 42 |
| 058_produtividade_medio_4.sql | Produtividade · Médio | 20 |

**Total: 62 perguntas novas inseridas.**

## Origem de cada lote

Três lotes fornecidos pelo proprietário do projeto ("ARQUIVO 056/057/058"
no material original):
- "FINANÇAS — FÁCIL (1)"
- "PRODUTIVIDADE — FÁCIL (50)"
- "PRODUTIVIDADE — MÉDIO (22)"

## Deduplicação aplicada

| Categoria | Enviadas | Duplicatas exatas | Inseridas |
|---|---|---|---|
| Finanças · Fácil | 1 | 1 | 0 (arquivo não criado) |
| Produtividade · Fácil | 50 | 8 | 42 → seed 057 |
| Produtividade · Médio | 22 | 2 | 20 → seed 058 |

A pergunta de Finanças Fácil ("O que significa poupar dinheiro?") já
existia, texto idêntico, no seed 015 — nenhum arquivo novo foi criado para
Finanças nesta rodada.

Duplicatas exatas descartadas (Produtividade Fácil): "O que significa
estabelecer uma meta?", "O que é procrastinação?", "O que significa
planejar o dia?", "O que significa delegar uma tarefa?", "O que é uma
rotina?", "O que é uma interrupção?", "O que significa organizar
informações?", "O que é uma tarefa recorrente?" — já presentes nos seeds
012, 013, 021 ou 022.

Duplicatas exatas descartadas (Produtividade Médio): "O que é time
blocking?" e "O que é batching de tarefas?" — já presentes no seed 013.

## Correção de qualidade (mesma dos lotes anteriores)

Viés mais forte já visto até agora nesta categoria: nas sobreviventes,
**39 de 42 (93%) do lote Fácil** e **18 de 20 (90%) do lote Médio** tinham
a resposta correta em "A", sem nenhuma em C ou D. Posições redistribuídas
com seed fixa própria (95 para o 057, 96 para o 058 — sequência distinta
das seeds 42 a 94 já usadas), distribuição controlada entre A/B/C/D.
Conteúdo pedagógico inalterado — só a ordem de exibição mudou. Verificado
programaticamente: 0 divergências entre o conjunto de alternativas/resposta
original e o inserido nos 2 arquivos.

## Estado atual do banco de perguntas (após 057–058)

| Categoria | Fácil | Médio | Difícil | Total |
|---|---|---|---|---|
| Tecnologia | 100 | 124 | 100 | 324 |
| Marketing Digital | 100 | 100 | 106 | 306 |
| Finanças | 99 | 100 | 101 | 300 |
| Produtividade | 92 | 98 | 99 | 289 |
| Inteligência Artificial | 98 | 99 | 136 | 333 |
| **TOTAL** | | | | **1.552** |

Produtividade Fácil (92) e Médio (98) estão agora muito perto da meta
implícita de ~100 — faltam poucas perguntas em cada uma para fechar.
Finanças Fácil (99) segue precisando de só 1 pergunta nova (não-duplicada)
para completar 100.
