const BASE = 'http://127.0.0.1:3300';
let ipSeq = 1;
const uniqueIp = () => `10.${(ipSeq >> 16) & 255}.${(ipSeq >> 8) & 255}.${ipSeq++ & 255}`;
async function call(method, path, body, token) {
  const t0 = performance.now();
  let status = 0, json = null;
  try {
    const res = await fetch(BASE + path, {
      method,
      headers: { 'content-type': 'application/json', 'x-forwarded-for': uniqueIp(), ...(token ? { authorization: `Bearer ${token}` } : {}) },
      body: body ? JSON.stringify(body) : undefined,
    });
    status = res.status;
    json = await res.json().catch(() => null);
  } catch (e) { status = -1; }
  return { ms: performance.now() - t0, status, json };
}
function pct(arr, p) { if (!arr.length) return 0; const s = [...arr].sort((a, b) => a - b); return s[Math.min(s.length - 1, Math.floor((p / 100) * s.length))]; }
module.exports = { call, pct, BASE };
