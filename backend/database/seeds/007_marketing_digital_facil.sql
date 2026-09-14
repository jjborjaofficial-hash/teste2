-- Migration/seed: conteúdo Marketing Digital, nível Fácil (25 perguntas)
-- Fonte: lote de 80 perguntas de Marketing Digital fornecido pelo proprietário
-- do projeto (perguntas 1–25 do lote, marcadas como "Fácil"). O lote completo
-- também contém as perguntas de nível Médio (007) e Difícil (008), separadas
-- em arquivos próprios seguindo o mesmo padrão usado para Tecnologia
-- (um arquivo por categoria + dificuldade).
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes de
-- Tecnologia, não é decisão de negócio): no lote original, as respostas
-- corretas eram TODAS a alternativa "A" — decorável sem conhecimento real.
-- A posição da alternativa correta foi redistribuída por pergunta com seed
-- fixa (46 — distinta das seeds 42/43/44/45 já usadas) e distribuição
-- controlada entre A/B/C/D, reprodutível — o conteúdo pedagógico permanece
-- exatamente como enviado, só a ORDEM de exibição mudou.
--
-- Categoria "Marketing Digital" (slug: marketing-digital) já existe desde a
-- migration 021 — esta é a primeira leva de perguntas para ela.
--
-- Idempotente: usa a coluna `source` (migration 022) como marcador — rodar
-- este arquivo mais de uma vez não duplica as perguntas.
--
-- CORREÇÃO DE DUPLICATA CRUZADA (rodada de consolidação): 1 pergunta deste
-- arquivo ("O que é uma rede social?") tinha o MESMO enunciado de uma
-- pergunta já existente em 003_tecnologia_facil.sql. Removida daqui.

BEGIN;

DO $$
DECLARE
  v_category_id UUID;
