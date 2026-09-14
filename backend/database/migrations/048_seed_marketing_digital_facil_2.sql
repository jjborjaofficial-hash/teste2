-- Migration/seed: conteúdo Marketing Digital, nível Fácil (26 perguntas)
-- Fonte: novo lote de perguntas fornecido pelo proprietário do projeto,
-- filtrado para conter apenas perguntas que ainda não existiam no banco
-- (comparação por texto normalizado contra todos os seeds já aplicados) —
-- 26 perguntas novas restantes deste lote para esta categoria+dificuldade
-- depois da deduplicação.
--
-- CORREÇÃO DE QUALIDADE APLICADA (mesma higiene de dado dos lotes
-- anteriores, não é decisão de negócio): no lote original, a esmagadora
-- maioria das respostas corretas era a alternativa "A" — decorável sem
-- conhecimento real. A posição da alternativa correta foi redistribuída
-- por pergunta com seed fixa (57 — distinta das seeds 42 a
-- 56 já usadas nos seeds anteriores) e distribuição
-- controlada entre A/B/C/D, reprodutível — o conteúdo pedagógico
-- permanece exatamente como enviado, só a ORDEM de exibição mudou.
--
-- Categoria "Marketing Digital" (slug: marketing-digital) já existe desde a
-- migration 021.
--
-- Idempotente: usa a coluna `source` (migration 022) como marcador — rodar
-- este arquivo mais de uma vez não duplica as perguntas.

BEGIN;

DO $$
DECLARE
  v_category_id UUID;
