-- Explicações pedagógicas (BE-004) — IA difícil lote 4: as mesmas 25 perguntas da migration 426 (explicação curta e clara,
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
    ('seed_ia_dificil_v2', 'O que é automação robótica de processos (RPA)?', 'O RPA usa software, os chamados robôs de software, para executar tarefas repetitivas e baseadas em regras, como preencher formulários ou copiar dados entre sistemas. Não são robôs físicos.'),
    ('seed_ia_dificil_v2', 'Qual é a função da camada de saída?', 'A camada de saída é a última da rede: transforma o que foi calculado nas camadas anteriores na previsão ou resultado final, como a classe de uma imagem ou um valor.'),
    ('seed_ia_dificil_v2', 'O que é engenharia de dados em IA?', 'Engenharia de dados é recolher, organizar e preparar os dados para que possam ser analisados e usados por modelos. Sem dados bem preparados, a IA aprende mal.'),
    ('seed_ia_dificil_v2', 'O que é ética em Inteligência Artificial?', 'A ética em IA estuda como usar a IA de forma responsável e segura: respeitar as pessoas, evitar discriminação, proteger dados e responder pelos efeitos das decisões.'),
    ('seed_ia_dificil_v2', 'O que são redes neurais convolucionais (CNNs)?', 'As CNNs usam filtros que percorrem a imagem e detetam padrões visuais, como bordas, formas e texturas. Por isso são muito usadas em reconhecimento de imagens.'),
    ('seed_ia_dificil_v2', 'O que é segurança de modelos de IA?', 'Segurança de modelos é protegê-los contra manipulação, ataques (como dados envenenados ou entradas feitas para os enganar) e uso indevido.'),
    ('seed_ia_dificil_v2', 'O que é privacidade de dados em IA?', 'Privacidade de dados em IA é proteger as informações pessoais usadas pelos sistemas, garantindo que são usadas só para o fim combinado e que não chegam a quem não deve.'),
    ('seed_ia_dificil_v2', 'O que é mecanismo de atenção em IA?', 'O mecanismo de atenção deixa o modelo dar mais peso às partes mais relevantes da entrada ao produzir cada resultado, como as palavras mais importantes de uma frase.'),
    ('seed_ia_dificil_v2', 'O que é transparência em IA?', 'Transparência é conseguir perceber como e por que um sistema de IA chega às suas decisões: que dados usa, que regras segue e quais os seus limites.'),
    ('seed_ia_dificil_v2', 'Qual é um desafio dos grandes modelos de IA?', 'Os grandes modelos exigem muito poder de computação, energia e enormes quantidades de dados para serem treinados e usados, o que os torna caros.'),
    ('seed_ia_dificil_v2', 'O que é um agente inteligente?', 'Um agente inteligente observa o ambiente (por sensores ou dados), decide e age para alcançar um objetivo, como um robô aspirador ou um assistente virtual.'),
    ('seed_ia_dificil_v2', 'O que são redes neurais recorrentes (RNNs)?', 'As RNNs têm ligações que devolvem informação aos passos seguintes, o que lhes dá uma espécie de memória. Servem para dados em sequência, como texto, áudio ou séries temporais.'),
    ('seed_ia_dificil_v2', 'O que é AGI?', 'AGI significa Inteligência Artificial Geral: uma IA hipotética capaz de realizar muitas tarefas intelectuais como uma pessoa. Ainda não existe.'),
    ('seed_ia_dificil_v2', 'O que é um algoritmo de Machine Learning?', 'Um algoritmo de machine learning é um método que permite à máquina aprender padrões a partir de dados, em vez de ser programada com regras escritas à mão.'),
    ('seed_ia_dificil_v2', 'O que é embedding em IA?', 'Um embedding é a representação de uma palavra, imagem ou outro dado como uma lista de números. Itens com significado parecido ficam com números parecidos.'),
    ('seed_ia_dificil_v2', 'O que é viés algorítmico?', 'Viés algorítmico é quando o sistema dá resultados injustos para certas pessoas ou grupos, porque aprendeu padrões inadequados dos dados ou foi mal desenhado.'),
    ('seed_ia_dificil_v2', 'O que é detecção de objetos?', 'Na detecção de objetos o modelo diz o que há na imagem e onde está, normalmente desenhando caixas à volta de cada objeto. Serve, por exemplo, em câmaras de segurança e em carros autónomos.'),
    ('seed_ia_dificil_v2', 'O que é uma rede neural profunda?', 'Uma rede neural profunda tem várias camadas entre a entrada e a saída. Cada camada aprende uma parte do problema, das mais simples às mais abstratas.'),
    ('seed_ia_dificil_v2', 'Qual é o principal objetivo do desenvolvimento responsável de Inteligência Artificial?', 'O objetivo é que a IA traga benefício à sociedade: sistemas úteis, seguros, éticos e confiáveis, que respeitem as pessoas e possam ser responsabilizados.'),
    ('seed_ia_dificil_v2', 'O que é copiloto de IA?', 'Um copiloto de IA é um assistente que trabalha ao lado do utilizador e ajuda em tarefas concretas, como escrever, resumir ou programar, mas quem decide é a pessoa.'),
    ('seed_ia_dificil_v2', 'Por que dados de qualidade são importantes para IA?', 'A IA aprende com os dados. Se forem errados, incompletos ou enviesados, o modelo aprende padrões errados. Dados bons dão melhores resultados.'),
    ('seed_ia_dificil_v2', 'O que é MLOps?', 'MLOps junta práticas de machine learning e de operações: desenvolver, implementar e manter os modelos em produção, com monitorização e atualizações, para que continuem a funcionar bem.'),
    ('seed_ia_dificil_v2', 'O que são GANs (Generative Adversarial Networks)?', 'Numa GAN há duas redes que competem: o gerador cria dados falsos e o discriminador tenta distinguir o falso do real. Com o treino, o gerador passa a criar dados cada vez mais realistas.'),
    ('seed_ia_dificil_v2', 'O que é backpropagation?', 'O backpropagation calcula o erro da saída e propaga-o para trás pela rede, para saber quanto cada peso contribuiu e ajustá-lo. É assim que as redes neurais aprendem.'),
    ('seed_ia_dificil_v2', 'O que é inferência em tempo real?', 'Inferência em tempo real é o modelo já treinado responder logo que recebe a entrada, em milissegundos ou segundos, como um assistente de voz ou a deteção de fraude num pagamento.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações IA difícil lote 4: % pergunta(s) atualizada(s) (esperado: 25).', v_updated;
END $$;
