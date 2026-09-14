-- Seed: conteúdo Tecnologia, nível Médio (41 perguntas)
-- Fonte: lote fornecido pelo proprietário do projeto (50
-- perguntas nesta categoria+dificuldade), filtrado para conter apenas
-- perguntas que ainda não existiam no banco (comparação por texto
-- normalizado contra os enunciados já existentes em 003-029).
--
-- Das 50 perguntas do lote original, 9 já existiam
-- palavra-por-palavra no banco — foram descartadas. As 41 restantes são
-- genuinamente novas e entram neste arquivo.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes
-- anteriores, não é decisão de negócio): no lote original, TODAS as
-- respostas corretas vinham na alternativa "A" — decorável sem
-- conhecimento real. A posição da alternativa correta foi redistribuída por
-- pergunta com seed fixa (69 — distinta das seeds 42 a 68 já
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

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_tecnologia_medio_v3') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_tecnologia_medio_v3) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_tec_medio3 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'medium', v.statement, 15, 10, 'seed_tecnologia_medio_v3'
    FROM (VALUES
      ('Qual é a principal função de uma placa de vídeo (GPU)?'),
      ('O que significa BIOS em um computador?'),
      ('Qual é a função de um driver de dispositivo?'),
      ('O que é uma partição de disco?'),
      ('Qual é a diferença principal entre RAM e armazenamento interno?'),
      ('O que é cache de processador?'),
      ('O que significa resolução de tela?'),
      ('Qual tecnologia permite comunicação sem fio de curto alcance entre dispositivos?'),
      ('Para que serve uma porta USB?'),
      ('O que é HDMI?'),
      ('Qual é a função de um antivírus?'),
      ('O que é autenticação multifator?'),
      ('O que é engenharia social na segurança digital?'),
      ('Qual é a finalidade de uma senha forte?'),
      ('O que é um sistema embarcado?'),
      ('Qual exemplo representa um sistema embarcado?'),
      ('O que é um hipervisor?'),
      ('O que é uma atualização de firmware?'),
      ('O que é código QR?'),
      ('O que é NFC?'),
      ('Qual é a principal função de um modem?'),
      ('O que é largura de banda?'),
      ('O que é um servidor web?'),
      ('O que é HTTP?'),
      ('O que significa HTTPS?'),
      ('O que é um cookie de navegador?'),
      ('O que é uma licença de software?'),
      ('O que é manutenção preventiva?'),
      ('O que é manutenção corretiva?'),
      ('O que é monitoramento de sistemas?'),
      ('O que é JSON?'),
      ('O que é XML?'),
      ('O que é Git?'),
      ('Para que serve o GitHub?'),
      ('O que é debug?'),
      ('O que é compilador?'),
      ('O que é algoritmo?'),
      ('O que é inteligência artificial generativa?'),
      ('O que é computação de borda (Edge Computing)?'),
      ('O que é transformação digital?'),
      ('O que é governança de TI?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_tec_medio3 q
    JOIN (VALUES
      ('Qual é a principal função de uma placa de vídeo (GPU)?', 'Controlar a alimentação elétrica', FALSE, 0),
      ('Qual é a principal função de uma placa de vídeo (GPU)?', 'Processar gráficos e acelerar tarefas visuais', TRUE, 1),
      ('Qual é a principal função de uma placa de vídeo (GPU)?', 'Substituir o sistema operacional', FALSE, 2),
      ('Qual é a principal função de uma placa de vídeo (GPU)?', 'Armazenar arquivos permanentemente', FALSE, 3),
      ('O que significa BIOS em um computador?', 'Sistema de armazenamento online', FALSE, 0),
      ('O que significa BIOS em um computador?', 'Linguagem de programação', FALSE, 1),
      ('O que significa BIOS em um computador?', 'Programa de edição de imagens', FALSE, 2),
      ('O que significa BIOS em um computador?', 'Sistema básico responsável pela inicialização do hardware', TRUE, 3),
      ('Qual é a função de um driver de dispositivo?', 'Proteger contra vírus automaticamente', FALSE, 0),
      ('Qual é a função de um driver de dispositivo?', 'Permitir comunicação entre o sistema operacional e o hardware', TRUE, 1),
      ('Qual é a função de um driver de dispositivo?', 'Aumentar a velocidade da internet', FALSE, 2),
      ('Qual é a função de um driver de dispositivo?', 'Criar páginas web', FALSE, 3),
      ('O que é uma partição de disco?', 'Uma rede social', FALSE, 0),
      ('O que é uma partição de disco?', 'Um antivírus', FALSE, 1),
      ('O que é uma partição de disco?', 'Um tipo de processador', FALSE, 2),
      ('O que é uma partição de disco?', 'Divisão lógica de uma unidade de armazenamento', TRUE, 3),
      ('Qual é a diferença principal entre RAM e armazenamento interno?', 'RAM é temporária; armazenamento guarda dados permanentemente', TRUE, 0),
      ('Qual é a diferença principal entre RAM e armazenamento interno?', 'RAM não influencia no desempenho', FALSE, 1),
      ('Qual é a diferença principal entre RAM e armazenamento interno?', 'Ambas possuem exatamente a mesma função', FALSE, 2),
      ('Qual é a diferença principal entre RAM e armazenamento interno?', 'Armazenamento funciona apenas durante jogos', FALSE, 3),
      ('O que é cache de processador?', 'Memória rápida usada para acesso frequente de dados', TRUE, 0),
      ('O que é cache de processador?', 'Tipo de cabo', FALSE, 1),
      ('O que é cache de processador?', 'Espaço para instalar programas', FALSE, 2),
      ('O que é cache de processador?', 'Sistema de segurança', FALSE, 3),
      ('O que significa resolução de tela?', 'Velocidade do processador', FALSE, 0),
      ('O que significa resolução de tela?', 'Capacidade do disco', FALSE, 1),
      ('O que significa resolução de tela?', 'Quantidade de pixels exibidos em uma imagem', TRUE, 2),
      ('O que significa resolução de tela?', 'Quantidade de aplicativos', FALSE, 3),
      ('Qual tecnologia permite comunicação sem fio de curto alcance entre dispositivos?', 'HDMI', FALSE, 0),
      ('Qual tecnologia permite comunicação sem fio de curto alcance entre dispositivos?', 'Bluetooth', TRUE, 1),
      ('Qual tecnologia permite comunicação sem fio de curto alcance entre dispositivos?', 'SATA', FALSE, 2),
      ('Qual tecnologia permite comunicação sem fio de curto alcance entre dispositivos?', 'VGA', FALSE, 3),
      ('Para que serve uma porta USB?', 'Aumentar o tamanho da tela', FALSE, 0),
      ('Para que serve uma porta USB?', 'Conectar dispositivos e transferir dados ou energia', TRUE, 1),
      ('Para que serve uma porta USB?', 'Substituir o processador', FALSE, 2),
      ('Para que serve uma porta USB?', 'Criar vírus', FALSE, 3),
      ('O que é HDMI?', 'Banco de dados', FALSE, 0),
      ('O que é HDMI?', 'Sistema operacional', FALSE, 1),
      ('O que é HDMI?', 'Tipo de memória', FALSE, 2),
      ('O que é HDMI?', 'Interface usada principalmente para transmitir áudio e vídeo digital', TRUE, 3),
      ('Qual é a função de um antivírus?', 'Detectar e remover softwares maliciosos', TRUE, 0),
      ('Qual é a função de um antivírus?', 'Criar aplicativos', FALSE, 1),
      ('Qual é a função de um antivírus?', 'Melhorar resolução', FALSE, 2),
      ('Qual é a função de um antivírus?', 'Aumentar memória RAM', FALSE, 3),
      ('O que é autenticação multifator?', 'Uso de várias contas iguais', FALSE, 0),
      ('O que é autenticação multifator?', 'Instalação de vários sistemas', FALSE, 1),
      ('O que é autenticação multifator?', 'Criação de múltiplos arquivos', FALSE, 2),
      ('O que é autenticação multifator?', 'Uso de mais de uma forma de verificar identidade', TRUE, 3),
      ('O que é engenharia social na segurança digital?', 'Construção de computadores', FALSE, 0),
      ('O que é engenharia social na segurança digital?', 'Programação industrial', FALSE, 1),
      ('O que é engenharia social na segurança digital?', 'Criação de redes físicas', FALSE, 2),
      ('O que é engenharia social na segurança digital?', 'Manipulação de pessoas para obter informações ou acesso', TRUE, 3),
      ('Qual é a finalidade de uma senha forte?', 'Criar aplicativos', FALSE, 0),
      ('Qual é a finalidade de uma senha forte?', 'Melhorar gráficos', FALSE, 1),
      ('Qual é a finalidade de uma senha forte?', 'Aumentar velocidade do computador', FALSE, 2),
      ('Qual é a finalidade de uma senha forte?', 'Dificultar acessos não autorizados', TRUE, 3),
      ('O que é um sistema embarcado?', 'Computador sem memória', FALSE, 0),
      ('O que é um sistema embarcado?', 'Rede social', FALSE, 1),
      ('O que é um sistema embarcado?', 'Banco de dados online', FALSE, 2),
      ('O que é um sistema embarcado?', 'Sistema computacional integrado dentro de um equipamento específico', TRUE, 3),
      ('Qual exemplo representa um sistema embarcado?', 'Aplicativo de mensagens', FALSE, 0),
      ('Qual exemplo representa um sistema embarcado?', 'Navegador web', FALSE, 1),
      ('Qual exemplo representa um sistema embarcado?', 'Sistema de controle de uma máquina de lavar inteligente', TRUE, 2),
      ('Qual exemplo representa um sistema embarcado?', 'Documento de texto', FALSE, 3),
      ('O que é um hipervisor?', 'Sistema de pagamento', FALSE, 0),
      ('O que é um hipervisor?', 'Programa antivírus', FALSE, 1),
      ('O que é um hipervisor?', 'Navegador', FALSE, 2),
      ('O que é um hipervisor?', 'Software responsável por criar e gerenciar máquinas virtuais', TRUE, 3),
      ('O que é uma atualização de firmware?', 'Troca física de hardware', FALSE, 0),
      ('O que é uma atualização de firmware?', 'Exclusão do sistema', FALSE, 1),
      ('O que é uma atualização de firmware?', 'Criação de usuário', FALSE, 2),
      ('O que é uma atualização de firmware?', 'Atualização do software interno de um dispositivo', TRUE, 3),
      ('O que é código QR?', 'Processador', FALSE, 0),
      ('O que é código QR?', 'Código visual que pode armazenar informações acessíveis por leitura', TRUE, 1),
      ('O que é código QR?', 'Sistema operacional', FALSE, 2),
      ('O que é código QR?', 'Tipo de vírus', FALSE, 3),
      ('O que é NFC?', 'Tecnologia de comunicação sem fio de curta distância', TRUE, 0),
      ('O que é NFC?', 'Tipo de memória RAM', FALSE, 1),
      ('O que é NFC?', 'Sistema operacional', FALSE, 2),
      ('O que é NFC?', 'Linguagem de programação', FALSE, 3),
      ('Qual é a principal função de um modem?', 'Converter sinais para permitir comunicação com a rede', TRUE, 0),
      ('Qual é a principal função de um modem?', 'Armazenar arquivos', FALSE, 1),
      ('Qual é a principal função de um modem?', 'Processar gráficos', FALSE, 2),
      ('Qual é a principal função de um modem?', 'Criar aplicativos', FALSE, 3),
      ('O que é largura de banda?', 'Capacidade de transmissão de dados em uma rede', TRUE, 0),
      ('O que é largura de banda?', 'Espaço do teclado', FALSE, 1),
      ('O que é largura de banda?', 'Tamanho do monitor', FALSE, 2),
      ('O que é largura de banda?', 'Número de usuários', FALSE, 3),
      ('O que é um servidor web?', 'Um teclado especial', FALSE, 0),
      ('O que é um servidor web?', 'Servidor responsável por disponibilizar páginas e aplicações web', TRUE, 1),
      ('O que é um servidor web?', 'Um antivírus', FALSE, 2),
      ('O que é um servidor web?', 'Uma placa gráfica', FALSE, 3),
      ('O que é HTTP?', 'Tipo de processador', FALSE, 0),
      ('O que é HTTP?', 'Protocolo usado para comunicação entre navegador e servidores web', TRUE, 1),
      ('O que é HTTP?', 'Sistema operacional', FALSE, 2),
      ('O que é HTTP?', 'Banco de dados', FALSE, 3),
      ('O que significa HTTPS?', 'Linguagem de programação', FALSE, 0),
      ('O que significa HTTPS?', 'Memória externa', FALSE, 1),
      ('O que significa HTTPS?', 'Versão segura do HTTP usando criptografia', TRUE, 2),
      ('O que significa HTTPS?', 'Sistema operacional', FALSE, 3),
      ('O que é um cookie de navegador?', 'Vírus obrigatório', FALSE, 0),
      ('O que é um cookie de navegador?', 'Pequeno arquivo usado para armazenar informações sobre navegação', TRUE, 1),
      ('O que é um cookie de navegador?', 'Tipo de hardware', FALSE, 2),
      ('O que é um cookie de navegador?', 'Programa de edição', FALSE, 3),
      ('O que é uma licença de software?', 'Conjunto de regras sobre uso e distribuição de um programa', TRUE, 0),
      ('O que é uma licença de software?', 'Tipo de vírus', FALSE, 1),
      ('O que é uma licença de software?', 'Cabo de rede', FALSE, 2),
      ('O que é uma licença de software?', 'Senha do computador', FALSE, 3),
      ('O que é manutenção preventiva?', 'Apenas reparar equipamentos quebrados', FALSE, 0),
      ('O que é manutenção preventiva?', 'Ações realizadas para evitar problemas futuros', TRUE, 1),
      ('O que é manutenção preventiva?', 'Apagar arquivos', FALSE, 2),
      ('O que é manutenção preventiva?', 'Instalar jogos', FALSE, 3),
      ('O que é manutenção corretiva?', 'Monitoramento de rede', FALSE, 0),
      ('O que é manutenção corretiva?', 'Atualização automática', FALSE, 1),
      ('O que é manutenção corretiva?', 'Reparação realizada após ocorrer uma falha', TRUE, 2),
      ('O que é manutenção corretiva?', 'Criação de backup', FALSE, 3),
      ('O que é monitoramento de sistemas?', 'Acompanhamento do funcionamento e desempenho de serviços', TRUE, 0),
      ('O que é monitoramento de sistemas?', 'Instalação de jogos', FALSE, 1),
      ('O que é monitoramento de sistemas?', 'Criação de vídeos', FALSE, 2),
      ('O que é monitoramento de sistemas?', 'Exclusão de usuários', FALSE, 3),
      ('O que é JSON?', 'Rede social', FALSE, 0),
      ('O que é JSON?', 'Sistema antivírus', FALSE, 1),
      ('O que é JSON?', 'Formato leve usado para troca de dados entre sistemas', TRUE, 2),
      ('O que é JSON?', 'Hardware', FALSE, 3),
      ('O que é XML?', 'Linguagem de marcação usada para estruturar dados', TRUE, 0),
      ('O que é XML?', 'Processador', FALSE, 1),
      ('O que é XML?', 'Sistema operacional', FALSE, 2),
      ('O que é XML?', 'Banco físico', FALSE, 3),
      ('O que é Git?', 'Antivírus', FALSE, 0),
      ('O que é Git?', 'Sistema operacional', FALSE, 1),
      ('O que é Git?', 'Navegador', FALSE, 2),
      ('O que é Git?', 'Sistema de controle de versões de código', TRUE, 3),
      ('Para que serve o GitHub?', 'Editar imagens', FALSE, 0),
      ('Para que serve o GitHub?', 'Hospedar e colaborar em projetos de código', TRUE, 1),
      ('Para que serve o GitHub?', 'Aumentar memória', FALSE, 2),
      ('Para que serve o GitHub?', 'Criar computadores', FALSE, 3),
      ('O que é debug?', 'Instalar hardware', FALSE, 0),
      ('O que é debug?', 'Apagar banco de dados', FALSE, 1),
      ('O que é debug?', 'Processo de encontrar e corrigir erros em software', TRUE, 2),
      ('O que é debug?', 'Criar vírus', FALSE, 3),
      ('O que é compilador?', 'Programa que transforma código-fonte em código executável', TRUE, 0),
      ('O que é compilador?', 'Sistema de armazenamento', FALSE, 1),
      ('O que é compilador?', 'Firewall', FALSE, 2),
      ('O que é compilador?', 'Navegador', FALSE, 3),
      ('O que é algoritmo?', 'Tipo de computador', FALSE, 0),
      ('O que é algoritmo?', 'Arquivo de imagem', FALSE, 1),
      ('O que é algoritmo?', 'Sequência de instruções para resolver um problema', TRUE, 2),
      ('O que é algoritmo?', 'Rede sem fio', FALSE, 3),
      ('O que é inteligência artificial generativa?', 'IA capaz de criar novos conteúdos como textos, imagens ou códigos', TRUE, 0),
      ('O que é inteligência artificial generativa?', 'Sistema de armazenamento', FALSE, 1),
      ('O que é inteligência artificial generativa?', 'Cabo de conexão', FALSE, 2),
      ('O que é inteligência artificial generativa?', 'Memória física', FALSE, 3),
      ('O que é computação de borda (Edge Computing)?', 'Exclusão de dados', FALSE, 0),
      ('O que é computação de borda (Edge Computing)?', 'Bloqueio de internet', FALSE, 1),
      ('O que é computação de borda (Edge Computing)?', 'Processamento de dados mais próximo da origem onde são gerados', TRUE, 2),
      ('O que é computação de borda (Edge Computing)?', 'Uso apenas de servidores distantes', FALSE, 3),
      ('O que é transformação digital?', 'Impressão de documentos', FALSE, 0),
      ('O que é transformação digital?', 'Troca de computadores somente', FALSE, 1),
      ('O que é transformação digital?', 'Uso de tecnologia para melhorar processos e negócios', TRUE, 2),
      ('O que é transformação digital?', 'Exclusão de sistemas', FALSE, 3),
      ('O que é governança de TI?', 'Venda de computadores', FALSE, 0),
      ('O que é governança de TI?', 'Instalação de jogos', FALSE, 1),
      ('O que é governança de TI?', 'Gestão de recursos tecnológicos alinhada aos objetivos da organização', TRUE, 2),
      ('O que é governança de TI?', 'Criação de redes sociais', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_tec_medio3;

    RAISE NOTICE '41 perguntas inseridas com sucesso (source=seed_tecnologia_medio_v3).';
  END IF;
END $$;

COMMIT;
