DROP TABLE IF EXISTS paysage."SousUnitePaysagere" CASCADE ;

-- Création de la table SousUnitePaysagere
CREATE TABLE paysage."SousUnitePaysagere" (
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
    "lienUP" VARCHAR,

    "opSaisie" VARCHAR,
	"dateCrea" VARCHAR,
	"dateModif" VARCHAR,
    "valid" BOOLEAN DEFAULT FALSE,
	"geometrie" GEOMETRY(MultiPolygon, 2154),
	"etiquette" VARCHAR
);

-- Description de la table
COMMENT ON TABLE paysage."SousUnitePaysagere" IS 'Une sous-unité paysagère est une subdivision d''une unité paysagère. Le découpage y est réalisé de manière plus fine, les sous–unités présentant entre elles de légères variations des composantes paysagères (liées à la topographie, à la fonctionnalité des milieux, aux tissus urbains). Les sous-unités sont particulièrement utilisées au sein des unités paysagères très urbaines et peuvent être compatibles avec un découpage par quartier. Comme pour les unités paysagères, les limites entre sous-unités peuvent être nettes ou « floues »';

-- Description de chaque champ composant la table
COMMENT ON COLUMN paysage."SousUnitePaysagere"."id" IS 'Identifiant unique servant de clé primaire pour la structure locale';

COMMENT ON COLUMN paysage."SousUnitePaysagere"."identifiantLocal" IS 'Chaîne de caractères identifiant de façon unique la sous-unité paysagère au sein de sa classe et du jeu de données dans lesquels il a été défini';
COMMENT ON COLUMN paysage."SousUnitePaysagere"."identifiantGlobal" IS 'Chaîne de caractères identifiant de façon unique la sous-unité paysagère au sein de sa classe et de l’ensemble des atlas de paysage sur le territoire français';
COMMENT ON COLUMN paysage."SousUnitePaysagere"."nom" IS 'Nom de la sous-unité paysagère';
COMMENT ON COLUMN paysage."SousUnitePaysagere"."lienPageAtlas" IS 'Lien vers la partie de l’atlas de paysage décrivant la sous-unité paysagère. Ce lien permet à l’utilisateur d’avoir accès à la totalité de l’information concernant la sous-unité paysagère';
COMMENT ON COLUMN paysage."SousUnitePaysagere"."motClefGenerique" IS 'Mots ou expressions indiquant les principales caractéristiques de la sous-unité paysagère. Un mot-clef générique ne contient pas de nom propre';
COMMENT ON COLUMN paysage."SousUnitePaysagere"."motClefToponymique" IS 'Suite de mots ou expressions indiquant les principaux lieux nommés d’intérêt de la sous-unité paysagère. Un mot-clef toponymique est un nom de lieu (avec un nom propre)';
COMMENT ON COLUMN paysage."SousUnitePaysagere"."description" IS 'Texte court, extrait de l’atlas, décrivant de façon synthétique la sous-unité paysagère';
COMMENT ON COLUMN paysage."SousUnitePaysagere"."image" IS 'Lien vers une image illustrant ou symbolisant la sous-unité paysagère';
COMMENT ON COLUMN paysage."SousUnitePaysagere"."dateDefinition" IS 'Date à laquelle la sous-unité paysagère a été définie, délimitée et nommée';
COMMENT ON COLUMN paysage."SousUnitePaysagere"."dateActualisation" IS 'Date à laquelle la sous-unité paysagère a été actualisée';
COMMENT ON COLUMN paysage."SousUnitePaysagere"."lienAtlasPaysage" IS 'Lien vers la classe AtlasPaysage correspondant à la sous-unité paysagère. Ce lien permet à l’utilisateur global de trouver les découpages paysagers relatifs à un atlas donné';
COMMENT ON COLUMN paysage."SousUnitePaysagere"."codeDepartement" IS 'Code INSEE du ou des département(s) où se situe la sous-unité paysagère';
COMMENT ON COLUMN paysage."SousUnitePaysagere"."codeRegion" IS 'Code INSEE du ou des région(s) où se situe la sous-unité paysagère';
COMMENT ON COLUMN paysage."SousUnitePaysagere"."lienUP" IS 'Lien vers l’unité paysagère à laquelle appartient la sous-unité paysagère';

COMMENT ON COLUMN paysage."SousUnitePaysagere"."opSaisie" IS 'Nom de l''opérateur qui a saisit la donnée';
COMMENT ON COLUMN paysage."SousUnitePaysagere"."dateCrea" IS 'Date de création de la donnée';
COMMENT ON COLUMN paysage."SousUnitePaysagere"."dateModif" IS 'Date de la dernière modification de la donnée';
COMMENT ON COLUMN paysage."SousUnitePaysagere"."valid" IS 'L''objet est valide et diffusable';
COMMENT ON COLUMN paysage."SousUnitePaysagere"."geometrie" IS 'Représentation géométrique 2D de l’emprise de l''objet géopgraphique';
COMMENT ON COLUMN paysage."SousUnitePaysagere"."etiquette" IS 'Etiquette utilisée pour les cartes web GeoIDE Carto2';

-- Attribution de la clé primaire sur l'id
ALTER TABLE paysage."SousUnitePaysagere"
ADD PRIMARY KEY (id);

-- Création d'un index spatial
CREATE INDEX sidx_sousunitepaysagere_geometrie
ON paysage."SousUnitePaysagere"
USING GIST (geometrie);

-- Clés étrangères
ALTER TABLE paysage."SousUnitePaysagere" ADD FOREIGN KEY ("lienUP") REFERENCES paysage."UnitePaysagere"("identifiantGlobal");




-- Ajout des sous unités paysagères de la Manche dans la table standard SousUnitePaysagere
INSERT INTO paysage."SousUnitePaysagere"(
    "identifiantLocal",
    "identifiantGlobal",
    "nom",
    "lienPageAtlas",
    "motClefGenerique",
    "motClefToponymique",
    "description",
    "image",
    "dateDefinition",
    "dateActualisation",
    "lienAtlasPaysage",
    "codeDepartement",
    "codeRegion",
    "lienUP",
    "opSaisie",
	"dateCrea",
	"dateModif",
    "valid",
	"geometrie"
)
SELECT
    a."identifiantLocal",
    a."identifiantGlobal",
    a."nom",
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    a."codeDepartement",
    a."codeRegion",
    NULL,
    'julien.defenouillère',
	NOW(),
	NULL,
    'true',
	a."geom"
FROM paysage."SousUnitePaysagere_old" as a
;


-- MAJ de la nouvelle colonne etiquette

UPDATE paysage."SousUnitePaysagere"
SET etiquette =
CASE
    WHEN substr("identifiantGlobal",14,3) = 'reg' THEN substr("identifiantGlobal",29,4)||' : '||"nom"
    WHEN substr("identifiantGlobal",14,4) = 'dept' THEN substr("identifiantGlobal",30,4)||' : '||"nom"
ELSE 'Problème d''étiquetage'
END
;