-- Migration 029: Pontos por dificuldade de Quiz (docx "Aprenda-e-Ganhe-Documentao-
-- Oficial(1)", Seção 5.9-B — "DETALHAMENTO CONCRETO — Sistema de Pontos + Missões").
--
-- Até aqui, `quizService.submitAnswer` chamava `xpService.addXpAndPoints` com
-- `pointsDelta: 0` FIXO NO CÓDIGO — ou seja, responder quiz corretamente dava
-- XP, mas NUNCA dava Pontos. Isso é uma lacuna maior do que parece: o Quiz é
-- "o coração do sistema" (Doc. Mestre Seção 19.4) e é a atividade mais
-- frequente da plataforma, mas não alimentava a economia de Pontos em nada —
-- só Missões, Streak e Indicações geravam Pontos. Sem o Quiz gerando Pontos,
-- a Loja e a conversão Pontos->Dinheiro (migration 028) ficam praticamente
-- inacessíveis para quem só joga quiz e não faz missão.
--
-- O documento já tinha o exemplo concreto, nunca implementado:
--   "Quiz fácil: +10 pontos | Quiz médio: +25 pontos | Quiz difícil: +50 pontos"
-- Esta migration ativa exatamente essa tabela, usando a coluna `difficulty`
-- que já existe em `questions` (migration 005) — sem precisar de coluna nova
-- nem de o admin recadastrar pontuação pergunta por pergunta.
--
-- NÃO implementado aqui (falta valor de exemplo concreto na documentação, e
-- o Manual do Desenvolvedor proíbe inventar regra de negócio sem aprovação):
-- o "bônus de pontos por sequência de acertos" citado na mesma seção, sem
-- fórmula ou valor definido. Fica registrado como pendência, não como “feito”.

INSERT INTO system_config (key, value, description) VALUES
    ('quiz_points_reward_easy', '10',
     'Pontos concedidos por acertar uma pergunta de dificuldade "easy" (docx Seção 5.9-B).'),
    ('quiz_points_reward_medium', '25',
     'Pontos concedidos por acertar uma pergunta de dificuldade "medium" (docx Seção 5.9-B).'),
    ('quiz_points_reward_hard', '50',
     'Pontos concedidos por acertar uma pergunta de dificuldade "hard" (docx Seção 5.9-B).')
ON CONFLICT (key) DO NOTHING;

-- Simétrico à coluna xp_awarded já existente (migration 005) — histórico
-- completo por tentativa (Manual Parte 4: "toda tabela financeira/de Pontos
-- deve manter histórico completo de alterações"). O valor definitivo (já
-- líquido de teto diário/boost) também fica registrado no livro-razão
-- (points_ledger, source = 'quiz_correct_answer'); esta coluna é o espelho
-- rápido no histórico de tentativas, sem precisar de JOIN.
ALTER TABLE quiz_attempts ADD COLUMN IF NOT EXISTS points_awarded INTEGER NOT NULL DEFAULT 0;
