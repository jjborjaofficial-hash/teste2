import { useEffect, useState } from 'react';
import { rankingApi } from '../api/gameplayApi';
import { Card } from '../components/Card';
import { RankingIcon, ProfileIcon } from '../icons';
import { AVATAR_FRAME_CLASSES } from '../constants/shopCosmetics';

/**
 * Ranking Semanal (Doc. Mestre Seção 9 — Estratégia de Engajamento e Retenção:
 * "painel dos usuários que mais evoluíram na semana").
 */
export function Ranking() {
  const [top, setTop] = useState([]);
  const [myPosition, setMyPosition] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    Promise.all([rankingApi.topWeekly(), rankingApi.myPosition()])
      .then(([topRes, meRes]) => {
        setTop(topRes.data);
        setMyPosition(meRes.data);
      })
      .finally(() => setLoading(false));
  }, []);

  return (
    <div className="space-y-4 pb-4">
      <header className="pt-2 flex items-center gap-2">
        <RankingIcon className="w-7 h-7 text-primary" />
        <h1 className="font-display text-h1 text-text">Ranking Semanal</h1>
      </header>

      {myPosition?.position && (
        <Card className="bg-primary/5 border-primary/20">
          <p className="text-caption text-text-secondary">Sua posição esta semana</p>
          <p className="font-display text-h1 text-primary">
            #{myPosition.position} <span className="text-body font-sans text-text-secondary">· {myPosition.xpEarned} XP</span>
          </p>
        </Card>
      )}

      {loading && <p className="text-caption text-text-secondary">Carregando ranking...</p>}

      <div className="space-y-2">
        {top.map((entry) => (
          <Card key={entry.userId} className="flex items-center gap-3 !py-3">
            <span className="font-display font-semibold text-h2 text-text-secondary w-8 text-center">
              {entry.position}
            </span>
            <div
              className={`w-9 h-9 rounded-full bg-primary/10 flex items-center justify-center shrink-0 ${
                AVATAR_FRAME_CLASSES[entry.avatarFrame] || ''
              }`}
            >
              <ProfileIcon className="w-5 h-5 text-primary" />
            </div>
            <div className="flex-1">
              <p className="text-body font-semibold text-text">{entry.name}</p>
            </div>
            <span className="font-display font-semibold text-gold">{entry.xpEarned} XP</span>
          </Card>
        ))}

        {!loading && top.length === 0 && (
          <Card><p className="text-body text-text-secondary">O ranking desta semana ainda está sendo construído.</p></Card>
        )}
      </div>
    </div>
  );
}
