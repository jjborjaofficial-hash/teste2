-- Alternativas (BE-003, regularização) — Tecnologia difícil lote 3: perguntas 1 a 25 do seed dificil_v2 (migration 056).
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
    ('seed_tecnologia_dificil_v2', 'Em uma arquitetura de software distribuída, qual é um dos principais desafios ao utilizar múltiplos serviços independentes?', 0, 'Impedir que qualquer serviço tenha seu próprio banco de dados', 'Garantir segurança, desempenho e acessibilidade de interfaces entre os usuários'),
    ('seed_tecnologia_dificil_v2', 'Em uma arquitetura de software distribuída, qual é um dos principais desafios ao utilizar múltiplos serviços independentes?', 1, 'Eliminar completamente a necessidade de rede', 'Garantir armazenamento, compressão e tradução de arquivos entre os serviços'),
    ('seed_tecnologia_dificil_v2', 'Em uma arquitetura de software distribuída, qual é um dos principais desafios ao utilizar múltiplos serviços independentes?', 2, 'Fazer todos os serviços utilizarem exatamente o mesmo processo', 'Garantir tamanho, velocidade e simplicidade de código dentro dos serviços'),
    ('seed_tecnologia_dificil_v2', 'O que caracteriza principalmente uma arquitetura de microsserviços?', 1, 'Banco de dados sem tabelas', 'Aplicação reunida em módulos dependentes e compartilhados'),
    ('seed_tecnologia_dificil_v2', 'O que caracteriza principalmente uma arquitetura de microsserviços?', 2, 'Sistema sem comunicação entre componentes', 'Aplicação dividida em camadas sequenciais e hierárquicas'),
    ('seed_tecnologia_dificil_v2', 'O que caracteriza principalmente uma arquitetura de microsserviços?', 3, 'Aplicação executada exclusivamente em um único arquivo', 'Aplicação distribuída em réplicas idênticas e sincronizadas'),
    ('seed_tecnologia_dificil_v2', 'Em bancos de dados relacionais, qual é a principal finalidade de uma transação?', 0, 'Substituir índices', 'Garantir que um conjunto de tabelas seja armazenado de forma compactada'),
    ('seed_tecnologia_dificil_v2', 'Em bancos de dados relacionais, qual é a principal finalidade de uma transação?', 1, 'Eliminar todas as consultas SQL', 'Garantir que um conjunto de consultas seja executado de forma paralela'),
    ('seed_tecnologia_dificil_v2', 'Em bancos de dados relacionais, qual é a principal finalidade de uma transação?', 2, 'Aumentar automaticamente o espaço disponível no disco', 'Garantir que um conjunto de usuários seja identificado de forma segura'),
    ('seed_tecnologia_dificil_v2', 'O que significa ACID em bancos de dados?', 0, 'Autenticação, Criptografia, Índice e Dados', 'Autenticação, Criptografia, Integridade e Disponibilidade'),
    ('seed_tecnologia_dificil_v2', 'O que significa ACID em bancos de dados?', 1, 'Acesso, Controle, Integração e Distribuição', 'Atomicidade, Concorrência, Indexação e Distribuição'),
    ('seed_tecnologia_dificil_v2', 'O que significa ACID em bancos de dados?', 3, 'Aplicação, Consulta, Interface e Desenvolvimento', 'Armazenamento, Consulta, Integridade e Disponibilidade'),
    ('seed_tecnologia_dificil_v2', 'Qual é a principal função de um índice em um banco de dados?', 0, 'Substituir todas as tabelas', 'Armazenar determinados registros'),
    ('seed_tecnologia_dificil_v2', 'Qual é a principal função de um índice em um banco de dados?', 1, 'Criptografar automaticamente os dados', 'Proteger determinadas tabelas'),
    ('seed_tecnologia_dificil_v2', 'Qual é a principal função de um índice em um banco de dados?', 2, 'Impedir qualquer alteração nos registros', 'Replicar determinadas colunas'),
    ('seed_tecnologia_dificil_v2', 'Qual pode ser uma consequência do excesso de índices em uma tabela?', 0, 'Redução obrigatória da segurança', 'Maior velocidade em operações de inserção, atualização e exclusão'),
    ('seed_tecnologia_dificil_v2', 'Qual pode ser uma consequência do excesso de índices em uma tabela?', 1, 'Eliminação automática do banco de dados', 'Maior segurança em operações de backup, restauração e migração'),
    ('seed_tecnologia_dificil_v2', 'Qual pode ser uma consequência do excesso de índices em uma tabela?', 2, 'Impossibilidade de realizar consultas', 'Menor espaço ocupado em disco por tabelas, colunas e registros'),
    ('seed_tecnologia_dificil_v2', 'O que é normalização em bancos de dados relacionais?', 1, 'Criação automática de backups', 'Duplicação dos dados para aumentar desempenho e disponibilidade'),
    ('seed_tecnologia_dificil_v2', 'O que é normalização em bancos de dados relacionais?', 2, 'Criptografia de todas as tabelas', 'Compactação dos dados para reduzir espaço e tempo de leitura'),
    ('seed_tecnologia_dificil_v2', 'O que é normalização em bancos de dados relacionais?', 3, 'Transformação do banco em arquivos de texto', 'Proteção dos dados para impedir acessos e alterações indevidas'),
    ('seed_tecnologia_dificil_v2', 'O que caracteriza uma condição de corrida em sistemas concorrentes?', 0, 'Falha física do processador', 'Resultado dependente da velocidade máxima de execução de instruções do processador'),
    ('seed_tecnologia_dificil_v2', 'O que caracteriza uma condição de corrida em sistemas concorrentes?', 2, 'Falta de espaço no disco', 'Resultado dependente da capacidade limitada de memória para operações concorrentes'),
    ('seed_tecnologia_dificil_v2', 'O que caracteriza uma condição de corrida em sistemas concorrentes?', 3, 'Erro causado exclusivamente por senha incorreta', 'Erro causado pela ordem incorreta de digitação de comandos em operações manuais'),
    ('seed_tecnologia_dificil_v2', 'O que é um deadlock?', 1, 'Exclusão automática de um processo', 'Situação em que processos ficam em execução consumindo recursos uns dos outros'),
    ('seed_tecnologia_dificil_v2', 'O que é um deadlock?', 2, 'Falta de memória RAM causada por arquivos temporários', 'Situação em que processos ficam encerrados liberando recursos uns dos outros'),
    ('seed_tecnologia_dificil_v2', 'O que é um deadlock?', 3, 'Falha de conexão com a internet', 'Situação em que processos ficam duplicados disputando memória uns dos outros'),
    ('seed_tecnologia_dificil_v2', 'Qual mecanismo pode ajudar a evitar condições de corrida em código concorrente?', 0, 'Aumento da resolução do monitor', 'Cache ou mecanismo de armazenamento equivalente'),
    ('seed_tecnologia_dificil_v2', 'Qual mecanismo pode ajudar a evitar condições de corrida em código concorrente?', 1, 'Alteração do formato da imagem', 'Proxy ou mecanismo de redirecionamento equivalente'),
    ('seed_tecnologia_dificil_v2', 'Qual mecanismo pode ajudar a evitar condições de corrida em código concorrente?', 3, 'Compressão de arquivos', 'Hash ou mecanismo de verificação equivalente'),
    ('seed_tecnologia_dificil_v2', 'O que é uma race condition?', 0, 'Um formato de banco de dados', 'Situação em que o resultado depende do tamanho ou formato de armazenamento de registros comuns'),
    ('seed_tecnologia_dificil_v2', 'O que é uma race condition?', 1, 'Um protocolo de internet', 'Situação em que o resultado depende da rede ou protocolo de comunicação de aplicações remotas'),
    ('seed_tecnologia_dificil_v2', 'O que é uma race condition?', 3, 'Um tipo de ataque exclusivamente físico', 'Situação em que o resultado depende da senha ou chave de acesso de usuários autorizados'),
    ('seed_tecnologia_dificil_v2', 'Em redes, qual é a função principal do protocolo TCP?', 0, 'Criptografar todas as páginas web', 'Fornecer comunicação sem conexão com entrega rápida e sem confirmação de recebimento'),
    ('seed_tecnologia_dificil_v2', 'Em redes, qual é a função principal do protocolo TCP?', 1, 'Resolver nomes de domínio', 'Fornecer resolução de nomes com consulta distribuída e cache hierárquico'),
    ('seed_tecnologia_dificil_v2', 'Em redes, qual é a função principal do protocolo TCP?', 3, 'Distribuir endereços IP automaticamente', 'Fornecer atribuição de endereços com configuração automática e temporária'),
    ('seed_tecnologia_dificil_v2', 'Qual é uma característica fundamental do UDP em comparação com TCP?', 0, 'Substitui o DNS', 'Não estabelece uma resolução de nomes e possui menor latência de consulta'),
    ('seed_tecnologia_dificil_v2', 'Qual é uma característica fundamental do UDP em comparação com TCP?', 2, 'Garante sempre a entrega ordenada', 'Estabelece uma conexão tradicional e possui entrega ordenada'),
    ('seed_tecnologia_dificil_v2', 'Qual é uma característica fundamental do UDP em comparação com TCP?', 3, 'Realiza obrigatoriamente retransmissão de todos os pacotes', 'Estabelece uma retransmissão automática e possui maior confiabilidade'),
    ('seed_tecnologia_dificil_v2', 'Qual é a finalidade principal do protocolo DHCP?', 0, 'Resolver consultas SQL', 'Traduzir nomes de domínio automaticamente para os dispositivos'),
    ('seed_tecnologia_dificil_v2', 'Qual é a finalidade principal do protocolo DHCP?', 1, 'Transferir páginas web', 'Transferir arquivos de rede automaticamente entre os dispositivos'),
    ('seed_tecnologia_dificil_v2', 'Qual é a finalidade principal do protocolo DHCP?', 2, 'Criptografar arquivos', 'Proteger conexões de rede automaticamente nos dispositivos'),
    ('seed_tecnologia_dificil_v2', 'O que caracteriza uma rede baseada em IPv6?', 0, 'Não suporta roteamento', 'Utiliza endereços de 32 bits'),
    ('seed_tecnologia_dificil_v2', 'O que caracteriza uma rede baseada em IPv6?', 2, 'Não permite comunicação pela internet', 'Utiliza endereços de 64 bits'),
    ('seed_tecnologia_dificil_v2', 'O que caracteriza uma rede baseada em IPv6?', 3, 'Utiliza exclusivamente endereços de 16 bits', 'Utiliza endereços de 48 bits'),
    ('seed_tecnologia_dificil_v2', 'Qual é uma vantagem importante do IPv6?', 0, 'Ausência de roteadores', 'Velocidade de transmissão muito maior que o IPv4'),
    ('seed_tecnologia_dificil_v2', 'Qual é uma vantagem importante do IPv6?', 2, 'Necessidade menor de endereços', 'Alcance de sinal sem fio muito maior que o IPv4'),
    ('seed_tecnologia_dificil_v2', 'Qual é uma vantagem importante do IPv6?', 3, 'Eliminação completa de ataques cibernéticos', 'Custo de equipamentos muito menor que o IPv4'),
    ('seed_tecnologia_dificil_v2', 'O que é NAT em redes?', 0, 'Protocolo de envio de e-mails', 'Técnica que traduz nomes de domínio entre diferentes servidores de endereçamento'),
    ('seed_tecnologia_dificil_v2', 'O que é NAT em redes?', 1, 'Sistema de armazenamento', 'Técnica que compacta pacotes de dados entre diferentes redes de endereçamento'),
    ('seed_tecnologia_dificil_v2', 'O que é NAT em redes?', 2, 'Algoritmo de compressão', 'Técnica que criptografa endereços IP entre diferentes tipos de endereçamento'),
    ('seed_tecnologia_dificil_v2', 'O que é uma CDN?', 0, 'Sistema operacional para servidores', 'Rede centralizada de servidores usada para armazenar conteúdos dos usuários com maior segurança'),
    ('seed_tecnologia_dificil_v2', 'O que é uma CDN?', 2, 'Banco de dados exclusivamente local', 'Rede privada de computadores usada para proteger conteúdos internos com maior controle'),
    ('seed_tecnologia_dificil_v2', 'O que é uma CDN?', 3, 'Linguagem de programação', 'Rede distribuída de roteadores usada para encaminhar pacotes entre os usuários com menor custo'),
    ('seed_tecnologia_dificil_v2', 'Qual é a principal função de um balanceador de carga?', 1, 'Criar senhas automaticamente', 'Armazenar requisições entre diferentes servidores ou instâncias'),
    ('seed_tecnologia_dificil_v2', 'Qual é a principal função de um balanceador de carga?', 2, 'Substituir o banco de dados', 'Traduzir requisições entre diferentes protocolos ou linguagens'),
    ('seed_tecnologia_dificil_v2', 'Qual é a principal função de um balanceador de carga?', 3, 'Aumentar fisicamente a memória RAM', 'Criptografar requisições entre diferentes clientes ou usuários'),
    ('seed_tecnologia_dificil_v2', 'O que significa alta disponibilidade?', 0, 'Utilização obrigatória de um único servidor', 'Capacidade de um sistema permanecer protegido durante grande parte do tempo, inclusive diante de alguns ataques'),
    ('seed_tecnologia_dificil_v2', 'O que significa alta disponibilidade?', 1, 'Capacidade de armazenar apenas arquivos grandes', 'Capacidade de um sistema permanecer rápido durante grande parte do tempo, inclusive diante de alguns picos de uso'),
    ('seed_tecnologia_dificil_v2', 'O que significa alta disponibilidade?', 3, 'Ausência completa de manutenção', 'Capacidade de um sistema permanecer atualizado durante grande parte do tempo, inclusive diante de algumas manutenções'),
    ('seed_tecnologia_dificil_v2', 'O que é redundância em infraestrutura?', 1, 'Remover todos os servidores secundários', 'Manter componentes ou recursos mínimos para reduzir o custo de operação'),
    ('seed_tecnologia_dificil_v2', 'O que é redundância em infraestrutura?', 2, 'Diminuir a capacidade do sistema', 'Manter componentes ou recursos isolados para aumentar a segurança de acesso'),
    ('seed_tecnologia_dificil_v2', 'O que é redundância em infraestrutura?', 3, 'Eliminar backups', 'Manter componentes ou recursos atualizados para aumentar o desempenho do sistema'),
    ('seed_tecnologia_dificil_v2', 'Qual é a finalidade de um mecanismo de failover?', 0, 'Impedir atualizações', 'Distribuir o serviço entre vários recursos quando o principal recebe muita carga'),
    ('seed_tecnologia_dificil_v2', 'Qual é a finalidade de um mecanismo de failover?', 2, 'Aumentar a resolução gráfica', 'Copiar o serviço para um recurso externo quando o principal é atualizado'),
    ('seed_tecnologia_dificil_v2', 'Qual é a finalidade de um mecanismo de failover?', 3, 'Excluir servidores inativos permanentemente', 'Isolar o serviço em um recurso separado quando o principal é atacado'),
    ('seed_tecnologia_dificil_v2', 'Qual é uma característica importante de sistemas distribuídos?', 0, 'Todos os componentes precisam estar no mesmo processo', 'Componentes podem executar em diferentes máquinas e dispensam coordenar suas operações'),
    ('seed_tecnologia_dificil_v2', 'Qual é uma característica importante de sistemas distribuídos?', 1, 'Não podem apresentar falhas parciais', 'Componentes precisam executar na mesma máquina e compartilhar a mesma memória física'),
    ('seed_tecnologia_dificil_v2', 'Qual é uma característica importante de sistemas distribuídos?', 2, 'Não existe comunicação de rede', 'Componentes devem executar em diferentes redes e usam o mesmo processador')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Tecnologia difícil lote 3: perguntas 1 a 25 do seed dificil_v2 (migration 056): % alternativa(s) errada(s) atualizada(s) (esperado: 69).', v_updated;
END $$;
