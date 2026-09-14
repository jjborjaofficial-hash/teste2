# Políticas da Plataforma — Aprenda e Ganhe
### Versão 1.0 — Documento de Referência para as Páginas do Rodapé

> ⚠️ **Aviso importante**: este documento organiza em tópicos sequenciais o conteúdo
> que já está implementado (ou deveria estar) nas páginas legais do app. Ele é
> baseado na Seção 16 do Documento Mestre e nas decisões tomadas ao longo do
> desenvolvimento. **Não substitui revisão jurídica formal** — antes de operar
> com dinheiro real, um advogado moçambicano deve revisar especialmente as
> Partes I e II.

---

## PARTE I — TERMOS DE USO

### 1. Aceitação dos Termos
1.1. Ao criar uma conta no Aprenda e Ganhe, o usuário declara ter lido, compreendido
e concordado integralmente com estes Termos de Uso e com a Política de Privacidade.
1.2. O aceite é feito através de checkbox obrigatório no momento do cadastro
(desmarcado por padrão), junto com a declaração de maioridade.
1.3. O uso continuado da plataforma após qualquer atualização destes Termos
constitui aceite das novas condições.

### 2. Elegibilidade e Cadastro
2.1. O usuário deve residir em Moçambique.
2.2. O usuário deve possuir um número de telefone ativo, vinculado a uma conta
M-Pesa (prefixos 84/85) ou e-Mola (prefixos 86/87).
2.3. O usuário deve ser maior de idade, conforme a legislação moçambicana.
2.4. Cada pessoa tem direito a **apenas uma conta**. Um mesmo número de telefone
não pode estar vinculado a mais de uma conta ativa simultaneamente.

### 3. Conta Única e Identidade
3.1. É estritamente proibida a criação de múltiplas contas pela mesma pessoa.
3.2. A plataforma pode solicitar verificação adicional de identidade a qualquer
momento, especialmente antes da liberação de saques.
3.3. Contas identificadas como duplicadas podem ser suspensas ou banidas, com
retenção de saldo, sem aviso prévio.

### 4. Uso Aceitável e Antifraude (Tolerância Zero)
4.1. É proibido o uso de robôs, scripts, automações ou qualquer ferramenta que
burle o sistema de tempo e respostas dos quizzes.
4.2. É proibido o uso de VPNs ou qualquer método para mascarar a localização real
do usuário.
4.3. Cada usuário possui um **Trust Score** (Pontuação de Confiança) que reflete
o histórico de atividade legítima na plataforma.
4.4. A plataforma reserva-se o direito de:
   - reter o saldo em MZN de contas suspeitas;
   - zerar os Pontos (XP) acumulados de forma fraudulenta;
   - banir permanentemente contas com indícios claros de fraude, sem necessidade
     de aviso prévio.

### 5. Natureza das Recompensas
5.1. Os ganhos financeiros oferecidos pela plataforma são um **incentivo ao
estudo e ao hábito diário**, e não constituem promessa de salário, renda fixa
ou retorno financeiro garantido.
5.2. As regras matemáticas de recompensa (conversão de XP, teto de saque,
requisitos de missões) podem ser ajustadas a qualquer momento, visando a
sustentabilidade do ecossistema.

### 6. Saques e Pagamentos
6.1. O saque mínimo é de **100 MZN** acumulados (valor já ganho na plataforma —
nunca depositado pelo usuário). Não há teto diário para SOLICITAR saque: o
usuário pode pedir quando quiser, qualquer valor acima do mínimo.
6.2. Existe, isso sim, um teto de **quanto o usuário pode GANHAR em dinheiro
real por dia** (7,20 MZN/dia, via missões e marcos de streak) — não deve ser
confundido com um teto de saque.
6.3. **O usuário nunca deposita ou transfere dinheiro para a plataforma, em
nenhuma circunstância.** A plataforma nunca cobra valor monetário de ninguém.
Estes valores podem ser ajustados pela plataforma sem aviso prévio.
6.4. O processamento do pagamento **não é imediato**: passa por análise de
Trust Score e é processado manualmente pela equipe da plataforma.
6.5. Prazo estimado de processamento: até 24 horas após a aprovação, sujeito a
variações operacionais e ao tempo de processamento da instituição financeira
(M-Pesa/e-Mola).
6.6. Um usuário não pode ter mais de uma solicitação de saque em andamento ao
mesmo tempo.
6.7. A plataforma pode aprovar, rejeitar, suspender para revisão ou cancelar
qualquer solicitação de saque, a seu critério, especialmente em caso de
suspeita de fraude.

