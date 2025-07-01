DROP TABLE IF EXISTS paysage."AtlasPaysage" CASCADE ;

-- Création de la table AtlasPaysage
CREATE TABLE paysage."AtlasPaysage" (
	"id" SERIAL,
	"nom" VARCHAR,
	"identifiant" VARCHAR,
	"maitreOuvrage" VARCHAR,
	"maitreOeuvre" VARCHAR,
	"typeAtlas" VARCHAR,
	"lienAtlas" VARCHAR,
	"dateRealisationAtlas" VARCHAR,
	"dateRevisionDynamiques" VARCHAR,
	"lienOPP" VARCHAR,
	"opSaisie" VARCHAR,
	"dateCrea" VARCHAR,
	"dateModif" VARCHAR,
	"geometrie" GEOMETRY(MultiPolygon, 2154),
	"valid" BOOLEAN DEFAULT FALSE,
	"etiquette" VARCHAR
);

-- Description de la table
COMMENT ON TABLE paysage."AtlasPaysage" IS 'Un atlas du paysage est un document de connaissance des paysages. Cette classe est destinée à fournir à l’utilisateur des informations générales sur l’atlas, ses conditions de réalisation et de mise à jour.';

-- Description de chaque champ composant la table
COMMENT ON COLUMN paysage."AtlasPaysage"."id" IS 'Identifiant unique servant de clé primaire pour la structure locale';

COMMENT ON COLUMN paysage."AtlasPaysage"."nom" IS 'Nom complet de l’atlas correspondant au jeu de données';
COMMENT ON COLUMN paysage."AtlasPaysage"."identifiant" IS 'Chaîne de caractères identifiant de façon unique l’atlas du paysage au sein de l’ensemble des atlas disponibles sur le territoire français';
COMMENT ON COLUMN paysage."AtlasPaysage"."maitreOuvrage" IS 'Nom du ou des maîtres d’ouvrage, commanditaires de l’atlas des paysages';
COMMENT ON COLUMN paysage."AtlasPaysage"."maitreOeuvre" IS 'Nom du ou des maîtres d’oeuvre ayant conduit la réalisation de l’atlas des paysages';
COMMENT ON COLUMN paysage."AtlasPaysage"."typeAtlas" IS 'Niveau administratif de l’atlas correspondant au jeu de données';
COMMENT ON COLUMN paysage."AtlasPaysage"."lienAtlas" IS 'Lien vers le site Internet où l’atlas correspondant au jeu de données est disponible';
COMMENT ON COLUMN paysage."AtlasPaysage"."dateRealisationAtlas" IS 'Date de fin de réalisation de l’atlas. La date de publication peut être choisie pour dater la fin de la réalisation';
COMMENT ON COLUMN paysage."AtlasPaysage"."dateRevisionDynamiques" IS 'Date de révision des informations liées aux dynamiques';
COMMENT ON COLUMN paysage."AtlasPaysage"."lienOPP" IS 'Lien vers l’OPP (Observatoire Photographique du Paysage) correspondant à l’atlas des paysages';

COMMENT ON COLUMN paysage."AtlasPaysage"."opSaisie" IS 'Nom de l''opérateur qui a saisit la donnée';
COMMENT ON COLUMN paysage."AtlasPaysage"."dateCrea" IS 'Date de création de la donnée';
COMMENT ON COLUMN paysage."AtlasPaysage"."dateModif" IS 'Date de la dernière modification de la donnée';
COMMENT ON COLUMN paysage."AtlasPaysage"."geometrie" IS 'Représentation géométrique 2D de l’emprise de l’atlas du paysage  correspondant au jeu de données';
COMMENT ON COLUMN paysage."AtlasPaysage"."valid" IS 'L''objet est valide et diffusable';
COMMENT ON COLUMN paysage."AtlasPaysage"."etiquette" IS 'Etiquette utilisée pour les cartes web GeoIDE Carto2';

-- Attribution de la clé primaire sur l'id
ALTER TABLE paysage."AtlasPaysage"
ADD PRIMARY KEY (id);

-- Création d'un index spatial
CREATE INDEX sidx_atlaspaysage_geom
ON paysage."AtlasPaysage"
USING GIST (geom);

-- MAJ de la nouvelle colonne etiquette

UPDATE paysage."AtlasPaysage"
SET etiquette =
CASE
    WHEN substr("identifiant",14,3) = 'reg' THEN 'R'||substr("identifiant",18,2)||' : '||"nom"
    WHEN substr("identifiant",14,4) = 'dept' THEN 'D'||substr("identifiant",20,2)||' : '||"nom"
ELSE 'Problème d''étiquetage'
END
;

