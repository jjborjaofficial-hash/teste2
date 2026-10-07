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
