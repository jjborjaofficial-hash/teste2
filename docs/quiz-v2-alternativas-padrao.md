# Padrão das alternativas do quiz (modelo para TODAS as perguntas)

Decidido com o dono em 2026-10-07. Serve para a regularização do BE-003 (reescrever alternativas
em lotes de 25) e para qualquer pergunta nova. Quem escrever ou corrigir alternativas segue isto.

## Por quê
Hoje a alternativa correta é a mais longa em **89,4%** das 1.659 perguntas (ao acaso seria ~25%).
Quem escolhe sempre a mais longa acerta ~9 em 10, e o quiz paga dinheiro real. O objetivo é que o
tamanho, o detalhe e a posição **não revelem** a resposta: só o conhecimento revela.

## REGRA DE OURO DO DONO (2026-10-07)
**A resposta CERTA e a explicação dela não se mudam.** O trabalho é ajustar as **erradas** (em geral as curtas)
até terem tamanho e forma parecidos com os da certa. A certa só se mexe se tiver explicação embutida ou
defeito real, e isso exige avisar o dono. Os "Depois" dos modelos abaixo mostram o princípio (opções
equilibradas); na prática, mantenha a certa original e reescreva as erradas à volta dela.

## As 8 regras
1. **Tamanho parecido.** As 4 opções com número de palavras próximo (diferença de até ~30% entre a
   maior e a menor). A correta **não** pode ser a mais longa por larga margem.
2. **Meta por grupo** (categoria + dificuldade): a correta é a mais longa em no máximo ~30–35% das
   perguntas. Ao corrigir um lote, variar de propósito: às vezes a correta é a mais curta, às vezes a
   do meio. Medir com `npm run quiz:validate`.
3. **Mesma estrutura.** As 4 começam do mesmo jeito e têm o mesmo tipo de frase (todas "Perda de…",
   ou todas substantivo curto). A correta não pode ser a única com pontuação, vírgula, parênteses ou
   "e/ou".
4. **Erradas plausíveis.** Cada errada deve ser algo que alguém que não sabe poderia escolher: um
   conceito vizinho, uma confusão comum, o contrário da correta, ou uma verdade que não responde à
   pergunta. Evitar absurdos ("Receita extra", "Taxa de cartão") e piadas.
5. **Sem explicação dentro da correta.** Nada de "porque", "ou seja", dois-pontos ou parênteses
   explicativos na opção. Quem explica é o "Por quê?" (`questions.explanation`) depois de responder.
6. **Sem pistas de linguagem.** Evitar "sempre", "nunca", "apenas", "somente" só nas erradas, e
   evitar "geralmente/pode" só na correta. Se usar, usar em todas ou em nenhuma.
7. **Sem repetidas nem quase iguais.** Nenhuma opção contida na outra; nenhuma "todas as anteriores"
   nem "nenhuma das anteriores".
8. **Só uma correta, e a posição é aleatória.** O servidor já embaralha a ordem a cada apresentação;
   ao reescrever, **mantém-se** o `is_correct` e o `display_order` originais (a migration só altera
   `question_alternatives.label`).

9. **Explicação coerente com as novas opções.** Várias explicações dizem "Não é X, Y nem Z", citando as
   alternativas erradas antigas. Ao trocar as erradas, conferir a explicação da pergunta: se ela citar
   opções que deixaram de existir, **reescrevê-la no mesmo lote** (a migration desse lote faz um UPDATE que
   sobrescreve só essas explicações). Nas fáceis de Finanças a maioria não cita; no médio e no difícil muitas citam.

## Como reescrever (passo a passo, por pergunta)
1. Ler a pergunta e a explicação (se já existir) para ter certeza do conceito certo.
2. Escrever a correta numa frase curta e natural (8 a 14 palavras em conceitos; 1 a 3 palavras em
   nomes/siglas; só o número com unidade em contas).
3. Para cada errada, escolher um **tipo de distrator** diferente: (a) conceito vizinho, (b) o
   contrário, (c) verdade que não responde, (d) confusão comum. Dar-lhe o mesmo comprimento e a
   mesma forma da correta.
4. Conferir as regras 1 a 7; trocar a correta de "mais longa" para "meio" ou "mais curta" quando o
   lote já tiver muitas "mais longas".
5. Nunca mudar a pergunta, qual é a correta, nem o número de alternativas.

## Modelos por tipo de pergunta

### A. Definição ("O que é X?")
**Antes (reprova):** a correta é a única longa; as erradas são absurdas e curtas.
- Receita extra
- Lucro financeiro
- Aumento automático do valor
- Perda de valor de um ativo ao longo do tempo ✔

**Depois (modelo):** mesmo tamanho e forma; erradas são confusões reais.
- Perda de valor de um ativo com o passar do tempo ✔
- Aumento do valor de um ativo com o uso
- Redução das dívidas da empresa a cada ano
- Pagamento dos lucros aos sócios da empresa

### B. Conceito curto ("Qual é…?", nome ou sigla)
**Antes:** correta com explicação embutida.
- Taxa de cartão
- Salário empresarial
- Valor de uma dívida pessoal
- Indicador que mostra o desempenho operacional antes de juros, impostos, depreciação e amortização ✔

**Depois:** só o conceito; o detalhe vai para o "Por quê?".
- Lucro operacional antes de juros e impostos ✔
- Lucro líquido depois de todos os impostos
- Receita total das vendas do período
- Fluxo de caixa disponível para os sócios

