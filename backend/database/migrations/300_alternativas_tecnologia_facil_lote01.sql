-- Alternativas (BE-003, regularização) — Tecnologia fácil lote 1: perguntas 1 a 25 do seed v1 (migration 033).
-- Segue docs/quiz-v2-alternativas-padrao.md e a regra do dono: a resposta CERTA NÃO muda; só o texto das alternativas
-- ERRADAS é ajustado para ter tamanho e forma parecidos aos da certa. Tecnologia usa a faixa de migrations 300+
-- (Finanças usa 141+ e Produtividade 200+), para não colidir com as outras sessões.
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
    ('seed_tecnologia_facil_v1', 'O que é um computador?', 0, 'Um tipo de internet', 'Rede mundial capaz de ligar, organizar e distribuir informações'),
    ('seed_tecnologia_facil_v1', 'O que é um computador?', 2, 'Apenas uma tela para assistir vídeos', 'Aparelho eletrônico capaz de imprimir, digitalizar e copiar documentos'),
    ('seed_tecnologia_facil_v1', 'O que é um computador?', 3, 'Um programa de edição', 'Programa capaz de criar, editar e guardar documentos de texto'),
    ('seed_tecnologia_facil_v1', 'Qual componente é considerado o "cérebro" do computador?', 0, 'Impressora', 'Memória (RAM)'),
    ('seed_tecnologia_facil_v1', 'Qual componente é considerado o "cérebro" do computador?', 2, 'Teclado', 'Disco rígido (HD)'),
    ('seed_tecnologia_facil_v1', 'Qual componente é considerado o "cérebro" do computador?', 3, 'Monitor', 'Placa de vídeo (GPU)'),
    ('seed_tecnologia_facil_v1', 'Qual é a função principal do teclado?', 0, 'Exibir imagens', 'Mostrar textos e imagens ao usuário do computador'),
    ('seed_tecnologia_facil_v1', 'Qual é a função principal do teclado?', 2, 'Guardar arquivos', 'Guardar arquivos e programas dentro do computador'),
    ('seed_tecnologia_facil_v1', 'Qual é a função principal do teclado?', 3, 'Aumentar a velocidade da internet', 'Controlar o movimento do cursor na tela do computador'),
    ('seed_tecnologia_facil_v1', 'O que é um smartphone?', 1, 'Um computador sem tela', 'Computador portátil com teclado físico e capacidade de executar programas'),
    ('seed_tecnologia_facil_v1', 'O que é um smartphone?', 2, 'Apenas um telefone para chamadas', 'Telefone simples com capacidade de fazer chamadas e enviar mensagens'),
    ('seed_tecnologia_facil_v1', 'O que é um smartphone?', 3, 'Um tipo de impressora', 'Relógio digital com capacidade de medir o tempo e marcar alarmes'),
    ('seed_tecnologia_facil_v1', 'O que é um aplicativo?', 0, 'Cabo de internet', 'Sistema que controla o funcionamento geral de um dispositivo'),
    ('seed_tecnologia_facil_v1', 'O que é um aplicativo?', 1, 'Tipo de bateria', 'Peça física instalada dentro de um dispositivo eletrônico'),
    ('seed_tecnologia_facil_v1', 'O que é um aplicativo?', 3, 'Peça física do computador', 'Conta criada para entrar numa rede social ou serviço'),
    ('seed_tecnologia_facil_v1', 'Onde normalmente são instalados aplicativos em um smartphone?', 1, 'Processador', 'Navegador de internet'),
    ('seed_tecnologia_facil_v1', 'Onde normalmente são instalados aplicativos em um smartphone?', 2, 'Teclado', 'Agenda de contatos'),
    ('seed_tecnologia_facil_v1', 'Onde normalmente são instalados aplicativos em um smartphone?', 3, 'Monitor', 'Galeria de fotografias'),
    ('seed_tecnologia_facil_v1', 'O que é a internet?', 0, 'Uma peça do computador', 'Rede local que liga computadores dentro de uma casa'),
    ('seed_tecnologia_facil_v1', 'O que é a internet?', 1, 'Um tipo de memória', 'Programa que permite abrir e guardar documentos digitais'),
    ('seed_tecnologia_facil_v1', 'O que é a internet?', 3, 'Apenas um aplicativo', 'Serviço que permite enviar mensagens e fazer chamadas'),
    ('seed_tecnologia_facil_v1', 'Qual destes é um navegador de internet?', 0, 'Android', 'Google Drive'),
    ('seed_tecnologia_facil_v1', 'Qual destes é um navegador de internet?', 2, 'WhatsApp', 'Microsoft Word'),
    ('seed_tecnologia_facil_v1', 'Qual destes é um navegador de internet?', 3, 'Windows', 'Adobe Reader'),
    ('seed_tecnologia_facil_v1', 'Para que serve um navegador?', 0, 'Aumentar a bateria', 'Proteger o computador contra vírus e ameaças'),
    ('seed_tecnologia_facil_v1', 'Para que serve um navegador?', 1, 'Guardar arquivos automaticamente', 'Editar textos e criar apresentações de slides'),
    ('seed_tecnologia_facil_v1', 'Para que serve um navegador?', 3, 'Criar componentes físicos', 'Guardar e organizar fotografias e documentos'),
    ('seed_tecnologia_facil_v1', 'O que é um site?', 0, 'Um processador', 'Programa usado para abrir páginas na internet'),
    ('seed_tecnologia_facil_v1', 'O que é um site?', 2, 'Um aplicativo físico', 'Conjunto de aplicativos disponíveis numa loja virtual'),
    ('seed_tecnologia_facil_v1', 'O que é um site?', 3, 'Um cabo de computador', 'Conjunto de arquivos guardados num computador'),
    ('seed_tecnologia_facil_v1', 'O que é um endereço de site?', 1, 'Modelo do teclado', 'Nome utilizado para identificar um usuário numa conta'),
    ('seed_tecnologia_facil_v1', 'O que é um endereço de site?', 2, 'Senha do computador', 'Código utilizado para proteger o acesso a uma página'),
    ('seed_tecnologia_facil_v1', 'O que é um endereço de site?', 3, 'Número da bateria', 'Número utilizado para identificar um aparelho numa rede'),
    ('seed_tecnologia_facil_v1', 'O que significa Wi-Fi?', 1, 'Tipo de computador', 'Tecnologia de conexão por cabo a uma rede'),
    ('seed_tecnologia_facil_v1', 'O que significa Wi-Fi?', 2, 'Aplicativo de mensagens', 'Tecnologia de carregamento sem fio de aparelhos'),
    ('seed_tecnologia_facil_v1', 'O que significa Wi-Fi?', 3, 'Sistema operacional', 'Tecnologia de armazenamento de dados na nuvem'),
    ('seed_tecnologia_facil_v1', 'Para que serve um roteador?', 0, 'Guardar documentos', 'Armazenar arquivos para vários dispositivos'),
    ('seed_tecnologia_facil_v1', 'Para que serve um roteador?', 1, 'Aumentar o tamanho da tela', 'Ligar o computador à rede elétrica da casa'),
    ('seed_tecnologia_facil_v1', 'Para que serve um roteador?', 2, 'Criar aplicativos', 'Reproduzir vídeos e músicas em vários aparelhos'),
    ('seed_tecnologia_facil_v1', 'O que é uma senha?', 0, 'Tipo de arquivo', 'Nome usado para identificar e encontrar uma conta ou dispositivo'),
    ('seed_tecnologia_facil_v1', 'O que é uma senha?', 1, 'Nome do usuário', 'Endereço usado para enviar e receber mensagens eletrônicas'),
    ('seed_tecnologia_facil_v1', 'O que é uma senha?', 2, 'Modelo do computador', 'Imagem usada para identificar e personalizar uma conta'),
    ('seed_tecnologia_facil_v1', 'Por que devemos evitar compartilhar senhas?', 1, 'Para melhorar a câmera', 'Para evitar que o aparelho fique lento com o tempo'),
    ('seed_tecnologia_facil_v1', 'Por que devemos evitar compartilhar senhas?', 2, 'Para aumentar a velocidade da internet', 'Para economizar espaço de armazenamento do aparelho'),
    ('seed_tecnologia_facil_v1', 'Por que devemos evitar compartilhar senhas?', 3, 'Para instalar aplicativos', 'Para reduzir o consumo de dados móveis'),
    ('seed_tecnologia_facil_v1', 'O que é um arquivo?', 0, 'Um aplicativo obrigatório', 'Programa digital onde informações são processadas'),
    ('seed_tecnologia_facil_v1', 'O que é um arquivo?', 2, 'Um cabo', 'Unidade física onde informações são guardadas'),
    ('seed_tecnologia_facil_v1', 'O que é um arquivo?', 3, 'Uma peça física do computador', 'Tela digital onde informações são apresentadas'),
    ('seed_tecnologia_facil_v1', 'Qual destes é um exemplo de arquivo?', 0, 'Teclado', 'Pen drive'),
    ('seed_tecnologia_facil_v1', 'Qual destes é um exemplo de arquivo?', 1, 'Processador', 'Pasta de documentos'),
    ('seed_tecnologia_facil_v1', 'Qual destes é um exemplo de arquivo?', 3, 'Monitor', 'Aplicativo de mensagens'),
    ('seed_tecnologia_facil_v1', 'O que é uma pasta no computador?', 1, 'Uma rede social', 'Programa usado para editar arquivos'),
    ('seed_tecnologia_facil_v1', 'O que é uma pasta no computador?', 2, 'Um vírus', 'Cabo usado para transferir arquivos'),
    ('seed_tecnologia_facil_v1', 'O que é uma pasta no computador?', 3, 'Um navegador', 'Aplicativo usado para enviar arquivos'),
    ('seed_tecnologia_facil_v1', 'O que é memória de armazenamento?', 0, 'Velocidade do teclado', 'Espaço usado para executar programas em andamento'),
    ('seed_tecnologia_facil_v1', 'O que é memória de armazenamento?', 1, 'Qualidade da câmera', 'Velocidade usada para processar dados e comandos'),
    ('seed_tecnologia_facil_v1', 'O que é memória de armazenamento?', 2, 'Tamanho do monitor', 'Capacidade usada para exibir imagens e vídeos'),
    ('seed_tecnologia_facil_v1', 'Qual destes é um dispositivo de armazenamento?', 0, 'Microfone', 'Cabo USB'),
    ('seed_tecnologia_facil_v1', 'Qual destes é um dispositivo de armazenamento?', 2, 'Coluna', 'Carregador portátil'),
    ('seed_tecnologia_facil_v1', 'Qual destes é um dispositivo de armazenamento?', 3, 'Mouse', 'Placa de som'),
    ('seed_tecnologia_facil_v1', 'Para que serve um pen drive?', 0, 'Criar internet', 'Transmitir e receber sinais de internet'),
    ('seed_tecnologia_facil_v1', 'Para que serve um pen drive?', 1, 'Aumentar o brilho da tela', 'Imprimir e digitalizar documentos em papel'),
    ('seed_tecnologia_facil_v1', 'Para que serve um pen drive?', 3, 'Fazer chamadas telefônicas', 'Carregar e alimentar aparelhos eletrônicos'),
    ('seed_tecnologia_facil_v1', 'O que é uma fotografia digital?', 0, 'Imagem somente impressa', 'Imagem impressa em papel fotográfico'),
    ('seed_tecnologia_facil_v1', 'O que é uma fotografia digital?', 1, 'Um cabo', 'Imagem transmitida por sinal de televisão'),
    ('seed_tecnologia_facil_v1', 'O que é uma fotografia digital?', 2, 'Tipo de aplicativo', 'Programa usado para editar imagens'),
    ('seed_tecnologia_facil_v1', 'O que é vídeo digital?', 0, 'Um documento de texto', 'Sequência de textos armazenados em formato eletrônico'),
    ('seed_tecnologia_facil_v1', 'O que é vídeo digital?', 1, 'Um programa antivírus', 'Sequência de gravações de áudio armazenadas em formato eletrônico'),
    ('seed_tecnologia_facil_v1', 'O que é vídeo digital?', 2, 'Apenas uma fotografia', 'Imagem única armazenada em formato eletrônico')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Tecnologia fácil lote 1: perguntas 1 a 25 do seed v1: % alternativa(s) errada(s) atualizada(s) (esperado: 69).', v_updated;
END $$;
