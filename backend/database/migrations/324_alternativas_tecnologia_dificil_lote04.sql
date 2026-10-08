-- Alternativas (BE-003, regularização) — Tecnologia difícil lote 4: perguntas 26 a 48 do seed dificil_v2 (migration 056) e 1 e 2 do seed dificil_v3 (migration 066).
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
    ('seed_tecnologia_dificil_v2', 'O que é consistência eventual?', 1, 'Modelo em que todos os dados são sempre iguais instantaneamente', 'Modelo em que todas as réplicas são bloqueadas até que uma delas confirme a gravação'),
    ('seed_tecnologia_dificil_v2', 'O que é consistência eventual?', 2, 'Sistema sem replicação', 'Modelo em que cada réplica guarda dados próprios e nunca troca informações com as demais'),
    ('seed_tecnologia_dificil_v2', 'O que é consistência eventual?', 3, 'Método de criptografia', 'Modelo em que as réplicas ficam sempre diferentes, sem qualquer convergência'),
    ('seed_tecnologia_dificil_v2', 'O que é cache?', 0, 'Sistema utilizado exclusivamente para apagar dados', 'Cópia permanente de dados para garantir a recuperação após falhas'),
    ('seed_tecnologia_dificil_v2', 'O que é cache?', 2, 'Linguagem de programação', 'Registro de eventos do sistema para auditar acessos e erros'),
    ('seed_tecnologia_dificil_v2', 'O que é cache?', 3, 'Tipo de firewall', 'Compressão de dados para reduzir o espaço ocupado em disco'),
    ('seed_tecnologia_dificil_v2', 'Qual é um problema potencial de um cache mal configurado?', 0, 'Aumento obrigatório da segurança', 'Perda dos dados armazenados no banco principal'),
    ('seed_tecnologia_dificil_v2', 'Qual é um problema potencial de um cache mal configurado?', 1, 'Eliminação automática do banco', 'Bloqueio das consultas feitas por novos usuários'),
    ('seed_tecnologia_dificil_v2', 'Qual é um problema potencial de um cache mal configurado?', 3, 'Impossibilidade de realizar consultas', 'Duplicação dos registros gravados no banco'),
    ('seed_tecnologia_dificil_v2', 'O que é uma vulnerabilidade de SQL Injection?', 0, 'Problema relacionado à resolução da tela', 'Falha que pode permitir a interceptação de conexões de rede por meio de certificados mal configurados'),
    ('seed_tecnologia_dificil_v2', 'O que é uma vulnerabilidade de SQL Injection?', 1, 'Falha exclusiva de redes Wi-Fi', 'Falha que pode permitir a execução de código no navegador por meio de scripts inseridos em páginas'),
    ('seed_tecnologia_dificil_v2', 'O que é uma vulnerabilidade de SQL Injection?', 2, 'Ataque físico ao servidor', 'Falha que pode permitir o acesso a arquivos do servidor por meio de caminhos de diretório manipulados'),
    ('seed_tecnologia_dificil_v2', 'Qual prática ajuda a prevenir SQL Injection?', 0, 'Armazenar senhas em texto puro', 'Concatenar diretamente o texto digitado nas consultas'),
    ('seed_tecnologia_dificil_v2', 'Qual prática ajuda a prevenir SQL Injection?', 1, 'Permitir qualquer entrada do usuário', 'Aumentar o tamanho máximo dos campos de formulário'),
    ('seed_tecnologia_dificil_v2', 'Qual prática ajuda a prevenir SQL Injection?', 2, 'Desativar validações', 'Trocar o banco de dados por um servidor mais rápido'),
    ('seed_tecnologia_dificil_v2', 'O que caracteriza um ataque XSS?', 1, 'Falha de memória RAM', 'Interceptação de mensagens trocadas entre o navegador e o servidor'),
    ('seed_tecnologia_dificil_v2', 'O que caracteriza um ataque XSS?', 2, 'Ataque contra cabos de rede', 'Envio excessivo de requisições para tornar o servidor indisponível'),
    ('seed_tecnologia_dificil_v2', 'O que caracteriza um ataque XSS?', 3, 'Ataque exclusivamente contra roteadores', 'Quebra de senhas por meio de tentativas automáticas repetidas'),
    ('seed_tecnologia_dificil_v2', 'Qual prática ajuda a reduzir riscos de XSS?', 1, 'Aceitar qualquer código HTML', 'Criptografar todo o tráfego trocado entre o navegador e o servidor web'),
    ('seed_tecnologia_dificil_v2', 'Qual prática ajuda a reduzir riscos de XSS?', 2, 'Desativar autenticação', 'Aumentar a frequência das cópias de segurança dos dados dos usuários'),
    ('seed_tecnologia_dificil_v2', 'Qual prática ajuda a reduzir riscos de XSS?', 3, 'Armazenar todas as entradas sem tratamento', 'Exigir senhas mais longas e complexas para acessar as contas do sistema'),
    ('seed_tecnologia_dificil_v2', 'O que é CSRF?', 1, 'Protocolo de DNS', 'Ataque que pode interceptar a comunicação de um usuário autenticado e capturar os dados que ele envia'),
    ('seed_tecnologia_dificil_v2', 'O que é CSRF?', 2, 'Tipo de banco de dados', 'Falha que pode permitir a um invasor executar comandos no servidor por meio de entradas manipuladas'),
    ('seed_tecnologia_dificil_v2', 'O que é CSRF?', 3, 'Sistema de compressão', 'Ataque que pode sobrecarregar um sistema com requisições até impedir o acesso dos usuários legítimos'),
    ('seed_tecnologia_dificil_v2', 'Qual mecanismo pode ajudar a proteger aplicações contra CSRF?', 0, 'Compressão de imagens', 'Logs de acesso'),
    ('seed_tecnologia_dificil_v2', 'Qual mecanismo pode ajudar a proteger aplicações contra CSRF?', 2, 'Alteração do monitor', 'Balanceadores de carga'),
    ('seed_tecnologia_dificil_v2', 'Qual mecanismo pode ajudar a proteger aplicações contra CSRF?', 3, 'Aumento da memória RAM', 'Compactação de scripts'),
    ('seed_tecnologia_dificil_v2', 'Qual é uma prática recomendada para armazenamento de senhas?', 1, 'Usar a mesma senha para todos os usuários', 'Criptografar as senhas com uma chave única guardada no mesmo servidor'),
    ('seed_tecnologia_dificil_v2', 'Qual é uma prática recomendada para armazenamento de senhas?', 2, 'Armazenar senhas em texto puro', 'Guardar as senhas em arquivos de texto protegidos por permissões do sistema'),
    ('seed_tecnologia_dificil_v2', 'Qual é uma prática recomendada para armazenamento de senhas?', 3, 'Armazenar senhas diretamente no código-fonte', 'Codificar as senhas em Base64 antes de gravá-las no banco de dados'),
    ('seed_tecnologia_dificil_v2', 'Por que um salt é utilizado no armazenamento de senhas?', 0, 'Para armazenar arquivos maiores', 'Para reduzir o tamanho do hash gravado no banco de dados'),
    ('seed_tecnologia_dificil_v2', 'Por que um salt é utilizado no armazenamento de senhas?', 1, 'Para substituir autenticação', 'Para permitir recuperar a senha original quando o usuário a esquece'),
    ('seed_tecnologia_dificil_v2', 'Por que um salt é utilizado no armazenamento de senhas?', 2, 'Para aumentar a velocidade da internet', 'Para acelerar a verificação das senhas durante o processo de login'),
    ('seed_tecnologia_dificil_v2', 'Qual é a finalidade principal de HTTPS?', 0, 'Aumentar a capacidade do disco', 'Acelerar a comunicação HTTP utilizando cache'),
    ('seed_tecnologia_dificil_v2', 'Qual é a finalidade principal de HTTPS?', 1, 'Substituir o DNS', 'Traduzir nomes de domínio em endereços IP'),
    ('seed_tecnologia_dificil_v2', 'Qual é a finalidade principal de HTTPS?', 2, 'Eliminar todos os vírus', 'Compactar a comunicação HTTP utilizando gzip'),
    ('seed_tecnologia_dificil_v2', 'O que é TLS?', 0, 'Linguagem de programação', 'Protocolo de roteamento utilizado para encaminhar pacotes entre redes'),
    ('seed_tecnologia_dificil_v2', 'O que é TLS?', 2, 'Banco de dados', 'Protocolo de transferência utilizado para enviar arquivos entre servidores'),
    ('seed_tecnologia_dificil_v2', 'O que é TLS?', 3, 'Sistema operacional', 'Protocolo de resolução utilizado para localizar domínios na internet'),
    ('seed_tecnologia_dificil_v2', 'Em criptografia assimétrica, qual característica é correta?', 0, 'Funciona somente sem internet', 'Utiliza uma única chave secreta compartilhada entre quem envia e quem recebe'),
    ('seed_tecnologia_dificil_v2', 'Em criptografia assimétrica, qual característica é correta?', 1, 'Utiliza sempre uma única chave compartilhada', 'Utiliza apenas algoritmos de hash, sem qualquer chave envolvida no processo'),
    ('seed_tecnologia_dificil_v2', 'Em criptografia assimétrica, qual característica é correta?', 2, 'Não utiliza chaves', 'Utiliza uma chave pública para cifrar e a mesma chave pública para decifrar'),
    ('seed_tecnologia_dificil_v2', 'Qual é uma diferença fundamental entre criptografia simétrica e assimétrica?', 0, 'Ambas utilizam obrigatoriamente a mesma chave', 'A simétrica é usada somente em redes locais privadas, enquanto a assimétrica é usada somente em redes públicas abertas'),
    ('seed_tecnologia_dificil_v2', 'Qual é uma diferença fundamental entre criptografia simétrica e assimétrica?', 1, 'A simétrica não utiliza matemática', 'A simétrica depende de certificados emitidos por terceiros, enquanto a assimétrica depende de uma senha numérica'),
    ('seed_tecnologia_dificil_v2', 'Qual é uma diferença fundamental entre criptografia simétrica e assimétrica?', 3, 'A assimétrica não possui chaves', 'A simétrica serve apenas para assinaturas digitais, enquanto a assimétrica serve apenas para compactar dados'),
    ('seed_tecnologia_dificil_v2', 'O que é uma assinatura digital?', 0, 'Uma imagem digitalizada de uma assinatura manuscrita', 'Mecanismo criptográfico usado para ocultar o conteúdo de uma mensagem de qualquer pessoa sem a chave'),
    ('seed_tecnologia_dificil_v2', 'O que é uma assinatura digital?', 2, 'Um tipo de senha', 'Mecanismo de compressão usado para reduzir o tamanho de uma mensagem ou documento antes do envio'),
    ('seed_tecnologia_dificil_v2', 'O que é uma assinatura digital?', 3, 'Um antivírus', 'Registro digitalizado usado para comprovar a presença física de uma pessoa em um local ou evento'),
    ('seed_tecnologia_dificil_v2', 'Em inteligência artificial, o que é overfitting?', 0, 'Quando o computador fica sem energia', 'Quando o modelo aprende poucos padrões do conjunto de treinamento e não consegue ajustar-se nem a esses dados'),
    ('seed_tecnologia_dificil_v2', 'Em inteligência artificial, o que é overfitting?', 2, 'Quando o modelo não recebe nenhum dado', 'Quando o modelo é treinado com dados demais e passa a consumir mais memória do que o computador possui'),
    ('seed_tecnologia_dificil_v2', 'Em inteligência artificial, o que é overfitting?', 3, 'Quando o banco de dados é apagado', 'Quando o modelo ignora o conjunto de treinamento e passa a aprender apenas com os dados de validação'),
    ('seed_tecnologia_dificil_v2', 'Qual técnica pode ajudar a reduzir overfitting em modelos de Machine Learning?', 1, 'Remover completamente os dados de validação', 'Treino mais longo'),
    ('seed_tecnologia_dificil_v2', 'Qual técnica pode ajudar a reduzir overfitting em modelos de Machine Learning?', 2, 'Treinar sempre com uma única amostra', 'Menos dados de treino'),
    ('seed_tecnologia_dificil_v2', 'Qual técnica pode ajudar a reduzir overfitting em modelos de Machine Learning?', 3, 'Eliminar qualquer avaliação do modelo', 'Modelo maior'),
    ('seed_tecnologia_dificil_v2', 'O que é um conjunto de validação em Machine Learning?', 0, 'Arquivo de configuração da rede', 'Dados utilizados para treinar os parâmetros internos do modelo antes de qualquer avaliação'),
    ('seed_tecnologia_dificil_v2', 'O que é um conjunto de validação em Machine Learning?', 1, 'Dados utilizados exclusivamente para armazenar senhas', 'Dados utilizados para medir o desempenho final do modelo somente depois de concluído'),
    ('seed_tecnologia_dificil_v2', 'O que é um conjunto de validação em Machine Learning?', 3, 'Banco de dados do sistema operacional', 'Dados utilizados para substituir os valores ausentes do conjunto de treinamento'),
    ('seed_tecnologia_dificil_v2', 'O que é inferência em um modelo de Machine Learning?', 1, 'Processo de formatar o computador', 'Processo de ajustar os parâmetros de um modelo para reduzir o erro nos dados de treinamento'),
    ('seed_tecnologia_dificil_v2', 'O que é inferência em um modelo de Machine Learning?', 2, 'Processo de instalar memória RAM', 'Processo de coletar e rotular grandes volumes de dados para alimentar um modelo ainda não treinado'),
    ('seed_tecnologia_dificil_v2', 'O que é inferência em um modelo de Machine Learning?', 3, 'Processo de apagar o modelo', 'Processo de comparar vários modelos treinados para escolher o que apresenta menor custo de execução'),
    ('seed_tecnologia_dificil_v2', 'O que é containerização?', 0, 'Armazenamento de arquivos em um pendrive', 'Divisão de uma aplicação em módulos independentes executados em máquinas físicas separadas'),
    ('seed_tecnologia_dificil_v2', 'O que é containerização?', 1, 'Criação de uma máquina física', 'Simulação de um computador completo com sistema operacional próprio sobre um hardware emulado'),
    ('seed_tecnologia_dificil_v2', 'O que é containerização?', 3, 'Exclusão de dependências de software', 'Replicação de uma aplicação em vários servidores para distribuir o tráfego entre eles'),
    ('seed_tecnologia_dificil_v2', 'Qual é uma vantagem importante da containerização?', 0, 'Eliminar completamente a necessidade de segurança', 'Dispensar a necessidade de atualizar as dependências da aplicação'),
    ('seed_tecnologia_dificil_v2', 'Qual é uma vantagem importante da containerização?', 1, 'Garantir que nenhum sistema apresente falhas', 'Eliminar a necessidade de testar a aplicação antes da implantação'),
    ('seed_tecnologia_dificil_v2', 'Qual é uma vantagem importante da containerização?', 3, 'Tornar todo software automaticamente gratuito', 'Substituir o sistema operacional do servidor por um sistema próprio'),
    ('seed_tecnologia_dificil_v2', 'O que é CI/CD no desenvolvimento de software?', 0, 'Um formato de imagem', 'Práticas e processos para planejar, documentar e arquivar requisitos de forma detalhada e periódica'),
    ('seed_tecnologia_dificil_v2', 'O que é CI/CD no desenvolvimento de software?', 1, 'Um tipo de memória de computador', 'Práticas e processos para monitorar, medir e cobrar o uso de servidores de forma contínua e precisa'),
    ('seed_tecnologia_dificil_v2', 'O que é CI/CD no desenvolvimento de software?', 3, 'Um protocolo de internet', 'Práticas e processos para revisar, aprovar e liberar mudanças de forma manual e individual'),
    ('seed_tecnologia_dificil_v3', 'Qual é a principal finalidade de uma arquitetura de microsserviços?', 1, 'Colocar todos os códigos em um único arquivo', 'Reunir vários serviços independentes em uma única aplicação compacta executada como um só bloco'),
    ('seed_tecnologia_dificil_v3', 'Qual é a principal finalidade de uma arquitetura de microsserviços?', 2, 'Eliminar completamente bancos de dados', 'Replicar uma aplicação inteira em vários servidores para suportar mais acessos simultâneos'),
    ('seed_tecnologia_dificil_v3', 'Qual é a principal finalidade de uma arquitetura de microsserviços?', 3, 'Substituir todos os servidores físicos', 'Dividir uma aplicação em camadas visuais que se comunicam apenas por meio do navegador'),
    ('seed_tecnologia_dificil_v3', 'O que é computação em nuvem híbrida?', 0, 'Armazenamento somente em dispositivos móveis', 'Modelo que utiliza somente servidores de um único provedor de nuvem'),
    ('seed_tecnologia_dificil_v3', 'O que é computação em nuvem híbrida?', 2, 'Uso apenas de computadores pessoais', 'Modelo que mantém todos os sistemas apenas em servidores da própria empresa'),
    ('seed_tecnologia_dificil_v3', 'O que é computação em nuvem híbrida?', 3, 'Sistema sem conexão com internet', 'Modelo que divide os dados entre dois provedores de nuvem concorrentes')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Tecnologia difícil lote 4: perguntas 26 a 48 do seed dificil_v2 (migration 056) e 1 e 2 do seed dificil_v3 (migration 066): % alternativa(s) errada(s) atualizada(s) (esperado: 75).', v_updated;
END $$;
