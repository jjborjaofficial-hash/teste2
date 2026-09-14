# Changelog — Novo lote de perguntas (Tecnologia Médio v3 + Marketing Digital "cobrir lacunas")

## O que mudou

4 novos arquivos de seed em `backend/database/seeds/` (030 a 033), a partir
de dois lotes fornecidos pelo proprietário do projeto:

- Lote "TECNOLOGIA — MÉDIO (50 questões novas diferenciadas)"
- Lote "MARKETING DIGITAL — questões novas para cobrir lacunas (32 questões:
  10 fácil, 10 médio, 12 difícil)"

| Arquivo | Categoria · Dificuldade | Perguntas |
|---|---|---|
| 030_tecnologia_medio_3.sql | Tecnologia · Médio | 41 |
| 031_marketing_digital_facil_4.sql | Marketing Digital · Fácil | 8 |
| 032_marketing_digital_medio_4.sql | Marketing Digital · Médio | 9 |
| 033_marketing_digital_dificil_4.sql | Marketing Digital · Difícil | 12 |

**Total: 70 perguntas novas inseridas.**

## Deduplicação aplicada

Os dois lotes somavam 82 perguntas. Cada uma foi comparada (texto
normalizado) contra os 804 enunciados já existentes nos seeds 003–029.
Resultado: **12 descartadas** por já existirem (9 de Tecnologia Médio já
estavam nos seeds 004/025; 2 de Marketing Digital Fácil e 1 de Marketing
Digital Médio já estavam em seeds anteriores de Marketing Digital). Nenhuma
duplicata interna entre os dois lotes. As 70 restantes entraram nos
arquivos 030–033.

## Correção de qualidade (mesma dos lotes anteriores)

Nos dois lotes originais, **100% das respostas corretas** vinham na
alternativa "A". A posição da alternativa correta foi redistribuída por
pergunta com seed fixa própria (69 para Tecnologia Médio; 70/71/72 para
Marketing Digital Fácil/Médio/Difícil — sequência distinta das seeds 42 a
68 já usadas), com distribuição praticamente igual entre A/B/C/D. O
conteúdo pedagógico permanece exatamente como enviado — só a ordem de
exibição das alternativas mudou.

## Estado atual do banco de perguntas (após 030–033)

| Categoria | Fácil | Médio | Difícil | Total |
|---|---|---|---|---|
| Tecnologia | 100 | 124 | 98 | 322 |
| Marketing Digital | 93 | 98 | 106 | 297 |
| Finanças | 33 | 38 | 31 | 102 |
| Produtividade | 37 | 35 | 24 | 96 |
| Inteligência Artificial | 31 | 35 | 0 | 66 |
| **TOTAL** | | | | **883** |

Inteligência Artificial Difícil continua sem nenhuma pergunta — é a maior
lacuna do banco no momento. Produtividade Difícil (24) e Inteligência
Artificial Fácil/Médio (31/35) também estão relativamente atrás das outras
categorias.
