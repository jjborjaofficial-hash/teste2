-- Alternativas (BE-003, regularização) — Tecnologia difícil lote 1: perguntas 1 a 25 do seed dificil_v1 (migration 036).
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
    ('seed_tecnologia_dificil_v1', 'O que é computação em nuvem?', 0, 'Programa instalado apenas em computadores antigos', 'Modelo que permite instalação local de recursos computacionais dentro da empresa'),
    ('seed_tecnologia_dificil_v1', 'O que é computação em nuvem?', 1, 'Sistema exclusivo para armazenamento físico', 'Modelo que permite compartilhamento de arquivos entre computadores de uma mesma rede'),
    ('seed_tecnologia_dificil_v1', 'O que é computação em nuvem?', 3, 'Método para aumentar o tamanho do monitor', 'Modelo que permite virtualização de recursos computacionais dentro de um único servidor'),
    ('seed_tecnologia_dificil_v1', 'Qual é uma característica da computação em nuvem?', 0, 'Funcionamento somente offline', 'Funcionamento normal mesmo sem conexão com a internet'),
    ('seed_tecnologia_dificil_v1', 'Qual é uma característica da computação em nuvem?', 1, 'Ausência total de segurança', 'Custo fixo independente do uso do usuário ou empresa'),
    ('seed_tecnologia_dificil_v1', 'Qual é uma característica da computação em nuvem?', 3, 'Dependência obrigatória de um único computador físico', 'Propriedade exclusiva dos equipamentos pelo usuário ou empresa'),
    ('seed_tecnologia_dificil_v1', 'O que significa SaaS em tecnologia?', 0, 'Sistema operacional de servidores', 'Servidor como Serviço, onde máquinas são disponibilizadas pela internet'),
    ('seed_tecnologia_dificil_v1', 'O que significa SaaS em tecnologia?', 2, 'Serviço de antivírus físico', 'Sistema como Serviço, onde estruturas são disponibilizadas pela internet'),
    ('seed_tecnologia_dificil_v1', 'O que significa SaaS em tecnologia?', 3, 'Sistema automático de armazenamento seguro', 'Armazenamento como Serviço, onde arquivos são disponibilizados pela internet'),
    ('seed_tecnologia_dificil_v1', 'Qual exemplo representa um modelo SaaS?', 1, 'Um cabo de rede', 'Uma máquina virtual configurada pelo administrador'),
    ('seed_tecnologia_dificil_v1', 'Qual exemplo representa um modelo SaaS?', 2, 'Um processador', 'Um ambiente de desenvolvimento instalado no computador'),
    ('seed_tecnologia_dificil_v1', 'Qual exemplo representa um modelo SaaS?', 3, 'Uma placa gráfica', 'Um servidor físico instalado na sala da empresa'),
    ('seed_tecnologia_dificil_v1', 'O que é IaaS?', 0, 'Linguagem de programação', 'Modelo que fornece aplicações completas como e-mail, agenda e documentos através da nuvem'),
    ('seed_tecnologia_dificil_v1', 'O que é IaaS?', 2, 'Sistema de edição de imagens', 'Modelo que fornece ambientes de desenvolvimento como linguagens, bibliotecas e ferramentas através da nuvem'),
    ('seed_tecnologia_dificil_v1', 'O que é IaaS?', 3, 'Aplicativo de mensagens', 'Modelo que fornece dispositivos físicos como computadores, impressoras e cabos através de lojas'),
    ('seed_tecnologia_dificil_v1', 'O que é PaaS?', 0, 'Programa de proteção contra vírus', 'Plataforma que oferece aplicações prontas para uso e acesso por navegadores'),
    ('seed_tecnologia_dificil_v1', 'O que é PaaS?', 1, 'Dispositivo de armazenamento físico', 'Plataforma que oferece servidores e redes para criação e gestão de infraestruturas'),
    ('seed_tecnologia_dificil_v1', 'O que é PaaS?', 2, 'Rede social', 'Plataforma que oferece armazenamento e backup para cópia e restauração de arquivos'),
    ('seed_tecnologia_dificil_v1', 'O que é virtualização?', 0, 'Criação de senhas', 'Tecnologia que permite criar cópias digitais de documentos físicos, como contratos ou livros'),
    ('seed_tecnologia_dificil_v1', 'O que é virtualização?', 1, 'Processo de apagar dados', 'Tecnologia que permite criar redes sem fio em ambientes físicos, como escritórios ou casas'),
    ('seed_tecnologia_dificil_v1', 'O que é virtualização?', 2, 'Instalação de aplicativos móveis', 'Tecnologia que permite criar interfaces visuais para aplicações móveis, como menus ou botões'),
    ('seed_tecnologia_dificil_v1', 'O que é uma máquina virtual?', 1, 'Um computador sem sistema operacional', 'Ambiente computacional criado por hardware dedicado que funciona como um servidor físico'),
    ('seed_tecnologia_dificil_v1', 'O que é uma máquina virtual?', 2, 'Um tipo de cabo', 'Programa criado por fabricantes que funciona como um sistema de segurança independente'),
    ('seed_tecnologia_dificil_v1', 'O que é uma máquina virtual?', 3, 'Um arquivo de imagem', 'Arquivo de imagem criado por backup que funciona como uma cópia independente do disco'),
    ('seed_tecnologia_dificil_v1', 'Qual é a função de um hipervisor?', 0, 'Proteger apenas emails', 'Proteger redes inteiras em um ambiente corporativo'),
    ('seed_tecnologia_dificil_v1', 'Qual é a função de um hipervisor?', 1, 'Criar páginas web', 'Distribuir tráfego de rede em um ambiente de produção'),
    ('seed_tecnologia_dificil_v1', 'Qual é a função de um hipervisor?', 2, 'Editar vídeos', 'Armazenar arquivos de usuários em um ambiente de nuvem'),
    ('seed_tecnologia_dificil_v1', 'O que é contêiner em tecnologia?', 0, 'Um dispositivo físico de armazenamento', 'Servidor físico que permite hospedar aplicações com seus usuários'),
    ('seed_tecnologia_dificil_v1', 'O que é contêiner em tecnologia?', 1, 'Um navegador', 'Sistema completo que permite executar aplicações com seu próprio sistema operacional'),
    ('seed_tecnologia_dificil_v1', 'O que é contêiner em tecnologia?', 2, 'Uma rede social', 'Navegador isolado que permite acessar aplicações com suas permissões'),
    ('seed_tecnologia_dificil_v1', 'Qual tecnologia é muito utilizada para gerenciamento de contêineres?', 3, 'Excel', 'Wireshark'),
    ('seed_tecnologia_dificil_v1', 'O que é DevOps?', 1, 'Programa de edição gráfica', 'Cultura e conjunto de normas que separam desenvolvimento de software e segurança'),
    ('seed_tecnologia_dificil_v1', 'O que é DevOps?', 2, 'Tipo de hardware', 'Metodologia e conjunto de ferramentas que substituem equipes de software e suporte'),
    ('seed_tecnologia_dificil_v1', 'O que é DevOps?', 3, 'Sistema bancário', 'Linguagem e conjunto de comandos que automatizam instalação de software e sistemas'),
    ('seed_tecnologia_dificil_v1', 'O que significa CI/CD?', 1, 'Método de criptografia', 'Práticas de criptografia contínua e proteção ou monitoramento contínuo de dados'),
    ('seed_tecnologia_dificil_v1', 'O que significa CI/CD?', 2, 'Linguagem de programação', 'Práticas de compilação inicial e distribuição ou instalação manual de software'),
    ('seed_tecnologia_dificil_v1', 'O que significa CI/CD?', 3, 'Sistema de armazenamento físico', 'Práticas de comunicação interna e documentação ou revisão periódica de projetos'),
    ('seed_tecnologia_dificil_v1', 'O que é uma API REST?', 0, 'Um antivírus', 'Interface que permite comunicação entre sistemas usando arquivos compartilhados em um disco'),
    ('seed_tecnologia_dificil_v1', 'O que é uma API REST?', 1, 'Um tipo de memória', 'Interface que permite visualização de dados usando princípios do design responsivo'),
    ('seed_tecnologia_dificil_v1', 'O que é uma API REST?', 2, 'Um cabo de rede', 'Biblioteca que permite criação de interfaces usando princípios da arquitetura REST'),
    ('seed_tecnologia_dificil_v1', 'O que significa HTTP?', 0, 'Sistema operacional', 'Protocolo utilizado para envio e recebimento de mensagens de correio eletrônico'),
    ('seed_tecnologia_dificil_v1', 'O que significa HTTP?', 1, 'Linguagem de programação', 'Linguagem utilizada para criação e estruturação de páginas na web'),
    ('seed_tecnologia_dificil_v1', 'O que significa HTTP?', 2, 'Banco de dados', 'Sistema utilizado para tradução e localização de endereços na web'),
    ('seed_tecnologia_dificil_v1', 'Qual é a função do HTTPS?', 1, 'Melhorar a câmera do dispositivo', 'Acelerar a comunicação através de compressão de dados na comunicação web'),
    ('seed_tecnologia_dificil_v1', 'Qual é a função do HTTPS?', 2, 'Criar aplicativos automaticamente', 'Armazenar o histórico de navegação através de cookies na comunicação web'),
    ('seed_tecnologia_dificil_v1', 'Qual é a função do HTTPS?', 3, 'Aumentar a memória RAM', 'Traduzir nomes de sites através de servidores de domínio na comunicação web'),
    ('seed_tecnologia_dificil_v1', 'O que é DNS?', 0, 'Processador gráfico', 'Sistema responsável por distribuir endereços IP para dispositivos de uma rede'),
    ('seed_tecnologia_dificil_v1', 'O que é DNS?', 1, 'Programa antivírus', 'Sistema responsável por filtrar conexões entre dispositivos de uma rede'),
    ('seed_tecnologia_dificil_v1', 'O que é DNS?', 2, 'Sistema de armazenamento de fotos', 'Sistema responsável por criptografar dados entre dispositivos de uma rede'),
    ('seed_tecnologia_dificil_v1', 'O que acontece quando um usuário acessa um site pelo domínio?', 0, 'O site é instalado no dispositivo', 'O navegador cria uma cópia do servidor associado ao domínio'),
    ('seed_tecnologia_dificil_v1', 'O que acontece quando um usuário acessa um site pelo domínio?', 1, 'A memória RAM é substituída', 'O firewall escolhe o servidor associado ao domínio'),
    ('seed_tecnologia_dificil_v1', 'O que acontece quando um usuário acessa um site pelo domínio?', 3, 'O computador troca automaticamente de sistema operacional', 'O roteador instala o servidor associado ao domínio'),
    ('seed_tecnologia_dificil_v1', 'O que é firewall?', 0, 'Um navegador', 'Sistema que armazena e organiza conexões de rede baseado em contas definidas'),
    ('seed_tecnologia_dificil_v1', 'O que é firewall?', 1, 'Um processador', 'Sistema que converte e traduz conexões de rede baseado em nomes definidos'),
    ('seed_tecnologia_dificil_v1', 'O que é firewall?', 2, 'Um cabo de internet', 'Sistema que acelera e distribui conexões de rede baseado em prioridades definidas'),
    ('seed_tecnologia_dificil_v1', 'Qual é a função principal de um firewall?', 0, 'Aumentar a capacidade do armazenamento', 'Ajudar a acelerar redes durante acessos simultâneos'),
    ('seed_tecnologia_dificil_v1', 'Qual é a função principal de um firewall?', 1, 'Criar aplicativos', 'Ajudar a limpar computadores contra arquivos infectados'),
    ('seed_tecnologia_dificil_v1', 'Qual é a função principal de um firewall?', 3, 'Melhorar a resolução da tela', 'Ajudar a conectar redes entre locais distantes'),
    ('seed_tecnologia_dificil_v1', 'O que é criptografia assimétrica?', 0, 'Método sem uso de chaves', 'Método que utiliza a mesma chave para cifrar e decifrar informações'),
    ('seed_tecnologia_dificil_v1', 'O que é criptografia assimétrica?', 1, 'Sistema de compressão de arquivos', 'Método que utiliza compressão diferente para guardar e enviar informações'),
    ('seed_tecnologia_dificil_v1', 'O que é criptografia assimétrica?', 3, 'Técnica de aumentar velocidade da internet', 'Método que utiliza assinaturas diferentes para copiar e restaurar informações'),
    ('seed_tecnologia_dificil_v1', 'O que é uma chave pública em criptografia assimétrica?', 0, 'Senha pessoal obrigatoriamente secreta', 'Chave que deve ser mantida em segredo para permitir determinadas operações criptográficas'),
    ('seed_tecnologia_dificil_v1', 'O que é uma chave pública em criptografia assimétrica?', 1, 'Tipo de memória', 'Chave que pode ser substituída para permitir determinadas operações bancárias'),
    ('seed_tecnologia_dificil_v1', 'O que é uma chave pública em criptografia assimétrica?', 3, 'Arquivo de vídeo', 'Chave que pode ser alterada para registrar determinadas operações criptográficas'),
    ('seed_tecnologia_dificil_v1', 'O que é engenharia social?', 0, 'Desenvolvimento de jogos', 'Manipulação estatística para obter resultados ou realizar análises corretas'),
    ('seed_tecnologia_dificil_v1', 'O que é engenharia social?', 1, 'Criação de redes físicas', 'Programação automática para obter informações ou realizar ações repetitivas'),
    ('seed_tecnologia_dificil_v1', 'O que é engenharia social?', 3, 'Construção de computadores', 'Monitoramento técnico para obter informações ou realizar ações preventivas'),
    ('seed_tecnologia_dificil_v1', 'Qual é um exemplo de engenharia social?', 0, 'Instalar uma atualização de segurança', 'Alguém instalar uma atualização de segurança para proteger dados confidenciais'),
    ('seed_tecnologia_dificil_v1', 'Qual é um exemplo de engenharia social?', 2, 'Atualizar um aplicativo oficial', 'Alguém atualizar um aplicativo oficial para corrigir falhas conhecidas'),
    ('seed_tecnologia_dificil_v1', 'Qual é um exemplo de engenharia social?', 3, 'Criar um backup', 'Alguém criar um backup completo para recuperar dados confidenciais'),
    ('seed_tecnologia_dificil_v1', 'O que é autenticação biométrica?', 0, 'Uso de endereço IP', 'Verificação de identidade usando endereços de rede ou números de série'),
    ('seed_tecnologia_dificil_v1', 'O que é autenticação biométrica?', 2, 'Uso apenas de nome de usuário', 'Verificação de identidade usando senhas numéricas ou perguntas pessoais'),
    ('seed_tecnologia_dificil_v1', 'O que é autenticação biométrica?', 3, 'Uso de cabo USB', 'Verificação de identidade usando cartões magnéticos ou tokens de segurança')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Tecnologia difícil lote 1: perguntas 1 a 25 do seed dificil_v1 (migration 036): % alternativa(s) errada(s) atualizada(s) (esperado: 73).', v_updated;
END $$;
