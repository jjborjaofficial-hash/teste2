-- Migration/seed: conteúdo Inteligência Artificial, nível Difícil — lote 1 (49 de 50 perguntas)
-- Fonte: lote de 50 perguntas avançadas de IA (Transformers, deep learning,
-- RAG, RLHF, avaliação de modelos) fornecido pelo proprietário do projeto.
-- Este é o PRIMEIRO conteúdo de Inteligência Artificial Difícil — a
-- categoria estava zerada até este arquivo.
--
-- NOTA: o lote foi enviado duas vezes no mesmo envio (dois documentos
-- idênticos, palavra por palavra). Tratei como um único lote de 50
-- perguntas, não 100 — a segunda cópia foi ignorada.
--
-- DEDUPLICAÇÃO APLICADA: "O que é fine-tuning?" já existia no banco (em
-- Inteligência Artificial Médio) e foi removida deste arquivo. Sobraram 49
-- perguntas novas e únicas.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes
-- anteriores): este lote já vem com respostas parcialmente variadas (39 A,
-- 10 B, 1 C). Para manter consistência com o resto do banco, a posição da
-- alternativa correta (preservando o texto correto do documento original)
-- foi redistribuída por pergunta com seed fixa (88 — distinta das seeds 42
-- a 87 já usadas) e distribuição controlada entre A/B/C/D. Conteúdo
-- pedagógico inalterado, só a ORDEM de exibição mudou.
--
-- Idempotente: usa a coluna `source` (migration 022) como marcador — rodar
-- este arquivo mais de uma vez não duplica as perguntas.

BEGIN;

DO $$
DECLARE
  v_category_id UUID;
