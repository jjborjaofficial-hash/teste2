-- Explicações pedagógicas (BE-004) — IA fácil lote 4: as mesmas 24 perguntas da migration 406 (linguagem simples e curta,
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
    ('seed_ia_facil_v3', 'Qual afirmação sobre IA é mais adequada?', 'A IA ajuda muito, mas pode errar. Por isso os resultados devem ser lidos com espírito crítico e conferidos quando o assunto é importante.'),
    ('seed_ia_facil_v3', 'Por que a supervisão humana pode ser importante?', 'Uma pessoa a acompanhar o trabalho da IA consegue notar erros, riscos e decisões que não fazem sentido antes de causarem problemas. A IA é mais segura quando alguém a vigia.'),
    ('seed_ia_facil_v3', 'Qual destas informações pode ser considerada pessoal?', 'Um número de telefone identifica uma pessoa e permite contactá-la, por isso é um dado pessoal. A data de um feriado, a temperatura de uma cidade ou o nome de um país não dizem quem é alguém.'),
    ('seed_ia_facil_v3', 'Uma pessoa usa IA para escrever um trabalho escolar. Qual é uma boa prática?', 'A IA pode ajudar, mas o trabalho continua a ser seu. Ler, perceber e conferir o texto garante que está certo e que você aprendeu o assunto.'),
    ('seed_ia_facil_v3', 'Qual é uma limitação comum dos sistemas de IA?', 'Os sistemas de IA podem dar respostas erradas ou inventadas, mesmo quando parecem seguros. Essa é uma das suas limitações mais conhecidas.'),
    ('seed_ia_facil_v3', 'O que significa supervisionar uma IA?', 'Supervisionar é observar como a IA trabalha e avaliar se os resultados estão bons. Não é desligá-la nem apagar o que ela usa.'),
    ('seed_ia_facil_v3', 'Por que dados pessoais exigem cuidado ao utilizar sistemas de IA?', 'Dados pessoais, como nome, telefone ou fotografias, podem revelar quem você é. Se forem colocados num sistema de IA sem cuidado, essa informação pode ser mal usada.'),
    ('seed_ia_facil_v3', 'Qual é uma forma responsável de começar a utilizar uma ferramenta de IA?', 'Antes de usar uma ferramenta de IA, convém saber para que serve, o que ela não faz bem e que regras tem. Assim você a usa com mais segurança e melhores resultados.'),
    ('seed_ia_facil_v3', 'Qual é uma vantagem de utilizar IA como ferramenta de apoio?', 'Como ferramenta de apoio, a IA faz depressa partes repetitivas de uma tarefa, como resumir ou organizar. Quem decide e confere continua a ser você.'),
    ('seed_ia_facil_v4', 'Um aplicativo que sugere músicas de acordo com o histórico de escuta está utilizando principalmente:', 'Um sistema de recomendação olha para o que você já ouviu e sugere músicas parecidas. É o mesmo princípio das lojas online e dos serviços de vídeo.'),
    ('seed_ia_facil_v4', 'Qual é uma limitação importante dos sistemas de IA?', 'A IA pode errar, inventar ou dar respostas inadequadas. Por isso os resultados importantes devem ser conferidos antes de serem usados.'),
    ('seed_ia_facil_v4', 'Por que os dados são importantes para muitos sistemas de inteligência artificial?', 'Muitos sistemas de IA aprendem com exemplos. Quanto melhores forem os dados, melhor o sistema reconhece padrões e melhora os seus resultados.'),
    ('seed_ia_facil_v4', 'Qual tecnologia é frequentemente utilizada para identificar objetos em fotografias?', 'A visão computacional ensina o computador a olhar para imagens e reconhecer o que nelas aparece, como pessoas, objetos ou letras. É a tecnologia por trás da identificação de objetos em fotografias.'),
    ('seed_ia_facil_v4', 'Qual atitude é recomendada ao utilizar uma ferramenta de IA para obter informações importantes?', 'Uma resposta bem escrita não é, só por isso, uma resposta certa. Quando a informação é importante, confira-a em fontes confiáveis antes de a usar.'),
    ('seed_ia_facil_v4', 'Qual destas tarefas pode ser realizada por uma IA generativa?', 'Uma IA generativa cria conteúdos novos, como textos ou imagens, a partir do que você pede. Ela trabalha com informação e não repara aparelhos.'),
    ('seed_ia_facil_v4', 'Para que serve o reconhecimento de voz?', 'O reconhecimento de voz ouve o que você diz e converte em dados que o sistema entende. É assim que um assistente virtual percebe os seus comandos.'),
    ('seed_ia_facil_v4', 'O que pode fazer um sistema de recomendação?', 'Um sistema de recomendação usa o que sabe sobre você e o seu comportamento para sugerir conteúdos ou produtos que provavelmente lhe interessam.'),
    ('seed_ia_facil_v4', 'Qual destes é um exemplo comum de inteligência artificial no dia a dia?', 'Um assistente virtual percebe o que você diz e responde, por isso usa IA. Cabos, tomadas e calculadoras simples só executam funções fixas, sem aprender nada.'),
    ('seed_ia_facil_v5', 'Para que modelos de IA precisam de dados durante o treinamento?', 'Durante o treinamento, o modelo olha para muitos exemplos e vai aprendendo padrões e relações entre eles. Sem dados não há de onde aprender.'),
    ('seed_ia_facil_v5', 'Qual é um exemplo de aplicação de Inteligência Artificial?', 'Os assistentes virtuais entendem pedidos e respondem, e por isso são uma aplicação de IA. Papel, tomadas e cadeiras são objetos comuns que não aprendem.'),
    ('seed_ia_facil_v6', 'Qual é uma utilização comum da inteligência artificial no atendimento ao cliente?', 'Muitos clientes fazem as mesmas perguntas. A IA responde-lhes sozinha e a qualquer hora, e a equipa fica livre para os casos mais difíceis.'),
    ('seed_ia_facil_v6', 'O que pode acontecer quando um sistema de IA recebe dados de baixa qualidade?', 'A IA aprende com os dados que recebe. Se os dados forem fracos ou errados, os resultados também ficam piores, como um aluno que estuda por um livro com erros.'),
    ('seed_ia_facil_v7', 'O que é um filtro de spam baseado em IA?', 'O filtro aprende que características têm as mensagens indesejadas e passa a bloqueá-las. Por isso o seu e-mail separa o spam sem você ter de o fazer.'),
    ('seed_ia_facil_v7', 'O que é síntese de voz?', 'A síntese de voz lê um texto em voz alta, como quando um assistente responde falando. Faz o caminho contrário ao do reconhecimento de voz.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações IA fácil lote 4: % pergunta(s) atualizada(s) (esperado: 24).', v_updated;
END $$;
