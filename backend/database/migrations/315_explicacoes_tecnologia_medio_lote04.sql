-- Explicações pedagógicas (BE-004) — Tecnologia médio lote 4: perguntas 30 a 33 do seed medio_v2 (migration 055) e 1 a 21 do seed medio_v3 (migration 060).
-- Preenche questions.explanation com o "Por quê?" de cada pergunta (raciocínio e contexto, nível médio, conforme
-- docs/quiz-v2-rodadas-e-feedback.md), já coerente com as alternativas novas da migration 314. Só atualiza perguntas
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
    ('seed_tecnologia_medio_v2', 'Qual empresa fornece serviços de nuvem?', 'A Amazon Web Services (AWS) é uma empresa que fornece serviços de nuvem, como servidores, armazenamento e bancos de dados alugados pela internet. Os outros nomes são produtos de edição, redes sociais e mensagens, que não vendem infraestrutura de nuvem.'),
    ('seed_tecnologia_medio_v2', 'O que é um aplicativo móvel?', 'Aplicativo móvel é um programa desenvolvido para dispositivos móveis, como smartphones e tablets, e instalado a partir de uma loja. Programas de computador de mesa, peças ou sistemas operacionais são outra coisa.'),
    ('seed_tecnologia_medio_v2', 'O que é uma falha de segurança?', 'Falha de segurança, ou vulnerabilidade, é um ponto fraco de um sistema que pode ser explorado por atacantes. Por isso as atualizações que a corrigem são importantes. Atualizações, permissões e cópias de segurança não são falhas.'),
    ('seed_tecnologia_medio_v2', 'Por que a segurança digital é importante?', 'A segurança digital é importante porque protege dados e sistemas contra ameaças, como vírus, golpes e invasões, evitando prejuízos e perda de privacidade. Organizar, acelerar ou embelezar sistemas não é o objetivo dela.'),
    ('seed_tecnologia_medio_v3', 'Qual é a principal função de uma placa de vídeo (GPU)?', 'A GPU processa gráficos e acelera tarefas visuais, como jogos e edição de vídeo, aliviando o processador. Controlar a temperatura, executar instruções gerais ou acelerar o disco são funções de outros componentes.'),
    ('seed_tecnologia_medio_v3', 'O que significa BIOS em um computador?', 'A BIOS é o sistema básico que inicializa o hardware quando o computador liga e passa o controle ao sistema operacional. Não é o sistema operacional, nem um sistema de rede ou de segurança.'),
    ('seed_tecnologia_medio_v3', 'Qual é a função de um driver de dispositivo?', 'O driver é o programa que permite a comunicação entre o sistema operacional e o hardware, como a impressora ou a placa de vídeo, traduzindo os comandos. Sem o driver certo, o dispositivo pode não funcionar. Ele não faz a ponte entre o roteador e o provedor.'),
    ('seed_tecnologia_medio_v3', 'O que é uma partição de disco?', 'Partição é a divisão lógica de uma unidade de armazenamento em partes que o sistema trata como discos separados, útil para instalar sistemas ou organizar dados. Não é uma divisão física, uma cópia nem uma junção de unidades.'),
    ('seed_tecnologia_medio_v3', 'Qual é a diferença principal entre RAM e armazenamento interno?', 'A RAM é temporária: guarda dados só enquanto o computador está ligado e é rápida; o armazenamento guarda os dados de forma permanente, mesmo desligado. Por isso os papéis são distintos, e a RAM influencia muito o desempenho.'),
    ('seed_tecnologia_medio_v3', 'O que é cache de processador?', 'O cache do processador é uma memória muito rápida e pequena, que guarda dados usados com frequência para o processador não ter de buscá-los na memória mais lenta. Não é armazenamento permanente, espaço para programas nem proteção de senhas.'),
    ('seed_tecnologia_medio_v3', 'O que significa resolução de tela?', 'Resolução de tela é a quantidade de pixels exibidos numa imagem, em largura e altura, e quanto maior, mais detalhes. Não é a quantidade de cores, o tamanho físico da tela nem a quantidade de quadros de um vídeo.'),
    ('seed_tecnologia_medio_v3', 'Qual tecnologia permite comunicação sem fio de curto alcance entre dispositivos?', 'Bluetooth é a tecnologia de comunicação sem fio de curto alcance entre dispositivos. Ethernet, Thunderbolt e DisplayPort são conexões por cabo, usadas em redes, dados e vídeo.'),
    ('seed_tecnologia_medio_v3', 'Para que serve uma porta USB?', 'A porta USB conecta dispositivos e transfere dados ou energia, como carregar um celular ou ligar um pen drive. Transmitir áudio e vídeo digital é papel do HDMI, e as redes usam outras interfaces.'),
    ('seed_tecnologia_medio_v3', 'O que é HDMI?', 'HDMI é uma interface usada principalmente para transmitir áudio e vídeo digital, por exemplo, entre um computador e uma TV. Transmitir dados e energia é papel do USB, e conectar redes é papel do Ethernet.'),
    ('seed_tecnologia_medio_v3', 'Qual é a função de um antivírus?', 'O antivírus detecta e remove softwares maliciosos, como vírus e trojans, e ajuda a prevenir infecções. Verificar o disco, compactar arquivos ou limpar o histórico são outras tarefas, feitas por outras ferramentas.'),
    ('seed_tecnologia_medio_v3', 'O que é autenticação multifator?', 'A autenticação multifator usa mais de uma forma de verificar a identidade, como senha mais código no celular ou digital. Duas senhas ou vários usuários não formam fatores diferentes, e é a variedade que dá a segurança extra.'),
    ('seed_tecnologia_medio_v3', 'O que é engenharia social na segurança digital?', 'Engenharia social é a manipulação de pessoas, por conversa ou mensagem, para obter informações ou acesso, como fazer alguém contar a senha. Explora a confiança humana, não falhas técnicas. Proteger, criptografar ou instalar programas são outras coisas.'),
    ('seed_tecnologia_medio_v3', 'Qual é a finalidade de uma senha forte?', 'Uma senha forte serve para dificultar acessos não autorizados, porque é difícil de adivinhar. Não acelera acessos nem organiza contas, e não substitui o antivírus: cada proteção cobre um tipo de risco.'),
    ('seed_tecnologia_medio_v3', 'O que é um sistema embarcado?', 'Sistema embarcado é um sistema computacional integrado dentro de um equipamento específico, como um carro ou um micro-ondas, para controlar uma função. Não é um sistema geral para computadores, nem um armazenamento remoto.'),
    ('seed_tecnologia_medio_v3', 'Qual exemplo representa um sistema embarcado?', 'O sistema que controla uma máquina de lavar inteligente é um sistema embarcado: está integrado ao equipamento e controla uma função específica. Aplicativos de conta bancária, sistemas de lojas ou arquivos de configuração são programas gerais.'),
    ('seed_tecnologia_medio_v3', 'O que é um hipervisor?', 'O hipervisor é o software responsável por criar e gerenciar máquinas virtuais, dividindo os recursos de um computador físico entre vários sistemas. Não gerencia contas, não baixa programas nem é hardware de rede.'),
    ('seed_tecnologia_medio_v3', 'O que é uma atualização de firmware?', 'A atualização de firmware altera o software interno de um dispositivo, como o roteador ou a TV, para corrigir falhas ou melhorar o funcionamento. Não troca a peça física, o aplicativo nem a conta.'),
    ('seed_tecnologia_medio_v3', 'O que é código QR?', 'O código QR é um código visual, de quadradinhos, que armazena informações que um aparelho acessa ao lê-lo com a câmera. Não é um código numérico digitado, um programa instalado nem uma imagem comum.'),
    ('seed_tecnologia_medio_v3', 'O que é NFC?', 'NFC é uma tecnologia de comunicação sem fio de curta distância, de poucos centímetros, usada em pagamentos por aproximação. Não é por cabo, não tem longo alcance e não localiza por satélite.'),
    ('seed_tecnologia_medio_v3', 'Qual é a principal função de um modem?', 'O modem converte os sinais da linha do provedor em sinais digitais, permitindo a comunicação com a rede. Distribuir o sinal pela casa é papel do roteador, e proteger ou amplificar o sinal são outras funções.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Tecnologia médio lote 4: perguntas 30 a 33 do seed medio_v2 (migration 055) e 1 a 21 do seed medio_v3 (migration 060): % pergunta(s) atualizada(s) (esperado: 25).', v_updated;
END $$;
