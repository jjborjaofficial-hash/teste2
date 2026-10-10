-- Explicações pedagógicas (BE-004) — IA médio lote 1: as mesmas 25 perguntas da migration 408 (linguagem simples e curta,
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
    ('seed_ia_medio_v1', 'O que é treinamento de um modelo de aprendizado de máquina?', 'Treinar um modelo é mostrar-lhe muitos exemplos para que ele ajuste os seus parâmetros internos até acertar mais. No fim, consegue aplicar o que aprendeu a casos novos.'),
    ('seed_ia_medio_v1', 'O que são dados de treinamento?', 'São os exemplos que o modelo analisa para aprender. Quanto mais variados e corretos forem, melhor ele aprende os padrões que existem neles.'),
    ('seed_ia_medio_v1', 'O que são dados de teste?', 'Os dados de teste ficam de fora do treinamento e servem para ver como o modelo se sai com exemplos novos. Se fosse avaliado com os mesmos exemplos com que aprendeu, o resultado pareceria melhor do que é.'),
    ('seed_ia_medio_v1', 'O que é overfitting?', 'Overfitting é decorar os exemplos em vez de aprender a regra. O modelo vai bem nos dados de treinamento, mas falha em dados novos, que é onde interessa que funcione.'),
    ('seed_ia_medio_v1', 'O que é generalização em aprendizado de máquina?', 'Generalizar é conseguir resolver casos que o modelo nunca viu, usando o que aprendeu. É o objetivo do treinamento: não decorar os exemplos, mas servir para situações novas.'),
    ('seed_ia_medio_v1', 'O que é classificação em aprendizado de máquina?', 'Classificar é colocar cada exemplo numa categoria, como spam ou não spam. A resposta é uma classe e não um número.'),
    ('seed_ia_medio_v1', 'Qual é um exemplo de classificação?', 'Aqui o sistema escolhe entre duas classes, spam ou não spam. Prever um preço ou uma temperatura seria regressão, porque a resposta é um número.'),
    ('seed_ia_medio_v1', 'O que é regressão em aprendizado de máquina?', 'Regressão prevê um valor numérico, como um preço ou uma temperatura, e não uma categoria. É a diferença principal em relação à classificação.'),
    ('seed_ia_medio_v1', 'Qual pode ser um exemplo de regressão?', 'O preço de um imóvel é um número que varia, por isso prevê-lo é regressão. Os outros exemplos escolhem uma categoria, o que é classificação.'),
    ('seed_ia_medio_v1', 'O que é processamento de linguagem natural?', 'O processamento de linguagem natural permite aos computadores lerem, interpretarem e produzirem linguagem humana. É a base de tradutores, assistentes e chatbots.'),
    ('seed_ia_medio_v1', 'O que é análise de sentimento?', 'A análise de sentimento lê textos, como comentários de clientes, e estima se a opinião é positiva, negativa ou neutra. Ajuda as empresas a perceber o que as pessoas pensam.'),
    ('seed_ia_medio_v1', 'O que é um dataset?', 'Um dataset é uma coleção organizada de dados, em geral em linhas e colunas, usada para treinar ou avaliar modelos. Sem datasets, o modelo não tem de onde aprender.'),
    ('seed_ia_medio_v1', 'O que é um rótulo em aprendizado supervisionado?', 'O rótulo é a resposta certa que acompanha cada exemplo, por exemplo gato numa foto de um gato. O modelo aprende comparando o que prevê com esse rótulo.'),
    ('seed_ia_medio_v1', 'O que caracteriza o aprendizado supervisionado?', 'No aprendizado supervisionado o modelo vê exemplos já com a resposta certa e aprende a relação entre os dados e essas respostas. Depois usa essa relação em casos novos.'),
    ('seed_ia_medio_v1', 'O que caracteriza o aprendizado não supervisionado?', 'No aprendizado não supervisionado não há respostas prontas: o sistema explora os dados e descobre sozinho padrões, como grupos de clientes parecidos.'),
    ('seed_ia_medio_v1', 'O que é agrupamento, ou clustering?', 'O clustering junta dados parecidos em grupos, sem que ninguém diga antes quais são os grupos. É muito usado para separar clientes com hábitos semelhantes.'),
    ('seed_ia_medio_v1', 'Por que a qualidade dos dados é importante?', 'Um modelo aprende com o que lhe dão. Se os dados tiverem erros, lacunas ou preconceitos, o modelo aprende isso também e os resultados saem piores.'),
    ('seed_ia_medio_v1', 'O que é limpeza de dados?', 'Limpar os dados é arrumar a casa antes de treinar: corrigir erros, remover repetições e tratar valores em falta. Dados limpos dão um modelo mais fiável.'),
    ('seed_ia_medio_v1', 'O que é engenharia de prompt?', 'Engenharia de prompt é escrever instruções claras para a IA, com objetivo, contexto e formato esperado. Um bom pedido costuma dar uma resposta melhor.'),
    ('seed_ia_medio_v1', 'Qual característica tende a melhorar um prompt?', 'Um bom prompt diz o que se quer, dá o contexto necessário e define o objetivo. Pedidos vagos ou contraditórios deixam o modelo a adivinhar.'),
    ('seed_ia_medio_v1', 'O que significa alucinação em IA generativa?', 'Alucinação é quando a IA inventa algo que soa convincente, como um dado, uma citação ou um facto que não existe. Soa certo mas não é, por isso importa conferir.'),
    ('seed_ia_medio_v1', 'Qual é uma forma de reduzir o risco de confiar em uma informação alucinada?', 'Como a IA pode inventar, a defesa é conferir em fontes confiáveis, sobretudo quando um erro teria consequências. Pedir ao próprio modelo que confirme não resolve, porque ele pode repetir o erro.'),
    ('seed_ia_medio_v1', 'O que é multimodalidade em IA?', 'Um modelo multimodal trabalha com mais de um tipo de informação, por exemplo entende uma foto e responde por texto. Não é o mesmo que falar vários idiomas.'),
    ('seed_ia_medio_v1', 'O que é geração de código por IA?', 'A IA pode escrever ou sugerir código de programação a partir de uma descrição em linguagem comum. Ajuda a ganhar tempo, mas o resultado deve ser lido e testado.'),
    ('seed_ia_medio_v1', 'Por que código gerado por IA deve ser revisado?', 'O código gerado pela IA pode parecer certo e ter erros, falhas de segurança ou lógica errada. Por isso deve ser lido, testado e entendido antes de ser usado a sério.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações IA médio lote 1: % pergunta(s) atualizada(s) (esperado: 25).', v_updated;
END $$;
