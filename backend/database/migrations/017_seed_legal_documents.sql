-- Migration 017: Seed dos 6 Documentos Jurídicos Oficiais (v1.0)
-- Referência: docx "final jur.. do aprenda e ganhe" + docs/politicas-plataforma-organizadas.md
-- + prints da Central Jurídica (Termos, Privacidade, Cookies, Recompensas, Comunidade, Aviso Legal).
--
-- ⚠️ Mesmo aviso do documento de referência original: este conteúdo NÃO substitui
-- revisão jurídica formal antes de operar com dinheiro real em produção.

INSERT INTO legal_documents (type, title, requires_acceptance, status) VALUES
    ('termos',      'Termos de Uso',              TRUE,  'active'),
    ('privacidade', 'Política de Privacidade',    TRUE,  'active'),
    ('cookies',     'Política de Cookies',        FALSE, 'active'),
    ('recompensas', 'Política de Recompensas',    FALSE, 'active'),
    ('comunidade',  'Política de Comunidade',     FALSE, 'active'),
    ('aviso_legal', 'Aviso Legal (Disclaimer)',   FALSE, 'active')
ON CONFLICT (type) DO NOTHING;

-- ============================================================
-- 1. TERMOS DE USO — v1.0
-- ============================================================
WITH doc AS (SELECT id FROM legal_documents WHERE type = 'termos'),
     v AS (
        INSERT INTO legal_document_versions (document_id, version, content, effective_date, published_at)
        SELECT id, '1.0', $doc$1. Elegibilidade e Cadastro
O usuário deve residir em Moçambique, ser maior de idade conforme a legislação moçambicana e possuir um número de telefone ativo vinculado a uma conta M-Pesa (prefixos 84/85) ou e-Mola (prefixos 86/87). Cada pessoa tem direito a apenas uma conta; um mesmo número de telefone, BI ou CPF não pode estar vinculado a mais de uma conta ativa simultaneamente.

2. Conta Única e Identidade
É estritamente proibida a criação de múltiplas contas pela mesma pessoa. A plataforma pode solicitar verificação adicional de identidade a qualquer momento, especialmente antes da liberação de saques. Contas identificadas como duplicadas podem ser suspensas ou banidas, com retenção de saldo, sem aviso prévio.

3. Uso Aceitável e Antifraude (Tolerância Zero)
É proibido o uso de robôs, scripts, automações ou qualquer ferramenta que burle o sistema de tempo e respostas dos quizzes, bem como o uso de VPNs para mascarar a localização real do usuário. Cada usuário possui um Trust Score (Pontuação de Confiança) que reflete seu histórico de atividade legítima. A plataforma reserva-se o direito de reter o saldo em MZN de contas suspeitas, zerar os Pontos (XP) acumulados de forma fraudulenta e banir permanentemente contas com indícios claros de fraude, sem necessidade de aviso prévio.

4. Natureza das Recompensas
Os ganhos financeiros oferecidos pela plataforma são um incentivo ao estudo e ao hábito diário, e não constituem promessa de salário, renda fixa ou retorno financeiro garantido. As regras matemáticas de recompensa podem ser ajustadas a qualquer momento, visando a sustentabilidade do ecossistema.

5. Nenhum Depósito, Nenhuma Cobrança
O usuário nunca precisa depositar ou transferir dinheiro para o Aprenda e Ganhe. A plataforma nunca cobra nenhum valor monetário de nenhum usuário, em nenhuma circunstância. O único fluxo de dinheiro é da plataforma para o usuário, quando este solicita o saque do que já ganhou estudando.

6. Saques e Pagamentos
O processamento do pagamento não é imediato: passa por uma auditoria do Trust Score antes de ser liberado via M-Pesa ou e-Mola. As regras completas de valor mínimo, prazos e critérios estão descritas na Política de Recompensas.

7. Suspensão e Encerramento de Conta
A plataforma pode suspender ou encerrar contas em caso de fraude, uso de bots, manipulação do sistema, criação de múltiplas contas, violação destes Termos ou abuso de recompensas. O usuário será informado do motivo sempre que possível, e poderá apresentar recurso através da Central de Ajuda.

8. Propriedade Intelectual
O nome "Aprenda e Ganhe", o logotipo, a identidade visual, o código-fonte, o design, os conteúdos educativos e o banco de perguntas são propriedade da plataforma e não podem ser reproduzidos sem autorização.

9. Alterações nos Termos
Estes Termos podem ser atualizados periodicamente. Quando isso acontecer, o usuário precisará revisar e aceitar a nova versão antes de continuar usando a plataforma. O uso continuado após a atualização constitui aceite das novas condições.

10. Resolução de Conflitos e Canais Oficiais
Dúvidas, reclamações e recursos devem ser encaminhados através da Central de Ajuda Jurídica, dentro da plataforma.$doc$, '2026-08-07', now()
        FROM doc
        ON CONFLICT (document_id, version) DO NOTHING
        RETURNING id, document_id
     )
