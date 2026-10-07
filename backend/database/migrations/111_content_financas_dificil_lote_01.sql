-- Migration 111: conteúdo do quiz, lote 01 (piloto, P15) — Finanças / difícil, 25 perguntas.
--
-- Problema corrigido: a alternativa correta era a mais longa em 99% das perguntas desta
-- categoria/dificuldade (o acaso daria ~25%) e as erradas eram absurdas, o que permitia
-- acertar sem saber. Aqui as 4 alternativas ficam com tamanho e estrutura parecidos, com
-- erradas plausíveis, e cada pergunta ganha explicação, "Aprenda" e "Dica".
--
-- Seguro: só altera o TEXTO das alternativas (mesmos IDs, mesma posição da correta, mesmo
-- is_correct) e só preenche perguntas ainda SEM explicação, por isso nunca sobrescreve
-- conteúdo já editado e voltar a correr é inofensivo. Enunciados e dificuldade não mudam.
-- Revisão humana do texto é recomendada antes de ir para produção.

BEGIN;

UPDATE question_alternatives qa
SET label = v.label
FROM (VALUES
  ('2b02aba4-4bf7-41bc-83af-e8dfccaba835'::uuid,0,$t$Tendência de o preço de um ativo subir de forma contínua ao longo do ano$t$),
  ('2b02aba4-4bf7-41bc-83af-e8dfccaba835'::uuid,1,$t$Diferença entre o preço de compra e o preço de venda do ativo$t$),
  ('2b02aba4-4bf7-41bc-83af-e8dfccaba835'::uuid,2,$t$Intensidade das oscilações do preço de um ativo ao longo do tempo$t$),
  ('2b02aba4-4bf7-41bc-83af-e8dfccaba835'::uuid,3,$t$Quantidade de unidades do ativo negociadas durante um dia de mercado$t$),
  ('66da9caf-d62c-4876-b523-160da17f03eb'::uuid,0,$t$Risco de o valor do ativo cair por causa da inflação do período$t$),
  ('66da9caf-d62c-4876-b523-160da17f03eb'::uuid,1,$t$Risco de quem emitiu o título deixar de pagar a dívida no vencimento$t$),
  ('66da9caf-d62c-4876-b523-160da17f03eb'::uuid,2,$t$Risco de a taxa de juros mudar antes do vencimento do título$t$),
  ('66da9caf-d62c-4876-b523-160da17f03eb'::uuid,3,$t$Risco de não conseguir vender um ativo depressa sem perder valor$t$),
  ('7d23cefc-f276-43ee-b9c9-9300e9de6e99'::uuid,0,$t$Rendimento que o investimento paga aos investidores no ano$t$),
  ('7d23cefc-f276-43ee-b9c9-9300e9de6e99'::uuid,1,$t$Facilidade de converter o investimento em dinheiro sem perder valor$t$),
  ('7d23cefc-f276-43ee-b9c9-9300e9de6e99'::uuid,2,$t$Nível de proteção do capital investido contra perdas de valor$t$),
  ('7d23cefc-f276-43ee-b9c9-9300e9de6e99'::uuid,3,$t$Prazo mínimo em que o dinheiro precisa ficar aplicado$t$),
  ('87ee11ca-431d-4e32-a61e-3cf0c6fd28c7'::uuid,0,$t$Liquidez mede o lucro obtido no ano; solvência mede o lucro acumulado$t$),
  ('87ee11ca-431d-4e32-a61e-3cf0c6fd28c7'::uuid,1,$t$Liquidez trata das dívidas de longo prazo; solvência trata das de curto prazo$t$),
  ('87ee11ca-431d-4e32-a61e-3cf0c6fd28c7'::uuid,2,$t$As duas medem a quantidade de dinheiro que há em caixa hoje$t$),
  ('87ee11ca-431d-4e32-a61e-3cf0c6fd28c7'::uuid,3,$t$Liquidez é pagar as dívidas de curto prazo; solvência, as de longo prazo$t$),
  ('a54e5cce-8ef0-42db-89f3-2d23ccfa0ec9'::uuid,0,$t$Taxa cobrada pelo banco por guardar o dinheiro do cliente numa conta$t$),
  ('a54e5cce-8ef0-42db-89f3-2d23ccfa0ec9'::uuid,1,$t$Ganho a que se renuncia ao não usar o dinheiro na melhor opção$t$),
  ('a54e5cce-8ef0-42db-89f3-2d23ccfa0ec9'::uuid,2,$t$Perda de valor do dinheiro por causa da inflação do período$t$),
  ('a54e5cce-8ef0-42db-89f3-2d23ccfa0ec9'::uuid,3,$t$Imposto pago ao Estado sobre o dinheiro que fica sem uso no ano$t$),
  ('c55b3c21-c38e-4708-b6cf-1532a3241327'::uuid,0,$t$Permite medir com clareza o desempenho real do negócio$t$),
  ('c55b3c21-c38e-4708-b6cf-1532a3241327'::uuid,1,$t$Reduz automaticamente o valor dos impostos que o negócio paga$t$),
  ('c55b3c21-c38e-4708-b6cf-1532a3241327'::uuid,2,$t$Assegura que o negócio terá lucro nos meses de vendas fracas$t$),
  ('c55b3c21-c38e-4708-b6cf-1532a3241327'::uuid,3,$t$Dispensa o registro das entradas e saídas de dinheiro$t$),
  ('0c14c497-b3bc-48dc-a6bb-b3ff4920e0cb'::uuid,0,$t$Mistura de capital próprio e dívidas que financia a empresa$t$),
  ('0c14c497-b3bc-48dc-a6bb-b3ff4920e0cb'::uuid,1,$t$Conjunto de edifícios, terrenos e máquinas que a empresa possui$t$),
  ('0c14c497-b3bc-48dc-a6bb-b3ff4920e0cb'::uuid,2,$t$Organização dos departamentos, dos cargos e das chefias da empresa$t$),
  ('0c14c497-b3bc-48dc-a6bb-b3ff4920e0cb'::uuid,3,$t$Total do dinheiro disponível em caixa e nas contas bancárias$t$),
  ('277e11c0-c9fa-4cc0-bdd4-f3ff1f37da2f'::uuid,0,$t$Plano com as metas de vendas e de produção para o ano seguinte$t$),
  ('277e11c0-c9fa-4cc0-bdd4-f3ff1f37da2f'::uuid,1,$t$Contrato que define as condições e os juros de um empréstimo$t$),
  ('277e11c0-c9fa-4cc0-bdd4-f3ff1f37da2f'::uuid,2,$t$Relatório que mostra a situação econômica e financeira de uma empresa$t$),
  ('277e11c0-c9fa-4cc0-bdd4-f3ff1f37da2f'::uuid,3,$t$Registro dos clientes, dos fornecedores e dos contatos da empresa$t$),
  ('4a564ca3-ce77-4eb1-8e29-5974e4c8a761'::uuid,0,$t$Acordo de compra ou venda de um ativo no futuro, com preço fixado hoje$t$),
  ('4a564ca3-ce77-4eb1-8e29-5974e4c8a761'::uuid,1,$t$Empréstimo cujo valor total só é pago por inteiro no fim do prazo contratado$t$),
  ('4a564ca3-ce77-4eb1-8e29-5974e4c8a761'::uuid,2,$t$Seguro que compensa a perda de valor de um ativo no fim do ano$t$),
  ('4a564ca3-ce77-4eb1-8e29-5974e4c8a761'::uuid,3,$t$Compromisso de investir uma quantia fixa por mês durante anos$t$),
  ('525d0a97-4322-42f4-a041-f9cb2d615940'::uuid,0,$t$Previsão dos resultados financeiros da empresa para os próximos anos$t$),
  ('525d0a97-4322-42f4-a041-f9cb2d615940'::uuid,1,$t$Cobrança das dívidas em atraso dos clientes da empresa em tribunal$t$),
  ('525d0a97-4322-42f4-a041-f9cb2d615940'::uuid,2,$t$Exame independente das contas para confirmar que estão corretas$t$),
  ('525d0a97-4322-42f4-a041-f9cb2d615940'::uuid,3,$t$Escolha das aplicações mais rentáveis para o dinheiro da empresa$t$),
  ('6e37ec06-ce31-44af-be0e-aaee95772131'::uuid,0,$t$Taxa de juros cobrada pelo banco sobre o empréstimo do projeto$t$),
  ('6e37ec06-ce31-44af-be0e-aaee95772131'::uuid,1,$t$Taxa de desconto que anula o valor presente líquido do investimento$t$),
  ('6e37ec06-ce31-44af-be0e-aaee95772131'::uuid,2,$t$Porcentagem do lucro distribuída aos sócios a cada ano$t$),
  ('6e37ec06-ce31-44af-be0e-aaee95772131'::uuid,3,$t$Variação média dos preços dos produtos da empresa durante o ano$t$),
  ('85d0762b-4a44-4210-87f1-8bfd9524891d'::uuid,0,$t$Disfarçar a origem ilegal do dinheiro para que pareça legítimo$t$),
  ('85d0762b-4a44-4210-87f1-8bfd9524891d'::uuid,1,$t$Troca de notas antigas por novas feita pelo banco central$t$),
  ('85d0762b-4a44-4210-87f1-8bfd9524891d'::uuid,2,$t$Declaração de rendimentos entregue ao fisco fora do prazo$t$),
  ('85d0762b-4a44-4210-87f1-8bfd9524891d'::uuid,3,$t$Transferência de dinheiro entre duas contas do titular$t$),
  ('8ad90c54-aaf0-4f4b-9479-6a9ff2b3ecb9'::uuid,0,$t$Uma quantia recebida hoje vale mais do que a mesma quantia no futuro$t$),
  ('8ad90c54-aaf0-4f4b-9479-6a9ff2b3ecb9'::uuid,1,$t$Receber no futuro é melhor porque os preços costumam baixar com o tempo$t$),
  ('8ad90c54-aaf0-4f4b-9479-6a9ff2b3ecb9'::uuid,2,$t$O valor do dinheiro não depende do momento em que é recebido$t$),
  ('8ad90c54-aaf0-4f4b-9479-6a9ff2b3ecb9'::uuid,3,$t$O valor do dinheiro só muda quando a moeda do país é trocada por outra$t$),
  ('b5d8c819-76a8-4f51-9e21-c502b95be80c'::uuid,0,$t$Soma das despesas previstas durante a vida do projeto$t$),
  ('b5d8c819-76a8-4f51-9e21-c502b95be80c'::uuid,1,$t$Método que traz os fluxos de caixa futuros do projeto ao valor de hoje$t$),
  ('b5d8c819-76a8-4f51-9e21-c502b95be80c'::uuid,2,$t$Porcentagem do investimento que é recuperada no primeiro ano$t$),
  ('b5d8c819-76a8-4f51-9e21-c502b95be80c'::uuid,3,$t$Diferença entre o preço de venda e o custo de cada produto vendido$t$),
  ('cdab3438-2710-4d85-91b7-b14f8f2ff0cc'::uuid,0,$t$Queda forte dos preços de um ativo causada pela falta de compradores$t$),
  ('cdab3438-2710-4d85-91b7-b14f8f2ff0cc'::uuid,1,$t$Alta de preços bem acima do valor real, alimentada por especulação$t$),
  ('cdab3438-2710-4d85-91b7-b14f8f2ff0cc'::uuid,2,$t$Subida de preços justificada pelo aumento dos lucros do ativo$t$),
  ('cdab3438-2710-4d85-91b7-b14f8f2ff0cc'::uuid,3,$t$Crise bancária provocada pela falta de dinheiro nos bancos do país$t$),
  ('e753dd3f-0a2d-4f74-b5b6-1818e408be3d'::uuid,0,$t$Estratégia de preços e de promoções usada para aumentar as vendas da loja$t$),
  ('e753dd3f-0a2d-4f74-b5b6-1818e408be3d'::uuid,1,$t$Conjunto de benefícios e de prêmios oferecidos aos funcionários$t$),
  ('e753dd3f-0a2d-4f74-b5b6-1818e408be3d'::uuid,2,$t$Sistema de controle do estoque e das compras feitas pela empresa$t$),
  ('e753dd3f-0a2d-4f74-b5b6-1818e408be3d'::uuid,3,$t$Regras para dirigir a empresa com transparência e responsabilidade$t$),
  ('413fd1d3-5662-40d5-9792-838f3cbee519'::uuid,0,$t$Aumento do valor de um ativo causado pela inflação ao longo do período$t$),
  ('413fd1d3-5662-40d5-9792-838f3cbee519'::uuid,1,$t$Redução gradual do valor de ativos intangíveis, como patentes e licenças$t$),
  ('413fd1d3-5662-40d5-9792-838f3cbee519'::uuid,2,$t$Registro da venda de produtos a prazo no balanço anual da empresa$t$),
  ('413fd1d3-5662-40d5-9792-838f3cbee519'::uuid,3,$t$Perda gradual de valor de bens físicos, como máquinas e veículos$t$),
  ('485e57e5-96b0-41cc-ba59-52f30bc8baf9'::uuid,0,$t$Auditoria feita por uma empresa externa contratada pelo governo do país$t$),
  ('485e57e5-96b0-41cc-ba59-52f30bc8baf9'::uuid,1,$t$Cálculo dos impostos que a empresa deve pagar ao fisco a cada ano$t$),
  ('485e57e5-96b0-41cc-ba59-52f30bc8baf9'::uuid,2,$t$Plano de metas de vendas definido pela direção comercial da empresa$t$),
  ('485e57e5-96b0-41cc-ba59-52f30bc8baf9'::uuid,3,$t$Processos que protegem os recursos e garantem informações corretas$t$),
  ('4a2ab04a-486e-4340-8e24-b4c9074d4cfb'::uuid,0,$t$Previsão das receitas e despesas correntes do próximo mês$t$),
  ('4a2ab04a-486e-4340-8e24-b4c9074d4cfb'::uuid,1,$t$Cálculo do salário e dos encargos dos funcionários da empresa$t$),
  ('4a2ab04a-486e-4340-8e24-b4c9074d4cfb'::uuid,2,$t$Planejamento e avaliação de investimentos de longo prazo$t$),
  ('4a2ab04a-486e-4340-8e24-b4c9074d4cfb'::uuid,3,$t$Controle diário do dinheiro que entra e sai do caixa$t$),
  ('4ed610c7-58f1-4e40-8dfc-bfeeedc40807'::uuid,0,$t$Prazo médio do título que indica o quanto o preço reage aos juros$t$),
  ('4ed610c7-58f1-4e40-8dfc-bfeeedc40807'::uuid,1,$t$Data em que quem emitiu o título decide pagá-lo antes do vencimento$t$),
  ('4ed610c7-58f1-4e40-8dfc-bfeeedc40807'::uuid,2,$t$Porcentagem do valor do título que é paga em juros a cada ano$t$),
  ('4ed610c7-58f1-4e40-8dfc-bfeeedc40807'::uuid,3,$t$Número de dias em que o título foi negociado na bolsa de valores$t$),
  ('7da17bcc-ce51-4885-b3dc-e7d405fb913a'::uuid,0,$t$Capacidade de aumentar as vendas mesmo sem controlar os gastos$t$),
  ('7da17bcc-ce51-4885-b3dc-e7d405fb913a'::uuid,1,$t$Capacidade de atingir objetivos usando bem os recursos disponíveis$t$),
  ('7da17bcc-ce51-4885-b3dc-e7d405fb913a'::uuid,2,$t$Quantidade de dinheiro que a empresa mantém guardada em caixa ou em bancos$t$),
  ('7da17bcc-ce51-4885-b3dc-e7d405fb913a'::uuid,3,$t$Número de investimentos que a empresa realizou durante o ano$t$),
  ('91b46fc1-34d8-400c-8a1b-2863c1bc9c8b'::uuid,0,$t$Lucro final da empresa depois de pagar as despesas, os juros e os impostos$t$),
  ('91b46fc1-34d8-400c-8a1b-2863c1bc9c8b'::uuid,1,$t$Total das vendas do período menos o custo das mercadorias vendidas$t$),
  ('91b46fc1-34d8-400c-8a1b-2863c1bc9c8b'::uuid,2,$t$Fluxo de caixa que sobra depois de pagar os investimentos do ano$t$),
  ('91b46fc1-34d8-400c-8a1b-2863c1bc9c8b'::uuid,3,$t$Lucro operacional antes de juros, impostos, depreciação e amortização$t$),
  ('a4986e7f-bd80-4d21-ae2b-e0b3d484c2fb'::uuid,0,$t$Aumento do número de produtos fabricados, independentemente do custo$t$),
  ('a4986e7f-bd80-4d21-ae2b-e0b3d484c2fb'::uuid,1,$t$Capacidade de obter melhores resultados usando bem os recursos$t$),
  ('a4986e7f-bd80-4d21-ae2b-e0b3d484c2fb'::uuid,2,$t$Capacidade de reduzir os investimentos ao mínimo possível a cada ano$t$),
  ('a4986e7f-bd80-4d21-ae2b-e0b3d484c2fb'::uuid,3,$t$Crescimento do número de funcionários contratados pela empresa no ano$t$),
  ('b9a02231-9a67-46d2-b1f7-427cd146bd69'::uuid,0,$t$Taxa máxima que os bancos comerciais podem cobrar de seus clientes$t$),
  ('b9a02231-9a67-46d2-b1f7-427cd146bd69'::uuid,1,$t$Taxa fixa cobrada nos empréstimos feitos pelos bancos às empresas do país$t$),
  ('b9a02231-9a67-46d2-b1f7-427cd146bd69'::uuid,2,$t$Taxa de referência do banco central que influencia as demais taxas$t$),
  ('b9a02231-9a67-46d2-b1f7-427cd146bd69'::uuid,3,$t$Rendimento médio das ações negociadas na bolsa de valores do país$t$),
  ('fe40e314-8a27-4519-a64e-bc4a49fc4096'::uuid,0,$t$Custo que aumenta na mesma proporção da quantidade produzida pela empresa$t$),
  ('fe40e314-8a27-4519-a64e-bc4a49fc4096'::uuid,1,$t$Gasto extra que surge nos meses em que as vendas são elevadas$t$),
  ('fe40e314-8a27-4519-a64e-bc4a49fc4096'::uuid,2,$t$Valor cobrado pelo fornecedor por cada unidade que a empresa compra$t$),
  ('fe40e314-8a27-4519-a64e-bc4a49fc4096'::uuid,3,$t$Custo que se mantém praticamente igual, ainda que a produção varie$t$)
) AS v(question_id, display_order, label)
WHERE qa.question_id = v.question_id
  AND qa.display_order = v.display_order
  AND EXISTS (SELECT 1 FROM questions q WHERE q.id = qa.question_id AND q.explanation IS NULL);

