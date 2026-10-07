-- Alternativas (BE-003, regularização) — Tecnologia fácil lote 4: perguntas 26 a 47 do seed v2 (migration 035) e as 3 do seed v3 (migration 095).
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
    ('seed_tecnologia_facil_v2', 'Para que serve principalmente uma câmera digital?', 0, 'Substituir o processador', 'Reproduzir sons e músicas em formato digital'),
    ('seed_tecnologia_facil_v2', 'Para que serve principalmente uma câmera digital?', 2, 'Criar conexões Wi-Fi', 'Guardar fotos e arquivos em formato digital'),
    ('seed_tecnologia_facil_v2', 'Para que serve principalmente uma câmera digital?', 3, 'Aumentar a memória RAM', 'Exibir textos e imagens em formato digital'),
    ('seed_tecnologia_facil_v2', 'O que é um QR Code?', 0, 'Formato de áudio', 'Código numérico que pode armazenar senhas e ser digitado por usuários autorizados'),
    ('seed_tecnologia_facil_v2', 'O que é um QR Code?', 2, 'Tipo de vírus', 'Imagem digital que pode armazenar fotografias e ser aberta por programas compatíveis'),
    ('seed_tecnologia_facil_v2', 'O que é um QR Code?', 3, 'Sistema operacional', 'Programa digital que pode armazenar informações e ser instalado em dispositivos compatíveis'),
    ('seed_tecnologia_facil_v2', 'Para que um QR Code pode ser utilizado?', 0, 'Melhorar a qualidade da câmera', 'Guardar senhas ou proteger informações após ser digitalizado'),
    ('seed_tecnologia_facil_v2', 'Para que um QR Code pode ser utilizado?', 1, 'Aumentar a bateria', 'Corrigir erros ou atualizar o sistema após ser digitalizado'),
    ('seed_tecnologia_facil_v2', 'Para que um QR Code pode ser utilizado?', 3, 'Substituir a memória RAM', 'Apagar arquivos ou limpar o histórico após ser digitalizado'),
    ('seed_tecnologia_facil_v2', 'Por que alguns aplicativos solicitam permissões?', 0, 'Para aumentar fisicamente o armazenamento', 'Para atualizar determinadas funções do sistema necessárias aos seus recursos digitais'),
    ('seed_tecnologia_facil_v2', 'Por que alguns aplicativos solicitam permissões?', 1, 'Para mudar o processador', 'Para cobrar determinadas funções ou informações do usuário necessárias aos seus recursos'),
    ('seed_tecnologia_facil_v2', 'Por que alguns aplicativos solicitam permissões?', 2, 'Para substituir a bateria', 'Para bloquear determinadas funções ou informações do dispositivo usadas por outros aplicativos'),
    ('seed_tecnologia_facil_v2', 'Qual é uma boa prática ao conceder permissões a um aplicativo?', 0, 'Compartilhar a senha do dispositivo', 'Conceder as permissões pedidas para que o aplicativo funcione mais depressa no aparelho'),
    ('seed_tecnologia_facil_v2', 'Qual é uma boa prática ao conceder permissões a um aplicativo?', 1, 'Desativar todas as proteções', 'Desativar as proteções do aparelho para que o aplicativo funcione sem avisos'),
    ('seed_tecnologia_facil_v2', 'Qual é uma boa prática ao conceder permissões a um aplicativo?', 2, 'Aceitar todas sem verificar', 'Aceitar as permissões pedidas sem ler o que o aplicativo vai poder acessar'),
    ('seed_tecnologia_facil_v2', 'O que é uma notificação?', 0, 'Um tipo de processador', 'Cópia guardada por um aplicativo ou sistema para restaurar o usuário após algum problema'),
    ('seed_tecnologia_facil_v2', 'O que é uma notificação?', 2, 'Um arquivo de áudio', 'Programa instalado por um aplicativo ou sistema para proteger o usuário contra algum vírus'),
    ('seed_tecnologia_facil_v2', 'O que é uma notificação?', 3, 'Um cabo de internet', 'Conta criada por um aplicativo ou sistema para identificar o usuário em algum serviço'),
    ('seed_tecnologia_facil_v2', 'O que é modo avião em um smartphone?', 0, 'Programa antivírus', 'Configuração que bloqueia ou filtra determinados anúncios e avisos do dispositivo'),
    ('seed_tecnologia_facil_v2', 'O que é modo avião em um smartphone?', 1, 'Sistema que melhora a câmera', 'Configuração que aumenta ou melhora determinadas conexões sem fio do dispositivo'),
    ('seed_tecnologia_facil_v2', 'O que é modo avião em um smartphone?', 3, 'Modo que aumenta a memória', 'Configuração que desliga ou reinicia determinados aplicativos instalados no dispositivo'),
    ('seed_tecnologia_facil_v2', 'Para que serve normalmente o GPS de um smartphone?', 1, 'Aumentar a capacidade de armazenamento', 'Aumentar ou ajustar a intensidade do sinal do dispositivo usando sistemas de rede'),
    ('seed_tecnologia_facil_v2', 'Para que serve normalmente o GPS de um smartphone?', 2, 'Substituir o Wi-Fi', 'Guardar ou copiar os mapas do dispositivo usando sistemas de armazenamento'),
    ('seed_tecnologia_facil_v2', 'Para que serve normalmente o GPS de um smartphone?', 3, 'Melhorar o áudio', 'Medir ou controlar o brilho da tela do dispositivo usando sensores de luz'),
    ('seed_tecnologia_facil_v2', 'O que é localização em tempo real?', 1, 'Uma senha', 'Informação que representa o histórico antigo de visitas de um site ou conta conforme o serviço utilizado'),
    ('seed_tecnologia_facil_v2', 'O que é localização em tempo real?', 2, 'Uma rede social', 'Informação que representa a velocidade atual ou média de um dispositivo ou rede conforme o serviço utilizado'),
    ('seed_tecnologia_facil_v2', 'O que é localização em tempo real?', 3, 'Um tipo de arquivo', 'Informação que representa o endereço fixo de uma casa, loja ou empresa registrada conforme o serviço utilizado'),
    ('seed_tecnologia_facil_v2', 'O que é um arquivo PDF?', 1, 'Tipo de vírus', 'Formato de documento criado para editar de forma rápida o seu texto em diferentes dispositivos'),
    ('seed_tecnologia_facil_v2', 'O que é um arquivo PDF?', 2, 'Formato exclusivo de áudio', 'Formato de arquivo criado para reduzir de forma automática o tamanho das imagens em diferentes dispositivos'),
    ('seed_tecnologia_facil_v2', 'O que é um arquivo PDF?', 3, 'Sistema operacional', 'Programa de computador criado para abrir de forma segura os documentos em diferentes dispositivos'),
    ('seed_tecnologia_facil_v2', 'Por que organizar arquivos em pastas pode ser útil?', 0, 'Aumenta a capacidade da bateria', 'Facilita a instalação e atualização dos programas'),
    ('seed_tecnologia_facil_v2', 'Por que organizar arquivos em pastas pode ser útil?', 1, 'Impede qualquer perda de dados', 'Facilita a cópia e recuperação dos arquivos apagados'),
    ('seed_tecnologia_facil_v2', 'Por que organizar arquivos em pastas pode ser útil?', 2, 'Aumenta automaticamente a velocidade da internet', 'Facilita a conexão e a navegação em redes sem fio'),
    ('seed_tecnologia_facil_v2', 'O que é um arquivo compactado?', 1, 'Arquivo que só funciona online', 'Arquivo ou conjunto de arquivos protegido ou escondido por uma ferramenta de segurança'),
    ('seed_tecnologia_facil_v2', 'O que é um arquivo compactado?', 2, 'Arquivo que não pode ser aberto', 'Arquivo ou conjunto de arquivos copiado ou enviado por uma ferramenta de e-mail'),
    ('seed_tecnologia_facil_v2', 'O que é um arquivo compactado?', 3, 'Arquivo necessariamente infectado', 'Arquivo ou conjunto de arquivos convertido ou editado por uma ferramenta de imagem'),
    ('seed_tecnologia_facil_v2', 'O que significa sincronizar dados?', 0, 'Formatar o dispositivo', 'Guardar informações protegidas por senha em diferentes dispositivos ou serviços'),
    ('seed_tecnologia_facil_v2', 'O que significa sincronizar dados?', 2, 'Apagar todas as informações', 'Remover informações repetidas de diferentes dispositivos ou serviços'),
    ('seed_tecnologia_facil_v2', 'O que significa sincronizar dados?', 3, 'Desligar a internet', 'Conectar diferentes dispositivos ou serviços à mesma rede sem fio'),
    ('seed_tecnologia_facil_v2', 'Qual pode ser um exemplo de sincronização?', 0, 'Alterar o brilho da tela', 'Fotos de um smartphone serem enviadas manualmente por e-mail a um único contato'),
    ('seed_tecnologia_facil_v2', 'Qual pode ser um exemplo de sincronização?', 2, 'Apagar uma fotografia', 'Fotos de um smartphone serem editadas manualmente por um aplicativo de edição'),
    ('seed_tecnologia_facil_v2', 'Qual pode ser um exemplo de sincronização?', 3, 'Desligar o telefone', 'Fotos de um smartphone serem impressas automaticamente por uma impressora sem fio'),
    ('seed_tecnologia_facil_v2', 'O que é uma conta de armazenamento em nuvem?', 1, 'Uma conta exclusiva para chamadas telefônicas', 'Conta utilizada para acessar um serviço que permite fazer chamadas internacionais'),
    ('seed_tecnologia_facil_v2', 'O que é uma conta de armazenamento em nuvem?', 2, 'Um sistema operacional', 'Conta utilizada para acessar um serviço que permite assistir a filmes e séries'),
    ('seed_tecnologia_facil_v2', 'O que é uma conta de armazenamento em nuvem?', 3, 'Um tipo de cartão de memória', 'Conta utilizada para acessar um serviço que permite pagar contas pela internet'),
    ('seed_tecnologia_facil_v2', 'O que é streaming?', 0, 'Formatação do dispositivo', 'Gravação de conteúdo de áudio ou vídeo para edição depois de os dados serem guardados'),
    ('seed_tecnologia_facil_v2', 'O que é streaming?', 1, 'Download obrigatório de todos os arquivos antes de assistir', 'Download completo do conteúdo de áudio ou vídeo antes de começar a reprodução'),
    ('seed_tecnologia_facil_v2', 'O que é streaming?', 2, 'Instalação de memória RAM', 'Cópia de conteúdo de áudio ou vídeo para um cartão depois de os dados serem baixados'),
    ('seed_tecnologia_facil_v2', 'Qual é uma possível vantagem do streaming?', 0, 'Funciona sempre sem internet', 'Permite começar a consumir determinado conteúdo sem necessariamente gastar dados móveis ou Wi-Fi'),
    ('seed_tecnologia_facil_v2', 'Qual é uma possível vantagem do streaming?', 1, 'Não utiliza dados', 'Permite começar a guardar determinado conteúdo sem necessariamente ocupar espaço de armazenamento'),
    ('seed_tecnologia_facil_v2', 'Qual é uma possível vantagem do streaming?', 3, 'Não depende de servidores', 'Permite começar a consumir determinado conteúdo sem necessariamente depender de internet ou servidores'),
    ('seed_tecnologia_facil_v2', 'O que é uma captura de tela (screenshot)?', 0, 'Programa de edição', 'Imagem que registra o conteúdo guardado na câmera em determinado momento'),
    ('seed_tecnologia_facil_v2', 'O que é uma captura de tela (screenshot)?', 1, 'Arquivo de áudio', 'Vídeo que registra o conteúdo exibido na tela durante determinado período'),
    ('seed_tecnologia_facil_v2', 'O que é uma captura de tela (screenshot)?', 3, 'Vírus que bloqueia o computador', 'Programa que registra o histórico exibido no navegador em determinado momento'),
    ('seed_tecnologia_facil_v2', 'Qual é uma boa atitude ao receber uma mensagem com um link suspeito?', 0, 'Compartilhar com todos os contatos', 'Avisar os contatos e clicar no link para confirmar se ele é legítimo'),
    ('seed_tecnologia_facil_v2', 'Qual é uma boa atitude ao receber uma mensagem com um link suspeito?', 1, 'Clicar imediatamente', 'Clicar rapidamente e fechar a página caso ela pareça suspeita'),
    ('seed_tecnologia_facil_v2', 'Qual é uma boa atitude ao receber uma mensagem com um link suspeito?', 3, 'Enviar a senha ao remetente', 'Responder ao remetente e pedir que ele confirme se o link é legítimo'),
    ('seed_tecnologia_facil_v3', 'O que é uma tela sensível ao toque (touchscreen)?', 1, 'Tipo de tela usada apenas em computadores antigos', 'Tela que permite controlar o dispositivo usando um mouse conectado por cabo'),
    ('seed_tecnologia_facil_v3', 'O que é uma tela sensível ao toque (touchscreen)?', 2, 'Tela que só funciona com um teclado externo conectado', 'Tela que permite controlar o dispositivo falando comandos em voz alta'),
    ('seed_tecnologia_facil_v3', 'O que é uma tela sensível ao toque (touchscreen)?', 3, 'Acessório separado que precisa ser comprado à parte do celular', 'Tela que permite controlar o dispositivo movendo o aparelho com as mãos'),
    ('seed_tecnologia_facil_v3', 'Para que serve uma webcam?', 0, 'Guardar arquivos baixados da internet', 'Reproduzir sons e músicas, permitindo chamadas de voz e gravações'),
    ('seed_tecnologia_facil_v3', 'Para que serve uma webcam?', 2, 'Aumentar a velocidade da internet', 'Imprimir imagens e textos, permitindo cópias de documentos em papel'),
    ('seed_tecnologia_facil_v3', 'Para que serve uma webcam?', 3, 'Proteger o computador contra vírus', 'Guardar arquivos e fotos, permitindo cópias de segurança e restauração'),
    ('seed_tecnologia_facil_v3', 'O que é o "modo escuro" (dark mode) em aplicativos?', 0, 'Modo que bloqueia o acesso à internet', 'Opção de aparência com fundo claro, usada para leitura de texto e destaque de cores em algumas telas'),
    ('seed_tecnologia_facil_v3', 'O que é o "modo escuro" (dark mode) em aplicativos?', 1, 'Função que desliga o aplicativo automaticamente à noite', 'Opção de segurança com acesso restrito, usada para proteção de contas e bloqueio de anúncios'),
    ('seed_tecnologia_facil_v3', 'O que é o "modo escuro" (dark mode) em aplicativos?', 3, 'Recurso que apaga todos os dados do aplicativo', 'Opção de desempenho com menos animações, usada para rapidez e economia de dados em alguns aplicativos')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Tecnologia fácil lote 4: perguntas 26 a 47 do seed v2 (migration 035) e as 3 do seed v3 (migration 095): % alternativa(s) errada(s) atualizada(s) (esperado: 66).', v_updated;
END $$;