UPDATE legal_documents SET current_version_id = v.id FROM v WHERE legal_documents.id = v.document_id;

-- ============================================================
-- 2. POLÍTICA DE PRIVACIDADE — v1.0
-- ============================================================
WITH doc AS (SELECT id FROM legal_documents WHERE type = 'privacidade'),
     v AS (
        INSERT INTO legal_document_versions (document_id, version, content, effective_date, published_at)
        SELECT id, '1.0', $doc$1. Dados Coletados
Coletamos nome, número de telefone, senha (armazenada com hash, nunca em texto puro), histórico de estudos, dados de sessões de quiz e transações financeiras. Coletamos apenas os dados estritamente necessários ao funcionamento do serviço (princípio da minimização de dados).

2. Finalidade da Coleta e Forma de Utilização
Os dados são usados para operar a plataforma, calcular o Trust Score, prevenir fraudes, processar saques com histórico auditável e personalizar a experiência de aprendizagem.

3. Tempo de Armazenamento
Dados financeiros e de auditoria são mantidos pelo prazo exigido por lei, mesmo após o encerramento da conta. Demais dados são mantidos enquanto a conta estiver ativa.

4. Compartilhamento com Terceiros
Dados de navegação podem ser usados de forma anônima para exibição de anúncios de parceiros de publicidade (AdSense, AdCash e similares), que é nossa fonte de receita. Informações pessoais identificáveis nunca são vendidas a terceiros.

5. Segurança dos Dados
Aplicamos controle de acesso, autenticação segura, autorização por níveis, criptografia de informações sensíveis, backup seguro, monitoramento, logs de segurança e auditoria contínua.

6. Direitos do Usuário
O usuário pode solicitar acesso aos seus dados, correção de informações incorretas ou o encerramento da conta através da Central de Ajuda, respeitado o período de retenção de dados financeiros exigido por lei.

7. Exclusão ou Conservação dos Dados
Dados financeiros nunca são excluídos fisicamente, apenas de forma lógica (soft delete), preservando a integridade do livro-razão de transações e o histórico de auditoria.

8. Processos Relacionados à Privacidade
Qualquer solicitação relacionada à privacidade pode ser feita através da Central de Ajuda Jurídica, categoria "Privacidade".$doc$, '2026-08-07', now()
        FROM doc
        ON CONFLICT (document_id, version) DO NOTHING
        RETURNING id, document_id
     )
UPDATE legal_documents SET current_version_id = v.id FROM v WHERE legal_documents.id = v.document_id;

-- ============================================================
-- 3. POLÍTICA DE COOKIES — v1.0
-- ============================================================
WITH doc AS (SELECT id FROM legal_documents WHERE type = 'cookies'),
     v AS (
        INSERT INTO legal_document_versions (document_id, version, content, effective_date, published_at)
        SELECT id, '1.0', $doc$1. O que são Cookies
Cookies são pequenos arquivos de texto usados para lembrar preferências e melhorar sua experiência na plataforma.

2. Tipos de Cookies Utilizados
- Cookies essenciais: necessários para o funcionamento básico da plataforma (login, segurança). Não podem ser desativados.
- Cookies de preferência: lembram configurações como idioma e tema.
- Cookies analíticos: ajudam a entender como a plataforma é usada, de forma agregada.
- Cookies de publicidade: usados por parceiros (AdSense, AdCash) para exibir anúncios relevantes.

3. Tecnologias Utilizadas por Parceiros
Nossos parceiros de publicidade podem utilizar identificadores de anúncio e tecnologias semelhantes a cookies para mensurar o desempenho de campanhas.

4. Como Configurar suas Preferências
O usuário pode aceitar, recusar ou configurar individualmente cada categoria de cookie (exceto os essenciais) a qualquer momento, através do gerenciador de preferências disponível na plataforma. As escolhas feitas são armazenadas e podem ser alteradas posteriormente.$doc$, '2026-08-07', now()
        FROM doc
        ON CONFLICT (document_id, version) DO NOTHING
        RETURNING id, document_id
     )
UPDATE legal_documents SET current_version_id = v.id FROM v WHERE legal_documents.id = v.document_id;

