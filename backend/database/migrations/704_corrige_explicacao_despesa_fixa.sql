-- Corrige a EXPLICAÇÃO de uma pergunta de Finanças (aprovado pelo dono em 2026-10-17).
-- Motivo: a migration 700 trocou a alternativa errada "Compra ocasional de roupa" por "Compra de roupa", e a explicação
-- ainda citava o texto antigo. A resposta CERTA ("Aluguel") e as alternativas NÃO mudam; só a frase da explicação.
-- Segurança: só mexe se o texto atual ainda for exatamente o original (idempotente; não sobrescreve edição posterior).
DO $$
DECLARE
  v_updated INTEGER;
BEGIN
  UPDATE questions
  SET explanation = 'Despesa fixa é a que se repete em todo período com o mesmo valor, como o aluguel. Lanche eventual, passeio e compra de roupa são despesas variáveis, porque mudam de um mês para outro.'
  WHERE source = 'seed_financas_facil_v1'
    AND statement = 'Qual destes é um exemplo de despesa fixa?'
    AND explanation = 'Despesa fixa é a que se repete em todo período com o mesmo valor, como o aluguel. Lanche eventual, passeio e compra ocasional de roupa são despesas variáveis, porque mudam de um mês para outro.';
  GET DIAGNOSTICS v_updated = ROW_COUNT;
  RAISE NOTICE 'Explicação despesa fixa corrigida: % pergunta(s) (esperado: 1).', v_updated;
END $$;
