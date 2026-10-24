const fs = require('fs');
const { call, pct } = require('./common');
const PID = Number(fs.readFileSync('server.pid', 'utf8'));
const TICK = 100; // CLK_TCK
const cpuMs = () => { const f = fs.readFileSync(`/proc/${PID}/stat`, 'utf8').split(') ')[1].split(' '); return ((Number(f[11]) + Number(f[12])) / TICK) * 1000; };
const phones = JSON.parse(fs.readFileSync('phones.json'));
(async () => {
  const out = {};
  const measure = async (name, n, fn) => {
    const c0 = cpuMs(); const lat = []; let bad = 0;
    for (let i = 0; i < n; i++) { const r = await fn(i); lat.push(r.ms); if (r.status >= 400 || r.status < 0) bad++; }
    const c1 = cpuMs();
    out[name] = { n, cpuMsPerReq: +((c1 - c0) / n).toFixed(1), p50: Math.round(pct(lat, 50)), p95: Math.round(pct(lat, 95)), erros: bad };
    console.log(name, JSON.stringify(out[name]));
  };
  const idle0 = cpuMs(); await new Promise((r) => setTimeout(r, 5000)); console.log('CPU parado em 5 s (ms):', (cpuMs() - idle0).toFixed(0));
  const tokens = [];
  await measure('login (bcrypt)', 30, async (i) => { const r = await call('POST', '/api/v1/auth/login', { phone: phones[i], password: 'Teste12345' }); if (r.json?.data?.accessToken) tokens[i] = r.json.data.accessToken; return r; });
  const T = (i) => tokens[i % tokens.length];
  await measure('GET /users/me', 80, (i) => call('GET', '/api/v1/users/me', null, T(i)));
  await measure('GET /gamification/me', 80, (i) => call('GET', '/api/v1/gamification/me', null, T(i)));
  await measure('GET /missions', 80, (i) => call('GET', '/api/v1/missions', null, T(i)));
  await measure('GET /wallet', 80, (i) => call('GET', '/api/v1/wallet', null, T(i)));
  const cats = (await call('GET', '/api/v1/quiz/categories', null, T(0))).json?.data;
  const catId = Array.isArray(cats) ? cats[0].id : cats?.categories?.[0]?.id;
  await measure('GET /quiz/categories', 60, (i) => call('GET', '/api/v1/quiz/categories', null, T(i)));
  const rounds = [];
  await measure('POST /quiz/rounds (iniciar rodada)', 25, async (i) => { const r = await call('POST', '/api/v1/quiz/rounds', { categoryId: catId }, T(i)); rounds[i] = r.json?.data?.round?.id || r.json?.data?.id || r.json?.data?.roundId; return r; });
  const qs = [];
  await measure('GET pergunta da rodada', 25, async (i) => { const r = await call('GET', `/api/v1/quiz/rounds/${rounds[i]}/question`, null, T(i)); qs[i] = r.json?.data; return r; });
  await measure('POST /quiz/answers (responder)', 25, (i) => {
    const q = qs[i]; const alt = q?.alternatives?.[0]?.id;
    return call('POST', '/api/v1/quiz/answers', { questionId: q?.id || q?.questionId, alternativeId: alt, roundId: rounds[i] }, T(i));
  });
  fs.writeFileSync('cpu-result.json', JSON.stringify(out, null, 2));
})();
