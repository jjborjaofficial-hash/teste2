-- Explicações pedagógicas (BE-004) — Tecnologia fácil lote 3: perguntas 1 a 25 do seed v2 (migration 035).
-- Preenche questions.explanation com o "Por quê?" de cada pergunta (linguagem simples e curta, conforme
-- docs/quiz-v2-rodadas-e-feedback.md), já coerente com as alternativas novas da migration 304. Só atualiza perguntas
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
    ('seed_tecnologia_facil_v2', 'Qual é a principal função de um navegador de internet?', 'O navegador é o programa usado para acessar e visualizar conteúdos disponíveis na web, como sites, vídeos e notícias. Editar textos, proteger o computador e organizar arquivos são tarefas de outros programas.'),
    ('seed_tecnologia_facil_v2', 'O que acontece normalmente quando um arquivo é colocado na "Lixeira" de um computador?', 'Ao colocar um arquivo na lixeira, ele é só marcado para exclusão e, normalmente, pode ser recuperado até a lixeira ser esvaziada. A exclusão definitiva só acontece depois disso. Ele não é copiado para a nuvem nem compactado.'),
    ('seed_tecnologia_facil_v2', 'Qual destes dispositivos é usado principalmente para introduzir texto no computador?', 'O teclado é o dispositivo usado principalmente para introduzir texto no computador. O monitor e o projetor mostram imagens, e a coluna de som reproduz áudio: são dispositivos de saída.'),
    ('seed_tecnologia_facil_v2', 'Para que serve principalmente o mouse?', 'O mouse controla o ponteiro na tela e permite clicar, arrastar e interagir com botões, menus e janelas. Digitar textos é função do teclado, e mostrar imagens é função do monitor.'),
    ('seed_tecnologia_facil_v2', 'O que significa fazer download?', 'Fazer download é transferir dados de um sistema remoto, como um site ou um servidor, para o seu dispositivo. O caminho contrário, do dispositivo para a internet, chama-se upload.'),
    ('seed_tecnologia_facil_v2', 'O que significa fazer upload?', 'Fazer upload é enviar dados do seu dispositivo para um servidor ou serviço remoto, como postar uma foto ou guardar um arquivo na nuvem. Receber dados na direção contrária chama-se download.'),
    ('seed_tecnologia_facil_v2', 'Qual é a finalidade principal de uma extensão de arquivo?', 'A extensão, como .jpg ou .txt, vem no fim do nome e indica o tipo ou o formato do arquivo, o que ajuda o sistema a escolher o programa certo para abri-lo. Ela não guarda nome, local nem data.'),
    ('seed_tecnologia_facil_v2', 'Qual destas extensões normalmente identifica uma imagem?', 'A extensão .jpg identifica uma imagem. O .txt é texto simples, o .mp3 é áudio e o .exe é um programa executável.'),
    ('seed_tecnologia_facil_v2', 'Qual destas extensões normalmente está associada a um arquivo de áudio?', 'A extensão .mp3 identifica um arquivo de áudio, como uma música. O .html é uma página da web, e o .png e o .jpg são imagens.'),
    ('seed_tecnologia_facil_v2', 'Qual destas extensões normalmente identifica um documento de texto simples?', 'A extensão .txt identifica um documento de texto simples, sem formatação. O .mp4 é vídeo, o .exe é um programa executável e o .jpg é uma imagem.'),
    ('seed_tecnologia_facil_v2', 'Para que serve o Bluetooth?', 'O Bluetooth permite comunicação sem fio de curta distância entre dispositivos compatíveis, como o celular e um fone de ouvido. Não usa cabo, não é o Wi-Fi da internet e não faz localização por satélite.'),
    ('seed_tecnologia_facil_v2', 'Qual destes dispositivos pode normalmente ser conectado a um smartphone por Bluetooth?', 'Fones de ouvido sem fio se conectam ao smartphone por Bluetooth. Pen drives, cartões de memória comuns e carregadores com cabo não têm essa conexão sem fio.'),
    ('seed_tecnologia_facil_v2', 'O que é uma rede Wi-Fi protegida por senha?', 'Uma rede Wi-Fi protegida por senha é uma rede sem fio que exige autenticação, ou seja, a senha, para permitir o acesso. Isso impede que qualquer pessoa a use. Ela não é uma rede com fio nem uma rede que bloqueia sites.'),
    ('seed_tecnologia_facil_v2', 'Qual é uma boa prática ao utilizar uma rede Wi-Fi pública?', 'Redes públicas podem ser usadas por outras pessoas, e os dados podem ser vistos por golpistas. Por isso é melhor evitar atividades sensíveis, como acessar o banco, nessas redes quando não há proteção adequada.'),
    ('seed_tecnologia_facil_v2', 'O que é um link?', 'Link é um elemento, como um texto ou botão, que leva o usuário a outra página, arquivo ou recurso quando é clicado. Não é um programa de proteção, não guarda o histórico e não traduz páginas.'),
    ('seed_tecnologia_facil_v2', 'O que acontece normalmente quando se clica em um link?', 'Quando se clica num link, o navegador ou aplicativo tenta abrir o recurso associado a ele, como uma página ou um arquivo. Clicar normalmente não desliga o computador nem instala nada sozinho.'),
    ('seed_tecnologia_facil_v2', 'O que é uma conta de usuário em um serviço digital?', 'A conta de usuário é a identidade que a pessoa usa para entrar num serviço digital e usar os seus recursos, como o e-mail ou a rede social. Não é um programa nem um arquivo, e a senha só protege a conta.'),
    ('seed_tecnologia_facil_v2', 'Por que uma senha diferente para cada serviço pode ser mais segura?', 'Se cada serviço tiver a sua senha, o roubo de uma delas não dá acesso às outras contas, o que reduz o impacto do problema. Repetir a senha faz com que um único vazamento comprometa várias contas.'),
    ('seed_tecnologia_facil_v2', 'O que é uma atualização de segurança?', 'A atualização de segurança altera o software para corrigir falhas conhecidas, que os golpistas poderiam usar para invadir o aparelho. Mudar o visual, melhorar o hardware ou liberar espaço são outros objetivos.'),
    ('seed_tecnologia_facil_v2', 'Por que não é recomendado instalar programas de fontes desconhecidas?', 'Programas de fontes desconhecidas podem trazer malware, que são programas maliciosos, ou outros programas indesejados. Preço, compatibilidade e idioma não são o motivo principal do risco.'),
    ('seed_tecnologia_facil_v2', 'O que é armazenamento interno de um smartphone?', 'O armazenamento interno é o espaço do próprio smartphone onde ficam guardados aplicativos, fotos, vídeos e outros dados. Não é a memória que executa os programas, nem o espaço de serviços online, nem um cartão externo.'),
    ('seed_tecnologia_facil_v2', 'O que pode acontecer quando o armazenamento do smartphone fica quase cheio?', 'Com o armazenamento quase cheio, o smartphone pode ter dificuldade para instalar aplicativos ou guardar novos arquivos, como fotos e vídeos. Isso não muda o brilho da tela nem o volume do som.'),
    ('seed_tecnologia_facil_v2', 'Qual é a função principal de um cartão de memória?', 'O cartão de memória expande o espaço disponível para guardar certos tipos de dados, como fotos e vídeos, em aparelhos compatíveis. Não acelera aplicativos, não melhora fotos e não amplia o sinal de rede.'),
    ('seed_tecnologia_facil_v2', 'O que é resolução de uma imagem?', 'A resolução de uma imagem é a quantidade de detalhes que ela mostra, medida pelas suas dimensões em pixels. Quanto mais pixels, mais detalhe. Não é o número de cores, o tamanho do arquivo nem o tamanho físico da tela.'),
    ('seed_tecnologia_facil_v2', 'O que é um pixel?', 'Pixel é a menor unidade que compõe uma imagem digital: muitos pixels juntos formam a foto que vemos na tela. Não é uma peça do processador, nem uma medida de velocidade da internet, nem uma medida de tamanho de arquivo.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Tecnologia fácil lote 3: perguntas 1 a 25 do seed v2 (migration 035): % pergunta(s) atualizada(s) (esperado: 25).', v_updated;
END $$;
