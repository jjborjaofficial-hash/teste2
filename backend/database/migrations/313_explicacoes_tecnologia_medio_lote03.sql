-- Explicações pedagógicas (BE-004) — Tecnologia médio lote 3: perguntas 5 a 29 do seed medio_v2 (migration 055).
-- Preenche questions.explanation com o "Por quê?" de cada pergunta (raciocínio e contexto, nível médio, conforme
-- docs/quiz-v2-rodadas-e-feedback.md), já coerente com as alternativas novas da migration 312. Só atualiza perguntas
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
    ('seed_tecnologia_medio_v2', 'Qual é uma vantagem do SSD em comparação ao HD?', 'O SSD não tem peças móveis e usa memória flash, por isso lê e grava dados mais depressa que o HD, que depende de discos giratórios. Isso acelera o arranque do computador e a abertura dos programas. Em geral, custa mais por gigabyte.'),
    ('seed_tecnologia_medio_v2', 'O que significa hardware?', 'Hardware é a parte física do computador, o que se pode tocar, como processador, memória, teclado e tela. A parte lógica, formada por programas, é o software. Os dados não são hardware.'),
    ('seed_tecnologia_medio_v2', 'O que significa software?', 'Software é o conjunto de programas e sistemas usados pelo computador, como o sistema operacional e os aplicativos, e é a parte lógica que dá instruções ao hardware. Peças, cabos e placas são hardware.'),
    ('seed_tecnologia_medio_v2', 'Qual é a função de uma placa-mãe?', 'A placa-mãe é a placa principal do computador: nela se encaixam e se comunicam o processador, a memória e o armazenamento. Processar dados é função do processador, guardar arquivos é do armazenamento e a energia vem da fonte.'),
    ('seed_tecnologia_medio_v2', 'Qual equipamento normalmente distribui internet para vários dispositivos?', 'O roteador recebe a conexão da internet e a distribui para vários dispositivos, por cabo ou por Wi-Fi. Teclado, scanner e projetor são dispositivos de entrada e de saída, sem função de distribuir rede.'),
    ('seed_tecnologia_medio_v2', 'O que representa um endereço IP?', 'O endereço IP identifica um dispositivo numa rede, como o endereço de uma casa permite entregar uma encomenda. Não identifica um usuário, um site pelo nome ou um arquivo: esses têm outros identificadores.'),
    ('seed_tecnologia_medio_v2', 'Para que serve o DNS?', 'O DNS funciona como uma lista telefônica da internet: converte nomes de sites, fáceis de lembrar, em endereços IP, que as máquinas usam para se encontrar. Sem ele, teríamos de digitar números para abrir cada site.'),
    ('seed_tecnologia_medio_v2', 'Qual é a principal função de um backup?', 'O backup cria uma cópia de segurança dos dados, para poder recuperá-los se houver perda, defeito ou ataque. Não remove vírus nem acelera nada; só garante que existe outra cópia.'),
    ('seed_tecnologia_medio_v2', 'Qual prática aumenta a segurança de uma conta?', 'A autenticação de dois fatores exige, além da senha, uma segunda confirmação, como um código no celular, o que protege a conta mesmo que a senha vaze. Repetir senhas, usar datas pessoais ou instalar programas de origem duvidosa aumenta o risco.'),
    ('seed_tecnologia_medio_v2', 'O que é uma API?', 'A API é uma interface que permite que sistemas diferentes se comuniquem, definindo como pedir e receber dados. Por exemplo, um aplicativo de clima obtém a previsão por uma API. Não é um sistema que executa programas nem uma memória.'),
    ('seed_tecnologia_medio_v2', 'Qual destes é um sistema de gerenciamento de banco de dados?', 'MySQL é um sistema de gerenciamento de banco de dados: guarda e organiza dados e permite consultá-los. Bluetooth e HDMI são tecnologias de conexão, e o Windows Explorer é o gerenciador de arquivos do Windows.'),
    ('seed_tecnologia_medio_v2', 'Qual destas é uma linguagem de programação?', 'Python é uma linguagem de programação, usada para escrever instruções que o computador executa. Windows e Android são sistemas operacionais, e Wi-Fi é uma tecnologia de rede sem fio.'),
    ('seed_tecnologia_medio_v2', 'O que significa IoT?', 'IoT vem de Internet of Things, a Internet das Coisas: objetos do dia a dia ligados à internet, que coletam e trocam dados. Não é um sistema operacional, um processador nem uma internet dos computadores.'),
    ('seed_tecnologia_medio_v2', 'Qual exemplo representa IoT?', 'Um relógio inteligente conectado à internet é um exemplo de IoT: um objeto físico que envia e recebe dados. Uma lâmpada comum, uma calculadora simples e uma impressora ligada por cabo não usam a internet.'),
    ('seed_tecnologia_medio_v2', 'O que é frontend?', 'O frontend é a parte visual de uma aplicação, aquilo que o usuário vê e com que interage, como botões e telas. A lógica e o processamento ficam no backend, e os dados no banco de dados.'),
    ('seed_tecnologia_medio_v2', 'O que é backend?', 'O backend é a parte responsável pela lógica e pelo processamento do sistema, que o usuário não vê: valida pedidos, aplica regras e fala com o banco de dados. A aparência e a interação ficam no frontend.'),
    ('seed_tecnologia_medio_v2', 'O que é autenticação?', 'Autenticação é o processo de confirmar quem é o usuário, por exemplo com senha, código ou impressão digital. É diferente da autorização, que define o que ele pode fazer depois de entrar, e de criar a conta.'),
    ('seed_tecnologia_medio_v2', 'O que é autorização?', 'Autorização é definir o que cada usuário pode acessar ou fazer, depois de ele ter sido identificado. Confirmar a identidade é a autenticação, e registrar as atividades é função dos logs.'),
    ('seed_tecnologia_medio_v2', 'O que é VPN?', 'A VPN cria uma conexão protegida pela internet, com os dados cifrados, o que protege quem usa redes públicas. Não é o Wi-Fi de casa, nem uma cópia de segurança, nem o serviço que traduz nomes de sites.'),
    ('seed_tecnologia_medio_v2', 'O que significa latência?', 'Latência é o tempo de atraso na comunicação de dados: o intervalo entre enviar um pedido e receber a resposta. Latência alta causa travamentos em jogos online e chamadas. Não é a quantidade de dados por segundo, que é a largura de banda.'),
    ('seed_tecnologia_medio_v2', 'O que significa código aberto?', 'Código aberto é o código que está disponível para estudo e modificação, conforme a licença. Isso não é o mesmo que gratuito nem que ausência de licença, e não significa que seja inseguro ou que esteja escondido.'),
    ('seed_tecnologia_medio_v2', 'O que é atualização de software?', 'Uma atualização de software é uma melhoria ou correção de um programa, com novos recursos ou correções de falhas. Não é cópia, compra ou isolamento do programa. Quem as ignora pode ficar sem correções de segurança.'),
    ('seed_tecnologia_medio_v2', 'Qual é a função de um servidor?', 'O servidor fornece serviços ou dados a outros dispositivos, que são os clientes, como páginas, arquivos ou e-mails. Consumir esses serviços é papel do cliente, e exibir imagens ou controlar energia não é função do servidor.'),
    ('seed_tecnologia_medio_v2', 'O que são logs?', 'Logs são registros das atividades realizadas pelos sistemas, como acessos, erros e operações. Servem para investigar problemas e auditar. Não são arquivos quaisquer, programas nem cópias de segurança.'),
    ('seed_tecnologia_medio_v2', 'O que é escalabilidade?', 'Escalabilidade é a capacidade de um sistema crescer e suportar mais usuários ou mais carga sem perder desempenho. Proteger dados, reduzir custos ou recuperar dados após falhas são outras qualidades.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Tecnologia médio lote 3: perguntas 5 a 29 do seed medio_v2 (migration 055): % pergunta(s) atualizada(s) (esperado: 25).', v_updated;
END $$;