BEGIN
  SELECT id INTO v_category_id FROM categories WHERE slug = 'marketing-digital';
  IF v_category_id IS NULL THEN
    RAISE EXCEPTION 'Categoria "marketing-digital" não encontrada — rode a migration 021 primeiro.';
  END IF;

  IF EXISTS (SELECT 1 FROM questions WHERE source = 'seed_marketing_digital_facil_v2') THEN
    RAISE NOTICE 'Perguntas já foram inseridas anteriormente (source=seed_marketing_digital_facil_v2) — nada a fazer.';
  ELSE

    CREATE TEMP TABLE tmp_new_questions_mkt_facil2 AS
    WITH inserted AS (
    INSERT INTO questions (category_id, difficulty, statement, time_limit_seconds, xp_reward, source)
    SELECT v_category_id, 'easy', v.statement, 15, 10, 'seed_marketing_digital_facil_v2'
    FROM (VALUES
      ('Para que serve uma imagem em uma publicação?'),
      ('O que é um seguidor?'),
      ('O que significa publicar conteúdo regularmente?'),
      ('O que é uma hashtag?'),
      ('Para que serve o perfil de uma empresa em uma rede social?'),
      ('O que significa interação nas redes sociais?'),
      ('O que é um comentário?'),
      ('O que significa compartilhar uma publicação?'),
      ('O que é um produto digital?'),
      ('Qual é um exemplo de produto digital?'),
      ('O que significa vender pela internet?'),
      ('O que é uma oferta?'),
      ('O que é desconto?'),
      ('O que é uma descrição de produto?'),
      ('Por que uma descrição clara pode ajudar nas vendas?'),
      ('O que é uma audiência digital?'),
      ('O que significa criar conteúdo?'),
      ('Para que serve uma chamada para ação, conhecida como CTA?'),
      ('Qual destas é uma CTA?'),
      ('O que é conteúdo relevante?'),
      ('Qual métrica mostra quantas vezes um conteúdo foi visualizado?'),
      ('Por que testar diferentes anúncios pode ser útil?'),
      ('O que significa alcance?'),
      ('Qual é uma característica de um bom título?'),
      ('Qual é uma vantagem de analisar dados de uma campanha?'),
      ('Por que conhecer a persona é importante?')
    ) AS v(statement)
    RETURNING id, statement
    )
    SELECT * FROM inserted;

    INSERT INTO question_alternatives (question_id, label, is_correct, display_order)
    SELECT q.id, a.label, a.is_correct, a.display_order
    FROM tmp_new_questions_mkt_facil2 q
    JOIN (VALUES
      ('Para que serve uma imagem em uma publicação?', 'Para substituir obrigatoriamente todo o texto', FALSE, 0),
      ('Para que serve uma imagem em uma publicação?', 'Apenas para aumentar o preço do produto', FALSE, 1),
      ('Para que serve uma imagem em uma publicação?', 'Pode ajudar a chamar atenção e comunicar uma mensagem visualmente', TRUE, 2),
      ('Para que serve uma imagem em uma publicação?', 'Para esconder informações', FALSE, 3),
      ('O que é um seguidor?', 'Cliente que sempre compra', FALSE, 0),
      ('O que é um seguidor?', 'Pessoa ou conta que acompanha determinado perfil ou página', TRUE, 1),
      ('O que é um seguidor?', 'Funcionário obrigatório da empresa', FALSE, 2),
      ('O que é um seguidor?', 'Administrador da internet', FALSE, 3),
      ('O que significa publicar conteúdo regularmente?', 'Publicar apenas quando houver reclamações', FALSE, 0),
      ('O que significa publicar conteúdo regularmente?', 'Nunca publicar', FALSE, 1),
      ('O que significa publicar conteúdo regularmente?', 'Manter uma frequência planejada de publicação', TRUE, 2),
      ('O que significa publicar conteúdo regularmente?', 'Publicar tudo em um único dia', FALSE, 3),
      ('O que é uma hashtag?', 'Palavra ou expressão precedida pelo símbolo # usada para categorizar conteúdo', TRUE, 0),
      ('O que é uma hashtag?', 'Um endereço residencial', FALSE, 1),
      ('O que é uma hashtag?', 'Uma senha bancária', FALSE, 2),
      ('O que é uma hashtag?', 'Um tipo de pagamento', FALSE, 3),
      ('Para que serve o perfil de uma empresa em uma rede social?', 'Apresentar a marca, seus produtos, serviços ou conteúdos ao público', TRUE, 0),
      ('Para que serve o perfil de uma empresa em uma rede social?', 'Guardar dinheiro', FALSE, 1),
      ('Para que serve o perfil de uma empresa em uma rede social?', 'Substituir um banco', FALSE, 2),
      ('Para que serve o perfil de uma empresa em uma rede social?', 'Criar documentos oficiais automaticamente', FALSE, 3),
      ('O que significa interação nas redes sociais?', 'Ações como comentários, curtidas, compartilhamentos ou respostas', TRUE, 0),
      ('O que significa interação nas redes sociais?', 'Pagamento de impostos', FALSE, 1),
      ('O que significa interação nas redes sociais?', 'Apenas visualização de um computador', FALSE, 2),
      ('O que significa interação nas redes sociais?', 'Criação de contas bancárias', FALSE, 3),
      ('O que é um comentário?', 'Um tipo de investimento', FALSE, 0),
      ('O que é um comentário?', 'Um contrato', FALSE, 1),
      ('O que é um comentário?', 'Um anúncio obrigatório', FALSE, 2),
      ('O que é um comentário?', 'Uma manifestação escrita ou reação deixada em um conteúdo', TRUE, 3),
      ('O que significa compartilhar uma publicação?', 'Distribuir aquele conteúdo para outras pessoas ou espaços da plataforma', TRUE, 0),
      ('O que significa compartilhar uma publicação?', 'Bloquear o autor', FALSE, 1),
      ('O que significa compartilhar uma publicação?', 'Apagar a publicação', FALSE, 2),
      ('O que significa compartilhar uma publicação?', 'Alterar o preço do produto', FALSE, 3),
      ('O que é um produto digital?', 'Apenas dinheiro eletrônico', FALSE, 0),
      ('O que é um produto digital?', 'Produto entregue principalmente em formato digital', TRUE, 1),
      ('O que é um produto digital?', 'Produto necessariamente feito de metal', FALSE, 2),
      ('O que é um produto digital?', 'Apenas produto vendido em loja física', FALSE, 3),
      ('Qual é um exemplo de produto digital?', 'E-book', TRUE, 0),
      ('Qual é um exemplo de produto digital?', 'Sapato físico', FALSE, 1),
      ('Qual é um exemplo de produto digital?', 'Cadeira', FALSE, 2),
      ('Qual é um exemplo de produto digital?', 'Mesa', FALSE, 3),
      ('O que significa vender pela internet?', 'Vender somente em mercados físicos', FALSE, 0),
      ('O que significa vender pela internet?', 'Não utilizar comunicação digital', FALSE, 1),
      ('O que significa vender pela internet?', 'Utilizar canais online para apresentar e comercializar produtos ou serviços', TRUE, 2),
      ('O que significa vender pela internet?', 'Fazer pagamentos apenas em dinheiro físico', FALSE, 3),
      ('O que é uma oferta?', 'Um imposto', FALSE, 0),
      ('O que é uma oferta?', 'Proposta apresentada ao consumidor para adquirir um produto ou serviço', TRUE, 1),
      ('O que é uma oferta?', 'Uma senha', FALSE, 2),
      ('O que é uma oferta?', 'Apenas uma reclamação', FALSE, 3),
      ('O que é desconto?', 'Uma multa', FALSE, 0),
      ('O que é desconto?', 'Aumento obrigatório do preço', FALSE, 1),
      ('O que é desconto?', 'Redução aplicada sobre um preço ou valor', TRUE, 2),
      ('O que é desconto?', 'Um empréstimo', FALSE, 3),
      ('O que é uma descrição de produto?', 'Código secreto', FALSE, 0),
      ('O que é uma descrição de produto?', 'Texto que apresenta características, benefícios ou informações sobre o produto', TRUE, 1),
      ('O que é uma descrição de produto?', 'Senha de acesso', FALSE, 2),
      ('O que é uma descrição de produto?', 'Documento bancário', FALSE, 3),
      ('Por que uma descrição clara pode ajudar nas vendas?', 'Porque garante venda automática', FALSE, 0),
      ('Por que uma descrição clara pode ajudar nas vendas?', 'Porque elimina concorrentes', FALSE, 1),
      ('Por que uma descrição clara pode ajudar nas vendas?', 'Porque torna o produto gratuito', FALSE, 2),
      ('Por que uma descrição clara pode ajudar nas vendas?', 'Porque ajuda o potencial cliente a entender o que está sendo oferecido', TRUE, 3),
      ('O que é uma audiência digital?', 'Somente concorrentes', FALSE, 0),
      ('O que é uma audiência digital?', 'Conjunto de pessoas alcançadas ou interessadas em determinado conteúdo, marca ou tema', TRUE, 1),
      ('O que é uma audiência digital?', 'Apenas funcionários', FALSE, 2),
      ('O que é uma audiência digital?', 'Apenas investidores', FALSE, 3),
      ('O que significa criar conteúdo?', 'Apenas comprar anúncios', FALSE, 0),
      ('O que significa criar conteúdo?', 'Produzir materiais como textos, vídeos, imagens, áudios ou outros formatos para um determinado objetivo', TRUE, 1),
      ('O que significa criar conteúdo?', 'Apenas vender produtos', FALSE, 2),
      ('O que significa criar conteúdo?', 'Criar uma conta bancária', FALSE, 3),
      ('Para que serve uma chamada para ação, conhecida como CTA?', 'Diminuir o alcance', FALSE, 0),
      ('Para que serve uma chamada para ação, conhecida como CTA?', 'Esconder informações', FALSE, 1),
      ('Para que serve uma chamada para ação, conhecida como CTA?', 'Apagar comentários', FALSE, 2),
      ('Para que serve uma chamada para ação, conhecida como CTA?', 'Orientar o usuário sobre uma ação desejada', TRUE, 3),
      ('Qual destas é uma CTA?', '"Categoria"', FALSE, 0),
      ('Qual destas é uma CTA?', '"Data de nascimento"', FALSE, 1),
      ('Qual destas é uma CTA?', '"Saiba mais"', TRUE, 2),
      ('Qual destas é uma CTA?', '"Endereço"', FALSE, 3),
      ('O que é conteúdo relevante?', 'Conteúdo relacionado às necessidades e interesses do público', TRUE, 0),
      ('O que é conteúdo relevante?', 'Qualquer publicação aleatória', FALSE, 1),
      ('O que é conteúdo relevante?', 'Conteúdo sem objetivo', FALSE, 2),
      ('O que é conteúdo relevante?', 'Apenas publicidade', FALSE, 3),
      ('Qual métrica mostra quantas vezes um conteúdo foi visualizado?', 'Salário', FALSE, 0),
      ('Qual métrica mostra quantas vezes um conteúdo foi visualizado?', 'Margem', FALSE, 1),
      ('Qual métrica mostra quantas vezes um conteúdo foi visualizado?', 'Estoque', FALSE, 2),
      ('Qual métrica mostra quantas vezes um conteúdo foi visualizado?', 'Visualizações', TRUE, 3),
      ('Por que testar diferentes anúncios pode ser útil?', 'Para descobrir quais versões apresentam melhor desempenho', TRUE, 0),
      ('Por que testar diferentes anúncios pode ser útil?', 'Para impedir vendas', FALSE, 1),
      ('Por que testar diferentes anúncios pode ser útil?', 'Para eliminar métricas', FALSE, 2),
      ('Por que testar diferentes anúncios pode ser útil?', 'Para aumentar custos sem análise', FALSE, 3),
      ('O que significa alcance?', 'Valor de uma campanha', FALSE, 0),
      ('O que significa alcance?', 'Número de funcionários', FALSE, 1),
      ('O que significa alcance?', 'Quantidade de dinheiro recebido', FALSE, 2),
      ('O que significa alcance?', 'Número de pessoas ou contas que foram expostas ao conteúdo', TRUE, 3),
      ('Qual é uma característica de um bom título?', 'Deve esconder o tema', FALSE, 0),
      ('Qual é uma característica de um bom título?', 'Deve ser sempre enorme', FALSE, 1),
      ('Qual é uma característica de um bom título?', 'Deve despertar interesse e comunicar claramente o assunto', TRUE, 2),
      ('Qual é uma característica de um bom título?', 'Não deve ter relação com o conteúdo', FALSE, 3),
      ('Qual é uma vantagem de analisar dados de uma campanha?', 'Garante vendas', FALSE, 0),
      ('Qual é uma vantagem de analisar dados de uma campanha?', 'Impede alterações', FALSE, 1),
      ('Qual é uma vantagem de analisar dados de uma campanha?', 'Elimina a necessidade de planejamento', FALSE, 2),
      ('Qual é uma vantagem de analisar dados de uma campanha?', 'Permite tomar decisões baseadas em resultados', TRUE, 3),
      ('Por que conhecer a persona é importante?', 'Elimina concorrentes', FALSE, 0),
      ('Por que conhecer a persona é importante?', 'Ajuda a produzir comunicação mais adequada ao público', TRUE, 1),
      ('Por que conhecer a persona é importante?', 'Garante lucro', FALSE, 2),
      ('Por que conhecer a persona é importante?', 'Evita criação de conteúdo', FALSE, 3)
    ) AS a(statement, label, is_correct, display_order)
    ON q.statement = a.statement;

    DROP TABLE tmp_new_questions_mkt_facil2;

    RAISE NOTICE '26 perguntas inseridas com sucesso (source=seed_marketing_digital_facil_v2).';
  END IF;
END $$;

COMMIT;
