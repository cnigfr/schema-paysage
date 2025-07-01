DROP TABLE IF EXISTS paysage."TypeOrographie" CASCADE ;

-- Création de la table
CREATE TABLE paysage."TypeOrographie" (
"id" SERIAL,
"TypeOrographie" VARCHAR
);

-- Insertion de la liste des valeurs
INSERT INTO paysage."TypeOrographie" ("TypeOrographie") VALUES
('maritime'),
('insulaire'),
('littoral'),
('lacustre'),
('coursEau'),
('vallee'),
('plaine'),
('plateau'),
('coteau'),
('montagne'),
('autreReliefMarque'),
(NULL)
;

-- Description de la table
COMMENT ON TABLE paysage."TypeOrographie" IS 'Caractéristique dominante de l’unité paysagère selon des critères orographiques ou géomorphologiques';

-- Attribution de la clé primaire sur l'id
ALTER TABLE paysage."TypeOrographie"
ADD PRIMARY KEY ("id")
;