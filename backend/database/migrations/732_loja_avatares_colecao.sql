-- Migration 732: coleção de avatares da Loja (24 itens, slot "avatar" criado na 730)
-- Preços por faixa: 300 (Épico), 400 (Épico), 500 (Lendário — raridade calculada por rarity.js).
-- As imagens vivem no frontend (frontend/src/assets/avatars/<chave>.webp; o nome do ficheiro é a chave).
-- Os preços podem ser ajustados depois sem recriar nada (UPDATE em shop_items.price_points).

INSERT INTO shop_items (key, category, name, description, price_points, effect_key, eligibility_rule) VALUES
    ('avatar_capuz_real', 'cosmetic', 'Capuz Real', 'Figura encapuzada com boné de coroa dourada.', 400, NULL, NULL),
    ('avatar_mascara_neon', 'cosmetic', 'Máscara Neon', 'Capuz azul e máscara de olhos em X, com brilho neon.', 400, NULL, NULL),
    ('avatar_oni', 'cosmetic', 'Oni Vermelho', 'Máscara de demónio de chifres, num capuz vermelho.', 400, NULL, NULL),
    ('avatar_pantera', 'cosmetic', 'Pantera da Noite', 'Pantera negra de olhos dourados.', 300, NULL, NULL),
    ('avatar_lobo', 'cosmetic', 'Lobo Azul', 'Lobo de olhos azuis sob relâmpagos.', 300, NULL, NULL),
    ('avatar_leao', 'cosmetic', 'Leão Dourado', 'O rei da savana, em tons de ouro e fogo.', 300, NULL, NULL),
    ('avatar_tigre', 'cosmetic', 'Tigre de Fogo', 'Tigre de olhar intenso, rodeado de chamas.', 300, NULL, NULL),
    ('avatar_aguia', 'cosmetic', 'Águia Real', 'Águia de bico dourado e olhar firme.', 300, NULL, NULL),
    ('avatar_dragao', 'cosmetic', 'Dragão Negro', 'Dragão de escamas negras e olhos de brasa.', 500, NULL, NULL),
    ('avatar_montanha_lua', 'cosmetic', 'Montanha ao Luar', 'Montanhas e lago sob a lua cheia.', 300, NULL, NULL),
    ('avatar_lua_vermelha', 'cosmetic', 'Lua Vermelha', 'Cerejeira em flor sob uma lua vermelha.', 300, NULL, NULL),
    ('avatar_onda_lua', 'cosmetic', 'Onda ao Luar', 'Onda azul a rebentar diante da lua.', 300, NULL, NULL),
    ('avatar_coroa_ouro', 'cosmetic', 'Coroa de Ouro', 'Coroa dourada sobre fundo negro.', 500, NULL, NULL),
    ('avatar_dolares', 'cosmetic', 'Maço de Dólares', 'Um maço de notas preso com faixa dourada.', 500, NULL, NULL),
    ('avatar_saco_ouro', 'cosmetic', 'Saco de Ouro', 'Saco de dólares rodeado de moedas de ouro.', 500, NULL, NULL),
    ('avatar_bitcoin', 'cosmetic', 'Bitcoin Dourado', 'Moeda de Bitcoin em ouro.', 500, NULL, NULL),
    ('avatar_supercarro', 'cosmetic', 'Supercarro Dourado', 'Supercarro negro numa cidade de luzes douradas.', 500, NULL, NULL),
    ('avatar_relogio_ouro', 'cosmetic', 'Relógio de Ouro', 'Relógio de ouro, símbolo de status.', 500, NULL, NULL),
    ('avatar_astronauta', 'cosmetic', 'Astronauta Negro', 'Astronauta de capacete espelhado.', 300, NULL, NULL),
    ('avatar_planeta', 'cosmetic', 'Planeta Anelado', 'Planeta de anéis dourados no espaço.', 300, NULL, NULL),
    ('avatar_anjo', 'cosmetic', 'Anjo Encapuzado', 'Figura de capuz com asas e auréola.', 400, NULL, NULL),
    ('avatar_rosa_negra', 'cosmetic', 'Rosa Negra', 'Rosa negra com contornos dourados.', 300, NULL, NULL),
    ('avatar_yin_yang', 'cosmetic', 'Yin-Yang Dourado', 'Yin-yang em fumo e ouro.', 300, NULL, NULL),
    ('avatar_comando_neon', 'cosmetic', 'Comando Neon', 'Comando de jogo com luzes neon roxas.', 300, NULL, NULL)
ON CONFLICT (key) DO NOTHING;
