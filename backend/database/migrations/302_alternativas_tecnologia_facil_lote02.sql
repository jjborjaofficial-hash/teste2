-- Alternativas (BE-003, regularização) — Tecnologia fácil lote 2: perguntas 26 a 50 do seed v1 (migration 033).
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
    ('seed_tecnologia_facil_v1', 'O que é email?', 0, 'Tipo de memória', 'Serviço utilizado para guardar e compartilhar arquivos na internet'),
    ('seed_tecnologia_facil_v1', 'O que é email?', 1, 'Cabo de rede', 'Programa utilizado para abrir e navegar em páginas da internet'),
    ('seed_tecnologia_facil_v1', 'O que é email?', 3, 'Sistema operacional', 'Aplicativo utilizado para fazer chamadas de voz e vídeo'),
    ('seed_tecnologia_facil_v1', 'O que é uma mensagem instantânea?', 0, 'Documento físico', 'Documento impresso enviado e recebido pelo correio tradicional'),
    ('seed_tecnologia_facil_v1', 'O que é uma mensagem instantânea?', 2, 'Arquivo de sistema', 'Programa instalado e atualizado automaticamente através da internet'),
    ('seed_tecnologia_facil_v1', 'O que é uma mensagem instantânea?', 3, 'Tipo de computador', 'Conversa transmitida em tempo real com imagem através de câmeras'),
    ('seed_tecnologia_facil_v1', 'Qual aplicativo é conhecido por mensagens instantâneas?', 0, 'BIOS', 'Spotify'),
    ('seed_tecnologia_facil_v1', 'O que é uma chamada de vídeo?', 0, 'Tipo de memória', 'Mensagem que transmite texto e emojis pela internet'),
    ('seed_tecnologia_facil_v1', 'O que é uma chamada de vídeo?', 1, 'Programa antivírus', 'Programa que transmite filmes e séries pela internet'),
    ('seed_tecnologia_facil_v1', 'O que é uma chamada de vídeo?', 2, 'Arquivo de texto', 'Chamada que transmite voz pela rede telefônica comum'),
    ('seed_tecnologia_facil_v1', 'O que é inteligência artificial?', 0, 'Um cabo de computador', 'Tecnologia que permite computadores guardarem grandes quantidades de dados'),
    ('seed_tecnologia_facil_v1', 'O que é inteligência artificial?', 1, 'Um tipo de bateria', 'Tecnologia que permite aparelhos conectarem-se à internet sem usar fios'),
    ('seed_tecnologia_facil_v1', 'O que é inteligência artificial?', 2, 'Uma impressora', 'Tecnologia que permite programas funcionarem sem estarem instalados no aparelho'),
    ('seed_tecnologia_facil_v1', 'Qual é um exemplo de inteligência artificial?', 0, 'Teclado físico', 'Planilhas eletrônicas e processadores de texto'),
    ('seed_tecnologia_facil_v1', 'Qual é um exemplo de inteligência artificial?', 1, 'Cabo USB', 'Câmeras fotográficas e cartões de memória'),
    ('seed_tecnologia_facil_v1', 'Qual é um exemplo de inteligência artificial?', 3, 'Monitor desligado', 'Impressoras e digitalizadores de documentos'),
    ('seed_tecnologia_facil_v1', 'O que é uma atualização de aplicativo?', 0, 'Apagar todos os dados', 'Cópia criada para guardar os dados de um aplicativo'),
    ('seed_tecnologia_facil_v1', 'O que é uma atualização de aplicativo?', 1, 'Desligar o telefone', 'Nova conta criada para entrar e usar um aplicativo'),
    ('seed_tecnologia_facil_v1', 'O que é uma atualização de aplicativo?', 3, 'Remover a internet', 'Novo aparelho comprado para executar melhor um aplicativo'),
    ('seed_tecnologia_facil_v1', 'Por que atualizar aplicativos?', 0, 'Para reduzir funcionalidades sempre', 'Para liberar espaço no armazenamento do aparelho'),
    ('seed_tecnologia_facil_v1', 'Por que atualizar aplicativos?', 1, 'Para danificar o dispositivo', 'Para mudar a cor e o ícone do aplicativo'),
    ('seed_tecnologia_facil_v1', 'Por que atualizar aplicativos?', 2, 'Para apagar arquivos', 'Para aumentar a velocidade da internet móvel'),
    ('seed_tecnologia_facil_v1', 'O que é um vírus de computador?', 0, 'Uma atualização', 'Programa legítimo que pode corrigir erros ou melhorar o desempenho'),
    ('seed_tecnologia_facil_v1', 'O que é um vírus de computador?', 2, 'Um navegador', 'Programa comum que pode abrir páginas ou mostrar informações'),
    ('seed_tecnologia_facil_v1', 'O que é um vírus de computador?', 3, 'Um aplicativo comum', 'Aplicativo de segurança que pode detectar e remover ameaças'),
    ('seed_tecnologia_facil_v1', 'O que é antivírus?', 0, 'Tipo de teclado', 'Programa usado para ajudar a organizar e guardar arquivos digitais'),
    ('seed_tecnologia_facil_v1', 'O que é antivírus?', 1, 'Sistema operacional', 'Programa usado para ajudar a escrever e editar textos digitais'),
    ('seed_tecnologia_facil_v1', 'O que é antivírus?', 2, 'Programa para criar vírus', 'Programa usado para ajudar a espalhar e esconder ameaças digitais'),
    ('seed_tecnologia_facil_v1', 'O que é backup?', 0, 'Bloqueio da internet', 'Atualização automática de informações importantes'),
    ('seed_tecnologia_facil_v1', 'O que é backup?', 1, 'Formatação do computador', 'Proteção por senha de informações importantes'),
    ('seed_tecnologia_facil_v1', 'O que é backup?', 2, 'Exclusão de arquivos', 'Organização de informações importantes em pastas'),
    ('seed_tecnologia_facil_v1', 'Por que fazer backup?', 1, 'Para criar vírus', 'Para acelerar o computador em caso de lentidão'),
    ('seed_tecnologia_facil_v1', 'Por que fazer backup?', 2, 'Para aumentar o tamanho da tela', 'Para liberar espaço em caso de falta de memória'),
    ('seed_tecnologia_facil_v1', 'Por que fazer backup?', 3, 'Para desligar o computador', 'Para impedir o acesso em caso de ataque ou invasão'),
    ('seed_tecnologia_facil_v1', 'O que é nuvem (cloud)?', 0, 'Um cabo de energia', 'Serviço que permite enviar e receber mensagens pela internet'),
    ('seed_tecnologia_facil_v1', 'O que é nuvem (cloud)?', 1, 'Um teclado', 'Programa que permite abrir e visualizar páginas pela internet'),
    ('seed_tecnologia_facil_v1', 'O que é nuvem (cloud)?', 3, 'Um antivírus físico', 'Aparelho que permite guardar e transportar dados sem internet'),
    ('seed_tecnologia_facil_v1', 'Qual é um exemplo de armazenamento em nuvem?', 0, 'Monitor', 'Mozilla Firefox'),
    ('seed_tecnologia_facil_v1', 'Qual é um exemplo de armazenamento em nuvem?', 1, 'Mouse', 'Microsoft Word'),
    ('seed_tecnologia_facil_v1', 'Qual é um exemplo de armazenamento em nuvem?', 3, 'Processador', 'Adobe Reader'),
    ('seed_tecnologia_facil_v1', 'O que é Bluetooth?', 1, 'Sistema operacional', 'Tecnologia para comunicação por cabo entre dispositivos próximos'),
    ('seed_tecnologia_facil_v1', 'O que é Bluetooth?', 2, 'Navegador', 'Tecnologia para acesso à internet em dispositivos distantes'),
    ('seed_tecnologia_facil_v1', 'O que é Bluetooth?', 3, 'Memória interna', 'Tecnologia para localização de dispositivos através de satélites'),
    ('seed_tecnologia_facil_v1', 'O que é GPS?', 0, 'Programa antivírus', 'Sistema usado para comunicação e mensagens'),
    ('seed_tecnologia_facil_v1', 'O que é GPS?', 1, 'Tipo de arquivo', 'Sistema usado para armazenamento e cópia de dados'),
    ('seed_tecnologia_facil_v1', 'O que é GPS?', 3, 'Sistema de armazenamento', 'Sistema usado para pesquisa e acesso a sites'),
    ('seed_tecnologia_facil_v1', 'O que é QR Code?', 1, 'Um vírus', 'Código que pode ser digitado por usuários para acessar contas'),
    ('seed_tecnologia_facil_v1', 'O que é QR Code?', 2, 'Uma senha', 'Programa que pode ser instalado em dispositivos para proteger dados'),
    ('seed_tecnologia_facil_v1', 'O que é QR Code?', 3, 'Um processador', 'Cabo que pode ser ligado a dispositivos para transmitir informações'),
    ('seed_tecnologia_facil_v1', 'O que é uma rede social?', 1, 'Um cabo', 'Plataforma onde pessoas guardam arquivos e documentos'),
    ('seed_tecnologia_facil_v1', 'O que é uma rede social?', 2, 'Um componente do computador', 'Plataforma onde pessoas compram produtos e serviços'),
    ('seed_tecnologia_facil_v1', 'O que é uma rede social?', 3, 'Um sistema operacional', 'Plataforma onde pessoas pesquisam sites e notícias'),
    ('seed_tecnologia_facil_v1', 'Qual destes é uma rede social?', 0, 'Excel', 'Google Drive'),
    ('seed_tecnologia_facil_v1', 'Qual destes é uma rede social?', 2, 'Windows', 'Microsoft Word'),
    ('seed_tecnologia_facil_v1', 'O que é download?', 0, 'Apagar arquivos', 'Copiar arquivos de um dispositivo para outro aparelho'),
    ('seed_tecnologia_facil_v1', 'O que é download?', 2, 'Enviar arquivos', 'Enviar arquivos de um dispositivo para a internet'),
    ('seed_tecnologia_facil_v1', 'O que é download?', 3, 'Desligar internet', 'Abrir arquivos da internet sem guardar no dispositivo'),
    ('seed_tecnologia_facil_v1', 'O que é upload?', 0, 'Apagar arquivos', 'Baixar arquivos de um serviço online para um dispositivo'),
    ('seed_tecnologia_facil_v1', 'O que é upload?', 2, 'Desligar o computador', 'Apagar arquivos de um dispositivo e de um serviço online'),
    ('seed_tecnologia_facil_v1', 'O que é upload?', 3, 'Criar uma senha', 'Copiar arquivos de um dispositivo para outro dispositivo'),
    ('seed_tecnologia_facil_v1', 'O que é segurança digital?', 1, 'Melhorar imagens', 'Organização de dispositivos, dados e arquivos em pastas'),
    ('seed_tecnologia_facil_v1', 'O que é segurança digital?', 2, 'Aumentar volume do computador', 'Velocidade de dispositivos, redes e conexões à internet'),
    ('seed_tecnologia_facil_v1', 'O que é segurança digital?', 3, 'Apenas criar aplicativos', 'Criação de aplicativos, programas e sites para usuários'),
    ('seed_tecnologia_facil_v1', 'Qual atitude aumenta a segurança online?', 1, 'Instalar qualquer programa', 'Usar a mesma senha e evitar atualizações'),
    ('seed_tecnologia_facil_v1', 'Qual atitude aumenta a segurança online?', 2, 'Compartilhar senhas', 'Usar senhas curtas e abrir mensagens estranhas'),
    ('seed_tecnologia_facil_v1', 'Qual atitude aumenta a segurança online?', 3, 'Abrir qualquer mensagem', 'Instalar aplicativos de fontes desconhecidas'),
    ('seed_tecnologia_facil_v1', 'Por que a tecnologia é importante atualmente?', 0, 'Porque funciona sem energia', 'Porque garante segurança, privacidade e proteção total dos dados'),
    ('seed_tecnologia_facil_v1', 'Por que a tecnologia é importante atualmente?', 1, 'Porque elimina todas as atividades humanas', 'Porque funciona sozinha, sem pessoas, sem energia e sem manutenção'),
    ('seed_tecnologia_facil_v1', 'Por que a tecnologia é importante atualmente?', 2, 'Porque substitui todas as pessoas', 'Porque dispensa estudo, trabalho, esforço e dedicação das pessoas')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Tecnologia fácil lote 2: perguntas 26 a 50 do seed v1 (migration 033): % alternativa(s) errada(s) atualizada(s) (esperado: 69).', v_updated;
END $$;
