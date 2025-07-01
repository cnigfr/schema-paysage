DROP TABLE IF EXISTS paysage."ObjetEvolution" CASCADE ;

-- Création de la table
CREATE TABLE paysage."ObjetEvolution" (
"id" SERIAL,
"ObjetEvolution" VARCHAR
);

-- Insertion de la liste des valeurs
INSERT INTO paysage."ObjetEvolution" ("ObjetEvolution") VALUES
('autres formations herbacées'),
('bananiers, palmiers et bambous'),
('eaux continentales'),
('eaux maritimes'),
('écosystème marin fixe'),
('énergie'),
('formations arborées'),
('formations arbustives'),
('formations herbacées'),
('fourrés'),
('haies et formations arbustives organisées'),
('landes'),
('lichens et mousses'),
('matériaux composites'),
('matériaux minéraux'),
('névés et glaciers'),
('pelouses et prairies urbaines'),
('pelouses naturelles'),
('peuplement de conifères'),
('peuplement de feuillus'),
('pollution lumineuse'),
('prairies naturelles'),
('sols nus'),
('terres arables'),
('trait de côte'),
('végétation sclérophylle'),
('vignes'),
('zones bâties'),
('zones imperméables'),
('zones non bâties'),
('autre'),
(NULL)
;

-- Description de la table
COMMENT ON TABLE paysage."ObjetEvolution" IS 'Caractéristique paysagère sur laquelle porte l’évolution';

-- Attribution de la clé primaire sur l'id
ALTER TABLE paysage."ObjetEvolution"
ADD PRIMARY KEY ("id")
;
