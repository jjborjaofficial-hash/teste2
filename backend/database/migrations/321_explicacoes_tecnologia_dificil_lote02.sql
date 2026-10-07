-- Explicações pedagógicas (BE-004) — Tecnologia difícil lote 2: perguntas 26 a 50 do seed dificil_v1 (migration 036).
-- Preenche questions.explanation com o "Por quê?" de cada pergunta (raciocínio e relação entre conceitos, nível difícil, conforme
-- docs/quiz-v2-rodadas-e-feedback.md), já coerente com as alternativas novas da migration 320. Só atualiza perguntas
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
    ('seed_tecnologia_dificil_v1', 'O que é machine learning supervisionado?', 'No machine learning supervisionado, o modelo é treinado com dados previamente classificados, ou seja, com a resposta certa conhecida, e aprende a repeti-la em dados novos. No não supervisionado, os dados não têm rótulos, e no aprendizado por reforço o modelo aprende por recompensas.'),
    ('seed_tecnologia_dificil_v1', 'O que é uma rede neural artificial?', 'Uma rede neural artificial é um modelo computacional inspirado na estrutura do cérebro, com camadas de unidades ligadas entre si, capaz de reconhecer padrões nos dados. É a base do deep learning. Não é uma rede de cabos nem um banco de dados.'),
    ('seed_tecnologia_dificil_v1', 'O que é deep learning?', 'Deep learning é a subárea do machine learning baseada em redes neurais profundas, com muitas camadas, que aprende representações complexas, como as de imagens e de fala. Não é segurança, análise de tabelas, nem árvores de decisão simples.'),
    ('seed_tecnologia_dificil_v1', 'O que é processamento de linguagem natural (PLN)?', 'O processamento de linguagem natural é a área da IA que permite aos computadores compreender e gerar a linguagem humana, em textos ou fala, como nos tradutores e nos assistentes virtuais. Reconhecer imagens é visão computacional.'),
    ('seed_tecnologia_dificil_v1', 'O que é visão computacional?', 'A visão computacional é a área da IA que permite aos sistemas interpretar informações visuais de imagens e vídeos, como reconhecer rostos ou objetos. Interpretar sons é outra área, e gerar texto é do processamento de linguagem natural.'),
    ('seed_tecnologia_dificil_v1', 'O que é Big Data?', 'Big Data é um grande volume de dados, muitas vezes variados e gerados rapidamente, que exige tecnologias específicas para processamento e análise. O tamanho do disco, o número de usuários ou de arquivos não definem o conceito.'),
    ('seed_tecnologia_dificil_v1', 'O que significa análise de dados?', 'A análise de dados é o processo de examinar dados para obter informações úteis e apoiar decisões, por exemplo descobrir que produto vende mais. Copiar, apagar ou criptografar dados são operações diferentes, com outros objetivos.'),
    ('seed_tecnologia_dificil_v1', 'O que é mineração de dados?', 'A mineração de dados é o processo de descobrir padrões e informações relevantes em grandes conjuntos de dados, usando técnicas estatísticas e de aprendizado de máquina. É um passo da análise de dados, e não armazenar, proteger ou transmitir dados.'),
    ('seed_tecnologia_dificil_v1', 'O que é blockchain em termos tecnológicos?', 'Blockchain é uma estrutura distribuída de registros, organizados em blocos conectados e protegidos por criptografia, o que torna difícil alterar o passado. Diferente de um banco centralizado, não depende de um servidor único.'),
    ('seed_tecnologia_dificil_v1', 'O que é um contrato inteligente (smart contract)?', 'Um contrato inteligente é um programa executado numa blockchain que realiza ações automaticamente quando as regras definidas são cumpridas, sem intermediário. Um documento assinado, uma cópia agendada ou um pagamento por aplicativo não são contratos inteligentes.'),
    ('seed_tecnologia_dificil_v1', 'O que é edge computing?', 'Edge computing é o processamento de dados próximo ao local onde eles são gerados, em vez de enviá-los a servidores distantes. Por isso difere do armazenamento na nuvem e não é uma transmissão contínua nem um processamento centralizado.'),
    ('seed_tecnologia_dificil_v1', 'Qual é uma vantagem do edge computing?', 'Ao processar os dados mais perto do usuário ou do dispositivo, o edge computing pode reduzir a latência, porque os dados percorrem menos caminho. Isso não elimina a nuvem nem os servidores, e não amplia a segurança por si só.'),
    ('seed_tecnologia_dificil_v1', 'O que é baixa latência?', 'Baixa latência é um pequeno atraso na comunicação ou no processamento de dados, essencial em jogos online e chamadas de vídeo. Não tem a ver com a qualidade da imagem, o espaço de armazenamento nem o número de usuários.'),
    ('seed_tecnologia_dificil_v1', 'O que é arquitetura de microsserviços?', 'Na arquitetura de microsserviços, a aplicação é dividida em pequenos serviços independentes, que se comunicam entre si, cada um com uma função. É o oposto do monólito, em que tudo fica num único bloco, e não é replicação nem telas.'),
    ('seed_tecnologia_dificil_v1', 'Qual é uma vantagem dos microsserviços?', 'Uma vantagem dos microsserviços é permitir desenvolver, atualizar e escalar cada parte da aplicação de forma independente, sem mexer em todo o sistema. Eles não eliminam servidores nem tornam o desenvolvimento sequencial.'),
    ('seed_tecnologia_dificil_v1', 'O que é escalabilidade em sistemas?', 'Escalabilidade é a capacidade de um sistema lidar com o aumento de usuários ou de demanda, mantendo o desempenho. Recuperar dados, reduzir custos ou proteger acessos são outras qualidades, não escalabilidade.'),
    ('seed_tecnologia_dificil_v1', 'O que é escalabilidade horizontal?', 'A escalabilidade horizontal aumenta a capacidade adicionando mais máquinas ou instâncias, e o trabalho é dividido entre elas. Aumentar os recursos de uma única máquina, como memória e CPU, é a escalabilidade vertical.'),
    ('seed_tecnologia_dificil_v1', 'O que é escalabilidade vertical?', 'A escalabilidade vertical aumenta a capacidade de uma máquina existente, como mais CPU ou memória, e tem um limite. Adicionar máquinas é a horizontal, e distribuir tráfego é função de um balanceador.'),
    ('seed_tecnologia_dificil_v1', 'O que é observabilidade em sistemas?', 'Observabilidade é a capacidade de entender o estado interno de um sistema a partir dos dados que ele produz, como logs, métricas e rastreamentos. Não é proteger acessos, ampliar o desempenho nem documentar o sistema.'),
    ('seed_tecnologia_dificil_v1', 'O que são logs em sistemas?', 'Logs são registros de eventos e atividades realizados por aplicações ou sistemas, usados para investigar falhas e auditar acessos. Não são cópias de arquivos, credenciais nem componentes de código.'),
    ('seed_tecnologia_dificil_v1', 'O que é uma vulnerabilidade de software?', 'Uma vulnerabilidade de software é uma falha que pode causar comportamentos inesperados ou ser explorada por atacantes. Corrigi-las é o objetivo das atualizações de segurança. Uma melhoria, um recurso novo ou uma atualização normal não são vulnerabilidades.'),
    ('seed_tecnologia_dificil_v1', 'O que é teste de penetração (pentest)?', 'O teste de penetração, ou pentest, é uma avaliação de segurança que simula ataques controlados para identificar vulnerabilidades antes de um atacante real. Difere de testes de desempenho, de monitoramento e de auditorias de licenças.'),
    ('seed_tecnologia_dificil_v1', 'O que é Zero Trust em segurança?', 'Zero Trust é o modelo de segurança que assume que nenhuma entidade deve ser automaticamente confiável, nem dentro da rede, e exige verificação contínua. É o contrário de confiar após o login ou conforme o cargo.'),
    ('seed_tecnologia_dificil_v1', 'O que é API Gateway?', 'O API Gateway é o componente que gerencia e controla o acesso às APIs numa arquitetura de sistemas, como autenticação, limites de uso e roteamento. Não armazena dados, não executa cálculos e não remove ameaças.'),
    ('seed_tecnologia_dificil_v1', 'Por que a segurança da informação é importante?', 'A segurança da informação é importante para proteger dados, sistemas e usuários contra acessos indevidos, perdas ou ataques, mantendo confidencialidade, integridade e disponibilidade. Armazenar, acelerar ou organizar não são o objetivo dela.')
  ) AS v(source, statement, explanation)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND q.explanation IS NULL;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicações Tecnologia difícil lote 2: perguntas 26 a 50 do seed dificil_v1 (migration 036): % pergunta(s) atualizada(s) (esperado: 25).', v_updated;
END $$;
