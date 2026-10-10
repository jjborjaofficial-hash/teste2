-- Alternativas (BE-003, regularização) — IA difícil lote 2: 25 perguntas ativas de IA difícil (seed_ia_dificil_v1, as 24 restantes, e a primeira do v2) ainda sem explicação.
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
    ('seed_ia_dificil_v1', 'Qual é uma vantagem do fine-tuning em relação ao treinamento de um modelo do zero?', 0, 'Garante ausência total de erros', 'Pode garantir que o modelo não cometa erros nas tarefas do novo domínio'),
    ('seed_ia_dificil_v1', 'Qual é uma vantagem do fine-tuning em relação ao treinamento de um modelo do zero?', 1, 'Elimina a necessidade de avaliação', 'Pode dispensar a avaliação do modelo porque o pré-treinamento já foi validado'),
    ('seed_ia_dificil_v1', 'Qual é uma vantagem do fine-tuning em relação ao treinamento de um modelo do zero?', 3, 'Não requer nenhum dado', 'Pode funcionar sem dados do novo domínio, usando o modelo já existente'),
    ('seed_ia_dificil_v1', 'O que é beam search?', 0, 'Um método para eliminar tokens desconhecidos', 'Um método de busca que elimina os tokens desconhecidos durante a geração do texto'),
    ('seed_ia_dificil_v1', 'O que é beam search?', 2, 'Um algoritmo de compressão de modelos', 'Um método de compressão que reduz o número de sequências guardadas pelo modelo'),
    ('seed_ia_dificil_v1', 'O que é beam search?', 3, 'Uma técnica exclusiva de treinamento de imagens', 'Uma técnica de treinamento que mantém várias versões do modelo durante o ajuste'),
    ('seed_ia_dificil_v1', 'O que é alinhamento de modelos de IA?', 1, 'Processo de aumentar somente o número de parâmetros', 'Processo de ajustar o número de parâmetros do modelo ao tamanho dos dados de treino disponíveis para cada tarefa'),
    ('seed_ia_dificil_v1', 'O que é alinhamento de modelos de IA?', 2, 'Processo de reduzir a resolução das entradas', 'Processo de organizar os dados de entrada para que tenham a mesma resolução, formato e escala'),
    ('seed_ia_dificil_v1', 'O que é alinhamento de modelos de IA?', 3, 'Processo de remover o treinamento', 'Processo de reduzir o treinamento do modelo para que ele consuma menos energia, tempo e memória'),
    ('seed_ia_dificil_v1', 'O que é SHAP em explicabilidade de modelos?', 1, 'Uma arquitetura de Transformer', 'Uma arquitetura de Transformer baseada em atenção para estimar a próxima palavra de uma frase em tarefas de tradução'),
    ('seed_ia_dificil_v1', 'O que é SHAP em explicabilidade de modelos?', 2, 'Um método de compressão de áudio', 'Um método de compressão de áudio baseado em transformadas para reduzir o tamanho dos ficheiros de som e de voz'),
    ('seed_ia_dificil_v1', 'O que é SHAP em explicabilidade de modelos?', 3, 'Um algoritmo exclusivo de tokenização', 'Um algoritmo de tokenização baseado em frequências para dividir o texto em unidades menores'),
    ('seed_ia_dificil_v1', 'O que tende a acontecer quando a temperatura de amostragem de um modelo de linguagem é aumentada?', 0, 'A geração tende a ficar mais determinística', 'A geração tende a repetir as mesmas sequências com maior frequência'),
    ('seed_ia_dificil_v1', 'O que tende a acontecer quando a temperatura de amostragem de um modelo de linguagem é aumentada?', 1, 'A distribuição tende a ficar mais concentrada', 'A distribuição tende a ficar mais concentrada nos tokens mais prováveis'),
    ('seed_ia_dificil_v1', 'O que tende a acontecer quando a temperatura de amostragem de um modelo de linguagem é aumentada?', 3, 'O modelo deixa de utilizar probabilidades', 'O modelo tende a escolher o token seguinte pela ordem do vocabulário'),
    ('seed_ia_dificil_v1', 'Em deep learning, o que significa overfitting?', 0, 'O modelo apresenta desempenho ruim tanto no treino quanto no teste', 'O modelo apresenta desempenho ruim tanto no treino quanto no teste por falta de capacidade para aprender'),
    ('seed_ia_dificil_v1', 'Em deep learning, o que significa overfitting?', 1, 'O modelo aprende sem utilizar dados', 'O modelo aprende sem dados de validação e perde a capacidade de ajustar os pesos'),
    ('seed_ia_dificil_v1', 'Em deep learning, o que significa overfitting?', 3, 'O modelo não possui parâmetros', 'O modelo possui poucos parâmetros e por isso não consegue representar padrões complexos'),
    ('seed_ia_dificil_v1', 'Qual técnica pode ajudar a reduzir overfitting?', 0, 'Remover completamente a validação', 'Padding'),
    ('seed_ia_dificil_v1', 'Qual técnica pode ajudar a reduzir overfitting?', 2, 'Aumentar indefinidamente os parâmetros sem alterar os dados', 'Softmax'),
    ('seed_ia_dificil_v1', 'Qual técnica pode ajudar a reduzir overfitting?', 3, 'Treinar apenas uma vez', 'Tokenização'),
    ('seed_ia_dificil_v1', 'Em modelos generativos, o que significa "temperatura" na geração de texto?', 0, 'Controlar a velocidade física do computador', 'Controlar a velocidade de processamento do modelo durante a geração dos tokens'),
    ('seed_ia_dificil_v1', 'Em modelos generativos, o que significa "temperatura" na geração de texto?', 2, 'Alterar a temperatura do processador', 'Limitar a quantidade de tokens que o modelo pode gerar em cada resposta'),
    ('seed_ia_dificil_v1', 'Em modelos generativos, o que significa "temperatura" na geração de texto?', 3, 'Determinar o tamanho máximo do vocabulário', 'Determinar o tamanho do vocabulário usado pelo modelo na distribuição de tokens'),
    ('seed_ia_dificil_v1', 'Em processamento de linguagem natural, o que é tokenização?', 0, 'Exclusão de todas as palavras raras', 'Exclusão das palavras raras do texto antes do treino do modelo'),
    ('seed_ia_dificil_v1', 'Em processamento de linguagem natural, o que é tokenização?', 1, 'Tradução automática para outro idioma', 'Tradução automática do texto para um idioma que o modelo conhece'),
    ('seed_ia_dificil_v1', 'Em processamento de linguagem natural, o que é tokenização?', 2, 'Compressão física do arquivo', 'Compressão do ficheiro de texto para ocupar menos espaço em disco'),
    ('seed_ia_dificil_v1', 'O que é um vetor de similaridade semântica?', 0, 'Um conjunto de parâmetros exclusivamente visuais', 'Um conjunto de parâmetros visuais usado para comparar a semelhança de cor entre imagens'),
    ('seed_ia_dificil_v1', 'O que é um vetor de similaridade semântica?', 1, 'Um tipo de função de ativação', 'Um tipo de função de ativação usado para limitar a saída dos neurónios entre dois valores'),
    ('seed_ia_dificil_v1', 'O que é um vetor de similaridade semântica?', 3, 'Uma lista de palavras proibidas', 'Uma lista de palavras bloqueadas usada para filtrar o conteúdo gerado pelo modelo'),
    ('seed_ia_dificil_v1', 'Qual problema o mecanismo de atenção multi-head procura resolver em Transformers?', 0, 'Reduzir o número de parâmetros para zero', 'Reduzir o número de parâmetros do modelo para acelerar o treinamento em larga escala'),
    ('seed_ia_dificil_v1', 'Qual problema o mecanismo de atenção multi-head procura resolver em Transformers?', 1, 'Impedir o uso de contexto', 'Impedir que o modelo use contexto distante ao processar uma frase longa'),
    ('seed_ia_dificil_v1', 'Qual problema o mecanismo de atenção multi-head procura resolver em Transformers?', 2, 'Eliminar o treinamento supervisionado', 'Dispensar o treinamento supervisionado ao dividir o modelo em várias partes menores'),
    ('seed_ia_dificil_v1', 'Qual é uma vantagem importante do RAG?', 0, 'Garantir que qualquer informação recuperada seja verdadeira', 'Garantir que as informações recuperadas das fontes externas sejam verdadeiras e estejam atualizadas no momento da consulta'),
    ('seed_ia_dificil_v1', 'Qual é uma vantagem importante do RAG?', 1, 'Impedir atualizações da base de conhecimento', 'Impedir que a base de conhecimento seja atualizada depois do treinamento do modelo de linguagem usado pelo sistema'),
    ('seed_ia_dificil_v1', 'Qual é uma vantagem importante do RAG?', 2, 'Eliminar completamente a necessidade de avaliação', 'Dispensar a avaliação do sistema porque as respostas passam a vir de documentos confiáveis escolhidos pela equipa'),
    ('seed_ia_dificil_v1', 'O que é RLHF?', 0, 'Um método de compressão de imagens', 'Aprendizado supervisionado a partir de rótulos humanos'),
    ('seed_ia_dificil_v1', 'Em um Transformer, qual é a principal função do mecanismo de self-attention?', 1, 'Converter texto diretamente em imagens', 'Converter cada token num vetor de tamanho fixo antes de entrar nas camadas'),
    ('seed_ia_dificil_v1', 'Em um Transformer, qual é a principal função do mecanismo de self-attention?', 2, 'Reduzir o tamanho do vocabulário', 'Reduzir o tamanho do vocabulário agrupando tokens que aparecem com pouca frequência'),
    ('seed_ia_dificil_v1', 'Em um Transformer, qual é a principal função do mecanismo de self-attention?', 3, 'Eliminar completamente a necessidade de embeddings', 'Calcular a perda do modelo comparando a previsão com o token correto de cada posição'),
    ('seed_ia_dificil_v1', 'O que significa interpretabilidade em IA?', 0, 'Capacidade de aumentar o número de parâmetros', 'Capacidade de aumentar o número de parâmetros do modelo sem perder desempenho nas tarefas já treinadas'),
    ('seed_ia_dificil_v1', 'O que significa interpretabilidade em IA?', 1, 'Capacidade de executar sem dados', 'Capacidade de executar o modelo em equipamentos que não têm acesso aos dados de treino originais'),
    ('seed_ia_dificil_v1', 'O que significa interpretabilidade em IA?', 2, 'Capacidade de gerar respostas mais longas', 'Capacidade de gerar respostas mais longas e mais detalhadas a partir de instruções curtas'),
    ('seed_ia_dificil_v1', 'O que é distribuição de dados em machine learning?', 0, 'A quantidade de memória RAM disponível', 'A quantidade de memória usada para armazenar os exemplos de treino do modelo'),
    ('seed_ia_dificil_v1', 'O que é distribuição de dados em machine learning?', 1, 'O número de camadas de uma rede', 'O número de camadas e de neurónios usados para ajustar o modelo aos exemplos'),
    ('seed_ia_dificil_v1', 'O que é distribuição de dados em machine learning?', 2, 'A velocidade da conexão', 'A velocidade com que os exemplos são lidos do disco durante cada época'),
    ('seed_ia_dificil_v1', 'Por que data leakage pode produzir uma avaliação enganosa?', 0, 'Porque elimina todos os dados de teste', 'Porque pode eliminar os dados de teste e impedir que o desempenho seja medido com rigor'),
    ('seed_ia_dificil_v1', 'Por que data leakage pode produzir uma avaliação enganosa?', 1, 'Porque impede o treinamento', 'Porque pode impedir o treinamento e fazer o modelo parecer menos preciso do que realmente é'),
    ('seed_ia_dificil_v1', 'Por que data leakage pode produzir uma avaliação enganosa?', 2, 'Porque sempre reduz a precisão', 'Porque pode reduzir a precisão medida e esconder os verdadeiros pontos fortes do modelo em dados novos'),
    ('seed_ia_dificil_v1', 'Qual é a função principal da regularização L2?', 0, 'Remover todas as camadas ocultas', 'Aumentar a taxa de aprendizagem'),
    ('seed_ia_dificil_v1', 'Qual é a função principal da regularização L2?', 1, 'Eliminar a função de ativação', 'Eliminar a função de ativação'),
    ('seed_ia_dificil_v1', 'Qual é a função principal da regularização L2?', 2, 'Aumentar automaticamente o tamanho do dataset', 'Gerar novos exemplos de treino'),
    ('seed_ia_dificil_v1', 'O que é atenção causal em um modelo autoregressivo?', 0, 'Permitir que cada token veja todos os tokens futuros', 'Permitir que cada token utilize informações de todas as posições futuras durante a previsão'),
    ('seed_ia_dificil_v1', 'O que é atenção causal em um modelo autoregressivo?', 2, 'Fazer o modelo ignorar o token atual', 'Fazer o modelo ignorar o token atual ao calcular a previsão da posição seguinte'),
    ('seed_ia_dificil_v1', 'O que é atenção causal em um modelo autoregressivo?', 3, 'Remover completamente o contexto anterior', 'Remover o contexto anterior para que cada token seja previsto de forma independente'),
    ('seed_ia_dificil_v1', 'Em LLMs, o que é perplexidade?', 1, 'O número de camadas do modelo', 'Uma medida relacionada ao número de camadas que o modelo utiliza em cada sequência'),
    ('seed_ia_dificil_v1', 'Em LLMs, o que é perplexidade?', 2, 'A quantidade de GPUs utilizadas', 'Uma medida relacionada à quantidade de GPUs necessárias para treinar o modelo'),
    ('seed_ia_dificil_v1', 'Em LLMs, o que é perplexidade?', 3, 'O tamanho físico do arquivo do modelo', 'Uma medida relacionada ao tamanho do arquivo do modelo depois de guardado em disco'),
    ('seed_ia_dificil_v1', 'O que é hallucination em modelos generativos?', 0, 'Quando o modelo deixa de utilizar GPU', 'Quando o modelo deixa de utilizar a GPU durante a geração, mas continua a responder'),
    ('seed_ia_dificil_v1', 'O que é hallucination em modelos generativos?', 1, 'Quando o banco de dados fica indisponível', 'Quando o banco de dados fica indisponível, mas o modelo continua a funcionar'),
    ('seed_ia_dificil_v1', 'O que é hallucination em modelos generativos?', 2, 'Quando o modelo não possui tokens', 'Quando o modelo não possui tokens suficientes, mas tenta completar a resposta'),
    ('seed_ia_dificil_v1', 'Qual técnica é frequentemente utilizada para reduzir o problema do vanishing gradient em redes profundas?', 0, 'Redução do conjunto de treinamento a uma única amostra', 'Uso de conjuntos de treino menores'),
    ('seed_ia_dificil_v1', 'O que caracteriza uma métrica de avaliação inadequada para um problema de IA?', 0, 'Uma métrica calculada sobre dados', 'Uma métrica calculada sobre dados de teste separados dos dados de treino'),
    ('seed_ia_dificil_v1', 'O que caracteriza uma métrica de avaliação inadequada para um problema de IA?', 2, 'Uma métrica que pode ser comparada entre modelos', 'Uma métrica que pode ser comparada entre vários modelos treinados no mesmo problema'),
    ('seed_ia_dificil_v1', 'O que caracteriza uma métrica de avaliação inadequada para um problema de IA?', 3, 'Uma métrica usada durante testes', 'Uma métrica usada durante os testes antes da publicação do modelo em produção'),
    ('seed_ia_dificil_v1', 'Em IA generativa, o que é um modelo multimodal?', 1, 'Um modelo treinado apenas com números', 'Um modelo treinado com dados numéricos, como séries temporais, tabelas ou leituras de sensores industriais'),
    ('seed_ia_dificil_v1', 'Em IA generativa, o que é um modelo multimodal?', 2, 'Um modelo que possui necessariamente várias GPUs', 'Um modelo executado em várias GPUs, como acontece com os maiores modelos de linguagem'),
    ('seed_ia_dificil_v1', 'Em IA generativa, o que é um modelo multimodal?', 3, 'Um modelo que só pode produzir texto', 'Um modelo que recebe vários textos ao mesmo tempo, como perguntas, respostas ou documentos'),
    ('seed_ia_dificil_v2', 'O que é Edge AI?', 1, 'Uso exclusivo da nuvem', 'Processamento de IA realizado em grandes centros de dados distantes dos utilizadores'),
    ('seed_ia_dificil_v2', 'O que é Edge AI?', 2, 'Sistema sem internet', 'Processamento de IA realizado depois de os dados serem arquivados em servidores'),
    ('seed_ia_dificil_v2', 'O que é Edge AI?', 3, 'Armazenamento manual', 'Armazenamento de dados feito por pessoas antes de entrarem no modelo')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas IA difícil lote 2: % alternativa(s) errada(s) atualizada(s) (esperado: 71).', v_updated;
END $$;
