DROP TABLE IF EXISTS paysage."LimiteDecoupagePaysager" CASCADE ;

-- Création de la table LimiteDecoupagePaysager
CREATE TABLE paysage."LimiteDecoupagePaysager" (
	"id" SERIAL,

	"identifiantLocal" VARCHAR,
	"identifiantGlobal" VARCHAR,
	"statut" VARCHAR,
	"largeurEstimee" VARCHAR,
	"nature" VARCHAR,

    "opSaisie" VARCHAR,
	"dateCrea" VARCHAR,
	"dateModif" VARCHAR,
    "geometrie" Geometry(Linestring, 2154),
	"etiquette" VARCHAR
);

-- Description de la table
COMMENT ON TABLE paysage."LimiteDecoupagePaysager" IS 'Une limite de découpage paysager est une portion du contour d’un découpage paysager : unité paysagère ou ensemble paysager ou sous-ensemble paysager.
Cette classe est essentiellement destinée à renseigner l’utilisateur sur la nature et la précision de la limite.';

-- Description de chaque champ composant la table
COMMENT ON COLUMN paysage."LimiteDecoupagePaysager"."id" IS 'Identifiant unique servant de clé primaire pour la structure locale';

COMMENT ON COLUMN paysage."LimiteDecoupagePaysager"."identifiantLocal" IS 'Chaîne de caractères identifiant de façon unique le découpage paysager au sein de sa classe et du  jeu de données dans lesquels il a été défini';
COMMENT ON COLUMN paysage."LimiteDecoupagePaysager"."identifiantGlobal" IS 'Chaîne de caractères identifiant de façon unique la limite de découpage paysager au sein de sa classe et  de l’ensemble des atlas  de paysage sur le territoire français';
COMMENT ON COLUMN paysage."LimiteDecoupagePaysager"."statut" IS 'Cet attribut indique la fiabilité de la position de la limite, i.e. s’il s’agit d’une limite nette ou d’une limite floue';
COMMENT ON COLUMN paysage."LimiteDecoupagePaysager"."largeurEstimee" IS 'Largeur moyenne estimée de la zone de transition entre 2 découpages paysagers, exprimée en mètres. Cet attribut mesure l’incertitude de la position de la limite sur le terrain';
COMMENT ON COLUMN paysage."LimiteDecoupagePaysager"."nature" IS 'Cet attribut indique quel objet géographique a été utilisé comme limite du découpage paysager';

COMMENT ON COLUMN paysage."LimiteDecoupagePaysager"."opSaisie" IS 'Nom de l''opérateur qui a saisit la donnée';
COMMENT ON COLUMN paysage."LimiteDecoupagePaysager"."dateCrea" IS 'Date de création de la donnée';
COMMENT ON COLUMN paysage."LimiteDecoupagePaysager"."dateModif" IS 'Date de la dernière modification de la donnée';
COMMENT ON COLUMN paysage."LimiteDecoupagePaysager"."etiquette" IS 'Etiquette utilisée pour les cartes web GeoIDE Carto2';

-- Attribution de la clé primaire sur l'id
ALTER TABLE paysage."LimiteDecoupagePaysager"
ADD PRIMARY KEY (id);

-- Création d'un index spatial
CREATE INDEX sidx_limitedecoupagepaysager_geom
ON paysage."LimiteDecoupagePaysager"
USING GIST (geom);
