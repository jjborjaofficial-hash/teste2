-- Alternativas (BE-003, regularização) — IA difícil lote 5: 25 perguntas ativas de IA difícil (seed_ia_dificil_v2, as 25 seguintes por ordem de inserção) ainda sem explicação.
-- Segue docs/quiz-v2-alternativas-padrao.md e a regra do dono (2026-10-07): a resposta CERTA NÃO muda; só o texto das
-- alternativas ERRADAS é ajustado (tamanho e forma parecidos com os da certa, distratores plausíveis, sem absolutos só nas erradas).
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
    ('seed_ia_dificil_v2', 'O que é uma época (epoch) no treinamento de IA?', 1, 'Tipo de algoritmo', 'Uma passagem de um único exemplo do conjunto de dados pelo modelo'),
    ('seed_ia_dificil_v2', 'O que é uma época (epoch) no treinamento de IA?', 2, 'Tempo de desligamento do computador', 'Uma atualização dos pesos do modelo depois de cada lote de exemplos'),
    ('seed_ia_dificil_v2', 'O que é uma época (epoch) no treinamento de IA?', 3, 'Quantidade de usuários', 'Uma avaliação final do modelo com dados de teste que ficaram separados do treino'),
    ('seed_ia_dificil_v2', 'O que é precisão (precision) em classificação?', 0, 'Velocidade do algoritmo', 'Proporção de casos positivos reais encontrados entre todos os casos positivos reais'),
    ('seed_ia_dificil_v2', 'O que é precisão (precision) em classificação?', 1, 'Total de dados usados', 'Proporção de previsões corretas, positivas ou negativas, entre todas as previsões'),
    ('seed_ia_dificil_v2', 'O que é precisão (precision) em classificação?', 2, 'Quantidade de erros', 'Proporção de erros do modelo entre todas as previsões positivas'),
    ('seed_ia_dificil_v2', 'O que é função de ativação em uma rede neural?', 0, 'Sistema operacional', 'Função que mede o erro da saída de um neurônio e permite o ajuste automático dos pesos da rede'),
    ('seed_ia_dificil_v2', 'O que é função de ativação em uma rede neural?', 1, 'Programa de instalação', 'Função que define o número de neurônios e permite escolher camadas da rede'),
    ('seed_ia_dificil_v2', 'O que é função de ativação em uma rede neural?', 3, 'Banco de dados', 'Função que guarda a saída de um neurônio e permite recuperar padrões antigos'),
    ('seed_ia_dificil_v2', 'O que caracteriza uma rede neural artificial?', 0, 'Linguagem de programação', 'Modelo estatístico inspirado no funcionamento dos mercados financeiros'),
    ('seed_ia_dificil_v2', 'O que caracteriza uma rede neural artificial?', 1, 'Sistema operacional', 'Modelo computacional inspirado na organização das bases de dados relacionais'),
    ('seed_ia_dificil_v2', 'O que caracteriza uma rede neural artificial?', 3, 'Banco de dados tradicional', 'Modelo matemático inspirado no funcionamento das árvores de decisão'),
    ('seed_ia_dificil_v2', 'O que são modelos de linguagem grandes (LLMs)?', 0, 'Sistemas sem dados', 'Modelos treinados com grandes volumes de imagens para reconhecer e gerar objetos reais'),
    ('seed_ia_dificil_v2', 'O que são modelos de linguagem grandes (LLMs)?', 1, 'Programas apenas de edição', 'Modelos treinados com poucos exemplos de texto para corrigir e traduzir palavras'),
    ('seed_ia_dificil_v2', 'O que são modelos de linguagem grandes (LLMs)?', 3, 'Sistemas operacionais', 'Modelos treinados com grandes volumes de áudio para transcrever e sintetizar voz'),
    ('seed_ia_dificil_v2', 'O que é segurança em IA?', 0, 'Remoção de algoritmos', 'Monitorização dos custos dos modelos e sistemas durante a produção'),
    ('seed_ia_dificil_v2', 'O que é segurança em IA?', 2, 'Criação de vírus', 'Otimização dos modelos e sistemas para consumirem menos energia'),
    ('seed_ia_dificil_v2', 'O que é segurança em IA?', 3, 'Redução de dados', 'Verificação dos resultados dos modelos e sistemas contra erros de cálculo'),
    ('seed_ia_dificil_v2', 'O que significa GPT em modelos de IA?', 1, 'Generated Personal Text', 'Generative Probabilistic Translator'),
    ('seed_ia_dificil_v2', 'O que significa GPT em modelos de IA?', 2, 'Global Program Tool', 'General Pre-trained Transformer'),
    ('seed_ia_dificil_v2', 'O que significa GPT em modelos de IA?', 3, 'General Processing Technology', 'Generative Processing Transformer'),
    ('seed_ia_dificil_v2', 'Qual é a vantagem do RAG?', 0, 'Elimina todos os dados', 'Permite respostas mais rápidas e baseadas em treino adicional do modelo'),
    ('seed_ia_dificil_v2', 'Qual é a vantagem do RAG?', 1, 'Reduz capacidade da IA', 'Permite respostas mais criativas e baseadas em temperaturas mais altas'),
    ('seed_ia_dificil_v2', 'Qual é a vantagem do RAG?', 2, 'Impede treinamento', 'Permite respostas mais curtas e baseadas em regras fixas'),
    ('seed_ia_dificil_v2', 'O que é validação cruzada?', 0, 'Processo de compra', 'Técnica para aumentar o desempenho de um modelo repetindo o treino com os mesmos dados'),
    ('seed_ia_dificil_v2', 'O que é validação cruzada?', 1, 'Sistema de segurança física', 'Técnica para comparar o desempenho de dois modelos usando o mesmo conjunto de teste'),
    ('seed_ia_dificil_v2', 'O que é validação cruzada?', 2, 'Método de apagar informações', 'Técnica para reduzir o tamanho de um modelo usando diferentes níveis de precisão'),
    ('seed_ia_dificil_v2', 'O que é regularização em Machine Learning?', 0, 'Aumento automático dos dados', 'Técnica usada para aumentar overfitting e melhorar a velocidade do modelo'),
    ('seed_ia_dificil_v2', 'O que é regularização em Machine Learning?', 2, 'Processo para aumentar erros', 'Técnica usada para reduzir o tamanho dos dados e melhorar a leitura do modelo'),
    ('seed_ia_dificil_v2', 'O que é regularização em Machine Learning?', 3, 'Exclusão do treinamento', 'Técnica usada para acelerar o treinamento e melhorar a memória do modelo'),
    ('seed_ia_dificil_v2', 'O que diferencia RPA tradicional de IA?', 1, 'RPA sempre aprende sozinho', 'RPA permite decisões mais complexas baseadas em aprendizagem automática'),
    ('seed_ia_dificil_v2', 'O que diferencia RPA tradicional de IA?', 2, 'Não existe diferença', 'IA executa tarefas mais simples baseadas em regras fixas'),
    ('seed_ia_dificil_v2', 'O que diferencia RPA tradicional de IA?', 3, 'IA não usa dados', 'IA permite tarefas mais repetitivas baseadas em scripts'),
    ('seed_ia_dificil_v2', 'O que acontece quando o learning rate é muito alto?', 1, 'O modelo sempre fica perfeito', 'O modelo pode demorar muito mais tempo a aprender e acabar por usar mais memória'),
    ('seed_ia_dificil_v2', 'O que acontece quando o learning rate é muito alto?', 2, 'Os dados são apagados', 'O modelo pode perder os dados de treino e aprender de forma incorreta'),
    ('seed_ia_dificil_v2', 'O que acontece quando o learning rate é muito alto?', 3, 'O treinamento nunca acontece', 'O modelo pode aprender devagar e ficar preso numa solução pior'),
    ('seed_ia_dificil_v2', 'O que é memória de longo prazo em redes LSTM?', 0, 'Exclusão de dados antigos', 'Capacidade de apagar informações irrelevantes durante sequências longas'),
    ('seed_ia_dificil_v2', 'O que é memória de longo prazo em redes LSTM?', 1, 'Redução de velocidade', 'Capacidade de reduzir o tamanho das informações durante sequências longas'),
    ('seed_ia_dificil_v2', 'O que é memória de longo prazo em redes LSTM?', 2, 'Armazenamento físico do computador', 'Capacidade de guardar informações importantes no disco durante o treino'),
    ('seed_ia_dificil_v2', 'O que mede a acurácia de um modelo?', 0, 'Velocidade do computador', 'Percentual de casos positivos encontrados pelo modelo'),
    ('seed_ia_dificil_v2', 'O que mede a acurácia de um modelo?', 1, 'Quantidade de dados armazenados', 'Percentual de dados usados no treino do modelo'),
    ('seed_ia_dificil_v2', 'O que mede a acurácia de um modelo?', 2, 'Número de usuários', 'Percentual de previsões feitas em tempo real pelo modelo'),
    ('seed_ia_dificil_v2', 'Qual é a principal vantagem do Transfer Learning?', 0, 'Remover a necessidade de dados', 'Reduzir tempo e custo de armazenamento necessários para guardar novos modelos'),
    ('seed_ia_dificil_v2', 'Qual é a principal vantagem do Transfer Learning?', 2, 'Eliminar todos os erros da IA', 'Reduzir erros e camadas necessárias para treinar modelos'),
    ('seed_ia_dificil_v2', 'Qual é a principal vantagem do Transfer Learning?', 3, 'Substituir todos os programadores', 'Reduzir tempo e número de programadores necessários para avaliar novos modelos'),
    ('seed_ia_dificil_v2', 'Qual é a função da camada de entrada em uma rede neural?', 0, 'Gerar o resultado final', 'Gerar os dados que serão processados pelo modelo'),
    ('seed_ia_dificil_v2', 'Qual é a função da camada de entrada em uma rede neural?', 1, 'Armazenar arquivos', 'Guardar os pesos que serão ajustados pelo modelo'),
    ('seed_ia_dificil_v2', 'Qual é a função da camada de entrada em uma rede neural?', 3, 'Controlar a internet', 'Controlar o ritmo com que o modelo atualiza os pesos'),
    ('seed_ia_dificil_v2', 'O que é treinamento de um modelo de IA?', 0, 'Instalação de um aplicativo', 'Processo em que o modelo gera respostas usando dados fornecidos'),
    ('seed_ia_dificil_v2', 'O que é treinamento de um modelo de IA?', 2, 'Processo de apagar informações', 'Processo em que o modelo é avaliado usando dados fornecidos'),
    ('seed_ia_dificil_v2', 'O que é treinamento de um modelo de IA?', 3, 'Criação manual de respostas', 'Processo em que o modelo é publicado usando dados fornecidos pelos clientes'),
    ('seed_ia_dificil_v2', 'O que é modelo generativo?', 1, 'Programa de armazenamento', 'Modelo que aprende padrões para classificar dados parecidos com os originais'),
    ('seed_ia_dificil_v2', 'O que é modelo generativo?', 2, 'Modelo que apenas classifica informações', 'Modelo que aprende regras para comprimir dados semelhantes aos originais'),
    ('seed_ia_dificil_v2', 'O que é modelo generativo?', 3, 'Sistema sem parâmetros', 'Modelo que aprende padrões para detetar dados diferentes dos originais'),
    ('seed_ia_dificil_v2', 'O que é reconhecimento facial baseado em IA?', 0, 'Método de armazenamento', 'Tecnologia que identifica ou verifica pessoas através de impressões digitais e de dados biométricos de cada pessoa'),
    ('seed_ia_dificil_v2', 'O que é reconhecimento facial baseado em IA?', 2, 'Editor de imagens', 'Tecnologia que identifica ou corrige defeitos através de filtros de imagem'),
    ('seed_ia_dificil_v2', 'O que é reconhecimento facial baseado em IA?', 3, 'Sistema de impressão', 'Tecnologia que identifica ou localiza objetos através de câmaras de vigilância'),
    ('seed_ia_dificil_v2', 'O que é F1-score?', 0, 'Linguagem de programação', 'Métrica que combina acurácia e velocidade em uma única medida'),
    ('seed_ia_dificil_v2', 'O que é F1-score?', 1, 'Banco de dados', 'Métrica que compara precisão e tempo de treino em duas medidas'),
    ('seed_ia_dificil_v2', 'O que é F1-score?', 3, 'Tipo de rede neural', 'Métrica que combina erro e custo em uma única medida'),
    ('seed_ia_dificil_v2', 'O que é um chatbot inteligente?', 1, 'Banco de dados simples', 'Sistema de respostas fixas que utiliza menus para interagir com usuários'),
    ('seed_ia_dificil_v2', 'O que é um chatbot inteligente?', 2, 'Editor de texto', 'Sistema de edição que utiliza IA para corrigir textos de usuários'),
    ('seed_ia_dificil_v2', 'O que é um chatbot inteligente?', 3, 'Programa sem respostas', 'Sistema de análise que utiliza IA para monitorizar conversas de usuários'),
    ('seed_ia_dificil_v2', 'O que é generalização em IA?', 0, 'Exclusão de dados', 'Capacidade do modelo de funcionar bem nos dados de treino'),
    ('seed_ia_dificil_v2', 'O que é generalização em IA?', 1, 'Capacidade de memorizar apenas exemplos antigos', 'Capacidade do modelo de memorizar bem os exemplos antigos'),
    ('seed_ia_dificil_v2', 'O que é generalização em IA?', 3, 'Redução da velocidade', 'Capacidade do modelo de funcionar bem em menos tempo'),
    ('seed_ia_dificil_v2', 'O que é ataque adversarial em IA?', 0, 'Treinamento normal', 'Técnica que tenta acelerar modelos usando entradas padronizadas'),
    ('seed_ia_dificil_v2', 'O que é ataque adversarial em IA?', 1, 'Armazenamento seguro', 'Técnica que tenta proteger modelos usando entradas criptografadas'),
    ('seed_ia_dificil_v2', 'O que é ataque adversarial em IA?', 3, 'Atualização automática', 'Técnica que tenta melhorar modelos usando entradas adicionais'),
    ('seed_ia_dificil_v2', 'O que é engenharia de prompts?', 1, 'Construção de robôs', 'Técnica de treinar modelos novos para obter melhores respostas em tarefas de IA'),
    ('seed_ia_dificil_v2', 'O que é engenharia de prompts?', 2, 'Criação de redes sociais', 'Técnica de ajustar os pesos internos para obter melhores respostas dos modelos de IA em produção'),
    ('seed_ia_dificil_v2', 'O que é engenharia de prompts?', 3, 'Programação de computadores físicos', 'Técnica de otimizar servidores para obter melhores respostas de modelos de IA'),
    ('seed_ia_dificil_v2', 'O que é tokenização em modelos de linguagem?', 1, 'Exclusão de palavras', 'Processo de eliminar palavras raras dos textos antes do processamento pelo modelo'),
    ('seed_ia_dificil_v2', 'O que é tokenização em modelos de linguagem?', 2, 'Criação de senhas', 'Processo de proteger textos com códigos para armazenamento pelo modelo'),
    ('seed_ia_dificil_v2', 'O que é tokenização em modelos de linguagem?', 3, 'Tradução automática', 'Processo de traduzir textos para outros idiomas para processamento pelo modelo')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas IA difícil lote 5: % alternativa(s) errada(s) atualizada(s) (esperado: 75).', v_updated;
END $$;
