import { useState, useEffect } from 'react';
import { Link, useParams } from 'react-router-dom';
import { ChevronRightIcon } from '../icons';
import { legalApi } from '../api/legalApi';

/**
 * Central Jurídica (docx "final jur.." Partes 2 e 3).
 * Os 6 documentos oficiais (Termos, Privacidade, Cookies, Recompensas,
 * Comunidade, Aviso Legal) agora vêm do backend com metadados de versão,
 * data de publicação e status — não são mais texto fixo no frontend. Isso
 * permite ao Painel Administrativo publicar uma nova versão sem precisar de
 * deploy do app (ver docx Parte 11.1).
 *
 * ⚠️ Isto NÃO substitui revisão jurídica formal antes de produção.
 */

const STATUS_LABELS = { active: 'Ativo', archived: 'Arquivado' };

function LegalShell({ title, children, backTo = '/perfil' }) {
  return (
    <div className="min-h-screen bg-background px-6 py-8">
      <div className="max-w-md mx-auto space-y-4">
        <Link to={backTo} className="text-caption text-primary font-semibold">← Voltar</Link>
        <h1 className="font-display text-h1 text-text">{title}</h1>
        <div className="text-body text-text-secondary space-y-4">{children}</div>
      </div>
    </div>
  );
}

function DocumentMeta({ version, effectiveDate, status }) {
  return (
    <div className="flex flex-wrap gap-x-4 gap-y-1 text-caption text-text-secondary bg-surface border border-border rounded-card px-4 py-3">
      <span>Versão: <strong className="text-text">{version || '—'}</strong></span>
      <span>
        Publicado em:{' '}
        <strong className="text-text">
          {effectiveDate ? new Date(effectiveDate).toLocaleDateString('pt-MZ') : '—'}
        </strong>
      </span>
      <span>Status: <strong className="text-success">{STATUS_LABELS[status] || status}</strong></span>
    </div>
  );
}

function LoadingState() {
  return <p className="text-body text-text-secondary">Carregando documento...</p>;
}

function ErrorState() {
  return <p className="text-danger text-body">Não foi possível carregar este documento agora.</p>;
}

/**
 * Página genérica para qualquer um dos 6 documentos jurídicos — busca conteúdo
 * e metadados diretamente do backend (fonte única da verdade).
 */
function LegalDocumentPage({ type, backTo }) {
  const [doc, setDoc] = useState(null);
  const [error, setError] = useState(false);

  useEffect(() => {
    let mounted = true;
    legalApi.getDocument(type)
      .then((res) => { if (mounted) setDoc(res.data); })
      .catch(() => { if (mounted) setError(true); });
    return () => { mounted = false; };
  }, [type]);

  if (error) {
    return (
      <LegalShell title="Documento indisponível" backTo={backTo}>
        <ErrorState />
      </LegalShell>
    );
  }

  if (!doc) {
    return (
      <LegalShell title="Carregando..." backTo={backTo}>
        <LoadingState />
      </LegalShell>
    );
  }

  return (
    <LegalShell title={doc.title} backTo={backTo}>
      <DocumentMeta version={doc.version} effectiveDate={doc.effectiveDate} status={doc.status} />
      <div className="space-y-4 pt-2">
        {doc.content.split('\n\n').map((paragraph, i) => (
          <p key={i} className="whitespace-pre-line">{paragraph}</p>
        ))}
      </div>
    </LegalShell>
  );
}

export function TermsPage() {
  return <LegalDocumentPage type="termos" />;
}

export function PrivacyPage() {
  return <LegalDocumentPage type="privacidade" />;
}

export function RewardsPolicyPage() {
  return <LegalDocumentPage type="recompensas" />;
}

export function CookiesPage() {
  return <LegalDocumentPage type="cookies" backTo="/legal" />;
}

export function CommunityPage() {
  return <LegalDocumentPage type="comunidade" backTo="/legal" />;
}

