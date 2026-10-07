-- Alternativas (BE-003, regularização) — Tecnologia médio lote 1: perguntas 1 a 25 do seed medio_v1 (migration 034).
-- Segue docs/quiz-v2-alternativas-padrao.md e a regra do dono: a resposta CERTA NÃO muda; só o texto das alternativas
-- ERRADAS é ajustado para ter tamanho e forma parecidos aos da certa. Tecnologia usa a faixa de migrations 300+.
-- Segurança: só altera question_alternatives.label, só de alternativas erradas (is_correct = FALSE), e só se o
-- texto atual ainda for exatamente o original (nunca sobrescreve edição posterior; idempotente). Não toca em ids,
-- is_correct, display_order, perguntas nem explicações. O runner já envolve o ficheiro numa transação.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE question_alternatives a
  SET label = v.new_label
  FROM questions q,
  (VALUES
    ('seed_tecnologia_medio_v1', 'O que é um sistema operacional?', 0, 'Um dispositivo de armazenamento', 'Software responsável por proteger arquivos do computador e impedir a entrada de vírus'),
    ('seed_tecnologia_medio_v1', 'O que é um sistema operacional?', 2, 'Um aplicativo de mensagens', 'Software responsável por conectar o computador a redes e permitir o envio de mensagens'),
    ('seed_tecnologia_medio_v1', 'O que é um sistema operacional?', 3, 'Um tipo de cabo de internet', 'Hardware responsável por guardar arquivos do computador e permitir a instalação de programas'),
    ('seed_tecnologia_medio_v1', 'Qual é a principal função de um processador (CPU)?', 0, 'Armazenar arquivos permanentemente', 'Guardar arquivos e programas necessários para o funcionamento do computador'),
    ('seed_tecnologia_medio_v1', 'Qual é a principal função de um processador (CPU)?', 2, 'Conectar o computador à internet', 'Conectar redes e periféricos necessários para o funcionamento do computador'),
    ('seed_tecnologia_medio_v1', 'Qual é a principal função de um processador (CPU)?', 3, 'Mostrar imagens na tela', 'Exibir imagens e gráficos necessários para o funcionamento da tela do computador'),
    ('seed_tecnologia_medio_v1', 'O que significa RAM?', 0, 'Sistema de armazenamento externo', 'Memória de leitura permanente utilizada para guardar o sistema do computador'),
    ('seed_tecnologia_medio_v1', 'O que significa RAM?', 2, 'Programa de segurança', 'Rede de acesso remoto utilizada para conectar computadores à distância'),
    ('seed_tecnologia_medio_v1', 'O que significa RAM?', 3, 'Rede automática mundial', 'Rotina de atualização automática utilizada para corrigir falhas do computador'),
    ('seed_tecnologia_medio_v1', 'Qual é a principal característica da memória RAM?', 0, 'Serve apenas para conectar à internet', 'Armazena dados permanentemente mesmo quando o dispositivo está desligado'),
    ('seed_tecnologia_medio_v1', 'Qual é a principal característica da memória RAM?', 2, 'Substitui o processador', 'Executa cálculos rapidamente enquanto o dispositivo está em funcionamento'),
    ('seed_tecnologia_medio_v1', 'Qual é a principal característica da memória RAM?', 3, 'Nunca perde informações', 'Guarda cópias de segurança enquanto o dispositivo está em funcionamento'),
    ('seed_tecnologia_medio_v1', 'O que é um SSD?', 0, 'Rede social', 'Dispositivo de armazenamento que utiliza discos magnéticos para guardar dados'),
    ('seed_tecnologia_medio_v1', 'O que é um SSD?', 2, 'Sistema operacional', 'Dispositivo de entrada que utiliza sensores ópticos para registrar movimentos'),
    ('seed_tecnologia_medio_v1', 'O que é um SSD?', 3, 'Programa antivírus', 'Dispositivo de rede que utiliza sinais de rádio para distribuir dados'),
    ('seed_tecnologia_medio_v1', 'Qual é uma vantagem do SSD em relação ao HD tradicional?', 1, 'Não permite guardar arquivos', 'Maior capacidade de guardar mais dados por menos dinheiro'),
    ('seed_tecnologia_medio_v1', 'Qual é uma vantagem do SSD em relação ao HD tradicional?', 2, 'Maior tamanho físico', 'Maior número de peças móveis para ler e gravar dados'),
    ('seed_tecnologia_medio_v1', 'Qual é uma vantagem do SSD em relação ao HD tradicional?', 3, 'Necessita sempre de internet', 'Maior dependência de conexão com a internet para gravar dados'),
    ('seed_tecnologia_medio_v1', 'O que é hardware?', 0, 'Dados armazenados na nuvem', 'Parte lógica de um computador ou dispositivo eletrônico'),
    ('seed_tecnologia_medio_v1', 'O que é hardware?', 1, 'Programas instalados', 'Conjunto de dados de um computador ou dispositivo eletrônico'),
    ('seed_tecnologia_medio_v1', 'O que é hardware?', 2, 'Senhas de usuários', 'Rede de conexões de um computador ou dispositivo eletrônico'),
    ('seed_tecnologia_medio_v1', 'O que é software?', 1, 'Cabo de energia', 'Conjunto de peças e componentes que funcionam em um dispositivo'),
    ('seed_tecnologia_medio_v1', 'O que é software?', 2, 'Peças físicas do computador', 'Conjunto de redes e conexões que funcionam em um dispositivo'),
    ('seed_tecnologia_medio_v1', 'O que é software?', 3, 'Tela do computador', 'Conjunto de telas e imagens que funcionam em um dispositivo'),
    ('seed_tecnologia_medio_v1', 'Qual destes é um exemplo de software?', 0, 'Teclado', 'Placa de vídeo'),
    ('seed_tecnologia_medio_v1', 'Qual destes é um exemplo de software?', 1, 'Placa-mãe', 'Disco rígido'),
    ('seed_tecnologia_medio_v1', 'Qual destes é um exemplo de software?', 2, 'Monitor', 'Memória RAM'),
    ('seed_tecnologia_medio_v1', 'O que é uma placa-mãe?', 0, 'Um programa de edição', 'Componente que processa e executa instruções para várias partes do computador'),
    ('seed_tecnologia_medio_v1', 'O que é uma placa-mãe?', 1, 'Um antivírus', 'Componente que fornece e distribui energia para várias partes do computador'),
    ('seed_tecnologia_medio_v1', 'O que é uma placa-mãe?', 2, 'Um navegador', 'Componente que guarda e mantém dados temporários de várias partes do computador'),
    ('seed_tecnologia_medio_v1', 'Para que serve uma placa de vídeo?', 0, 'Guardar documentos', 'Processar sons e músicas reproduzidos pelo computador'),
    ('seed_tecnologia_medio_v1', 'Para que serve uma placa de vídeo?', 1, 'Controlar senhas', 'Processar cálculos e instruções executados pelo computador'),
    ('seed_tecnologia_medio_v1', 'Para que serve uma placa de vídeo?', 2, 'Criar contas online', 'Processar dados e sinais transmitidos pela rede do computador'),
    ('seed_tecnologia_medio_v1', 'O que é uma rede de computadores?', 1, 'Um arquivo digital', 'Conjunto de programas instalados para organizar informações e recursos'),
    ('seed_tecnologia_medio_v1', 'O que é uma rede de computadores?', 2, 'Um tipo de aplicativo', 'Conjunto de arquivos guardados para proteger informações e recursos'),
    ('seed_tecnologia_medio_v1', 'O que é uma rede de computadores?', 3, 'Um único computador desligado', 'Conjunto de peças internas ligadas para processar informações e recursos'),
    ('seed_tecnologia_medio_v1', 'O que é internet?', 0, 'Um sistema operacional', 'Rede local que conecta computadores e dispositivos de uma mesma casa ou empresa'),
    ('seed_tecnologia_medio_v1', 'O que é internet?', 1, 'Apenas um programa', 'Conjunto de sites que conecta usuários e empresas para troca de informações'),
    ('seed_tecnologia_medio_v1', 'O que é internet?', 3, 'Um tipo de memória', 'Serviço mundial que conecta computadores e telefones para troca de mensagens'),
    ('seed_tecnologia_medio_v1', 'O que é Wi-Fi?', 0, 'Sistema de pagamento', 'Tecnologia que permite conexão por cabo a uma rede'),
    ('seed_tecnologia_medio_v1', 'O que é Wi-Fi?', 1, 'Tipo de processador', 'Tecnologia que permite carregamento sem fio de aparelhos'),
    ('seed_tecnologia_medio_v1', 'O que é Wi-Fi?', 2, 'Programa de edição', 'Tecnologia que permite armazenamento de dados em servidores remotos'),
    ('seed_tecnologia_medio_v1', 'O que é um navegador?', 0, 'Peça interna do computador', 'Programa usado para criar páginas e conteúdos para a internet'),
    ('seed_tecnologia_medio_v1', 'O que é um navegador?', 2, 'Dispositivo de armazenamento', 'Programa usado para guardar páginas e conteúdos na nuvem'),
    ('seed_tecnologia_medio_v1', 'O que é um navegador?', 3, 'Tipo de vírus', 'Programa usado para enviar mensagens e conteúdos pela internet'),
    ('seed_tecnologia_medio_v1', 'Qual destes é um navegador?', 1, 'Android', 'Google Drive'),
    ('seed_tecnologia_medio_v1', 'Qual destes é um navegador?', 2, 'Windows', 'Microsoft Word'),
    ('seed_tecnologia_medio_v1', 'Qual destes é um navegador?', 3, 'Excel', 'Adobe Reader'),
    ('seed_tecnologia_medio_v1', 'O que é armazenamento em nuvem?', 0, 'Guardar arquivos apenas em papel', 'Serviço que permite guardar e imprimir arquivos pela impressora'),
    ('seed_tecnologia_medio_v1', 'O que é armazenamento em nuvem?', 2, 'Aumentar fisicamente o computador', 'Serviço que permite criar e editar arquivos pelo computador'),
    ('seed_tecnologia_medio_v1', 'O que é armazenamento em nuvem?', 3, 'Criar vírus', 'Serviço que permite enviar e receber mensagens pela internet'),
    ('seed_tecnologia_medio_v1', 'Qual é uma vantagem da nuvem?', 0, 'Funcionar apenas offline', 'Permitir acesso aos arquivos a partir do mesmo computador onde foram criados'),
    ('seed_tecnologia_medio_v1', 'Qual é uma vantagem da nuvem?', 1, 'Impedir qualquer compartilhamento', 'Permitir aumento da memória interna do computador com espaço extra'),
    ('seed_tecnologia_medio_v1', 'Qual é uma vantagem da nuvem?', 3, 'Eliminar totalmente a necessidade de segurança', 'Permitir uso dos arquivos com maior velocidade que o disco do computador'),
    ('seed_tecnologia_medio_v1', 'Por que fazer backup é importante?', 0, 'Substitui todos os programas', 'Ajuda a acelerar o computador depois de falhas acidentais'),
    ('seed_tecnologia_medio_v1', 'Por que fazer backup é importante?', 2, 'Elimina todas as senhas', 'Ajuda a impedir a entrada de vírus por acessos indevidos'),
    ('seed_tecnologia_medio_v1', 'Por que fazer backup é importante?', 3, 'Aumenta automaticamente a velocidade da internet', 'Ajuda a atualizar programas com versões mais recentes'),
    ('seed_tecnologia_medio_v1', 'O que é malware?', 0, 'Sistema operacional', 'Software legítimo criado para corrigir falhas ou realizar ações automáticas'),
    ('seed_tecnologia_medio_v1', 'O que é malware?', 2, 'Navegador seguro', 'Software de segurança criado para detectar danos ou bloquear ações não autorizadas'),
    ('seed_tecnologia_medio_v1', 'O que é malware?', 3, 'Programa de edição', 'Software de edição criado para alterar imagens ou realizar ações gráficas'),
    ('seed_tecnologia_medio_v1', 'O que é phishing?', 1, 'Método de melhorar internet', 'Técnica de proteção usada para tentar bloquear informações através de mensagens ou páginas falsas'),
    ('seed_tecnologia_medio_v1', 'O que é phishing?', 2, 'Programa de edição', 'Técnica de pesquisa usada para tentar localizar informações através de mensagens ou páginas públicas'),
    ('seed_tecnologia_medio_v1', 'O que é phishing?', 3, 'Tipo de memória', 'Técnica de cópia usada para tentar guardar informações através de mensagens ou páginas salvas'),
    ('seed_tecnologia_medio_v1', 'O que é uma senha forte?', 1, 'Nome próprio simples', 'Senha fácil de lembrar, combinando nomes e datas pessoais quando possível'),
    ('seed_tecnologia_medio_v1', 'O que é uma senha forte?', 2, 'Palavra comum', 'Senha curta de digitar, combinando poucos caracteres iguais quando possível'),
    ('seed_tecnologia_medio_v1', 'O que é uma senha forte?', 3, 'Data de nascimento', 'Senha longa de decorar, repetindo a mesma sequência em vários serviços quando possível'),
    ('seed_tecnologia_medio_v1', 'O que é autenticação de dois fatores (2FA)?', 0, 'Duas senhas iguais', 'Camada adicional de segurança que exige a mesma senha duas vezes seguidas'),
    ('seed_tecnologia_medio_v1', 'O que é autenticação de dois fatores (2FA)?', 1, 'Dois navegadores instalados', 'Camada adicional de proteção que exige dois aplicativos antivírus instalados'),
    ('seed_tecnologia_medio_v1', 'O que é autenticação de dois fatores (2FA)?', 3, 'Dois computadores ligados', 'Camada adicional de acesso que exige dois aparelhos conectados à mesma rede'),
    ('seed_tecnologia_medio_v1', 'Qual é um exemplo de uso de inteligência artificial?', 1, 'Um cabo USB', 'Planilhas eletrônicas que calculam fórmulas'),
    ('seed_tecnologia_medio_v1', 'Qual é um exemplo de uso de inteligência artificial?', 2, 'Um monitor desligado', 'Impressoras que imprimem documentos em papel'),
    ('seed_tecnologia_medio_v1', 'Qual é um exemplo de uso de inteligência artificial?', 3, 'Um teclado físico', 'Câmeras que gravam vídeos em alta resolução')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Tecnologia médio lote 1: perguntas 1 a 25 do seed medio_v1 (migration 034): % alternativa(s) errada(s) atualizada(s) (esperado: 72).', v_updated;
END $$;
