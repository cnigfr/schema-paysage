DROP TABLE IF EXISTS paysage."DocumentPaysage" CASCADE ;

-- Création de la table DocumentPaysage
CREATE TABLE paysage."DocumentPaysage" (
	"id" SERIAL,
	"nom" VARCHAR,
	"date" VARCHAR,
	"auteur" VARCHAR,
	"document" VARCHAR,
	"conditionsUtilisationTexte" VARCHAR,
	"conditionsUtilisationURL" VARCHAR,
	"lienAtlas" VARCHAR,
    "opSaisie" VARCHAR,
	"dateCrea" VARCHAR,
	"dateModif" VARCHAR,
	"geometrie" Geometry(Multipolygon, 2154),
	"valid" BOOLEAN DEFAULT FALSE,
	"etiquette" VARCHAR
);

-- Description de la table
COMMENT ON TABLE paysage."DocumentPaysage" IS 'Un document paysage est un document illustrant un découpage paysager. Il peut s’agir d’un bloc-diagramme, d’une coupe, d’un croquis, d’une photographie, etc';

-- Description de chaque champ composant la table
COMMENT ON COLUMN paysage."DocumentPaysage"."id" IS 'Identifiant unique servant de clé primaire pour la structure locale';

COMMENT ON COLUMN paysage"DocumentPaysage"."nom" IS 'Intitulé du document paysage';
COMMENT ON COLUMN paysage."DocumentPaysage"."date" IS 'Date à laquelle le document paysage a été réalisé';
COMMENT ON COLUMN paysage."DocumentPaysage"."auteur" IS 'Nom de l’auteur du document';
COMMENT ON COLUMN paysage."DocumentPaysage"."document" IS 'Lien vers le document paysage';
COMMENT ON COLUMN paysage."DocumentPaysage"."conditionsUtilisationTexte" IS 'Conditions d’utilisation du document, sous forme d’un texte';
COMMENT ON COLUMN paysage."DocumentPaysage"."conditionsUtilisationURL" IS 'Conditions d’utilisation du document, sous forme d’un lien vers un texte';

COMMENT ON COLUMN paysage."DocumentPaysage"."opSaisie" IS 'Nom de l''opérateur qui a saisit la donnée';
COMMENT ON COLUMN paysage."DocumentPaysage"."dateCrea" IS 'Date de création de la donnée';
COMMENT ON COLUMN paysage."DocumentPaysage"."dateModif" IS 'Date de la dernière modification de la donnée';
COMMENT ON COLUMN paysage."DocumentPaysage"."geometrie" IS 'Représentation géométrique 2D de l’emprise du document paysage  correspondant au jeu de données';
COMMENT ON COLUMN paysage."DocumentPaysage"."valid" IS 'L''objet est valide et diffusable';
COMMENT ON COLUMN paysage."DocumentPaysage"."etiquette" IS 'Etiquette utilisée pour les cartes web GeoIDE Carto2';

-- Attribution de la clé primaire sur l'id
ALTER TABLE paysage."DocumentPaysage"
ADD PRIMARY KEY (id);