export function DisclaimerPage() {
  return <LegalDocumentPage type="aviso_legal" backTo="/legal" />;
}

// Rota genérica /legal/:type — usada pelos links da Central Jurídica
export function LegalDocumentByRoute() {
  const { type } = useParams();
  return <LegalDocumentPage type={type} backTo="/legal" />;
}

/**
 * Central Jurídica (docx Parte 3): página única listando os 6 documentos com
 * nome, versão, data de publicação e status — exatamente a estrutura dos prints.
 */
export function CentralJuridica() {
  const [documents, setDocuments] = useState(null);

  useEffect(() => {
    let mounted = true;
    legalApi.listDocuments()
      .then((res) => { if (mounted) setDocuments(res.data); })
      .catch(() => { if (mounted) setDocuments([]); });
    return () => { mounted = false; };
  }, []);

  return (
    <LegalShell title="Central Jurídica">
      <p>Todos os documentos oficiais que regem o uso da plataforma Aprenda e Ganhe.</p>

      {documents === null && <LoadingState />}

      {documents && (
        <div className="space-y-2 pt-1">
          {documents.map((doc) => (
            <Link
              key={doc.type}
              to={`/legal/${doc.type}`}
              className="flex items-center justify-between gap-2 bg-surface border border-border rounded-card px-4 py-3 hover:border-primary/40"
            >
              <div>
                <p className="text-body font-semibold text-text">{doc.title}</p>
                <p className="text-caption text-text-secondary">
                  Versão {doc.version || '—'} · {STATUS_LABELS[doc.status] || doc.status}
                </p>
              </div>
              <ChevronRightIcon className="w-4 h-4 text-text-secondary shrink-0" />
            </Link>
          ))}
        </div>
      )}

      <div className="pt-4 space-y-2">
        <Link to="/suporte" className="flex items-center justify-between gap-2 bg-surface border border-border rounded-card px-4 py-3">
          <span className="text-body font-semibold text-text">Central de Ajuda</span>
          <ChevronRightIcon className="w-4 h-4 text-text-secondary shrink-0" />
        </Link>
        <Link to="/como-funciona" className="flex items-center justify-between gap-2 bg-surface border border-border rounded-card px-4 py-3">
          <span className="text-body font-semibold text-text">Como Funciona</span>
          <ChevronRightIcon className="w-4 h-4 text-text-secondary shrink-0" />
        </Link>
      </div>
    </LegalShell>
  );
}

function Section({ number, title, children }) {
  return (
    <div>
      <h2 className="text-body font-semibold text-text mb-1">{number}. {title}</h2>
      <div className="space-y-1">{children}</div>
    </div>
  );
}

function FaqItem({ question, children }) {
  const [open, setOpen] = useState(false);
  return (
    <div className="border border-border rounded-card overflow-hidden">
      <button
        onClick={() => setOpen((o) => !o)}
        className="w-full flex items-center justify-between gap-2 px-4 py-3 text-left"
      >
        <span className="text-body font-semibold text-text">{question}</span>
        <ChevronRightIcon
          className={`w-4 h-4 text-text-secondary shrink-0 transition-transform duration-micro ${
            open ? 'rotate-90' : ''
          }`}
        />
      </button>
      {open && <div className="px-4 pb-3 text-body text-text-secondary">{children}</div>}
    </div>
  );
}

function FaqGroup({ title, items }) {
  return (
    <div>
      <h3 className="text-caption font-semibold text-text-secondary uppercase tracking-wide mb-2">
        {title}
      </h3>
      <div className="space-y-2">
        {items.map((item, i) => (
          <FaqItem key={i} question={item.q}>{item.a}</FaqItem>
        ))}
      </div>
    </div>
  );
}

