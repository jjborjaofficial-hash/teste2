-- Explicações pedagógicas (BE-004) — IA médio lote 2: as mesmas 25 perguntas da migration 410 (linguagem simples e curta,
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
    ('seed_ia_medio_v1', 'O que é automação inteligente?', 'Automação inteligente junta a automação, que executa tarefas sozinha, com técnicas de IA, que permitem lidar com casos variados ou apoiar decisões. É mais flexível do que seguir apenas regras fixas.'),
    ('seed_ia_medio_v1', 'O que é um modelo de linguagem?', 'Um modelo de linguagem aprendeu, a partir de muito texto, os padrões de como as palavras se combinam. Com isso consegue entender pedidos e produzir texto.'),
    ('seed_ia_medio_v1', 'O que é contexto em uma conversa com IA?', 'Contexto é a informação que você dá à IA sobre a situação, o objetivo e o que importa, para ela perceber melhor o pedido. Sem contexto, ela tem de adivinhar.'),
    ('seed_ia_medio_v1', 'Por que fornecer contexto adequado a uma IA pode melhorar a resposta?', 'Com contexto, a IA percebe o que você quer, que limites deve respeitar e em que situação está. Isso torna a resposta mais útil, mas não a dispensa de ser conferida.'),
    ('seed_ia_medio_v2', 'O que é reconhecimento de padrões?', 'Reconhecer padrões é encontrar regularidades que se repetem nos dados, como hábitos de compra ou formas numa imagem. É a base de grande parte do que a IA faz.'),
    ('seed_ia_medio_v2', 'O que é viés em IA?', 'Viés é uma tendência que empurra os resultados para o mesmo lado, muitas vezes porque os dados de treinamento eram desiguais. Pode levar a decisões injustas, por isso é preciso detetá-lo e corrigi-lo.'),
    ('seed_ia_medio_v2', 'O que é automação com IA?', 'Automação com IA é usar a IA para fazer, ou ajudar a fazer, processos sem intervenção a cada passo, como separar e-mails ou responder a perguntas frequentes. Poupa tempo em tarefas repetitivas.'),
    ('seed_ia_medio_v2', 'O que significa treinamento de um modelo?', 'Treinar é ajustar o modelo com dados, de forma que ele acerte cada vez mais. Depois do treinamento, o modelo pode ser usado em casos novos.'),
    ('seed_ia_medio_v2', 'Qual é uma preocupação importante ao utilizar IA com dados pessoais?', 'Quando uma IA usa dados pessoais, é preciso garantir que eles ficam protegidos e só são usados para o fim certo. Uma fuga de dados pode prejudicar muito as pessoas envolvidas.'),
    ('seed_ia_medio_v3', 'Qual é a principal diferença entre um sistema baseado em regras e um sistema de aprendizado de máquina?', 'Num sistema baseado em regras, uma pessoa escreve as regras. No aprendizado de máquina, o sistema descobre os padrões a partir dos dados, o que o torna mais flexível quando é difícil escrever todas as regras.'),
    ('seed_ia_medio_v3', 'Durante o treinamento de um modelo, para que serve o conjunto de validação?', 'O conjunto de validação serve para ir testando o modelo durante o desenvolvimento e decidir ajustes, como a sua configuração. O teste final fica para o fim, com dados que o modelo nunca viu.'),
    ('seed_ia_medio_v3', 'O que caracteriza o overfitting?', 'No overfitting o modelo decora os detalhes dos dados de treinamento, até o ruído, e por isso falha em dados novos. Resultados ótimos no treino e fracos fora dele são o sinal típico.'),
    ('seed_ia_medio_v3', 'Qual situação representa melhor underfitting?', 'Underfitting é quando o modelo é simples demais e não apanha os padrões importantes, por isso vai mal tanto no treinamento como em dados novos. É o oposto do overfitting.'),
    ('seed_ia_medio_v3', 'Por que separar dados de treinamento e teste é importante?', 'Se o modelo fosse avaliado com os mesmos dados que usou para aprender, pareceria melhor do que é. Separar o teste mostra como ele se comporta com exemplos novos, que é o que interessa.'),
    ('seed_ia_medio_v3', 'O que significa generalização em aprendizado de máquina?', 'Generalizar é saber lidar com dados que o modelo nunca viu, e não apenas com os que treinou. É o que mostra se ele realmente aprendeu.'),
    ('seed_ia_medio_v3', 'Um modelo apresenta 99% de precisão no treinamento e 65% em dados novos. Qual hipótese deve ser investigada primeiro?', '99% no treinamento e 65% em dados novos é a marca do overfitting: o modelo decorou os exemplos e não generalizou. É a primeira hipótese a verificar.'),
    ('seed_ia_medio_v3', 'O que é uma variável ou característica utilizada por um modelo para fazer uma previsão?', 'Uma feature, ou característica, é cada informação de entrada que o modelo usa para fazer a previsão, como a idade ou o preço. Escolher boas features ajuda muito o resultado.'),
    ('seed_ia_medio_v3', 'Num sistema que prevê o preço de uma casa usando área, localização e número de quartos, esses elementos são exemplos de:', 'Área, localização e número de quartos são as informações de entrada que o modelo usa para estimar o preço: são as features. O preço previsto é a saída.'),
    ('seed_ia_medio_v3', 'Em um problema de classificação, o que normalmente se pretende prever?', 'Na classificação a resposta é uma categoria, como spam ou não spam. Quando a resposta é um número contínuo, o problema é de regressão.'),
    ('seed_ia_medio_v3', 'Qual exemplo representa um problema de regressão?', 'O preço de uma casa é um número que pode variar de forma contínua, por isso prevê-lo é regressão. Detetar spam ou reconhecer gatos são classificações.'),
    ('seed_ia_medio_v3', 'Qual exemplo representa classificação binária?', 'A classificação binária tem só duas respostas possíveis, aqui fraude ou não fraude. Estimar um salário, um consumo ou uma temperatura dá um número, o que é regressão.'),
    ('seed_ia_medio_v3', 'O que é aprendizado supervisionado?', 'No aprendizado supervisionado cada exemplo vem com a resposta certa, e o modelo aprende a relação entre os dados e essas respostas. Serve, por exemplo, para detetar spam ou prever preços.'),
    ('seed_ia_medio_v3', 'Qual tarefa é típica do aprendizado não supervisionado?', 'No aprendizado não supervisionado não há respostas marcadas, por isso o modelo procura estrutura sozinho, como grupos de clientes parecidos. As outras tarefas usam exemplos com resposta conhecida.'),
    ('seed_ia_medio_v3', 'O que é clustering?', 'Clustering junta elementos parecidos em grupos sem precisar de rótulos. É útil para descobrir grupos naturais nos dados, como tipos de clientes.'),
    ('seed_ia_medio_v3', 'Uma empresa divide seus clientes em grupos com comportamentos semelhantes sem definir previamente os grupos. Qual técnica pode ser adequada?', 'A empresa não definiu os grupos antes, por isso é preciso descobri-los nos dados: é clustering. Classificação exigiria categorias já conhecidas e regressão preveria um número.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações IA médio lote 2: % pergunta(s) atualizada(s) (esperado: 25).', v_updated;
END $$;
