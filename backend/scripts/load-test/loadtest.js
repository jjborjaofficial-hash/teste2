const fs = require('fs');
const { spawn } = require('child_process');
const { call, pct } = require('./common');
const phones = JSON.parse(fs.readFileSync('phones.json'));
const PID = Number(fs.readFileSync('server.pid', 'utf8'));
const V = Number(process.argv[2]); const DUR = Number(process.argv[3] || 60) * 1000; const MODE = process.argv[4] || 'usage';
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const rnd = (a, b) => a + Math.random() * (b - a);
const stats = {}; const rec = (name, r) => { (stats[name] ||= { lat: [], bad: 0, codes: {} }); stats[name].lat.push(r.ms); if (r.status >= 400 || r.status < 0) { stats[name].bad++; stats[name].codes[r.status] = (stats[name].codes[r.status] || 0) + 1; } };
let throttler = null;
const startThrottle = () => { throttler = spawn('python3', ['throttle.py', String(PID), '0.10'], { stdio: 'ignore' }); };
const stopThrottle = async () => { if (throttler) { throttler.kill('SIGTERM'); throttler = null; await sleep(300); try { process.kill(PID, 'SIGCONT'); } catch {} } };
async function loginAll() { const t = []; for (let i = 0; i < V; i++) { const r = await call('POST', '/api/v1/auth/login', { phone: phones[i], password: 'Teste12345' }); t[i] = r.json?.data?.accessToken; } return t; }
(async () => {
  console.log(`== ${MODE}: ${V} utilizadores, ${DUR / 1000}s, servidor a 10% de CPU`);
  if (MODE === 'usage') {
    const tokens = await loginAll(); // sem limite (preparação)
    startThrottle(); await sleep(500);
    const end = Date.now() + DUR;
    const user = async (i) => {
      const tk = tokens[i]; await sleep(rnd(0, 3000));
      for (const [n, p] of [['me', '/api/v1/users/me'], ['gamification', '/api/v1/gamification/me'], ['missoes', '/api/v1/missions'], ['carteira', '/api/v1/wallet'], ['categorias', '/api/v1/quiz/categories']]) { rec(n, await call('GET', p, null, tk)); await sleep(200); }
      const cats = (await call('GET', '/api/v1/quiz/categories', null, tk)).json?.data; const catId = Array.isArray(cats) ? cats[i % cats.length].id : null;
      let round = null, answered = 0;
      while (Date.now() < end) {
        if (!round || answered >= 10) { const r = await call('POST', '/api/v1/quiz/rounds', { categoryId: catId }, tk); rec('iniciar rodada', r); round = r.json?.data?.round?.id || r.json?.data?.id || r.json?.data?.roundId; answered = 0; if (!round) { await sleep(2000); continue; } }
        const q = await call('GET', `/api/v1/quiz/rounds/${round}/question`, null, tk); rec('pergunta', q);
        const qd = q.json?.data; if (!qd?.alternatives) { round = null; await sleep(1000); continue; }
        await sleep(rnd(4000, 8000)); // tempo a pensar
        const a = await call('POST', '/api/v1/quiz/answers', { questionId: qd.id || qd.questionId, alternativeId: qd.alternatives[Math.floor(Math.random() * qd.alternatives.length)].id, roundId: round }, tk); rec('responder', a); answered++;
        await sleep(rnd(1500, 3000));
      }
    };
    await Promise.all(Array.from({ length: V }, (_, i) => user(i)));
  } else { // logins ao mesmo tempo
    startThrottle(); await sleep(500);
    const t0 = performance.now(); const done = [];
    await Promise.all(Array.from({ length: V }, async (_, i) => { const r = await call('POST', '/api/v1/auth/login', { phone: phones[i], password: 'Teste12345' }); rec('login', r); done.push(performance.now() - t0); }));
    console.log('todos ligados ao fim de', Math.round((performance.now() - t0) / 1000), 's');
  }
  await stopThrottle();
  for (const [n, s] of Object.entries(stats)) console.log(`${n.padEnd(15)} n=${String(s.lat.length).padStart(4)}  p50=${String(Math.round(pct(s.lat, 50))).padStart(6)}ms  p95=${String(Math.round(pct(s.lat, 95))).padStart(6)}ms  erros=${s.bad} ${JSON.stringify(s.codes)}`);
  process.exit(0);
})().catch(async (e) => { console.error(e); await stopThrottle(); process.exit(1); });