export function HowItWorksPage() {
  return (
    <LegalShell title="Como Funciona">
      <Section number={1} title="Estude">
        <p>Responda quizzes sobre Finanças, Tecnologia, IA, Marketing Digital e
        Produtividade.</p>
      </Section>
      <Section number={2} title="Ganhe XP e Suba de Nível">
        <p>Cada resposta certa gera XP. Seu XP acumulado define seu nível.</p>
      </Section>
      <Section number={3} title="Complete Missões">
        <p>Missões diárias liberam recompensas em XP, Pontos e, às vezes, MZN.</p>
      </Section>
      <Section number={4} title="Mantenha sua Ofensiva">
        <p>Estude todo dia para acumular streak e desbloquear marcos de recompensa
        crescentes (7, 15, 30, 60 e 100 dias).</p>
      </Section>
      <Section number={5} title="Saque quando quiser">
        <p>Ao atingir 100 MZN acumulados, solicite seu saque a qualquer momento.
        Sem depósito, sem cobrança — só o que você já ganhou.</p>
      </Section>
    </LegalShell>
  );
}

const FAQ_GROUPS = [
  {
    title: '1. Conta e Cadastro',
    items: [
      {
        q: 'Preciso depositar algo para começar?',
        a: 'Não. Você nunca deposita nada — só ganha estudando. A plataforma nunca cobra valor algum de você.',
      },
      {
        q: 'Posso ter duas contas?',
        a: 'Não. Cada pessoa tem direito a apenas uma conta, vinculada a um único número de telefone (M-Pesa ou e-Mola).',
      },
      {
        q: 'Que número de telefone posso usar?',
        a: 'Um número ativo M-Pesa (prefixos 84/85) ou e-Mola (prefixos 86/87), registrado em seu nome.',
      },
      {
        q: 'Esqueci minha senha, e agora?',
        a: 'No momento não há recuperação automática de senha pelo app. Entre em contato pelos canais de suporte abaixo.',
      },
      {
        q: 'Como encerro minha conta?',
        a: 'Entre em contato pelo suporte solicitando o encerramento. Dados financeiros são mantidos por exigência legal mesmo após o encerramento.',
      },
    ],
  },
  {
    title: '2. Estudos, XP e Missões',
    items: [
      {
        q: 'Como ganho XP?',
        a: 'Respondendo corretamente às perguntas dos quizzes, dentro do tempo do cronômetro.',
      },
      {
        q: 'O que acontece se eu errar ou o tempo acabar?',
        a: 'A resposta é contabilizada como errada e nenhum XP é concedido para aquela pergunta — mas você pode tentar outra pergunta na mesma hora.',
      },
      {
        q: 'Como funcionam as Missões?',
        a: 'Cada missão pede uma quantidade de quizzes corretos em uma categoria. Ao concluir, você precisa resgatar a recompensa manualmente na aba de Missões.',
      },
      {
        q: 'O que é a Ofensiva (streak)?',
        a: 'É a contagem de dias consecutivos que você estudou. Aos 7, 15, 30, 60 e 100 dias você desbloqueia recompensas cada vez maiores.',
      },
      {
        q: 'Se eu faltar um dia, perco minha ofensiva?',
        a: 'Sim, normalmente. Mas ao atingir 15 dias de ofensiva você ganha um item de proteção que evita a quebra uma única vez.',
      },
    ],
  },
  {
    title: '3. Carteira e Saques',
    items: [
      {
        q: 'Qual o valor mínimo para sacar?',
        a: '100 MZN acumulados. Esse valor é sempre dinheiro que você já ganhou — nunca um depósito seu.',
      },
      {
        q: 'Existe um limite de quanto posso sacar por dia?',
        a: 'Não. Você pode solicitar saque quando quiser, de qualquer valor acima do mínimo, respeitado seu saldo disponível.',
      },
      {
        q: 'Então o que é o valor de 7,20 MZN que aparece às vezes?',
        a: 'É o teto de quanto você pode GANHAR em dinheiro real por dia através de missões e streak — não tem relação com o saque em si.',
      },
      {
        q: 'Por que meu saque está demorando?',
        a: 'O pagamento é processado manualmente pela nossa equipe e pode levar até 24 horas após a aprovação.',
      },
      {
        q: 'Posso cancelar um saque depois de solicitar?',
        a: 'A solicitação já entra em análise imediatamente. Entre em contato com o suporte o quanto antes se precisar cancelar.',
      },
      {
        q: 'Meu saque foi rejeitado. Perdi o dinheiro?',
        a: 'Não. Se um saque é rejeitado ou cancelado, o valor é automaticamente devolvido ao seu saldo na Carteira.',
      },
    ],
  },
  {
    title: '4. Segurança e Trust Score',
    items: [
      {
        q: 'O que é o Trust Score?',
        a: 'É uma pontuação de confiança baseada no seu histórico de atividade legítima. Ela influencia sua elegibilidade para saques.',
      },
      {
        q: 'Por que meu Trust Score caiu?',
        a: 'Atividades sinalizadas automaticamente como suspeitas (por exemplo, respostas muito rápidas para serem humanamente plausíveis) reduzem a pontuação.',
      },
      {
        q: 'Posso ver meu Trust Score exato?',
        a: 'Não é exibido o número exato — apenas um selo qualitativo do status da sua conta, por política interna de segurança.',
      },
      {
        q: 'Uso VPN. Isso é um problema?',
        a: 'Sim. O uso de VPN para mascarar localização é proibido pelos Termos de Uso e pode levar à suspensão da conta.',
      },
    ],
  },
  {
    title: '5. Indicações',
    items: [
      {
        q: 'Como funciona o programa de indicação?',
        a: 'Você tem um código único. Quando alguém se cadastra com seu código e completa uma quantidade mínima de quizzes, você recebe uma recompensa em Pontos automaticamente.',
      },
      {
        q: 'Onde encontro meu código de indicação?',
        a: 'No seu Perfil, ou solicitando diretamente pelo app na área de Convites.',
      },
    ],
  },
  {
    title: '6. Privacidade e Termos',
    items: [
      {
        q: 'Meus dados são vendidos para alguém?',
        a: 'Não. Informações pessoais identificáveis nunca são vendidas a terceiros. Apenas dados de navegação anônimos podem ser usados para anúncios.',
      },
      {
        q: 'Os Termos de Uso podem mudar?',
        a: 'Sim. Quando isso acontece, você precisa revisar e aceitar a nova versão antes de continuar usando o app.',
      },
    ],
  },
];