-- ============================================================
-- 4. POLÍTICA DE RECOMPENSAS — v1.0
-- ============================================================
WITH doc AS (SELECT id FROM legal_documents WHERE type = 'recompensas'),
     v AS (
        INSERT INTO legal_document_versions (document_id, version, content, effective_date, published_at)
        SELECT id, '1.0', $doc$1. Natureza das Recompensas
As recompensas são um incentivo à aprendizagem contínua, não uma fonte de renda garantida. Ganhos financeiros dependem do cumprimento das condições estabelecidas nesta política e nos Termos de Uso.

2. Como o Usuário Ganha Recompensas
Respostas corretas nos quizzes geram XP. Missões concluídas e marcos de Ofensiva (streak) geram XP, Pontos e, em determinados marcos, dinheiro real (MZN).

3. Critérios para Receber Recompensas
O usuário precisa manter um Trust Score dentro dos parâmetros mínimos exigidos e cumprir integralmente os requisitos de cada missão ou marco de streak.

4. Valor Mínimo para Saque e Processo de Solicitação
O saque mínimo é de 100 MZN acumulados (valor já ganho, nunca depositado pelo usuário). O usuário solicita o saque através da Carteira, informando o método (M-Pesa ou e-Mola).

5. Prazo de Processamento e Análise Antifraude
O processamento não é imediato: toda solicitação passa por verificação antifraude e auditoria do Trust Score antes de ser aprovada. O prazo pode levar até 24 horas após a aprovação. Solicitações podem ser suspensas para revisão manual quando houver indício de irregularidade.

6. Possibilidade de Revisão Manual e Motivos para Suspensão
Solicitações de saque podem ser suspensas ou rejeitadas em caso de suspeita de fraude, Trust Score insuficiente ou dados de pagamento inconsistentes. Saques rejeitados ou cancelados têm o valor automaticamente devolvido ao saldo do usuário.

7. Dados Necessários para Pagamento e Responsabilidade pelas Informações
O usuário é responsável por fornecer corretamente o número M-Pesa ou e-Mola vinculado à sua conta. A plataforma não se responsabiliza por pagamentos enviados a números informados incorretamente pelo próprio usuário.$doc$, '2026-08-07', now()
        FROM doc
        ON CONFLICT (document_id, version) DO NOTHING
        RETURNING id, document_id
     )
UPDATE legal_documents SET current_version_id = v.id FROM v WHERE legal_documents.id = v.document_id;

-- ============================================================
-- 5. POLÍTICA DE COMUNIDADE — v1.0
-- ============================================================
WITH doc AS (SELECT id FROM legal_documents WHERE type = 'comunidade'),
     v AS (
        INSERT INTO legal_document_versions (document_id, version, content, effective_date, published_at)
        SELECT id, '1.0', $doc$1. Comportamento Esperado
Espera-se respeito entre usuários em qualquer área social da plataforma (ranking, comentários, convites), com linguagem apropriada e sem assédio.

2. Proibição de Fraude e Contas Falsas
É proibida a criação de contas falsas, o uso de identidades de terceiros e qualquer tentativa de burlar os sistemas de verificação da plataforma.

3. Proibição de Automações Não Autorizadas
Não é permitido o uso de bots, scripts ou qualquer automação para interagir com a plataforma, incluindo quizzes, missões, ranking ou o programa de indicações.

4. Manipulação de Rankings e Abuso de Indicações
É proibida qualquer tentativa de manipular artificialmente o Ranking Semanal, bem como o abuso do programa de indicações (por exemplo, indicações fictícias ou contas criadas apenas para gerar recompensa de indicação).

5. Conteúdos Proibidos
Não são permitidos conteúdos ofensivos, discriminatórios, ilegais ou que violem direitos de terceiros em qualquer campo de texto livre da plataforma.

6. Consequências das Violações
Violações a esta política podem resultar em advertência, suspensão temporária ou banimento permanente da conta, conforme a gravidade, sem prejuízo das demais sanções previstas nos Termos de Uso.$doc$, '2026-08-07', now()
        FROM doc
        ON CONFLICT (document_id, version) DO NOTHING
        RETURNING id, document_id
     )
UPDATE legal_documents SET current_version_id = v.id FROM v WHERE legal_documents.id = v.document_id;

-- ============================================================
-- 6. AVISO LEGAL (DISCLAIMER) — v1.0
-- ============================================================
WITH doc AS (SELECT id FROM legal_documents WHERE type = 'aviso_legal'),
     v AS (
        INSERT INTO legal_document_versions (document_id, version, content, effective_date, published_at)
        SELECT id, '1.0', $doc$O Aprenda e Ganhe é uma plataforma de tecnologia educacional e mídia. As recompensas financeiras são oferecidas como incentivo à gamificação e dependem do cumprimento de missões e regras estabelecidas, não constituindo promessa de renda, salário ou retorno financeiro garantido.

A participação na plataforma não representa garantia de rendimento financeiro. Recompensas dependem do cumprimento das condições estabelecidas nas demais políticas desta Central Jurídica.

Podem ocorrer manutenções ou indisponibilidades técnicas temporárias, sem que isso gere direito a indenização.

Os conteúdos educativos disponibilizados possuem finalidade estritamente informativa e não substituem aconselhamento profissional especializado (financeiro, jurídico ou de qualquer outra natureza).

A plataforma poderá atualizar suas políticas a qualquer momento, sendo o usuário notificado e, quando aplicável, solicitado a manifestar novo consentimento.

© 2026 Plataforma Aprenda e Ganhe. Todos os direitos reservados.$doc$, '2026-08-07', now()
        FROM doc
        ON CONFLICT (document_id, version) DO NOTHING
        RETURNING id, document_id
     )
UPDATE legal_documents SET current_version_id = v.id FROM v WHERE legal_documents.id = v.document_id;
