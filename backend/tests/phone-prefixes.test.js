const { detectPhoneProvider, phoneRegex, PHONE_HELP } = require('../src/common/phone');

describe('prefixos dos números de Moçambique', () => {
  it('Vodacom 84/85 = M-Pesa; Movitel 86/87/88 = e-Mola', () => {
    expect(detectPhoneProvider('841234567')).toBe('mpesa');
    expect(detectPhoneProvider('851234567')).toBe('mpesa');
    expect(detectPhoneProvider('861234567')).toBe('emola');
    expect(detectPhoneProvider('871234567')).toBe('emola');
    expect(detectPhoneProvider('881234567')).toBe('emola');
    expect(detectPhoneProvider('821234567')).toBeNull();
    expect(detectPhoneProvider('891234567')).toBeNull();
  });

  it('a validação aceita 88 e recusa prefixos desconhecidos e tamanhos errados', () => {
    expect(phoneRegex.test('881234567')).toBe(true);
    expect(phoneRegex.test('891234567')).toBe(false);
    expect(phoneRegex.test('83123456')).toBe(false);
    expect(phoneRegex.test('8812345678')).toBe(false);
    expect(PHONE_HELP).toMatch(/86\/87\/88/);
  });
});
