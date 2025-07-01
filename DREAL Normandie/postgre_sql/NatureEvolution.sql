DROP TABLE IF EXISTS paysage."NatureEvolution" CASCADE ;

-- Création de la table
CREATE TABLE paysage."NatureEvolution" (
"id" SERIAL,
"NatureEvolution" VARCHAR
);

-- Insertion de la liste des valeurs
INSERT INTO paysage."NatureEvolution" ("NatureEvolution") VALUES
('apparition'),
('augmentation'),
('disparition'),
('diminution'),
('stabilisation'),
(NULL)
;

-- Description de la table
COMMENT ON TABLE paysage."NatureEvolution" IS 'Evolution de la dynamique paysagère';

-- Attribution de la clé primaire sur l'id
ALTER TABLE paysage."NatureEvolution"
ADD PRIMARY KEY ("id")
;
