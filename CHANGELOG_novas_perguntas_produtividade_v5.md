# Changelog — Produtividade (Fácil + Médio, lote 5) + Finanças Fácil (descartada, 2ª vez)

## O que mudou

2 novos arquivos de seed em `backend/database/seeds/` (059 e 060):

| Arquivo | Categoria · Dificuldade | Perguntas |
|---|---|---|
| 059_produtividade_facil_5.sql | Produtividade · Fácil | 7 |
| 060_produtividade_medio_5.sql | Produtividade · Médio | 2 |

**Total: 9 perguntas novas inseridas.**

## Origem de cada lote

Três lotes fornecidos pelo proprietário do projeto ("ARQUIVO 059/060/061"
no material original), dimensionados para fechar exatamente as lacunas
restantes identificadas no changelog anterior:
- "FINANÇAS — FÁCIL (1)"
- "PRODUTIVIDADE — FÁCIL (8)"
- "PRODUTIVIDADE — MÉDIO (2)"

## Deduplicação aplicada

| Categoria | Enviadas | Duplicatas exatas | Inseridas |
|---|---|---|---|
| Finanças · Fácil | 1 | 1 | 0 (arquivo não criado) |
| Produtividade · Fácil | 8 | 1 | 7 → seed 059 |
| Produtividade · Médio | 2 | 0 | 2 → seed 060 |

Finanças Fácil recebeu uma 2ª pergunta seguida que já existia: "O que é
uma despesa?" é texto idêntico ao já presente no seed 034. Continua em 99,
faltando 1 pergunta inédita para fechar 100.

Duplicata exata descartada (Produtividade Fácil): "Qual comportamento pode
prejudicar a produtividade?" — já presente no seed 054 (adicionado na
rodada anterior desta mesma conversa).

## Correção de qualidade (mesma dos lotes anteriores)

Amostras pequenas desta vez (7 e 2 perguntas), então o viés é menos
extremo, mas ainda presente: Produtividade Fácil sobreviventes tinham A=4,
B=3, nenhuma em C/D; Produtividade Médio tinha as 2 em B. Posições
redistribuídas com seed fixa própria (97 para o 059, 98 para o 060 —
sequência distinta das seeds 42 a 96 já usadas), distribuição controlada
entre A/B/C/D mesmo em lotes pequenos. Verificado programaticamente: 0
divergências entre o conjunto de alternativas/resposta original e o
inserido nos 2 arquivos.

## Estado atual do banco de perguntas (após 059–060)

| Categoria | Fácil | Médio | Difícil | Total |
|---|---|---|---|---|
| Tecnologia | 100 | 124 | 100 | 324 |
| Marketing Digital | 100 | 100 | 106 | 306 |
| Finanças | 99 | 100 | 101 | 300 |
| Produtividade | 99 | **100** | 99 | 298 |
| Inteligência Artificial | 98 | 99 | 136 | 333 |
| **TOTAL** | | | | **1.561** |

Produtividade Médio fechou exatamente em 100. Restam apenas lacunas
mínimas: Finanças Fácil precisa de 1 pergunta inédita (já recebeu 2
duplicatas seguidas — vale conferir a fonte do material antes de enviar
mais), Produtividade Fácil de 1, e Inteligência Artificial Fácil/Médio de
2/1 respectivamente.
