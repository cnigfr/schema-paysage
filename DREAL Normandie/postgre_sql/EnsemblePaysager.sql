DROP TABLE IF EXISTS paysage."EnsemblePaysager" CASCADE ;

-- Création de la table EnsemblePaysager
CREATE TABLE paysage."EnsemblePaysager" (
    "id" SERIAL,
    "identifiantLocal" VARCHAR,
    "identifiantGlobal" VARCHAR,
    "nom" VARCHAR,
    "lienPageAtlas" VARCHAR,
    "motClefGenerique" VARCHAR,
    "motClefToponymique" VARCHAR,
    "description" VARCHAR,
    "image" VARCHAR,
    "dateDefinition" VARCHAR,
    "dateActualisation" VARCHAR,
    "lienAtlasPaysage" VARCHAR,
    "codeDepartement" VARCHAR,
    "codeRegion" VARCHAR,
    "opSaisie" VARCHAR,
	"dateCrea" VARCHAR,
	"dateModif" VARCHAR,
    "valid" BOOLEAN DEFAULT FALSE,
	"geometrie" GEOMETRY(MultiPolygon, 2154),
	"etiquette" VARCHAR
);

-- Description de la table
COMMENT ON TABLE paysage."EnsemblePaysager" IS 'Un ensemble paysager est observé à l’échelle d’un territoire régional. Il est issu de l’association de plusieurs unités paysagères dont les caractéristiques géomorphologiques, écologiques, d’occupation du sol et de perception des habitants et des acteurs sont cohérentes à l’échelle dézoomée du territoire régional. Comme pour les unités paysagères, les limites entre ensembles paysagers peuvent être nettes ou « floues ». Cette nomination « EP » englobe celles parfois usitées telles que « grands paysages », « grands ensembles paysagers », « grandes entités paysagères », etc';

-- Description de chaque champ composant la table
COMMENT ON COLUMN paysage."EnsemblePaysager"."id" IS 'Identifiant unique servant de clé primaire pour la structure locale';
COMMENT ON COLUMN paysage."EnsemblePaysager"."identifiantLocal" IS 'Chaîne de caractères identifiant de façon unique l''unité paysagère au sein de sa classe et du jeu de données dans lesquels il a été défini';
COMMENT ON COLUMN paysage."EnsemblePaysager"."identifiantGlobal" IS 'Chaîne de caractères identifiant de façon unique l''unité paysagère au sein de sa classe et de l’ensemble des atlas de paysage sur le territoire français';
COMMENT ON COLUMN paysage."EnsemblePaysager"."nom" IS 'Nom de l''ensemble paysager';
COMMENT ON COLUMN paysage."EnsemblePaysager"."lienPageAtlas" IS 'Lien vers la partie de l’atlas de paysage décrivant l''unité paysagère. Ce lien permet à l’utilisateur d’avoir accès à la totalité de l’information concernant l''unité paysagère';
COMMENT ON COLUMN paysage."EnsemblePaysager"."motClefGenerique" IS 'Mots ou expressions indiquant les principales caractéristiques de l''unité paysagère. Un mot-clef générique ne contient pas de nom propre';
COMMENT ON COLUMN paysage."EnsemblePaysager"."motClefToponymique" IS 'Suite de mots ou expressions indiquant les principaux lieux nommés d’intérêt de l''unité paysagère. Un mot-clef toponymique est un nom de lieu (avec un nom propre)';
COMMENT ON COLUMN paysage."EnsemblePaysager"."description" IS 'Texte court, extrait de l’atlas, décrivant de façon synthétique l''unité paysagère';
COMMENT ON COLUMN paysage."EnsemblePaysager"."image" IS 'Lien vers une image illustrant ou symbolisant l''unité paysagère';
COMMENT ON COLUMN paysage."EnsemblePaysager"."dateDefinition" IS 'Date à laquelle l''ensemble paysager a été défini, délimité et nommé';
COMMENT ON COLUMN paysage."EnsemblePaysager"."dateActualisation" IS 'Date à laquelle l''ensemble paysager a été actualisé';
COMMENT ON COLUMN paysage."EnsemblePaysager"."lienAtlasPaysage" IS 'Lien vers la classe AtlasPaysage correspondant à l''unité paysagère. Ce lien permet à l’utilisateur global de trouver les découpages paysagers relatifs à un atlas donné';
COMMENT ON COLUMN paysage."EnsemblePaysager"."codeDepartement" IS 'Code INSEE du ou des département(s) où se situe l''unité paysagère';

COMMENT ON COLUMN paysage."EnsemblePaysager"."codeRegion" IS 'Code INSEE du ou des région(s) où se situe l''unité paysagère';
COMMENT ON COLUMN paysage."EnsemblePaysager"."opSaisie" IS 'Nom de l''opérateur qui a saisit la donnée';
COMMENT ON COLUMN paysage."EnsemblePaysager"."dateCrea" IS 'Date de création de la donnée';
COMMENT ON COLUMN paysage."EnsemblePaysager"."dateModif" IS 'Date de la dernière modification de la donnée';
COMMENT ON COLUMN paysage."EnsemblePaysager"."valid" IS 'L''objet est valide et diffusable';
COMMENT ON COLUMN paysage."EnsemblePaysager"."geometrie" IS 'Représentation géométrique 2D de l’emprise de l''objet géographique';
COMMENT ON COLUMN paysage."EnsemblePaysager"."etiquette" IS 'Etiquette utilisée pour les cartes web GeoIDE Carto2';

-- Attribution de la clé primaire sur l'id
ALTER TABLE paysage."EnsemblePaysager"
ADD PRIMARY KEY (id);

-- Création d'un index spatial
CREATE INDEX sidx_ensemblepaysager_geom
ON paysage."EnsemblePaysager"
USING GIST (geometrie);

-- Ajouter une contrainte unique à la colonne "identifiantGlobal" pour la table "UnitePaysagere" et la liaison avec "lienEP"
ALTER TABLE paysage."EnsemblePaysager" ADD CONSTRAINT uniq_identifiantglobalep UNIQUE ("identifiantGlobal");


-- MAJ de la nouvelle colonne etiquette

UPDATE paysage."EnsemblePaysager"
SET etiquette =
CASE
    WHEN substr("identifiantGlobal",14,3) = 'reg' THEN substr("identifiantGlobal",27,2)||' : '||"nom"
    WHEN substr("identifiantGlobal",14,4) = 'dept' THEN substr("identifiantGlobal",28,2)||' : '||"nom"
ELSE 'Problème d''étiquetage'
END
;