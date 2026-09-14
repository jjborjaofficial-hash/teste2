# Changelog — Novo lote de perguntas (Marketing Digital Fácil/Médio/Difícil, v3)

## O que mudou

3 novos arquivos de seed em `backend/database/seeds/` (027 a 029), a partir
de três lotes fornecidos pelo proprietário do projeto:

- Lote "MARKETING DIGITAL — FÁCIL (49 questões)"
- Lote "MARKETING DIGITAL — MÉDIO (42 questões)"
- Lote "MARKETING DIGITAL — DIFÍCIL (50 questões)"

| Arquivo | Categoria · Dificuldade | Perguntas |
|---|---|---|
| 027_marketing_digital_facil_3.sql | Marketing Digital · Fácil | 34 |
| 028_marketing_digital_medio_3.sql | Marketing Digital · Médio | 31 |
| 029_marketing_digital_dificil_3.sql | Marketing Digital · Difícil | 44 |

**Total: 109 perguntas novas inseridas.**

## Deduplicação aplicada

Os três lotes somavam 141 perguntas. Cada uma foi comparada (texto
normalizado) contra os 695 enunciados já existentes nos seeds 003–026.
Resultado: **32 descartadas** por já existirem (15 de Fácil, 11 de Médio, 6
de Difícil — repetições de perguntas já presentes nos seeds 007/008/009 ou
018/019/020 de Marketing Digital). Nenhuma duplicata interna entre os três
lotes. As 109 restantes entraram nos arquivos 027–029.

## Correção de qualidade (mesma dos lotes anteriores)

Nos três lotes originais, **100% das respostas corretas** vinham na
alternativa "A" — decorável sem qualquer conhecimento real. A posição da
alternativa correta foi redistribuída por pergunta com seed fixa própria
(66/67/68 — sequência distinta das seeds 42 a 65 já usadas), com
distribuição praticamente igual entre A/B/C/D. O conteúdo pedagógico
permanece exatamente como enviado — só a ordem de exibição das alternativas
mudou.

## Estado atual do banco de perguntas (após 027–029)

| Categoria | Fácil | Médio | Difícil | Total |
|---|---|---|---|---|
| Tecnologia | 100 | 83 | 98 | 281 |
| Marketing Digital | 85 | 89 | 94 | 268 |
| Finanças | 33 | 38 | 31 | 102 |
| Produtividade | 37 | 35 | 24 | 96 |
| Inteligência Artificial | 31 | 35 | 0 | 66 |
| **TOTAL** | | | | **813** |

Inteligência Artificial Difícil continua sem nenhuma pergunta — é a maior
lacuna do banco no momento.
