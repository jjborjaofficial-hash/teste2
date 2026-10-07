-- Alternativas (BE-003, regularização) — Tecnologia médio lote 2: perguntas 26 a 46 do seed medio_v1 (migration 034) e 1 a 4 do seed medio_v2 (migration 055).
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
    ('seed_tecnologia_medio_v1', 'O que é machine learning?', 0, 'Um tipo de computador físico', 'Área da robótica em que máquinas executam movimentos a partir de comandos'),
    ('seed_tecnologia_medio_v1', 'O que é machine learning?', 1, 'Um antivírus', 'Área da segurança digital em que sistemas detectam vírus a partir de assinaturas'),
    ('seed_tecnologia_medio_v1', 'O que é machine learning?', 3, 'Um navegador', 'Área da computação gráfica em que sistemas criam imagens a partir de modelos'),
    ('seed_tecnologia_medio_v1', 'O que é programação?', 0, 'Compra de equipamentos', 'Processo de montar peças para que computadores executem tarefas'),
    ('seed_tecnologia_medio_v1', 'O que é programação?', 1, 'Uso de redes sociais', 'Processo de instalar programas para que computadores executem tarefas'),
    ('seed_tecnologia_medio_v1', 'O que é programação?', 3, 'Montagem de computadores físicos apenas', 'Processo de projetar interfaces para que usuários executem tarefas'),
    ('seed_tecnologia_medio_v1', 'O que é uma linguagem de programação?', 1, 'Idioma falado por pessoas', 'Linguagem utilizada para escrever textos que leitores conseguem interpretar'),
    ('seed_tecnologia_medio_v1', 'O que é uma linguagem de programação?', 2, 'Sistema de pagamento', 'Sistema utilizado para armazenar dados que computadores conseguem organizar'),
    ('seed_tecnologia_medio_v1', 'O que é uma linguagem de programação?', 3, 'Tipo de hardware', 'Dispositivo utilizado para executar instruções que computadores conseguem processar'),
    ('seed_tecnologia_medio_v1', 'O que é aplicativo móvel?', 0, 'Rede Wi-Fi', 'Programa desenvolvido para funcionar em computadores de mesa como desktops'),
    ('seed_tecnologia_medio_v1', 'O que é aplicativo móvel?', 1, 'Peça do telefone', 'Peça desenvolvida para funcionar em dispositivos móveis como smartphones'),
    ('seed_tecnologia_medio_v1', 'O que é aplicativo móvel?', 3, 'Cabo de carregamento', 'Sistema desenvolvido para funcionar em dispositivos móveis como smartphones'),
    ('seed_tecnologia_medio_v1', 'O que é uma atualização de software?', 0, 'Desligar o dispositivo', 'Alteração feita para proteger, copiar arquivos ou restaurar recursos'),
    ('seed_tecnologia_medio_v1', 'O que é uma atualização de software?', 1, 'Remover a internet', 'Instalação feita para melhorar, ocultar problemas ou remover recursos'),
    ('seed_tecnologia_medio_v1', 'O que é uma atualização de software?', 2, 'Apagar todos os dados', 'Configuração feita para reduzir, controlar problemas ou bloquear recursos'),
    ('seed_tecnologia_medio_v1', 'Por que atualizar programas é importante?', 0, 'Remove todos os arquivos', 'Pode liberar espaço e melhorar aparência e organização'),
    ('seed_tecnologia_medio_v1', 'Por que atualizar programas é importante?', 1, 'Impede qualquer uso', 'Pode aumentar memória e melhorar velocidade e conexão'),
    ('seed_tecnologia_medio_v1', 'Por que atualizar programas é importante?', 3, 'Sempre reduz segurança', 'Pode instalar anúncios e mudar configurações e preferências'),
    ('seed_tecnologia_medio_v1', 'O que é banco de dados?', 0, 'Uma tela', 'Sistema organizado para transmitir e receber mensagens'),
    ('seed_tecnologia_medio_v1', 'O que é banco de dados?', 1, 'Um cabo de internet', 'Sistema organizado para proteger e bloquear acessos'),
    ('seed_tecnologia_medio_v1', 'O que é banco de dados?', 3, 'Um antivírus', 'Sistema organizado para compilar e executar programas'),
    ('seed_tecnologia_medio_v1', 'O que é uma aplicação web?', 1, 'Uma bateria', 'Programa instalável através de uma loja de aplicativos no celular'),
    ('seed_tecnologia_medio_v1', 'O que é uma aplicação web?', 2, 'Apenas um documento impresso', 'Programa gravado através de um disco físico inserido no computador'),
    ('seed_tecnologia_medio_v1', 'O que é uma aplicação web?', 3, 'Um componente físico', 'Programa copiado através de um pen drive entre computadores'),
    ('seed_tecnologia_medio_v1', 'O que é servidor?', 0, 'Um vírus', 'Computador ou sistema que consome serviços e recursos de outros dispositivos'),
    ('seed_tecnologia_medio_v1', 'O que é servidor?', 1, 'Apenas um teclado', 'Programa ou aplicativo que envia mensagens e arquivos para outros dispositivos'),
    ('seed_tecnologia_medio_v1', 'O que é servidor?', 2, 'Uma aplicação de mensagens', 'Rede ou conexão que liga serviços e recursos entre outros dispositivos'),
    ('seed_tecnologia_medio_v1', 'O que é endereço IP?', 0, 'Tipo de memória', 'Identificação alfabética atribuída a sites em uma rede'),
    ('seed_tecnologia_medio_v1', 'O que é endereço IP?', 1, 'Nome de aplicativo', 'Identificação numérica atribuída a usuários em um aplicativo'),
    ('seed_tecnologia_medio_v1', 'O que é endereço IP?', 3, 'Senha de usuário', 'Identificação visual atribuída a perfis em uma rede social'),
    ('seed_tecnologia_medio_v1', 'O que é domínio de internet?', 0, 'Um arquivo temporário', 'Número utilizado para identificar um aparelho na internet'),
    ('seed_tecnologia_medio_v1', 'O que é domínio de internet?', 1, 'Um vírus', 'Código utilizado para proteger um site na internet'),
    ('seed_tecnologia_medio_v1', 'O que é domínio de internet?', 2, 'Um processador', 'Programa utilizado para visualizar um site na internet'),
    ('seed_tecnologia_medio_v1', 'O que é código-fonte?', 0, 'Um documento físico', 'Conjunto de arquivos copiados por usuários para instalar um software'),
    ('seed_tecnologia_medio_v1', 'O que é código-fonte?', 1, 'Um cabo', 'Conjunto de mensagens enviadas por sistemas para avisar um usuário'),
    ('seed_tecnologia_medio_v1', 'O que é código-fonte?', 2, 'Uma imagem', 'Conjunto de dados guardados por servidores para identificar um usuário'),
    ('seed_tecnologia_medio_v1', 'O que é código aberto (open source)?', 1, 'Programa sempre pago', 'Software cujo código pode ser vendido ou escondido conforme seu fabricante exige'),
    ('seed_tecnologia_medio_v1', 'O que é código aberto (open source)?', 2, 'Software sem código', 'Software cujo uso pode ser gratuito ou limitado conforme seu anúncio permite'),
    ('seed_tecnologia_medio_v1', 'O que é código aberto (open source)?', 3, 'Sistema sem segurança', 'Software cujo código pode ser invadido ou alterado sem a licença do autor'),
    ('seed_tecnologia_medio_v1', 'O que é API?', 0, 'Memória do computador', 'Interface que permite visualização de telas em diferentes sistemas ou aparelhos'),
    ('seed_tecnologia_medio_v1', 'O que é API?', 1, 'Sistema operacional', 'Sistema que permite execução de programas em diferentes aparelhos ou redes'),
    ('seed_tecnologia_medio_v1', 'O que é API?', 2, 'Tipo de bateria', 'Protocolo que permite conexão de aparelhos entre diferentes redes ou provedores'),
    ('seed_tecnologia_medio_v1', 'Para que serve uma API?', 0, 'Substituir a internet', 'Permitir instalação e atualização de programas entre sistemas'),
    ('seed_tecnologia_medio_v1', 'Para que serve uma API?', 2, 'Criar vírus', 'Permitir proteção e bloqueio de acessos entre sistemas'),
    ('seed_tecnologia_medio_v1', 'Para que serve uma API?', 3, 'Aumentar fisicamente o computador', 'Permitir edição e organização de imagens entre sistemas'),
    ('seed_tecnologia_medio_v1', 'O que é criptografia?', 0, 'Exclusão de arquivos', 'Técnica de recuperar informações transformando dados para restaurar acesso perdido'),
    ('seed_tecnologia_medio_v1', 'O que é criptografia?', 1, 'Criação de aplicativos', 'Técnica de comprimir informações transformando dados para reduzir espaço ocupado'),
    ('seed_tecnologia_medio_v1', 'O que é criptografia?', 3, 'Aumento de velocidade do processador', 'Técnica de organizar informações transformando dados para facilitar acesso rápido'),
    ('seed_tecnologia_medio_v1', 'O que é blockchain?', 1, 'Um cabo', 'Tecnologia de registro centralizado que organiza informações em tabelas ligadas por servidores únicos'),
    ('seed_tecnologia_medio_v1', 'O que é blockchain?', 2, 'Um antivírus', 'Tecnologia de transmissão distribuída que organiza informações em pacotes ligados por protocolos de rede'),
    ('seed_tecnologia_medio_v1', 'O que é blockchain?', 3, 'Um navegador', 'Tecnologia de armazenamento remoto que organiza informações em pastas ligadas por contas de usuário'),
    ('seed_tecnologia_medio_v1', 'O que é realidade virtual?', 0, 'Um sistema bancário', 'Tecnologia que sobrepõe elementos digitais ao mundo real visto pela câmera'),
    ('seed_tecnologia_medio_v1', 'O que é realidade virtual?', 1, 'Uma rede social', 'Tecnologia que transmite vídeos ao vivo gravados por câmeras remotas'),
    ('seed_tecnologia_medio_v1', 'O que é realidade virtual?', 2, 'Um tipo de memória', 'Tecnologia que projeta imagens em telas gigantes controladas por computador'),
    ('seed_tecnologia_medio_v1', 'O que é Internet das Coisas (IoT)?', 0, 'Um antivírus', 'Conexão de computadores pessoais à internet para guardar e proteger dados'),
    ('seed_tecnologia_medio_v1', 'O que é Internet das Coisas (IoT)?', 2, 'Apenas uso de computadores', 'Conexão de sistemas virtuais à internet para criar e vender produtos'),
    ('seed_tecnologia_medio_v1', 'O que é Internet das Coisas (IoT)?', 3, 'Um sistema operacional', 'Conexão de aplicativos móveis à internet para baixar e atualizar dados'),
    ('seed_tecnologia_medio_v1', 'Qual é uma boa prática de segurança digital?', 1, 'Clicar em qualquer link recebido', 'Manter sistemas antigos e compartilhar informações pessoais'),
    ('seed_tecnologia_medio_v1', 'Qual é uma boa prática de segurança digital?', 2, 'Usar a mesma senha em tudo', 'Usar senhas fáceis e repetir informações pessoais em vários sites'),
    ('seed_tecnologia_medio_v1', 'Qual é uma boa prática de segurança digital?', 3, 'Compartilhar senhas com qualquer pessoa', 'Desativar proteções do aparelho e publicar informações pessoais'),
    ('seed_tecnologia_medio_v2', 'Qual é a principal função de um sistema operacional?', 0, 'Aumentar fisicamente a memória do computador', 'Proteger o hardware e permitir a detecção de ameaças'),
    ('seed_tecnologia_medio_v2', 'Qual é a principal função de um sistema operacional?', 1, 'Substituir todos os aplicativos', 'Conectar o hardware e permitir o acesso a páginas'),
    ('seed_tecnologia_medio_v2', 'Qual é a principal função de um sistema operacional?', 2, 'Criar conexão de internet automaticamente', 'Testar o hardware e permitir a troca de componentes'),
    ('seed_tecnologia_medio_v2', 'Qual componente do computador é responsável pelo processamento de informações?', 0, 'Monitor', 'SSD'),
    ('seed_tecnologia_medio_v2', 'Qual componente do computador é responsável pelo processamento de informações?', 1, 'Impressora', 'Fonte'),
    ('seed_tecnologia_medio_v2', 'Qual componente do computador é responsável pelo processamento de informações?', 2, 'Teclado', 'Mouse'),
    ('seed_tecnologia_medio_v2', 'Qual é a função principal da memória RAM?', 0, 'Substituir o processador', 'Executar cálculos rapidamente para programas em execução'),
    ('seed_tecnologia_medio_v2', 'Qual é a função principal da memória RAM?', 2, 'Controlar a energia do computador', 'Distribuir energia temporariamente para programas em execução'),
    ('seed_tecnologia_medio_v2', 'Qual é a função principal da memória RAM?', 3, 'Guardar arquivos permanentemente', 'Guardar arquivos permanentemente para programas em execução'),
    ('seed_tecnologia_medio_v2', 'Qual destas opções representa um dispositivo de armazenamento?', 0, 'Monitor', 'CPU'),
    ('seed_tecnologia_medio_v2', 'Qual destas opções representa um dispositivo de armazenamento?', 1, 'Mouse', 'GPU'),
    ('seed_tecnologia_medio_v2', 'Qual destas opções representa um dispositivo de armazenamento?', 2, 'Webcam', 'Mouse')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Tecnologia médio lote 2: perguntas 26 a 46 do seed medio_v1 (migration 034) e 1 a 4 do seed medio_v2 (migration 055): % alternativa(s) errada(s) atualizada(s) (esperado: 72).', v_updated;
END $$;
