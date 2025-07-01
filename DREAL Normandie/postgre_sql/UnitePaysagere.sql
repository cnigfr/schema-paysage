DROP TABLE IF EXISTS paysage."UnitePaysagere" CASCADE ;

-- Création de la table UnitePaysagere
CREATE TABLE paysage."UnitePaysagere" (
    "id" SERIAL,
    "identifiantLocal" VARCHAR,
    "identifiantGlobal" VARCHAR,
    "nom" VARCHAR,
    "lienPageAtlas" VARCHAR,
    "typeOrographie1" VARCHAR,
    "typeOrographie2" VARCHAR,
    "dominantePaysagere1" VARCHAR,
    "dominantePaysagere2" VARCHAR,
    "typeLocal" VARCHAR,
    "motClefGenerique" VARCHAR,
    "motClefToponymique" VARCHAR,
    "description" VARCHAR,
    "image" VARCHAR,
    "dateDefinition" VARCHAR,
    "dateActualisation" VARCHAR,
    "lienAtlasPaysage" VARCHAR,
    "codeDepartement" VARCHAR,
    "codeRegion" VARCHAR,
    "lienEP" VARCHAR,
	"geometrie" GEOMETRY(MultiPolygon, 2154),

    "opSaisie" VARCHAR,
	"dateCrea" VARCHAR,
	"dateModif" VARCHAR,
    "valid" BOOLEAN DEFAULT FALSE,
    "etiquette" VARCHAR
);

-- Description de la table
COMMENT ON TABLE paysage."UnitePaysagere" IS 'L''unité paysagère est le découpage paysager central dans la construction de la connaissance du paysage, il est issu de la qualification et de la caractérisation des paysages à l’échelle globale du département. Elle désigne une partie continue de territoire homogène au regard de ses caractéristiques géomorphologiques, écologiques, d’occupation du sol et de perception que les habitants et acteurs du territoire lui portent.Ce « paysage donné » est caractérisé par un ensemble de structures paysagères et d’éléments de paysage qui lui procurent sa singularité. Une unité paysagère est distinguée des unités paysagères voisines par des limites qui peuvent être nettes ou « floues »';

-- Description de chaque champ composant la table
COMMENT ON COLUMN paysage."UnitePaysagere"."id" IS 'Identifiant unique servant de clé primaire pour la structure locale';
COMMENT ON COLUMN paysage."UnitePaysagere"."identifiantLocal" IS 'Chaîne de caractères identifiant de façon unique l''unité paysagère au sein de sa classe et du jeu de données dans lesquels il a été défini ';
COMMENT ON COLUMN paysage."UnitePaysagere"."identifiantGlobal" IS 'Chaîne de caractères identifiant de façon unique l''unité paysagère au sein de sa classe et de l’ensemble des atlas de paysage sur le territoire français';
COMMENT ON COLUMN paysage."UnitePaysagere"."nom" IS 'Nom de l’unité paysagère';
COMMENT ON COLUMN paysage."UnitePaysagere"."lienPageAtlas" IS 'Lien vers la partie de l’atlas de paysage décrivant l''unité paysagère. Ce lien permet à l’utilisateur d’avoir accès à la totalité de l’information concernant l''unité paysagère';
COMMENT ON COLUMN paysage."UnitePaysagere"."typeOrographie1" IS 'Caractéristique dominante première de l''unité paysagère selon des critères orographiques ou géomorphologiques';
COMMENT ON COLUMN paysage."UnitePaysagere"."typeOrographie2" IS 'Caractéristique dominante secondaire de l''unité paysagère selon des critères orographiques ou géomorphologiques';
COMMENT ON COLUMN paysage."UnitePaysagere"."dominantePaysagere1" IS 'Caractéristique dominante première de l’unité paysagère selon des critères d’occupation ou d’usage du sol';
COMMENT ON COLUMN paysage."UnitePaysagere"."dominantePaysagere2" IS 'Caractéristique dominante secondaire de l’unité paysagère selon des critères d’occupation ou d’usage du sol';
COMMENT ON COLUMN paysage."UnitePaysagere"."typeLocal" IS 'Caractéristique dominante de l’unité paysagère selon une classification spécifique à l’atlas des paysages correspondant au jeu de données géomatiques';
COMMENT ON COLUMN paysage."UnitePaysagere"."motClefGenerique" IS 'Mots ou expressions indiquant les principales caractéristiques de l''unité paysagère. Un mot-clef générique ne contient pas de nom propre';
COMMENT ON COLUMN paysage."UnitePaysagere"."motClefToponymique" IS 'Suite de mots ou expressions indiquant les principaux lieux nommés d’intérêt de l''unité paysagère. Un mot-clef toponymique est un nom de lieu (avec un nom propre)';
COMMENT ON COLUMN paysage."UnitePaysagere"."description" IS 'Texte court, extrait de l’atlas, décrivant de façon synthétique l''unité paysagère';
COMMENT ON COLUMN paysage."UnitePaysagere"."image" IS 'Lien vers une image illustrant ou symbolisant l''unité paysagère';
COMMENT ON COLUMN paysage."UnitePaysagere"."dateDefinition" IS 'Date à laquelle l''unité paysagère a été définie, délimitée et nommée';
COMMENT ON COLUMN paysage."UnitePaysagere"."dateActualisation" IS 'Date à laquelle l''unité paysagère a été actualisée';
COMMENT ON COLUMN paysage."UnitePaysagere"."lienAtlasPaysage" IS 'Lien vers la classe AtlasPaysage correspondant à l''unité paysagère. Ce lien permet à l’utilisateur global de trouver les découpages paysagers relatifs à un atlas donné';
COMMENT ON COLUMN paysage."UnitePaysagere"."codeDepartement" IS 'Code INSEE du ou des département(s) où se situe l''unité paysagère';
COMMENT ON COLUMN paysage."UnitePaysagere"."codeRegion" IS 'Code INSEE du ou des région(s) où se situe l''unité paysagère';
COMMENT ON COLUMN paysage."UnitePaysagere"."lienEP" IS 'Lien vers l’ensemble paysager auquel appartient l’unité paysagère';
COMMENT ON COLUMN paysage."UnitePaysagere"."geometrie" IS 'Représentation géométrique 2D de l’emprise de l''objet géographique';

