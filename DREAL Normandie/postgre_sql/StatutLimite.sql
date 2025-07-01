DROP TABLE IF EXISTS paysage."StatutLimite" CASCADE ;

-- Création de la table
CREATE TABLE paysage."StatutLimite" (
"id" SERIAL,
"StatutLimite" VARCHAR
);

-- Insertion de la liste des valeurs
INSERT INTO paysage."StatutLimite" ("StatutLimite") VALUES
('limiteFranche'),
('limiteFloue'),
(NULL)
;

-- Description de la table
COMMENT ON TABLE paysage."StatutLimite" IS 'Evolution de la dynamique paysagère';

-- Attribution de la clé primaire sur l'id
ALTER TABLE paysage."StatutLimite"
ADD PRIMARY KEY ("id")
;
