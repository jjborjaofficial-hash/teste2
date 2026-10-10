-- Explicações pedagógicas (BE-004) — IA difícil lote 2: as mesmas 25 perguntas da migration 422 (explicação curta e clara,
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
    ('seed_ia_dificil_v1', 'Qual é uma vantagem do fine-tuning em relação ao treinamento de um modelo do zero?', 'No fine-tuning parte-se de um modelo já pré-treinado e ajusta-se à tarefa nova. Assim aproveitam-se representações que ele já aprendeu e precisa-se de menos dados e tempo do que para treinar do zero.'),
    ('seed_ia_dificil_v1', 'O que é beam search?', 'O beam search, em vez de escolher o próximo token mais provável e seguir em frente, mantém várias sequências candidatas ao mesmo tempo e fica com a melhor no fim. Costuma dar resultados melhores do que escolher token a token.'),
    ('seed_ia_dificil_v1', 'O que é alinhamento de modelos de IA?', 'Alinhar um modelo é orientá-lo para fazer o que as pessoas realmente querem: seguir instruções, respeitar limites e evitar respostas nocivas. Técnicas como o RLHF servem para isso.'),
    ('seed_ia_dificil_v1', 'O que é SHAP em explicabilidade de modelos?', 'SHAP usa valores de Shapley, da teoria dos jogos, para dizer quanto cada característica contribuiu para uma previsão concreta. Ajuda a explicar por que o modelo decidiu como decidiu.'),
    ('seed_ia_dificil_v1', 'O que tende a acontecer quando a temperatura de amostragem de um modelo de linguagem é aumentada?', 'Uma temperatura mais alta achata a distribuição de probabilidades, e tokens menos prováveis passam a ter mais hipóteses de sair. O texto fica mais variado e imprevisível; com temperatura baixa fica mais previsível.'),
    ('seed_ia_dificil_v1', 'Em deep learning, o que significa overfitting?', 'Overfitting é o modelo decorar o treino, incluindo ruído e particularidades, e por isso ir mal com dados novos. Ele vai bem no treino e mal no teste.'),
    ('seed_ia_dificil_v1', 'Qual técnica pode ajudar a reduzir overfitting?', 'O dropout desliga neurónios ao acaso durante o treino, o que impede a rede de depender demasiado de poucos caminhos e ajuda-a a generalizar melhor com dados novos.'),
    ('seed_ia_dificil_v1', 'Em modelos generativos, o que significa "temperatura" na geração de texto?', 'A temperatura regula o quão arriscadas são as escolhas do modelo: valores altos dão respostas mais variadas e criativas, valores baixos dão respostas mais previsíveis.'),
    ('seed_ia_dificil_v1', 'Em processamento de linguagem natural, o que é tokenização?', 'Tokenizar é partir o texto em pedaços (tokens), como palavras ou partes de palavras, e dar a cada um deles um número. É assim que o modelo consegue "ler" o texto.'),
    ('seed_ia_dificil_v1', 'O que é um vetor de similaridade semântica?', 'Um vetor semântico é uma lista de números que representa o significado de uma palavra ou frase. Quanto mais perto estão dois vetores, mais parecidos são os significados.'),
    ('seed_ia_dificil_v1', 'Qual problema o mecanismo de atenção multi-head procura resolver em Transformers?', 'Várias cabeças de atenção olham para a mesma frase em paralelo, cada uma focada num tipo de relação (por exemplo, sujeito e verbo, ou palavras próximas). Juntas dão ao modelo uma visão mais rica.'),
    ('seed_ia_dificil_v1', 'Qual é uma vantagem importante do RAG?', 'Com RAG o modelo consulta documentos externos na hora de responder, em vez de depender do que ficou guardado nos pesos durante o treino. Assim a base pode ser atualizada sem treinar o modelo de novo.'),
    ('seed_ia_dificil_v1', 'O que é RLHF?', 'RLHF significa Reinforcement Learning from Human Feedback, ou seja, aprendizado por reforço a partir de feedback humano: pessoas avaliam as respostas e o modelo é ajustado para as melhorar.'),
    ('seed_ia_dificil_v1', 'Em um Transformer, qual é a principal função do mecanismo de self-attention?', 'Na self-attention cada token olha para os outros da mesma frase e decide a quais deve dar mais atenção para perceber o seu sentido naquele contexto.'),
    ('seed_ia_dificil_v1', 'O que significa interpretabilidade em IA?', 'Interpretabilidade é conseguir perceber por que um modelo deu determinada resposta ou tomou determinada decisão. É importante para confiar nele, detetar erros e justificar resultados.'),
    ('seed_ia_dificil_v1', 'O que é distribuição de dados em machine learning?', 'A distribuição dos dados descreve como os valores ou exemplos se repartem: onde se concentram e quais são raros. Se os dados de produção forem distribuídos de outra forma que os de treino, o modelo tende a falhar.'),
    ('seed_ia_dificil_v1', 'Por que data leakage pode produzir uma avaliação enganosa?', 'Com leakage o modelo vê, durante o treino, informação que não devia ver. Os números de avaliação ficam bonitos, mas no mundo real, com dados que nunca viu, o desempenho é pior.'),
    ('seed_ia_dificil_v1', 'Qual é a função principal da regularização L2?', 'A regularização L2 soma ao erro uma penalização pelo tamanho dos pesos. Assim o modelo evita pesos muito grandes e tende a generalizar melhor.'),
    ('seed_ia_dificil_v1', 'O que é atenção causal em um modelo autoregressivo?', 'Na atenção causal cada posição só pode olhar para os tokens anteriores e para si própria, nunca para os seguintes. É o que permite gerar texto palavra a palavra sem espreitar o futuro.'),
    ('seed_ia_dificil_v1', 'Em LLMs, o que é perplexidade?', 'Perplexidade mede o quanto um modelo se surpreende com um texto. Quanto menor, melhor ele prevê os tokens da sequência.'),
    ('seed_ia_dificil_v1', 'O que é hallucination em modelos generativos?', 'Alucinação é o modelo dar uma resposta que parece plausível e bem escrita, mas é falsa ou sem base. Por isso convém conferir as informações importantes.'),
    ('seed_ia_dificil_v1', 'Qual técnica é frequentemente utilizada para reduzir o problema do vanishing gradient em redes profundas?', 'Funções como a ReLU não achatam o gradiente nas zonas positivas, por isso o sinal chega às primeiras camadas sem se desfazer.'),
    ('seed_ia_dificil_v1', 'O que caracteriza uma métrica de avaliação inadequada para um problema de IA?', 'Uma métrica é inadequada quando mede algo diferente do que realmente importa na aplicação. Por exemplo, uma acurácia alta num problema com classes muito desiguais pode esconder falhas.'),
    ('seed_ia_dificil_v1', 'Em IA generativa, o que é um modelo multimodal?', 'Um modelo multimodal trabalha com mais de um tipo de dado, por exemplo texto, imagem e áudio, e consegue relacioná-los: descrever uma fotografia ou responder a uma pergunta falada.'),
    ('seed_ia_dificil_v2', 'O que é Edge AI?', 'Edge AI corre a IA perto de onde os dados nascem, no próprio telemóvel, câmara ou sensor, em vez de enviar tudo para a nuvem. Reduz o atraso e protege melhor a privacidade.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações IA difícil lote 2: % pergunta(s) atualizada(s) (esperado: 25).', v_updated;
END $$;
