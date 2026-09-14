-- Seed: conteúdo Tecnologia, nível Médio (33 perguntas)
-- Fonte: lote "TECNOLOGIA — MÉDIO (50 questões)" fornecido
-- pelo proprietário do projeto, filtrado para conter apenas perguntas que
-- ainda não existiam no banco (comparação por texto normalizado contra os
-- 614 enunciados já existentes em 003-024).
--
-- Das 50 perguntas do lote original, algumas repetiam (com o mesmo
-- enunciado) perguntas já presentes nos seeds 004/006 de Tecnologia
-- Médio — essas foram descartadas. As 33 restantes são
-- genuinamente novas e entram neste arquivo.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes
-- anteriores, não é decisão de negócio): no lote original, a esmagadora
-- maioria das respostas corretas era a alternativa "A" — decorável sem
-- conhecimento real. A posição da alternativa correta foi redistribuída por
-- pergunta com seed fixa (64 — distinta das seeds 42 a 63 já
-- usadas nos seeds anteriores) e distribuição controlada entre A/B/C/D,
-- reprodutível — o conteúdo pedagógico permanece exatamente como enviado,
-- só a ORDEM de exibição mudou.
--
-- Idempotente: usa a coluna `source` (migration 022) como marcador — rodar
-- este arquivo mais de uma vez não duplica as perguntas.

BEGIN;

DO $$
DECLARE
  v_category_id UUID;