/**
 * Meus Consentimentos (docx jurídico Parte 5 — Registro de Consentimento; e
 * Parte 14 — "Direitos dos usuários: solicitar informações"). A API já
 * existia (`GET /legal/my-acceptances`) mas não tinha nenhuma tela — o
 * usuário não tinha como ver quais versões dos documentos ele aceitou e quando.
 */
export function MyLegalAcceptances() {
  const [acceptances, setAcceptances] = useState(null);
  const [error, setError] = useState(false);

  useEffect(() => {
    legalApi.myAcceptances()
      .then((res) => setAcceptances(res.data))
      .catch(() => setError(true));
  }, []);

  return (
    <LegalShell title="Meus Consentimentos">
      <p>Histórico de todos os documentos jurídicos que você aceitou, com a versão e o momento exato do aceite.</p>

      {error && <ErrorState />}
      {!error && acceptances === null && <LoadingState />}
      {acceptances?.length === 0 && <p className="text-caption">Nenhum aceite registrado ainda.</p>}

      {acceptances && acceptances.length > 0 && (
        <div className="space-y-2 pt-1">
          {acceptances.map((a, i) => (
            <div key={i} className="bg-surface border border-border rounded-card px-4 py-3">
              <p className="text-body font-semibold text-text">{a.title}</p>
              <p className="text-caption text-text-secondary">
                Versão {a.version} · Aceito em {new Date(a.accepted_at).toLocaleString('pt-MZ')}
              </p>
            </div>
          ))}
        </div>
      )}
    </LegalShell>
  );
}

export { FAQ_GROUPS, Section, FaqGroup, LegalShell };
