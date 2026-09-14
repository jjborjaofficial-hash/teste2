import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { PrimaryButton, SecondaryButton } from '../components/Button';
import { XpIcon } from '../icons';
import { LivePlatformStats } from '../components/LivePlatformStats';

/**
 * Onboarding Persuasivo (Doc. Mestre Seção 19.1).
 * Sequência de 3 telas (estilo stories) com persuasão sutil, seguida da
 * Bifurcação de Entrada (Entrar / Criar Nova Conta) e da Prova Social.
 * Textos são os mesmos especificados literalmente na Seção 19.1 do Doc. Mestre
 * (copy oficial do produto, não texto de terceiros).
 */
const slides = [
  {
    title: 'O seu tempo na internet vale muito.',
    body: 'O seu conhecimento vale mais ainda. Transforme seus minutos livres em evolução.',
  },
  {
    title: 'Estude apenas alguns minutos por dia.',
    body: 'Responda a quizzes rápidos sobre Finanças e Tecnologia e seja recompensado.',
  },
  {
    title: 'Junte-se a outros estudantes em Moçambique.',
    body: 'O progresso é seu, a recompensa também. Saques rápidos e automáticos via M-Pesa e e-Mola.',
  },
];

export function Onboarding() {
  const [step, setStep] = useState(0);
  const navigate = useNavigate();
  const isLastSlide = step === slides.length - 1;

  function next() {
    if (isLastSlide) {
      setStep(slides.length); // avança para a bifurcação
    } else {
      setStep((s) => s + 1);
    }
  }

  const showBifurcation = step >= slides.length;

  return (
    <div className="min-h-screen bg-background flex flex-col">
      <div className="flex-1 flex flex-col justify-center px-6 max-w-md mx-auto w-full">
        {!showBifurcation ? (
          <>
            <div className="flex gap-1 mb-8">
              {slides.map((_, i) => (
                <div
                  key={i}
                  className={`h-1 flex-1 rounded-full transition-colors duration-micro ${
                    i <= step ? 'bg-primary' : 'bg-border'
                  }`}
                />
              ))}
            </div>

            <div className="flex justify-center mb-8">
              <div className="w-20 h-20 rounded-full bg-primary/10 flex items-center justify-center">
                <XpIcon className="w-10 h-10 text-primary" />
              </div>
            </div>

            <h1 className="font-display text-h1 text-text text-center mb-3">
              {slides[step].title}
            </h1>
            <p className="text-body text-text-secondary text-center mb-10">
              {slides[step].body}
            </p>

            <PrimaryButton onClick={next} className="w-full">
              {isLastSlide ? 'Começar' : 'Continuar'}
            </PrimaryButton>
          </>
        ) : (
          <div className="animate-pop-in">
            <h1 className="font-display text-h1 text-text text-center mb-2">
              Aprenda e Ganhe
            </h1>
            <p className="text-body text-text-secondary text-center mb-8">
              Transforme seu progresso em recompensas.
            </p>

            <div className="bg-gold/10 rounded-card p-4 text-center mb-8">
              <LivePlatformStats />
            </div>

            <div className="flex gap-3">
              <SecondaryButton onClick={() => navigate('/entrar')} className="flex-1">
                Entrar
              </SecondaryButton>
              <PrimaryButton onClick={() => navigate('/cadastro')} className="flex-1">
                Criar Conta
              </PrimaryButton>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
