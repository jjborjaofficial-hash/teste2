-- Alternativas (BE-003, regularização) — Tecnologia fácil lote 3: perguntas 1 a 25 do seed v2 (migration 035).
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
    ('seed_tecnologia_facil_v2', 'Qual é a principal função de um navegador de internet?', 0, 'Substituir o sistema operacional', 'Criar e editar documentos de texto no computador'),
    ('seed_tecnologia_facil_v2', 'Qual é a principal função de um navegador de internet?', 1, 'Aumentar a memória RAM do computador', 'Proteger e limpar arquivos infectados no computador'),
    ('seed_tecnologia_facil_v2', 'Qual é a principal função de um navegador de internet?', 3, 'Carregar fisicamente a bateria', 'Guardar e organizar arquivos em pastas do computador'),
    ('seed_tecnologia_facil_v2', 'O que acontece normalmente quando um arquivo é colocado na "Lixeira" de um computador?', 0, 'Ele é transformado em PDF', 'Ele é apagado de forma definitiva e não pode mais ser recuperado depois de excluído da lixeira'),
    ('seed_tecnologia_facil_v2', 'O que acontece normalmente quando um arquivo é colocado na "Lixeira" de um computador?', 2, 'Ele é duplicado', 'Ele é copiado para a nuvem e pode ser acessado de outros aparelhos conectados'),
    ('seed_tecnologia_facil_v2', 'O que acontece normalmente quando um arquivo é colocado na "Lixeira" de um computador?', 3, 'Ele é automaticamente enviado para a internet', 'Ele é compactado para ocupar menos espaço e pode ser aberto novamente mais tarde'),
    ('seed_tecnologia_facil_v2', 'Para que serve principalmente o mouse?', 0, 'Aumentar a velocidade da internet', 'Inserir textos e números nos campos da interface'),
    ('seed_tecnologia_facil_v2', 'Para que serve principalmente o mouse?', 1, 'Armazenar documentos', 'Exibir imagens, vídeos e janelas na tela do computador'),
    ('seed_tecnologia_facil_v2', 'Para que serve principalmente o mouse?', 3, 'Reproduzir energia', 'Conectar periféricos e dispositivos às portas do computador'),
    ('seed_tecnologia_facil_v2', 'O que significa fazer download?', 1, 'Apagar um arquivo', 'Transferir dados do dispositivo do usuário para um sistema remoto'),
    ('seed_tecnologia_facil_v2', 'O que significa fazer download?', 2, 'Enviar um arquivo para outra pessoa', 'Copiar dados de um dispositivo do usuário para outro dispositivo'),
    ('seed_tecnologia_facil_v2', 'O que significa fazer download?', 3, 'Desligar o computador', 'Converter dados de um formato para outro no dispositivo do usuário final'),
    ('seed_tecnologia_facil_v2', 'O que significa fazer upload?', 0, 'Apagar dados', 'Receber dados de um servidor ou serviço remoto para o dispositivo'),
    ('seed_tecnologia_facil_v2', 'O que significa fazer upload?', 2, 'Instalar uma bateria', 'Copiar dados do dispositivo para outro aparelho próximo'),
    ('seed_tecnologia_facil_v2', 'O que significa fazer upload?', 3, 'Desligar a internet', 'Compactar dados do dispositivo antes de guardá-los na memória'),
    ('seed_tecnologia_facil_v2', 'Qual é a finalidade principal de uma extensão de arquivo?', 0, 'Indicar a senha do arquivo', 'Indicar o nome ou autor do arquivo'),
    ('seed_tecnologia_facil_v2', 'Qual é a finalidade principal de uma extensão de arquivo?', 1, 'Aumentar o tamanho do arquivo', 'Indicar o local ou pasta do arquivo'),
    ('seed_tecnologia_facil_v2', 'Qual é a finalidade principal de uma extensão de arquivo?', 2, 'Proteger automaticamente o arquivo contra vírus', 'Indicar a data de criação do arquivo'),
    ('seed_tecnologia_facil_v2', 'Para que serve o Bluetooth?', 0, 'Substituir o sistema operacional', 'Permitir transmissão de dados por cabo entre dispositivos compatíveis'),
    ('seed_tecnologia_facil_v2', 'Para que serve o Bluetooth?', 1, 'Aumentar a capacidade do armazenamento', 'Permitir acesso à internet sem fio dentro de casa em dispositivos compatíveis'),
    ('seed_tecnologia_facil_v2', 'Para que serve o Bluetooth?', 2, 'Criar páginas da internet', 'Permitir localização e navegação por satélite em dispositivos compatíveis'),
    ('seed_tecnologia_facil_v2', 'Qual destes dispositivos pode normalmente ser conectado a um smartphone por Bluetooth?', 0, 'Papel impresso', 'Pen drive comum'),
    ('seed_tecnologia_facil_v2', 'Qual destes dispositivos pode normalmente ser conectado a um smartphone por Bluetooth?', 1, 'Cartão de memória sem adaptador', 'Cartão de memória comum'),
    ('seed_tecnologia_facil_v2', 'Qual destes dispositivos pode normalmente ser conectado a um smartphone por Bluetooth?', 3, 'Cabo de energia desligado', 'Carregador com cabo'),
    ('seed_tecnologia_facil_v2', 'O que é uma rede Wi-Fi protegida por senha?', 0, 'Uma rede exclusiva para computadores antigos', 'Uma rede sem fio que bloqueia sites para evitar distrações dos usuários'),
    ('seed_tecnologia_facil_v2', 'O que é uma rede Wi-Fi protegida por senha?', 1, 'Uma rede que não transmite dados', 'Uma rede com fio que exige cabo para permitir acesso'),
    ('seed_tecnologia_facil_v2', 'O que é uma rede Wi-Fi protegida por senha?', 2, 'Uma rede que funciona somente sem internet', 'Uma rede sem fio que limita a velocidade para poupar dados'),
    ('seed_tecnologia_facil_v2', 'Qual é uma boa prática ao utilizar uma rede Wi-Fi pública?', 0, 'Instalar qualquer aplicativo recomendado por desconhecidos', 'Aceitar conexões automáticas em redes abertas quando houver sinal disponível no local'),
    ('seed_tecnologia_facil_v2', 'Qual é uma boa prática ao utilizar uma rede Wi-Fi pública?', 2, 'Desativar todas as proteções', 'Desativar as atualizações de segurança do aparelho enquanto estiver conectado à rede'),
    ('seed_tecnologia_facil_v2', 'Qual é uma boa prática ao utilizar uma rede Wi-Fi pública?', 3, 'Compartilhar a senha bancária', 'Compartilhar dados pessoais com outros usuários da rede para facilitar a conexão'),
    ('seed_tecnologia_facil_v2', 'O que é um link?', 1, 'Um antivírus', 'Elemento que pode proteger o usuário contra vírus, golpes ou ataques'),
    ('seed_tecnologia_facil_v2', 'O que é um link?', 2, 'Um tipo de memória RAM', 'Elemento que pode guardar o histórico de páginas, arquivos ou downloads'),
    ('seed_tecnologia_facil_v2', 'O que é um link?', 3, 'Um componente do processador', 'Elemento que pode traduzir o texto de páginas, sites ou documentos'),
    ('seed_tecnologia_facil_v2', 'O que acontece normalmente quando se clica em um link?', 0, 'O sistema operacional é substituído', 'O aparelho tenta instalar o recurso associado ao link no sistema operacional'),
    ('seed_tecnologia_facil_v2', 'O que acontece normalmente quando se clica em um link?', 1, 'O computador necessariamente desliga', 'O navegador tenta enviar os dados do usuário para o dono do link'),
    ('seed_tecnologia_facil_v2', 'O que acontece normalmente quando se clica em um link?', 3, 'A memória RAM é apagada', 'O aplicativo tenta guardar o recurso associado ao link na nuvem'),
    ('seed_tecnologia_facil_v2', 'O que é uma conta de usuário em um serviço digital?', 0, 'Um componente físico', 'Aplicativo utilizado para instalar e atualizar determinados recursos do aparelho'),
    ('seed_tecnologia_facil_v2', 'O que é uma conta de usuário em um serviço digital?', 2, 'Um arquivo de imagem', 'Arquivo utilizado para guardar e enviar determinados recursos do serviço'),
    ('seed_tecnologia_facil_v2', 'O que é uma conta de usuário em um serviço digital?', 3, 'Um tipo de cabo', 'Senha utilizada para proteger e bloquear determinados recursos do serviço'),
    ('seed_tecnologia_facil_v2', 'Por que uma senha diferente para cada serviço pode ser mais segura?', 0, 'Porque elimina a necessidade de autenticação', 'Porque facilita lembrar as senhas de todos os serviços'),
    ('seed_tecnologia_facil_v2', 'Por que uma senha diferente para cada serviço pode ser mais segura?', 2, 'Porque impede qualquer tentativa de fraude', 'Porque dispensa o uso de antivírus e de atualizações nos aparelhos'),
    ('seed_tecnologia_facil_v2', 'Por que uma senha diferente para cada serviço pode ser mais segura?', 3, 'Porque aumenta automaticamente a velocidade da internet', 'Porque aumenta a velocidade de acesso aos serviços digitais'),
    ('seed_tecnologia_facil_v2', 'O que é uma atualização de segurança?', 1, 'Aumento do volume do dispositivo', 'Alteração de software destinada, entre outras coisas, a mudar o visual e os ícones do aparelho'),
    ('seed_tecnologia_facil_v2', 'O que é uma atualização de segurança?', 2, 'Troca do monitor', 'Alteração de hardware destinada, entre outras coisas, a melhorar o desempenho do aparelho'),
    ('seed_tecnologia_facil_v2', 'O que é uma atualização de segurança?', 3, 'Exclusão de documentos', 'Alteração de software destinada, entre outras coisas, a liberar espaço no aparelho'),
    ('seed_tecnologia_facil_v2', 'Por que não é recomendado instalar programas de fontes desconhecidas?', 1, 'Eles garantem maior segurança', 'Eles podem ser mais caros do que os aplicativos oficiais'),
    ('seed_tecnologia_facil_v2', 'Por que não é recomendado instalar programas de fontes desconhecidas?', 2, 'Eles sempre ocupam pouco espaço', 'Eles podem não funcionar em celulares de outras marcas'),
    ('seed_tecnologia_facil_v2', 'Por que não é recomendado instalar programas de fontes desconhecidas?', 3, 'Eles aumentam a duração da bateria', 'Eles podem estar em idiomas que o usuário não entende'),
    ('seed_tecnologia_facil_v2', 'O que é armazenamento interno de um smartphone?', 0, 'Velocidade da internet', 'Espaço utilizado para executar aplicativos, jogos e outros processos em andamento'),
    ('seed_tecnologia_facil_v2', 'O que é armazenamento interno de um smartphone?', 1, 'Qualidade da câmera', 'Espaço utilizado para guardar fotos, vídeos e outros dados em serviços online'),
    ('seed_tecnologia_facil_v2', 'O que é armazenamento interno de um smartphone?', 2, 'Capacidade do carregador', 'Espaço utilizado para guardar aplicativos, fotos, vídeos e outros dados num cartão externo'),
    ('seed_tecnologia_facil_v2', 'O que pode acontecer quando o armazenamento do smartphone fica quase cheio?', 1, 'A internet fica necessariamente mais rápida', 'A conexão com a internet pode ficar mais lenta e instável ao navegar em sites'),
    ('seed_tecnologia_facil_v2', 'O que pode acontecer quando o armazenamento do smartphone fica quase cheio?', 2, 'A bateria passa a carregar mais rápido', 'O dispositivo pode desligar sozinho e apagar todos os aplicativos instalados'),
    ('seed_tecnologia_facil_v2', 'O que pode acontecer quando o armazenamento do smartphone fica quase cheio?', 3, 'A câmera automaticamente fica melhor', 'A tela pode ficar com menos brilho e o som do aparelho pode ficar mais baixo'),
    ('seed_tecnologia_facil_v2', 'Qual é a função principal de um cartão de memória?', 0, 'Substituir o processador', 'Acelerar a execução de determinados tipos de aplicativos em dispositivos compatíveis'),
    ('seed_tecnologia_facil_v2', 'Qual é a função principal de um cartão de memória?', 1, 'Melhorar automaticamente a câmera', 'Melhorar a qualidade de captura de determinados tipos de fotos em dispositivos compatíveis'),
    ('seed_tecnologia_facil_v2', 'Qual é a função principal de um cartão de memória?', 3, 'Aumentar a velocidade da rede móvel', 'Ampliar o alcance do sinal de determinados tipos de redes em dispositivos compatíveis'),
    ('seed_tecnologia_facil_v2', 'O que é resolução de uma imagem?', 1, 'Tamanho físico do celular', 'Quantidade de cores representadas por seus tons em pixels'),
    ('seed_tecnologia_facil_v2', 'O que é resolução de uma imagem?', 2, 'Velocidade da internet', 'Quantidade de espaço ocupado por seu arquivo em megabytes'),
    ('seed_tecnologia_facil_v2', 'O que é resolução de uma imagem?', 3, 'Capacidade da bateria', 'Tamanho físico da tela onde a imagem é exibida em polegadas'),
    ('seed_tecnologia_facil_v2', 'O que é um pixel?', 0, 'Uma conexão Wi-Fi', 'Uma pequena peça que compõe o processador do aparelho'),
    ('seed_tecnologia_facil_v2', 'O que é um pixel?', 1, 'Um tipo de vírus', 'Uma pequena unidade que mede a velocidade da internet'),
    ('seed_tecnologia_facil_v2', 'O que é um pixel?', 2, 'Um sistema operacional', 'Uma pequena unidade que mede o tamanho de um arquivo')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Tecnologia fácil lote 3: perguntas 1 a 25 do seed v2 (migration 035): % alternativa(s) errada(s) atualizada(s) (esperado: 63).', v_updated;
END $$;