### C. Conta / número ("Quanto…?")
**Antes:** valores soltos, a correta é a única "redonda" ou a do meio óbvio.
- 55.000 MZN
- 60.000 MZN
- 60.500 MZN ✔
- 65.000 MZN

**Depois:** erradas saem de erros reais de cálculo (juros simples, só um ano, taxa errada), todas com
o mesmo formato.
- 60.500 MZN ✔
- 55.000 MZN (só um ano de juros)
- 60.000 MZN (juros simples)
- 66.550 MZN (resultado de três anos em vez de dois)

(A nota entre parênteses é só aqui no guia, **não** vai para a alternativa: na alternativa fica apenas
o valor. Os erros de cálculo servem para escolher os valores errados.)

### D. Aplicação / situação ("Qual é a melhor atitude…?")
**Antes:** a correta é a frase mais completa; as erradas são "Gastar tudo", "Ignorar".
- Gastar tudo hoje
- Ignorar o orçamento
- Pedir emprestado sem pensar
- Separar uma parte do dinheiro para emergências antes de gastar ✔

**Depois:** todas parecem decisões razoáveis, só uma é a melhor.
- Guardar uma parte do rendimento para emergências ✔
- Pagar primeiro as contas e gastar o que sobrar
- Investir tudo o que sobra no mesmo ativo
- Comprar a prazo para manter o dinheiro disponível

## Lista de verificação (por pergunta, antes de entregar o lote)
- [ ] As 4 opções têm tamanho e forma parecidos (regras 1 e 3).
- [ ] A correta não é a mais longa por margem grande (regra 1) e o lote varia a posição de tamanho.
- [ ] Nenhuma errada é absurda (regra 4); nenhuma pista de linguagem (regra 6).
- [ ] Sem explicação dentro da correta (regra 5).
- [ ] `is_correct`, `display_order` e a pergunta ficaram iguais (regra 8).
- [ ] O "Por quê?" já existe ou foi escrito no mesmo lote.
- [ ] `npm run quiz:validate` rodado; antes/depois registado em `backend/PENDENTE.md`.

## Como cada lote entra no projeto
Lotes de 25 perguntas; o dono revê o texto **antes** da migration. Cada lote = 1 migration
(`UPDATE question_alternatives SET label = …` casando por pergunta + posição + `is_correct`),
teste, relatório do validador (antes/depois), commit, push, deploy do backend e atualização do
`backend/PENDENTE.md`. Perguntas ainda não corrigidas continuam a ser servidas e nada é apagado.

## Validador estendido (BE-003, P9 a P14)

`npm run quiz:audit` (só leitura) junta o validador de tamanho com quatro verificações novas. A coluna **Quando bloqueia**
vale para **perguntas novas ou reescritas** no admin; nas perguntas antigas tudo é só informativo.

| Alerta | O que significa | Regra | Quando bloqueia | Como corrigir |
|---|---|---|---|---|
| `correta_mais_longa_destacada` | a correta é a mais longa e passa ~1,3x a média das erradas | 1, 2 | sim | encurtar a correta ou completar as erradas |
| `explicacao_embutida_na_correta` | parênteses, dois-pontos, "porque", "ou seja" na correta | 5 | sim | mover para a explicação |
| `alternativas_duplicadas_ou_quase_iguais` | duas opções quase iguais | 7 | sim | trocar uma por outro distrator |
| `todas_ou_nenhuma_das_anteriores` | a opção inteira é "todas/nenhuma das anteriores", "ambas estão corretas"… | 7 | sim | usar uma opção normal |
| `pergunta_duplicada` | enunciado igual ou >= 85% parecido com outro (ignora "de, que, qual, um…") | — | sim | reformular ou não criar |
| `pista_absoluta_so_nas_erradas` | "sempre, nunca, apenas…" só nas erradas | 6 | não (aviso) | usar em todas ou em nenhuma |
| `pista_cautela_so_na_correta` | "geralmente, pode…" só na correta | 6 | não (aviso) | usar em todas ou em nenhuma |
| `estrutura_so_na_correta` | só a correta tem vírgula, parênteses, aspas ou "e/ou" | 3 | não (aviso) | dar a mesma forma às quatro |
| `inicio_diferente_so_na_correta` | as erradas começam igual e a correta não | 3 | não (aviso) | mesmo início nas quatro |
| `palavras_desequilibradas` | diferença de palavras entre a maior e a menor opção > 50% (só opções de 4+ palavras) | 1 | não (aviso) | aproximar os tamanhos |
| `opcao_contida_noutra` | uma opção (2+ palavras) está inteira dentro de outra | 7 | não (aviso) | tornar as opções independentes |

**Posição da correta.** Analisa a ordem GUARDADA (o servidor embaralha ao servir). Acusa `distribuicao_desigual` (qui² a 1%),
`sequencia_longa_na_mesma_posicao` e `padrao_ciclico` (A, B, C, D, A, B, C, D…) por grupo, com mínimo de 20 perguntas. Em dados ao
acaso dá ~2% de falsos alarmes por grupo, por isso um grupo isolado a acusar pede conferência, não pânico. A sequência usa a ordem de
criação aproximada (`created_at`, depois a ordem física); o teste de distribuição não depende da ordem.

**`--strict`** termina com código 1 só com defeitos graves: pergunta sem exatamente 1 correta ou com opção/enunciado vazio, enunciados
idênticos e "todas/nenhuma das anteriores". Tamanho e avisos de viés são meta em andamento e não derrubam nada.

