-- Explicações pedagógicas (BE-004) — IA médio lote 3: as mesmas 25 perguntas da migration 412 (linguagem simples e curta,
-- conforme docs/quiz-v2-rodadas-e-feedback.md), já coerentes com as alternativas novas. Só atualiza perguntas que ainda NÃO têm
-- explicação (idempotente, nunca sobrescreve texto já escrito). Não altera perguntas nem alternativas. Se alguma pergunta já
-- não existir, é ignorada (nunca falha, para não impedir o arranque do backend). O runner já envolve o ficheiro numa transação.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE questions q
  SET explanation = v.explanation
  FROM (VALUES
    ('seed_ia_medio_v3', 'O que é aprendizado por reforço?', 'No aprendizado por reforço o modelo age, recebe um sinal de recompensa ou penalização e vai ajustando o comportamento para ganhar mais recompensa. É assim que se treinam, por exemplo, agentes que jogam.'),
    ('seed_ia_medio_v3', 'Num sistema de aprendizado por reforço, o que representa uma recompensa?', 'A recompensa é o sinal que diz ao agente se a ação foi boa ou má. O agente procura as ações que dão mais recompensa.'),
    ('seed_ia_medio_v3', 'Um agente escolhe uma ação, recebe uma recompensa e ajusta seu comportamento. Esse processo está associado a:', 'Agir, receber recompensa e ajustar o comportamento é o ciclo do aprendizado por reforço. Não há respostas prontas; o agente aprende com o resultado das suas ações.'),
    ('seed_ia_medio_v3', 'Qual é a função geral de uma camada em uma rede neural?', 'Cada camada recebe os dados da anterior e transforma-os num formato mais útil para a seguinte. Empilhando camadas, a rede constrói representações cada vez mais ricas.'),
    ('seed_ia_medio_v3', 'O que são pesos em uma rede neural?', 'Os pesos são números dentro da rede que decidem a importância de cada entrada. O treinamento consiste em ajustar esses pesos até a rede acertar mais.'),
    ('seed_ia_medio_v3', 'Durante o treinamento, os pesos de uma rede neural normalmente:', 'Treinar uma rede neural é ir mudando os pesos, passo a passo, para que o erro diminua. No fim, os pesos guardam o que a rede aprendeu.'),
    ('seed_ia_medio_v3', 'O que é uma função de ativação?', 'A função de ativação decide como cada neurónio responde à sua entrada, introduzindo curvas em vez de simples somas. É isso que permite à rede aprender relações complexas.'),
    ('seed_ia_medio_v3', 'Por que a não linearidade é importante em redes neurais?', 'Sem não linearidade, uma rede com muitas camadas comportava-se como uma única conta simples e só aprenderia relações em linha reta. A não linearidade deixa-a captar padrões complicados.'),
    ('seed_ia_medio_v3', 'O que significa época (epoch) no treinamento de um modelo?', 'Uma época é uma volta completa por todos os exemplos de treinamento. Treinar costuma exigir várias épocas, para o modelo ir melhorando aos poucos.'),
    ('seed_ia_medio_v3', 'Se um modelo for treinado durante muitas épocas sem controle adequado, qual risco pode aumentar?', 'Treinar épocas a mais pode fazer o modelo decorar os exemplos, ou seja, cair em overfitting. Por isso se vigia o erro na validação e se para a tempo.'),
    ('seed_ia_medio_v3', 'O que é taxa de aprendizagem (learning rate)?', 'A taxa de aprendizagem diz o tamanho do passo que o modelo dá cada vez que ajusta os pesos. Passos pequenos demoram muito e passos grandes podem passar ao lado da melhor solução.'),
    ('seed_ia_medio_v3', 'Se a taxa de aprendizagem for excessivamente alta, qual problema pode ocorrer?', 'Com uma taxa de aprendizagem muito alta, os passos são grandes demais e o modelo salta de um lado para o outro sem assentar numa boa solução. Por isso o valor tem de ser escolhido com cuidado.'),
    ('seed_ia_medio_v3', 'O que é uma função de perda?', 'A função de perda dá um número para o erro do modelo: quanto menor, melhor. O treinamento tenta fazer esse número descer.'),
    ('seed_ia_medio_v3', 'Durante o treinamento, o objetivo comum de um algoritmo de otimização é:', 'O algoritmo de otimização ajusta os pesos para que a função de perda seja a menor possível, o que significa que os erros do modelo diminuem.'),
    ('seed_ia_medio_v3', 'O que é uma matriz de confusão?', 'A matriz de confusão cruza o que o modelo previu com o que era a realidade, mostrando acertos e os tipos de erro. Ajuda a perceber onde ele se engana.'),
    ('seed_ia_medio_v3', 'Em classificação, o que representa um verdadeiro positivo?', 'Verdadeiro positivo é quando o modelo diz que sim e acerta, porque o caso é mesmo positivo. Exemplo: dizer que um e-mail é spam e ele ser spam.'),
    ('seed_ia_medio_v3', 'O que representa um falso positivo?', 'Falso positivo é um alarme falso: o modelo diz que sim, mas a realidade é não. Exemplo: marcar como spam um e-mail importante.'),
    ('seed_ia_medio_v3', 'O que representa um falso negativo?', 'Falso negativo é um caso que passou despercebido: o modelo diz que não, mas era sim. Exemplo: não detetar uma doença que a pessoa tem.'),
    ('seed_ia_medio_v3', 'Por que precisão (precision) e recall podem ser importantes?', 'A precisão diz quantas das previsões positivas estavam certas, e o recall diz quantos dos casos positivos reais foram apanhados. Cada uma mostra um lado do desempenho.'),
    ('seed_ia_medio_v3', 'Em um sistema de detecção de doenças, deixar passar muitos casos positivos pode ser especialmente preocupante. Qual métrica pode receber atenção especial?', 'Num diagnóstico, deixar passar um doente (falso negativo) é grave, e o recall mede exatamente quantos casos positivos reais foram apanhados. Por isso é a métrica a vigiar.'),
    ('seed_ia_medio_v3', 'O que significa balancear um conjunto de dados?', 'Balancear é fazer com que as classes estejam representadas de forma adequada, para que o modelo não aprenda só a classe mais comum. Pode ser feito acrescentando exemplos da classe rara ou reduzindo a mais comum.'),
    ('seed_ia_medio_v3', 'Por que classes muito desequilibradas podem dificultar o treinamento?', 'Se quase todos os exemplos são de uma classe, o modelo acerta muito só por apostar nela e aprende pouco sobre a rara. O resultado parece bom, mas falha justamente nos casos raros.'),
    ('seed_ia_medio_v3', 'O que é normalização de dados?', 'Normalizar é pôr os valores numa escala comparável, por exemplo entre 0 e 1. Assim, uma característica com números enormes não domina as outras.'),
    ('seed_ia_medio_v3', 'Por que a normalização pode ajudar determinados modelos?', 'Quando uma característica vai de 0 a 1 e outra de 0 a 1 000 000, o ajuste dos pesos fica difícil e lento. Normalizar equilibra as escalas e ajuda o treinamento.'),
    ('seed_ia_medio_v3', 'O que é engenharia de características (feature engineering)?', 'Feature engineering é preparar bem as informações de entrada: criar novas, transformar as que existem ou escolher as mais úteis. Boas características ajudam muito o modelo.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações IA médio lote 3: % pergunta(s) atualizada(s) (esperado: 25).', v_updated;
END $$;