### 7. Suspensão e Encerramento de Conta
7.1. A plataforma pode suspender ou banir contas que violem estes Termos.
7.2. Em caso de banimento por fraude comprovada, o saldo pode ser retido
permanentemente.
7.3. O usuário pode solicitar o encerramento voluntário da própria conta a
qualquer momento, através do suporte.

### 8. Alterações nos Termos
8.1. Estes Termos podem ser atualizados periodicamente.
8.2. Alterações significativas serão comunicadas através da plataforma.
8.3. Mecanismo automático de reaceite: **implementado** (ver
`docs/reaceite-termos-e-correcao-regras-saque.md`). `users.terms_version` é
comparado com a versão vigente a cada requisição a `GET /users/me`; se
divergente, o usuário é bloqueado em `/reaceitar-termos` até confirmar o
aceite da versão atual.

### 9. Limitação de Responsabilidade
9.1. O Aprenda e Ganhe é uma plataforma de tecnologia educacional e mídia.
9.2. A plataforma não se responsabiliza por atrasos causados por instituições
financeiras terceiras (M-Pesa, e-Mola) fora de seu controle direto.
9.3. A plataforma não garante disponibilidade ininterrupta do serviço.

### 10. Legislação Aplicável
10.1. Estes Termos são regidos pelas leis da República de Moçambique.
10.2. *(Pendente de revisão jurídica formal: foro/jurisdição específica para
resolução de disputas ainda não foi definido por um advogado.)*

---

## PARTE II — POLÍTICA DE PRIVACIDADE

### 1. Dados Coletados
1.1. Dados de cadastro: nome, número de telefone, senha (armazenada com hash,
nunca em texto puro).
1.2. Dados de uso: histórico de quizzes, XP, streak, missões, transações
financeiras.
1.3. Dados técnicos: endereço IP, tipo de dispositivo, logs de acesso
(usados para segurança e prevenção de fraude).

### 2. Finalidade do Uso dos Dados
2.1. Operar e manter a plataforma funcionando corretamente.
2.2. Calcular Trust Score e prevenir fraudes.
2.3. Processar saques e manter histórico financeiro auditável.
2.4. Exibir anúncios relevantes de parceiros (fonte de receita da plataforma).

### 3. Compartilhamento com Terceiros
3.1. Dados de navegação podem ser usados de forma **anônima** para exibição de
anúncios de parceiros publicitários.
3.2. Informações pessoais identificáveis (nome, telefone) **nunca são vendidas**
a terceiros.
3.3. Dados podem ser compartilhados com autoridades legais mediante ordem
judicial válida.

### 4. Segurança dos Dados
4.1. Senhas são armazenadas com hash criptográfico (bcrypt), nunca em texto puro.
4.2. Comunicação entre aplicativo e servidor é criptografada (HTTPS).
4.3. Acesso administrativo aos dados é restrito por papel (admin_master,
admin_financeiro, admin_suporte) e totalmente auditado.

### 5. Direitos do Usuário
5.1. O usuário pode solicitar acesso aos próprios dados através do suporte.
5.2. O usuário pode solicitar a exclusão da conta, respeitado o período mínimo
de retenção de dados financeiros exigido por lei (ver item 6).

### 6. Retenção de Dados
6.1. Dados financeiros (transações, saques) são mantidos de forma permanente e
imutável (livro-razão), mesmo após o encerramento da conta, para fins de
auditoria e conformidade legal.
6.2. Dados de cadastro podem ser anonimizados mediante solicitação, exceto
quando sua manutenção for exigida por lei.

