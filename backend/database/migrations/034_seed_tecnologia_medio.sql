-- Migration/seed: conteúdo Tecnologia, nível Médio (50 perguntas)
-- Fonte: lote de perguntas fornecido pelo proprietário do projeto (mesmo padrão
-- do lote de Fácil, ver 003_tecnologia_facil.sql).
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado do lote anterior, não é
-- decisão de negócio): no lote original, as 50 respostas corretas eram TODAS a
-- alternativa "A" — decorável sem conhecimento real. A posição da alternativa
-- correta foi redistribuída por pergunta com seed fixa (43 — diferente da seed
-- 42 usada no lote Fácil, para não repetir o mesmo padrão de posições) e
-- distribuição controlada (13/13/12/12 entre A/B/C/D), reprodutível — o
-- conteúdo pedagógico (perguntas, alternativas) permanece exatamente como
-- enviado, só a ORDEM de exibição de cada alternativa mudou.
--
-- Observação: `xp_reward` (10) e `time_limit_seconds` (15) usam os mesmos
-- valores do lote Fácil e do exemplo genérico do Doc. Mestre (Seção 19.4:
-- "00:15 segundos"). Não existe, em nenhum documento oficial, uma tabela de
-- XP por dificuldade (diferente da tabela de PONTOS por dificuldade da Seção
-- 5.9-B, já aplicada em `quizService` desde a migration 029) — por isso não
-- foi inventado um valor de XP maior para "médio" sem aprovação explícita.
-- Fica registrado aqui como decisão em aberto, não como esquecimento.
--
-- Idempotente: usa a coluna `source` (migration 022) como marcador — rodar
-- este arquivo mais de uma vez não duplica as perguntas.
--
-- CORREÇÃO DE DUPLICATA CRUZADA (rodada de consolidação): 4 perguntas
-- deste arquivo tinham o MESMO enunciado de perguntas já existentes em
-- 003_tecnologia_facil.sql (mesma categoria, dificuldade Fácil) — "O que é
-- inteligência artificial?", "O que é um vírus de computador?", "O que é
-- antivírus?", "O que é backup?". Removidas daqui (mantidas em 003).
-- 50 → 46 perguntas.

BEGIN;

DO $$
DECLARE
  v_category_id UUID;
