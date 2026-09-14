-- Migration/seed: conteúdo Tecnologia, nível Fácil — lote 2 (47 de 50 perguntas)
-- Fonte: segundo lote de perguntas fornecido pelo proprietário do projeto (mesmo
-- padrão dos lotes anteriores: 003_tecnologia_facil.sql e 004_tecnologia_medio.sql).
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes anteriores, não
-- é decisão de negócio): no lote original, as 50 respostas corretas eram TODAS a
-- alternativa "A". Posição redistribuída por pergunta com seed fixa (44 — distinta
-- das seeds 42 e 43 já usadas, para não repetir o mesmo padrão de posições) e
-- distribuição controlada (13/12/13/12 entre A/B/C/D), reprodutível — o conteúdo
-- pedagógico permanece exatamente como enviado, só a ORDEM de exibição mudou.
--
-- DEDUPLICAÇÃO APLICADA (resolvendo a sobreposição sinalizada nas versões
-- anteriores deste arquivo, e a mesma que a migration 031 tentava cobrir sem
-- sucesso — 031 roda durante `migrate up`, antes de qualquer seed inserir
-- dados, então nunca encontrava nada para remover): estas 3 perguntas têm o
-- MESMO título de uma pergunta já existente em 003_tecnologia_facil.sql, na
-- mesma categoria e dificuldade, só com alternativas erradas reescritas com
-- palavras diferentes — foram REMOVIDAS deste arquivo (não inseridas de novo):
--   - "O que é um aplicativo?"
--   - "O que é uma chamada de vídeo?"
--   - "O que é uma pasta no computador?"
-- Sobraram 47 perguntas únicas.
--
-- `xp_reward` (10) e `time_limit_seconds` (15): mesmo racional já registrado em
-- 004_tecnologia_medio.sql (sem tabela oficial de XP por dificuldade).
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

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_tecnologia_facil_v2') THEN
    RAISE NOTICE 'Perguntas de Tecnologia (fácil, lote 2) já foram inseridas anteriormente — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_tec_facil2 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'easy', v.statement, 15, 10, 'seed_tecnologia_facil_v2'
    FROM (VALUES
      ('Qual é a principal função de um navegador de internet?'),
      ('O que acontece normalmente quando um arquivo é colocado na "Lixeira" de um computador?'),
      ('Qual destes dispositivos é usado principalmente para introduzir texto no computador?'),
      ('Para que serve principalmente o mouse?'),
      ('O que significa fazer download?'),
      ('O que significa fazer upload?'),
      ('Qual é a finalidade principal de uma extensão de arquivo?'),
      ('Qual destas extensões normalmente identifica uma imagem?'),
      ('Qual destas extensões normalmente está associada a um arquivo de áudio?'),
      ('Qual destas extensões normalmente identifica um documento de texto simples?'),
      ('Para que serve o Bluetooth?'),
      ('Qual destes dispositivos pode normalmente ser conectado a um smartphone por Bluetooth?'),
      ('O que é uma rede Wi-Fi protegida por senha?'),
      ('Qual é uma boa prática ao utilizar uma rede Wi-Fi pública?'),
      ('O que é um link?'),
      ('O que acontece normalmente quando se clica em um link?'),
      ('O que é uma conta de usuário em um serviço digital?'),
      ('Por que uma senha diferente para cada serviço pode ser mais segura?'),
      ('O que é uma atualização de segurança?'),
      ('Por que não é recomendado instalar programas de fontes desconhecidas?'),
      ('O que é armazenamento interno de um smartphone?'),
      ('O que pode acontecer quando o armazenamento do smartphone fica quase cheio?'),
      ('Qual é a função principal de um cartão de memória?'),
      ('O que é resolução de uma imagem?'),
      ('O que é um pixel?'),
      ('O que geralmente significa "HD" em relação à qualidade de vídeo?'),
      ('Para que serve principalmente uma câmera digital?'),
      ('O que é um QR Code?'),
      ('Para que um QR Code pode ser utilizado?'),
      ('Por que alguns aplicativos solicitam permissões?'),
      ('Qual é uma boa prática ao conceder permissões a um aplicativo?'),
      ('O que é uma notificação?'),
      ('O que é modo avião em um smartphone?'),
      ('Para que serve normalmente o GPS de um smartphone?'),
      ('O que é localização em tempo real?'),
      ('O que é um arquivo PDF?'),
      ('Qual aplicativo pode ser utilizado para visualizar muitos arquivos PDF?'),
      ('Por que organizar arquivos em pastas pode ser útil?'),
      ('O que é um arquivo compactado?'),
      ('Qual formato é frequentemente utilizado para arquivos compactados?'),
      ('O que significa sincronizar dados?'),
      ('Qual pode ser um exemplo de sincronização?'),
      ('O que é uma conta de armazenamento em nuvem?'),
      ('O que é streaming?'),
      ('Qual é uma possível vantagem do streaming?'),
      ('O que é uma captura de tela (screenshot)?'),
      ('Qual é uma boa atitude ao receber uma mensagem com um link suspeito?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_tec_facil2 q
    JOIN (VALUES
      ('Qual é a principal função de um navegador de internet?', 'Substituir o sistema operacional', FALSE, 0),
      ('Qual é a principal função de um navegador de internet?', 'Aumentar a memória RAM do computador', FALSE, 1),
      ('Qual é a principal função de um navegador de internet?', 'Acessar e visualizar conteúdos disponíveis na web', TRUE, 2),
      ('Qual é a principal função de um navegador de internet?', 'Carregar fisicamente a bateria', FALSE, 3),
      ('O que acontece normalmente quando um arquivo é colocado na "Lixeira" de um computador?', 'Ele é transformado em PDF', FALSE, 0),
      ('O que acontece normalmente quando um arquivo é colocado na "Lixeira" de um computador?', 'Ele é marcado para exclusão e pode permanecer recuperável até a lixeira ser esvaziada', TRUE, 1),
      ('O que acontece normalmente quando um arquivo é colocado na "Lixeira" de um computador?', 'Ele é duplicado', FALSE, 2),
      ('O que acontece normalmente quando um arquivo é colocado na "Lixeira" de um computador?', 'Ele é automaticamente enviado para a internet', FALSE, 3),
      ('Qual destes dispositivos é usado principalmente para introduzir texto no computador?', 'Monitor', FALSE, 0),
      ('Qual destes dispositivos é usado principalmente para introduzir texto no computador?', 'Projetor', FALSE, 1),
      ('Qual destes dispositivos é usado principalmente para introduzir texto no computador?', 'Coluna de som', FALSE, 2),
      ('Qual destes dispositivos é usado principalmente para introduzir texto no computador?', 'Teclado', TRUE, 3),
      ('Para que serve principalmente o mouse?', 'Aumentar a velocidade da internet', FALSE, 0),
      ('Para que serve principalmente o mouse?', 'Armazenar documentos', FALSE, 1),
      ('Para que serve principalmente o mouse?', 'Controlar o ponteiro e interagir com elementos da interface', TRUE, 2),
      ('Para que serve principalmente o mouse?', 'Reproduzir energia', FALSE, 3),
      ('O que significa fazer download?', 'Transferir dados de um sistema remoto para o dispositivo do usuário', TRUE, 0),
      ('O que significa fazer download?', 'Apagar um arquivo', FALSE, 1),
      ('O que significa fazer download?', 'Enviar um arquivo para outra pessoa', FALSE, 2),
      ('O que significa fazer download?', 'Desligar o computador', FALSE, 3),
      ('O que significa fazer upload?', 'Apagar dados', FALSE, 0),
      ('O que significa fazer upload?', 'Enviar dados do dispositivo para um servidor ou serviço remoto', TRUE, 1),
      ('O que significa fazer upload?', 'Instalar uma bateria', FALSE, 2),
      ('O que significa fazer upload?', 'Desligar a internet', FALSE, 3),
      ('Qual é a finalidade principal de uma extensão de arquivo?', 'Indicar a senha do arquivo', FALSE, 0),
      ('Qual é a finalidade principal de uma extensão de arquivo?', 'Aumentar o tamanho do arquivo', FALSE, 1),
      ('Qual é a finalidade principal de uma extensão de arquivo?', 'Proteger automaticamente o arquivo contra vírus', FALSE, 2),
      ('Qual é a finalidade principal de uma extensão de arquivo?', 'Indicar o tipo ou formato do arquivo', TRUE, 3),
      ('Qual destas extensões normalmente identifica uma imagem?', '.txt', FALSE, 0),
      ('Qual destas extensões normalmente identifica uma imagem?', '.mp3', FALSE, 1),
      ('Qual destas extensões normalmente identifica uma imagem?', '.jpg', TRUE, 2),
      ('Qual destas extensões normalmente identifica uma imagem?', '.exe', FALSE, 3),
      ('Qual destas extensões normalmente está associada a um arquivo de áudio?', '.html', FALSE, 0),
      ('Qual destas extensões normalmente está associada a um arquivo de áudio?', '.mp3', TRUE, 1),
      ('Qual destas extensões normalmente está associada a um arquivo de áudio?', '.png', FALSE, 2),
      ('Qual destas extensões normalmente está associada a um arquivo de áudio?', '.jpg', FALSE, 3),
      ('Qual destas extensões normalmente identifica um documento de texto simples?', '.mp4', FALSE, 0),
      ('Qual destas extensões normalmente identifica um documento de texto simples?', '.exe', FALSE, 1),
      ('Qual destas extensões normalmente identifica um documento de texto simples?', '.txt', TRUE, 2),
      ('Qual destas extensões normalmente identifica um documento de texto simples?', '.jpg', FALSE, 3),
      ('Para que serve o Bluetooth?', 'Substituir o sistema operacional', FALSE, 0),
      ('Para que serve o Bluetooth?', 'Aumentar a capacidade do armazenamento', FALSE, 1),
      ('Para que serve o Bluetooth?', 'Criar páginas da internet', FALSE, 2),
      ('Para que serve o Bluetooth?', 'Permitir comunicação sem fio de curta distância entre dispositivos compatíveis', TRUE, 3),
      ('Qual destes dispositivos pode normalmente ser conectado a um smartphone por Bluetooth?', 'Papel impresso', FALSE, 0),
      ('Qual destes dispositivos pode normalmente ser conectado a um smartphone por Bluetooth?', 'Cartão de memória sem adaptador', FALSE, 1),
      ('Qual destes dispositivos pode normalmente ser conectado a um smartphone por Bluetooth?', 'Fones de ouvido sem fio', TRUE, 2),
      ('Qual destes dispositivos pode normalmente ser conectado a um smartphone por Bluetooth?', 'Cabo de energia desligado', FALSE, 3),
      ('O que é uma rede Wi-Fi protegida por senha?', 'Uma rede exclusiva para computadores antigos', FALSE, 0),
      ('O que é uma rede Wi-Fi protegida por senha?', 'Uma rede que não transmite dados', FALSE, 1),
      ('O que é uma rede Wi-Fi protegida por senha?', 'Uma rede que funciona somente sem internet', FALSE, 2),
      ('O que é uma rede Wi-Fi protegida por senha?', 'Uma rede sem fio que exige autenticação para permitir acesso', TRUE, 3),
      ('Qual é uma boa prática ao utilizar uma rede Wi-Fi pública?', 'Instalar qualquer aplicativo recomendado por desconhecidos', FALSE, 0),
      ('Qual é uma boa prática ao utilizar uma rede Wi-Fi pública?', 'Evitar realizar atividades sensíveis em redes não confiáveis quando não houver proteção adequada', TRUE, 1),
      ('Qual é uma boa prática ao utilizar uma rede Wi-Fi pública?', 'Desativar todas as proteções', FALSE, 2),
      ('Qual é uma boa prática ao utilizar uma rede Wi-Fi pública?', 'Compartilhar a senha bancária', FALSE, 3),
      ('O que é um link?', 'Elemento que pode direcionar o usuário para outra página, arquivo ou recurso', TRUE, 0),
      ('O que é um link?', 'Um antivírus', FALSE, 1),
      ('O que é um link?', 'Um tipo de memória RAM', FALSE, 2),
      ('O que é um link?', 'Um componente do processador', FALSE, 3),
      ('O que acontece normalmente quando se clica em um link?', 'O sistema operacional é substituído', FALSE, 0),
      ('O que acontece normalmente quando se clica em um link?', 'O computador necessariamente desliga', FALSE, 1),
      ('O que acontece normalmente quando se clica em um link?', 'O navegador ou aplicativo tenta abrir o recurso associado ao link', TRUE, 2),
      ('O que acontece normalmente quando se clica em um link?', 'A memória RAM é apagada', FALSE, 3),
      ('O que é uma conta de usuário em um serviço digital?', 'Um componente físico', FALSE, 0),
      ('O que é uma conta de usuário em um serviço digital?', 'Identidade utilizada para acessar e utilizar determinados recursos do serviço', TRUE, 1),
      ('O que é uma conta de usuário em um serviço digital?', 'Um arquivo de imagem', FALSE, 2),
      ('O que é uma conta de usuário em um serviço digital?', 'Um tipo de cabo', FALSE, 3),
      ('Por que uma senha diferente para cada serviço pode ser mais segura?', 'Porque elimina a necessidade de autenticação', FALSE, 0),
      ('Por que uma senha diferente para cada serviço pode ser mais segura?', 'Porque reduz o impacto caso uma das senhas seja comprometida', TRUE, 1),
      ('Por que uma senha diferente para cada serviço pode ser mais segura?', 'Porque impede qualquer tentativa de fraude', FALSE, 2),
      ('Por que uma senha diferente para cada serviço pode ser mais segura?', 'Porque aumenta automaticamente a velocidade da internet', FALSE, 3),
      ('O que é uma atualização de segurança?', 'Alteração de software destinada, entre outras coisas, a corrigir vulnerabilidades conhecidas', TRUE, 0),
      ('O que é uma atualização de segurança?', 'Aumento do volume do dispositivo', FALSE, 1),
      ('O que é uma atualização de segurança?', 'Troca do monitor', FALSE, 2),
      ('O que é uma atualização de segurança?', 'Exclusão de documentos', FALSE, 3),
      ('Por que não é recomendado instalar programas de fontes desconhecidas?', 'Eles podem conter malware ou software indesejado', TRUE, 0),
      ('Por que não é recomendado instalar programas de fontes desconhecidas?', 'Eles garantem maior segurança', FALSE, 1),
      ('Por que não é recomendado instalar programas de fontes desconhecidas?', 'Eles sempre ocupam pouco espaço', FALSE, 2),
      ('Por que não é recomendado instalar programas de fontes desconhecidas?', 'Eles aumentam a duração da bateria', FALSE, 3),
      ('O que é armazenamento interno de um smartphone?', 'Velocidade da internet', FALSE, 0),
      ('O que é armazenamento interno de um smartphone?', 'Qualidade da câmera', FALSE, 1),
      ('O que é armazenamento interno de um smartphone?', 'Capacidade do carregador', FALSE, 2),
      ('O que é armazenamento interno de um smartphone?', 'Espaço utilizado para guardar aplicativos, fotos, vídeos e outros dados no próprio dispositivo', TRUE, 3),
      ('O que pode acontecer quando o armazenamento do smartphone fica quase cheio?', 'O dispositivo pode apresentar dificuldades para instalar aplicativos ou guardar novos arquivos', TRUE, 0),
      ('O que pode acontecer quando o armazenamento do smartphone fica quase cheio?', 'A internet fica necessariamente mais rápida', FALSE, 1),
      ('O que pode acontecer quando o armazenamento do smartphone fica quase cheio?', 'A bateria passa a carregar mais rápido', FALSE, 2),
      ('O que pode acontecer quando o armazenamento do smartphone fica quase cheio?', 'A câmera automaticamente fica melhor', FALSE, 3),
      ('Qual é a função principal de um cartão de memória?', 'Substituir o processador', FALSE, 0),
      ('Qual é a função principal de um cartão de memória?', 'Melhorar automaticamente a câmera', FALSE, 1),
      ('Qual é a função principal de um cartão de memória?', 'Expandir o espaço disponível para armazenar determinados tipos de dados em dispositivos compatíveis', TRUE, 2),
      ('Qual é a função principal de um cartão de memória?', 'Aumentar a velocidade da rede móvel', FALSE, 3),
      ('O que é resolução de uma imagem?', 'Quantidade de detalhes representados por suas dimensões em pixels', TRUE, 0),
      ('O que é resolução de uma imagem?', 'Tamanho físico do celular', FALSE, 1),
      ('O que é resolução de uma imagem?', 'Velocidade da internet', FALSE, 2),
      ('O que é resolução de uma imagem?', 'Capacidade da bateria', FALSE, 3),
      ('O que é um pixel?', 'Uma conexão Wi-Fi', FALSE, 0),
      ('O que é um pixel?', 'Um tipo de vírus', FALSE, 1),
      ('O que é um pixel?', 'Um sistema operacional', FALSE, 2),
      ('O que é um pixel?', 'Uma pequena unidade que compõe uma imagem digital', TRUE, 3),
      ('O que geralmente significa "HD" em relação à qualidade de vídeo?', 'Dados hospedados', FALSE, 0),
      ('O que geralmente significa "HD" em relação à qualidade de vídeo?', 'Hardware digital', FALSE, 1),
      ('O que geralmente significa "HD" em relação à qualidade de vídeo?', 'Disco híbrido', FALSE, 2),
      ('O que geralmente significa "HD" em relação à qualidade de vídeo?', 'Alta definição', TRUE, 3),
      ('Para que serve principalmente uma câmera digital?', 'Substituir o processador', FALSE, 0),
      ('Para que serve principalmente uma câmera digital?', 'Capturar imagens e vídeos em formato digital', TRUE, 1),
      ('Para que serve principalmente uma câmera digital?', 'Criar conexões Wi-Fi', FALSE, 2),
      ('Para que serve principalmente uma câmera digital?', 'Aumentar a memória RAM', FALSE, 3),
      ('O que é um QR Code?', 'Formato de áudio', FALSE, 0),
      ('O que é um QR Code?', 'Código visual que pode armazenar informações e ser lido por dispositivos compatíveis', TRUE, 1),
      ('O que é um QR Code?', 'Tipo de vírus', FALSE, 2),
      ('O que é um QR Code?', 'Sistema operacional', FALSE, 3),
      ('Para que um QR Code pode ser utilizado?', 'Melhorar a qualidade da câmera', FALSE, 0),
      ('Para que um QR Code pode ser utilizado?', 'Aumentar a bateria', FALSE, 1),
      ('Para que um QR Code pode ser utilizado?', 'Abrir um site ou apresentar informações após ser digitalizado', TRUE, 2),
      ('Para que um QR Code pode ser utilizado?', 'Substituir a memória RAM', FALSE, 3),
      ('Por que alguns aplicativos solicitam permissões?', 'Para aumentar fisicamente o armazenamento', FALSE, 0),
      ('Por que alguns aplicativos solicitam permissões?', 'Para mudar o processador', FALSE, 1),
      ('Por que alguns aplicativos solicitam permissões?', 'Para substituir a bateria', FALSE, 2),
      ('Por que alguns aplicativos solicitam permissões?', 'Para acessar determinadas funções ou informações do dispositivo necessárias aos seus recursos', TRUE, 3),
      ('Qual é uma boa prática ao conceder permissões a um aplicativo?', 'Compartilhar a senha do dispositivo', FALSE, 0),
      ('Qual é uma boa prática ao conceder permissões a um aplicativo?', 'Desativar todas as proteções', FALSE, 1),
      ('Qual é uma boa prática ao conceder permissões a um aplicativo?', 'Aceitar todas sem verificar', FALSE, 2),
      ('Qual é uma boa prática ao conceder permissões a um aplicativo?', 'Verificar se as permissões solicitadas fazem sentido para a função do aplicativo', TRUE, 3),
      ('O que é uma notificação?', 'Um tipo de processador', FALSE, 0),
      ('O que é uma notificação?', 'Aviso enviado por um aplicativo ou sistema para informar o usuário sobre algum evento', TRUE, 1),
      ('O que é uma notificação?', 'Um arquivo de áudio', FALSE, 2),
      ('O que é uma notificação?', 'Um cabo de internet', FALSE, 3),
      ('O que é modo avião em um smartphone?', 'Programa antivírus', FALSE, 0),
      ('O que é modo avião em um smartphone?', 'Sistema que melhora a câmera', FALSE, 1),
      ('O que é modo avião em um smartphone?', 'Configuração que desativa ou restringe determinadas comunicações sem fio do dispositivo', TRUE, 2),
      ('O que é modo avião em um smartphone?', 'Modo que aumenta a memória', FALSE, 3),
      ('Para que serve normalmente o GPS de um smartphone?', 'Determinar ou estimar a localização do dispositivo usando sistemas de posicionamento', TRUE, 0),
      ('Para que serve normalmente o GPS de um smartphone?', 'Aumentar a capacidade de armazenamento', FALSE, 1),
      ('Para que serve normalmente o GPS de um smartphone?', 'Substituir o Wi-Fi', FALSE, 2),
      ('Para que serve normalmente o GPS de um smartphone?', 'Melhorar o áudio', FALSE, 3),
      ('O que é localização em tempo real?', 'Informação que representa a posição atual ou recente de um dispositivo ou pessoa conforme o serviço utilizado', TRUE, 0),
      ('O que é localização em tempo real?', 'Uma senha', FALSE, 1),
      ('O que é localização em tempo real?', 'Uma rede social', FALSE, 2),
      ('O que é localização em tempo real?', 'Um tipo de arquivo', FALSE, 3),
      ('O que é um arquivo PDF?', 'Formato de documento criado para preservar de forma consistente sua apresentação em diferentes dispositivos', TRUE, 0),
      ('O que é um arquivo PDF?', 'Tipo de vírus', FALSE, 1),
      ('O que é um arquivo PDF?', 'Formato exclusivo de áudio', FALSE, 2),
      ('O que é um arquivo PDF?', 'Sistema operacional', FALSE, 3),
      ('Qual aplicativo pode ser utilizado para visualizar muitos arquivos PDF?', 'Aplicativo de câmera', FALSE, 0),
      ('Qual aplicativo pode ser utilizado para visualizar muitos arquivos PDF?', 'Gravador de voz', FALSE, 1),
      ('Qual aplicativo pode ser utilizado para visualizar muitos arquivos PDF?', 'Leitor de PDF', TRUE, 2),
      ('Qual aplicativo pode ser utilizado para visualizar muitos arquivos PDF?', 'Calculadora', FALSE, 3),
      ('Por que organizar arquivos em pastas pode ser útil?', 'Aumenta a capacidade da bateria', FALSE, 0),
      ('Por que organizar arquivos em pastas pode ser útil?', 'Impede qualquer perda de dados', FALSE, 1),
      ('Por que organizar arquivos em pastas pode ser útil?', 'Aumenta automaticamente a velocidade da internet', FALSE, 2),
      ('Por que organizar arquivos em pastas pode ser útil?', 'Facilita a localização e organização das informações', TRUE, 3),
      ('O que é um arquivo compactado?', 'Arquivo ou conjunto de arquivos reduzido ou agrupado por uma ferramenta de compressão', TRUE, 0),
      ('O que é um arquivo compactado?', 'Arquivo que só funciona online', FALSE, 1),
      ('O que é um arquivo compactado?', 'Arquivo que não pode ser aberto', FALSE, 2),
      ('O que é um arquivo compactado?', 'Arquivo necessariamente infectado', FALSE, 3),
      ('Qual formato é frequentemente utilizado para arquivos compactados?', '.jpg', FALSE, 0),
      ('Qual formato é frequentemente utilizado para arquivos compactados?', '.zip', TRUE, 1),
      ('Qual formato é frequentemente utilizado para arquivos compactados?', '.html', FALSE, 2),
      ('Qual formato é frequentemente utilizado para arquivos compactados?', '.mp3', FALSE, 3),
      ('O que significa sincronizar dados?', 'Formatar o dispositivo', FALSE, 0),
      ('O que significa sincronizar dados?', 'Manter informações atualizadas entre diferentes dispositivos ou serviços', TRUE, 1),
      ('O que significa sincronizar dados?', 'Apagar todas as informações', FALSE, 2),
      ('O que significa sincronizar dados?', 'Desligar a internet', FALSE, 3),
      ('Qual pode ser um exemplo de sincronização?', 'Alterar o brilho da tela', FALSE, 0),
      ('Qual pode ser um exemplo de sincronização?', 'Fotos de um smartphone serem automaticamente atualizadas em um serviço de nuvem', TRUE, 1),
      ('Qual pode ser um exemplo de sincronização?', 'Apagar uma fotografia', FALSE, 2),
      ('Qual pode ser um exemplo de sincronização?', 'Desligar o telefone', FALSE, 3),
      ('O que é uma conta de armazenamento em nuvem?', 'Conta utilizada para acessar um serviço que permite armazenar dados remotamente', TRUE, 0),
      ('O que é uma conta de armazenamento em nuvem?', 'Uma conta exclusiva para chamadas telefônicas', FALSE, 1),
      ('O que é uma conta de armazenamento em nuvem?', 'Um sistema operacional', FALSE, 2),
      ('O que é uma conta de armazenamento em nuvem?', 'Um tipo de cartão de memória', FALSE, 3),
      ('O que é streaming?', 'Formatação do dispositivo', FALSE, 0),
      ('O que é streaming?', 'Download obrigatório de todos os arquivos antes de assistir', FALSE, 1),
      ('O que é streaming?', 'Instalação de memória RAM', FALSE, 2),
      ('O que é streaming?', 'Transmissão de conteúdo de áudio ou vídeo para reprodução enquanto os dados são recebidos', TRUE, 3),
      ('Qual é uma possível vantagem do streaming?', 'Funciona sempre sem internet', FALSE, 0),
      ('Qual é uma possível vantagem do streaming?', 'Não utiliza dados', FALSE, 1),
      ('Qual é uma possível vantagem do streaming?', 'Permite começar a consumir determinado conteúdo sem necessariamente baixar o arquivo inteiro antes', TRUE, 2),
      ('Qual é uma possível vantagem do streaming?', 'Não depende de servidores', FALSE, 3),
      ('O que é uma captura de tela (screenshot)?', 'Programa de edição', FALSE, 0),
      ('O que é uma captura de tela (screenshot)?', 'Arquivo de áudio', FALSE, 1),
      ('O que é uma captura de tela (screenshot)?', 'Imagem que registra o conteúdo exibido na tela em determinado momento', TRUE, 2),
      ('O que é uma captura de tela (screenshot)?', 'Vírus que bloqueia o computador', FALSE, 3),
      ('Qual é uma boa atitude ao receber uma mensagem com um link suspeito?', 'Compartilhar com todos os contatos', FALSE, 0),
      ('Qual é uma boa atitude ao receber uma mensagem com um link suspeito?', 'Clicar imediatamente', FALSE, 1),
      ('Qual é uma boa atitude ao receber uma mensagem com um link suspeito?', 'Verificar a origem e evitar clicar antes de confirmar que o link é legítimo', TRUE, 2),
      ('Qual é uma boa atitude ao receber uma mensagem com um link suspeito?', 'Enviar a senha ao remetente', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_tec_facil2;

    RAISE NOTICE '50 perguntas de Tecnologia (fácil, lote 2) inseridas com sucesso.';
  END IF;
END $$;

COMMIT;