### 7. Alterações na Política
7.1. Esta Política pode ser atualizada periodicamente, seguindo o mesmo processo
de comunicação previsto na Parte I, Seção 8.

---

## PARTE III — POLÍTICA DE RECOMPENSAS

### 1. Natureza das Recompensas
1.1. As recompensas são um incentivo à aprendizagem contínua, não uma fonte de
renda garantida.

### 2. Moedas da Plataforma
2.1. **Pontos**: moeda soft, de uso corriqueiro, sem conversão direta garantida
em dinheiro.
2.2. **Dinheiro Real (MZN)**: concentrado em missões de alto valor educativo e
marcos de constância (streak).

### 3. Como se Ganha Recompensa
3.1. Respostas corretas em quizzes geram XP.
3.2. Conclusão de missões diárias gera XP, Pontos e, em alguns casos, MZN.
3.3. Marcos de Ofensiva (streak de 7, 15, 30, 60 e 100 dias) geram bônus
crescentes, incluindo recompensas em dinheiro real a partir do marco de 30 dias.

### 4. Regras de Saque
4.1. Ver Parte I, Seção 6 (Saques e Pagamentos).

### 5. Elegibilidade e Trust Score
5.1. O acesso a saques exige um Trust Score mínimo, definido internamente pela
plataforma e sujeito a alteração.
5.2. Atividade suspeita (ex.: respostas suspeitosamente rápidas) reduz o Trust
Score automaticamente.

### 6. Alterações nas Regras
6.1. Valores de recompensa, marcos de streak e regras de qualificação podem ser
ajustados a qualquer momento para garantir a sustentabilidade financeira da
plataforma.

---

## PARTE IV — COMO FUNCIONA

### 1. Cadastro
1.1. Nome, telefone (M-Pesa/e-Mola) e senha.
1.2. Declaração de maioridade e aceite dos Termos de Uso.

### 2. Categorias de Estudo
2.1. Finanças, Tecnologia, Inteligência Artificial, Marketing Digital e
Produtividade.

### 3. Sistema de XP e Níveis
3.1. Cada resposta correta gera XP.
3.2. O acúmulo de XP determina o nível do usuário, exibido no Painel Principal.

### 4. Missões
4.1. Missões diárias, semanais e especiais, com metas de quizzes a completar.
4.2. Concluir uma missão libera recompensa em XP, Pontos e/ou MZN, a ser
resgatada manualmente pelo usuário.

### 5. Ofensiva (Streak)
5.1. Dias consecutivos de atividade geram bônus crescentes.
5.2. Ao atingir 15 dias, o usuário recebe um "item de proteção" que evita a
quebra do streak uma única vez.

### 6. Ranking Semanal
6.1. Usuários são ranqueados semanalmente pelo XP ganho na semana corrente.

### 7. Carteira e Saques
7.1. Ver Parte I, Seção 6 e Parte III.

---

## PARTE V — SUPORTE E FAQ

### 1. Canais de Contato
1.1. *(Pendente: endereço de e-mail/canal de suporte oficial ainda não definido.
Placeholder atual no app não tem contato real.)*

### 2. Perguntas Frequentes (a expandir)
2.1. "Por que meu saque está demorando?" — O pagamento é processado manualmente
e pode levar até 24h após a aprovação.
2.2. "Por que meu Trust Score caiu?" — Atividade automaticamente sinalizada como
suspeita (ex.: respostas muito rápidas) reduz a pontuação.
2.3. "Posso ter duas contas?" — Não. Cada pessoa tem direito a apenas uma conta,
vinculada a um único número de telefone.

---

## Itens que precisam de decisão/ação antes de produção

| Item | Situação |
|---|---|
| Revisão jurídica formal (Partes I e II) | ❌ Não feita — recomendado antes de operar com dinheiro real |
| Foro/jurisdição para disputas | ❌ Não definido |
| Mecanismo de reaceite de novos Termos | ✅ Implementado — checkbox obrigatório, bloqueia o app até reaceitar quando a versão dos Termos muda |
| Canal de suporte real (e-mail/telefone) | ❌ Não definido |
| FAQ completo | ⚠️ Só 3 perguntas de exemplo acima |
