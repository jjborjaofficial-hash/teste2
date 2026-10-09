-- Alternativas (BE-003, regularização) — IA fácil lote 4: as 24 perguntas ativas de IA fácil que ainda não tinham explicação
-- (seed v3 48 a 56, v4 inteiro, v5, v6 e v7). Segue docs/quiz-v2-alternativas-padrao.md e a regra do dono (2026-10-07): a resposta
-- CERTA NÃO muda; só o texto das alternativas ERRADAS é ajustado (tamanho e forma parecidos com os da certa, distratores plausíveis,
-- sem absolutos só nas erradas).
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
    ('seed_ia_facil_v3', 'Qual afirmação sobre IA é mais adequada?', 0, 'IA é sempre correta', 'IA é uma ferramenta confiável e, por isso, os seus resultados podem ser usados sem revisão'),
    ('seed_ia_facil_v3', 'Qual afirmação sobre IA é mais adequada?', 2, 'IA não precisa de dados', 'IA depende de muitos dados, por isso os resultados são definitivos'),
    ('seed_ia_facil_v3', 'Qual afirmação sobre IA é mais adequada?', 3, 'IA nunca comete erros', 'IA pode ser útil e, por isso, os seus resultados dispensam revisão'),
    ('seed_ia_facil_v3', 'Por que a supervisão humana pode ser importante?', 1, 'Porque IA nunca pode executar tarefas', 'Porque a IA ainda não consegue executar tarefas simples'),
    ('seed_ia_facil_v3', 'Por que a supervisão humana pode ser importante?', 2, 'Para impedir toda automação', 'Para reduzir o uso de automação nas tarefas do dia a dia'),
    ('seed_ia_facil_v3', 'Por que a supervisão humana pode ser importante?', 3, 'Para substituir todos os algoritmos', 'Para trocar os algoritmos por regras escritas à mão'),
    ('seed_ia_facil_v3', 'Qual destas informações pode ser considerada pessoal?', 0, 'Data de um feriado público', 'Data de um feriado'),
    ('seed_ia_facil_v3', 'Qual destas informações pode ser considerada pessoal?', 1, 'Temperatura média de uma cidade', 'Temperatura de uma cidade'),
    ('seed_ia_facil_v3', 'Uma pessoa usa IA para escrever um trabalho escolar. Qual é uma boa prática?', 1, 'Considerar todas as respostas automaticamente verdadeiras', 'Copiar o texto gerado e confiar que a IA acertou nos factos'),
    ('seed_ia_facil_v3', 'Uma pessoa usa IA para escrever um trabalho escolar. Qual é uma boa prática?', 2, 'Entregar sem ler', 'Entregar o trabalho logo, sem ler o texto gerado'),
    ('seed_ia_facil_v3', 'Uma pessoa usa IA para escrever um trabalho escolar. Qual é uma boa prática?', 3, 'Esconder qualquer utilização da ferramenta sempre', 'Esconder do professor que a ferramenta foi utilizada'),
    ('seed_ia_facil_v3', 'Qual é uma limitação comum dos sistemas de IA?', 0, 'Não utilizam modelos', 'Precisam de modelos novos a cada resposta'),
    ('seed_ia_facil_v3', 'Qual é uma limitação comum dos sistemas de IA?', 1, 'Nunca conseguem processar dados', 'Têm dificuldade em guardar os dados'),
    ('seed_ia_facil_v3', 'Qual é uma limitação comum dos sistemas de IA?', 3, 'Não conseguem receber entradas', 'Têm dificuldade em receber instruções'),
    ('seed_ia_facil_v3', 'O que significa supervisionar uma IA?', 0, 'Remover todos os dados', 'Apagar os dados usados para treinar o sistema'),
    ('seed_ia_facil_v3', 'O que significa supervisionar uma IA?', 1, 'Impedir qualquer atualização', 'Bloquear as atualizações do sistema para o manter igual'),
    ('seed_ia_facil_v3', 'O que significa supervisionar uma IA?', 3, 'Desligar o sistema permanentemente', 'Desligar o sistema depois de cada uso'),
    ('seed_ia_facil_v3', 'Por que dados pessoais exigem cuidado ao utilizar sistemas de IA?', 0, 'São sempre públicos', 'Podem ocupar muito espaço no armazenamento do sistema'),
    ('seed_ia_facil_v3', 'Por que dados pessoais exigem cuidado ao utilizar sistemas de IA?', 2, 'Não possuem qualquer valor', 'Podem tornar o sistema mais lento durante o treino'),
    ('seed_ia_facil_v3', 'Por que dados pessoais exigem cuidado ao utilizar sistemas de IA?', 3, 'Nunca podem ser armazenados', 'Podem ser apagados pelo sistema sem aviso prévio'),
    ('seed_ia_facil_v3', 'Qual é uma forma responsável de começar a utilizar uma ferramenta de IA?', 0, 'Fornecer imediatamente todas as informações pessoais', 'Fornecer os dados pessoais logo no primeiro acesso para receber melhores respostas'),
    ('seed_ia_facil_v3', 'Qual é uma forma responsável de começar a utilizar uma ferramenta de IA?', 1, 'Aceitar qualquer resultado sem verificar', 'Aceitar os primeiros resultados sem os comparar com outros'),
    ('seed_ia_facil_v3', 'Qual é uma forma responsável de começar a utilizar uma ferramenta de IA?', 2, 'Utilizá-la para qualquer finalidade sem considerar riscos', 'Usá-la para tarefas importantes sem ler as regras de uso'),
    ('seed_ia_facil_v3', 'Qual é uma vantagem de utilizar IA como ferramenta de apoio?', 0, 'Garante que todas as decisões serão perfeitas', 'Pode dispensar a revisão dos resultados'),
    ('seed_ia_facil_v3', 'Qual é uma vantagem de utilizar IA como ferramenta de apoio?', 1, 'Impede aprendizagem', 'Pode reduzir o esforço de aprender'),
    ('seed_ia_facil_v3', 'Qual é uma vantagem de utilizar IA como ferramenta de apoio?', 2, 'Elimina a necessidade de conhecimento humano', 'Pode dispensar o conhecimento das pessoas'),
    ('seed_ia_facil_v4', 'Um aplicativo que sugere músicas de acordo com o histórico de escuta está utilizando principalmente:', 1, 'Editor de código', 'Editor de código-fonte'),
    ('seed_ia_facil_v4', 'Um aplicativo que sugere músicas de acordo com o histórico de escuta está utilizando principalmente:', 2, 'Sistema de impressão', 'Sistema de impressão remota'),
    ('seed_ia_facil_v4', 'Um aplicativo que sugere músicas de acordo com o histórico de escuta está utilizando principalmente:', 3, 'Firewall', 'Gestor de ficheiros'),
    ('seed_ia_facil_v4', 'Qual é uma limitação importante dos sistemas de IA?', 1, 'Funcionam apenas em computadores antigos', 'Exigem computadores muito antigos para funcionar'),
    ('seed_ia_facil_v4', 'Qual é uma limitação importante dos sistemas de IA?', 2, 'Nunca conseguem processar textos', 'Têm dificuldade em processar textos curtos'),
    ('seed_ia_facil_v4', 'Qual é uma limitação importante dos sistemas de IA?', 3, 'Não podem utilizar dados', 'Têm dificuldade em utilizar dados recebidos há pouco tempo'),
    ('seed_ia_facil_v4', 'Por que os dados são importantes para muitos sistemas de inteligência artificial?', 0, 'Substituem automaticamente o hardware', 'Servem para aumentar a velocidade física do processador durante o uso diário'),
    ('seed_ia_facil_v4', 'Por que os dados são importantes para muitos sistemas de inteligência artificial?', 1, 'Servem apenas para ocupar espaço no armazenamento', 'Servem para guardar o histórico de utilização do aparelho e proteger o sistema'),
    ('seed_ia_facil_v4', 'Por que os dados são importantes para muitos sistemas de inteligência artificial?', 3, 'Impedem qualquer tipo de aprendizagem', 'Servem para reduzir o consumo de energia do computador durante o treinamento'),
    ('seed_ia_facil_v4', 'Qual atitude é recomendada ao utilizar uma ferramenta de IA para obter informações importantes?', 0, 'Compartilhar todas as informações pessoais', 'Partilhar dados pessoais para melhorar as respostas'),
    ('seed_ia_facil_v4', 'Qual atitude é recomendada ao utilizar uma ferramenta de IA para obter informações importantes?', 2, 'Aceitar todas as respostas sem questionar', 'Aceitar as respostas que parecem bem escritas'),
    ('seed_ia_facil_v4', 'Qual atitude é recomendada ao utilizar uma ferramenta de IA para obter informações importantes?', 3, 'Ignorar possíveis erros', 'Ignorar os avisos de possíveis erros no resultado'),
    ('seed_ia_facil_v4', 'Qual destas tarefas pode ser realizada por uma IA generativa?', 0, 'Reparar uma tela quebrada', 'Reparar uma tela quebrada com um comando'),
    ('seed_ia_facil_v4', 'Qual destas tarefas pode ser realizada por uma IA generativa?', 2, 'Trocar fisicamente uma bateria', 'Trocar a bateria de um telemóvel avariado'),
    ('seed_ia_facil_v4', 'Para que serve o reconhecimento de voz?', 0, 'Criar automaticamente componentes físicos', 'Criar componentes físicos para o computador a partir de ordens escritas'),
    ('seed_ia_facil_v4', 'Para que serve o reconhecimento de voz?', 1, 'Aumentar a capacidade da bateria', 'Aumentar a duração da bateria quando o aparelho recebe ordens por voz'),
    ('seed_ia_facil_v4', 'Para que serve o reconhecimento de voz?', 2, 'Melhorar a velocidade da internet', 'Melhorar a velocidade da ligação à internet em chamadas de voz'),
    ('seed_ia_facil_v4', 'O que pode fazer um sistema de recomendação?', 0, 'Substituir uma ligação à internet', 'Substituir a ligação à internet quando a rede está lenta ou instável durante o dia'),
    ('seed_ia_facil_v4', 'O que pode fazer um sistema de recomendação?', 1, 'Aumentar a memória RAM', 'Aumentar a memória RAM do aparelho quando há muitos conteúdos abertos'),
    ('seed_ia_facil_v4', 'O que pode fazer um sistema de recomendação?', 2, 'Reparar fisicamente um computador', 'Reparar fisicamente o computador quando os produtos falham ao carregar'),
    ('seed_ia_facil_v4', 'Qual destes é um exemplo comum de inteligência artificial no dia a dia?', 0, 'Um cabo USB', 'Um carregador de telemóvel com ficha de três pinos'),
    ('seed_ia_facil_v4', 'Qual destes é um exemplo comum de inteligência artificial no dia a dia?', 1, 'Uma tomada elétrica', 'Uma tomada elétrica com interruptor embutido na parede'),
    ('seed_ia_facil_v4', 'Qual destes é um exemplo comum de inteligência artificial no dia a dia?', 3, 'Uma calculadora simples', 'Uma calculadora simples de bolso com painel solar'),
    ('seed_ia_facil_v5', 'Para que modelos de IA precisam de dados durante o treinamento?', 0, 'Para aumentar o tamanho físico do computador', 'Para aumentar o espaço do disco'),
    ('seed_ia_facil_v5', 'Para que modelos de IA precisam de dados durante o treinamento?', 1, 'Para substituir a eletricidade', 'Para reduzir o consumo de energia'),
    ('seed_ia_facil_v5', 'Para que modelos de IA precisam de dados durante o treinamento?', 3, 'Para desligar o sistema', 'Para proteger o sistema de vírus'),
    ('seed_ia_facil_v5', 'Qual é um exemplo de aplicação de Inteligência Artificial?', 0, 'Uma folha de papel', 'Folhas de papel'),
    ('seed_ia_facil_v5', 'Qual é um exemplo de aplicação de Inteligência Artificial?', 1, 'Uma tomada elétrica comum', 'Tomadas elétricas comuns'),
    ('seed_ia_facil_v5', 'Qual é um exemplo de aplicação de Inteligência Artificial?', 2, 'Uma cadeira', 'Cadeiras de escritório'),
    ('seed_ia_facil_v6', 'Qual é uma utilização comum da inteligência artificial no atendimento ao cliente?', 0, 'Substituir fisicamente os computadores', 'Trocar os computadores do balcão de atendimento'),
    ('seed_ia_facil_v6', 'Qual é uma utilização comum da inteligência artificial no atendimento ao cliente?', 3, 'Fabricar cabos de rede', 'Fabricar cabos de rede para os escritórios'),
    ('seed_ia_facil_v6', 'O que pode acontecer quando um sistema de IA recebe dados de baixa qualidade?', 1, 'O modelo deixa de precisar de treinamento', 'O modelo passa a precisar de menos treinamento'),
    ('seed_ia_facil_v6', 'O que pode acontecer quando um sistema de IA recebe dados de baixa qualidade?', 2, 'Todos os erros são corrigidos automaticamente', 'Os erros desaparecem quando o modelo é usado mais vezes'),
    ('seed_ia_facil_v7', 'O que é um filtro de spam baseado em IA?', 0, 'Um antivírus físico', 'Um programa que analisa os ficheiros do computador e apaga os vírus encontrados no disco'),
    ('seed_ia_facil_v7', 'O que é um filtro de spam baseado em IA?', 2, 'Um tipo de teclado inteligente', 'Um sistema que corrige automaticamente a escrita das mensagens antes de serem enviadas'),
    ('seed_ia_facil_v7', 'O que é um filtro de spam baseado em IA?', 3, 'Um cabo de rede especial', 'Um equipamento ligado à rede que aumenta a velocidade da internet na casa ou no escritório'),
    ('seed_ia_facil_v7', 'O que é síntese de voz?', 0, 'Um tipo de vírus de computador', 'Tecnologia que converte fala em texto escrito'),
    ('seed_ia_facil_v7', 'O que é síntese de voz?', 1, 'Um sistema de armazenamento de áudio', 'Tecnologia que guarda gravações de áudio'),
    ('seed_ia_facil_v7', 'O que é síntese de voz?', 2, 'Um cabo de conexão para microfones', 'Tecnologia que liga microfones ao computador')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas IA fácil lote 4: % alternativa(s) errada(s) atualizada(s) (esperado: 65).', v_updated;
END $$;
