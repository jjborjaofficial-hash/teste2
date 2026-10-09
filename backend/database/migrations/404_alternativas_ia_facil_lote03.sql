-- Alternativas (BE-003, regularização) — IA fácil lote 3: as perguntas 23 a 47 do seed v3 (migration 076; as 22 primeiras foram no lote 2).
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
    ('seed_ia_facil_v3', 'O que é um erro ou informação incorreta produzida por uma IA?', 0, 'Uma atualização do sistema', 'Uma atualização que muda o aspeto do programa usado'),
    ('seed_ia_facil_v3', 'O que é um erro ou informação incorreta produzida por uma IA?', 1, 'Uma melhoria automática', 'Uma melhoria que acelera o processamento dos dados'),
    ('seed_ia_facil_v3', 'O que é um erro ou informação incorreta produzida por uma IA?', 3, 'Um tipo de hardware', 'Uma falha física no equipamento do próprio utilizador'),
    ('seed_ia_facil_v3', 'Por que uma resposta de IA pode precisar de verificação?', 0, 'Porque IA nunca consegue produzir texto', 'Porque o servidor pode apagar a resposta depois'),
    ('seed_ia_facil_v3', 'Por que uma resposta de IA pode precisar de verificação?', 1, 'Porque modelos não utilizam dados', 'Porque os modelos copiam respostas de outros usuários'),
    ('seed_ia_facil_v3', 'Por que uma resposta de IA pode precisar de verificação?', 3, 'Porque toda resposta é necessariamente falsa', 'Porque o sistema altera as palavras ao enviar a resposta'),
    ('seed_ia_facil_v3', 'Qual área utiliza IA para recomendar produtos aos clientes?', 0, 'Agricultura manual exclusivamente', 'Agricultura manual'),
    ('seed_ia_facil_v3', 'Qual área utiliza IA para recomendar produtos aos clientes?', 2, 'Construção civil exclusivamente', 'Construção civil'),
    ('seed_ia_facil_v3', 'Qual área utiliza IA para recomendar produtos aos clientes?', 3, 'Impressão tradicional', 'Impressão tradicional'),
    ('seed_ia_facil_v3', 'Como a IA pode ajudar no atendimento ao cliente?', 0, 'Impedindo perguntas', 'Imprimindo automaticamente as faturas dos clientes'),
    ('seed_ia_facil_v3', 'Como a IA pode ajudar no atendimento ao cliente?', 2, 'Eliminando todos os clientes', 'Alterando automaticamente os preços dos produtos'),
    ('seed_ia_facil_v3', 'Como a IA pode ajudar no atendimento ao cliente?', 3, 'Desligando os canais de comunicação', 'Desligando automaticamente os canais de contacto'),
    ('seed_ia_facil_v3', 'Qual destes é um exemplo de processamento de linguagem natural?', 1, 'Aumento da resolução física de um monitor', 'Aumento da resolução do monitor'),
    ('seed_ia_facil_v3', 'Qual destes é um exemplo de processamento de linguagem natural?', 2, 'Carregamento de bateria', 'Carregamento rápido de bateria'),
    ('seed_ia_facil_v3', 'Qual destes é um exemplo de processamento de linguagem natural?', 3, 'Impressão de fotografias', 'Impressão de fotos em papel'),
    ('seed_ia_facil_v3', 'Qual é uma utilização da IA em tradução?', 0, 'Aumentar a velocidade da internet', 'Aumentar a velocidade da ligação à internet'),
    ('seed_ia_facil_v3', 'Qual é uma utilização da IA em tradução?', 1, 'Criar energia', 'Gerar energia para os aparelhos ligados'),
    ('seed_ia_facil_v3', 'Qual é uma utilização da IA em tradução?', 2, 'Reparar cabos', 'Reparar ligações de rede danificadas'),
    ('seed_ia_facil_v3', 'O que é uma recomendação personalizada?', 0, 'Uma sugestão completamente aleatória', 'Uma sugestão sorteada ao acaso entre várias opções do catálogo'),
    ('seed_ia_facil_v3', 'O que é uma recomendação personalizada?', 1, 'Um tipo de arquivo', 'Um aviso igual enviado ao mesmo tempo a vários utilizadores'),
    ('seed_ia_facil_v3', 'O que é uma recomendação personalizada?', 3, 'Um comando de hardware', 'Uma ordem enviada ao equipamento para ajustar o seu funcionamento interno'),
    ('seed_ia_facil_v3', 'O que é um robô?', 0, 'Um navegador', 'Uma aplicação capaz de abrir páginas e guardar favoritos'),
    ('seed_ia_facil_v3', 'O que é um robô?', 1, 'Um documento digital', 'Uma pasta digital capaz de guardar textos, imagens e vídeos'),
    ('seed_ia_facil_v3', 'O que é um robô?', 3, 'Um tipo de banco de dados', 'Uma base de dados capaz de guardar registos organizados'),
    ('seed_ia_facil_v3', 'Todos os robôs utilizam inteligência artificial?', 1, 'Sim, obrigatoriamente', 'Sim, os robôs aprendem a funcionar por conta própria'),
    ('seed_ia_facil_v3', 'Todos os robôs utilizam inteligência artificial?', 2, 'Apenas robôs industriais', 'Sim, a IA é o que permite ao robô mover as suas peças'),
    ('seed_ia_facil_v3', 'Todos os robôs utilizam inteligência artificial?', 3, 'Apenas robôs domésticos', 'Não, os robôs industriais podem usar IA mas os domésticos não podem'),
    ('seed_ia_facil_v3', 'Qual é a relação entre robótica e IA?', 0, 'Robótica não utiliza computadores', 'A robótica reúne peças mecânicas, motores ou sensores, mas não precisa de programas'),
    ('seed_ia_facil_v3', 'Qual é a relação entre robótica e IA?', 2, 'IA só funciona em máquinas físicas', 'A IA pode fornecer energia, movimento ou força mecânica a determinados robôs'),
    ('seed_ia_facil_v3', 'Qual é a relação entre robótica e IA?', 3, 'São exatamente a mesma coisa', 'A robótica pode substituir a IA, os dados e os algoritmos em determinados sistemas'),
    ('seed_ia_facil_v3', 'O que é um dado de entrada para uma IA?', 0, 'Cabo de energia', 'Peça física ligada ao sistema para o seu funcionamento'),
    ('seed_ia_facil_v3', 'O que é um dado de entrada para uma IA?', 2, 'Monitor', 'Programa instalado no sistema para a sua atualização'),
    ('seed_ia_facil_v3', 'O que é um dado de entrada para uma IA?', 3, 'Resultado produzido pelo sistema', 'Resultado devolvido ao utilizador pelo sistema'),
    ('seed_ia_facil_v3', 'O que é uma saída de um sistema de IA?', 0, 'Energia elétrica', 'Informação fornecida ao sistema antes do processamento'),
    ('seed_ia_facil_v3', 'O que é uma saída de um sistema de IA?', 1, 'Cabo de rede', 'Comando físico usado para ligar e desligar o sistema'),
    ('seed_ia_facil_v3', 'O que é uma saída de um sistema de IA?', 2, 'Teclado', 'Programa instalado no sistema para novas funções'),
    ('seed_ia_facil_v3', 'Qual é um exemplo de entrada para um chatbot?', 0, 'Uma impressora', 'Uma resposta escrita pelo chatbot'),
    ('seed_ia_facil_v3', 'Qual é um exemplo de entrada para um chatbot?', 1, 'Um cabo USB', 'Um cabo USB ligado ao computador'),
    ('seed_ia_facil_v3', 'Qual é um exemplo de entrada para um chatbot?', 2, 'Uma bateria', 'Uma bateria carregada pelo utilizador'),
    ('seed_ia_facil_v3', 'O que significa personalização por IA?', 0, 'Aumentar a velocidade do computador', 'Aumentar a velocidade e a memória do computador usado pelo utilizador'),
    ('seed_ia_facil_v3', 'O que significa personalização por IA?', 1, 'Criar uma conta automaticamente', 'Criar contas e perfis automaticamente para novos utilizadores do sistema'),
    ('seed_ia_facil_v3', 'O que significa personalização por IA?', 3, 'Eliminar dados pessoais', 'Eliminar dados pessoais e históricos de navegação guardados no sistema operativo'),
    ('seed_ia_facil_v3', 'Qual é um benefício potencial da personalização?', 1, 'Garantir que todos recebem exatamente o mesmo conteúdo', 'Apresentar conteúdos iguais e repetidos a cada utilizador'),
    ('seed_ia_facil_v3', 'Qual é um benefício potencial da personalização?', 2, 'Eliminar recomendações', 'Reduzir o número de opções disponíveis para cada utilizador'),
    ('seed_ia_facil_v3', 'Qual é um benefício potencial da personalização?', 3, 'Impedir escolhas', 'Impedir que o utilizador escolha conteúdos diferentes'),
    ('seed_ia_facil_v3', 'O que é um sistema de detecção de fraude baseado em IA?', 0, 'Sistema de impressão', 'Sistema que organiza ficheiros associados a possíveis cópias de segurança'),
    ('seed_ia_facil_v3', 'O que é um sistema de detecção de fraude baseado em IA?', 1, 'Programa para criar documentos', 'Sistema que cria documentos associados a possíveis pedidos de clientes'),
    ('seed_ia_facil_v3', 'O que é um sistema de detecção de fraude baseado em IA?', 3, 'Sistema que garante que nenhuma fraude existe', 'Sistema que imprime relatórios associados a possíveis reuniões de trabalho'),
    ('seed_ia_facil_v3', 'Por que a IA pode ser útil na detecção de fraude?', 0, 'Porque nunca produz falsos positivos', 'Pode apagar grandes quantidades de transações e ocultar registos antigos de clientes'),
    ('seed_ia_facil_v3', 'Por que a IA pode ser útil na detecção de fraude?', 2, 'Porque elimina a necessidade de dados', 'Pode substituir grandes quantidades de dados por decisões automáticas'),
    ('seed_ia_facil_v3', 'Por que a IA pode ser útil na detecção de fraude?', 3, 'Porque sabe automaticamente a intenção de todas as pessoas', 'Pode adivinhar a intenção de cada pessoa e confirmar fraudes sem erros'),
    ('seed_ia_facil_v3', 'O que é um viés em um sistema de IA?', 0, 'Uma peça do computador', 'Uma falha elétrica que pode danificar o equipamento'),
    ('seed_ia_facil_v3', 'O que é um viés em um sistema de IA?', 1, 'Uma atualização de software', 'Uma atualização que pode alterar o aspeto do programa'),
    ('seed_ia_facil_v3', 'O que é um viés em um sistema de IA?', 3, 'Uma conexão de internet', 'Uma ligação à rede que pode ficar lenta durante o horário de pico'),
    ('seed_ia_facil_v3', 'De onde pode surgir viés em IA?', 0, 'Apenas da bateria', 'Dos cabos usados ou da forma como o computador foi ligado'),
    ('seed_ia_facil_v3', 'De onde pode surgir viés em IA?', 1, 'Apenas da velocidade da internet', 'Da velocidade da internet ou do tipo de ecrã utilizado'),
    ('seed_ia_facil_v3', 'De onde pode surgir viés em IA?', 2, 'Apenas do monitor', 'Do monitor usado ou do local onde o sistema foi instalado'),
    ('seed_ia_facil_v3', 'Qual atitude ajuda a utilizar IA de maneira ética?', 0, 'Ignorar completamente os riscos', 'Confiar nos resultados sem os comparar com outras fontes'),
    ('seed_ia_facil_v3', 'Qual atitude ajuda a utilizar IA de maneira ética?', 1, 'Enganar utilizadores', 'Esconder dos utilizadores que a IA é usada nos serviços oferecidos'),
    ('seed_ia_facil_v3', 'Qual atitude ajuda a utilizar IA de maneira ética?', 3, 'Utilizar qualquer informação privada sem autorização', 'Usar dados privados dos utilizadores sem pedir autorização'),
    ('seed_ia_facil_v3', 'O que é privacidade de dados?', 1, 'Criação de imagens', 'Organização dos ficheiros pessoais por data, por tipo ou por tamanho'),
    ('seed_ia_facil_v3', 'O que é privacidade de dados?', 2, 'Aumento da velocidade da internet', 'Compressão de ficheiros pessoais para ocupar menos espaço'),
    ('seed_ia_facil_v3', 'O que é privacidade de dados?', 3, 'Instalação de programas', 'Instalação de programas pessoais em vários computadores')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas IA fácil lote 3: % alternativa(s) errada(s) atualizada(s) (esperado: 63).', v_updated;
END $$;
