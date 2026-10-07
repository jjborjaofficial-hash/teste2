-- Alternativas (BE-003, regularização) — Tecnologia médio lote 4: perguntas 30 a 33 do seed medio_v2 (migration 055) e 1 a 21 do seed medio_v3 (migration 060).
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
    ('seed_tecnologia_medio_v2', 'Qual empresa fornece serviços de nuvem?', 0, 'Paint', 'Adobe Photoshop Express'),
    ('seed_tecnologia_medio_v2', 'Qual empresa fornece serviços de nuvem?', 1, 'Instagram', 'Instagram Reels'),
    ('seed_tecnologia_medio_v2', 'Qual empresa fornece serviços de nuvem?', 2, 'WhatsApp', 'WhatsApp Business'),
    ('seed_tecnologia_medio_v2', 'O que é um aplicativo móvel?', 1, 'Cabo de dados', 'Programa desenvolvido para computadores de mesa'),
    ('seed_tecnologia_medio_v2', 'O que é um aplicativo móvel?', 2, 'Memória RAM', 'Peça desenvolvida para dispositivos móveis'),
    ('seed_tecnologia_medio_v2', 'O que é um aplicativo móvel?', 3, 'Placa gráfica', 'Sistema desenvolvido para dispositivos móveis'),
    ('seed_tecnologia_medio_v2', 'O que é uma falha de segurança?', 0, 'Atualização normal', 'Atualização que pode ser instalada por usuários'),
    ('seed_tecnologia_medio_v2', 'O que é uma falha de segurança?', 1, 'Aplicativo novo', 'Permissão que pode ser concedida por administradores'),
    ('seed_tecnologia_medio_v2', 'O que é uma falha de segurança?', 2, 'Backup', 'Cópia que pode ser restaurada por administradores'),
    ('seed_tecnologia_medio_v2', 'Por que a segurança digital é importante?', 0, 'Para criar arquivos', 'Para organizar dados e sistemas em categorias'),
    ('seed_tecnologia_medio_v2', 'Por que a segurança digital é importante?', 1, 'Para aumentar tamanho da tela', 'Para ampliar a velocidade de dados e sistemas'),
    ('seed_tecnologia_medio_v2', 'Por que a segurança digital é importante?', 3, 'Apenas para melhorar gráficos', 'Para melhorar a aparência de dados e sistemas'),
    ('seed_tecnologia_medio_v3', 'Qual é a principal função de uma placa de vídeo (GPU)?', 0, 'Controlar a alimentação elétrica', 'Controlar a temperatura e reduzir ruído do computador'),
    ('seed_tecnologia_medio_v3', 'Qual é a principal função de uma placa de vídeo (GPU)?', 2, 'Substituir o sistema operacional', 'Executar instruções e acelerar cálculos gerais'),
    ('seed_tecnologia_medio_v3', 'Qual é a principal função de uma placa de vídeo (GPU)?', 3, 'Armazenar arquivos permanentemente', 'Armazenar arquivos e acelerar acessos ao disco'),
    ('seed_tecnologia_medio_v3', 'O que significa BIOS em um computador?', 0, 'Sistema de armazenamento online', 'Sistema operacional responsável pela execução dos aplicativos'),
    ('seed_tecnologia_medio_v3', 'O que significa BIOS em um computador?', 1, 'Linguagem de programação', 'Sistema de rede responsável pela conexão dos dispositivos'),
    ('seed_tecnologia_medio_v3', 'O que significa BIOS em um computador?', 2, 'Programa de edição de imagens', 'Sistema de segurança responsável pela proteção dos arquivos'),
    ('seed_tecnologia_medio_v3', 'Qual é a função de um driver de dispositivo?', 0, 'Proteger contra vírus automaticamente', 'Permitir comunicação entre o navegador e o servidor web'),
    ('seed_tecnologia_medio_v3', 'Qual é a função de um driver de dispositivo?', 2, 'Aumentar a velocidade da internet', 'Permitir comunicação entre o aplicativo e o banco de dados'),
    ('seed_tecnologia_medio_v3', 'Qual é a função de um driver de dispositivo?', 3, 'Criar páginas web', 'Permitir comunicação entre o roteador e o provedor de internet'),
    ('seed_tecnologia_medio_v3', 'O que é uma partição de disco?', 0, 'Uma rede social', 'Divisão física de uma unidade de armazenamento'),
    ('seed_tecnologia_medio_v3', 'O que é uma partição de disco?', 1, 'Um antivírus', 'Cópia lógica de uma unidade de armazenamento'),
    ('seed_tecnologia_medio_v3', 'O que é uma partição de disco?', 2, 'Um tipo de processador', 'Junção lógica de várias unidades de armazenamento'),
    ('seed_tecnologia_medio_v3', 'Qual é a diferença principal entre RAM e armazenamento interno?', 1, 'RAM não influencia no desempenho', 'RAM é permanente; armazenamento guarda dados temporariamente'),
    ('seed_tecnologia_medio_v3', 'Qual é a diferença principal entre RAM e armazenamento interno?', 2, 'Ambas possuem exatamente a mesma função', 'RAM é lenta; armazenamento guarda dados rapidamente'),
    ('seed_tecnologia_medio_v3', 'Qual é a diferença principal entre RAM e armazenamento interno?', 3, 'Armazenamento funciona apenas durante jogos', 'RAM é gráfica; armazenamento guarda dados em servidores'),
    ('seed_tecnologia_medio_v3', 'O que é cache de processador?', 1, 'Tipo de cabo', 'Memória lenta usada para armazenamento permanente de dados'),
    ('seed_tecnologia_medio_v3', 'O que é cache de processador?', 2, 'Espaço para instalar programas', 'Espaço extra usado para instalação frequente de programas'),
    ('seed_tecnologia_medio_v3', 'O que é cache de processador?', 3, 'Sistema de segurança', 'Registro rápido usado para proteção frequente de senhas'),
    ('seed_tecnologia_medio_v3', 'O que significa resolução de tela?', 0, 'Velocidade do processador', 'Quantidade de cores exibidas em uma imagem'),
    ('seed_tecnologia_medio_v3', 'O que significa resolução de tela?', 1, 'Capacidade do disco', 'Tamanho físico da tela onde uma imagem aparece'),
    ('seed_tecnologia_medio_v3', 'O que significa resolução de tela?', 3, 'Quantidade de aplicativos', 'Quantidade de quadros exibidos em um vídeo'),
    ('seed_tecnologia_medio_v3', 'Qual tecnologia permite comunicação sem fio de curto alcance entre dispositivos?', 0, 'HDMI', 'Ethernet'),
    ('seed_tecnologia_medio_v3', 'Qual tecnologia permite comunicação sem fio de curto alcance entre dispositivos?', 2, 'SATA', 'Thunderbolt'),
    ('seed_tecnologia_medio_v3', 'Qual tecnologia permite comunicação sem fio de curto alcance entre dispositivos?', 3, 'VGA', 'DisplayPort'),
    ('seed_tecnologia_medio_v3', 'Para que serve uma porta USB?', 0, 'Aumentar o tamanho da tela', 'Conectar dispositivos e transmitir sinais de rádio'),
    ('seed_tecnologia_medio_v3', 'Para que serve uma porta USB?', 2, 'Substituir o processador', 'Conectar telas e transmitir áudio ou vídeo digital'),
    ('seed_tecnologia_medio_v3', 'Para que serve uma porta USB?', 3, 'Criar vírus', 'Conectar redes e transmitir dados de internet'),
    ('seed_tecnologia_medio_v3', 'O que é HDMI?', 0, 'Banco de dados', 'Interface usada principalmente para transmitir dados e carregar dispositivos'),
    ('seed_tecnologia_medio_v3', 'O que é HDMI?', 1, 'Sistema operacional', 'Interface usada principalmente para conectar redes e roteadores'),
    ('seed_tecnologia_medio_v3', 'O que é HDMI?', 2, 'Tipo de memória', 'Interface usada principalmente para armazenar arquivos e programas'),
    ('seed_tecnologia_medio_v3', 'Qual é a função de um antivírus?', 1, 'Criar aplicativos', 'Detectar e corrigir erros em arquivos do disco'),
    ('seed_tecnologia_medio_v3', 'Qual é a função de um antivírus?', 2, 'Melhorar resolução', 'Organizar e compactar arquivos pouco usados'),
    ('seed_tecnologia_medio_v3', 'Qual é a função de um antivírus?', 3, 'Aumentar memória RAM', 'Acelerar e limpar o histórico de navegação'),
    ('seed_tecnologia_medio_v3', 'O que é autenticação multifator?', 0, 'Uso de várias contas iguais', 'Uso de mais de uma senha para verificar identidade'),
    ('seed_tecnologia_medio_v3', 'O que é autenticação multifator?', 1, 'Instalação de vários sistemas', 'Uso de mais de um usuário para verificar acessos'),
    ('seed_tecnologia_medio_v3', 'O que é autenticação multifator?', 2, 'Criação de múltiplos arquivos', 'Uso de mais de uma conta para guardar arquivos'),
    ('seed_tecnologia_medio_v3', 'O que é engenharia social na segurança digital?', 0, 'Construção de computadores', 'Proteção de sistemas para bloquear informações ou acessos'),
    ('seed_tecnologia_medio_v3', 'O que é engenharia social na segurança digital?', 1, 'Programação industrial', 'Criptografia de dados para proteger informações ou acessos'),
    ('seed_tecnologia_medio_v3', 'O que é engenharia social na segurança digital?', 2, 'Criação de redes físicas', 'Instalação de programas para coletar informações ou acessos'),
    ('seed_tecnologia_medio_v3', 'Qual é a finalidade de uma senha forte?', 0, 'Criar aplicativos', 'Acelerar acessos a contas de usuários'),
    ('seed_tecnologia_medio_v3', 'Qual é a finalidade de uma senha forte?', 1, 'Melhorar gráficos', 'Organizar acessos a contas de usuários'),
    ('seed_tecnologia_medio_v3', 'Qual é a finalidade de uma senha forte?', 2, 'Aumentar velocidade do computador', 'Substituir antivírus em contas de usuários'),
    ('seed_tecnologia_medio_v3', 'O que é um sistema embarcado?', 0, 'Computador sem memória', 'Sistema computacional conectado a vários equipamentos de uma rede'),
    ('seed_tecnologia_medio_v3', 'O que é um sistema embarcado?', 1, 'Rede social', 'Sistema operacional instalado em computadores de uso geral'),
    ('seed_tecnologia_medio_v3', 'O que é um sistema embarcado?', 2, 'Banco de dados online', 'Sistema de armazenamento hospedado em servidores de um provedor'),
    ('seed_tecnologia_medio_v3', 'Qual exemplo representa um sistema embarcado?', 0, 'Aplicativo de mensagens', 'Aplicativo de controle de uma conta bancária online'),
    ('seed_tecnologia_medio_v3', 'Qual exemplo representa um sistema embarcado?', 1, 'Navegador web', 'Sistema de gerenciamento de uma loja virtual de compras'),
    ('seed_tecnologia_medio_v3', 'Qual exemplo representa um sistema embarcado?', 3, 'Documento de texto', 'Documento de configuração de um servidor de arquivos remoto'),
    ('seed_tecnologia_medio_v3', 'O que é um hipervisor?', 0, 'Sistema de pagamento', 'Software responsável por criar e gerenciar contas de usuários'),
    ('seed_tecnologia_medio_v3', 'O que é um hipervisor?', 1, 'Programa antivírus', 'Software responsável por baixar e atualizar programas instalados'),
    ('seed_tecnologia_medio_v3', 'O que é um hipervisor?', 2, 'Navegador', 'Hardware responsável por criar e gerenciar conexões de rede'),
    ('seed_tecnologia_medio_v3', 'O que é uma atualização de firmware?', 0, 'Troca física de hardware', 'Atualização do aplicativo principal de um dispositivo'),
    ('seed_tecnologia_medio_v3', 'O que é uma atualização de firmware?', 1, 'Exclusão do sistema', 'Atualização da peça física interna de um dispositivo'),
    ('seed_tecnologia_medio_v3', 'O que é uma atualização de firmware?', 2, 'Criação de usuário', 'Atualização da conta de usuário de um dispositivo'),
    ('seed_tecnologia_medio_v3', 'O que é código QR?', 0, 'Processador', 'Código numérico que pode armazenar senhas acessíveis por digitação'),
    ('seed_tecnologia_medio_v3', 'O que é código QR?', 2, 'Sistema operacional', 'Programa instalado que pode armazenar informações acessíveis por conta'),
    ('seed_tecnologia_medio_v3', 'O que é código QR?', 3, 'Tipo de vírus', 'Imagem digital que pode armazenar fotografias acessíveis por programas'),
    ('seed_tecnologia_medio_v3', 'O que é NFC?', 1, 'Tipo de memória RAM', 'Tecnologia de comunicação por cabo de curta distância'),
    ('seed_tecnologia_medio_v3', 'O que é NFC?', 2, 'Sistema operacional', 'Tecnologia de comunicação sem fio de longa distância'),
    ('seed_tecnologia_medio_v3', 'O que é NFC?', 3, 'Linguagem de programação', 'Tecnologia de localização por satélite em curta distância'),
    ('seed_tecnologia_medio_v3', 'Qual é a principal função de um modem?', 1, 'Armazenar arquivos', 'Distribuir sinais para permitir comunicação entre aparelhos'),
    ('seed_tecnologia_medio_v3', 'Qual é a principal função de um modem?', 2, 'Processar gráficos', 'Proteger sinais para impedir acessos indevidos à rede'),
    ('seed_tecnologia_medio_v3', 'Qual é a principal função de um modem?', 3, 'Criar aplicativos', 'Amplificar sinais para aumentar o alcance da rede')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Tecnologia médio lote 4: perguntas 30 a 33 do seed medio_v2 (migration 055) e 1 a 21 do seed medio_v3 (migration 060): % alternativa(s) errada(s) atualizada(s) (esperado: 75).', v_updated;
END $$;
