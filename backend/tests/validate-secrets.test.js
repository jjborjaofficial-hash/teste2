const { findJwtSecretProblems } = require('../src/config/validateSecrets');

const good = 'a'.repeat(40);
const good2 = 'b'.repeat(40);

describe('findJwtSecretProblems', () => {
  it('fora de produção não exige nada', () => {
    expect(findJwtSecretProblems({ NODE_ENV: 'development' })).toEqual([]);
    expect(findJwtSecretProblems({ NODE_ENV: 'test', JWT_ACCESS_SECRET: 'x' })).toEqual([]);
  });

  it('em produção aceita segredos longos e diferentes', () => {
    expect(
      findJwtSecretProblems({ NODE_ENV: 'production', JWT_ACCESS_SECRET: good, JWT_REFRESH_SECRET: good2 })
    ).toEqual([]);
  });

  it('em produção recusa vazio, valor de exemplo, curto e iguais', () => {
    const empty = findJwtSecretProblems({ NODE_ENV: 'production' });
    expect(empty).toHaveLength(2);

    const placeholder = findJwtSecretProblems({
      NODE_ENV: 'production',
      JWT_ACCESS_SECRET: 'troque_este_valor_em_producao',
      JWT_REFRESH_SECRET: good2,
    });
    expect(placeholder.join(' ')).toMatch(/valor de exemplo/);

    const short = findJwtSecretProblems({
      NODE_ENV: 'production',
      JWT_ACCESS_SECRET: 'abc123',
      JWT_REFRESH_SECRET: good2,
    });
    expect(short.join(' ')).toMatch(/curto demais/);

    const same = findJwtSecretProblems({
      NODE_ENV: 'production',
      JWT_ACCESS_SECRET: good,
      JWT_REFRESH_SECRET: good,
    });
    expect(same.join(' ')).toMatch(/não podem ser iguais/);
  });
});
