-- Explicações pedagógicas (BE-004) — IA médio lote 4: as mesmas 24 perguntas da migration 414 (linguagem simples e curta,
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
    ('seed_ia_medio_v3', 'Um modelo apresenta resultados ruins porque recebe informações irrelevantes e redundantes. Qual etapa pode ajudar?', 'Se o modelo recebe informação irrelevante ou repetida, ajuda escolher só as características que realmente contam. É a seleção de características, que simplifica o modelo e melhora os resultados.'),
    ('seed_ia_medio_v3', 'O que é redução de dimensionalidade?', 'Reduzir a dimensionalidade é ficar com menos características, mas mantendo o que importa nelas. Isso simplifica os dados e pode acelerar e melhorar o modelo.'),
    ('seed_ia_medio_v3', 'Qual pode ser uma vantagem da redução de dimensionalidade?', 'Com menos dimensões os dados ficam mais simples, o que facilita visualizá-los e treinar modelos. O cuidado é não perder informação importante.'),
    ('seed_ia_medio_v3', 'O que é inferência em inteligência artificial?', 'Inferência é usar o modelo já treinado para responder a casos novos, como quando você faz uma pergunta a um assistente. O modelo não está a aprender de novo, só a aplicar o que aprendeu.'),
    ('seed_ia_medio_v3', 'Qual é a principal diferença entre treinamento e inferência?', 'No treinamento o modelo aprende, ajustando os pesos. Na inferência já aprendeu e é usado para dar respostas. São duas fases diferentes da vida do modelo.'),
    ('seed_ia_medio_v3', 'O que significa latência em uma aplicação de IA?', 'Latência é o tempo de espera entre fazer o pedido e receber a resposta. Quanto menor, mais rápida parece a aplicação.'),
    ('seed_ia_medio_v3', 'Por que a latência é importante num chatbot?', 'Num chat, esperar muito tempo irrita e faz as pessoas desistirem. Por isso, além de a resposta ser boa, tem de chegar depressa.'),
    ('seed_ia_medio_v3', 'O que são parâmetros de um modelo?', 'Os parâmetros são os números dentro do modelo, como os pesos, que o treinamento vai ajustando. São eles que guardam o que o modelo aprendeu.'),
    ('seed_ia_medio_v3', 'Qual é uma diferença entre parâmetros e hiperparâmetros?', 'Parâmetros são aprendidos pelo modelo ao treinar, como os pesos. Hiperparâmetros, como a taxa de aprendizagem, são escolhidos por quem treina para controlar como o treinamento decorre.'),
    ('seed_ia_medio_v3', 'Qual dos seguintes é um exemplo de hiperparâmetro?', 'A taxa de aprendizagem é definida por quem treina o modelo, antes de começar, por isso é um hiperparâmetro. Os pesos, pelo contrário, são aprendidos.'),
    ('seed_ia_medio_v3', 'O que é um modelo pré-treinado?', 'Um modelo pré-treinado já aprendeu muito com um grande conjunto de dados. Depois pode ser usado tal como está ou adaptado a uma tarefa concreta.'),
    ('seed_ia_medio_v3', 'Qual é uma vantagem potencial de utilizar um modelo pré-treinado?', 'Partir de um modelo que já sabe muito poupa tempo e dinheiro, porque não é preciso treinar tudo de raiz. Ainda assim, convém avaliá-lo na tarefa concreta.'),
    ('seed_ia_medio_v3', 'O que é fine-tuning?', 'Fine-tuning é pegar num modelo já treinado e treiná-lo mais um pouco com exemplos de uma área específica. Assim ele fica melhor nesse domínio sem partir do zero.'),
    ('seed_ia_medio_v3', 'Uma empresa adapta um modelo de linguagem geral com exemplos específicos do seu setor. Isso pode ser considerado:', 'Pegar num modelo geral e treiná-lo com exemplos do seu setor é fine-tuning. Não é inferência, que é só usar o modelo, nem normalização, que é preparar os valores.'),
    ('seed_ia_medio_v3', 'O que é um token em modelos de linguagem?', 'Um token é um pedaço de texto, às vezes uma palavra, às vezes só parte dela, que o modelo usa para ler e escrever. O texto é dividido em tokens antes de ser processado.'),
    ('seed_ia_medio_v3', 'Por que a tokenização é importante em modelos de linguagem?', 'O modelo não lê letras como nós; trabalha com números. A tokenização parte o texto em unidades que podem ser convertidas e processadas.'),
    ('seed_ia_medio_v3', 'O que significa contexto em uma interação com um modelo de linguagem?', 'O contexto é tudo o que o modelo tem à vista para responder: o seu pedido, o que já foi dito e as instruções dadas. Quanto melhor o contexto, mais adequada a resposta.'),
    ('seed_ia_medio_v3', 'Um utilizador fornece objetivo, público-alvo, formato e restrições numa instrução para IA. Qual é o principal benefício?', 'Dizer o objetivo, o público, o formato e os limites dá à IA o contexto de que precisa para responder bem. Ainda é preciso rever o resultado.'),
    ('seed_ia_medio_v3', 'O que é uma alucinação em um modelo generativo?', 'Uma alucinação é uma resposta que soa convincente mas é falsa ou inventada, como uma citação que não existe. Por isso se confere o que a IA diz.'),
    ('seed_ia_medio_v3', 'Qual estratégia pode reduzir o risco de utilizar uma informação incorreta produzida por IA?', 'Como a IA pode inventar, o mais seguro é conferir as informações importantes em fontes confiáveis. Mais detalhe ou mais certeza no tom não garantem que está certo.'),
    ('seed_ia_medio_v3', 'O que é explicabilidade em IA?', 'Explicabilidade é conseguir perceber, e explicar a outras pessoas, como a IA chegou a um resultado. Sem isso, é difícil confiar nela ou encontrar os erros.'),
    ('seed_ia_medio_v3', 'Por que a explicabilidade pode ser importante em sistemas de IA usados em decisões sensíveis?', 'Em decisões que afetam pessoas, como crédito ou saúde, é preciso saber porquê. Explicar o raciocínio ajuda a descobrir erros e a justificar a decisão.'),
    ('seed_ia_medio_v4', 'O que é aprendizado de máquina (Machine Learning)?', 'No aprendizado de máquina o sistema aprende com exemplos em vez de seguir regras escritas uma a uma. Quanto melhores os dados, melhor aprende.'),
    ('seed_ia_medio_v5', 'Uma empresa utiliza IA para analisar currículos e recomendar candidatos. Por que é importante avaliar possíveis vieses nos dados utilizados pelo sistema?', 'Se os dados do passado favoreceram certos grupos, o modelo pode aprender e repetir essa injustiça, até a ampliar. Avaliar o viés evita que candidatos sejam prejudicados sem razão.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações IA médio lote 4: % pergunta(s) atualizada(s) (esperado: 24).', v_updated;
END $$;
