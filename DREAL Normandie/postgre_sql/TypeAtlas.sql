DROP TABLE IF EXISTS paysage."TypeAtlas" CASCADE ;

-- Création de la table DocumentPaysage
CREATE TABLE paysage."TypeAtlas" (
"id" SERIAL,
"TypeAtlas" VARCHAR
);

-- Insertion de la liste des valeurs
INSERT INTO paysage."TypeAtlas" ("TypeAtlas") VALUES
('departement'),
('region'),
('parcNaturel'),
('autre'),
(NULL)
;

-- Description de la table
COMMENT ON TABLE paysage."TypeAtlas" IS 'Niveau administratif de l’atlas correspondant au jeu de données';

-- Attribution de la clé primaire sur l'id
ALTER TABLE paysage."TypeAtlas"
ADD PRIMARY KEY ("id")
;
