# Changelog — Novo lote de perguntas (Finanças, Marketing Digital, Produtividade, IA)

## O que mudou

10 novos arquivos de seed em `backend/database/seeds/` (015 a 024), a partir de
três lotes de perguntas fornecidos pelo proprietário do projeto:

- Lote "80 novas — Marketing Digital"
- Lote "80 novas — Finanças"
- Lote "LOTE — 110 questões" (Finanças, Marketing Digital, Produtividade,
  Inteligência Artificial)

| Arquivo | Categoria · Dificuldade | Perguntas |
|---|---|---|
| 015_financas_facil.sql | Finanças · Fácil | 33 |
| 016_financas_medio.sql | Finanças · Médio | 38 |
| 017_financas_dificil.sql | Finanças · Difícil | 31 |
| 018_marketing_digital_facil_2.sql | Marketing Digital · Fácil | 26 |
| 019_marketing_digital_medio_2.sql | Marketing Digital · Médio | 28 |
| 020_marketing_digital_dificil_2.sql | Marketing Digital · Difícil | 25 |
| 021_produtividade_facil_2.sql | Produtividade · Fácil | 12 |
| 022_produtividade_medio_2.sql | Produtividade · Médio | 5 |
| 023_ia_facil_2.sql | Inteligência Artificial · Fácil | 6 |
| 024_ia_medio_2.sql | Inteligência Artificial · Médio | 5 |

**Total: 209 perguntas novas inseridas.** Esta é a primeira leva de conteúdo
de "Finanças" no pipeline de migrations/seeds — antes só existia uma pergunta
de exemplo em `001_sample_content.sql` (seed de desenvolvimento, fora do
pipeline).

## Deduplicação aplicada

Os três lotes somavam 241 perguntas processáveis. Antes de gerar os seeds,
cada pergunta foi comparada (por texto normalizado — minúsculas, sem acentos,
sem pontuação) contra:

1. Todas as perguntas já inseridas pelos seeds 003–014 (Tecnologia, Marketing
   Digital, Inteligência Artificial, Produtividade já existentes);
2. As outras perguntas dos três lotes novos entre si.

Resultado: **32 perguntas descartadas** por já existirem no banco (a maioria
do lote "LOTE 110", que repetia perguntas do lote "80 novas — Marketing
Digital" e de seeds de Produtividade/IA já aplicados). Nenhuma duplicata
interna entre os três lotes novos. As 209 restantes são as que entraram nos
arquivos 015–024.

## Correção de qualidade (mesma aplicada nos seeds 003–014)

Nos lotes originais, a esmagadora maioria das respostas corretas era sempre a
alternativa "A" — decorável sem conhecimento real do conteúdo. Para cada um
dos 10 arquivos, a posição da alternativa correta foi redistribuída por
pergunta com uma seed fixa própria (54 a 63 — sequência distinta das seeds 42
a 53 já usadas nos seeds 003–014), com distribuição controlada e praticamente
igual entre A/B/C/D. O conteúdo pedagógico (pergunta e alternativas)
permanece exatamente como enviado — só a ORDEM de exibição das alternativas
mudou.

## Pendências (partes dos lotes que chegaram cortadas)

Dois dos três documentos enviados vieram truncados no meio do texto:

- **Lote "80 novas — Marketing Digital":** corta na pergunta 79 (falta o
  resto da 79 e toda a 80).
- **Lote "LOTE 110":** corta na pergunta 84 (Inteligência Artificial) — faltam
  as perguntas 85 a 110 (provavelmente mais IA e a categoria Tecnologia, para
  fechar as 110).

Por pedido do proprietário do projeto, os arquivos 015–024 acima foram
gerados só com o que estava completo.

## Atualização — o restante das 83 perguntas do "LOTE 110" já está coberto

Um arquivo `025_lote_110_perguntas_incompleto.sql` apareceu no projeto
tentando inserir 5 perguntas como "novas" a partir das 83 perguntas
completas do LOTE 110 (Q1–Q83). Verificação por texto normalizado mostrou
que as 5 já existiam palavra-por-palavra no banco — 4 delas já tinham sido
inseridas pelos próprios arquivos 021, 022, 023 e 024 acima, e a 5ª já
existia desde o seed original 007. Ou seja: **as 83 perguntas completas do
LOTE 110 já estão 100% refletidas no banco** (63 entraram nos arquivos
015–024; as outras 20 já existiam desde os seeds 003–014). O arquivo
`025_lote_110_perguntas_incompleto.sql` foi removido do projeto para não
duplicar essas 5 perguntas com um `source` diferente.

O que genuinamente falta do LOTE 110 é só a parte que nunca chegou completa:
as perguntas 84 a 110 (a partir da Inteligência Artificial cortada, mais a
categoria Tecnologia que fecharia as 110). Também falta o fim do lote "80
novas — Marketing Digital" (perguntas 79 e 80).

Quando essas partes forem reenviadas, a próxima leva de seeds deve começar
em `025_...sql` de verdade, repetindo o processo de deduplicação (agora
contra os 613 enunciados já existentes em 003–024) e usando a próxima seed
livre (64 em diante) para a redistribuição de alternativas.
