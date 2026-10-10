-- Alternativas (BE-003, regularização) — IA difícil lote 1: 25 perguntas ativas de IA difícil (seed_ia_dificil_v1, as primeiras 25 por ordem de inserção) ainda sem explicação.
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
    ('seed_ia_dificil_v1', 'O que é concept drift?', 0, 'Redução do número de tokens', 'Aumento no volume de dados de entrada recebidos por segundo pelo sistema'),
    ('seed_ia_dificil_v1', 'O que é concept drift?', 1, 'Erro causado exclusivamente por falta de GPU', 'Perda de desempenho causada por falhas no hardware durante o treinamento'),
    ('seed_ia_dificil_v1', 'O que é concept drift?', 3, 'Alteração física do servidor', 'Alteração nos parâmetros do modelo provocada por uma atualização do servidor de produção'),
    ('seed_ia_dificil_v1', 'Qual é uma finalidade do RLHF?', 1, 'Aumentar automaticamente o vocabulário', 'Ampliar o vocabulário do modelo com palavras novas retiradas das conversas'),
    ('seed_ia_dificil_v1', 'Qual é uma finalidade do RLHF?', 2, 'Eliminar completamente o pré-treinamento', 'Substituir o pré-treinamento por um treino curto feito com avaliadores humanos'),
    ('seed_ia_dificil_v1', 'Qual é uma finalidade do RLHF?', 3, 'Impedir qualquer adaptação do modelo', 'Fixar o comportamento do modelo para que não possa ser ajustado depois do treino inicial feito pela equipa'),
    ('seed_ia_dificil_v1', 'Por que concept drift é relevante em sistemas de IA em produção?', 1, 'Porque impede qualquer modelo de ser treinado', 'Porque o modelo passa a precisar de mais memória quando recebe novos tipos de dados'),
    ('seed_ia_dificil_v1', 'Por que concept drift é relevante em sistemas de IA em produção?', 2, 'Porque elimina a necessidade de monitoramento', 'Porque os dados antigos deixam de ser armazenados e o modelo perde a capacidade de prever corretamente os novos casos'),
    ('seed_ia_dificil_v1', 'Por que concept drift é relevante em sistemas de IA em produção?', 3, 'Porque aumenta automaticamente a precisão', 'Porque o desempenho do modelo pode cair quando o servidor é atualizado sem aviso prévio'),
    ('seed_ia_dificil_v1', 'Qual é uma razão importante para avaliar um sistema de IA além da precisão?', 0, 'Porque precisão nunca é útil', 'Porque a precisão pode medir o tempo de resposta e deixar de fora a qualidade dos resultados obtidos'),
    ('seed_ia_dificil_v1', 'Qual é uma razão importante para avaliar um sistema de IA além da precisão?', 1, 'Porque qualquer modelo funciona igualmente bem em produção', 'Porque um modelo com boa precisão nos testes pode funcionar bem em produção, por isso outras métricas são dispensáveis'),
    ('seed_ia_dificil_v1', 'Qual é uma razão importante para avaliar um sistema de IA além da precisão?', 3, 'Porque modelos de IA não precisam ser testados', 'Porque os modelos de IA já são testados pelos fabricantes e as métricas adicionais podem encarecer o projeto sem benefício'),
    ('seed_ia_dificil_v1', 'O que caracteriza um embedding contextual?', 0, 'O embedding não utiliza vetores', 'O embedding pode ser calculado por contagem de ocorrências e não utilizar vetores densos'),
    ('seed_ia_dificil_v1', 'O que caracteriza um embedding contextual?', 1, 'O embedding contém apenas a frequência da palavra', 'A representação pode depender da frequência da palavra no conjunto de treino usado'),
    ('seed_ia_dificil_v1', 'O que caracteriza um embedding contextual?', 3, 'A representação de um token permanece sempre idêntica independentemente do contexto', 'A representação de um token pode ser fixa e igual em frases de contextos diferentes'),
    ('seed_ia_dificil_v1', 'O que é transfer learning?', 0, 'Treinar somente com dados sintéticos', 'Treinar um modelo do zero com dados sintéticos gerados por outro modelo maior e mais caro'),
    ('seed_ia_dificil_v1', 'O que é transfer learning?', 1, 'Transferir fisicamente um modelo para outro computador', 'Mover os pesos de um modelo para outro computador para reduzir o tempo de treino necessário'),
    ('seed_ia_dificil_v1', 'O que é transfer learning?', 2, 'Copiar arquivos sem modificar pesos', 'Copiar o modelo de outra tarefa sem alterar os pesos e usá-lo diretamente no novo domínio de aplicação'),
    ('seed_ia_dificil_v1', 'O que é quantização de um modelo de IA?', 1, 'Aumentar obrigatoriamente o número de parâmetros', 'Aumentar o número de camadas do modelo para guardar valores com mais detalhe'),
    ('seed_ia_dificil_v1', 'O que é quantização de um modelo de IA?', 2, 'Remover todos os embeddings', 'Remover os embeddings pouco usados para reduzir o tamanho final do modelo'),
    ('seed_ia_dificil_v1', 'O que é quantização de um modelo de IA?', 3, 'Transformar texto em áudio', 'Converter a saída do modelo em valores discretos para facilitar a leitura'),
    ('seed_ia_dificil_v1', 'Em um Transformer, por que são necessárias informações posicionais?', 1, 'Porque impedem a atenção entre tokens', 'Porque a atenção bloqueia a ligação entre tokens que estejam em posições diferentes da frase'),
    ('seed_ia_dificil_v1', 'Em um Transformer, por que são necessárias informações posicionais?', 2, 'Porque eliminam os embeddings', 'Porque os embeddings de cada token já trazem a posição, mas perdem-se na camada final'),
    ('seed_ia_dificil_v1', 'Em um Transformer, por que são necessárias informações posicionais?', 3, 'Porque substituem a função de perda', 'Porque a função de perda precisa conhecer a ordem dos tokens para calcular o erro de cada previsão'),
    ('seed_ia_dificil_v1', 'Em classificação altamente desbalanceada, por que a acurácia pode ser enganosa?', 1, 'Porque a acurácia nunca pode ser calculada', 'Porque a acurácia pode deixar de ser calculada quando as classes têm tamanhos muito diferentes entre si no treino'),
    ('seed_ia_dificil_v1', 'Em classificação altamente desbalanceada, por que a acurácia pode ser enganosa?', 2, 'Porque todas as classes possuem necessariamente o mesmo tamanho', 'Porque a acurácia pode contar os erros da classe minoritária e ignora os acertos da classe maior no conjunto de teste'),
    ('seed_ia_dificil_v1', 'Em classificação altamente desbalanceada, por que a acurácia pode ser enganosa?', 3, 'Porque o modelo não pode produzir probabilidades', 'Porque o modelo pode deixar de produzir probabilidades calibradas quando o conjunto de dados é muito desigual'),
    ('seed_ia_dificil_v1', 'O que é exploração no contexto de aprendizado por reforço?', 0, 'Escolher apenas ações já conhecidas como ótimas', 'Repetir as ações que já deram a maior recompensa para consolidar o que o agente aprendeu'),
    ('seed_ia_dificil_v1', 'O que é exploração no contexto de aprendizado por reforço?', 1, 'Reduzir o espaço de ações para uma única escolha', 'Reduzir o espaço de ações do agente para acelerar a convergência do treinamento'),
    ('seed_ia_dificil_v1', 'O que é exploração no contexto de aprendizado por reforço?', 3, 'Remover estados do ambiente', 'Remover do ambiente os estados que o agente já visitou para evitar repetições'),
    ('seed_ia_dificil_v1', 'Uma perplexidade menor geralmente indica:', 0, 'Maior número de parâmetros obrigatoriamente', 'Maior número de parâmetros, já que modelos maiores têm perplexidade menor'),
    ('seed_ia_dificil_v1', 'Uma perplexidade menor geralmente indica:', 1, 'Ausência de treinamento', 'Menor tempo de treinamento do modelo nas mesmas condições de avaliação'),
    ('seed_ia_dificil_v1', 'Por que modelos modernos utilizam embeddings?', 0, 'Para impedir relações semânticas', 'Para impedir que o modelo confunda tokens, mesmo com significados parecidos entre si'),
    ('seed_ia_dificil_v1', 'Por que modelos modernos utilizam embeddings?', 1, 'Para substituir completamente o treinamento', 'Para substituir o treinamento, usando uma tabela fixa de significados das palavras'),
    ('seed_ia_dificil_v1', 'Por que modelos modernos utilizam embeddings?', 3, 'Para remover toda informação contextual', 'Para eliminar a informação de contexto, guardando a posição exata de cada token da frase'),
    ('seed_ia_dificil_v1', 'O que diferencia aprendizado supervisionado de aprendizado não supervisionado?', 0, 'O não supervisionado exige sempre rótulos humanos', 'O não supervisionado utiliza dados rotulados por pessoas para agrupar entradas parecidas entre si'),
    ('seed_ia_dificil_v1', 'O que diferencia aprendizado supervisionado de aprendizado não supervisionado?', 2, 'O não supervisionado só pode ser usado em imagens', 'O não supervisionado é aplicado a imagens, enquanto o supervisionado é aplicado a textos'),
    ('seed_ia_dificil_v1', 'O que diferencia aprendizado supervisionado de aprendizado não supervisionado?', 3, 'O supervisionado nunca utiliza redes neurais', 'O supervisionado dispensa redes neurais, enquanto o não supervisionado depende delas'),
    ('seed_ia_dificil_v1', 'Em aprendizado por reforço, o que representa a função de valor?', 0, 'A quantidade de dados disponíveis', 'A quantidade de dados que o agente já coletou durante os episódios de treino realizados até agora'),
    ('seed_ia_dificil_v1', 'Em aprendizado por reforço, o que representa a função de valor?', 2, 'O número total de parâmetros da rede', 'O número de camadas da rede que o agente usa para decidir cada ação'),
    ('seed_ia_dificil_v1', 'Em aprendizado por reforço, o que representa a função de valor?', 3, 'A velocidade do processador', 'A recompensa imediata recebida pelo agente depois de executar uma única ação'),
    ('seed_ia_dificil_v1', 'Qual é uma possível vantagem da quantização?', 1, 'Eliminação completa da necessidade de hardware', 'Aumento da capacidade de memória do hardware e, em alguns casos, do número de parâmetros'),
    ('seed_ia_dificil_v1', 'Qual é uma possível vantagem da quantização?', 2, 'Aumento obrigatório da qualidade da resposta', 'Melhoria da qualidade das respostas e, em alguns casos, redução do tempo de treinamento'),
    ('seed_ia_dificil_v1', 'Qual é uma possível vantagem da quantização?', 3, 'Garantia de precisão perfeita', 'Redução do tamanho dos dados de treino e, em alguns casos, maior precisão nas previsões'),
    ('seed_ia_dificil_v1', 'Em redes neurais profundas, o que caracteriza o problema do vanishing gradient?', 0, 'Os gradientes tornam-se extremamente grandes durante a retropropagação', 'Os gradientes tornam-se muito grandes, dificultando a atualização das últimas camadas'),
    ('seed_ia_dificil_v1', 'Em redes neurais profundas, o que caracteriza o problema do vanishing gradient?', 2, 'Os dados de treinamento desaparecem', 'Os pesos das primeiras camadas desaparecem do modelo durante a fase de treinamento'),
    ('seed_ia_dificil_v1', 'Em redes neurais profundas, o que caracteriza o problema do vanishing gradient?', 3, 'O modelo deixa de possuir função de perda', 'A função de perda perde valor ao longo das épocas, dificultando o ajuste das camadas'),
    ('seed_ia_dificil_v1', 'O que é data leakage em aprendizado de máquina?', 0, 'Quando o modelo possui poucas camadas', 'Quando o modelo possui camadas em excesso e memoriza os exemplos usados no treinamento'),
    ('seed_ia_dificil_v1', 'O que é data leakage em aprendizado de máquina?', 1, 'Quando uma imagem possui baixa resolução', 'Quando os dados de treino são perdidos por falha de armazenamento antes do ajuste do modelo'),
    ('seed_ia_dificil_v1', 'O que é data leakage em aprendizado de máquina?', 3, 'Quando os dados são armazenados em um servidor', 'Quando os dados pessoais dos utilizadores são expostos por uma falha de segurança no servidor onde o modelo foi treinado'),
    ('seed_ia_dificil_v1', 'O que caracteriza aprendizado auto-supervisionado?', 1, 'O treinamento depende exclusivamente de rótulos humanos', 'O treinamento depende de rótulos escritos por pessoas para cada exemplo do conjunto de dados'),
    ('seed_ia_dificil_v1', 'O que caracteriza aprendizado auto-supervisionado?', 2, 'Não utiliza nenhuma função de perda', 'O modelo dispensa a função de perda e aprende por comparação direta entre os exemplos'),
    ('seed_ia_dificil_v1', 'O que caracteriza aprendizado auto-supervisionado?', 3, 'Só funciona com dados numéricos', 'O modelo aprende a partir de dados numéricos tabulares, sem usar textos nem imagens'),
    ('seed_ia_dificil_v1', 'O que é RAG (Retrieval-Augmented Generation)?', 0, 'Uma técnica exclusivamente para classificação de imagens', 'Uma técnica de classificação de imagens que combina redes convolucionais com busca em bases externas'),
    ('seed_ia_dificil_v1', 'O que é RAG (Retrieval-Augmented Generation)?', 2, 'Um método que elimina completamente o contexto', 'Um método que reduz o contexto do modelo para gerar respostas mais curtas e mais rápidas'),
    ('seed_ia_dificil_v1', 'O que é RAG (Retrieval-Augmented Generation)?', 3, 'Um algoritmo que impede o acesso a documentos', 'Um algoritmo que bloqueia o acesso do modelo a documentos privados durante a geração do texto'),
    ('seed_ia_dificil_v1', 'Por que bancos de dados vetoriais são utilizados em sistemas RAG?', 0, 'Para substituir todos os modelos de linguagem', 'Para substituir o modelo de linguagem na geração das respostas apresentadas ao utilizador'),
    ('seed_ia_dificil_v1', 'Por que bancos de dados vetoriais são utilizados em sistemas RAG?', 1, 'Para armazenar somente imagens sem metadados', 'Para guardar imagens e metadados em tabelas relacionais com consultas por palavra exata'),
    ('seed_ia_dificil_v1', 'Por que bancos de dados vetoriais são utilizados em sistemas RAG?', 3, 'Para impedir buscas semânticas', 'Para substituir as buscas semânticas por consultas feitas com palavras-chave exatas'),
    ('seed_ia_dificil_v1', 'Qual é uma limitação importante do beam search em geração de texto?', 0, 'Nunca utiliza probabilidades', 'Pode ignorar as probabilidades dos tokens e escolher as sequências de forma aleatória'),
    ('seed_ia_dificil_v1', 'Qual é uma limitação importante do beam search em geração de texto?', 1, 'Não pode produzir mais de um token', 'Pode produzir um único token por vez, o que impede a geração de frases completas'),
    ('seed_ia_dificil_v1', 'Qual é uma limitação importante do beam search em geração de texto?', 2, 'Só funciona com modelos sem parâmetros', 'Pode consumir muita memória, o que o torna inviável em modelos com mais de um milhão de parâmetros'),
    ('seed_ia_dificil_v1', 'Qual é o principal objetivo do algoritmo Q-learning?', 0, 'Reduzir a resolução dos dados', 'Reduzir a quantidade de dados necessária para treinar o agente em ambientes complexos'),
    ('seed_ia_dificil_v1', 'Qual é o principal objetivo do algoritmo Q-learning?', 2, 'Classificar imagens sem treinamento', 'Classificar imagens com um modelo treinado a partir de exemplos rotulados'),
    ('seed_ia_dificil_v1', 'Qual é o principal objetivo do algoritmo Q-learning?', 3, 'Gerar embeddings exclusivamente de palavras', 'Gerar representações vetoriais de palavras a partir de grandes volumes de texto'),
    ('seed_ia_dificil_v1', 'Em um sistema RAG, qual é a função do retriever?', 0, 'Traduzir todas as respostas', 'Traduzir a pergunta do utilizador para o idioma em que os documentos foram escritos'),
    ('seed_ia_dificil_v1', 'Em um sistema RAG, qual é a função do retriever?', 2, 'Atualizar automaticamente todos os pesos do LLM', 'Atualizar os pesos do modelo de linguagem com os documentos recuperados'),
    ('seed_ia_dificil_v1', 'Em um sistema RAG, qual é a função do retriever?', 3, 'Gerar exclusivamente imagens', 'Gerar a resposta final em linguagem natural a partir dos trechos encontrados'),
    ('seed_ia_dificil_v1', 'Qual estratégia pode ajudar a reduzir alucinações em sistemas de IA?', 0, 'Impedir o modelo de receber contexto', 'Reduzir o contexto fornecido ao modelo para que ele dependa menos de informações externas'),
    ('seed_ia_dificil_v1', 'Qual estratégia pode ajudar a reduzir alucinações em sistemas de IA?', 1, 'Remover todas as fontes externas', 'Retirar as fontes externas e confiar no que o modelo memorizou durante o treinamento'),
    ('seed_ia_dificil_v1', 'Qual estratégia pode ajudar a reduzir alucinações em sistemas de IA?', 2, 'Aumentar sempre a temperatura', 'Aumentar a temperatura de geração para que as respostas fiquem mais variadas, criativas e menos repetitivas'),
    ('seed_ia_dificil_v1', 'O que é knowledge distillation?', 1, 'Remover as funções de ativação', 'Remover as funções de ativação de um modelo para que ele fique menor e mais simples'),
    ('seed_ia_dificil_v1', 'O que é knowledge distillation?', 2, 'Apagar o conhecimento de um modelo', 'Apagar do modelo as informações sensíveis para que ele deixe de reproduzi-las'),
    ('seed_ia_dificil_v1', 'O que é knowledge distillation?', 3, 'Transformar um modelo supervisionado em banco de dados', 'Converter um modelo supervisionado em banco de dados para consulta mais rápida das respostas já geradas')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas IA difícil lote 1: % alternativa(s) errada(s) atualizada(s) (esperado: 74).', v_updated;
END $$;
