-- Explicações pedagógicas (BE-004) — IA difícil lote 5: as mesmas 25 perguntas da migration 428 (explicação curta e clara,
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
    ('seed_ia_dificil_v2', 'O que é uma época (epoch) no treinamento de IA?', 'Uma época é uma passagem completa de todos os dados de treinamento pelo modelo. Treinar costuma exigir várias épocas, para o modelo ir melhorando aos poucos.'),
    ('seed_ia_dificil_v2', 'O que é precisão (precision) em classificação?', 'A precisão responde: das vezes que o modelo disse positivo, quantas estavam certas? Uma precisão alta significa poucos falsos positivos.'),
    ('seed_ia_dificil_v2', 'O que é função de ativação em uma rede neural?', 'A função de ativação decide qual é a saída de um neurônio a partir da sua entrada. Ao introduzir não linearidade, permite à rede aprender padrões complexos, e não apenas relações simples.'),
    ('seed_ia_dificil_v2', 'O que caracteriza uma rede neural artificial?', 'Uma rede neural artificial é formada por unidades ligadas entre si, os neurônios artificiais, inspiradas de forma simplificada nos neurônios do cérebro. Aprende ajustando as ligações.'),
    ('seed_ia_dificil_v2', 'O que são modelos de linguagem grandes (LLMs)?', 'Os LLMs (Large Language Models) são treinados com enormes quantidades de texto para compreender e gerar linguagem. É a tecnologia por trás de assistentes como os chatbots atuais.'),
    ('seed_ia_dificil_v2', 'O que é segurança em IA?', 'Segurança em IA é proteger os modelos e os sistemas contra ataques, como a manipulação dos dados ou das entradas, e contra usos indevidos.'),
    ('seed_ia_dificil_v2', 'O que significa GPT em modelos de IA?', 'GPT significa Generative Pre-trained Transformer: generativo (cria conteúdo), pré-treinado (já treinado com muitos dados) e Transformer (a arquitetura usada).'),
    ('seed_ia_dificil_v2', 'Qual é a vantagem do RAG?', 'Com RAG o modelo consulta fontes específicas na hora de responder, por isso as respostas podem ser mais atuais e apoiadas em documentos, e não só no que o modelo aprendeu no treino.'),
    ('seed_ia_dificil_v2', 'O que é validação cruzada?', 'Na validação cruzada os dados são divididos em várias partes: o modelo treina com algumas e é avaliado com a restante, e repete-se trocando as partes. Dá uma medida mais fiável do desempenho.'),
    ('seed_ia_dificil_v2', 'O que é regularização em Machine Learning?', 'A regularização limita a complexidade do modelo, por exemplo penalizando pesos grandes. Assim ele decora menos o treino, sofre menos de overfitting e generaliza melhor.'),
    ('seed_ia_dificil_v2', 'O que diferencia RPA tradicional de IA?', 'O RPA segue regras fixas definidas por pessoas, como um script. A IA aprende com dados e consegue tomar decisões mais complexas e lidar com casos que não estavam previstos.'),
    ('seed_ia_dificil_v2', 'O que acontece quando o learning rate é muito alto?', 'Com um learning rate muito alto, os passos de atualização são tão grandes que o modelo salta por cima da melhor solução e pode nunca estabilizar. Com um valor muito baixo, aprende devagar demais.'),
    ('seed_ia_dificil_v2', 'O que é memória de longo prazo em redes LSTM?', 'As LSTM têm uma célula de memória que decide o que guardar e o que esquecer. Isso permite-lhes manter informação importante ao longo de sequências longas, como frases extensas.'),
    ('seed_ia_dificil_v2', 'O que mede a acurácia de um modelo?', 'A acurácia é a percentagem de previsões que o modelo acertou, em relação ao total. Pode enganar quando as classes são muito desiguais.'),
    ('seed_ia_dificil_v2', 'Qual é a principal vantagem do Transfer Learning?', 'Com transfer learning reaproveita-se um modelo já treinado como ponto de partida, por isso é preciso menos tempo e menos dados para treinar um modelo novo.'),
    ('seed_ia_dificil_v2', 'Qual é a função da camada de entrada em uma rede neural?', 'A camada de entrada é a primeira da rede: recebe os dados (por exemplo, os pixels de uma imagem) e passa-os para as camadas seguintes processarem.'),
    ('seed_ia_dificil_v2', 'O que é treinamento de um modelo de IA?', 'Treinar é o modelo aprender: recebe muitos exemplos, compara as suas previsões com as respostas certas e vai ajustando os pesos até errar menos.'),
    ('seed_ia_dificil_v2', 'O que é modelo generativo?', 'Um modelo generativo aprende os padrões dos dados e usa-os para criar dados novos parecidos, como textos, imagens ou música.'),
    ('seed_ia_dificil_v2', 'O que é reconhecimento facial baseado em IA?', 'O reconhecimento facial usa IA para identificar uma pessoa, ou confirmar quem ela é, a partir das características do rosto. Levanta questões de privacidade.'),
    ('seed_ia_dificil_v2', 'O que é F1-score?', 'O F1-score junta precisão e recall num só número (a média harmónica). É útil quando as classes estão desequilibradas e não basta olhar para a acurácia.'),
    ('seed_ia_dificil_v2', 'O que é um chatbot inteligente?', 'Um chatbot inteligente conversa com as pessoas usando IA, entende perguntas em linguagem natural e responde, em vez de apenas seguir um menu fixo.'),
    ('seed_ia_dificil_v2', 'O que é generalização em IA?', 'Generalizar é o modelo funcionar bem com dados que nunca viu, e não só com os do treino. É o que se espera de um modelo útil.'),
    ('seed_ia_dificil_v2', 'O que é ataque adversarial em IA?', 'Num ataque adversarial alguém altera ligeiramente uma entrada, por exemplo uma imagem, de modo que o modelo erre, mesmo que a mudança passe despercebida a uma pessoa.'),
    ('seed_ia_dificil_v2', 'O que é engenharia de prompts?', 'Engenharia de prompts é escrever instruções (prompts) claras e bem pensadas para o modelo, com contexto, exemplos e formato desejado, para obter respostas melhores.'),
    ('seed_ia_dificil_v2', 'O que é tokenização em modelos de linguagem?', 'Tokenização é dividir o texto em unidades menores (tokens), como palavras ou pedaços de palavras, e convertê-las em números que o modelo consegue processar.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações IA difícil lote 5: % pergunta(s) atualizada(s) (esperado: 25).', v_updated;
END $$;
