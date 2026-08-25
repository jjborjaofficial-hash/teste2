-- Migration 021: Categorias Oficiais da Plataforma
-- Referência: Doc. Mestre Seção 5 — "categorias: Finanças, Tecnologia,
-- Inteligência Artificial, Marketing Digital e Produtividade".
--
-- Antes desta migration, as categorias só existiam em
-- database/seeds/001_sample_content.sql — um seed de DESENVOLVIMENTO que
-- precisa ser rodado manualmente e não faz parte do pipeline de migrations.
-- Isso significa que um banco de produção criado do zero (`npm run migrate:up`)
-- subiria sem NENHUMA categoria — o Hub de Estudos ficaria vazio.
--
-- Esta migration garante as 5 categorias oficiais em qualquer ambiente,
-- sempre. As perguntas de cada categoria continuam sendo conteúdo editorial
-- (não faz sentido "hardcodar" perguntas em uma migration) — para isso,
-- existe agora o Painel Administrativo de Categorias e Perguntas.

INSERT INTO categories (name, slug, description, icon_key) VALUES
    ('Finanças', 'financas', 'Educação financeira básica e avançada', 'wallet'),
    ('Tecnologia', 'tecnologia', 'Conceitos gerais de tecnologia', 'quiz'),
    ('Inteligência Artificial', 'inteligencia-artificial', 'Fundamentos de Inteligência Artificial', 'quiz'),
    ('Marketing Digital', 'marketing-digital', 'Estratégias e conceitos de marketing digital', 'quiz'),
    ('Produtividade', 'produtividade', 'Hábitos e ferramentas de produtividade pessoal', 'quiz')
ON CONFLICT (slug) DO NOTHING;
