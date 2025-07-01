DROP TABLE IF EXISTS paysage."Dynamique" CASCADE ;

-- Création de la table DocumentPaysage
CREATE TABLE paysage."Dynamique" (
	"id" SERIAL,
	"natureEvolution" VARCHAR,
	"objetEvolution" VARCHAR,
	"description" VARCHAR,
	"dateObservation" VARCHAR,
	"dateFin" VARCHAR,
	"lienPhotoOPP" VARCHAR,
	"lienEP" VARCHAR,
	"lienUP" VARCHAR,
	"lienSousUP" VARCHAR,
    "opSaisie" VARCHAR,
	"dateCrea" VARCHAR,
	"dateModif" VARCHAR
);

-- Description de la table
COMMENT ON TABLE paysage."Dynamique" IS 'Une dynamique est une évolution du paysage en général depuis la dernière version de l’atlas des paysages. Une dynamique est modélisée par un « data type », c’est-à-dire un attribut complexe ; celui-ci peut s’appliquer à tout niveau de découpage paysager : sous-unités paysagères, unités paysagères, ensembles paysagers. Un découpage paysager peut avoir plusieurs dynamiques';

-- Description de chaque champ composant la table
COMMENT ON COLUMN paysage."Dynamique"."id" IS 'Identifiant unique servant de clé primaire pour la structure locale';
COMMENT ON COLUMN paysage."Dynamique"."natureEvolution" IS 'Evolution de la dynamique paysagère';
COMMENT ON COLUMN paysage."Dynamique"."objetEvolution" IS 'Caractéristique paysagère sur laquelle porte l’évolution';
COMMENT ON COLUMN paysage."Dynamique"."description" IS 'Texte libre décrivant la dynamique de façon plus détaillée ou plus adaptée que la combinaison natureEvolution + objetEvolution';
COMMENT ON COLUMN paysage."Dynamique"."dateObservation" IS 'Date à laquelle la dynamique a été observée';
COMMENT ON COLUMN paysage."Dynamique"."dateFin" IS 'Date à laquelle un arrêt de la dynamique a été observé';
COMMENT ON COLUMN paysage."Dynamique"."lienPhotoOPP" IS 'Lien vers la série de photos de l''OPP illustrant cette dynamique';
COMMENT ON COLUMN paysage."Dynamique"."lienEP" IS 'Lien vers l''ensemble paysager auquel s''applique cette dynamique';
COMMENT ON COLUMN paysage."Dynamique"."lienUP" IS 'Lien vers l''unité paysagère à laquelle s''applique cette dynamique';
COMMENT ON COLUMN paysage."Dynamique"."lienSousUP" IS 'Lien vers la sous unité paysagère à laquelle s''applique cette dynamique';


COMMENT ON COLUMN paysage."Dynamique"."opSaisie" IS 'Nom de l''opérateur qui a saisit la donnée';
COMMENT ON COLUMN paysage."Dynamique"."dateCrea" IS 'Date de création de la donnée';
COMMENT ON COLUMN paysage."Dynamique"."dateModif" IS 'Date de la dernière modification de la donnée';

-- Attribution de la clé primaire sur l'id
ALTER TABLE paysage."Dynamique"
ADD PRIMARY KEY (id);

-- Clés étrangères
ALTER TABLE paysage."Dynamique" ADD FOREIGN KEY ("natureEvolution") REFERENCES paysage."NatureEvolution"("NatureEvolution");
ALTER TABLE paysage."Dynamique" ADD FOREIGN KEY ("objetEvolution") REFERENCES paysage."ObjetEvolution"("ObjetEvolution");
ALTER TABLE paysage."Dynamique" ADD FOREIGN KEY ("natureEvolution") REFERENCES paysage."NatureEvolution"("NatureEvolution");
