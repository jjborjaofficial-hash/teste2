-- Migration 730: Loja de avatares (imagem de perfil comprável com Pontos)
-- Novo tipo de cosmético: o slot "avatar" (chaves `avatar_...`), ao lado de
-- moldura (`frame_...`) e tema (`theme_...`). Equipar é grátis depois de
-- comprar; a imagem em si vive no frontend (frontend/src/assets/avatars).
-- Primeiro item: avatar do Naruto, 500 Pontos. Preço e disponibilidade podem
-- ser ajustados depois pelo Painel Administrativo, sem deploy.

ALTER TABLE users ADD COLUMN IF NOT EXISTS equipped_avatar_image VARCHAR(40);

INSERT INTO shop_items (key, category, name, description, price_points, effect_key, eligibility_rule) VALUES
    (
        'avatar_naruto', 'cosmetic', 'Avatar Naruto',
        'Troque a sua imagem de perfil por este avatar exclusivo, que aparece no seu perfil e no ranking.',
        500, NULL, NULL
    )
ON CONFLICT (key) DO NOTHING;
