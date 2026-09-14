# Changelog — Raridade dos itens (spec "Meus Recursos" Seção 57)

## Decisão de negócio (aprovada explicitamente, não inventada)

Faixas de preço em Pontos aprovadas pelo proprietário do projeto:

| Raridade | Regra |
|---|---|
| Comum | sem `eligibility_rule` e preço < 100 Pontos |
| Raro | sem `eligibility_rule` e preço 100–199 |
| Épico | preço 200–499, OU tem `eligibility_rule` (qualquer preço abaixo de 500) |
| Lendário | preço ≥ 500 (sempre, mesmo com `eligibility_rule`) |

Calculada automaticamente a partir de dados que já existem em `shop_items`
— nenhum item precisa ser classificado manualmente, inclusive itens novos
criados depois pelo Painel Admin já nascem com raridade correta.

Validado contra 100% do catálogo já seedado (migrations 020/023/026):
Streak Shield e Proteção de Streak → Comum; Coin Boost e as 6 molduras →
Raro; Tema Noite, Recuperar Streak, Moldura de Campeão e Selo Top 10 →
Épico; Selo Lenda dos 100 Dias → Lendário (que a própria descrição do item
já chamava de "o selo mais raro da plataforma" — a fórmula confirma isso
sozinha, sem precisar de ajuste manual).

## Arquivos novos
- `src/modules/shop/rarity.js` — função pura `resolveRarity(pricePoints, eligibilityRule)`,
  compartilhada entre Loja e "Meus Recursos" (mesmo item = mesma raridade nos dois lugares)

## Arquivos modificados
- `src/modules/shop/repositories/inventoryRepository.js` (+ `price_points`, `eligibility_rule` no SELECT)
- `src/modules/shop/repositories/shopRepository.js` (idem, para itens permanentes)
- `src/modules/shop/services/inventoryService.js` (+ campo `rarity` em cada item, + ordenação por raridade)
- `src/modules/shop/services/shopService.js` (+ campo `rarity` no catálogo da Loja)
- `frontend/src/pages/MeusRecursos.jsx` (badge de raridade + opção "Raridade" no seletor de ordenação)
- `frontend/src/pages/Shop.jsx` (badge de raridade nos cards da Loja, para consistência visual)

## Não há mais pendência da Seção 57
A única lacuna registrada na entrega anterior (`CHANGELOG_meus_recursos_completo.md`)
está resolvida.
