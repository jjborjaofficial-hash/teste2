-- Alternativas (BE-003, regularização) — Marketing Digital fácil lote 4: as 23 perguntas ativas que faltam (seed v3#28 a v3#34, v4#1 a v4#8, v5#1 a v5#5, v6#1, v6#2 e v7#1), que fecha o fácil.
-- Segue docs/quiz-v2-alternativas-padrao.md: a resposta CERTA não muda; só o texto das alternativas ERRADAS é
-- ajustado para ter tamanho e forma parecidos aos da certa. Marketing Digital usa a faixa de migrations 500+
-- (Finanças 144+, Produtividade 200+, Tecnologia 300+, IA 400+), para não colidir com as outras sessões.
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
    ('seed_marketing_digital_facil_v3', 'O que é uma plataforma digital?', 0, 'Cabo de rede', 'Equipamento físico que liga os computadores à rede'),
    ('seed_marketing_digital_facil_v3', 'O que é uma plataforma digital?', 1, 'Placa de computador', 'Componente interno do computador'),
    ('seed_marketing_digital_facil_v3', 'O que é uma plataforma digital?', 3, 'Processador', 'Peça que executa os cálculos e as tarefas do computador'),
    ('seed_marketing_digital_facil_v3', 'Por que empresas usam Marketing Digital?', 0, 'Para desligar sistemas', 'Para controlar o horário e o ponto dos funcionários'),
    ('seed_marketing_digital_facil_v3', 'Por que empresas usam Marketing Digital?', 2, 'Para substituir internet', 'Para trocar a internet por outros meios de comunicação mais baratos'),
    ('seed_marketing_digital_facil_v3', 'Por que empresas usam Marketing Digital?', 3, 'Para criar vírus', 'Para guardar arquivos e fotos dos funcionários'),
    ('seed_marketing_digital_facil_v3', 'O que é presença digital?', 0, 'Velocidade da rede', 'Qualidade da conexão de internet de uma empresa'),
    ('seed_marketing_digital_facil_v3', 'O que é presença digital?', 1, 'Presença física em loja', 'Presença da marca em lojas e pontos de venda físicos'),
    ('seed_marketing_digital_facil_v3', 'O que é presença digital?', 2, 'Memória do computador', 'Memória do computador usada para guardar os sites'),
    ('seed_marketing_digital_facil_v3', 'O que é conteúdo patrocinado?', 0, 'Arquivo do sistema', 'Arquivo guardado pelo sistema do computador'),
    ('seed_marketing_digital_facil_v3', 'O que é conteúdo patrocinado?', 2, 'Conteúdo apagado', 'Conteúdo apagado pelo autor da página depois de ter sido publicado'),
    ('seed_marketing_digital_facil_v3', 'O que é conteúdo patrocinado?', 3, 'Conteúdo privado', 'Conteúdo privado enviado a contatos próximos'),
    ('seed_marketing_digital_facil_v3', 'O que é uma publicação?', 0, 'Hardware', 'Peça física do computador'),
    ('seed_marketing_digital_facil_v3', 'O que é uma publicação?', 1, 'Programa instalado', 'Programa instalado no computador ou no celular'),
    ('seed_marketing_digital_facil_v3', 'O que é uma publicação?', 2, 'Senha', 'Senha usada para entrar numa plataforma digital'),
    ('seed_marketing_digital_facil_v3', 'O que é algoritmo das redes sociais?', 0, 'Uma senha', 'Uma senha que protege a conta de cada usuário'),
    ('seed_marketing_digital_facil_v3', 'O que é algoritmo das redes sociais?', 1, 'Um computador físico', 'Um computador usado pela equipe da rede social para guardar os dados'),
    ('seed_marketing_digital_facil_v3', 'O que é algoritmo das redes sociais?', 2, 'Um cabo de internet', 'Um cabo que leva a internet até o computador'),
    ('seed_marketing_digital_facil_v3', 'O que é estratégia digital?', 1, 'Troca de peças do computador', 'Troca das peças do computador para melhorar o desempenho'),
    ('seed_marketing_digital_facil_v3', 'O que é estratégia digital?', 2, 'Criação de vírus', 'Criação de programas para atacar sites de concorrentes'),
    ('seed_marketing_digital_facil_v3', 'O que é estratégia digital?', 3, 'Instalação de aplicativos', 'Instalação de aplicativos no celular dos funcionários'),
    ('seed_marketing_digital_facil_v4', 'O que é uma página de captura?', 0, 'Página de configuração do computador', 'Página para configurar o computador e o sistema operacional da empresa'),
    ('seed_marketing_digital_facil_v4', 'O que é uma página de captura?', 1, 'Página sem objetivo definido', 'Página com notícias gerais sobre o setor da empresa'),
    ('seed_marketing_digital_facil_v4', 'O que é uma página de captura?', 3, 'Página usada para apagar dados', 'Página usada para apagar contas e dados dos clientes'),
    ('seed_marketing_digital_facil_v4', 'Qual informação é normalmente solicitada em uma página de captura?', 0, 'Código do computador', 'Código de série do computador'),
    ('seed_marketing_digital_facil_v4', 'Qual informação é normalmente solicitada em uma página de captura?', 1, 'Senha do banco', 'Senha do banco do visitante'),
    ('seed_marketing_digital_facil_v4', 'Qual informação é normalmente solicitada em uma página de captura?', 2, 'Número do processador', 'Modelo do processador'),
    ('seed_marketing_digital_facil_v4', 'O que é uma publicação patrocinada?', 1, 'Arquivo protegido', 'Arquivo protegido por senha e guardado no computador'),
    ('seed_marketing_digital_facil_v4', 'O que é uma publicação patrocinada?', 2, 'Publicação apagada', 'Publicação apagada da página pelo administrador depois de publicada'),
    ('seed_marketing_digital_facil_v4', 'O que é uma publicação patrocinada?', 3, 'Mensagem privada', 'Mensagem privada enviada a um contato da lista'),
    ('seed_marketing_digital_facil_v4', 'O que é uma bio em uma rede social?', 0, 'Programa de edição', 'Programa de edição de fotos e vídeos'),
    ('seed_marketing_digital_facil_v4', 'O que é uma bio em uma rede social?', 1, 'Sistema de pagamento', 'Sistema de pagamento de anúncios'),
    ('seed_marketing_digital_facil_v4', 'O que é uma bio em uma rede social?', 2, 'Banco de dados', 'Banco de dados dos seguidores'),
    ('seed_marketing_digital_facil_v4', 'Por que uma empresa deve responder comentários nas redes sociais?', 0, 'Para bloquear usuários', 'Para impedir que usuários insatisfeitos voltem a comentar'),
    ('seed_marketing_digital_facil_v4', 'Por que uma empresa deve responder comentários nas redes sociais?', 2, 'Para diminuir alcance', 'Para reduzir o alcance das publicações seguintes'),
    ('seed_marketing_digital_facil_v4', 'Por que uma empresa deve responder comentários nas redes sociais?', 3, 'Para apagar seguidores', 'Para remover os seguidores que fazem críticas'),
    ('seed_marketing_digital_facil_v4', 'O que é um nicho de mercado?', 0, 'Todos os usuários da internet', 'Grande parte dos usuários de internet de um país'),
    ('seed_marketing_digital_facil_v4', 'O que é um nicho de mercado?', 1, 'Sistema de anúncios', 'Sistema usado para criar e publicar anúncios online'),
    ('seed_marketing_digital_facil_v4', 'O que é um nicho de mercado?', 3, 'Apenas concorrentes', 'Grupo de empresas que vendem produtos semelhantes'),
    ('seed_marketing_digital_facil_v4', 'O que é uma chamada de atenção em um anúncio?', 0, 'Senha', 'Senha usada para entrar na conta de anúncios'),
    ('seed_marketing_digital_facil_v4', 'O que é uma chamada de atenção em um anúncio?', 2, 'Erro de sistema', 'Erro de sistema que aparece na tela ao publicar o anúncio'),
    ('seed_marketing_digital_facil_v4', 'O que é uma chamada de atenção em um anúncio?', 3, 'Arquivo oculto', 'Arquivo oculto guardado nas pastas do computador'),
    ('seed_marketing_digital_facil_v5', 'O que é uma marca no Marketing Digital?', 0, 'Um tipo de computador', 'Tipo de computador usado nas empresas de tecnologia'),
    ('seed_marketing_digital_facil_v5', 'O que é uma marca no Marketing Digital?', 2, 'Um método de pagamento', 'Método de pagamento aceito nas lojas online'),
    ('seed_marketing_digital_facil_v5', 'O que é uma marca no Marketing Digital?', 3, 'Apenas um anúncio pago', 'Anúncio pago exibido nas redes sociais da empresa'),
    ('seed_marketing_digital_facil_v5', 'Qual é a função de uma rede social para uma empresa?', 1, 'Apenas enviar mensagens privadas', 'Enviar mensagens privadas aos contatos da empresa'),
    ('seed_marketing_digital_facil_v5', 'Qual é a função de uma rede social para uma empresa?', 2, 'Substituir todos os funcionários', 'Substituir os funcionários por atendimento automático'),
    ('seed_marketing_digital_facil_v5', 'Qual é a função de uma rede social para uma empresa?', 3, 'Eliminar clientes', 'Eliminar os clientes que fazem reclamações'),
    ('seed_marketing_digital_facil_v5', 'O que é engajamento nas redes sociais?', 0, 'Número de pagamentos realizados', 'Número de pagamentos recebidos pela loja online'),
    ('seed_marketing_digital_facil_v5', 'O que é engajamento nas redes sociais?', 1, 'Tamanho da empresa', 'Tamanho da equipe que cuida das redes sociais'),
    ('seed_marketing_digital_facil_v5', 'O que é engajamento nas redes sociais?', 2, 'Quantidade de computadores usados', 'Quantidade de computadores usados pela equipe'),
    ('seed_marketing_digital_facil_v5', 'Por que uma empresa cria conteúdos na internet?', 0, 'Para evitar comunicação', 'Para diminuir o contato com os clientes da empresa e evitar reclamações'),
    ('seed_marketing_digital_facil_v5', 'Por que uma empresa cria conteúdos na internet?', 1, 'Apenas para ocupar espaço', 'Para ocupar espaço nos servidores da plataforma'),
    ('seed_marketing_digital_facil_v5', 'Por que uma empresa cria conteúdos na internet?', 3, 'Para eliminar concorrentes automaticamente', 'Para fazer os concorrentes fecharem as contas'),
    ('seed_marketing_digital_facil_v5', 'O que é uma chamada para ação (CTA)?', 1, 'Sistema financeiro', 'Sistema financeiro usado para pagar os anúncios online'),
    ('seed_marketing_digital_facil_v5', 'O que é uma chamada para ação (CTA)?', 2, 'Ferramenta de edição', 'Ferramenta de edição de imagens e vídeos'),
    ('seed_marketing_digital_facil_v5', 'O que é uma chamada para ação (CTA)?', 3, 'Tipo de vírus digital', 'Tipo de vírus que atinge contas de anúncios'),
    ('seed_marketing_digital_facil_v6', 'O que é alcance em uma rede social?', 1, 'Quantidade de dinheiro investido', 'Quantidade de dinheiro investido em anúncios na campanha'),
    ('seed_marketing_digital_facil_v6', 'O que é alcance em uma rede social?', 2, 'Quantidade de produtos vendidos', 'Quantidade de produtos vendidos depois da publicação'),
    ('seed_marketing_digital_facil_v6', 'O que é alcance em uma rede social?', 3, 'Número de funcionários de uma empresa', 'Número de funcionários que cuidam das redes'),
    ('seed_marketing_digital_facil_v6', 'O que é uma campanha de Marketing Digital?', 0, 'Apenas uma publicação aleatória', 'Uma publicação feita ao acaso, sem planejamento nem objetivo definido para a marca'),
    ('seed_marketing_digital_facil_v6', 'O que é uma campanha de Marketing Digital?', 2, 'Uma conta bancária', 'Uma conta bancária usada para pagar os anúncios da marca na internet'),
    ('seed_marketing_digital_facil_v6', 'O que é uma campanha de Marketing Digital?', 3, 'Um programa de computador', 'Um programa de computador usado para publicar conteúdo na internet'),
    ('seed_marketing_digital_facil_v7', 'O que é uma newsletter?', 0, 'Um vírus enviado por e-mail', 'Programa malicioso enviado por e-mail para roubar os dados dos usuários da empresa'),
    ('seed_marketing_digital_facil_v7', 'O que é uma newsletter?', 1, 'Um tipo de anúncio impresso', 'Anúncio impresso distribuído em jornais, revistas e panfletos da região'),
    ('seed_marketing_digital_facil_v7', 'O que é uma newsletter?', 2, 'Um sistema de pagamento bancário', 'Sistema de pagamento bancário usado pelos clientes nas compras online')
  ) AS v(source, statement, display_order, old_label, new_label)
  WHERE q.source = v.source
    AND q.statement = v.statement
    AND a.question_id = q.id
    AND a.display_order = v.display_order
    AND a.is_correct = FALSE
    AND a.label = v.old_label;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Alternativas Marketing Digital fácil lote 4: % alternativa(s) errada(s) atualizada(s) (esperado: 66).', v_updated;
END $$;
