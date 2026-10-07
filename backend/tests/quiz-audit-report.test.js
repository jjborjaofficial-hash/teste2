/** Teste unitário (sem banco) da auditoria completa do banco de perguntas (BE-003, P12). */
const { buildAudit, formatAuditText, checkIntegrity } = require('../src/modules/quiz/validation/auditReport');

const mk = (id, statement, labels, correctIdx, group = 'T | easy') => ({
  id,
  statement,
  group,
  alternatives: labels.map((label, i) => ({ label, is_correct: i === correctIdx })),
});

const good = (i, pos = i % 4) =>
  mk(`g${i}`, `Pergunta número ${i} sobre tema ${i * 7}`, ['Guardar dinheiro', 'Gastar tudo hoje', 'Pedir emprestado', 'Ignorar o orçamento'], pos);

describe('auditoria completa (P12)', () => {
  test('banco limpo: sem defeitos graves', () => {
    const a = buildAudit(Array.from({ length: 8 }, (_, i) => good(i)));
    expect(a.total).toBe(8);
    expect(a.strictFailures).toBe(0);
    expect(a.integrity).toEqual([]);
    expect(a.duplicates.exactGroups).toEqual([]);
  });

  test('conta defeitos graves: integridade, duplicada exata e "todas as anteriores"', () => {
    const broken = mk('b1', 'Pergunta quebrada', ['Só uma', 'Outra'], 0);
    broken.alternatives[1].is_correct = true; // duas corretas
    const qs = [
      good(1),
      mk('d1', 'O que é inflação?', ['Subida geral dos preços', 'Queda dos juros', 'Aumento do emprego', 'Corte de impostos'], 0),
      mk('d2', 'o que e inflacao', ['Subida geral dos preços', 'Queda dos juros', 'Aumento do emprego', 'Corte de impostos'], 0),
      mk('t1', 'Qual destas é uma poupança?', ['Fundo de emergência', 'Dívida cara', 'Multa fixa', 'Todas as anteriores'], 3),
      broken,
    ];
    const a = buildAudit(qs);
    expect(a.strictBreakdown).toEqual({ integridade: 1, enunciadosDuplicadosExatos: 1, todasOuNenhumaDasAnteriores: 1 });
    expect(a.strictFailures).toBe(3);
    expect(a.integrity[0]).toMatchObject({ id: 'b1', codes: ['corretas_2'] });
  });

  test('checkIntegrity apanha opção vazia e enunciado vazio', () => {
    const p = checkIntegrity([mk('x', '  ', ['a', ' ', 'c'], 0)]);
    expect(p[0].codes).toEqual(expect.arrayContaining(['alternativa_vazia', 'enunciado_vazio']));
  });

  test('o texto do relatório traz as 5 secções e a linha de defeitos graves', () => {
    const txt = formatAuditText(buildAudit(Array.from({ length: 6 }, (_, i) => good(i))), { list: true });
    ['1) Tamanho', '2) Viés', '3) Perguntas duplicadas', '4) Posição', '5) Integridade', 'DEFEITOS GRAVES'].forEach((s) => expect(txt).toContain(s));
  });

  test('a medição histórica do validador não muda (summarize continua igual)', () => {
    const a = buildAudit([mk('a', 'Enunciado A longo o bastante', ['Resposta bem comprida e detalhada aqui', 'No', 'Ok', 'Sim'], 0)]);
    expect(a.validator.longestSharePct).toBe(100);
    expect(a.validator.failingCount).toBe(1);
  });
});
