import { useEffect, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { trustScoreApi } from '../api/profileApi';
import { referralsApi } from '../api/referralsApi';
import { Card } from '../components/Card';
import { PrimaryButton, SecondaryButton } from '../components/Button';
import { useToast } from '../components/Toast';
import { ApiError } from '../api/client';
import { TrustShieldIcon, ProfileIcon, SettingsIcon, InviteIcon, ChevronRightIcon, ShopIcon, PointsIcon, AchievementIcon } from '../icons';
import { AVATAR_FRAME_CLASSES } from '../constants/shopCosmetics';

const BADGE_LABELS = {
  verified_trusted: 'Conta Verificada e Confiável',
  in_good_standing: 'Conta em dia',
  under_review: 'Conta em análise',
  restricted: 'Conta restrita',
};

const REFERRAL_STATUS_LABELS = {
  pending: 'Aguardando qualificação',
  rewarded: 'Qualificada — recompensa concedida',
};

/**
 * Seção "Convites" do Perfil (Manual Parte 3 — módulo Convites/Indicações).
 * Antes desta seção, o backend (`GET /referrals/me/code`, `GET /referrals/me`)
 * já existia pronto, mas nada no frontend chamava essa API — a pessoa não
 * tinha como ver o próprio código nem quem ela já indicou. Os nomes exibidos
 * abaixo vêm de um JOIN real com a tabela de usuários: se "Bosco" se cadastrar
 * com o código de alguém, é exatamente o nome "Bosco" que aparece aqui.
 */
function ReferralsSection() {
  const { showToast } = useToast();
  const [code, setCode] = useState(null);
  const [referrals, setReferrals] = useState(null);
  const [error, setError] = useState(false);
  const [expanded, setExpanded] = useState(false);

  useEffect(() => {
    referralsApi.getMyCode()
      .then((res) => setCode(res.data.code))
      .catch(() => setError(true));
    referralsApi.listMyReferrals()
      .then((res) => setReferrals(res.data))
      .catch(() => setReferrals([]));
  }, []);

  const inviteLink = code ? `${window.location.origin}/cadastro?ref=${code}` : null;
  const qualifiedCount = referrals?.filter((r) => r.status === 'rewarded').length ?? 0;

  async function handleShare() {
    const shareText = `Estou usando o Aprenda e Ganhe para estudar e ganhar MZN de verdade. Cadastre-se com meu código ${code}: ${inviteLink}`;
    if (navigator.share) {
      try {
        await navigator.share({ title: 'Aprenda e Ganhe', text: shareText, url: inviteLink });
      } catch {
        // Usuário cancelou o compartilhamento — não é um erro a ser exibido.
      }
      return;
    }
    await handleCopy();
  }

  async function handleCopy() {
    try {
      await navigator.clipboard.writeText(inviteLink);
      showToast('Link de convite copiado!', 'success');
    } catch {
      showToast('Não foi possível copiar o link automaticamente.', 'error');
    }
  }

  if (error) return null;

  return (
    <div className="space-y-2">
      <h2 className="font-display text-h2 text-text">Convites</h2>
      <Card className="space-y-3">
        <div className="flex items-center gap-3">
          <InviteIcon className="w-7 h-7 text-primary shrink-0" />
          <div className="flex-1">
            <p className="text-body font-semibold text-text">Seu código de indicação</p>
            <p className="text-caption text-text-secondary">
              Convide amigos. Quando eles responderem alguns quizzes, você ganha Pontos.
            </p>
          </div>
        </div>

        <div className="flex items-center justify-center bg-background border border-border rounded-button py-3">
          <span className="font-display text-h2 tracking-widest text-primary">{code || '···'}</span>
        </div>

        <div className="flex gap-2">
          <SecondaryButton onClick={handleCopy} className="flex-1 !py-2 text-caption" disabled={!code}>
            Copiar link
          </SecondaryButton>
          <PrimaryButton onClick={handleShare} className="flex-1 !py-2 text-caption" disabled={!code}>
            Compartilhar
          </PrimaryButton>
        </div>

        <button
          onClick={() => setExpanded((e) => !e)}
          className="w-full flex items-center justify-between text-caption text-text-secondary pt-2 border-t border-border"
        >
          <span>
            {referrals === null
              ? 'Carregando indicações...'
              : `${referrals.length} indicação${referrals.length !== 1 ? 'ões' : ''} · ${qualifiedCount} qualificada${qualifiedCount !== 1 ? 's' : ''}`}
          </span>
          <ChevronRightIcon className={`w-4 h-4 shrink-0 transition-transform duration-micro ${expanded ? 'rotate-90' : ''}`} />
        </button>

        {expanded && referrals?.length > 0 && (
          <div className="space-y-1.5 pt-1">
            {referrals.map((r) => (
              <div key={r.id} className="flex items-center justify-between text-caption">
                <span className="text-text">{r.referredName}</span>
                <span className={r.status === 'rewarded' ? 'text-success font-semibold' : 'text-text-secondary'}>
                  {REFERRAL_STATUS_LABELS[r.status] || r.status}
                </span>
              </div>
            ))}
          </div>
        )}
        {expanded && referrals?.length === 0 && (
          <p className="text-caption text-text-secondary pt-1">Você ainda não indicou ninguém.</p>
        )}
      </Card>
    </div>
  );
}

/**
 * Perfil e Configurações (Doc. Mestre Seção 19.7).
 * O selo de Trust Score é qualitativo, nunca o valor numérico exato
 * (regra da ficha técnica de ícone, Seção 13.5). O preenchimento visual do
 * ícone reflete a faixa (badge), não o número — ver TrustShieldIcon.
 */
export function Profile() {
  const { user, logout } = useAuth();
  const { showToast } = useToast();
  const navigate = useNavigate();
  const [badge, setBadge] = useState(null);
  const [settingsSpinKey, setSettingsSpinKey] = useState(0);

  useEffect(() => {
    trustScoreApi.me().then((res) => setBadge(res.data.badge)).catch(() => setBadge(null));
  }, []);

  async function handleLogout() {
    await logout();
    navigate('/onboarding', { replace: true });
  }

  function handleSettingsTap() {
    // Seção 13.6: "Configurações — rotação suave só durante o toque, sem loop".
    setSettingsSpinKey((k) => k + 1);
    showToast('Configurações avançadas em breve.', 'success');
  }

  return (
    <div className="space-y-5 pb-4">
      <header className="pt-2 flex flex-col items-center text-center relative">
        <button
          onClick={handleSettingsTap}
          aria-label="Configurações"
          className="absolute top-2 right-0 w-11 h-11 flex items-center justify-center text-text-secondary"
        >
          <SettingsIcon className="w-6 h-6" spinKey={settingsSpinKey} />
        </button>

        <div
          className={`w-20 h-20 rounded-full bg-primary/10 flex items-center justify-center mb-3 ${
            AVATAR_FRAME_CLASSES[user?.equippedAvatarFrame] || ''
          }`}
        >
          <ProfileIcon className="w-10 h-10 text-primary" />
        </div>
        <h1 className="font-display text-h1 text-text">{user?.name}</h1>
        <p className="text-caption text-text-secondary">{user?.phone}</p>
      </header>

      {badge && (
        <Card className="flex items-center gap-3">
          <TrustShieldIcon className="w-8 h-8 text-success shrink-0" badge={badge} />
          <div>
            <p className="text-body font-semibold text-text">{BADGE_LABELS[badge] || 'Status da conta'}</p>
            <p className="text-caption text-text-secondary">Seu histórico de atividade legítima</p>
          </div>
        </Card>
      )}

      <Link to="/loja" className="flex items-center justify-between gap-2 bg-surface border border-border rounded-card px-4 py-3">
        <span className="flex items-center gap-2">
          <ShopIcon className="w-5 h-5 text-primary" />
          <span className="text-body font-semibold text-text">Loja de Pontos</span>
        </span>
        <span className="flex items-center gap-2">
          <span className="flex items-center gap-1 text-caption text-gold font-semibold">
            <PointsIcon className="w-4 h-4" />
            {user?.pointsBalance ?? 0}
          </span>
          <ChevronRightIcon className="w-4 h-4 text-text-secondary" />
        </span>
      </Link>

      <Link to="/meus-recursos" className="flex items-center justify-between gap-2 bg-surface border border-border rounded-card px-4 py-3 mt-3">
        <span className="flex items-center gap-2">
          <AchievementIcon className="w-5 h-5 text-primary" />
          <span className="text-body font-semibold text-text">Meus Recursos</span>
        </span>
        <ChevronRightIcon className="w-4 h-4 text-text-secondary" />
      </Link>

      <ReferralsSection />

      <div className="space-y-2">
        <h2 className="font-display text-h2 text-text">Legal</h2>
        <Card className="block">
          <Link to="/legal" className="text-body text-text">Central Jurídica</Link>
        </Card>
        <Card className="block">
          <a href="/termos" className="text-body text-text">Termos de Uso</a>
        </Card>
        <Card className="block">
          <a href="/privacidade" className="text-body text-text">Política de Privacidade</a>
        </Card>
        <Card className="block">
          <a href="/recompensas" className="text-body text-text">Política de Recompensas</a>
        </Card>
        <Card className="block">
          <Link to="/suporte" className="text-body text-text">Suporte, Reclamações e Recursos</Link>
        </Card>
        <Card className="block">
          <Link to="/meus-consentimentos" className="text-body text-text">Meus Consentimentos</Link>
        </Card>
      </div>

      <SecondaryButton onClick={handleLogout} className="w-full">
        Sair
      </SecondaryButton>
    </div>
  );
}
