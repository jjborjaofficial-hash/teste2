# Changelog — "Meus Recursos" completo (spec Seções 34-60)

Fecha as lacunas identificadas na auditoria contra o documento enviado
("PÁGINA MEUS RECURSOS / MEU INVENTÁRIO", Seções 34-60).

## 1. Resolvido o desvio de design: itens permanentes agora aparecem aqui

**Antes:** molduras, temas e selos de prestígio ficavam só na Loja/Perfil —
contrariando a Seção 34 ("a página não deve mostrar apenas os itens
comprados na Loja").

**Agora:** `inventoryService.listInventory()` busca e mistura dois mundos:
- itens temporários/consumíveis (`user_inventory`, como já era)
- itens permanentes possuídos (`shopRepository.listOwnedPermanentItemsForInventory`,
  novo) — molduras e temas mostram **Equipar/Desequipar** direto em "Meus
  Recursos" (spec Seção 45); selos de prestígio aparecem como "Permanente",
  sem opção de equipar (não fazem sentido como "vestíveis", só como conquista).

Nenhuma lógica de equipar foi duplicada — o botão na tela nova chama o
mesmo `shopService.equip/unequip` que já existia.

## 2. Categorias visuais (Seção 35)

`resolveDisplayCategory()` mapeia cada item para um dos 5 grupos da spec
(⚡ Boosts, 🛡 Proteção, 🎨 Personalização, 🏆 Competição, 🎁 Eventos), usando
categoria técnica + `effect_key` + origem (itens de evento/campanha sempre
caem em "Eventos", não importa a categoria técnica).

## 3. Ordenação (Seção 49)

Novo parâmetro `?sort=` em `GET /inventory`: `expiry` (padrão, recomendação
da própria spec — ativos com menos tempo primeiro), `recent`, `category`
(agrupa visualmente na tela), `name`.

**Não implementado, por decisão de negócio pendente:** ordenação por
"raridade" (spec Seção 57 também pede um indicador de raridade). Nenhum
documento oficial define quais itens são raros/comuns/épicos — inventar essa
classificação seria decisão de negócio sem aprovação, o que o Manual do
Desenvolvedor proíbe explicitamente. Fica registrado como pendência real,
não implementado por padrão arbitrário.

## 4. Detalhes do item (Seção 46)

Modal de detalhe ao tocar em qualquer card: nome, descrição, status, origem,
"Ativado em" / "Expira em" / "Usado em" (o que se aplicar), quantidade.

## 5. Alerta proativo de expiração (Seção 50)

Novo CRON job `notifyInventoryExpiringSoon.js` (a cada 5 min, já registrado
no worker BullMQ): avisa quando um item ativo expira em até 15 minutos.
Coluna nova `expiry_alert_sent` garante um único aviso por item, nunca
repetido — como a spec pede. **A contagem/expiração em si não depende desse
aviso** (continua funcionando via `expireInventoryItems.js` mesmo se a
notificação falhar).

## 6. Origens expandidas (Seção 47)

`user_inventory.source` aceita agora também `quiz`, `campaign`, `reward`,
além de `shop`, `mission`, `event`, `admin`, `system` — nenhum fluxo atual
usa as três novas ainda (Quiz não concede itens de inventário hoje, só
XP/Pontos), mas o schema já suporta, sem quebrar nada existente.

## Arquivos novos
- `database/migrations/030_inventory_gaps_meus_recursos.sql`
- `src/cron/jobs/notifyInventoryExpiringSoon.js`

## Arquivos modificados
- `src/modules/shop/repositories/shopRepository.js` (+ `listOwnedPermanentItemsForInventory`)
- `src/modules/shop/repositories/inventoryRepository.js` (+ alerta de expiração)
- `src/modules/shop/services/inventoryService.js` (merge + categorias + ordenação — reescrito)
- `src/modules/shop/controllers/inventoryController.js` (parâmetro `?sort=`)
- `src/modules/notifications/services/notificationsService.js` (+ `notifyItemExpiringSoon`)
- `src/queue/definitions.js` (novo job agendado)
- `frontend/src/pages/MeusRecursos.jsx` (reescrita completa)
- `frontend/src/api/inventoryApi.js` (+ parâmetro de ordenação)
- `tests/shop.test.js` (+ 1 caso de teste)

## 3. Raridade — implementada após aprovação explícita

**Atualização:** a pendência de raridade (abaixo) foi resolvida depois desta
entrega. Ver `CHANGELOG_raridade.md` para os detalhes: raridade calculada
automaticamente por faixa de preço + `eligibility_rule`, aprovada pelo
proprietário do projeto (não é mais uma lacuna).

## Pendência explícita (não implementada, precisa de decisão sua) — RESOLVIDA
~~**Indicador de raridade** (Seção 57): requer decidir, item por item, o que
é raro/comum — dado de negócio que não está em nenhum documento oficial.~~
