-- Ajuste de alternativas (BE-003, resíduo de pistas) — Marketing Digital: 41 alternativas erradas reescritas em 18 perguntas que só tinham avisos de pista.
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
    ('seed_marketing_digital_medio_v1', 'O que é funil de vendas?', 0, 'Sistema que registra os pagamentos feitos pelos clientes em cada etapa da compra', 'Sistema que costuma registrar os pagamentos feitos pelos clientes em cada etapa da compra'),
    ('seed_marketing_digital_medio_v1', 'O que é funil de vendas?', 1, 'Banco de dados que armazena o histórico de contatos e compras dos clientes', 'Banco de dados que pode armazenar o histórico de contatos e compras dos clientes'),
    ('seed_marketing_digital_facil_v3', 'O que é conteúdo no Marketing Digital?', 1, 'Material técnico guardado nos servidores da empresa', 'Material técnico, guardado nos servidores da empresa'),
    ('seed_marketing_digital_facil_v3', 'O que é conteúdo no Marketing Digital?', 2, 'Conjunto de códigos de programação usados para construir um site ou aplicativo', 'Conjunto de códigos, usados para construir um site'),
    ('seed_marketing_digital_facil_v3', 'O que é Google?', 1, 'Um antivírus', 'Um programa que protege contra vírus'),
    ('seed_marketing_digital_facil_v3', 'O que é Google?', 2, 'Um componente que faz os cálculos do computador', 'Um componente de cálculo do computador'),
    ('seed_marketing_digital_facil_v3', 'O que é Google?', 3, 'Uma placa que processa as imagens da tela', 'Uma placa de imagens da tela'),
    ('seed_marketing_digital_facil_v3', 'O que é métrica?', 0, 'Código usado pelo usuário para entrar na conta', 'Código usado para entrar na conta'),
    ('seed_marketing_digital_facil_v3', 'O que é métrica?', 2, 'Sistema operacional', 'Sistema que controla o computador'),
    ('seed_marketing_digital_facil_v3', 'O que é métrica?', 3, 'Formato de anúncio usado nas redes sociais', 'Formato de anúncio nas redes'),
    ('seed_marketing_digital_facil_v2', 'O que significa publicar conteúdo regularmente?', 0, 'Publicar conteúdos conforme a vontade de cada dia', 'Postar conforme a vontade de cada dia'),
    ('seed_marketing_digital_facil_v2', 'O que significa publicar conteúdo regularmente?', 1, 'Publicar em dias e horas ao acaso', 'Escolher dias e horas ao acaso'),
    ('seed_marketing_digital_medio_v1', 'O que é prova social?', 0, 'Contrato assinado entre a empresa e os anunciantes para divulgar e vender uma solução ao público', 'Contrato assinado entre a empresa e os anunciantes, para divulgar uma solução'),
    ('seed_marketing_digital_medio_v1', 'O que é prova social?', 2, 'Documento emitido por um banco para comprovar o pagamento de uma solução', 'Documento emitido por um banco, para comprovar o pagamento de uma solução'),
    ('seed_marketing_digital_facil_v2', 'O que é uma descrição de produto?', 0, 'Código interno que identifica o produto no estoque e na loja virtual', 'Código interno, que identifica o produto no estoque e na loja virtual'),
    ('seed_marketing_digital_facil_v2', 'O que é uma descrição de produto?', 3, 'Documento bancário que comprova o pagamento do produto pelo cliente na loja online', 'Documento do banco, que comprova o pagamento do produto pelo cliente'),
    ('seed_marketing_digital_facil_v2', 'Para que serve o perfil de uma empresa em uma rede social?', 1, 'Armazenar os dados bancários da empresa para pagar anúncios e fornecedores', 'Armazenar os dados bancários, para pagar anúncios e fornecedores'),
    ('seed_marketing_digital_facil_v2', 'Para que serve o perfil de uma empresa em uma rede social?', 2, 'Registar oficialmente a empresa junto das autoridades e dos órgãos públicos', 'Registar oficialmente a empresa, junto das autoridades públicas'),
    ('seed_marketing_digital_facil_v3', 'O que é uma persona?', 1, 'Aplicativo de mensagens', 'Aplicativo para enviar mensagens aos clientes'),
    ('seed_marketing_digital_facil_v3', 'O que é uma persona?', 2, 'Computador usado pela equipe para gerir as redes sociais', 'Computador usado para gerir redes sociais'),
    ('seed_marketing_digital_facil_v5', 'Por que uma empresa cria conteúdos na internet?', 0, 'Para diminuir o contato com os clientes da empresa e evitar reclamações', 'Para diminuir o contato com os clientes, evitando reclamações'),
    ('seed_marketing_digital_facil_v5', 'Por que uma empresa cria conteúdos na internet?', 1, 'Para ocupar espaço nos servidores da plataforma', 'Para ocupar espaço nos servidores, sem atrair ninguém'),
    ('seed_marketing_digital_facil_v1', 'Para que serve uma palavra-chave no marketing digital?', 0, 'Ajudar a criar uma conta automaticamente para cada visitante que acessa o site da empresa', 'Ajudar a criar uma conta para cada visitante que pode acessar o site da empresa'),
    ('seed_marketing_digital_facil_v1', 'Para que serve uma palavra-chave no marketing digital?', 2, 'Ajudar a proteger o acesso ao painel de anúncios com uma senha difícil de adivinhar', 'Ajudar a proteger o painel de anúncios, que pode ter uma senha difícil de adivinhar'),
    ('seed_marketing_digital_facil_v1', 'Para que serve uma palavra-chave no marketing digital?', 3, 'Ajudar a substituir o endereço do site por um nome mais curto e fácil de lembrar', 'Ajudar a trocar o endereço do site por um nome que pode ser mais curto e fácil de lembrar'),
    ('seed_marketing_digital_facil_v3', 'O que é um blog?', 0, 'Componente que executa as tarefas do computador', 'Componente que executa as tarefas'),
    ('seed_marketing_digital_facil_v3', 'O que é um blog?', 2, 'Antivírus', 'Programa de proteção antivírus'),
    ('seed_marketing_digital_facil_v3', 'O que é um blog?', 3, 'Sistema operacional', 'Sistema operacional do computador'),
    ('seed_marketing_digital_medio_v1', 'Uma publicação viral garante lucro?', 0, 'Sim, quando alcança muitas visualizações e curtidas', 'Quase sempre'),
    ('seed_marketing_digital_medio_v1', 'Uma publicação viral garante lucro?', 3, 'Sim, se for compartilhado em vários canais', 'Em geral sim'),
    ('seed_marketing_digital_facil_v1', 'O que é tráfego em marketing digital?', 1, 'Fluxo de veículos que passam diante da loja física da empresa', 'Fluxo de veículos, que passam diante da loja física'),
    ('seed_marketing_digital_facil_v1', 'O que é tráfego em marketing digital?', 3, 'Quantidade de produtos disponíveis para venda em uma loja virtual', 'Quantidade de produtos, disponíveis para venda numa loja virtual'),
    ('seed_marketing_digital_facil_v3', 'O que é uma plataforma digital?', 0, 'Equipamento físico que liga os computadores à rede', 'Equipamento físico que liga os computadores à rede local'),
    ('seed_marketing_digital_facil_v3', 'O que é uma plataforma digital?', 1, 'Componente interno do computador', 'Componente interno de um computador pessoal ou portátil'),
    ('seed_marketing_digital_facil_v3', 'O que é uma plataforma digital?', 3, 'Peça que executa os cálculos e as tarefas do computador', 'Peça que executa cálculos e tarefas do computador'),
    ('seed_marketing_digital_facil_v1', 'O que é email marketing?', 0, 'Sistema usado para registar pagamentos e faturas dos clientes', 'Sistema usado para registar pagamentos, faturas e recibos dos clientes'),
    ('seed_marketing_digital_facil_v1', 'O que é email marketing?', 1, 'Troca de mensagens pessoais entre os funcionários de uma mesma empresa', 'Troca de mensagens pessoais, entre funcionários de uma mesma empresa'),
    ('seed_marketing_digital_facil_v3', 'Qual é o principal objetivo do Marketing Digital?', 0, 'Criar imagens bonitas para publicar nas redes sociais', 'Criar imagens, vídeos e textos para as redes'),
    ('seed_marketing_digital_facil_v3', 'Qual é o principal objetivo do Marketing Digital?', 1, 'Desligar os anúncios online para reduzir os custos', 'Reduzir custos, desligando os anúncios online'),
    ('seed_marketing_digital_facil_v5', 'O que é uma marca no Marketing Digital?', 0, 'Tipo de computador usado nas empresas de tecnologia', 'Tipo de computador, usado em empresas de tecnologia'),
    ('seed_marketing_digital_facil_v5', 'O que é uma marca no Marketing Digital?', 2, 'Método de pagamento aceito nas lojas online', 'Método de pagamento, aceito em lojas online')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Ajuste de alternativas Marketing Digital (pistas): % alternativa(s) errada(s) atualizada(s) (esperado: 41).', v_updated;
END $$;
