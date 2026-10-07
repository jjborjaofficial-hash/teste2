-- Explicações pedagógicas (BE-004) — Tecnologia médio lote 2: perguntas 26 a 46 do seed medio_v1 (migration 034) e 1 a 4 do seed medio_v2 (migration 055).
-- Preenche questions.explanation com o "Por quê?" de cada pergunta (raciocínio e contexto, nível médio, conforme
-- docs/quiz-v2-rodadas-e-feedback.md), já coerente com as alternativas novas da migration 310. Só atualiza perguntas
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
    ('seed_tecnologia_medio_v1', 'O que é machine learning?', 'Machine learning, ou aprendizado de máquina, é a área da inteligência artificial em que os sistemas aprendem padrões a partir de dados, em vez de seguirem apenas regras escritas à mão. É assim que um filtro de spam melhora com o tempo. Não é robótica, antivírus ou computação gráfica.'),
    ('seed_tecnologia_medio_v1', 'O que é programação?', 'Programar é criar instruções, numa linguagem que o computador entenda, para que ele execute tarefas, como calcular ou mostrar uma página. Montar peças, instalar programas ou desenhar interfaces são atividades diferentes.'),
    ('seed_tecnologia_medio_v1', 'O que é uma linguagem de programação?', 'Uma linguagem de programação é uma linguagem formal usada para escrever instruções que o computador consegue interpretar, com regras próprias de escrita. Difere dos idiomas falados, que as pessoas entendem, e de sistemas ou dispositivos.'),
    ('seed_tecnologia_medio_v1', 'Qual destes é uma linguagem de programação?', 'Python é uma linguagem de programação, usada para escrever instruções que o computador executa. Chrome é um navegador, Bluetooth é uma tecnologia de conexão e o Windows Explorer é o gerenciador de arquivos do Windows.'),
    ('seed_tecnologia_medio_v1', 'O que é aplicativo móvel?', 'Aplicativo móvel é um programa feito para funcionar em dispositivos móveis, como smartphones e tablets, e instalado a partir de uma loja. Programas para computadores de mesa, peças ou sistemas operacionais não são aplicativos móveis.'),
    ('seed_tecnologia_medio_v1', 'O que é uma atualização de software?', 'A atualização de software é uma alteração que melhora o programa, corrige problemas ou adiciona recursos. Não serve para proteger, copiar arquivos ou ocultar problemas, e quem a ignora pode ficar sem correções importantes.'),
    ('seed_tecnologia_medio_v1', 'Por que atualizar programas é importante?', 'Atualizar programas é importante porque as atualizações podem corrigir falhas e melhorar a segurança e o funcionamento. Falhas conhecidas são a porta de entrada de muitos ataques. Elas não servem para liberar espaço, aumentar a memória ou instalar anúncios.'),
    ('seed_tecnologia_medio_v1', 'O que é banco de dados?', 'Banco de dados é um sistema organizado para armazenar e gerenciar informações, permitindo consultar, atualizar e relacionar dados com rapidez. É o que guarda, por exemplo, os cadastros de uma loja. Não é sistema de mensagens, de proteção ou de execução de programas.'),
    ('seed_tecnologia_medio_v1', 'O que é uma aplicação web?', 'Uma aplicação web é um programa acessado por meio de um navegador, pela internet ou por uma rede, sem precisar instalar nada. É o caso de e-mails e planilhas online. Programas instalados no celular ou gravados em discos não são aplicações web.'),
    ('seed_tecnologia_medio_v1', 'O que é servidor?', 'Servidor é um computador ou sistema que fornece serviços e recursos, como páginas, arquivos ou e-mails, a outros dispositivos, chamados clientes. O contrário, que consome esses serviços, é o cliente. Aplicativos de mensagens e redes não são o servidor.'),
    ('seed_tecnologia_medio_v1', 'O que é endereço IP?', 'O endereço IP é uma identificação numérica atribuída a cada dispositivo numa rede, como o endereço de uma casa que permite entregar dados no lugar certo. O nome em letras de um site é o domínio, e o identificador de usuário é outra coisa.'),
    ('seed_tecnologia_medio_v1', 'O que é domínio de internet?', 'O domínio é o nome usado para identificar um site na internet, como exemplo.com, mais fácil de lembrar do que um número. O número que identifica um aparelho é o endereço IP, e o código de proteção e o programa de visualização são outras coisas.'),
    ('seed_tecnologia_medio_v1', 'O que é código-fonte?', 'Código-fonte é o conjunto de instruções escritas por programadores, numa linguagem de programação, para criar um software. É a partir dele que o programa é construído. Arquivos de instalação, mensagens e dados de usuários não são o código-fonte.'),
    ('seed_tecnologia_medio_v1', 'O que é código aberto (open source)?', 'Em um software de código aberto, o código pode ser analisado e modificado, dentro do que a licença permite, o que facilita a colaboração e a auditoria. Isso não é o mesmo que ser gratuito, e não significa que qualquer um possa invadir ou alterar o programa.'),
    ('seed_tecnologia_medio_v1', 'O que é API?', 'API é uma interface que permite a comunicação entre diferentes sistemas ou aplicações, definindo como um pedido deve ser feito e como a resposta volta. Por exemplo, um aplicativo de clima usa uma API para buscar a previsão. Não é um sistema operacional nem um protocolo de rede.'),
    ('seed_tecnologia_medio_v1', 'Para que serve uma API?', 'A API serve para permitir a integração e a troca de informações entre sistemas, sem que um precise conhecer o funcionamento interno do outro. Não instala programas, não bloqueia acessos e não edita imagens.'),
    ('seed_tecnologia_medio_v1', 'O que é criptografia?', 'Criptografia é a técnica de proteger informações transformando os dados em algo ilegível para quem não tem a chave, impedindo o acesso não autorizado. É o que protege mensagens e pagamentos online. Recuperar, comprimir ou organizar dados são outras técnicas.'),
    ('seed_tecnologia_medio_v1', 'O que é blockchain?', 'Blockchain é uma tecnologia de registro distribuído: as informações são organizadas em blocos ligados por mecanismos criptográficos e guardadas em vários computadores, o que dificulta alterações. Um banco de dados comum é centralizado, o que a distingue.'),
    ('seed_tecnologia_medio_v1', 'O que é realidade virtual?', 'Realidade virtual é a tecnologia que cria ambientes digitais imersivos, simulados por computador, em que o usuário se sente dentro de outro lugar, geralmente com óculos próprios. A que sobrepõe elementos digitais ao mundo real é a realidade aumentada.'),
    ('seed_tecnologia_medio_v1', 'O que é Internet das Coisas (IoT)?', 'A Internet das Coisas é a conexão de objetos físicos, como lâmpadas, relógios e geladeiras, à internet, para coletar e trocar dados. Não se limita a computadores pessoais, a sistemas virtuais ou a aplicativos móveis.'),
    ('seed_tecnologia_medio_v1', 'Qual é uma boa prática de segurança digital?', 'Manter os sistemas atualizados corrige falhas conhecidas, e proteger as informações pessoais reduz o risco de golpes. Usar senhas fáceis e repetidas, desativar proteções ou publicar dados pessoais deixa o usuário exposto.'),
    ('seed_tecnologia_medio_v2', 'Qual é a principal função de um sistema operacional?', 'O sistema operacional controla o hardware e permite a execução dos programas, fazendo a ligação entre as peças e os aplicativos. Proteger contra ameaças, abrir páginas ou trocar componentes não é a função principal dele.'),
    ('seed_tecnologia_medio_v2', 'Qual componente do computador é responsável pelo processamento de informações?', 'A CPU é o componente responsável pelo processamento: executa as instruções dos programas e faz os cálculos. O SSD guarda dados, a fonte fornece energia e o mouse é um dispositivo de entrada.'),
    ('seed_tecnologia_medio_v2', 'Qual é a função principal da memória RAM?', 'A RAM armazena dados temporariamente enquanto os programas estão em execução, o que permite ao computador acessá-los depressa. Quando o aparelho desliga, esses dados se perdem. Guardar arquivos de forma permanente é função do armazenamento.'),
    ('seed_tecnologia_medio_v2', 'Qual destas opções representa um dispositivo de armazenamento?', 'O SSD é um dispositivo de armazenamento: guarda dados mesmo com o computador desligado. A CPU e a GPU processam informações, e o mouse é um dispositivo de entrada.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Tecnologia médio lote 2: perguntas 26 a 46 do seed medio_v1 (migration 034) e 1 a 4 do seed medio_v2 (migration 055): % pergunta(s) atualizada(s) (esperado: 25).', v_updated;
END $$;
