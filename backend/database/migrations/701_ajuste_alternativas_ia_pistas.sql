-- Ajuste de alternativas (BE-003, resíduo de pistas) — Inteligência Artificial: 50 alternativas erradas reescritas em 30 perguntas que só tinham avisos de pista.
-- Regra do dono: a resposta CERTA e a EXPLICAÇÃO NÃO mudam; só o texto de alternativas ERRADAS é ajustado (comprimento/palavras).
-- O nome `*_ajuste_alternativas_*` diz ao teste dos lotes que este texto substitui o do lote.
-- Segurança: só altera question_alternatives.label, só de erradas (is_correct = FALSE), e só se o texto atual ainda for exatamente
-- o original (idempotente; nunca sobrescreve edição posterior). O runner já envolve o ficheiro numa transação.

DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE question_alternatives a
  SET label = v.new_label
  FROM questions q,
  (VALUES
    ('seed_ia_medio_v3', 'O que é uma alucinação em um modelo generativo?', 0, 'Produção de conteúdo lento porque o servidor tem muitos pedidos para processar em simultâneo', 'Produção de conteúdo lento, devido ao excesso de pedidos no servidor'),
    ('seed_ia_medio_v3', 'O que é uma alucinação em um modelo generativo?', 1, 'Recusa de responder a um pedido porque o conteúdo é considerado inadequado ou perigoso', 'Recusa de responder a pedidos, por considerar o conteúdo inadequado ou perigoso'),
    ('seed_ia_facil_v1', 'Para que pode ser usada uma IA generativa?', 1, 'Para aumentar a velocidade da conexão com a internet', 'Para aumentar a velocidade, a estabilidade e o alcance da internet'),
    ('seed_ia_facil_v1', 'Para que pode ser usada uma IA generativa?', 2, 'Para consertar aparelhos eletrônicos que estão estragados', 'Para consertar aparelhos, cabos ou peças eletrônicas estragadas'),
    ('seed_ia_medio_v3', 'Por que a explicabilidade pode ser importante em sistemas de IA usados em decisões sensíveis?', 1, 'Pode acelerar as decisões do sistema e reduzir os dados de que ele precisa para funcionar', 'Pode acelerar as decisões, reduzir os dados necessários e simplificar o sistema'),
    ('seed_ia_medio_v3', 'Por que a explicabilidade pode ser importante em sistemas de IA usados em decisões sensíveis?', 2, 'Pode reduzir o tempo de treinamento e o custo de guardar os dados usados nele', 'Pode reduzir o tempo de treinamento, o custo de armazenamento e o consumo de energia'),
    ('seed_ia_medio_v3', 'Qual é a principal diferença entre um sistema baseado em regras e um sistema de aprendizado de máquina?', 0, 'O sistema baseado em regras aprende sozinho com os dados, enquanto o de aprendizado de máquina segue regras escritas pelo programador', 'O sistema baseado em regras pode aprender sozinho com os dados, enquanto o de aprendizado de máquina segue regras escritas pelo programador'),
    ('seed_ia_medio_v3', 'Qual é a principal diferença entre um sistema baseado em regras e um sistema de aprendizado de máquina?', 1, 'O sistema baseado em regras exige muitos dados de treinamento, enquanto o aprendizado de máquina funciona com regras fixas', 'O sistema baseado em regras costuma exigir muitos dados de treinamento, enquanto o aprendizado de máquina funciona com regras fixas'),
    ('seed_ia_medio_v1', 'Qual característica tende a melhorar um prompt?', 1, 'Pedido curto, com poucas palavras e sem indicar o formato esperado', 'Frases curtas, com poucas palavras e sem indicar o formato esperado'),
    ('seed_ia_medio_v1', 'Qual característica tende a melhorar um prompt?', 2, 'Pedido genérico, que deixa o modelo escolher livremente o objetivo', 'Linguagem genérica, que deixa o modelo escolher livremente o objetivo'),
    ('seed_ia_medio_v3', 'Se a taxa de aprendizagem for excessivamente alta, qual problema pode ocorrer?', 0, 'O treinamento fica muito lento e o modelo quase não ajusta os pesos', 'O treinamento pode ficar muito lento e o modelo quase não ajusta os pesos'),
    ('seed_ia_medio_v1', 'O que é um dataset?', 0, 'Programa que executa os cálculos usados para treinar e avaliar um modelo', 'Programa que executa os cálculos, treina e avalia os modelos'),
    ('seed_ia_medio_v1', 'O que é um dataset?', 2, 'Equipamento físico onde os dados são armazenados e processados durante o treinamento', 'Equipamento físico, usado para armazenar e processar dados no treinamento'),
    ('seed_ia_facil_v4', 'Qual é uma limitação importante dos sistemas de IA?', 1, 'Exigem computadores muito antigos para funcionar', 'Podem exigir computadores muito antigos para funcionar'),
    ('seed_ia_medio_v3', 'O que é inferência em inteligência artificial?', 0, 'Processo de ajustar os pesos de um modelo com dados já conhecidos e rotulados', 'Ajuste dos pesos de um modelo com dados já conhecidos e rotulados'),
    ('seed_ia_medio_v3', 'O que é inferência em inteligência artificial?', 1, 'Processo de avaliar o modelo comparando previsões com respostas conhecidas de teste', 'Avaliação do modelo comparando previsões com respostas conhecidas de teste'),
    ('seed_ia_facil_v7', 'O que é um filtro de spam baseado em IA?', 0, 'Um programa que analisa os ficheiros do computador e apaga os vírus encontrados no disco', 'Programa que analisa os ficheiros do computador e apaga os vírus encontrados no disco'),
    ('seed_ia_facil_v7', 'O que é um filtro de spam baseado em IA?', 3, 'Um equipamento ligado à rede que aumenta a velocidade da internet na casa ou no escritório', 'Equipamento ligado à rede que aumenta a velocidade da internet na casa ou no escritório'),
    ('seed_ia_facil_v3', 'Qual é uma limitação comum dos sistemas de IA?', 0, 'Precisam de modelos novos a cada resposta', 'Podem precisar de modelos novos a cada resposta'),
    ('seed_ia_medio_v1', 'O que é limpeza de dados?', 0, 'Processo de recolher dados de várias fontes e reuni-los numa única tabela organizada para análise', 'Processo de recolher dados de várias fontes, reuni-los numa tabela e prepará-los para análise'),
    ('seed_ia_medio_v1', 'O que é limpeza de dados?', 1, 'Processo de apagar os dados mais antigos do sistema para libertar espaço de armazenamento', 'Processo de apagar os dados mais antigos, para libertar espaço de armazenamento'),
    ('seed_ia_medio_v1', 'Por que código gerado por IA deve ser revisado?', 0, 'Pode deixar de funcionar quando o computador é reiniciado', 'Pode deixar de funcionar, perder dados ou travar quando o computador reinicia'),
    ('seed_ia_medio_v1', 'Por que código gerado por IA deve ser revisado?', 3, 'Pode ocupar demasiado espaço de armazenamento no sistema', 'Pode ocupar demasiado espaço, memória ou tempo de processamento'),
    ('seed_ia_medio_v1', 'O que é overfitting?', 2, 'Quando um modelo é treinado com demasiados dados e por isso demora muito tempo a responder', 'Quando um modelo é treinado com demasiados dados e por isso pode demorar muito tempo a responder'),
    ('seed_ia_facil_v3', 'Por que a supervisão humana pode ser importante?', 1, 'Porque a IA ainda não consegue executar tarefas simples', 'Porque a IA, hoje, não executa tarefas simples'),
    ('seed_ia_facil_v3', 'Por que a supervisão humana pode ser importante?', 2, 'Para reduzir o uso de automação nas tarefas do dia a dia', 'Para reduzir a automação, mesmo nas tarefas diárias'),
    ('seed_ia_medio_v1', 'Por que fornecer contexto adequado a uma IA pode melhorar a resposta?', 0, 'Reduz o tamanho do modelo e acelera o processamento de cada resposta', 'Reduz o tamanho do modelo, acelerando o processamento de cada resposta'),
    ('seed_ia_medio_v1', 'Por que fornecer contexto adequado a uma IA pode melhorar a resposta?', 2, 'Permite ao modelo guardar a conversa para outras utilizações futuras', 'Permite ao modelo guardar a conversa, para outras utilizações futuras'),
    ('seed_ia_facil_v6', 'O que pode acontecer quando um sistema de IA recebe dados de baixa qualidade?', 2, 'Os erros desaparecem quando o modelo é usado mais vezes', 'Os erros podem desaparecer quando o modelo é usado mais vezes'),
    ('seed_ia_medio_v1', 'Por que a qualidade dos dados é importante?', 0, 'Dados em maior quantidade tornam o modelo mais rápido a responder aos pedidos', 'Dados em maior quantidade podem tornar o modelo mais rápido a responder aos pedidos'),
    ('seed_ia_facil_v2', 'Uma IA pode cometer erros?', 0, 'Depende do tipo de computador', 'Depende do computador'),
    ('seed_ia_facil_v2', 'Uma IA pode cometer erros?', 1, 'Quase nunca erra', 'Quase nunca'),
    ('seed_ia_medio_v1', 'O que é automação inteligente?', 0, 'Uso de máquinas para repetir os mesmos passos de uma tarefa, sem analisar os dados nem decidir', 'Máquinas que repetem os mesmos passos de uma tarefa, sem analisar os dados nem decidir'),
    ('seed_ia_medio_v1', 'O que é automação inteligente?', 2, 'Uso de programas que executam tarefas de acordo com regras fixas e sem aprender com os dados', 'Programas que executam tarefas de acordo com regras fixas e sem aprender com os dados'),
    ('seed_ia_facil_v3', 'Qual é uma forma responsável de começar a utilizar uma ferramenta de IA?', 0, 'Fornecer os dados pessoais logo no primeiro acesso para receber melhores respostas', 'Fornecer os dados pessoais logo no primeiro acesso, para receber melhores respostas'),
    ('seed_ia_facil_v3', 'Qual é uma forma responsável de começar a utilizar uma ferramenta de IA?', 1, 'Aceitar os primeiros resultados sem os comparar com outros', 'Aceitar os primeiros resultados, sem os comparar com outros'),
    ('seed_ia_facil_v4', 'Para que serve o reconhecimento de voz?', 0, 'Criar componentes físicos para o computador a partir de ordens escritas', 'Criar componentes físicos que o computador pode usar a partir de ordens escritas'),
    ('seed_ia_facil_v1', 'A IA consegue sempre fornecer respostas corretas?', 2, 'Sim, em temas simples', 'Sim, em geral'),
    ('seed_ia_facil_v1', 'O que é recomendação baseada em IA?', 0, 'Pedido de produtos feito pelo próprio usuário com base em listas de preços', 'Pedido de produtos, feito pelo próprio usuário com base em listas de preços'),
    ('seed_ia_facil_v1', 'O que é recomendação baseada em IA?', 2, 'Cobrança de valores por serviços usados com base em planos e contratos', 'Cobrança de valores por serviços, planos e contratos usados pelo cliente'),
    ('seed_ia_facil_v1', 'Por que os dados são importantes para muitos sistemas de IA?', 0, 'Permitem que o modelo funcione sem precisar de algoritmos', 'Podem permitir que o modelo funcione, sem precisar de algoritmos'),
    ('seed_ia_facil_v1', 'Por que os dados são importantes para muitos sistemas de IA?', 2, 'Ajudam a escolher o computador mais barato para cada modelo', 'Ajudam a escolher o computador mais barato, para cada modelo'),
    ('seed_ia_medio_v3', 'Por que a tokenização é importante em modelos de linguagem?', 2, 'Aumenta o tamanho dos dados para o modelo ter mais exemplos', 'Pode aumentar o tamanho dos dados para o modelo ter mais exemplos'),
    ('seed_ia_medio_v3', 'O que é engenharia de características (feature engineering)?', 0, 'Processo de escolher e configurar o hardware mais adequado para treinar um modelo', 'Processo de escolher, comprar e configurar o hardware adequado para treinar um modelo'),
    ('seed_ia_medio_v3', 'O que é engenharia de características (feature engineering)?', 1, 'Processo de instalar e configurar os servidores onde um modelo vai funcionar', 'Processo de instalar, ligar e configurar os servidores onde um modelo vai funcionar'),
    ('seed_ia_medio_v3', 'Um modelo apresenta 99% de precisão no treinamento e 65% em dados novos. Qual hipótese deve ser investigada primeiro?', 2, 'Excesso de dados de teste', 'Dados mal rotulados'),
    ('seed_ia_medio_v3', 'Um modelo apresenta 99% de precisão no treinamento e 65% em dados novos. Qual hipótese deve ser investigada primeiro?', 3, 'Falta de armazenamento', 'Pouco armazenamento'),
    ('seed_ia_facil_v4', 'Por que os dados são importantes para muitos sistemas de inteligência artificial?', 0, 'Servem para aumentar a velocidade física do processador durante o uso diário', 'Ajudam a aumentar a velocidade física do processador durante o uso diário'),
    ('seed_ia_facil_v4', 'Por que os dados são importantes para muitos sistemas de inteligência artificial?', 1, 'Servem para guardar o histórico de utilização do aparelho e proteger o sistema', 'Podem guardar o histórico de utilização do aparelho e proteger o sistema'),
    ('seed_ia_medio_v2', 'O que é viés em IA?', 1, 'Falha técnica causada por falta de memória no sistema', 'Falha técnica que pode ser causada por falta de memória no sistema')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Ajuste de alternativas Inteligência Artificial (pistas): % alternativa(s) errada(s) atualizada(s) (esperado: 50).', v_updated;
END $$;
