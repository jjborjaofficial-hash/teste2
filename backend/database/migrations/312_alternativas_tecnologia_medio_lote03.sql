-- Alternativas (BE-003, regularização) — Tecnologia médio lote 3: perguntas 5 a 29 do seed medio_v2 (migration 055).
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
    ('seed_tecnologia_medio_v2', 'Qual é uma vantagem do SSD em comparação ao HD?', 1, 'Não precisa de energia', 'Maior capacidade de guardar dados por menos dinheiro'),
    ('seed_tecnologia_medio_v2', 'Qual é uma vantagem do SSD em comparação ao HD?', 2, 'Não armazena arquivos', 'Maior número de peças móveis internas'),
    ('seed_tecnologia_medio_v2', 'Qual é uma vantagem do SSD em comparação ao HD?', 3, 'Funciona somente online', 'Maior dependência de conexão com a internet'),
    ('seed_tecnologia_medio_v2', 'O que significa hardware?', 0, 'Programas instalados', 'Parte lógica de um computador'),
    ('seed_tecnologia_medio_v2', 'O que significa hardware?', 2, 'Contas digitais', 'Parte visual de um computador'),
    ('seed_tecnologia_medio_v2', 'O que significa hardware?', 3, 'Dados da internet', 'Conjunto de dados de um computador'),
    ('seed_tecnologia_medio_v2', 'O que significa software?', 0, 'Componentes físicos', 'Componentes e peças utilizados pelo computador'),
    ('seed_tecnologia_medio_v2', 'O que significa software?', 2, 'Cabos de conexão', 'Cabos, conectores e portas utilizados pelo computador'),
    ('seed_tecnologia_medio_v2', 'O que significa software?', 3, 'Placas eletrônicas', 'Placas e circuitos utilizados pelo computador'),
    ('seed_tecnologia_medio_v2', 'Qual é a função de uma placa-mãe?', 0, 'Criar documentos', 'Processar os dados do computador'),
    ('seed_tecnologia_medio_v2', 'Qual é a função de uma placa-mãe?', 1, 'Armazenar somente fotos', 'Armazenar os arquivos do computador'),
    ('seed_tecnologia_medio_v2', 'Qual é a função de uma placa-mãe?', 3, 'Controlar a internet', 'Alimentar os componentes do computador com energia'),
    ('seed_tecnologia_medio_v2', 'O que representa um endereço IP?', 0, 'Senha de acesso', 'Identificação de um usuário em um aplicativo'),
    ('seed_tecnologia_medio_v2', 'O que representa um endereço IP?', 1, 'Tipo de arquivo', 'Identificação de um site em um navegador'),
    ('seed_tecnologia_medio_v2', 'O que representa um endereço IP?', 2, 'Nome de usuário', 'Identificação de um arquivo em uma pasta'),
    ('seed_tecnologia_medio_v2', 'Para que serve o DNS?', 0, 'Editar vídeos', 'Guardar nomes de sites em arquivos de backup'),
    ('seed_tecnologia_medio_v2', 'Para que serve o DNS?', 1, 'Aumentar memória RAM', 'Converter endereços IP em senhas de acesso'),
    ('seed_tecnologia_medio_v2', 'Para que serve o DNS?', 3, 'Criar antivírus', 'Distribuir sinais de internet para dispositivos'),
    ('seed_tecnologia_medio_v2', 'Qual é a principal função de um backup?', 0, 'Remover vírus', 'Criar uma proteção contra vírus nos dados'),
    ('seed_tecnologia_medio_v2', 'Qual é a principal função de um backup?', 1, 'Criar aplicativos', 'Criar uma conta de acesso aos dados'),
    ('seed_tecnologia_medio_v2', 'Qual é a principal função de um backup?', 2, 'Aumentar velocidade da internet', 'Criar uma versão mais rápida dos dados'),
    ('seed_tecnologia_medio_v2', 'Qual prática aumenta a segurança de uma conta?', 0, 'Usar a mesma senha em tudo', 'Usar a mesma senha em vários sites'),
    ('seed_tecnologia_medio_v2', 'Qual prática aumenta a segurança de uma conta?', 2, 'Desativar segurança', 'Usar senhas com datas de aniversário'),
    ('seed_tecnologia_medio_v2', 'Qual prática aumenta a segurança de uma conta?', 3, 'Compartilhar senha', 'Instalar aplicativos de fontes desconhecidas'),
    ('seed_tecnologia_medio_v2', 'O que é uma API?', 0, 'Tipo de computador', 'Sistema que permite execução de programas em redes'),
    ('seed_tecnologia_medio_v2', 'O que é uma API?', 2, 'Memória externa', 'Memória que permite armazenamento de dados em redes'),
    ('seed_tecnologia_medio_v2', 'O que é uma API?', 3, 'Antivírus', 'Programa que permite proteção de sistemas e dados'),
    ('seed_tecnologia_medio_v2', 'Qual destas é uma linguagem de programação?', 0, 'PDF', 'Windows'),
    ('seed_tecnologia_medio_v2', 'Qual destas é uma linguagem de programação?', 1, 'USB', 'Android'),
    ('seed_tecnologia_medio_v2', 'Qual exemplo representa IoT?', 0, 'Cabo USB', 'Lâmpada comum ligada a um interruptor'),
    ('seed_tecnologia_medio_v2', 'Qual exemplo representa IoT?', 2, 'Teclado desligado', 'Calculadora simples sem conexão à internet'),
    ('seed_tecnologia_medio_v2', 'Qual exemplo representa IoT?', 3, 'Impressora sem energia', 'Impressora antiga ligada por cabo ao computador'),
    ('seed_tecnologia_medio_v2', 'O que é frontend?', 0, 'Servidor físico', 'Parte lógica de uma aplicação'),
    ('seed_tecnologia_medio_v2', 'O que é frontend?', 1, 'Banco de dados', 'Parte de dados de uma aplicação'),
    ('seed_tecnologia_medio_v2', 'O que é frontend?', 3, 'Processador', 'Parte de rede de uma aplicação'),
    ('seed_tecnologia_medio_v2', 'O que é backend?', 1, 'Monitor', 'Parte responsável pela aparência e interação do sistema'),
    ('seed_tecnologia_medio_v2', 'O que é backend?', 2, 'Tela do usuário', 'Parte responsável pela montagem e manutenção do hardware'),
    ('seed_tecnologia_medio_v2', 'O que é backend?', 3, 'Mouse', 'Parte responsável pela segurança e proteção contra vírus'),
    ('seed_tecnologia_medio_v2', 'O que é autenticação?', 1, 'Formatar computador', 'Processo de definir o que um usuário pode acessar'),
    ('seed_tecnologia_medio_v2', 'O que é autenticação?', 2, 'Apagar arquivos', 'Processo de proteger os dados de um usuário'),
    ('seed_tecnologia_medio_v2', 'O que é autenticação?', 3, 'Criar um programa', 'Processo de criar a conta de um usuário'),
    ('seed_tecnologia_medio_v2', 'O que é autorização?', 1, 'Criar senha', 'Confirmar identidade de usuários'),
    ('seed_tecnologia_medio_v2', 'O que é autorização?', 2, 'Atualizar sistema', 'Registrar atividades de usuários'),
    ('seed_tecnologia_medio_v2', 'O que é autorização?', 3, 'Instalar hardware', 'Proteger dados de usuários'),
    ('seed_tecnologia_medio_v2', 'O que é VPN?', 0, 'Memória RAM', 'Tecnologia que cria conexão sem fio dentro de casa'),
    ('seed_tecnologia_medio_v2', 'O que é VPN?', 1, 'Sistema operacional', 'Tecnologia que cria cópia de segurança pela internet'),
    ('seed_tecnologia_medio_v2', 'O que é VPN?', 3, 'Processador', 'Tecnologia que cria endereços para sites na internet'),
    ('seed_tecnologia_medio_v2', 'O que significa latência?', 1, 'Tamanho do arquivo', 'Quantidade de dados transmitidos por segundo'),
    ('seed_tecnologia_medio_v2', 'O que significa latência?', 2, 'Qualidade da tela', 'Tempo de duração da bateria do aparelho'),
    ('seed_tecnologia_medio_v2', 'O que significa latência?', 3, 'Espaço do disco', 'Tamanho do espaço de armazenamento de dados'),
    ('seed_tecnologia_medio_v2', 'O que significa código aberto?', 0, 'Programa sem arquivos', 'Código restrito para uso e distribuição conforme contrato'),
    ('seed_tecnologia_medio_v2', 'O que significa código aberto?', 1, 'Programa sempre pago', 'Código disponível para uso e cópia mesmo sem a licença do autor'),
    ('seed_tecnologia_medio_v2', 'O que significa código aberto?', 3, 'Código sem proteção', 'Código escondido para segurança e proteção conforme fabricante'),
    ('seed_tecnologia_medio_v2', 'O que é atualização de software?', 1, 'Formatação', 'Cópia ou restauração de um programa'),
    ('seed_tecnologia_medio_v2', 'O que é atualização de software?', 2, 'Exclusão do programa', 'Compra ou assinatura de um programa'),
    ('seed_tecnologia_medio_v2', 'O que é atualização de software?', 3, 'Troca de computador', 'Bloqueio ou isolamento de um programa'),
    ('seed_tecnologia_medio_v2', 'Qual é a função de um servidor?', 0, 'Aumentar tela', 'Consumir serviços ou dados de outros dispositivos'),
    ('seed_tecnologia_medio_v2', 'Qual é a função de um servidor?', 2, 'Substituir internet', 'Exibir imagens ou vídeos para outros dispositivos'),
    ('seed_tecnologia_medio_v2', 'Qual é a função de um servidor?', 3, 'Criar energia', 'Controlar energia ou sinal para outros dispositivos'),
    ('seed_tecnologia_medio_v2', 'O que são logs?', 0, 'Vídeos', 'Conjunto de arquivos guardados por sistemas'),
    ('seed_tecnologia_medio_v2', 'O que são logs?', 2, 'Aplicativos', 'Programas de atividades instalados por sistemas'),
    ('seed_tecnologia_medio_v2', 'O que são logs?', 3, 'Senhas', 'Cópias de segurança realizadas por sistemas'),
    ('seed_tecnologia_medio_v2', 'O que é escalabilidade?', 1, 'Exclusão de dados', 'Capacidade de um sistema proteger dados contra mais ameaças'),
    ('seed_tecnologia_medio_v2', 'O que é escalabilidade?', 2, 'Redução de usuários', 'Capacidade de um sistema reduzir custos usando menos usuários'),
    ('seed_tecnologia_medio_v2', 'O que é escalabilidade?', 3, 'Bloqueio do sistema', 'Capacidade de um sistema recuperar dados após uma falha')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Tecnologia médio lote 3: perguntas 5 a 29 do seed medio_v2 (migration 055): % alternativa(s) errada(s) atualizada(s) (esperado: 65).', v_updated;
END $$;
