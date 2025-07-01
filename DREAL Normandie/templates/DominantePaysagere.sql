DROP TABLE IF EXISTS paysage."DominantePaysagere" CASCADE ;

-- Création de la table
CREATE TABLE paysage."DominantePaysagere" (
"id" SERIAL,
"DominantePaysagere" VARCHAR
);

-- Insertion de la liste des valeurs
INSERT INTO paysage."DominantePaysagere" ("DominantePaysagere") VALUES
('paysage agricole'),
('paysage boisé'),
('paysage bâti continu'),
('paysage bâti discontinu'),
('paysage d''eau ou humide'),
('paysage d''infrastructures'),
('paysage ouvert naturel'),
('autre'),
(NULL)
;

-- Description de la table
COMMENT ON TABLE paysage."DominantePaysagere" IS 'Caractéristique dominante décrivant l''occupation ou l''usage du sol';

-- Attribution de la clé primaire sur l'id
ALTER TABLE paysage."DominantePaysagere"
ADD PRIMARY KEY ("id")
;