COMMENT ON COLUMN paysage."UnitePaysagere"."opSaisie" IS 'Nom de l''opérateur qui a saisit la donnée';
COMMENT ON COLUMN paysage."UnitePaysagere"."dateCrea" IS 'Date de création de la donnée';
COMMENT ON COLUMN paysage."UnitePaysagere"."dateModif" IS 'Date de la dernière modification de la donnée';
COMMENT ON COLUMN paysage."UnitePaysagere"."valid" IS 'L''objet est valide et diffusable';
COMMENT ON COLUMN paysage."UnitePaysagere"."etiquette" IS 'Etiquette utilisée pour les cartes web GeoIDE Carto2';

-- Attribution de la clé primaire sur l'id
ALTER TABLE paysage."UnitePaysagere"
ADD PRIMARY KEY (id);

-- Création d'un index spatial
CREATE INDEX sidx_unitepaysagere_geometrie
ON paysage."UnitePaysagere"
USING GIST (geometrie);

-- Ajouter une contrainte unique à la colonne "identifiantGlobal" pour la table "UnitePaysagere" et la liaison avec "lienUP"
ALTER TABLE paysage."UnitePaysagere" ADD CONSTRAINT uniq_identifiantglobalup UNIQUE ("identifiantGlobal");

-- Clés étrangères
ALTER TABLE paysage."UnitePaysagere" ADD FOREIGN KEY ("lienEP") REFERENCES paysage."EnsemblePaysager"("identifiantGlobal");
ALTER TABLE paysage."UnitePaysagere" ADD FOREIGN KEY ("typeOrographie1") REFERENCES paysage."TypeOrographie"("TypeOrographie"); 
ALTER TABLE paysage."UnitePaysagere" ADD FOREIGN KEY ("typeOrographie2") REFERENCES paysage."TypeOrographie"("TypeOrographie"); 
ALTER TABLE paysage."UnitePaysagere" ADD FOREIGN KEY ("dominantePaysagere1") REFERENCES paysage."DominantePaysagere"("DominantePaysagere"); 
ALTER TABLE paysage."UnitePaysagere" ADD FOREIGN KEY ("dominantePaysagere2") REFERENCES paysage."DominantePaysagere"("DominantePaysagere");