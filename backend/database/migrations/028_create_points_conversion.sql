-- Migration 028: Conversão de Pontos em Dinheiro Real (MZN)
-- Referência: "Aprenda-e-Ganhe-Documentao-Oficial" (Seção 5.9-B) e
-- "aprenda-e-ganhe-documentacao.pdf" (Seção 6.1) — a taxa de conversão só
-- existia como EXEMPLO em conversa ("1.000 pontos = 10 Mts... os valores
-- precisam ser calculados conforme a receita de anúncios e custos reais da
-- plataforma — ainda não são valores finais"). Não havia nenhuma tabela,
-- rota ou serviço que efetivamente convertesse Pontos em MZN.
--
-- Esta migration ativa a conversão de fato, usando exatamente a taxa do
-- exemplo já documentado como o valor vigente. Fica em `system_config` (não
-- fixo no código) para poder ser recalibrada sem deploy assim que a planilha
-- de sustentabilidade financeira (receita de anúncios vs. custo de
-- recompensas) for formalizada pelo proprietário do projeto.
--
-- >>> DECISÃO REGISTRADA (resolve conflito entre documentos oficiais) <<<
-- O documento "SISTEMA DE ECONOMIA E RECOMPENSAS" (recebido depois desta
-- migration) afirma textualmente: "Moedas virtuais NÃO podem ser sacadas.
-- Moedas virtuais NÃO possuem valor financeiro direto." — o que contradiz
-- diretamente esta conversão Pontos -> MZN.
-- Apresentado o conflito ao proprietário do projeto, a decisão explícita
-- foi: MANTER a conversão como está, avaliando o resultado na prática antes
-- de decidir remover. Ou seja, para este projeto, "Pontos" NÃO segue a
-- restrição de "Moedas Virtuais" descrita naquele documento — é tratado como
-- uma moeda intermediária conversível, por decisão consciente, não por
-- descuido. Qualquer sessão futura (humana ou IA) que reencontrar essa
-- aparente contradição deve considerá-la resolvida por esta nota, não
-- reabrir a discussão sem um pedido explícito do proprietário do projeto.

INSERT INTO system_config (key, value, description) VALUES
    ('points_conversion_rate_points', '1000',
     'Quantos Pontos equivalem a `points_conversion_rate_mzn` MZN na conversão Pontos -> Dinheiro. Conversões só são aceitas em múltiplos exatos deste valor (mesma lógica do exemplo documentado: 1.000 e 10.000 pontos).'),
    ('points_conversion_rate_mzn', '10.00',
     'Quantos MZN o usuário recebe a cada `points_conversion_rate_points` Pontos convertidos.'),
    ('min_trust_score_for_conversion', '60',
     'Trust Score mínimo exigido para converter Pontos em dinheiro real (mesmo racional do saque - Manual Parte 7: "limites de conversão devem respeitar o Trust Score").')
ON CONFLICT (key) DO NOTHING;

-- Converter Pontos em dinheiro é, na prática, outra forma de "ganhar dinheiro
-- real" — por isso conta para o mesmo teto de GANHO diário já aplicado a
-- missões e marcos de streak (Doc. Mestre Seção 16.3). Sem isso seria
-- possível contornar o teto simplesmente acumulando Pontos e convertendo
-- tudo de uma vez. Ver backend/src/modules/wallet/repositories/walletRepository.js
-- (sumEarningsToday agora também soma source = 'points_conversion').

-- CORREÇÃO DE REGRESSÃO: a migration 027 recriou esta constraint e, ao
-- listar os tipos manualmente, esqueceu 'withdrawal_sla_risk' (criado na
-- migration 018 para o alerta de saque pendente há mais de 24h — ver
-- notifyAdminsWithdrawalSlaRisk). Desde a 027, qualquer tentativa de gravar
-- esse tipo passou a falhar contra a constraint. Restaurado abaixo, junto
-- com o novo tipo 'points_converted' desta migration.
ALTER TABLE notifications DROP CONSTRAINT IF EXISTS notifications_type_check;

ALTER TABLE notifications
    ADD CONSTRAINT notifications_type_check
        CHECK (type IN (
            'streak_at_risk', 'mission_completed', 'milestone_reached',
            'withdrawal_status', 'weekly_ranking', 'system',
            'withdrawal_requested', 'withdrawal_new_admin', 'withdrawal_sla_risk',
            'daily_earning_cap_reached', 'points_converted'
        ));