BEGIN
  SELECT id INTO v_category_id FROM categories WHERE slug = 'tecnologia';
  IF v_category_id IS NULL THEN
    RAISE EXCEPTION 'Categoria "tecnologia" não encontrada — rode a migration 021 primeiro.';
  END IF;

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_tecnologia_medio_v2') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_tecnologia_medio_v2) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_tec_medio2 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'medium', v.statement, 15, 10, 'seed_tecnologia_medio_v2'
    FROM (VALUES
      ('Qual é a principal função de um sistema operacional?'),
      ('Qual componente do computador é responsável pelo processamento de informações?'),
      ('Qual é a função principal da memória RAM?'),
      ('Qual destas opções representa um dispositivo de armazenamento?'),
      ('Qual é uma vantagem do SSD em comparação ao HD?'),
      ('O que significa hardware?'),
      ('O que significa software?'),
      ('Qual é a função de uma placa-mãe?'),
      ('Qual equipamento normalmente distribui internet para vários dispositivos?'),
      ('O que representa um endereço IP?'),
      ('Para que serve o DNS?'),
      ('Qual é a principal função de um backup?'),
      ('Qual prática aumenta a segurança de uma conta?'),
      ('O que é uma API?'),
      ('Qual destes é um sistema de gerenciamento de banco de dados?'),
      ('Qual destas é uma linguagem de programação?'),
      ('O que significa IoT?'),
      ('Qual exemplo representa IoT?'),
      ('O que é frontend?'),
      ('O que é backend?'),
      ('O que é autenticação?'),
      ('O que é autorização?'),
      ('O que é VPN?'),
      ('O que significa latência?'),
      ('O que significa código aberto?'),
      ('O que é atualização de software?'),
      ('Qual é a função de um servidor?'),
      ('O que são logs?'),
      ('O que é escalabilidade?'),
      ('Qual empresa fornece serviços de nuvem?'),
      ('O que é um aplicativo móvel?'),
      ('O que é uma falha de segurança?'),
      ('Por que a segurança digital é importante?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_tec_medio2 q
    JOIN (VALUES
      ('Qual é a principal função de um sistema operacional?', 'Aumentar fisicamente a memória do computador', FALSE, 0),
      ('Qual é a principal função de um sistema operacional?', 'Substituir todos os aplicativos', FALSE, 1),
      ('Qual é a principal função de um sistema operacional?', 'Criar conexão de internet automaticamente', FALSE, 2),
      ('Qual é a principal função de um sistema operacional?', 'Controlar o hardware e permitir a execução de programas', TRUE, 3),
      ('Qual componente do computador é responsável pelo processamento de informações?', 'Monitor', FALSE, 0),
      ('Qual componente do computador é responsável pelo processamento de informações?', 'Impressora', FALSE, 1),
      ('Qual componente do computador é responsável pelo processamento de informações?', 'Teclado', FALSE, 2),
      ('Qual componente do computador é responsável pelo processamento de informações?', 'CPU', TRUE, 3),
      ('Qual é a função principal da memória RAM?', 'Substituir o processador', FALSE, 0),
      ('Qual é a função principal da memória RAM?', 'Armazenar dados temporariamente para programas em execução', TRUE, 1),
      ('Qual é a função principal da memória RAM?', 'Controlar a energia do computador', FALSE, 2),
      ('Qual é a função principal da memória RAM?', 'Guardar arquivos permanentemente', FALSE, 3),
      ('Qual destas opções representa um dispositivo de armazenamento?', 'Monitor', FALSE, 0),
      ('Qual destas opções representa um dispositivo de armazenamento?', 'Mouse', FALSE, 1),
      ('Qual destas opções representa um dispositivo de armazenamento?', 'Webcam', FALSE, 2),
      ('Qual destas opções representa um dispositivo de armazenamento?', 'SSD', TRUE, 3),
      ('Qual é uma vantagem do SSD em comparação ao HD?', 'Maior velocidade de leitura e gravação', TRUE, 0),
      ('Qual é uma vantagem do SSD em comparação ao HD?', 'Não precisa de energia', FALSE, 1),
      ('Qual é uma vantagem do SSD em comparação ao HD?', 'Não armazena arquivos', FALSE, 2),
      ('Qual é uma vantagem do SSD em comparação ao HD?', 'Funciona somente online', FALSE, 3),
      ('O que significa hardware?', 'Programas instalados', FALSE, 0),
      ('O que significa hardware?', 'Parte física de um computador', TRUE, 1),
      ('O que significa hardware?', 'Contas digitais', FALSE, 2),
      ('O que significa hardware?', 'Dados da internet', FALSE, 3),
      ('O que significa software?', 'Componentes físicos', FALSE, 0),
      ('O que significa software?', 'Programas e sistemas utilizados pelo computador', TRUE, 1),
      ('O que significa software?', 'Cabos de conexão', FALSE, 2),
      ('O que significa software?', 'Placas eletrônicas', FALSE, 3),
      ('Qual é a função de uma placa-mãe?', 'Criar documentos', FALSE, 0),
      ('Qual é a função de uma placa-mãe?', 'Armazenar somente fotos', FALSE, 1),
      ('Qual é a função de uma placa-mãe?', 'Conectar os componentes do computador', TRUE, 2),
      ('Qual é a função de uma placa-mãe?', 'Controlar a internet', FALSE, 3),
      ('Qual equipamento normalmente distribui internet para vários dispositivos?', 'Roteador', TRUE, 0),
      ('Qual equipamento normalmente distribui internet para vários dispositivos?', 'Teclado', FALSE, 1),
      ('Qual equipamento normalmente distribui internet para vários dispositivos?', 'Scanner', FALSE, 2),
      ('Qual equipamento normalmente distribui internet para vários dispositivos?', 'Projetor', FALSE, 3),
      ('O que representa um endereço IP?', 'Senha de acesso', FALSE, 0),
      ('O que representa um endereço IP?', 'Tipo de arquivo', FALSE, 1),
      ('O que representa um endereço IP?', 'Nome de usuário', FALSE, 2),
      ('O que representa um endereço IP?', 'Identificação de um dispositivo em uma rede', TRUE, 3),
      ('Para que serve o DNS?', 'Editar vídeos', FALSE, 0),
      ('Para que serve o DNS?', 'Aumentar memória RAM', FALSE, 1),
      ('Para que serve o DNS?', 'Converter nomes de sites em endereços IP', TRUE, 2),
      ('Para que serve o DNS?', 'Criar antivírus', FALSE, 3),
      ('Qual é a principal função de um backup?', 'Remover vírus', FALSE, 0),
      ('Qual é a principal função de um backup?', 'Criar aplicativos', FALSE, 1),
      ('Qual é a principal função de um backup?', 'Aumentar velocidade da internet', FALSE, 2),
      ('Qual é a principal função de um backup?', 'Criar uma cópia de segurança dos dados', TRUE, 3),
      ('Qual prática aumenta a segurança de uma conta?', 'Usar a mesma senha em tudo', FALSE, 0),
      ('Qual prática aumenta a segurança de uma conta?', 'Usar autenticação de dois fatores', TRUE, 1),
      ('Qual prática aumenta a segurança de uma conta?', 'Desativar segurança', FALSE, 2),
      ('Qual prática aumenta a segurança de uma conta?', 'Compartilhar senha', FALSE, 3),
      ('O que é uma API?', 'Tipo de computador', FALSE, 0),
      ('O que é uma API?', 'Interface que permite comunicação entre sistemas', TRUE, 1),
      ('O que é uma API?', 'Memória externa', FALSE, 2),
      ('O que é uma API?', 'Antivírus', FALSE, 3),
      ('Qual destes é um sistema de gerenciamento de banco de dados?', 'Bluetooth', FALSE, 0),
      ('Qual destes é um sistema de gerenciamento de banco de dados?', 'Windows Explorer', FALSE, 1),
      ('Qual destes é um sistema de gerenciamento de banco de dados?', 'HDMI', FALSE, 2),
      ('Qual destes é um sistema de gerenciamento de banco de dados?', 'MySQL', TRUE, 3),
      ('Qual destas é uma linguagem de programação?', 'PDF', FALSE, 0),
      ('Qual destas é uma linguagem de programação?', 'USB', FALSE, 1),
      ('Qual destas é uma linguagem de programação?', 'Python', TRUE, 2),
      ('Qual destas é uma linguagem de programação?', 'Wi-Fi', FALSE, 3),
      ('O que significa IoT?', 'Sistema operacional', FALSE, 0),
      ('O que significa IoT?', 'Tipo de processador', FALSE, 1),
      ('O que significa IoT?', 'Internet das Coisas', TRUE, 2),
      ('O que significa IoT?', 'Internet dos Computadores', FALSE, 3),
      ('Qual exemplo representa IoT?', 'Cabo USB', FALSE, 0),
      ('Qual exemplo representa IoT?', 'Relógio inteligente conectado à internet', TRUE, 1),
      ('Qual exemplo representa IoT?', 'Teclado desligado', FALSE, 2),
      ('Qual exemplo representa IoT?', 'Impressora sem energia', FALSE, 3),
      ('O que é frontend?', 'Servidor físico', FALSE, 0),
      ('O que é frontend?', 'Banco de dados', FALSE, 1),
      ('O que é frontend?', 'Parte visual de uma aplicação', TRUE, 2),
      ('O que é frontend?', 'Processador', FALSE, 3),
      ('O que é backend?', 'Parte responsável pela lógica e processamento do sistema', TRUE, 0),
      ('O que é backend?', 'Monitor', FALSE, 1),
      ('O que é backend?', 'Tela do usuário', FALSE, 2),
      ('O que é backend?', 'Mouse', FALSE, 3),
      ('O que é autenticação?', 'Processo de confirmar a identidade de um usuário', TRUE, 0),
      ('O que é autenticação?', 'Formatar computador', FALSE, 1),
      ('O que é autenticação?', 'Apagar arquivos', FALSE, 2),
      ('O que é autenticação?', 'Criar um programa', FALSE, 3),
      ('O que é autorização?', 'Definir permissões de acesso', TRUE, 0),
      ('O que é autorização?', 'Criar senha', FALSE, 1),
      ('O que é autorização?', 'Atualizar sistema', FALSE, 2),
      ('O que é autorização?', 'Instalar hardware', FALSE, 3),
      ('O que é VPN?', 'Memória RAM', FALSE, 0),
      ('O que é VPN?', 'Sistema operacional', FALSE, 1),
      ('O que é VPN?', 'Tecnologia que cria conexão protegida pela internet', TRUE, 2),
      ('O que é VPN?', 'Processador', FALSE, 3),
      ('O que significa latência?', 'Tempo de atraso na comunicação de dados', TRUE, 0),
      ('O que significa latência?', 'Tamanho do arquivo', FALSE, 1),
      ('O que significa latência?', 'Qualidade da tela', FALSE, 2),
      ('O que significa latência?', 'Espaço do disco', FALSE, 3),
      ('O que significa código aberto?', 'Programa sem arquivos', FALSE, 0),
      ('O que significa código aberto?', 'Programa sempre pago', FALSE, 1),
      ('O que significa código aberto?', 'Código disponível para estudo e modificação conforme licença', TRUE, 2),
      ('O que significa código aberto?', 'Código sem proteção', FALSE, 3),
      ('O que é atualização de software?', 'Melhoria ou correção de um programa', TRUE, 0),
      ('O que é atualização de software?', 'Formatação', FALSE, 1),
      ('O que é atualização de software?', 'Exclusão do programa', FALSE, 2),
      ('O que é atualização de software?', 'Troca de computador', FALSE, 3),
      ('Qual é a função de um servidor?', 'Aumentar tela', FALSE, 0),
      ('Qual é a função de um servidor?', 'Fornecer serviços ou dados para outros dispositivos', TRUE, 1),
      ('Qual é a função de um servidor?', 'Substituir internet', FALSE, 2),
      ('Qual é a função de um servidor?', 'Criar energia', FALSE, 3),
      ('O que são logs?', 'Vídeos', FALSE, 0),
      ('O que são logs?', 'Registros de atividades realizadas por sistemas', TRUE, 1),
      ('O que são logs?', 'Aplicativos', FALSE, 2),
      ('O que são logs?', 'Senhas', FALSE, 3),
      ('O que é escalabilidade?', 'Capacidade de um sistema crescer suportando mais usuários', TRUE, 0),
      ('O que é escalabilidade?', 'Exclusão de dados', FALSE, 1),
      ('O que é escalabilidade?', 'Redução de usuários', FALSE, 2),
      ('O que é escalabilidade?', 'Bloqueio do sistema', FALSE, 3),
      ('Qual empresa fornece serviços de nuvem?', 'Paint', FALSE, 0),
      ('Qual empresa fornece serviços de nuvem?', 'Instagram', FALSE, 1),
      ('Qual empresa fornece serviços de nuvem?', 'WhatsApp', FALSE, 2),
      ('Qual empresa fornece serviços de nuvem?', 'Amazon Web Services', TRUE, 3),
      ('O que é um aplicativo móvel?', 'Programa desenvolvido para dispositivos móveis', TRUE, 0),
      ('O que é um aplicativo móvel?', 'Cabo de dados', FALSE, 1),
      ('O que é um aplicativo móvel?', 'Memória RAM', FALSE, 2),
      ('O que é um aplicativo móvel?', 'Placa gráfica', FALSE, 3),
      ('O que é uma falha de segurança?', 'Atualização normal', FALSE, 0),
      ('O que é uma falha de segurança?', 'Aplicativo novo', FALSE, 1),
      ('O que é uma falha de segurança?', 'Backup', FALSE, 2),
      ('O que é uma falha de segurança?', 'Vulnerabilidade que pode ser explorada por atacantes', TRUE, 3),
      ('Por que a segurança digital é importante?', 'Para criar arquivos', FALSE, 0),
      ('Por que a segurança digital é importante?', 'Para aumentar tamanho da tela', FALSE, 1),
      ('Por que a segurança digital é importante?', 'Para proteger dados e sistemas contra ameaças', TRUE, 2),
      ('Por que a segurança digital é importante?', 'Apenas para melhorar gráficos', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_tec_medio2;

    RAISE NOTICE '33 perguntas inseridas com sucesso (source=seed_tecnologia_medio_v2).';
  END IF;
END $$;

COMMIT;