BEGIN
  SELECT id INTO v_category_id FROM categories WHERE slug = 'inteligencia-artificial';
  IF v_category_id IS NULL THEN
    RAISE EXCEPTION 'Categoria "inteligencia-artificial" não encontrada — rode a migration 021 primeiro.';
  END IF;

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_ia_dificil_v1') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_ia_dificil_v1) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_ia_dificil_v1 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'hard', v.statement, 15, 10, 'seed_ia_dificil_v1'
    FROM (VALUES
      ('Em um Transformer, qual é a principal função do mecanismo de self-attention?'),
      ('Qual problema o mecanismo de atenção multi-head procura resolver em Transformers?'),
      ('Em redes neurais profundas, o que caracteriza o problema do vanishing gradient?'),
      ('Qual técnica é frequentemente utilizada para reduzir o problema do vanishing gradient em redes profundas?'),
      ('O que diferencia aprendizado supervisionado de aprendizado não supervisionado?'),
      ('Em aprendizado por reforço, o que representa a função de valor?'),
      ('O que é exploração no contexto de aprendizado por reforço?'),
      ('Qual é o principal objetivo do algoritmo Q-learning?'),
      ('Em deep learning, o que significa overfitting?'),
      ('Qual técnica pode ajudar a reduzir overfitting?'),
      ('Qual é a função principal da regularização L2?'),
      ('Em modelos generativos, o que significa "temperatura" na geração de texto?'),
      ('O que tende a acontecer quando a temperatura de amostragem de um modelo de linguagem é aumentada?'),
      ('O que é beam search?'),
      ('Qual é uma limitação importante do beam search em geração de texto?'),
      ('Em processamento de linguagem natural, o que é tokenização?'),
      ('Por que modelos modernos utilizam embeddings?'),
      ('O que caracteriza um embedding contextual?'),
      ('Em um Transformer, por que são necessárias informações posicionais?'),
      ('O que é atenção causal em um modelo autoregressivo?'),
      ('Qual é uma vantagem do fine-tuning em relação ao treinamento de um modelo do zero?'),
      ('O que é transfer learning?'),
      ('O que caracteriza aprendizado auto-supervisionado?'),
      ('Em LLMs, o que é perplexidade?'),
      ('Uma perplexidade menor geralmente indica:'),
      ('O que é quantização de um modelo de IA?'),
      ('Qual é uma possível vantagem da quantização?'),
      ('O que é knowledge distillation?'),
      ('Em IA generativa, o que é um modelo multimodal?'),
      ('O que é RAG (Retrieval-Augmented Generation)?'),
      ('Qual é uma vantagem importante do RAG?'),
      ('Em um sistema RAG, qual é a função do retriever?'),
      ('O que é um vetor de similaridade semântica?'),
      ('Por que bancos de dados vetoriais são utilizados em sistemas RAG?'),
      ('O que é hallucination em modelos generativos?'),
      ('Qual estratégia pode ajudar a reduzir alucinações em sistemas de IA?'),
      ('O que é alinhamento de modelos de IA?'),
      ('O que é RLHF?'),
      ('Qual é uma finalidade do RLHF?'),
      ('O que é data leakage em aprendizado de máquina?'),
      ('Por que data leakage pode produzir uma avaliação enganosa?'),
      ('O que é distribuição de dados em machine learning?'),
      ('O que é concept drift?'),
      ('Por que concept drift é relevante em sistemas de IA em produção?'),
      ('O que significa interpretabilidade em IA?'),
      ('O que é SHAP em explicabilidade de modelos?'),
      ('O que caracteriza uma métrica de avaliação inadequada para um problema de IA?'),
      ('Em classificação altamente desbalanceada, por que a acurácia pode ser enganosa?'),
      ('Qual é uma razão importante para avaliar um sistema de IA além da precisão?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_ia_dificil_v1 q
    JOIN (VALUES
      ('Em um Transformer, qual é a principal função do mecanismo de self-attention?', 'Determinar quais tokens devem receber maior atenção considerando o contexto', TRUE, 0),
      ('Em um Transformer, qual é a principal função do mecanismo de self-attention?', 'Converter texto diretamente em imagens', FALSE, 1),
      ('Em um Transformer, qual é a principal função do mecanismo de self-attention?', 'Reduzir o tamanho do vocabulário', FALSE, 2),
      ('Em um Transformer, qual é a principal função do mecanismo de self-attention?', 'Eliminar completamente a necessidade de embeddings', FALSE, 3),
      ('Qual problema o mecanismo de atenção multi-head procura resolver em Transformers?', 'Reduzir o número de parâmetros para zero', FALSE, 0),
      ('Qual problema o mecanismo de atenção multi-head procura resolver em Transformers?', 'Impedir o uso de contexto', FALSE, 1),
      ('Qual problema o mecanismo de atenção multi-head procura resolver em Transformers?', 'Eliminar o treinamento supervisionado', FALSE, 2),
      ('Qual problema o mecanismo de atenção multi-head procura resolver em Transformers?', 'Permitir que o modelo considere diferentes relações entre tokens simultaneamente', TRUE, 3),
      ('Em redes neurais profundas, o que caracteriza o problema do vanishing gradient?', 'Os gradientes tornam-se extremamente grandes durante a retropropagação', FALSE, 0),
      ('Em redes neurais profundas, o que caracteriza o problema do vanishing gradient?', 'Os gradientes tornam-se muito pequenos, dificultando a atualização das primeiras camadas', TRUE, 1),
      ('Em redes neurais profundas, o que caracteriza o problema do vanishing gradient?', 'Os dados de treinamento desaparecem', FALSE, 2),
      ('Em redes neurais profundas, o que caracteriza o problema do vanishing gradient?', 'O modelo deixa de possuir função de perda', FALSE, 3),
      ('Qual técnica é frequentemente utilizada para reduzir o problema do vanishing gradient em redes profundas?', 'Redução do conjunto de treinamento a uma única amostra', FALSE, 0),
      ('Qual técnica é frequentemente utilizada para reduzir o problema do vanishing gradient em redes profundas?', 'Remoção da função de perda', FALSE, 1),
      ('Qual técnica é frequentemente utilizada para reduzir o problema do vanishing gradient em redes profundas?', 'Funções de ativação como ReLU', TRUE, 2),
      ('Qual técnica é frequentemente utilizada para reduzir o problema do vanishing gradient em redes profundas?', 'Exclusão das camadas iniciais', FALSE, 3),
      ('O que diferencia aprendizado supervisionado de aprendizado não supervisionado?', 'O não supervisionado exige sempre rótulos humanos', FALSE, 0),
      ('O que diferencia aprendizado supervisionado de aprendizado não supervisionado?', 'O supervisionado utiliza dados rotulados para aprender uma relação entre entradas e saídas', TRUE, 1),
      ('O que diferencia aprendizado supervisionado de aprendizado não supervisionado?', 'O não supervisionado só pode ser usado em imagens', FALSE, 2),
      ('O que diferencia aprendizado supervisionado de aprendizado não supervisionado?', 'O supervisionado nunca utiliza redes neurais', FALSE, 3),
      ('Em aprendizado por reforço, o que representa a função de valor?', 'A quantidade de dados disponíveis', FALSE, 0),
      ('Em aprendizado por reforço, o que representa a função de valor?', 'A estimativa do retorno esperado a partir de determinado estado ou estado-ação', TRUE, 1),
      ('Em aprendizado por reforço, o que representa a função de valor?', 'O número total de parâmetros da rede', FALSE, 2),
      ('Em aprendizado por reforço, o que representa a função de valor?', 'A velocidade do processador', FALSE, 3),
      ('O que é exploração no contexto de aprendizado por reforço?', 'Escolher apenas ações já conhecidas como ótimas', FALSE, 0),
      ('O que é exploração no contexto de aprendizado por reforço?', 'Reduzir o espaço de ações para uma única escolha', FALSE, 1),
      ('O que é exploração no contexto de aprendizado por reforço?', 'Experimentar ações para obter informações sobre suas possíveis recompensas', TRUE, 2),
      ('O que é exploração no contexto de aprendizado por reforço?', 'Remover estados do ambiente', FALSE, 3),
      ('Qual é o principal objetivo do algoritmo Q-learning?', 'Reduzir a resolução dos dados', FALSE, 0),
      ('Qual é o principal objetivo do algoritmo Q-learning?', 'Aprender uma função que estima o valor de ações em determinados estados', TRUE, 1),
      ('Qual é o principal objetivo do algoritmo Q-learning?', 'Classificar imagens sem treinamento', FALSE, 2),
      ('Qual é o principal objetivo do algoritmo Q-learning?', 'Gerar embeddings exclusivamente de palavras', FALSE, 3),
      ('Em deep learning, o que significa overfitting?', 'O modelo apresenta desempenho ruim tanto no treino quanto no teste', FALSE, 0),
      ('Em deep learning, o que significa overfitting?', 'O modelo aprende sem utilizar dados', FALSE, 1),
      ('Em deep learning, o que significa overfitting?', 'O modelo aprende excessivamente os padrões específicos do treinamento e generaliza mal', TRUE, 2),
      ('Em deep learning, o que significa overfitting?', 'O modelo não possui parâmetros', FALSE, 3),
      ('Qual técnica pode ajudar a reduzir overfitting?', 'Remover completamente a validação', FALSE, 0),
      ('Qual técnica pode ajudar a reduzir overfitting?', 'Dropout', TRUE, 1),
      ('Qual técnica pode ajudar a reduzir overfitting?', 'Aumentar indefinidamente os parâmetros sem alterar os dados', FALSE, 2),
      ('Qual técnica pode ajudar a reduzir overfitting?', 'Treinar apenas uma vez', FALSE, 3),
      ('Qual é a função principal da regularização L2?', 'Remover todas as camadas ocultas', FALSE, 0),
      ('Qual é a função principal da regularização L2?', 'Eliminar a função de ativação', FALSE, 1),
      ('Qual é a função principal da regularização L2?', 'Aumentar automaticamente o tamanho do dataset', FALSE, 2),
      ('Qual é a função principal da regularização L2?', 'Penalizar pesos excessivamente grandes', TRUE, 3),
      ('Em modelos generativos, o que significa "temperatura" na geração de texto?', 'Controlar a velocidade física do computador', FALSE, 0),
      ('Em modelos generativos, o que significa "temperatura" na geração de texto?', 'Influenciar a aleatoriedade da distribuição de probabilidade dos tokens gerados', TRUE, 1),
      ('Em modelos generativos, o que significa "temperatura" na geração de texto?', 'Alterar a temperatura do processador', FALSE, 2),
      ('Em modelos generativos, o que significa "temperatura" na geração de texto?', 'Determinar o tamanho máximo do vocabulário', FALSE, 3),
      ('O que tende a acontecer quando a temperatura de amostragem de um modelo de linguagem é aumentada?', 'A geração tende a ficar mais determinística', FALSE, 0),
      ('O que tende a acontecer quando a temperatura de amostragem de um modelo de linguagem é aumentada?', 'A distribuição tende a ficar mais concentrada', FALSE, 1),
      ('O que tende a acontecer quando a temperatura de amostragem de um modelo de linguagem é aumentada?', 'A geração tende a apresentar maior diversidade e aleatoriedade', TRUE, 2),
      ('O que tende a acontecer quando a temperatura de amostragem de um modelo de linguagem é aumentada?', 'O modelo deixa de utilizar probabilidades', FALSE, 3),
      ('O que é beam search?', 'Um método para eliminar tokens desconhecidos', FALSE, 0),
      ('O que é beam search?', 'Um método de busca que mantém várias sequências candidatas durante a geração', TRUE, 1),
      ('O que é beam search?', 'Um algoritmo de compressão de modelos', FALSE, 2),
      ('O que é beam search?', 'Uma técnica exclusiva de treinamento de imagens', FALSE, 3),
      ('Qual é uma limitação importante do beam search em geração de texto?', 'Nunca utiliza probabilidades', FALSE, 0),
      ('Qual é uma limitação importante do beam search em geração de texto?', 'Não pode produzir mais de um token', FALSE, 1),
      ('Qual é uma limitação importante do beam search em geração de texto?', 'Só funciona com modelos sem parâmetros', FALSE, 2),
      ('Qual é uma limitação importante do beam search em geração de texto?', 'Pode favorecer sequências de alta probabilidade que não sejam necessariamente as mais naturais', TRUE, 3),
      ('Em processamento de linguagem natural, o que é tokenização?', 'Exclusão de todas as palavras raras', FALSE, 0),
      ('Em processamento de linguagem natural, o que é tokenização?', 'Tradução automática para outro idioma', FALSE, 1),
      ('Em processamento de linguagem natural, o que é tokenização?', 'Compressão física do arquivo', FALSE, 2),
      ('Em processamento de linguagem natural, o que é tokenização?', 'Conversão de texto em unidades que o modelo consegue processar', TRUE, 3),
      ('Por que modelos modernos utilizam embeddings?', 'Para impedir relações semânticas', FALSE, 0),
      ('Por que modelos modernos utilizam embeddings?', 'Para substituir completamente o treinamento', FALSE, 1),
      ('Por que modelos modernos utilizam embeddings?', 'Para representar elementos discretos, como tokens, em espaços vetoriais contínuos', TRUE, 2),
      ('Por que modelos modernos utilizam embeddings?', 'Para remover toda informação contextual', FALSE, 3),
      ('O que caracteriza um embedding contextual?', 'O embedding não utiliza vetores', FALSE, 0),
      ('O que caracteriza um embedding contextual?', 'O embedding contém apenas a frequência da palavra', FALSE, 1),
      ('O que caracteriza um embedding contextual?', 'A representação pode variar de acordo com o contexto em que o token aparece', TRUE, 2),
      ('O que caracteriza um embedding contextual?', 'A representação de um token permanece sempre idêntica independentemente do contexto', FALSE, 3),
      ('Em um Transformer, por que são necessárias informações posicionais?', 'Porque o mecanismo de atenção, isoladamente, não fornece uma noção inerente da ordem dos tokens', TRUE, 0),
      ('Em um Transformer, por que são necessárias informações posicionais?', 'Porque impedem a atenção entre tokens', FALSE, 1),
      ('Em um Transformer, por que são necessárias informações posicionais?', 'Porque eliminam os embeddings', FALSE, 2),
      ('Em um Transformer, por que são necessárias informações posicionais?', 'Porque substituem a função de perda', FALSE, 3),
      ('O que é atenção causal em um modelo autoregressivo?', 'Permitir que cada token veja todos os tokens futuros', FALSE, 0),
      ('O que é atenção causal em um modelo autoregressivo?', 'Impedir que um token utilize informações futuras durante a previsão', TRUE, 1),
      ('O que é atenção causal em um modelo autoregressivo?', 'Fazer o modelo ignorar o token atual', FALSE, 2),
      ('O que é atenção causal em um modelo autoregressivo?', 'Remover completamente o contexto anterior', FALSE, 3),
      ('Qual é uma vantagem do fine-tuning em relação ao treinamento de um modelo do zero?', 'Garante ausência total de erros', FALSE, 0),
      ('Qual é uma vantagem do fine-tuning em relação ao treinamento de um modelo do zero?', 'Elimina a necessidade de avaliação', FALSE, 1),
      ('Qual é uma vantagem do fine-tuning em relação ao treinamento de um modelo do zero?', 'Pode aproveitar representações já aprendidas pelo modelo pré-treinado', TRUE, 2),
      ('Qual é uma vantagem do fine-tuning em relação ao treinamento de um modelo do zero?', 'Não requer nenhum dado', FALSE, 3),
      ('O que é transfer learning?', 'Treinar somente com dados sintéticos', FALSE, 0),
      ('O que é transfer learning?', 'Transferir fisicamente um modelo para outro computador', FALSE, 1),
      ('O que é transfer learning?', 'Copiar arquivos sem modificar pesos', FALSE, 2),
      ('O que é transfer learning?', 'Aproveitar conhecimento aprendido em uma tarefa ou domínio para melhorar o desempenho em outro', TRUE, 3),
      ('O que caracteriza aprendizado auto-supervisionado?', 'O modelo utiliza sinais derivados dos próprios dados para criar objetivos de treinamento', TRUE, 0),
      ('O que caracteriza aprendizado auto-supervisionado?', 'O treinamento depende exclusivamente de rótulos humanos', FALSE, 1),
      ('O que caracteriza aprendizado auto-supervisionado?', 'Não utiliza nenhuma função de perda', FALSE, 2),
      ('O que caracteriza aprendizado auto-supervisionado?', 'Só funciona com dados numéricos', FALSE, 3),
      ('Em LLMs, o que é perplexidade?', 'Uma medida relacionada à capacidade do modelo de prever tokens de uma sequência', TRUE, 0),
      ('Em LLMs, o que é perplexidade?', 'O número de camadas do modelo', FALSE, 1),
      ('Em LLMs, o que é perplexidade?', 'A quantidade de GPUs utilizadas', FALSE, 2),
      ('Em LLMs, o que é perplexidade?', 'O tamanho físico do arquivo do modelo', FALSE, 3),
      ('Uma perplexidade menor geralmente indica:', 'Maior número de parâmetros obrigatoriamente', FALSE, 0),
      ('Uma perplexidade menor geralmente indica:', 'Ausência de treinamento', FALSE, 1),
      ('Uma perplexidade menor geralmente indica:', 'Pior capacidade preditiva em relação à distribuição avaliada', FALSE, 2),
      ('Uma perplexidade menor geralmente indica:', 'Melhor capacidade de previsão dos tokens, sob as mesmas condições de avaliação', TRUE, 3),
      ('O que é quantização de um modelo de IA?', 'Representar parâmetros ou ativações usando menor precisão numérica', TRUE, 0),
      ('O que é quantização de um modelo de IA?', 'Aumentar obrigatoriamente o número de parâmetros', FALSE, 1),
      ('O que é quantização de um modelo de IA?', 'Remover todos os embeddings', FALSE, 2),
      ('O que é quantização de um modelo de IA?', 'Transformar texto em áudio', FALSE, 3),
      ('Qual é uma possível vantagem da quantização?', 'Redução do uso de memória e, em alguns casos, aumento da eficiência de inferência', TRUE, 0),
      ('Qual é uma possível vantagem da quantização?', 'Eliminação completa da necessidade de hardware', FALSE, 1),
      ('Qual é uma possível vantagem da quantização?', 'Aumento obrigatório da qualidade da resposta', FALSE, 2),
      ('Qual é uma possível vantagem da quantização?', 'Garantia de precisão perfeita', FALSE, 3),
      ('O que é knowledge distillation?', 'Treinar um modelo menor para reproduzir ou aproximar o comportamento de um modelo maior', TRUE, 0),
      ('O que é knowledge distillation?', 'Remover as funções de ativação', FALSE, 1),
      ('O que é knowledge distillation?', 'Apagar o conhecimento de um modelo', FALSE, 2),
      ('O que é knowledge distillation?', 'Transformar um modelo supervisionado em banco de dados', FALSE, 3),
      ('Em IA generativa, o que é um modelo multimodal?', 'Um modelo capaz de trabalhar com diferentes modalidades de informação, como texto, imagem ou áudio', TRUE, 0),
      ('Em IA generativa, o que é um modelo multimodal?', 'Um modelo treinado apenas com números', FALSE, 1),
      ('Em IA generativa, o que é um modelo multimodal?', 'Um modelo que possui necessariamente várias GPUs', FALSE, 2),
      ('Em IA generativa, o que é um modelo multimodal?', 'Um modelo que só pode produzir texto', FALSE, 3),
      ('O que é RAG (Retrieval-Augmented Generation)?', 'Uma técnica exclusivamente para classificação de imagens', FALSE, 0),
      ('O que é RAG (Retrieval-Augmented Generation)?', 'Uma abordagem que recupera informações relevantes de fontes externas e as utiliza para auxiliar a geração', TRUE, 1),
      ('O que é RAG (Retrieval-Augmented Generation)?', 'Um método que elimina completamente o contexto', FALSE, 2),
      ('O que é RAG (Retrieval-Augmented Generation)?', 'Um algoritmo que impede o acesso a documentos', FALSE, 3),
      ('Qual é uma vantagem importante do RAG?', 'Garantir que qualquer informação recuperada seja verdadeira', FALSE, 0),
      ('Qual é uma vantagem importante do RAG?', 'Impedir atualizações da base de conhecimento', FALSE, 1),
      ('Qual é uma vantagem importante do RAG?', 'Eliminar completamente a necessidade de avaliação', FALSE, 2),
      ('Qual é uma vantagem importante do RAG?', 'Permitir que o sistema utilize informações externas sem depender exclusivamente do conhecimento incorporado nos pesos do modelo', TRUE, 3),
      ('Em um sistema RAG, qual é a função do retriever?', 'Traduzir todas as respostas', FALSE, 0),
      ('Em um sistema RAG, qual é a função do retriever?', 'Recuperar documentos ou trechos potencialmente relevantes para uma consulta', TRUE, 1),
      ('Em um sistema RAG, qual é a função do retriever?', 'Atualizar automaticamente todos os pesos do LLM', FALSE, 2),
      ('Em um sistema RAG, qual é a função do retriever?', 'Gerar exclusivamente imagens', FALSE, 3),
      ('O que é um vetor de similaridade semântica?', 'Um conjunto de parâmetros exclusivamente visuais', FALSE, 0),
      ('O que é um vetor de similaridade semântica?', 'Um tipo de função de ativação', FALSE, 1),
      ('O que é um vetor de similaridade semântica?', 'Uma representação numérica usada para comparar a proximidade de significado entre elementos', TRUE, 2),
      ('O que é um vetor de similaridade semântica?', 'Uma lista de palavras proibidas', FALSE, 3),
      ('Por que bancos de dados vetoriais são utilizados em sistemas RAG?', 'Para substituir todos os modelos de linguagem', FALSE, 0),
      ('Por que bancos de dados vetoriais são utilizados em sistemas RAG?', 'Para armazenar somente imagens sem metadados', FALSE, 1),
      ('Por que bancos de dados vetoriais são utilizados em sistemas RAG?', 'Para armazenar e recuperar representações vetoriais de forma eficiente por similaridade', TRUE, 2),
      ('Por que bancos de dados vetoriais são utilizados em sistemas RAG?', 'Para impedir buscas semânticas', FALSE, 3),
      ('O que é hallucination em modelos generativos?', 'Quando o modelo deixa de utilizar GPU', FALSE, 0),
      ('O que é hallucination em modelos generativos?', 'Quando o banco de dados fica indisponível', FALSE, 1),
      ('O que é hallucination em modelos generativos?', 'Quando o modelo não possui tokens', FALSE, 2),
      ('O que é hallucination em modelos generativos?', 'Quando o modelo produz informação aparentemente plausível, mas incorreta ou não fundamentada', TRUE, 3),
      ('Qual estratégia pode ajudar a reduzir alucinações em sistemas de IA?', 'Impedir o modelo de receber contexto', FALSE, 0),
      ('Qual estratégia pode ajudar a reduzir alucinações em sistemas de IA?', 'Remover todas as fontes externas', FALSE, 1),
      ('Qual estratégia pode ajudar a reduzir alucinações em sistemas de IA?', 'Aumentar sempre a temperatura', FALSE, 2),
      ('Qual estratégia pode ajudar a reduzir alucinações em sistemas de IA?', 'Fornecer contexto confiável, utilizar recuperação de fontes e exigir verificação das informações', TRUE, 3),
      ('O que é alinhamento de modelos de IA?', 'Processo de orientar o comportamento do modelo para seguir objetivos, instruções e restrições desejadas', TRUE, 0),
      ('O que é alinhamento de modelos de IA?', 'Processo de aumentar somente o número de parâmetros', FALSE, 1),
      ('O que é alinhamento de modelos de IA?', 'Processo de reduzir a resolução das entradas', FALSE, 2),
      ('O que é alinhamento de modelos de IA?', 'Processo de remover o treinamento', FALSE, 3),
      ('O que é RLHF?', 'Um método de compressão de imagens', FALSE, 0),
      ('O que é RLHF?', 'Aprendizado por reforço a partir de feedback humano', TRUE, 1),
      ('O que é RLHF?', 'Recuperação linguística de alta frequência', FALSE, 2),
      ('O que é RLHF?', 'Redução linear de hardware funcional', FALSE, 3),
      ('Qual é uma finalidade do RLHF?', 'Ajustar o comportamento do modelo de acordo com preferências ou avaliações humanas', TRUE, 0),
      ('Qual é uma finalidade do RLHF?', 'Aumentar automaticamente o vocabulário', FALSE, 1),
      ('Qual é uma finalidade do RLHF?', 'Eliminar completamente o pré-treinamento', FALSE, 2),
      ('Qual é uma finalidade do RLHF?', 'Impedir qualquer adaptação do modelo', FALSE, 3),
      ('O que é data leakage em aprendizado de máquina?', 'Quando o modelo possui poucas camadas', FALSE, 0),
      ('O que é data leakage em aprendizado de máquina?', 'Quando uma imagem possui baixa resolução', FALSE, 1),
      ('O que é data leakage em aprendizado de máquina?', 'Quando informações que não deveriam estar disponíveis durante o treinamento acabam influenciando o modelo', TRUE, 2),
      ('O que é data leakage em aprendizado de máquina?', 'Quando os dados são armazenados em um servidor', FALSE, 3),
      ('Por que data leakage pode produzir uma avaliação enganosa?', 'Porque elimina todos os dados de teste', FALSE, 0),
      ('Por que data leakage pode produzir uma avaliação enganosa?', 'Porque impede o treinamento', FALSE, 1),
      ('Por que data leakage pode produzir uma avaliação enganosa?', 'Porque sempre reduz a precisão', FALSE, 2),
      ('Por que data leakage pode produzir uma avaliação enganosa?', 'Porque pode fazer o modelo parecer mais preciso do que realmente é em dados não vistos', TRUE, 3),
      ('O que é distribuição de dados em machine learning?', 'A quantidade de memória RAM disponível', FALSE, 0),
      ('O que é distribuição de dados em machine learning?', 'O número de camadas de uma rede', FALSE, 1),
      ('O que é distribuição de dados em machine learning?', 'A velocidade da conexão', FALSE, 2),
      ('O que é distribuição de dados em machine learning?', 'A forma como diferentes valores ou exemplos estão estatisticamente distribuídos', TRUE, 3),
      ('O que é concept drift?', 'Redução do número de tokens', FALSE, 0),
      ('O que é concept drift?', 'Erro causado exclusivamente por falta de GPU', FALSE, 1),
      ('O que é concept drift?', 'Mudança na relação entre as características dos dados e o alvo ao longo do tempo', TRUE, 2),
      ('O que é concept drift?', 'Alteração física do servidor', FALSE, 3),
      ('Por que concept drift é relevante em sistemas de IA em produção?', 'Porque um modelo treinado com dados antigos pode perder desempenho quando os padrões do ambiente mudam', TRUE, 0),
      ('Por que concept drift é relevante em sistemas de IA em produção?', 'Porque impede qualquer modelo de ser treinado', FALSE, 1),
      ('Por que concept drift é relevante em sistemas de IA em produção?', 'Porque elimina a necessidade de monitoramento', FALSE, 2),
      ('Por que concept drift é relevante em sistemas de IA em produção?', 'Porque aumenta automaticamente a precisão', FALSE, 3),
      ('O que significa interpretabilidade em IA?', 'Capacidade de aumentar o número de parâmetros', FALSE, 0),
      ('O que significa interpretabilidade em IA?', 'Capacidade de executar sem dados', FALSE, 1),
      ('O que significa interpretabilidade em IA?', 'Capacidade de gerar respostas mais longas', FALSE, 2),
      ('O que significa interpretabilidade em IA?', 'Capacidade de compreender ou explicar aspectos do funcionamento ou das decisões de um modelo', TRUE, 3),
      ('O que é SHAP em explicabilidade de modelos?', 'Um método baseado em valores de Shapley para estimar a contribuição das características para uma previsão', TRUE, 0),
      ('O que é SHAP em explicabilidade de modelos?', 'Uma arquitetura de Transformer', FALSE, 1),
      ('O que é SHAP em explicabilidade de modelos?', 'Um método de compressão de áudio', FALSE, 2),
      ('O que é SHAP em explicabilidade de modelos?', 'Um algoritmo exclusivo de tokenização', FALSE, 3),
      ('O que caracteriza uma métrica de avaliação inadequada para um problema de IA?', 'Uma métrica calculada sobre dados', FALSE, 0),
      ('O que caracteriza uma métrica de avaliação inadequada para um problema de IA?', 'Uma métrica que não representa corretamente o objetivo real da aplicação', TRUE, 1),
      ('O que caracteriza uma métrica de avaliação inadequada para um problema de IA?', 'Uma métrica que pode ser comparada entre modelos', FALSE, 2),
      ('O que caracteriza uma métrica de avaliação inadequada para um problema de IA?', 'Uma métrica usada durante testes', FALSE, 3),
      ('Em classificação altamente desbalanceada, por que a acurácia pode ser enganosa?', 'Porque uma classe majoritária pode dominar a métrica mesmo quando o modelo apresenta desempenho ruim nas classes minoritárias', TRUE, 0),
      ('Em classificação altamente desbalanceada, por que a acurácia pode ser enganosa?', 'Porque a acurácia nunca pode ser calculada', FALSE, 1),
      ('Em classificação altamente desbalanceada, por que a acurácia pode ser enganosa?', 'Porque todas as classes possuem necessariamente o mesmo tamanho', FALSE, 2),
      ('Em classificação altamente desbalanceada, por que a acurácia pode ser enganosa?', 'Porque o modelo não pode produzir probabilidades', FALSE, 3),
      ('Qual é uma razão importante para avaliar um sistema de IA além da precisão?', 'Porque precisão nunca é útil', FALSE, 0),
      ('Qual é uma razão importante para avaliar um sistema de IA além da precisão?', 'Porque qualquer modelo funciona igualmente bem em produção', FALSE, 1),
      ('Qual é uma razão importante para avaliar um sistema de IA além da precisão?', 'Porque segurança, robustez, justiça, latência, custo e capacidade de generalização também podem ser essenciais para o uso real', TRUE, 2),
      ('Qual é uma razão importante para avaliar um sistema de IA além da precisão?', 'Porque modelos de IA não precisam ser testados', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_ia_dificil_v1;

    RAISE NOTICE '49 perguntas inseridas com sucesso (source=seed_ia_dificil_v1).';
  END IF;
END $$;

COMMIT;
