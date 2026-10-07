-- Explicações pedagógicas (BE-004) — Tecnologia fácil lote 4: perguntas 26 a 47 do seed v2 (migration 035) e as 3 do seed v3 (migration 095).
-- Preenche questions.explanation com o "Por quê?" de cada pergunta (linguagem simples e curta, conforme
-- docs/quiz-v2-rodadas-e-feedback.md), já coerente com as alternativas novas da migration 306. Só atualiza perguntas
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
    ('seed_tecnologia_facil_v2', 'O que geralmente significa "HD" em relação à qualidade de vídeo?', 'HD, nesse contexto, significa alta definição: um vídeo com mais detalhes e nitidez do que o de definição comum. Não tem a ver com disco híbrido nem com dados hospedados.'),
    ('seed_tecnologia_facil_v2', 'Para que serve principalmente uma câmera digital?', 'A câmera digital serve para capturar imagens e vídeos em formato digital, que podem ser guardados e enviados. Reproduzir sons, guardar arquivos ou exibir textos são funções de outros aparelhos.'),
    ('seed_tecnologia_facil_v2', 'O que é um QR Code?', 'O QR Code é um código visual, feito de quadradinhos, que armazena informações e é lido por dispositivos compatíveis, como a câmera do celular. Não é um código digitado, nem uma imagem comum, nem um programa instalado.'),
    ('seed_tecnologia_facil_v2', 'Para que um QR Code pode ser utilizado?', 'O QR Code pode abrir um site ou mostrar informações depois de ser digitalizado pela câmera do aparelho. Não guarda senhas, não corrige erros do sistema e não apaga arquivos.'),
    ('seed_tecnologia_facil_v2', 'Por que alguns aplicativos solicitam permissões?', 'Alguns aplicativos pedem permissões para acessar funções ou informações do aparelho, como a câmera ou a localização, que os recursos deles precisam para funcionar. Elas não atualizam o sistema, não cobram nada e não bloqueiam outros aplicativos.'),
    ('seed_tecnologia_facil_v2', 'Qual é uma boa prática ao conceder permissões a um aplicativo?', 'Antes de aceitar uma permissão, vale ver se ela faz sentido para o que o aplicativo faz. Uma lanterna que pede acesso aos contatos, por exemplo, merece desconfiança. Aceitar sem ler ou desativar as proteções aumenta o risco.'),
    ('seed_tecnologia_facil_v2', 'O que é uma notificação?', 'Notificação é um aviso enviado por um aplicativo ou pelo sistema para informar o usuário sobre algum evento, como uma mensagem nova. Não é uma cópia de segurança, um programa de proteção ou uma conta.'),
    ('seed_tecnologia_facil_v2', 'O que é modo avião em um smartphone?', 'O modo avião é uma configuração que desativa ou limita as comunicações sem fio do aparelho, como o Wi-Fi, o Bluetooth e a rede móvel. Não bloqueia anúncios, não melhora conexões e não reinicia aplicativos.'),
    ('seed_tecnologia_facil_v2', 'Para que serve normalmente o GPS de um smartphone?', 'O GPS determina ou estima onde o dispositivo está, usando sistemas de posicionamento por satélite. Serve para mapas e navegação. Não ajusta o sinal, não guarda mapas e não mede a luz do ambiente.'),
    ('seed_tecnologia_facil_v2', 'O que é localização em tempo real?', 'Localização em tempo real é a informação sobre a posição atual ou recente de um dispositivo ou pessoa, conforme o serviço utilizado, como o aplicativo de mapas. Não é um histórico antigo, uma velocidade nem um endereço fixo.'),
    ('seed_tecnologia_facil_v2', 'O que é um arquivo PDF?', 'O PDF é um formato de documento criado para manter a mesma aparência em diferentes dispositivos, sem que o layout mude. Não foi criado para edição rápida, para reduzir imagens nem para ser um programa que abre documentos.'),
    ('seed_tecnologia_facil_v2', 'Qual aplicativo pode ser utilizado para visualizar muitos arquivos PDF?', 'Um leitor de PDF é o aplicativo usado para abrir e visualizar arquivos nesse formato. A câmera, o gravador de voz e a calculadora têm outras funções.'),
    ('seed_tecnologia_facil_v2', 'Por que organizar arquivos em pastas pode ser útil?', 'Organizar arquivos em pastas facilita encontrar e organizar as informações, como numa gaveta com divisórias. Não instala programas, não recupera arquivos apagados e não melhora a conexão.'),
    ('seed_tecnologia_facil_v2', 'O que é um arquivo compactado?', 'Arquivo compactado é um arquivo, ou um conjunto de arquivos, reduzido ou agrupado por uma ferramenta de compressão, o que facilita guardar e enviar. Não é um arquivo protegido, um e-mail nem uma imagem convertida.'),
    ('seed_tecnologia_facil_v2', 'Qual formato é frequentemente utilizado para arquivos compactados?', 'O formato .zip é muito usado para arquivos compactados. O .jpg é imagem, o .html é página da web e o .mp3 é áudio.'),
    ('seed_tecnologia_facil_v2', 'O que significa sincronizar dados?', 'Sincronizar é manter as informações atualizadas e iguais entre diferentes dispositivos ou serviços, como as fotos do celular e da nuvem. Não é guardar com senha, remover repetidos nem conectar à mesma rede.'),
    ('seed_tecnologia_facil_v2', 'Qual pode ser um exemplo de sincronização?', 'Quando as fotos do smartphone são automaticamente atualizadas num serviço de nuvem, as informações ficam iguais nos dois lugares: é sincronização. Enviar por e-mail, editar ou imprimir não mantém os dados atualizados entre aparelhos.'),
    ('seed_tecnologia_facil_v2', 'O que é uma conta de armazenamento em nuvem?', 'A conta de armazenamento em nuvem é a conta usada para acessar um serviço que guarda dados remotamente, como o Google Drive. Não serve para chamadas, filmes ou pagamento de contas.'),
    ('seed_tecnologia_facil_v2', 'O que é streaming?', 'Streaming é a transmissão de áudio ou vídeo que começa a tocar enquanto os dados ainda estão sendo recebidos, sem esperar o arquivo inteiro. Gravar, comprimir ou copiar para um cartão são outras coisas.'),
    ('seed_tecnologia_facil_v2', 'Qual é uma possível vantagem do streaming?', 'A vantagem do streaming é poder começar a ver ou ouvir o conteúdo sem baixar o arquivo inteiro antes. Ele precisa de internet e de servidores e gasta dados, e serve para ver ou ouvir, não para guardar.'),
    ('seed_tecnologia_facil_v2', 'O que é uma captura de tela (screenshot)?', 'A captura de tela, ou screenshot, é uma imagem que registra o que está exibido na tela naquele momento. Não é uma foto da câmera, uma gravação em vídeo nem um programa que espia o que se digita.'),
    ('seed_tecnologia_facil_v2', 'Qual é uma boa atitude ao receber uma mensagem com um link suspeito?', 'Ao receber um link suspeito, o melhor é verificar a origem e só clicar depois de confirmar que ele é legítimo, para evitar golpes. Clicar para testar, avisar os contatos ou responder ao remetente pode piorar o problema.'),
    ('seed_tecnologia_facil_v3', 'O que é uma tela sensível ao toque (touchscreen)?', 'Touchscreen é a tela sensível ao toque: o usuário controla o aparelho tocando nela com os dedos, sem mouse nem teclado. É a forma comum de uso dos smartphones e tablets, e não depende de voz nem de movimentos.'),
    ('seed_tecnologia_facil_v3', 'Para que serve uma webcam?', 'A webcam captura imagens e vídeo e por isso permite chamadas de vídeo e gravações. Reproduzir músicas, imprimir documentos ou guardar cópias de segurança são funções de outros dispositivos.'),
    ('seed_tecnologia_facil_v3', 'O que é o "modo escuro" (dark mode) em aplicativos?', 'O modo escuro muda a aparência do aplicativo para um fundo escuro, o que dá conforto visual e, em algumas telas, economiza bateria. Não é fundo claro, nem uma opção de segurança ou de desempenho.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Tecnologia fácil lote 4: perguntas 26 a 47 do seed v2 (migration 035) e as 3 do seed v3 (migration 095): % pergunta(s) atualizada(s) (esperado: 25).', v_updated;
END $$;