UPDATE questions q
SET explanation = v.explanation,
    learn_point = v.learn_point,
    memory_tip  = v.memory_tip,
    updated_at  = now()
FROM (VALUES
  ('2b02aba4-4bf7-41bc-83af-e8dfccaba835'::uuid,$t$Volatilidade mede o quanto o preço de um ativo sobe e desce num período. Quanto maior, mais incerto é o retorno. Ela não indica a direção do preço, só a intensidade das oscilações.$t$,$t$Volatilidade mede a intensidade das oscilações do preço, não a direção.$t$,$t$Volátil é o que balança muito, para cima e para baixo.$t$),
  ('66da9caf-d62c-4876-b523-160da17f03eb'::uuid,$t$O risco de liquidez é a dificuldade de transformar um ativo em dinheiro depressa sem aceitar um preço muito abaixo do justo. Imóveis e ações pouco negociadas costumam ter mais risco de liquidez.$t$,$t$Risco de liquidez é a possibilidade de não conseguir vender um ativo depressa sem perder valor.$t$,$t$Liquidez vem de líquido: o que escorre depressa para dinheiro.$t$),
  ('7d23cefc-f276-43ee-b9c9-9300e9de6e99'::uuid,$t$Liquidez indica a rapidez e o custo com que um investimento vira dinheiro. Uma poupança com resgate a qualquer momento tem alta liquidez; um terreno tem baixa liquidez.$t$,$t$Liquidez é a rapidez de conversão em dinheiro sem perder valor, e não a rentabilidade.$t$,$t$Pergunte: em quanto tempo o dinheiro está na minha mão?$t$),
  ('87ee11ca-431d-4e32-a61e-3cf0c6fd28c7'::uuid,$t$Liquidez é a capacidade de pagar obrigações que vencem em breve com o dinheiro disponível. Solvência olha para o longo prazo: se o patrimônio cobre todas as dívidas. Uma empresa pode ser solvente e ainda ter problemas de liquidez.$t$,$t$Liquidez é curto prazo; solvência é longo prazo.$t$,$t$Liquidez é agora; solvência é lá na frente.$t$),
  ('a54e5cce-8ef0-42db-89f3-2d23ccfa0ec9'::uuid,$t$Custo de oportunidade é o ganho a que se renuncia ao escolher uma opção em vez da melhor alternativa. Dinheiro parado deixa de render os juros que renderia numa aplicação segura.$t$,$t$Toda escolha tem um custo: o que se deixou de ganhar com a melhor alternativa.$t$,$t$Pergunte: o que perdi por não escolher a outra opção?$t$),
  ('c55b3c21-c38e-4708-b6cf-1532a3241327'::uuid,$t$Misturar as contas esconde quanto o negócio realmente ganha e gasta. Com as despesas separadas, é possível calcular o lucro, planejar e definir um salário para o dono. As contas também ficam mais claras para o fisco e para os bancos.$t$,$t$Separar as contas mostra o desempenho verdadeiro do negócio.$t$,$t$Dinheiro do negócio num bolso, dinheiro pessoal no outro.$t$),
  ('0c14c497-b3bc-48dc-a6bb-b3ff4920e0cb'::uuid,$t$A estrutura de capital mostra de onde vem o dinheiro da empresa: capital dos sócios e financiamentos de terceiros, como empréstimos. A proporção entre os dois afeta o custo de financiamento e o risco.$t$,$t$Estrutura de capital é a mistura de capital próprio e dívida.$t$,$t$Pergunte: o dinheiro é dos sócios ou dos credores?$t$),
  ('277e11c0-c9fa-4cc0-bdd4-f3ff1f37da2f'::uuid,$t$As demonstrações financeiras, como o balanço e a demonstração de resultados, resumem ativos, dívidas, receitas e despesas. São usadas por gestores, investidores, bancos e pelo fisco.$t$,$t$Demonstrações financeiras resumem a situação e o desempenho da empresa.$t$,$t$O balanço é a fotografia; o resultado é o filme.$t$),
  ('4a564ca3-ce77-4eb1-8e29-5974e4c8a761'::uuid,$t$Num contrato futuro, as partes combinam hoje o preço, a quantidade e a data de uma negociação que ocorre mais tarde. Serve para se proteger de variações de preço, por exemplo, um produtor que fixa o preço da colheita.$t$,$t$Contrato futuro fixa hoje o preço de uma compra ou venda que acontece mais tarde.$t$,$t$Futuro: preço combinado agora, negócio feito depois.$t$),
  ('525d0a97-4322-42f4-a041-f9cb2d615940'::uuid,$t$Na auditoria financeira, um auditor independente examina registros e demonstrações para confirmar que refletem a realidade e seguem as normas contábeis e a lei. Isso dá confiança a investidores, bancos e ao fisco.$t$,$t$Auditoria verifica se as contas estão corretas e conformes às normas.$t$,$t$O auditor é o olhar de fora que confirma os números.$t$),
  ('6e37ec06-ce31-44af-be0e-aaee95772131'::uuid,$t$A TIR é a taxa de retorno que faz o valor presente das entradas de caixa igualar o investimento, ou seja, que deixa o VPL em zero. Se for maior que a taxa mínima exigida, o projeto tende a ser atraente.$t$,$t$TIR é a taxa de retorno que zera o VPL do projeto.$t$,$t$TIR é a taxa em que o projeto empata (VPL = 0).$t$),
  ('85d0762b-4a44-4210-87f1-8bfd9524891d'::uuid,$t$Lavagem de dinheiro é esconder a origem criminosa de recursos, passando-os por vários negócios ou contas até parecerem legais. É crime, e bancos e empresas têm o dever de identificar e comunicar operações suspeitas.$t$,$t$Lavagem de dinheiro dá aparência legal a dinheiro de origem criminosa.$t$,$t$Lavar é limpar a origem suja do dinheiro.$t$),
  ('8ad90c54-aaf0-4f4b-9479-6a9ff2b3ecb9'::uuid,$t$O dinheiro de hoje pode ser investido e render juros, e a inflação reduz o poder de compra com o tempo. Por isso, receber 1.000 hoje vale mais do que receber 1.000 daqui a um ano.$t$,$t$Dinheiro hoje vale mais do que o mesmo dinheiro no futuro.$t$,$t$Hoje posso aplicar; amanhã só posso esperar.$t$),
  ('b5d8c819-76a8-4f51-9e21-c502b95be80c'::uuid,$t$O VPL desconta os fluxos de caixa futuros a uma taxa e subtrai o investimento inicial. Se for positivo, o projeto cria valor; se for negativo, tende a destruir valor.$t$,$t$VPL positivo indica que o projeto cria valor, considerando o valor do dinheiro no tempo.$t$,$t$VPL maior que zero: vale a pena; menor que zero: cuidado.$t$),
  ('cdab3438-2710-4d85-91b7-b14f8f2ff0cc'::uuid,$t$Numa bolha, os preços sobem muito além do valor fundamental porque muita gente compra esperando vender mais caro. Quando a confiança acaba, os preços despencam: é o estouro da bolha.$t$,$t$Bolha é preço muito acima do valor real, sustentado pela especulação.$t$,$t$Bolha de sabão: cresce, cresce e estoura.$t$),
  ('e753dd3f-0a2d-4f74-b5b6-1818e408be3d'::uuid,$t$A governança corporativa define como a empresa é dirigida e controlada: os papéis dos sócios, do conselho e dos gestores, a prestação de contas e a transparência. Reduz abusos e aumenta a confiança dos investidores.$t$,$t$Governança são as regras para dirigir a empresa com transparência e prestação de contas.$t$,$t$Quem manda, quem fiscaliza e quem presta contas.$t$),
  ('413fd1d3-5662-40d5-9792-838f3cbee519'::uuid,$t$A amortização contábil distribui, ao longo da vida útil, o custo de ativos intangíveis, como patentes, licenças e direitos. Para bens físicos usa-se o termo depreciação.$t$,$t$Amortização é para ativos intangíveis; depreciação é para bens físicos.$t$,$t$Amortiza-se o que não se toca; deprecia-se o que se toca.$t$),
  ('485e57e5-96b0-41cc-ba59-52f30bc8baf9'::uuid,$t$Controle interno são regras e procedimentos, como separação de funções, autorizações e conferências, que evitam fraudes e erros e garantem relatórios confiáveis. É feito dentro da própria empresa.$t$,$t$Controle interno protege os recursos e garante informações financeiras confiáveis.$t$,$t$Quem guarda o dinheiro não é quem o registra.$t$),
  ('4a2ab04a-486e-4340-8e24-b4c9074d4cfb'::uuid,$t$O orçamento de capital decide em que grandes projetos investir, como máquinas, instalações ou expansão, comparando custos e retornos com ferramentas como VPL e TIR. Envolve valores altos e retorno ao longo de vários anos.$t$,$t$Orçamento de capital avalia investimentos de longo prazo.$t$,$t$Capital quer dizer grandes investimentos, de longo prazo.$t$),
  ('4ed610c7-58f1-4e40-8dfc-bfeeedc40807'::uuid,$t$Duration é o prazo médio ponderado dos fluxos de um título. Quanto maior, mais o preço do título cai quando os juros sobem e mais sobe quando os juros descem.$t$,$t$Duration mede a sensibilidade do preço do título às taxas de juros.$t$,$t$Duration longa significa preço mais sensível aos juros.$t$),
  ('7da17bcc-ce51-4885-b3dc-e7d405fb913a'::uuid,$t$Eficiência financeira é conseguir bons resultados gastando só o necessário: evitar desperdícios, planejar e usar o dinheiro onde traz mais retorno.$t$,$t$Eficiência é obter resultados usando bem os recursos, e não gastar ou guardar mais.$t$,$t$Fazer mais com o mesmo dinheiro.$t$),
  ('91b46fc1-34d8-400c-8a1b-2863c1bc9c8b'::uuid,$t$O EBITDA é o resultado das operações antes de juros, impostos, depreciação e amortização. Ajuda a comparar o desempenho operacional entre empresas, mas não é o lucro final nem o dinheiro disponível em caixa.$t$,$t$EBITDA mostra o desempenho operacional antes de juros, impostos, depreciação e amortização.$t$,$t$As letras dizem o que fica de fora: juros, impostos, depreciação e amortização.$t$),
  ('a4986e7f-bd80-4d21-ae2b-e0b3d484c2fb'::uuid,$t$A produtividade financeira relaciona os resultados com os recursos usados: quanto lucro ou receita se gera por cada unidade investida. Produzir mais gastando muito mais não é ser mais produtivo.$t$,$t$Produtividade compara os resultados com os recursos usados.$t$,$t$Resultado dividido pelos recursos usados.$t$),
  ('b9a02231-9a67-46d2-b1f7-427cd146bd69'::uuid,$t$A taxa básica de juros é a referência definida pelo banco central. Quando sobe ou desce, influencia os juros de empréstimos, financiamentos e aplicações, e ajuda a controlar a inflação.$t$,$t$A taxa básica é a referência do banco central que influencia as demais taxas.$t$,$t$O banco central mexe na taxa básica e os outros juros acompanham.$t$),
  ('fe40e314-8a27-4519-a64e-bc4a49fc4096'::uuid,$t$Custos fixos, como aluguel, salários fixos e seguros, não mudam com o volume produzido no curto prazo. Já os custos variáveis crescem junto com a produção.$t$,$t$Custo fixo não depende da quantidade produzida.$t$,$t$Fixo é o que fica igual, produza muito ou pouco.$t$)
) AS v(question_id, explanation, learn_point, memory_tip)
WHERE q.id = v.question_id
  AND q.explanation IS NULL;

COMMIT;
