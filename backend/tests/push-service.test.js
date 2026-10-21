/**
 * pushService (Firebase) sem rede: tokens inválidos são apagados, outras falhas ficam nos logs sem apagar nada,
 * e a chave privada colada no Render (com \n literais ou entre aspas) é normalizada.
 */
jest.mock('../src/common/logger', () => ({ info: jest.fn(), warn: jest.fn(), error: jest.fn() }));
const mockSend = jest.fn();
jest.mock('firebase-admin/app', () => ({
  initializeApp: jest.fn(() => ({ name: 'app' })),
  getApps: jest.fn(() => []),
  getApp: jest.fn(),
  cert: jest.fn((c) => c),
}));
jest.mock('firebase-admin/messaging', () => ({ getMessaging: jest.fn(() => ({ sendEachForMulticast: mockSend })) }));

const ENV = { ...process.env };
function load(env) {
  jest.resetModules();
  Object.assign(process.env, { FIREBASE_PROJECT_ID: '', FIREBASE_CLIENT_EMAIL: '', FIREBASE_PRIVATE_KEY: '' }, env);
  return require('../src/common/notifications/pushService');
}
afterAll(() => { process.env = ENV; });

const creds = { FIREBASE_PROJECT_ID: 'p', FIREBASE_CLIENT_EMAIL: 'e@p.iam.gserviceaccount.com', FIREBASE_PRIVATE_KEY: 'k' };
const repo = (tokens) => ({ listTokensByUser: jest.fn().mockResolvedValue(tokens), deleteTokens: jest.fn() });

beforeEach(() => mockSend.mockReset());

test('sem credenciais do Firebase: não envia e não falha (modo silencioso)', async () => {
  const svc = load({});
  const r = await svc.sendToUser('u1', { title: 't', body: 'b' }, repo([{ token: 'a' }]));
  expect(r).toEqual({ sent: 0, skipped: true });
  expect(mockSend).not.toHaveBeenCalled();
});

test('envia a todos os aparelhos do utilizador e conta os sucessos', async () => {
  const svc = load(creds);
  mockSend.mockResolvedValue({ successCount: 2, responses: [{ success: true }, { success: true }] });
  const r = await svc.sendToUser('u1', { title: 't', body: 'b', data: { n: 1 } }, repo([{ token: 'a' }, { token: 'b' }]));
  expect(r).toEqual({ sent: 2, skipped: false });
  expect(mockSend.mock.calls[0][0].tokens).toEqual(['a', 'b']);
  expect(mockSend.mock.calls[0][0].data).toEqual({ n: '1' });
});

test('token inválido/expirado é apagado; outros ficam', async () => {
  const svc = load(creds);
  const tokens = repo([{ token: 'bom' }, { token: 'morto' }]);
  mockSend.mockResolvedValue({
    successCount: 1,
    responses: [{ success: true }, { success: false, error: { code: 'messaging/registration-token-not-registered' } }],
  });
  await svc.sendToUser('u1', { title: 't', body: 'b' }, tokens);
  expect(tokens.deleteTokens).toHaveBeenCalledWith(['morto']);
});

test('falha que não é token inválido (ex.: credencial) vai para o log e NÃO apaga o token', async () => {
  const svc = load(creds);
  const logger = require('../src/common/logger');
  const tokens = repo([{ token: 'a' }]);
  mockSend.mockResolvedValue({ successCount: 0, responses: [{ success: false, error: { code: 'messaging/third-party-auth-error' } }] });
  const r = await svc.sendToUser('u1', { title: 't', body: 'b' }, tokens);
  expect(r.sent).toBe(0);
  expect(tokens.deleteTokens).not.toHaveBeenCalled();
  expect(logger.warn).toHaveBeenCalledWith(expect.any(String), expect.objectContaining({ userId: 'u1', code: 'messaging/third-party-auth-error' }));
});

test('erro a enviar não rebenta o chamador', async () => {
  const svc = load(creds);
  mockSend.mockRejectedValue(new Error('rede'));
  const r = await svc.sendToUser('u1', { title: 't', body: 'b' }, repo([{ token: 'a' }]));
  expect(r).toMatchObject({ sent: 0, error: 'rede' });
});

test('normalizePrivateKey: \\n literais e aspas', () => {
  const { normalizePrivateKey } = load(creds);
  expect(normalizePrivateKey('-----BEGIN-----\\nabc\\n-----END-----\\n')).toBe('-----BEGIN-----\nabc\n-----END-----\n');
  expect(normalizePrivateKey('"-----BEGIN-----\\nabc"')).toBe('-----BEGIN-----\nabc');
});