BEGIN
  SELECT id INTO v_category_id FROM categories WHERE slug = 'tecnologia';
  IF v_category_id IS NULL THEN
    RAISE EXCEPTION 'Categoria "tecnologia" não encontrada — rode a migration 021 primeiro.';
  END IF;

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_tecnologia_medio_v1') THEN
    RAISE NOTICE 'Perguntas de Tecnologia (médio) já foram inseridas anteriormente — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_tec_medio AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'medium', v.statement, 15, 10, 'seed_tecnologia_medio_v1'
    FROM (VALUES
      ('O que é um sistema operacional?'),
      ('Qual destes é um exemplo de sistema operacional?'),
      ('Qual é a principal função de um processador (CPU)?'),
      ('O que significa RAM?'),
      ('Qual é a principal característica da memória RAM?'),
      ('O que é um SSD?'),
      ('Qual é uma vantagem do SSD em relação ao HD tradicional?'),
      ('O que é hardware?'),
      ('O que é software?'),
      ('Qual destes é um exemplo de software?'),
      ('O que é uma placa-mãe?'),
      ('Para que serve uma placa de vídeo?'),
      ('O que é uma rede de computadores?'),
      ('O que é internet?'),
      ('O que é Wi-Fi?'),
      ('O que é um navegador?'),
      ('Qual destes é um navegador?'),
      ('O que é armazenamento em nuvem?'),
      ('Qual é uma vantagem da nuvem?'),
      ('Por que fazer backup é importante?'),
      ('O que é malware?'),
      ('O que é phishing?'),
      ('O que é uma senha forte?'),
      ('O que é autenticação de dois fatores (2FA)?'),
      ('Qual é um exemplo de uso de inteligência artificial?'),
      ('O que é machine learning?'),
      ('O que é programação?'),
      ('O que é uma linguagem de programação?'),
      ('Qual destes é uma linguagem de programação?'),
      ('O que é aplicativo móvel?'),
      ('O que é uma atualização de software?'),
      ('Por que atualizar programas é importante?'),
      ('O que é banco de dados?'),
      ('O que é uma aplicação web?'),
      ('O que é servidor?'),
      ('O que é endereço IP?'),
      ('O que é domínio de internet?'),
      ('O que é código-fonte?'),
      ('O que é código aberto (open source)?'),
      ('O que é API?'),
      ('Para que serve uma API?'),
      ('O que é criptografia?'),
      ('O que é blockchain?'),
      ('O que é realidade virtual?'),
      ('O que é Internet das Coisas (IoT)?'),
      ('Qual é uma boa prática de segurança digital?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_tec_medio q
    JOIN (VALUES
      ('O que é um sistema operacional?', 'Um dispositivo de armazenamento', FALSE, 0),
      ('O que é um sistema operacional?', 'Software responsável por gerenciar recursos do computador e permitir a execução de programas', TRUE, 1),
      ('O que é um sistema operacional?', 'Um aplicativo de mensagens', FALSE, 2),
      ('O que é um sistema operacional?', 'Um tipo de cabo de internet', FALSE, 3),
      ('Qual destes é um exemplo de sistema operacional?', 'Google Chrome', FALSE, 0),
      ('Qual destes é um exemplo de sistema operacional?', 'YouTube', FALSE, 1),
      ('Qual destes é um exemplo de sistema operacional?', 'Windows', TRUE, 2),
      ('Qual destes é um exemplo de sistema operacional?', 'WhatsApp', FALSE, 3),
      ('Qual é a principal função de um processador (CPU)?', 'Armazenar arquivos permanentemente', FALSE, 0),
      ('Qual é a principal função de um processador (CPU)?', 'Executar instruções e realizar cálculos necessários para o funcionamento do computador', TRUE, 1),
      ('Qual é a principal função de um processador (CPU)?', 'Conectar o computador à internet', FALSE, 2),
      ('Qual é a principal função de um processador (CPU)?', 'Mostrar imagens na tela', FALSE, 3),
      ('O que significa RAM?', 'Sistema de armazenamento externo', FALSE, 0),
      ('O que significa RAM?', 'Memória de acesso aleatório utilizada temporariamente pelo computador', TRUE, 1),
      ('O que significa RAM?', 'Programa de segurança', FALSE, 2),
      ('O que significa RAM?', 'Rede automática mundial', FALSE, 3),
      ('Qual é a principal característica da memória RAM?', 'Serve apenas para conectar à internet', FALSE, 0),
      ('Qual é a principal característica da memória RAM?', 'Armazena dados temporariamente enquanto o dispositivo está em funcionamento', TRUE, 1),
      ('Qual é a principal característica da memória RAM?', 'Substitui o processador', FALSE, 2),
      ('Qual é a principal característica da memória RAM?', 'Nunca perde informações', FALSE, 3),
      ('O que é um SSD?', 'Rede social', FALSE, 0),
      ('O que é um SSD?', 'Dispositivo de armazenamento que utiliza memória flash para guardar dados', TRUE, 1),
      ('O que é um SSD?', 'Sistema operacional', FALSE, 2),
      ('O que é um SSD?', 'Programa antivírus', FALSE, 3),
      ('Qual é uma vantagem do SSD em relação ao HD tradicional?', 'Maior velocidade de leitura e gravação de dados', TRUE, 0),
      ('Qual é uma vantagem do SSD em relação ao HD tradicional?', 'Não permite guardar arquivos', FALSE, 1),
      ('Qual é uma vantagem do SSD em relação ao HD tradicional?', 'Maior tamanho físico', FALSE, 2),
      ('Qual é uma vantagem do SSD em relação ao HD tradicional?', 'Necessita sempre de internet', FALSE, 3),
      ('O que é hardware?', 'Dados armazenados na nuvem', FALSE, 0),
      ('O que é hardware?', 'Programas instalados', FALSE, 1),
      ('O que é hardware?', 'Senhas de usuários', FALSE, 2),
      ('O que é hardware?', 'Parte física de um computador ou dispositivo eletrônico', TRUE, 3),
      ('O que é software?', 'Conjunto de programas e instruções que funcionam em um dispositivo', TRUE, 0),
      ('O que é software?', 'Cabo de energia', FALSE, 1),
      ('O que é software?', 'Peças físicas do computador', FALSE, 2),
      ('O que é software?', 'Tela do computador', FALSE, 3),
      ('Qual destes é um exemplo de software?', 'Teclado', FALSE, 0),
      ('Qual destes é um exemplo de software?', 'Placa-mãe', FALSE, 1),
      ('Qual destes é um exemplo de software?', 'Monitor', FALSE, 2),
      ('Qual destes é um exemplo de software?', 'Microsoft Word', TRUE, 3),
      ('O que é uma placa-mãe?', 'Um programa de edição', FALSE, 0),
      ('O que é uma placa-mãe?', 'Um antivírus', FALSE, 1),
      ('O que é uma placa-mãe?', 'Um navegador', FALSE, 2),
      ('O que é uma placa-mãe?', 'Componente que conecta e permite comunicação entre várias partes do computador', TRUE, 3),
      ('Para que serve uma placa de vídeo?', 'Guardar documentos', FALSE, 0),
      ('Para que serve uma placa de vídeo?', 'Controlar senhas', FALSE, 1),
      ('Para que serve uma placa de vídeo?', 'Criar contas online', FALSE, 2),
      ('Para que serve uma placa de vídeo?', 'Processar imagens e gráficos exibidos pelo computador', TRUE, 3),
      ('O que é uma rede de computadores?', 'Conjunto de dispositivos conectados para compartilhar informações e recursos', TRUE, 0),
      ('O que é uma rede de computadores?', 'Um arquivo digital', FALSE, 1),
      ('O que é uma rede de computadores?', 'Um tipo de aplicativo', FALSE, 2),
      ('O que é uma rede de computadores?', 'Um único computador desligado', FALSE, 3),
      ('O que é internet?', 'Um sistema operacional', FALSE, 0),
      ('O que é internet?', 'Apenas um programa', FALSE, 1),
      ('O que é internet?', 'Rede mundial que conecta computadores e dispositivos para troca de informações', TRUE, 2),
      ('O que é internet?', 'Um tipo de memória', FALSE, 3),
      ('O que é Wi-Fi?', 'Sistema de pagamento', FALSE, 0),
      ('O que é Wi-Fi?', 'Tipo de processador', FALSE, 1),
      ('O que é Wi-Fi?', 'Programa de edição', FALSE, 2),
      ('O que é Wi-Fi?', 'Tecnologia que permite conexão sem fio a uma rede', TRUE, 3),
      ('O que é um navegador?', 'Peça interna do computador', FALSE, 0),
      ('O que é um navegador?', 'Programa usado para acessar páginas e conteúdos na internet', TRUE, 1),
      ('O que é um navegador?', 'Dispositivo de armazenamento', FALSE, 2),
      ('O que é um navegador?', 'Tipo de vírus', FALSE, 3),
      ('Qual destes é um navegador?', 'Google Chrome', TRUE, 0),
      ('Qual destes é um navegador?', 'Android', FALSE, 1),
      ('Qual destes é um navegador?', 'Windows', FALSE, 2),
      ('Qual destes é um navegador?', 'Excel', FALSE, 3),
      ('O que é armazenamento em nuvem?', 'Guardar arquivos apenas em papel', FALSE, 0),
      ('O que é armazenamento em nuvem?', 'Serviço que permite guardar e acessar arquivos pela internet', TRUE, 1),
      ('O que é armazenamento em nuvem?', 'Aumentar fisicamente o computador', FALSE, 2),
      ('O que é armazenamento em nuvem?', 'Criar vírus', FALSE, 3),
      ('Qual é uma vantagem da nuvem?', 'Funcionar apenas offline', FALSE, 0),
      ('Qual é uma vantagem da nuvem?', 'Impedir qualquer compartilhamento', FALSE, 1),
      ('Qual é uma vantagem da nuvem?', 'Permitir acesso aos arquivos a partir de diferentes dispositivos conectados', TRUE, 2),
      ('Qual é uma vantagem da nuvem?', 'Eliminar totalmente a necessidade de segurança', FALSE, 3),
      ('Por que fazer backup é importante?', 'Substitui todos os programas', FALSE, 0),
      ('Por que fazer backup é importante?', 'Ajuda a proteger informações contra perdas acidentais', TRUE, 1),
      ('Por que fazer backup é importante?', 'Elimina todas as senhas', FALSE, 2),
      ('Por que fazer backup é importante?', 'Aumenta automaticamente a velocidade da internet', FALSE, 3),
      ('O que é malware?', 'Sistema operacional', FALSE, 0),
      ('O que é malware?', 'Software malicioso criado para causar danos ou realizar ações não autorizadas', TRUE, 1),
      ('O que é malware?', 'Navegador seguro', FALSE, 2),
      ('O que é malware?', 'Programa de edição', FALSE, 3),
      ('O que é phishing?', 'Técnica de fraude usada para tentar obter informações através de mensagens ou páginas falsas', TRUE, 0),
      ('O que é phishing?', 'Método de melhorar internet', FALSE, 1),
      ('O que é phishing?', 'Programa de edição', FALSE, 2),
      ('O que é phishing?', 'Tipo de memória', FALSE, 3),
      ('O que é uma senha forte?', 'Senha difícil de adivinhar, combinando diferentes tipos de caracteres quando possível', TRUE, 0),
      ('O que é uma senha forte?', 'Nome próprio simples', FALSE, 1),
      ('O que é uma senha forte?', 'Palavra comum', FALSE, 2),
      ('O que é uma senha forte?', 'Data de nascimento', FALSE, 3),
      ('O que é autenticação de dois fatores (2FA)?', 'Duas senhas iguais', FALSE, 0),
      ('O que é autenticação de dois fatores (2FA)?', 'Dois navegadores instalados', FALSE, 1),
      ('O que é autenticação de dois fatores (2FA)?', 'Camada adicional de segurança que exige uma segunda forma de confirmação', TRUE, 2),
      ('O que é autenticação de dois fatores (2FA)?', 'Dois computadores ligados', FALSE, 3),
      ('Qual é um exemplo de uso de inteligência artificial?', 'Assistentes virtuais que respondem perguntas', TRUE, 0),
      ('Qual é um exemplo de uso de inteligência artificial?', 'Um cabo USB', FALSE, 1),
      ('Qual é um exemplo de uso de inteligência artificial?', 'Um monitor desligado', FALSE, 2),
      ('Qual é um exemplo de uso de inteligência artificial?', 'Um teclado físico', FALSE, 3),
      ('O que é machine learning?', 'Um tipo de computador físico', FALSE, 0),
      ('O que é machine learning?', 'Um antivírus', FALSE, 1),
      ('O que é machine learning?', 'Área da inteligência artificial em que sistemas aprendem padrões a partir de dados', TRUE, 2),
      ('O que é machine learning?', 'Um navegador', FALSE, 3),
      ('O que é programação?', 'Compra de equipamentos', FALSE, 0),
      ('O que é programação?', 'Uso de redes sociais', FALSE, 1),
      ('O que é programação?', 'Processo de criar instruções para que computadores executem tarefas', TRUE, 2),
      ('O que é programação?', 'Montagem de computadores físicos apenas', FALSE, 3),
      ('O que é uma linguagem de programação?', 'Linguagem utilizada para escrever instruções que computadores conseguem interpretar', TRUE, 0),
      ('O que é uma linguagem de programação?', 'Idioma falado por pessoas', FALSE, 1),
      ('O que é uma linguagem de programação?', 'Sistema de pagamento', FALSE, 2),
      ('O que é uma linguagem de programação?', 'Tipo de hardware', FALSE, 3),
      ('Qual destes é uma linguagem de programação?', 'Chrome', FALSE, 0),
      ('Qual destes é uma linguagem de programação?', 'Python', TRUE, 1),
      ('Qual destes é uma linguagem de programação?', 'Bluetooth', FALSE, 2),
      ('Qual destes é uma linguagem de programação?', 'Windows Explorer', FALSE, 3),
      ('O que é aplicativo móvel?', 'Rede Wi-Fi', FALSE, 0),
      ('O que é aplicativo móvel?', 'Peça do telefone', FALSE, 1),
      ('O que é aplicativo móvel?', 'Programa desenvolvido para funcionar em dispositivos móveis como smartphones', TRUE, 2),
      ('O que é aplicativo móvel?', 'Cabo de carregamento', FALSE, 3),
      ('O que é uma atualização de software?', 'Desligar o dispositivo', FALSE, 0),
      ('O que é uma atualização de software?', 'Remover a internet', FALSE, 1),
      ('O que é uma atualização de software?', 'Apagar todos os dados', FALSE, 2),
      ('O que é uma atualização de software?', 'Alteração feita para melhorar, corrigir problemas ou adicionar recursos', TRUE, 3),
      ('Por que atualizar programas é importante?', 'Remove todos os arquivos', FALSE, 0),
      ('Por que atualizar programas é importante?', 'Impede qualquer uso', FALSE, 1),
      ('Por que atualizar programas é importante?', 'Pode corrigir falhas e melhorar segurança e funcionamento', TRUE, 2),
      ('Por que atualizar programas é importante?', 'Sempre reduz segurança', FALSE, 3),
      ('O que é banco de dados?', 'Uma tela', FALSE, 0),
      ('O que é banco de dados?', 'Um cabo de internet', FALSE, 1),
      ('O que é banco de dados?', 'Sistema organizado para armazenar e gerenciar informações', TRUE, 2),
      ('O que é banco de dados?', 'Um antivírus', FALSE, 3),
      ('O que é uma aplicação web?', 'Programa acessível através de um navegador pela internet ou rede', TRUE, 0),
      ('O que é uma aplicação web?', 'Uma bateria', FALSE, 1),
      ('O que é uma aplicação web?', 'Apenas um documento impresso', FALSE, 2),
      ('O que é uma aplicação web?', 'Um componente físico', FALSE, 3),
      ('O que é servidor?', 'Um vírus', FALSE, 0),
      ('O que é servidor?', 'Apenas um teclado', FALSE, 1),
      ('O que é servidor?', 'Uma aplicação de mensagens', FALSE, 2),
      ('O que é servidor?', 'Computador ou sistema que fornece serviços e recursos para outros dispositivos', TRUE, 3),
      ('O que é endereço IP?', 'Tipo de memória', FALSE, 0),
      ('O que é endereço IP?', 'Nome de aplicativo', FALSE, 1),
      ('O que é endereço IP?', 'Identificação numérica atribuída a dispositivos em uma rede', TRUE, 2),
      ('O que é endereço IP?', 'Senha de usuário', FALSE, 3),
      ('O que é domínio de internet?', 'Um arquivo temporário', FALSE, 0),
      ('O que é domínio de internet?', 'Um vírus', FALSE, 1),
      ('O que é domínio de internet?', 'Um processador', FALSE, 2),
      ('O que é domínio de internet?', 'Nome utilizado para identificar um site na internet', TRUE, 3),
      ('O que é código-fonte?', 'Um documento físico', FALSE, 0),
      ('O que é código-fonte?', 'Um cabo', FALSE, 1),
      ('O que é código-fonte?', 'Uma imagem', FALSE, 2),
      ('O que é código-fonte?', 'Conjunto de instruções escritas por programadores para criar um software', TRUE, 3),
      ('O que é código aberto (open source)?', 'Software cujo código pode ser analisado ou modificado conforme sua licença permite', TRUE, 0),
      ('O que é código aberto (open source)?', 'Programa sempre pago', FALSE, 1),
      ('O que é código aberto (open source)?', 'Software sem código', FALSE, 2),
      ('O que é código aberto (open source)?', 'Sistema sem segurança', FALSE, 3),
      ('O que é API?', 'Memória do computador', FALSE, 0),
      ('O que é API?', 'Sistema operacional', FALSE, 1),
      ('O que é API?', 'Tipo de bateria', FALSE, 2),
      ('O que é API?', 'Interface que permite comunicação entre diferentes sistemas ou aplicações', TRUE, 3),
      ('Para que serve uma API?', 'Substituir a internet', FALSE, 0),
      ('Para que serve uma API?', 'Permitir integração e troca de informações entre sistemas', TRUE, 1),
      ('Para que serve uma API?', 'Criar vírus', FALSE, 2),
      ('Para que serve uma API?', 'Aumentar fisicamente o computador', FALSE, 3),
      ('O que é criptografia?', 'Exclusão de arquivos', FALSE, 0),
      ('O que é criptografia?', 'Criação de aplicativos', FALSE, 1),
      ('O que é criptografia?', 'Técnica de proteger informações transformando dados para impedir acesso não autorizado', TRUE, 2),
      ('O que é criptografia?', 'Aumento de velocidade do processador', FALSE, 3),
      ('O que é blockchain?', 'Tecnologia de registro distribuído que organiza informações em blocos ligados por mecanismos criptográficos', TRUE, 0),
      ('O que é blockchain?', 'Um cabo', FALSE, 1),
      ('O que é blockchain?', 'Um antivírus', FALSE, 2),
      ('O que é blockchain?', 'Um navegador', FALSE, 3),
      ('O que é realidade virtual?', 'Um sistema bancário', FALSE, 0),
      ('O que é realidade virtual?', 'Uma rede social', FALSE, 1),
      ('O que é realidade virtual?', 'Um tipo de memória', FALSE, 2),
      ('O que é realidade virtual?', 'Tecnologia que cria ambientes digitais imersivos simulados por computador', TRUE, 3),
      ('O que é Internet das Coisas (IoT)?', 'Um antivírus', FALSE, 0),
      ('O que é Internet das Coisas (IoT)?', 'Conexão de objetos físicos à internet para coletar e trocar dados', TRUE, 1),
      ('O que é Internet das Coisas (IoT)?', 'Apenas uso de computadores', FALSE, 2),
      ('O que é Internet das Coisas (IoT)?', 'Um sistema operacional', FALSE, 3),
      ('Qual é uma boa prática de segurança digital?', 'Manter sistemas atualizados e proteger informações pessoais', TRUE, 0),
      ('Qual é uma boa prática de segurança digital?', 'Clicar em qualquer link recebido', FALSE, 1),
      ('Qual é uma boa prática de segurança digital?', 'Usar a mesma senha em tudo', FALSE, 2),
      ('Qual é uma boa prática de segurança digital?', 'Compartilhar senhas com qualquer pessoa', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_tec_medio;

    RAISE NOTICE '50 perguntas de Tecnologia (médio) inseridas com sucesso.';
  END IF;
END $$;

COMMIT;
