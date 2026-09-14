import { useEffect, useState } from 'react';
import { walletApi } from '../api/gameplayApi';
import { gamificationApi } from '../api/profileApi';
import { Card } from '../components/Card';
import { PrimaryButton, SecondaryButton } from '../components/Button';
import { useToast } from '../components/Toast';
import { ApiError } from '../api/client';

// Regras confirmadas pelo proprietário do projeto (documentadas em
// docs/fluxo-saque-manual-permissoes-admin-ui.md e no backend, system_config):
// - Saque mínimo: 100 MZN acumulado (sem depósito — só o que já foi ganho).
// - Teto de GANHO diário: 7,20 MZN (não é teto de saque).
// - Não existe teto diário de SAQUE — pode sacar quando quiser, qualquer valor
//   acima do mínimo, respeitado o saldo disponível.
const WITHDRAWAL_MIN_MZN = 100;

/**
 * Carteira (Doc. Mestre Seção 19.6). Saldo, resgate M-Pesa/e-Mola, histórico
 * de transações, banner de anúncio no rodapé (Anúncio Estratégico 4).
 */
export function Wallet() {
  const { showToast } = useToast();
  const [balance, setBalance] = useState(null);
  const [history, setHistory] = useState([]);
  const [method, setMethod] = useState('mpesa');
  const [amount, setAmount] = useState(WITHDRAWAL_MIN_MZN.toFixed(2));
  const [submitting, setSubmitting] = useState(false);
  const [loading, setLoading] = useState(true);

  // Conversão de Pontos em dinheiro (docx "SISTEMA DE ECONOMIA E RECOMPENSAS",
  // Seção 6.1). A taxa vem sempre da API — nunca fixa no frontend — para que
  // um ajuste feito pelo admin em `system_config` apareça aqui sem deploy.
  const [pointsBalance, setPointsBalance] = useState(0);
  const [conversionRate, setConversionRate] = useState(null);
  const [pointsToConvert, setPointsToConvert] = useState('');
  const [converting, setConverting] = useState(false);

  async function load() {
    const [balanceRes, historyRes, gamificationRes, rateRes] = await Promise.all([
      walletApi.getBalance(),
      walletApi.getHistory(),
      gamificationApi.me(),
      walletApi.getConversionRate(),
    ]);
    setBalance(balanceRes.data.walletBalanceMzn);
    setHistory(historyRes.data);
    setPointsBalance(gamificationRes.data.pointsBalance ?? 0);
    setConversionRate(rateRes.data);
    setPointsToConvert(String(rateRes.data.ratePoints));
  }

  useEffect(() => {
    load().finally(() => setLoading(false));
  }, []);

  async function handleWithdraw(e) {
    e.preventDefault();
    setSubmitting(true);
    try {
      await walletApi.requestWithdrawal({ amountMzn: Number(amount), method });
      showToast('Saque solicitado! O valor estará na sua conta em até 24 horas.', 'success');
      await load();
    } catch (err) {
      showToast(err instanceof ApiError ? err.message : 'Não foi possível solicitar o saque.', 'error');
    } finally {
      setSubmitting(false);
    }
  }

  const canWithdraw = balance !== null && balance >= WITHDRAWAL_MIN_MZN;

  const pointsNumber = Number(pointsToConvert) || 0;
  const isMultipleOfRate = !!conversionRate && pointsNumber > 0 && pointsNumber % conversionRate.ratePoints === 0;
  const previewMzn = conversionRate && isMultipleOfRate
    ? (pointsNumber / conversionRate.ratePoints) * conversionRate.rateMzn
    : null;
  const canConvert = conversionRate && isMultipleOfRate && pointsNumber <= pointsBalance;

  async function handleConvert(e) {
    e.preventDefault();
    setConverting(true);
    try {
      const res = await walletApi.convertPoints({ pointsAmount: pointsNumber });
      showToast(
        `Convertido! ${res.data.pointsConverted} Pontos -> ${res.data.amountMzn.toFixed(2)} MZN.`,
        'success'
      );
      await load();
    } catch (err) {
      showToast(err instanceof ApiError ? err.message : 'Não foi possível converter os Pontos.', 'error');
    } finally {
      setConverting(false);
    }
  }

  return (
    <div className="space-y-5 pb-4">
      <header className="pt-2">
        <h1 className="font-display text-h1 text-text">Carteira</h1>
      </header>

      <Card className="text-center !p-6">
        <p className="text-caption text-text-secondary mb-1">Saldo disponível</p>
        <p className="font-display text-highlight text-gold">
          {loading ? '...' : balance.toFixed(2)} <span className="text-h2 font-sans">MZN</span>
        </p>
        <p className="text-caption text-text-secondary mt-2">
          Saque mínimo: {WITHDRAWAL_MIN_MZN.toFixed(2)} MZN — sem teto diário de saque.
        </p>
      </Card>

      {/* Deixa claríssimo, sem ambiguidade: nunca há depósito, nunca há cobrança. */}
      <div className="bg-success/5 border border-success/20 rounded-card p-4 text-center">
        <p className="text-caption text-success font-semibold">
          Você nunca precisa depositar nada. A plataforma nunca cobra valor
          algum de você — o único dinheiro que se move é da plataforma para você,
          quando você solicita um saque do que já ganhou estudando.
        </p>
      </div>

      <Card>
        <div className="flex items-center justify-between mb-3">
          <h2 className="font-display text-h2 text-text">Converter Pontos</h2>
          <span className="text-caption text-text-secondary">
            {pointsBalance} Pontos disponíveis
          </span>
        </div>

        {conversionRate && (
          <p className="text-caption text-text-secondary mb-3">
            Taxa atual: {conversionRate.ratePoints} Pontos = {conversionRate.rateMzn.toFixed(2)} MZN.
            A conversão entra no seu teto de ganho diário, igual a missões e streak.
          </p>
        )}

        <form onSubmit={handleConvert} className="space-y-3">
          <input
            type="number"
            step={conversionRate?.ratePoints ?? 1000}
            min={conversionRate?.ratePoints ?? 1000}
            max={pointsBalance}
            value={pointsToConvert}
            onChange={(e) => setPointsToConvert(e.target.value)}
            className="w-full rounded-button border border-border bg-surface px-4 py-3 text-body text-text focus:border-primary outline-none"
          />

          {!isMultipleOfRate && pointsNumber > 0 && conversionRate && (
            <p className="text-caption text-warning">
              A conversão só pode ser feita em múltiplos de {conversionRate.ratePoints} Pontos.
            </p>
          )}

          {previewMzn !== null && (
            <p className="text-caption text-success">
              Você vai receber {previewMzn.toFixed(2)} MZN na Carteira.
            </p>
          )}

          <SecondaryButton type="submit" loading={converting} disabled={!canConvert} className="w-full">
            Converter em Dinheiro
          </SecondaryButton>
        </form>
      </Card>

      <Card>
        <h2 className="font-display text-h2 text-text mb-3">Solicitar saque</h2>

        {!canWithdraw && !loading && (
          <p className="text-caption text-warning bg-warning/10 rounded-button px-3 py-2 mb-3">
            Você ainda não atingiu o mínimo de {WITHDRAWAL_MIN_MZN.toFixed(2)} MZN para
            solicitar um saque. Continue estudando para acumular mais.
          </p>
        )}

        <form onSubmit={handleWithdraw} className="space-y-3">
          <div className="flex gap-2">
            {['mpesa', 'emola'].map((m) => (
              <button
                type="button"
                key={m}
                onClick={() => setMethod(m)}
                className={`flex-1 rounded-button border py-2 text-button transition-colors duration-micro ${
                  method === m ? 'border-primary bg-primary/10 text-primary' : 'border-border text-text-secondary'
                }`}
              >
                {m === 'mpesa' ? 'M-Pesa' : 'e-Mola'}
              </button>
            ))}
          </div>

          <input
            type="number"
            step="0.01"
            min={WITHDRAWAL_MIN_MZN}
            max={balance ?? undefined}
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
            className="w-full rounded-button border border-border bg-surface px-4 py-3 text-body text-text focus:border-primary outline-none"
          />

          <PrimaryButton type="submit" loading={submitting} disabled={!canWithdraw} className="w-full">
            Solicitar Saque
          </PrimaryButton>
        </form>
      </Card>

      <div>
        <h2 className="font-display text-h2 text-text mb-2">Histórico</h2>
        {loading && <p className="text-caption text-text-secondary">Carregando...</p>}
        {!loading && history.length === 0 && (
          <Card><p className="text-body text-text-secondary">Nenhuma transação ainda.</p></Card>
        )}
        <div className="space-y-2">
          {history.map((t) => (
            <Card key={t.id} className="flex items-center justify-between !py-3">
              <div>
                <p className="text-body text-text capitalize">{t.source.replace(/_/g, ' ')}</p>
                <p className="text-caption text-text-secondary">
                  {new Date(t.createdAt).toLocaleDateString('pt-MZ')}
                </p>
              </div>
              <span className={`font-display font-semibold ${t.type === 'credit' ? 'text-success' : 'text-danger'}`}>
                {t.type === 'credit' ? '+' : '-'}{t.amountMzn.toFixed(2)} MZN
              </span>
            </Card>
          ))}
        </div>
      </div>

      {/* Anúncio Estratégico 4 — Banner Rodapé (Seção 19.6) */}
      <div className="bg-border/40 rounded-card h-16 flex items-center justify-center text-caption text-text-secondary">
        Espaço de anúncio (Banner Rodapé)
      </div>
    </div>
  );
}
