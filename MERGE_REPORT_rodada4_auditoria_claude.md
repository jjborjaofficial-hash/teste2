# Relatório de Fusão — Rodada 4 ("versão final" do usuário)

## Contexto

O proprietário indicou que este era o resultado final de rodadas próprias
de consolidação (`MERGE_REPORT_rodada4/5/6.md` já vinham no arquivo). Em
vez de assumir que "final" significa "não precisa auditar", apliquei o
mesmo rigor de todas as rodadas anteriores.

## Resultado: este arquivo estava, no geral, mais avançado que a minha base

- 72 seeds (minha base tinha 66) — 6 arquivos novos, todos validados
  estruturalmente (contagem de alternativas, TRUE/FALSE) sem problema
- Faltavam só os 3 `.gitignore` (restaurados a partir da minha base)

## Achado real: correção de duplicata mais completa que a minha

Meu processo de checagem de duplicata (usado nas rodadas 1-3) só comparava
perguntas **dentro da mesma categoria E mesma dificuldade**. Isso tinha um
ponto cego: não detectava a mesma pergunta aparecendo em dificuldades
diferentes da mesma categoria, nem em categorias diferentes.

Este arquivo trouxe uma correção editando diretamente 6 arquivos de seed
(`004_tecnologia_medio.sql`, `005_tecnologia_facil_2.sql`,
`007_marketing_digital_facil.sql`, `010_inteligencia_artificial_facil.sql`,
`034_financas_facil_2.sql`, `035_financas_medio_2.sql`) para remover 18
perguntas que apareciam duplicadas em outro arquivo do banco — cobrindo
exatamente o ponto cego acima.

**Verifiquei com uma varredura própria, em 3 níveis de rigor crescente**
(por categoria+dificuldade, por categoria, e global — ver
`docs/banco-de-perguntas-status.md`): confirmado **zero duplicata** no
arquivo do usuário, nos 3 níveis. Adotei essas 6 versões corrigidas.

## Achado adicional, documentado mas não corrigido nesta rodada

A migration `031_remove_duplicate_questions.sql` roda antes dos seeds
carregarem, então nunca limpa nada num banco novo — só serve como rede de
segurança para bancos já existentes com dados antigos. Isso deixou de ser
crítico porque a correção de conteúdo acima resolve na origem, mas fica
registrado em `docs/banco-de-perguntas-status.md` para quem for reler o
histórico entender por que a 031 existe mas "nunca faz nada" em instalação
nova.

## Validação final
- Sintaxe (`node --check`): sem erros
- Migrations: 001 a 031, sem lacuna
- Duplicata: zero em 3 níveis de rigor (categoria+dificuldade / categoria / global)
- Total: 1.659 perguntas
