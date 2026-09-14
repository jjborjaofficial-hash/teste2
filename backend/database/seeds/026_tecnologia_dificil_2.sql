-- Seed: conteúdo Tecnologia, nível Difícil (48 perguntas)
-- Fonte: lote "TECNOLOGIA — DIFÍCIL (50 questões)" fornecido
-- pelo proprietário do projeto, filtrado para conter apenas perguntas que
-- ainda não existiam no banco (comparação por texto normalizado contra os
-- 614 enunciados já existentes em 003-024).
--
-- Das 50 perguntas do lote original, algumas repetiam (com o mesmo
-- enunciado) perguntas já presentes nos seeds 004/006 de Tecnologia
-- Difícil — essas foram descartadas. As 48 restantes são
-- genuinamente novas e entram neste arquivo.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes
-- anteriores, não é decisão de negócio): no lote original, a esmagadora
-- maioria das respostas corretas era a alternativa "A" — decorável sem
-- conhecimento real. A posição da alternativa correta foi redistribuída por
-- pergunta com seed fixa (65 — distinta das seeds 42 a 63 já
-- usadas nos seeds anteriores) e distribuição controlada entre A/B/C/D,
-- reprodutível — o conteúdo pedagógico permanece exatamente como enviado,
-- só a ORDEM de exibição mudou.
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

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_tecnologia_dificil_v2') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_tecnologia_dificil_v2) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_tec_dificil2 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'hard', v.statement, 15, 10, 'seed_tecnologia_dificil_v2'
    FROM (VALUES
      ('Em uma arquitetura de software distribuída, qual é um dos principais desafios ao utilizar múltiplos serviços independentes?'),
      ('O que caracteriza principalmente uma arquitetura de microsserviços?'),
      ('Em bancos de dados relacionais, qual é a principal finalidade de uma transação?'),
      ('O que significa ACID em bancos de dados?'),
      ('Qual propriedade ACID garante que uma transação seja executada completamente ou não seja aplicada?'),
      ('Qual é a principal função de um índice em um banco de dados?'),
      ('Qual pode ser uma consequência do excesso de índices em uma tabela?'),
      ('O que é normalização em bancos de dados relacionais?'),
      ('O que caracteriza uma condição de corrida em sistemas concorrentes?'),
      ('O que é um deadlock?'),
      ('Qual mecanismo pode ajudar a evitar condições de corrida em código concorrente?'),
      ('O que é uma race condition?'),
      ('Em redes, qual é a função principal do protocolo TCP?'),
      ('Qual é uma característica fundamental do UDP em comparação com TCP?'),
      ('Qual protocolo é normalmente utilizado para resolver nomes de domínio em endereços IP?'),
      ('Qual é a finalidade principal do protocolo DHCP?'),
      ('O que caracteriza uma rede baseada em IPv6?'),
      ('Qual é uma vantagem importante do IPv6?'),
      ('O que é NAT em redes?'),
      ('O que é uma CDN?'),
      ('Qual é a principal função de um balanceador de carga?'),
      ('O que significa alta disponibilidade?'),
      ('O que é redundância em infraestrutura?'),
      ('Qual é a finalidade de um mecanismo de failover?'),
      ('Qual é uma característica importante de sistemas distribuídos?'),
      ('O que é consistência eventual?'),
      ('O que é cache?'),
      ('Qual é um problema potencial de um cache mal configurado?'),
      ('O que é uma vulnerabilidade de SQL Injection?'),
      ('Qual prática ajuda a prevenir SQL Injection?'),
      ('O que caracteriza um ataque XSS?'),
      ('Qual prática ajuda a reduzir riscos de XSS?'),
      ('O que é CSRF?'),
      ('Qual mecanismo pode ajudar a proteger aplicações contra CSRF?'),
      ('Qual é uma prática recomendada para armazenamento de senhas?'),
      ('Por que um salt é utilizado no armazenamento de senhas?'),
      ('Qual é a finalidade principal de HTTPS?'),
      ('O que é TLS?'),
      ('Em criptografia assimétrica, qual característica é correta?'),
      ('Qual é uma diferença fundamental entre criptografia simétrica e assimétrica?'),
      ('O que é uma assinatura digital?'),
      ('Em inteligência artificial, o que é overfitting?'),
      ('Qual técnica pode ajudar a reduzir overfitting em modelos de Machine Learning?'),
      ('O que é um conjunto de validação em Machine Learning?'),
      ('O que é inferência em um modelo de Machine Learning?'),
      ('O que é containerização?'),
      ('Qual é uma vantagem importante da containerização?'),
      ('O que é CI/CD no desenvolvimento de software?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_tec_dificil2 q
    JOIN (VALUES
      ('Em uma arquitetura de software distribuída, qual é um dos principais desafios ao utilizar múltiplos serviços independentes?', 'Impedir que qualquer serviço tenha seu próprio banco de dados', FALSE, 0),
      ('Em uma arquitetura de software distribuída, qual é um dos principais desafios ao utilizar múltiplos serviços independentes?', 'Eliminar completamente a necessidade de rede', FALSE, 1),
      ('Em uma arquitetura de software distribuída, qual é um dos principais desafios ao utilizar múltiplos serviços independentes?', 'Fazer todos os serviços utilizarem exatamente o mesmo processo', FALSE, 2),
      ('Em uma arquitetura de software distribuída, qual é um dos principais desafios ao utilizar múltiplos serviços independentes?', 'Garantir comunicação, consistência e tolerância a falhas entre os serviços', TRUE, 3),
      ('O que caracteriza principalmente uma arquitetura de microsserviços?', 'Aplicação dividida em serviços independentes e especializados', TRUE, 0),
      ('O que caracteriza principalmente uma arquitetura de microsserviços?', 'Banco de dados sem tabelas', FALSE, 1),
      ('O que caracteriza principalmente uma arquitetura de microsserviços?', 'Sistema sem comunicação entre componentes', FALSE, 2),
      ('O que caracteriza principalmente uma arquitetura de microsserviços?', 'Aplicação executada exclusivamente em um único arquivo', FALSE, 3),
      ('Em bancos de dados relacionais, qual é a principal finalidade de uma transação?', 'Substituir índices', FALSE, 0),
      ('Em bancos de dados relacionais, qual é a principal finalidade de uma transação?', 'Eliminar todas as consultas SQL', FALSE, 1),
      ('Em bancos de dados relacionais, qual é a principal finalidade de uma transação?', 'Aumentar automaticamente o espaço disponível no disco', FALSE, 2),
      ('Em bancos de dados relacionais, qual é a principal finalidade de uma transação?', 'Garantir que um conjunto de operações seja tratado de forma consistente', TRUE, 3),
      ('O que significa ACID em bancos de dados?', 'Autenticação, Criptografia, Índice e Dados', FALSE, 0),
      ('O que significa ACID em bancos de dados?', 'Acesso, Controle, Integração e Distribuição', FALSE, 1),
      ('O que significa ACID em bancos de dados?', 'Atomicidade, Consistência, Isolamento e Durabilidade', TRUE, 2),
      ('O que significa ACID em bancos de dados?', 'Aplicação, Consulta, Interface e Desenvolvimento', FALSE, 3),
      ('Qual propriedade ACID garante que uma transação seja executada completamente ou não seja aplicada?', 'Isolamento', FALSE, 0),
      ('Qual propriedade ACID garante que uma transação seja executada completamente ou não seja aplicada?', 'Atomicidade', TRUE, 1),
      ('Qual propriedade ACID garante que uma transação seja executada completamente ou não seja aplicada?', 'Durabilidade', FALSE, 2),
      ('Qual propriedade ACID garante que uma transação seja executada completamente ou não seja aplicada?', 'Consistência', FALSE, 3),
      ('Qual é a principal função de um índice em um banco de dados?', 'Substituir todas as tabelas', FALSE, 0),
      ('Qual é a principal função de um índice em um banco de dados?', 'Criptografar automaticamente os dados', FALSE, 1),
      ('Qual é a principal função de um índice em um banco de dados?', 'Impedir qualquer alteração nos registros', FALSE, 2),
      ('Qual é a principal função de um índice em um banco de dados?', 'Acelerar determinadas consultas', TRUE, 3),
      ('Qual pode ser uma consequência do excesso de índices em uma tabela?', 'Redução obrigatória da segurança', FALSE, 0),
      ('Qual pode ser uma consequência do excesso de índices em uma tabela?', 'Eliminação automática do banco de dados', FALSE, 1),
      ('Qual pode ser uma consequência do excesso de índices em uma tabela?', 'Impossibilidade de realizar consultas', FALSE, 2),
      ('Qual pode ser uma consequência do excesso de índices em uma tabela?', 'Maior custo em operações de inserção, atualização e exclusão', TRUE, 3),
      ('O que é normalização em bancos de dados relacionais?', 'Organização dos dados para reduzir redundâncias e anomalias', TRUE, 0),
      ('O que é normalização em bancos de dados relacionais?', 'Criação automática de backups', FALSE, 1),
      ('O que é normalização em bancos de dados relacionais?', 'Criptografia de todas as tabelas', FALSE, 2),
      ('O que é normalização em bancos de dados relacionais?', 'Transformação do banco em arquivos de texto', FALSE, 3),
      ('O que caracteriza uma condição de corrida em sistemas concorrentes?', 'Falha física do processador', FALSE, 0),
      ('O que caracteriza uma condição de corrida em sistemas concorrentes?', 'Resultado dependente da ordem imprevisível de execução de operações concorrentes', TRUE, 1),
      ('O que caracteriza uma condição de corrida em sistemas concorrentes?', 'Falta de espaço no disco', FALSE, 2),
      ('O que caracteriza uma condição de corrida em sistemas concorrentes?', 'Erro causado exclusivamente por senha incorreta', FALSE, 3),
      ('O que é um deadlock?', 'Situação em que processos ficam bloqueados esperando recursos uns dos outros', TRUE, 0),
      ('O que é um deadlock?', 'Exclusão automática de um processo', FALSE, 1),
      ('O que é um deadlock?', 'Falta de memória RAM causada por arquivos temporários', FALSE, 2),
      ('O que é um deadlock?', 'Falha de conexão com a internet', FALSE, 3),
      ('Qual mecanismo pode ajudar a evitar condições de corrida em código concorrente?', 'Aumento da resolução do monitor', FALSE, 0),
      ('Qual mecanismo pode ajudar a evitar condições de corrida em código concorrente?', 'Alteração do formato da imagem', FALSE, 1),
      ('Qual mecanismo pode ajudar a evitar condições de corrida em código concorrente?', 'Mutex ou mecanismo de sincronização equivalente', TRUE, 2),
      ('Qual mecanismo pode ajudar a evitar condições de corrida em código concorrente?', 'Compressão de arquivos', FALSE, 3),
      ('O que é uma race condition?', 'Um formato de banco de dados', FALSE, 0),
      ('O que é uma race condition?', 'Um protocolo de internet', FALSE, 1),
      ('O que é uma race condition?', 'Situação em que o resultado depende do momento ou ordem de execução de operações concorrentes', TRUE, 2),
      ('O que é uma race condition?', 'Um tipo de ataque exclusivamente físico', FALSE, 3),
      ('Em redes, qual é a função principal do protocolo TCP?', 'Criptografar todas as páginas web', FALSE, 0),
      ('Em redes, qual é a função principal do protocolo TCP?', 'Resolver nomes de domínio', FALSE, 1),
      ('Em redes, qual é a função principal do protocolo TCP?', 'Fornecer comunicação orientada à conexão com entrega confiável e ordenada', TRUE, 2),
      ('Em redes, qual é a função principal do protocolo TCP?', 'Distribuir endereços IP automaticamente', FALSE, 3),
      ('Qual é uma característica fundamental do UDP em comparação com TCP?', 'Substitui o DNS', FALSE, 0),
      ('Qual é uma característica fundamental do UDP em comparação com TCP?', 'Não estabelece uma conexão tradicional e possui menor sobrecarga', TRUE, 1),
      ('Qual é uma característica fundamental do UDP em comparação com TCP?', 'Garante sempre a entrega ordenada', FALSE, 2),
      ('Qual é uma característica fundamental do UDP em comparação com TCP?', 'Realiza obrigatoriamente retransmissão de todos os pacotes', FALSE, 3),
      ('Qual protocolo é normalmente utilizado para resolver nomes de domínio em endereços IP?', 'FTP', FALSE, 0),
      ('Qual protocolo é normalmente utilizado para resolver nomes de domínio em endereços IP?', 'SMTP', FALSE, 1),
      ('Qual protocolo é normalmente utilizado para resolver nomes de domínio em endereços IP?', 'DNS', TRUE, 2),
      ('Qual protocolo é normalmente utilizado para resolver nomes de domínio em endereços IP?', 'SSH', FALSE, 3),
      ('Qual é a finalidade principal do protocolo DHCP?', 'Resolver consultas SQL', FALSE, 0),
      ('Qual é a finalidade principal do protocolo DHCP?', 'Transferir páginas web', FALSE, 1),
      ('Qual é a finalidade principal do protocolo DHCP?', 'Criptografar arquivos', FALSE, 2),
      ('Qual é a finalidade principal do protocolo DHCP?', 'Atribuir configurações de rede automaticamente aos dispositivos', TRUE, 3),
      ('O que caracteriza uma rede baseada em IPv6?', 'Não suporta roteamento', FALSE, 0),
      ('O que caracteriza uma rede baseada em IPv6?', 'Utiliza endereços de 128 bits', TRUE, 1),
      ('O que caracteriza uma rede baseada em IPv6?', 'Não permite comunicação pela internet', FALSE, 2),
      ('O que caracteriza uma rede baseada em IPv6?', 'Utiliza exclusivamente endereços de 16 bits', FALSE, 3),
      ('Qual é uma vantagem importante do IPv6?', 'Ausência de roteadores', FALSE, 0),
      ('Qual é uma vantagem importante do IPv6?', 'Espaço de endereçamento muito maior que o IPv4', TRUE, 1),
      ('Qual é uma vantagem importante do IPv6?', 'Necessidade menor de endereços', FALSE, 2),
      ('Qual é uma vantagem importante do IPv6?', 'Eliminação completa de ataques cibernéticos', FALSE, 3),
      ('O que é NAT em redes?', 'Protocolo de envio de e-mails', FALSE, 0),
      ('O que é NAT em redes?', 'Sistema de armazenamento', FALSE, 1),
      ('O que é NAT em redes?', 'Algoritmo de compressão', FALSE, 2),
      ('O que é NAT em redes?', 'Técnica que traduz endereços IP entre diferentes espaços de endereçamento', TRUE, 3),
      ('O que é uma CDN?', 'Sistema operacional para servidores', FALSE, 0),
      ('O que é uma CDN?', 'Rede distribuída de servidores usada para entregar conteúdos aos usuários com menor latência', TRUE, 1),
      ('O que é uma CDN?', 'Banco de dados exclusivamente local', FALSE, 2),
      ('O que é uma CDN?', 'Linguagem de programação', FALSE, 3),
      ('Qual é a principal função de um balanceador de carga?', 'Distribuir requisições entre diferentes servidores ou instâncias', TRUE, 0),
      ('Qual é a principal função de um balanceador de carga?', 'Criar senhas automaticamente', FALSE, 1),
      ('Qual é a principal função de um balanceador de carga?', 'Substituir o banco de dados', FALSE, 2),
      ('Qual é a principal função de um balanceador de carga?', 'Aumentar fisicamente a memória RAM', FALSE, 3),
      ('O que significa alta disponibilidade?', 'Utilização obrigatória de um único servidor', FALSE, 0),
      ('O que significa alta disponibilidade?', 'Capacidade de armazenar apenas arquivos grandes', FALSE, 1),
      ('O que significa alta disponibilidade?', 'Capacidade de um sistema permanecer acessível durante grande parte do tempo, inclusive diante de algumas falhas', TRUE, 2),
      ('O que significa alta disponibilidade?', 'Ausência completa de manutenção', FALSE, 3),
      ('O que é redundância em infraestrutura?', 'Manter componentes ou recursos adicionais para aumentar a tolerância a falhas', TRUE, 0),
      ('O que é redundância em infraestrutura?', 'Remover todos os servidores secundários', FALSE, 1),
      ('O que é redundância em infraestrutura?', 'Diminuir a capacidade do sistema', FALSE, 2),
      ('O que é redundância em infraestrutura?', 'Eliminar backups', FALSE, 3),
      ('Qual é a finalidade de um mecanismo de failover?', 'Impedir atualizações', FALSE, 0),
      ('Qual é a finalidade de um mecanismo de failover?', 'Transferir o serviço para um recurso alternativo quando o principal falha', TRUE, 1),
      ('Qual é a finalidade de um mecanismo de failover?', 'Aumentar a resolução gráfica', FALSE, 2),
      ('Qual é a finalidade de um mecanismo de failover?', 'Excluir servidores inativos permanentemente', FALSE, 3),
      ('Qual é uma característica importante de sistemas distribuídos?', 'Todos os componentes precisam estar no mesmo processo', FALSE, 0),
      ('Qual é uma característica importante de sistemas distribuídos?', 'Não podem apresentar falhas parciais', FALSE, 1),
      ('Qual é uma característica importante de sistemas distribuídos?', 'Não existe comunicação de rede', FALSE, 2),
      ('Qual é uma característica importante de sistemas distribuídos?', 'Componentes podem executar em diferentes máquinas e precisam coordenar suas operações', TRUE, 3),
      ('O que é consistência eventual?', 'Modelo em que réplicas podem ficar temporariamente diferentes, mas tendem a convergir', TRUE, 0),
      ('O que é consistência eventual?', 'Modelo em que todos os dados são sempre iguais instantaneamente', FALSE, 1),
      ('O que é consistência eventual?', 'Sistema sem replicação', FALSE, 2),
      ('O que é consistência eventual?', 'Método de criptografia', FALSE, 3),
      ('O que é cache?', 'Sistema utilizado exclusivamente para apagar dados', FALSE, 0),
      ('O que é cache?', 'Armazenamento temporário de dados para acelerar acessos futuros', TRUE, 1),
      ('O que é cache?', 'Linguagem de programação', FALSE, 2),
      ('O que é cache?', 'Tipo de firewall', FALSE, 3),
      ('Qual é um problema potencial de um cache mal configurado?', 'Aumento obrigatório da segurança', FALSE, 0),
      ('Qual é um problema potencial de um cache mal configurado?', 'Eliminação automática do banco', FALSE, 1),
      ('Qual é um problema potencial de um cache mal configurado?', 'Dados desatualizados serem retornados ao usuário', TRUE, 2),
      ('Qual é um problema potencial de um cache mal configurado?', 'Impossibilidade de realizar consultas', FALSE, 3),
      ('O que é uma vulnerabilidade de SQL Injection?', 'Problema relacionado à resolução da tela', FALSE, 0),
      ('O que é uma vulnerabilidade de SQL Injection?', 'Falha exclusiva de redes Wi-Fi', FALSE, 1),
      ('O que é uma vulnerabilidade de SQL Injection?', 'Ataque físico ao servidor', FALSE, 2),
      ('O que é uma vulnerabilidade de SQL Injection?', 'Falha que pode permitir a manipulação de consultas SQL por meio de entradas não tratadas adequadamente', TRUE, 3),
      ('Qual prática ajuda a prevenir SQL Injection?', 'Armazenar senhas em texto puro', FALSE, 0),
      ('Qual prática ajuda a prevenir SQL Injection?', 'Permitir qualquer entrada do usuário', FALSE, 1),
      ('Qual prática ajuda a prevenir SQL Injection?', 'Desativar validações', FALSE, 2),
      ('Qual prática ajuda a prevenir SQL Injection?', 'Utilizar consultas parametrizadas ou prepared statements', TRUE, 3),
      ('O que caracteriza um ataque XSS?', 'Inserção de código executável em páginas visualizadas por outros usuários', TRUE, 0),
      ('O que caracteriza um ataque XSS?', 'Falha de memória RAM', FALSE, 1),
      ('O que caracteriza um ataque XSS?', 'Ataque contra cabos de rede', FALSE, 2),
      ('O que caracteriza um ataque XSS?', 'Ataque exclusivamente contra roteadores', FALSE, 3),
      ('Qual prática ajuda a reduzir riscos de XSS?', 'Escapar ou sanitizar corretamente dados inseridos em contextos apropriados', TRUE, 0),
      ('Qual prática ajuda a reduzir riscos de XSS?', 'Aceitar qualquer código HTML', FALSE, 1),
      ('Qual prática ajuda a reduzir riscos de XSS?', 'Desativar autenticação', FALSE, 2),
      ('Qual prática ajuda a reduzir riscos de XSS?', 'Armazenar todas as entradas sem tratamento', FALSE, 3),
      ('O que é CSRF?', 'Ataque que pode induzir um usuário autenticado a realizar uma ação não intencional em um sistema', TRUE, 0),
      ('O que é CSRF?', 'Protocolo de DNS', FALSE, 1),
      ('O que é CSRF?', 'Tipo de banco de dados', FALSE, 2),
      ('O que é CSRF?', 'Sistema de compressão', FALSE, 3),
      ('Qual mecanismo pode ajudar a proteger aplicações contra CSRF?', 'Compressão de imagens', FALSE, 0),
      ('Qual mecanismo pode ajudar a proteger aplicações contra CSRF?', 'Tokens anti-CSRF', TRUE, 1),
      ('Qual mecanismo pode ajudar a proteger aplicações contra CSRF?', 'Alteração do monitor', FALSE, 2),
      ('Qual mecanismo pode ajudar a proteger aplicações contra CSRF?', 'Aumento da memória RAM', FALSE, 3),
      ('Qual é uma prática recomendada para armazenamento de senhas?', 'Utilizar funções de hash apropriadas e adaptativas com salt', TRUE, 0),
      ('Qual é uma prática recomendada para armazenamento de senhas?', 'Usar a mesma senha para todos os usuários', FALSE, 1),
      ('Qual é uma prática recomendada para armazenamento de senhas?', 'Armazenar senhas em texto puro', FALSE, 2),
      ('Qual é uma prática recomendada para armazenamento de senhas?', 'Armazenar senhas diretamente no código-fonte', FALSE, 3),
      ('Por que um salt é utilizado no armazenamento de senhas?', 'Para armazenar arquivos maiores', FALSE, 0),
      ('Por que um salt é utilizado no armazenamento de senhas?', 'Para substituir autenticação', FALSE, 1),
      ('Por que um salt é utilizado no armazenamento de senhas?', 'Para aumentar a velocidade da internet', FALSE, 2),
      ('Por que um salt é utilizado no armazenamento de senhas?', 'Para tornar ataques baseados em tabelas pré-computadas mais difíceis', TRUE, 3),
      ('Qual é a finalidade principal de HTTPS?', 'Aumentar a capacidade do disco', FALSE, 0),
      ('Qual é a finalidade principal de HTTPS?', 'Substituir o DNS', FALSE, 1),
      ('Qual é a finalidade principal de HTTPS?', 'Eliminar todos os vírus', FALSE, 2),
      ('Qual é a finalidade principal de HTTPS?', 'Proteger a comunicação HTTP utilizando TLS', TRUE, 3),
      ('O que é TLS?', 'Linguagem de programação', FALSE, 0),
      ('O que é TLS?', 'Protocolo criptográfico utilizado para proteger comunicações em rede', TRUE, 1),
      ('O que é TLS?', 'Banco de dados', FALSE, 2),
      ('O que é TLS?', 'Sistema operacional', FALSE, 3),
      ('Em criptografia assimétrica, qual característica é correta?', 'Funciona somente sem internet', FALSE, 0),
      ('Em criptografia assimétrica, qual característica é correta?', 'Utiliza sempre uma única chave compartilhada', FALSE, 1),
      ('Em criptografia assimétrica, qual característica é correta?', 'Não utiliza chaves', FALSE, 2),
      ('Em criptografia assimétrica, qual característica é correta?', 'Utiliza um par de chaves relacionadas, normalmente uma pública e uma privada', TRUE, 3),
      ('Qual é uma diferença fundamental entre criptografia simétrica e assimétrica?', 'Ambas utilizam obrigatoriamente a mesma chave', FALSE, 0),
      ('Qual é uma diferença fundamental entre criptografia simétrica e assimétrica?', 'A simétrica não utiliza matemática', FALSE, 1),
      ('Qual é uma diferença fundamental entre criptografia simétrica e assimétrica?', 'A simétrica utiliza uma chave compartilhada para cifrar e decifrar, enquanto a assimétrica utiliza um par de chaves', TRUE, 2),
      ('Qual é uma diferença fundamental entre criptografia simétrica e assimétrica?', 'A assimétrica não possui chaves', FALSE, 3),
      ('O que é uma assinatura digital?', 'Uma imagem digitalizada de uma assinatura manuscrita', FALSE, 0),
      ('O que é uma assinatura digital?', 'Mecanismo criptográfico usado para verificar autenticidade e integridade de uma mensagem ou documento', TRUE, 1),
      ('O que é uma assinatura digital?', 'Um tipo de senha', FALSE, 2),
      ('O que é uma assinatura digital?', 'Um antivírus', FALSE, 3),
      ('Em inteligência artificial, o que é overfitting?', 'Quando o computador fica sem energia', FALSE, 0),
      ('Em inteligência artificial, o que é overfitting?', 'Quando o modelo aprende excessivamente os padrões do conjunto de treinamento e perde capacidade de generalização', TRUE, 1),
      ('Em inteligência artificial, o que é overfitting?', 'Quando o modelo não recebe nenhum dado', FALSE, 2),
      ('Em inteligência artificial, o que é overfitting?', 'Quando o banco de dados é apagado', FALSE, 3),
      ('Qual técnica pode ajudar a reduzir overfitting em modelos de Machine Learning?', 'Regularização', TRUE, 0),
      ('Qual técnica pode ajudar a reduzir overfitting em modelos de Machine Learning?', 'Remover completamente os dados de validação', FALSE, 1),
      ('Qual técnica pode ajudar a reduzir overfitting em modelos de Machine Learning?', 'Treinar sempre com uma única amostra', FALSE, 2),
      ('Qual técnica pode ajudar a reduzir overfitting em modelos de Machine Learning?', 'Eliminar qualquer avaliação do modelo', FALSE, 3),
      ('O que é um conjunto de validação em Machine Learning?', 'Arquivo de configuração da rede', FALSE, 0),
      ('O que é um conjunto de validação em Machine Learning?', 'Dados utilizados exclusivamente para armazenar senhas', FALSE, 1),
      ('O que é um conjunto de validação em Machine Learning?', 'Dados utilizados para avaliar e ajustar escolhas do modelo durante o desenvolvimento', TRUE, 2),
      ('O que é um conjunto de validação em Machine Learning?', 'Banco de dados do sistema operacional', FALSE, 3),
      ('O que é inferência em um modelo de Machine Learning?', 'Processo de utilizar um modelo treinado para produzir previsões ou resultados a partir de novos dados', TRUE, 0),
      ('O que é inferência em um modelo de Machine Learning?', 'Processo de formatar o computador', FALSE, 1),
      ('O que é inferência em um modelo de Machine Learning?', 'Processo de instalar memória RAM', FALSE, 2),
      ('O que é inferência em um modelo de Machine Learning?', 'Processo de apagar o modelo', FALSE, 3),
      ('O que é containerização?', 'Armazenamento de arquivos em um pendrive', FALSE, 0),
      ('O que é containerização?', 'Criação de uma máquina física', FALSE, 1),
      ('O que é containerização?', 'Empacotamento de uma aplicação e suas dependências em um ambiente isolado e reproduzível', TRUE, 2),
      ('O que é containerização?', 'Exclusão de dependências de software', FALSE, 3),
      ('Qual é uma vantagem importante da containerização?', 'Eliminar completamente a necessidade de segurança', FALSE, 0),
      ('Qual é uma vantagem importante da containerização?', 'Garantir que nenhum sistema apresente falhas', FALSE, 1),
      ('Qual é uma vantagem importante da containerização?', 'Facilitar a portabilidade e a consistência do ambiente de execução', TRUE, 2),
      ('Qual é uma vantagem importante da containerização?', 'Tornar todo software automaticamente gratuito', FALSE, 3),
      ('O que é CI/CD no desenvolvimento de software?', 'Um formato de imagem', FALSE, 0),
      ('O que é CI/CD no desenvolvimento de software?', 'Um tipo de memória de computador', FALSE, 1),
      ('O que é CI/CD no desenvolvimento de software?', 'Práticas e processos para integrar, testar e entregar software de forma automatizada e frequente', TRUE, 2),
      ('O que é CI/CD no desenvolvimento de software?', 'Um protocolo de internet', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_tec_dificil2;

    RAISE NOTICE '48 perguntas inseridas com sucesso (source=seed_tecnologia_dificil_v2).';
  END IF;
END $$;

COMMIT;
