-- Explicações pedagógicas (BE-004) — Tecnologia fácil lote 1: perguntas 1 a 25 do seed v1 (migration 033).
-- Preenche questions.explanation com o "Por quê?" de cada pergunta (linguagem simples e curta, conforme
-- docs/quiz-v2-rodadas-e-feedback.md), já coerente com as alternativas novas da migration 300. Só atualiza perguntas
-- que ainda NÃO têm explicação, então é idempotente e nunca sobrescreve texto já escrito. Não altera perguntas nem
-- alternativas. Se alguma pergunta já não existir, é simplesmente ignorada (nunca falha, para não impedir o arranque
-- do backend: as migrations correm no deploy). O runner já envolve o ficheiro numa transação.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE questions q
  SET explanation = v.explanation
  FROM (VALUES
    ('seed_tecnologia_facil_v1', 'O que é um computador?', 'O computador é um aparelho eletrônico que processa informações, guarda dados e consegue enviá-los para outros aparelhos. É por isso que serve para escrever, estudar, jogar e ver vídeos, tudo na mesma máquina.'),
    ('seed_tecnologia_facil_v1', 'Qual componente é considerado o "cérebro" do computador?', 'O processador, ou CPU, executa as instruções dos programas e faz os cálculos, por isso é chamado de cérebro do computador. A memória, o disco e a placa de vídeo ajudam, mas é o processador que comanda o trabalho.'),
    ('seed_tecnologia_facil_v1', 'Qual é a função principal do teclado?', 'O teclado é um dispositivo de entrada: serve para escrever textos e dar comandos ao computador. Mostrar imagens é função do monitor, e mover o cursor na tela é função do mouse.'),
    ('seed_tecnologia_facil_v1', 'Qual dispositivo apresenta informações visuais ao usuário?', 'O monitor é a tela que mostra ao usuário o que o computador está fazendo, como textos, imagens e vídeos. É um dispositivo de saída. O mouse, o microfone e o scanner servem para enviar informações ao computador.'),
    ('seed_tecnologia_facil_v1', 'O que é um smartphone?', 'Smartphone é um telefone inteligente: além de fazer chamadas, executa aplicativos e acessa a internet. Isso o diferencia de um telefone simples, que só faz chamadas e envia mensagens, e de um computador portátil.'),
    ('seed_tecnologia_facil_v1', 'Qual sistema operacional é muito utilizado em smartphones?', 'Android é um sistema operacional, o programa que faz o aparelho funcionar e permite instalar aplicativos. É um dos mais usados em smartphones. Bluetooth, HDMI e USB são formas de ligar aparelhos, não sistemas operacionais.'),
    ('seed_tecnologia_facil_v1', 'O que é um aplicativo?', 'Aplicativo, ou app, é um programa feito para uma tarefa específica, como conversar, tirar fotos ou ouvir música. Não é o sistema que controla todo o aparelho, nem uma peça física, nem a conta do usuário.'),
    ('seed_tecnologia_facil_v1', 'Onde normalmente são instalados aplicativos em um smartphone?', 'Os aplicativos são baixados e instalados a partir da loja de aplicativos do aparelho, como a Google Play ou a App Store. É lá que se procura, se instala e se atualiza cada app.'),
    ('seed_tecnologia_facil_v1', 'O que é a internet?', 'A internet é uma rede mundial que liga milhões de dispositivos e permite trocar mensagens, ver páginas e acessar informações. Não é um aparelho nem um programa: é a rede que conecta tudo. Uma rede dentro de casa é só uma rede local.'),
    ('seed_tecnologia_facil_v1', 'Qual destes é um navegador de internet?', 'Google Chrome é um navegador: o programa usado para abrir páginas e serviços da internet. Google Drive, Microsoft Word e Adobe Reader são outros tipos de programas e serviços, usados para guardar, escrever e ler arquivos.'),
    ('seed_tecnologia_facil_v1', 'Para que serve um navegador?', 'O navegador serve para acessar sites e serviços da internet, como pesquisar, ler notícias ou ver vídeos. Proteger o computador é papel do antivírus, e editar textos é papel de programas como o editor de documentos.'),
    ('seed_tecnologia_facil_v1', 'O que é um site?', 'Um site é um conjunto de páginas ligadas entre si e disponíveis na internet, que se abrem pelo navegador. O navegador é o programa que mostra o site, e os arquivos guardados no computador não formam um site.'),
    ('seed_tecnologia_facil_v1', 'O que é um endereço de site?', 'O endereço de um site é o nome usado para encontrar a página na internet, como www.exemplo.com. Funciona como o endereço de uma casa: diz onde ir. Não é o nome do usuário, a senha nem o número de um aparelho na rede.'),
    ('seed_tecnologia_facil_v1', 'O que significa Wi-Fi?', 'Wi-Fi é a tecnologia que liga aparelhos a uma rede sem usar cabos, por meio de ondas de rádio. A ligação por cabo é outra forma de conectar. Wi-Fi não é um serviço de armazenamento nem um tipo de carregador.'),
    ('seed_tecnologia_facil_v1', 'Para que serve um roteador?', 'O roteador recebe a internet e a distribui para os dispositivos da casa, por cabo ou por Wi-Fi. Não serve para guardar arquivos, reproduzir vídeos ou ligar o computador à energia elétrica.'),
    ('seed_tecnologia_facil_v1', 'O que é uma senha?', 'A senha é um código secreto que protege uma conta ou um aparelho e deixa entrar só quem a conhece. O nome de usuário apenas identifica a conta, e o e-mail ou a foto de perfil também não protegem nada.'),
    ('seed_tecnologia_facil_v1', 'Por que devemos evitar compartilhar senhas?', 'Quem tem a sua senha pode entrar na conta, ler mensagens e usar os seus dados. Por isso ela não deve ser compartilhada: para proteger contas e informações pessoais. A senha não tem relação com a lentidão do aparelho, com o espaço ou com os dados móveis.'),
    ('seed_tecnologia_facil_v1', 'O que é um arquivo?', 'Arquivo é uma unidade digital onde se guardam informações, como um texto, uma foto, uma música ou um vídeo. Cada arquivo tem um nome e fica guardado no computador ou no celular. Não é um programa nem uma peça física.'),
    ('seed_tecnologia_facil_v1', 'Qual destes é um exemplo de arquivo?', 'Uma fotografia digital é um arquivo: fica guardada no aparelho como informação eletrônica e pode ser aberta, copiada e enviada. O pen drive e a pasta guardam arquivos, e o aplicativo de mensagens os envia, mas nenhum deles é um arquivo.'),
    ('seed_tecnologia_facil_v1', 'O que é uma pasta no computador?', 'A pasta é um local do computador usado para organizar arquivos, como uma gaveta que junta documentos do mesmo assunto. Ajuda a encontrar as coisas depressa. Editar ou enviar arquivos são tarefas de programas, não da pasta.'),
    ('seed_tecnologia_facil_v1', 'O que é memória de armazenamento?', 'A memória de armazenamento é o espaço onde ficam guardados dados e arquivos, mesmo com o aparelho desligado. Não se confunde com a memória que executa os programas em andamento, com a velocidade do processador nem com a qualidade da imagem.'),
    ('seed_tecnologia_facil_v1', 'Qual destes é um dispositivo de armazenamento?', 'O pen drive é um dispositivo de armazenamento: guarda arquivos e pode ser ligado a diferentes aparelhos. O cabo USB e o carregador portátil só ligam ou alimentam aparelhos, e a placa de som trata o áudio, sem guardar arquivos.'),
    ('seed_tecnologia_facil_v1', 'Para que serve um pen drive?', 'O pen drive serve para guardar e transportar arquivos digitais, como documentos e fotografias, de um aparelho para outro. Ele não fornece internet, não imprime documentos e não carrega aparelhos.'),
    ('seed_tecnologia_facil_v1', 'O que é uma fotografia digital?', 'Fotografia digital é uma imagem guardada em formato eletrônico, como um arquivo no celular ou no computador. Pode ser vista na tela, copiada e enviada, ao contrário da foto impressa em papel.'),
    ('seed_tecnologia_facil_v1', 'O que é vídeo digital?', 'Vídeo digital é uma sequência de imagens guardada em formato eletrônico que, ao passar depressa, dá a sensação de movimento, em geral com som. Uma fotografia é só uma imagem, e um texto ou um áudio sozinhos não formam um vídeo.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Tecnologia fácil lote 1: perguntas 1 a 25 do seed v1: % pergunta(s) atualizada(s) (esperado: 25).', v_updated;
END $$;