BEGIN
  SELECT id INTO v_category_id FROM categories WHERE slug = 'marketing-digital';
  IF v_category_id IS NULL THEN
    RAISE EXCEPTION 'Categoria "marketing-digital" não encontrada — rode a migration 021 primeiro.';
  END IF;

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_marketing_digital_facil_v1') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_marketing_digital_facil_v1) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_mkt_facil AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'easy', v.statement, 15, 10, 'seed_marketing_digital_facil_v1'
    FROM (VALUES
      ('O que é marketing digital?'),
      ('O que é público-alvo?'),
      ('O que é uma marca?'),
      ('O que é conteúdo digital?'),
      ('Qual destes é um exemplo de conteúdo digital?'),
      ('O que é uma publicação nas redes sociais?'),
      ('O que significa engajamento nas redes sociais?'),
      ('O que é seguidor?'),
      ('O que é alcance?'),
      ('O que são impressões?'),
      ('O que é um anúncio digital?'),
      ('O que é uma chamada para ação?'),
      ('Qual destas é uma chamada para ação?'),
      ('O que é uma landing page?'),
      ('O que é tráfego em marketing digital?'),
      ('O que é tráfego orgânico?'),
      ('O que é tráfego pago?'),
      ('O que é SEO?'),
      ('Para que serve uma palavra-chave no marketing digital?'),
      ('O que é email marketing?'),
      ('O que é uma lista de contatos?'),
      ('O que é conteúdo educativo no marketing?'),
      ('Qual pode ser uma vantagem de produzir conteúdo educativo?'),
      ('O que é consistência no marketing de conteúdo?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_mkt_facil q
    JOIN (VALUES
      ('O que é marketing digital?', 'Uso de canais e ferramentas digitais para promover produtos, serviços ou marcas', TRUE, 0),
      ('O que é marketing digital?', 'Apenas publicidade na televisão', FALSE, 1),
      ('O que é marketing digital?', 'Apenas distribuição de panfletos', FALSE, 2),
      ('O que é marketing digital?', 'Apenas vendas presenciais', FALSE, 3),
      ('O que é público-alvo?', 'Todas as pessoas do mundo', FALSE, 0),
      ('O que é público-alvo?', 'Apenas concorrentes', FALSE, 1),
      ('O que é público-alvo?', 'Grupo de pessoas que uma empresa pretende alcançar com uma oferta ou comunicação', TRUE, 2),
      ('O que é público-alvo?', 'Apenas funcionários da empresa', FALSE, 3),
      ('O que é uma marca?', 'Um tipo de anúncio', FALSE, 0),
      ('O que é uma marca?', 'Apenas o preço de um produto', FALSE, 1),
      ('O que é uma marca?', 'Identidade que diferencia uma empresa, produto ou serviço na percepção do público', TRUE, 2),
      ('O que é uma marca?', 'Apenas um endereço de email', FALSE, 3),
      ('O que é conteúdo digital?', 'Material produzido e distribuído em meios digitais', TRUE, 0),
      ('O que é conteúdo digital?', 'Apenas produtos físicos', FALSE, 1),
      ('O que é conteúdo digital?', 'Apenas documentos impressos', FALSE, 2),
      ('O que é conteúdo digital?', 'Apenas anúncios de televisão', FALSE, 3),
      ('Qual destes é um exemplo de conteúdo digital?', 'Outdoor físico', FALSE, 0),
      ('Qual destes é um exemplo de conteúdo digital?', 'Vídeo publicado em uma rede social', TRUE, 1),
      ('Qual destes é um exemplo de conteúdo digital?', 'Cartaz colocado numa parede', FALSE, 2),
      ('Qual destes é um exemplo de conteúdo digital?', 'Folheto impresso', FALSE, 3),
      ('O que é uma publicação nas redes sociais?', 'Apenas uma venda', FALSE, 0),
      ('O que é uma publicação nas redes sociais?', 'Um contrato', FALSE, 1),
      ('O que é uma publicação nas redes sociais?', 'Uma senha', FALSE, 2),
      ('O que é uma publicação nas redes sociais?', 'Conteúdo compartilhado em uma plataforma social', TRUE, 3),
      ('O que significa engajamento nas redes sociais?', 'Apenas número de anúncios', FALSE, 0),
      ('O que significa engajamento nas redes sociais?', 'Apenas número de vendas', FALSE, 1),
      ('O que significa engajamento nas redes sociais?', 'Interações do público com determinado conteúdo, como curtidas, comentários, compartilhamentos ou salvamentos', TRUE, 2),
      ('O que significa engajamento nas redes sociais?', 'Apenas número de seguidores', FALSE, 3),
      ('O que é seguidor?', 'Funcionário da empresa', FALSE, 0),
      ('O que é seguidor?', 'Concorrente direto', FALSE, 1),
      ('O que é seguidor?', 'Cliente obrigatoriamente pagante', FALSE, 2),
      ('O que é seguidor?', 'Usuário que acompanha uma conta ou perfil em uma plataforma social', TRUE, 3),
      ('O que é alcance?', 'Número de funcionários', FALSE, 0),
      ('O que é alcance?', 'Quantidade de pessoas ou contas que foram expostas a determinado conteúdo', TRUE, 1),
      ('O que é alcance?', 'Valor gasto em publicidade', FALSE, 2),
      ('O que é alcance?', 'Quantidade de produtos vendidos', FALSE, 3),
      ('O que são impressões?', 'Número de pessoas que compraram', FALSE, 0),
      ('O que são impressões?', 'Número de comentários obrigatórios', FALSE, 1),
      ('O que são impressões?', 'Número de vezes que determinado conteúdo ou anúncio foi exibido', TRUE, 2),
      ('O que são impressões?', 'Número de seguidores perdidos', FALSE, 3),
      ('O que é um anúncio digital?', 'Contrato comercial', FALSE, 0),
      ('O que é um anúncio digital?', 'Mensagem promocional distribuída por meio de canais digitais', TRUE, 1),
      ('O que é um anúncio digital?', 'Documento bancário', FALSE, 2),
      ('O que é um anúncio digital?', 'Apenas um cartaz físico', FALSE, 3),
      ('O que é uma chamada para ação?', 'Instrução que incentiva o usuário a realizar uma ação', TRUE, 0),
      ('O que é uma chamada para ação?', 'Uma chamada telefônica', FALSE, 1),
      ('O que é uma chamada para ação?', 'Um tipo de pagamento', FALSE, 2),
      ('O que é uma chamada para ação?', 'Uma mensagem de erro', FALSE, 3),
      ('Qual destas é uma chamada para ação?', '"Empresa fundada em 2020"', FALSE, 0),
      ('Qual destas é uma chamada para ação?', '"Nossos horários"', FALSE, 1),
      ('Qual destas é uma chamada para ação?', '"Produto azul"', FALSE, 2),
      ('Qual destas é uma chamada para ação?', '"Compre agora"', TRUE, 3),
      ('O que é uma landing page?', 'Página obrigatória de login', FALSE, 0),
      ('O que é uma landing page?', 'Página exclusivamente para notícias', FALSE, 1),
      ('O que é uma landing page?', 'Página sem qualquer objetivo', FALSE, 2),
      ('O que é uma landing page?', 'Página criada com um objetivo específico, como captar contatos ou gerar uma ação', TRUE, 3),
      ('O que é tráfego em marketing digital?', 'Visitas ou acessos recebidos por um site, página ou canal digital', TRUE, 0),
      ('O que é tráfego em marketing digital?', 'Apenas trânsito de carros', FALSE, 1),
      ('O que é tráfego em marketing digital?', 'Apenas número de funcionários', FALSE, 2),
      ('O que é tráfego em marketing digital?', 'Apenas quantidade de produtos', FALSE, 3),
      ('O que é tráfego orgânico?', 'Visitas geradas por bots', FALSE, 0),
      ('O que é tráfego orgânico?', 'Visitas feitas apenas por funcionários', FALSE, 1),
      ('O que é tráfego orgânico?', 'Visitas compradas obrigatoriamente', FALSE, 2),
      ('O que é tráfego orgânico?', 'Visitas obtidas sem pagamento direto por cada acesso publicitário', TRUE, 3),
      ('O que é tráfego pago?', 'Visitas obtidas por meio de campanhas publicitárias pagas', TRUE, 0),
      ('O que é tráfego pago?', 'Visitas sem internet', FALSE, 1),
      ('O que é tráfego pago?', 'Visitas de funcionários', FALSE, 2),
      ('O que é tráfego pago?', 'Visitas exclusivamente gratuitas', FALSE, 3),
      ('O que é SEO?', 'Plataforma de mensagens', FALSE, 0),
      ('O que é SEO?', 'Sistema de pagamento', FALSE, 1),
      ('O que é SEO?', 'Conjunto de práticas para melhorar a visibilidade de páginas nos resultados de mecanismos de busca', TRUE, 2),
      ('O que é SEO?', 'Tipo de banco de dados', FALSE, 3),
      ('Para que serve uma palavra-chave no marketing digital?', 'Criar uma conta automaticamente', FALSE, 0),
      ('Para que serve uma palavra-chave no marketing digital?', 'Ajudar a representar termos que usuários podem pesquisar e orientar conteúdos ou campanhas', TRUE, 1),
      ('Para que serve uma palavra-chave no marketing digital?', 'Servir como senha bancária', FALSE, 2),
      ('Para que serve uma palavra-chave no marketing digital?', 'Substituir o domínio', FALSE, 3),
      ('O que é email marketing?', 'Sistema de pagamentos', FALSE, 0),
      ('O que é email marketing?', 'Envio de mensagens exclusivamente pessoais', FALSE, 1),
      ('O que é email marketing?', 'Serviço de armazenamento', FALSE, 2),
      ('O que é email marketing?', 'Uso de emails para comunicação, relacionamento ou promoção junto a contatos', TRUE, 3),
      ('O que é uma lista de contatos?', 'Lista de senhas', FALSE, 0),
      ('O que é uma lista de contatos?', 'Lista de funcionários públicos', FALSE, 1),
      ('O que é uma lista de contatos?', 'Conjunto organizado de pessoas ou endereços utilizados para comunicação', TRUE, 2),
      ('O que é uma lista de contatos?', 'Lista de produtos físicos', FALSE, 3),
      ('O que é conteúdo educativo no marketing?', 'Conteúdo criado para ensinar ou informar o público sobre determinado assunto', TRUE, 0),
      ('O que é conteúdo educativo no marketing?', 'Apenas anúncios pagos', FALSE, 1),
      ('O que é conteúdo educativo no marketing?', 'Conteúdo sem finalidade', FALSE, 2),
      ('O que é conteúdo educativo no marketing?', 'Conteúdo exclusivamente promocional', FALSE, 3),
      ('Qual pode ser uma vantagem de produzir conteúdo educativo?', 'Eliminar concorrentes', FALSE, 0),
      ('Qual pode ser uma vantagem de produzir conteúdo educativo?', 'Ajudar a construir confiança e autoridade perante o público', TRUE, 1),
      ('Qual pode ser uma vantagem de produzir conteúdo educativo?', 'Garantir milhões de visualizações', FALSE, 2),
      ('Qual pode ser uma vantagem de produzir conteúdo educativo?', 'Garantir vendas imediatas', FALSE, 3),
      ('O que é consistência no marketing de conteúdo?', 'Manter uma frequência e padrão de comunicação relativamente estáveis ao longo do tempo', TRUE, 0),
      ('O que é consistência no marketing de conteúdo?', 'Alterar a marca diariamente', FALSE, 1),
      ('O que é consistência no marketing de conteúdo?', 'Publicar apenas uma vez', FALSE, 2),
      ('O que é consistência no marketing de conteúdo?', 'Copiar todos os concorrentes', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_mkt_facil;

    RAISE NOTICE '24 perguntas inseridas com sucesso (source=seed_marketing_digital_facil_v1).';
  END IF;
END $$;

COMMIT;
