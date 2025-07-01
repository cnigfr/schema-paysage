DROP TABLE IF EXISTS paysage."NatureLimite" CASCADE ;

-- Création de la table
CREATE TABLE paysage."NatureLimite" (
"id" SERIAL,
"NatureLimite" VARCHAR
);

-- Insertion de la liste des valeurs
INSERT INTO paysage."NatureLimite" ("NatureLimite") VALUES
('front urbain'),
('horizon en mer'),
('ligne de crête'),
('limite administrative'),
('rupture de pente'),
('thalweg'),
('autre'),
(NULL)
;

-- Description de la table
COMMENT ON TABLE paysage."NatureLimite" IS 'La limite du découpage paysager';

-- Attribution de la clé primaire sur l'id
ALTER TABLE paysage."NatureLimite"
ADD PRIMARY KEY ("id")
;
