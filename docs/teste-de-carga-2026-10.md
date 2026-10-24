# Teste de carga — 24/10/2026

**Método:** backend local com a base de TESTES, limitado a 10% de um núcleo (a Render gratuita dá 0,1 CPU). Scripts em `backend/scripts/load-test/`. Não foi feito contra produção (a rede da sessão não chega lá e não se deve sobrecarregar utilizadores reais). **Limitações:** CPU da máquina de teste (não da Render); o limite por SIGSTOP/SIGCONT é, no máximo, ~2x mais generoso do que a quota real; base local (0,2 ms por consulta; o Neon de Frankfurt são ~2 ms, o que acrescenta ~10 a 40 ms por pedido). Tratar os números como ordem de grandeza.

## 1. Custo de CPU por pedido (sem limite, média)
| Pedido | CPU por pedido |
|---|---|
| **Login (bcrypt, custo 12)** | **258 ms** |
| Registo (também bcrypt) | ~258 ms (mesma conta) |
| `GET /missions` | 5,1 ms |
| `POST /quiz/answers` | 6,0 ms |
| `POST /quiz/rounds` | 5,2 ms |
| `GET /users/me`, `/gamification/me`, `/wallet`, pergunta | 2,5 a 2,8 ms |
| `GET /quiz/categories` | 1,7 ms |
| **Servidor parado** | **~16 ms por segundo** (16% do orçamento de 0,1 CPU só para existir) |
Memória: ~114 MB (limite do plano gratuito 512 MB): não é problema.

## 2. Uso normal com 10% de CPU (todos começam ao mesmo tempo: pior caso)
| Utilizadores | Painel (`/me`, `/missions`) p95 | Quiz (pergunta e resposta) p95 | Erros |
|---|---|---|---|
| 25 | até 1,7 s | 0,3 a 0,5 s | 0 |
| 50 | até 2,9 s | 0,3 a 0,4 s | 0 |
| 100 | **5,6 a 8,2 s** | 0,6 a 1,4 s | 0 |
| 150 | **9,5 a 13,5 s** | 2,3 a 2,8 s | 0 |
(Os "422" que apareceram eram da forma como o teste reaproveitava utilizadores com uma rodada a meio; não são erros do servidor.) Com 100 ou mais o pool de 20 ligações à base enche (mais de 50 consultas à espera).

## 3. Muitos logins ao mesmo tempo
10 logins simultâneos: o último demora 12 s; 25 logins: 30 s (medido, cerca de 1,2 s cada). Pelo cálculo (258 ms de CPU contra 100 ms de CPU por segundo) na Render real é **cerca de 2,6 s por login, ou ~23 logins por minuto**, e o 25.º utilizador esperaria mais de um minuto.

## 4. Conclusões
- **Confortável:** até cerca de **30 a 50 pessoas ativas ao mesmo tempo**. Com 100 o painel inicial fica lento (vários segundos) mas o quiz ainda responde; com 150 degrada. Cada pessoa ativa gera um pedido a cada 3 a 4 s.
- **O maior risco são os logins e registos** (bcrypt 12 = 100 vezes mais caro que qualquer outro pedido). Uma turma ou uma campanha a entrar ao mesmo tempo bloqueia o servidor durante muito tempo, e atrasa também quem já está a jogar. Quem já tem sessão não paga isto (o cookie de sessão dura dias).
- **Possíveis melhorias (nenhuma feita, decidir com o dono):** (a) baixar o custo do bcrypt de 12 para 10 ou 11 (4x ou 2x mais barato; 10 ainda é o mínimo aceitável; as senhas antigas continuam a funcionar; é uma decisão de segurança); (b) `GET /missions` é a leitura mais pesada e a mais lenta no painel: otimizar; (c) o servidor parado já gasta 16% do orçamento (agendador interno e fila): reduzir; (d) plano pago da Render (0,5 CPU = ~5x mais capacidade; é a solução simples); (e) o pool de ligações (20) pode ser pequeno com 100+ pessoas.
