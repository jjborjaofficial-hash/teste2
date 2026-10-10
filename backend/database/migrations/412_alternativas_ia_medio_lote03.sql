-- Alternativas (BE-003, regularização) — IA médio lote 3: as 25 perguntas seguintes de IA médio sem explicação (seed_ia_medio_v3, de "O que é aprendizado por reforço?" a "engenharia de características", na ordem do ficheiro 077)
-- Segue docs/quiz-v2-alternativas-padrao.md e a regra do dono (2026-10-07): a resposta
-- CERTA NÃO muda; só o texto das alternativas ERRADAS é ajustado (tamanho e forma parecidos com os da certa, distratores plausíveis,
-- sem absolutos só nas erradas).
-- Segurança: só altera question_alternatives.label, só de alternativas erradas (is_correct = FALSE), e só se o texto atual
-- ainda for exatamente o original (nunca sobrescreve edição posterior; idempotente). Não toca em ids, is_correct,
-- display_order nem perguntas. O runner já envolve o ficheiro numa transação.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE question_alternatives a
  SET label = v.new_label
  FROM questions q,
  (VALUES
    ('seed_ia_medio_v3', 'O que é aprendizado por reforço?', 0, 'Um sistema funciona apenas com regras fixas', 'Um modelo aprende com exemplos em que a resposta certa já vem indicada'),
    ('seed_ia_medio_v3', 'O que é aprendizado por reforço?', 2, 'Um modelo recebe sempre a resposta final de cada exemplo', 'Um modelo agrupa os dados por semelhança, sem receber nenhuma indicação'),
    ('seed_ia_medio_v3', 'O que é aprendizado por reforço?', 3, 'Um modelo não recebe qualquer retorno', 'Um modelo segue instruções escritas por programadores para cada situação'),
    ('seed_ia_medio_v3', 'Num sistema de aprendizado por reforço, o que representa uma recompensa?', 0, 'Um arquivo de treinamento', 'Um conjunto de exemplos usado para treinar o agente'),
    ('seed_ia_medio_v3', 'Num sistema de aprendizado por reforço, o que representa uma recompensa?', 1, 'Um erro de memória', 'Uma instrução que diz ao agente qual ação deve executar'),
    ('seed_ia_medio_v3', 'Num sistema de aprendizado por reforço, o que representa uma recompensa?', 2, 'Uma camada de rede', 'Uma medida do tempo gasto em cada decisão do agente'),
    ('seed_ia_medio_v3', 'Um agente escolhe uma ação, recebe uma recompensa e ajusta seu comportamento. Esse processo está associado a:', 0, 'Compressão de dados', 'Aprendizado supervisionado'),
    ('seed_ia_medio_v3', 'Um agente escolhe uma ação, recebe uma recompensa e ajusta seu comportamento. Esse processo está associado a:', 1, 'Reconhecimento óptico', 'Aprendizado não supervisionado'),
    ('seed_ia_medio_v3', 'Qual é a função geral de uma camada em uma rede neural?', 1, 'Substituir o sistema operacional', 'Guardar os dados originais usados no treinamento'),
    ('seed_ia_medio_v3', 'Qual é a função geral de uma camada em uma rede neural?', 2, 'Controlar a bateria', 'Decidir qual é o utilizador que pode usar o modelo'),
    ('seed_ia_medio_v3', 'Qual é a função geral de uma camada em uma rede neural?', 3, 'Armazenar permanentemente todos os arquivos', 'Medir o tempo que o modelo demora a responder'),
    ('seed_ia_medio_v3', 'O que são pesos em uma rede neural?', 1, 'Arquivos de imagem', 'Valores fixos que definem o número de camadas antes do treinamento'),
    ('seed_ia_medio_v3', 'O que são pesos em uma rede neural?', 2, 'Rótulos dos utilizadores', 'Informações que identificam quem está a usar a rede neural'),
    ('seed_ia_medio_v3', 'O que são pesos em uma rede neural?', 3, 'Componentes físicos do computador', 'Medidas do tamanho e do formato dos dados que entram na rede neural'),
    ('seed_ia_medio_v3', 'Durante o treinamento, os pesos de uma rede neural normalmente:', 1, 'São substituídos por arquivos', 'São fixados pelo programador antes e mantidos até ao fim'),
    ('seed_ia_medio_v3', 'Durante o treinamento, os pesos de uma rede neural normalmente:', 2, 'Permanecem sempre iguais', 'Ficam iguais depois da primeira passagem pelos dados'),
    ('seed_ia_medio_v3', 'Durante o treinamento, os pesos de uma rede neural normalmente:', 3, 'São apagados após cada exemplo', 'São repostos aos valores iniciais depois de cada época'),
    ('seed_ia_medio_v3', 'O que é uma função de ativação?', 1, 'Um mecanismo de armazenamento', 'Um mecanismo que guarda os pesos da rede entre uma época e a seguinte'),
    ('seed_ia_medio_v3', 'O que é uma função de ativação?', 2, 'Um banco de dados', 'Um conjunto de dados que a rede neural usa para se treinar e avaliar'),
    ('seed_ia_medio_v3', 'O que é uma função de ativação?', 3, 'Um sistema para ligar o computador', 'Um mecanismo que mede o erro entre a previsão e o valor esperado'),
    ('seed_ia_medio_v3', 'Por que a não linearidade é importante em redes neurais?', 0, 'Elimina todos os dados', 'Reduz o tempo de treinamento ao simplificar a rede'),
    ('seed_ia_medio_v3', 'Por que a não linearidade é importante em redes neurais?', 1, 'Impede o aprendizado', 'Evita que a rede precise de ajustar os pesos durante o treino'),
    ('seed_ia_medio_v3', 'Por que a não linearidade é importante em redes neurais?', 3, 'Reduz todas as entradas a zero', 'Permite guardar mais dados na memória durante o treinamento'),
    ('seed_ia_medio_v3', 'O que significa época (epoch) no treinamento de um modelo?', 0, 'Uma camada da rede neural', 'Uma passagem pelo conjunto de teste para medir o erro final'),
    ('seed_ia_medio_v3', 'O que significa época (epoch) no treinamento de um modelo?', 2, 'O tempo necessário para instalar o programa', 'O tempo máximo que o modelo tem para dar uma resposta'),
    ('seed_ia_medio_v3', 'O que significa época (epoch) no treinamento de um modelo?', 3, 'Uma categoria de dados', 'Um grupo de exemplos escolhidos ao acaso para a validação'),
    ('seed_ia_medio_v3', 'Se um modelo for treinado durante muitas épocas sem controle adequado, qual risco pode aumentar?', 0, 'Ausência de dados', 'Underfitting'),
    ('seed_ia_medio_v3', 'Se um modelo for treinado durante muitas épocas sem controle adequado, qual risco pode aumentar?', 1, 'Perda da linguagem', 'Viés de seleção'),
    ('seed_ia_medio_v3', 'Se um modelo for treinado durante muitas épocas sem controle adequado, qual risco pode aumentar?', 2, 'Desligamento automático do computador', 'Ruído nos dados'),
    ('seed_ia_medio_v3', 'O que é taxa de aprendizagem (learning rate)?', 0, 'Número total de utilizadores', 'Número de exemplos que o modelo vê em cada passagem pelos dados do treinamento'),
    ('seed_ia_medio_v3', 'O que é taxa de aprendizagem (learning rate)?', 1, 'Quantidade de arquivos armazenados', 'Número de camadas que a rede neural utiliza para processar as entradas'),
    ('seed_ia_medio_v3', 'O que é taxa de aprendizagem (learning rate)?', 3, 'Velocidade da conexão de internet', 'Percentagem de dados que o modelo separa para a fase de avaliação final'),
    ('seed_ia_medio_v3', 'Se a taxa de aprendizagem for excessivamente alta, qual problema pode ocorrer?', 0, 'O modelo necessariamente fica perfeito', 'O treinamento fica muito lento e o modelo quase não ajusta os pesos'),
    ('seed_ia_medio_v3', 'Se a taxa de aprendizagem for excessivamente alta, qual problema pode ocorrer?', 2, 'Os dados desaparecem', 'O modelo passa a ignorar os dados de treino e usa só os de teste'),
    ('seed_ia_medio_v3', 'Se a taxa de aprendizagem for excessivamente alta, qual problema pode ocorrer?', 3, 'O computador deixa de utilizar algoritmos', 'O modelo aprende mais depressa e atinge a melhor solução possível'),
    ('seed_ia_medio_v3', 'O que é uma função de perda?', 1, 'Um método de compressão', 'Uma medida usada para quantificar o tempo gasto entre duas fases do treinamento'),
    ('seed_ia_medio_v3', 'O que é uma função de perda?', 2, 'Um sistema de segurança física', 'Um método usado para escolher quais dados entram em cada época de treinamento'),
    ('seed_ia_medio_v3', 'O que é uma função de perda?', 3, 'Uma função que apaga dados', 'Uma função que decide como cada neurónio responde à entrada que lhe chega'),
    ('seed_ia_medio_v3', 'Durante o treinamento, o objetivo comum de um algoritmo de otimização é:', 1, 'Eliminar todas as entradas', 'Reduzir o número de entradas'),
    ('seed_ia_medio_v3', 'Durante o treinamento, o objetivo comum de um algoritmo de otimização é:', 2, 'Aumentar o tamanho do conjunto de teste', 'Aumentar o tamanho do modelo'),
    ('seed_ia_medio_v3', 'O que é uma matriz de confusão?', 0, 'Uma estrutura de armazenamento físico', 'Uma tabela que resume o tempo de resposta do modelo comparando pedidos simples e complexos'),
    ('seed_ia_medio_v3', 'O que é uma matriz de confusão?', 1, 'Uma tabela de preços', 'Um gráfico que mostra a evolução do erro do modelo comparando as épocas de treinamento'),
    ('seed_ia_medio_v3', 'O que é uma matriz de confusão?', 3, 'Um banco de imagens', 'Uma lista que resume as características dos dados comparando valores mínimos e máximos'),
    ('seed_ia_medio_v3', 'Em classificação, o que representa um verdadeiro positivo?', 0, 'O modelo prevê positivo e o caso é negativo', 'O modelo prevê positivo e o caso real é negativo'),
    ('seed_ia_medio_v3', 'Em classificação, o que representa um verdadeiro positivo?', 2, 'O modelo não produz previsão', 'O modelo prevê negativo e o caso real é negativo'),
    ('seed_ia_medio_v3', 'Em classificação, o que representa um verdadeiro positivo?', 3, 'O modelo prevê negativo e o caso é positivo', 'O modelo prevê negativo e o caso real é positivo'),
    ('seed_ia_medio_v3', 'O que representa um falso positivo?', 0, 'Uma previsão negativa correta', 'Uma previsão negativa quando o caso real é positivo'),
    ('seed_ia_medio_v3', 'O que representa um falso positivo?', 2, 'Ausência de previsão', 'Uma previsão negativa quando o caso real é negativo'),
    ('seed_ia_medio_v3', 'O que representa um falso positivo?', 3, 'Uma previsão positiva correta', 'Uma previsão positiva quando o caso real é positivo'),
    ('seed_ia_medio_v3', 'O que representa um falso negativo?', 0, 'O modelo não possui dados', 'O modelo prevê positivo quando o caso real é negativo'),
    ('seed_ia_medio_v3', 'O que representa um falso negativo?', 1, 'O modelo prevê negativo corretamente', 'O modelo prevê negativo quando o caso real é negativo'),
    ('seed_ia_medio_v3', 'O que representa um falso negativo?', 3, 'O modelo prevê positivo corretamente', 'O modelo prevê positivo quando o caso real é positivo'),
    ('seed_ia_medio_v3', 'Por que precisão (precision) e recall podem ser importantes?', 1, 'Avaliam a velocidade da internet', 'Permitem medir a rapidez com que um classificador responde aos pedidos'),
    ('seed_ia_medio_v3', 'Por que precisão (precision) e recall podem ser importantes?', 2, 'Substituem todos os dados de teste', 'Permitem escolher o número de camadas que um classificador deve ter'),
    ('seed_ia_medio_v3', 'Por que precisão (precision) e recall podem ser importantes?', 3, 'Medem apenas o tamanho do modelo', 'Permitem calcular o espaço que um classificador ocupa na memória do servidor'),
    ('seed_ia_medio_v3', 'Em um sistema de detecção de doenças, deixar passar muitos casos positivos pode ser especialmente preocupante. Qual métrica pode receber atenção especial?', 1, 'Latência da rede', 'Perda'),
    ('seed_ia_medio_v3', 'Em um sistema de detecção de doenças, deixar passar muitos casos positivos pode ser especialmente preocupante. Qual métrica pode receber atenção especial?', 2, 'Tamanho do arquivo', 'Precisão'),
    ('seed_ia_medio_v3', 'Em um sistema de detecção de doenças, deixar passar muitos casos positivos pode ser especialmente preocupante. Qual métrica pode receber atenção especial?', 3, 'Número de parâmetros', 'Exatidão'),
    ('seed_ia_medio_v3', 'O que significa balancear um conjunto de dados?', 1, 'Tornar todos os arquivos do mesmo tamanho', 'Garantir que o conjunto de dados cabe por inteiro na memória do computador usado'),
    ('seed_ia_medio_v3', 'O que significa balancear um conjunto de dados?', 2, 'Remover todas as classes minoritárias', 'Remover as classes minoritárias para o modelo aprender mais depressa com menos dados'),
    ('seed_ia_medio_v3', 'O que significa balancear um conjunto de dados?', 3, 'Duplicar obrigatoriamente todos os dados', 'Duplicar os exemplos existentes para aumentar o tamanho do conjunto de dados inteiro'),
    ('seed_ia_medio_v3', 'Por que classes muito desequilibradas podem dificultar o treinamento?', 0, 'A memória RAM aumenta automaticamente', 'O modelo pode favorecer a classe minoritária e apresentar desempenho fraco nas majoritárias'),
    ('seed_ia_medio_v3', 'Por que classes muito desequilibradas podem dificultar o treinamento?', 2, 'O conjunto deixa de conter dados', 'O modelo pode demorar mais tempo a ler os dados e por isso apresentar resultados piores'),
    ('seed_ia_medio_v3', 'Por que classes muito desequilibradas podem dificultar o treinamento?', 3, 'O modelo deixa de possuir algoritmo', 'O modelo pode trocar os rótulos das classes e apresentar o mesmo erro em cada uma'),
    ('seed_ia_medio_v3', 'O que é normalização de dados?', 0, 'Converter imagens em vídeos', 'Transformar valores numéricos em texto para serem lidos pelas pessoas'),
    ('seed_ia_medio_v3', 'O que é normalização de dados?', 1, 'Eliminar todos os valores', 'Eliminar valores repetidos para que cada exemplo apareça uma única vez'),
    ('seed_ia_medio_v3', 'O que é normalização de dados?', 3, 'Remover o algoritmo', 'Remover valores extremos para que o modelo aprenda só com casos típicos'),
    ('seed_ia_medio_v3', 'Por que a normalização pode ajudar determinados modelos?', 0, 'Elimina a necessidade de treinamento', 'Pode facilitar a leitura dos dados pelas pessoas quando os valores têm muitas casas decimais'),
    ('seed_ia_medio_v3', 'Por que a normalização pode ajudar determinados modelos?', 1, 'Garante previsões perfeitas', 'Pode reduzir o espaço ocupado no disco quando as características são guardadas em ficheiros'),
    ('seed_ia_medio_v3', 'Por que a normalização pode ajudar determinados modelos?', 2, 'Aumenta automaticamente o conjunto de dados', 'Pode aumentar o número de exemplos quando as características possuem poucos valores diferentes'),
    ('seed_ia_medio_v3', 'O que é engenharia de características (feature engineering)?', 0, 'Construção física de computadores', 'Processo de escolher e configurar o hardware mais adequado para treinar um modelo'),
    ('seed_ia_medio_v3', 'O que é engenharia de características (feature engineering)?', 1, 'Instalação de servidores', 'Processo de instalar e configurar os servidores onde um modelo vai funcionar'),
    ('seed_ia_medio_v3', 'O que é engenharia de características (feature engineering)?', 3, 'Criação de senhas', 'Processo de proteger as características do modelo contra acessos não autorizados')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas IA médio lote 3: % alternativa(s) errada(s) atualizada(s) (esperado: 73).', v_updated;
END $$;
