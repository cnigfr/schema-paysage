-- ============================================================================
-- Template GeoPackage pour le Standard Paysage du CNIG
-- Version: 1.2.0
-- Date: 2025
-- Système de coordonnées: Lambert 93 (EPSG:2154) pour la France métropolitaine
-- Support des projections outre-mer via WKT for CRS extension
-- Documentation formelle via Schema extension
-- ============================================================================

-- Ce script crée un GeoPackage vide conforme au standard Paysage
-- Il supporte le Lambert 93 et toutes les projections françaises via l'extension WKT for CRS

-- ============================================================================
-- CONFIGURATION SQLITE / GEOPACKAGE
-- ============================================================================

-- Définir l'Application ID pour GeoPackage (GP10 = 0x47503130)
PRAGMA application_id = 1196437808;

-- Définir la version GeoPackage 1.3.0 (format: MMmmpp = 10300)
PRAGMA user_version = 10300;

-- Activer les clés étrangères
PRAGMA foreign_keys = ON;

-- ============================================================================
-- TABLES SYSTÈME GEOPACKAGE (OGC GeoPackage 1.3)
-- ============================================================================

-- Table des systèmes de référence spatiale
-- Note : Inclut la colonne definition_12_063 pour l'extension WKT for CRS
CREATE TABLE IF NOT EXISTS gpkg_spatial_ref_sys (
    srs_name TEXT NOT NULL,
    srs_id INTEGER NOT NULL PRIMARY KEY,
    organization TEXT NOT NULL,
    organization_coordsys_id INTEGER NOT NULL,
    definition TEXT NOT NULL,
    description TEXT,
    definition_12_063 TEXT NOT NULL
);

-- Table du catalogue des couches
CREATE TABLE IF NOT EXISTS gpkg_contents (
    table_name TEXT NOT NULL PRIMARY KEY,
    data_type TEXT NOT NULL,
    identifier TEXT UNIQUE,
    description TEXT DEFAULT '',
    last_change DATETIME NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
    min_x DOUBLE,
    min_y DOUBLE,
    max_x DOUBLE,
    max_y DOUBLE,
    srs_id INTEGER,
    CONSTRAINT fk_gc_r_srs_id FOREIGN KEY (srs_id) REFERENCES gpkg_spatial_ref_sys(srs_id)
);

-- Table des colonnes géométriques
CREATE TABLE IF NOT EXISTS gpkg_geometry_columns (
    table_name TEXT NOT NULL,
    column_name TEXT NOT NULL,
    geometry_type_name TEXT NOT NULL,
    srs_id INTEGER NOT NULL,
    z TINYINT NOT NULL,
    m TINYINT NOT NULL,
    CONSTRAINT pk_geom_cols PRIMARY KEY (table_name, column_name),
    CONSTRAINT uk_gc_table_name UNIQUE (table_name),
    CONSTRAINT fk_gc_tn FOREIGN KEY (table_name) REFERENCES gpkg_contents(table_name),
    CONSTRAINT fk_gc_srs FOREIGN KEY (srs_id) REFERENCES gpkg_spatial_ref_sys(srs_id)
);

-- Table des extensions
CREATE TABLE IF NOT EXISTS gpkg_extensions (
    table_name TEXT,
    column_name TEXT,
    extension_name TEXT NOT NULL,
    definition TEXT NOT NULL,
    scope TEXT NOT NULL,
    CONSTRAINT ge_tce UNIQUE (table_name, column_name, extension_name)
);

-- Table des métadonnées
CREATE TABLE IF NOT EXISTS gpkg_metadata (
    id INTEGER CONSTRAINT m_pk PRIMARY KEY ASC NOT NULL,
    md_scope TEXT NOT NULL DEFAULT 'dataset',
    md_standard_uri TEXT NOT NULL,
    mime_type TEXT NOT NULL DEFAULT 'text/xml',
    metadata TEXT NOT NULL
);

-- Table des références de métadonnées
CREATE TABLE IF NOT EXISTS gpkg_metadata_reference (
    reference_scope TEXT NOT NULL,
    table_name TEXT,
    column_name TEXT,
    row_id_value INTEGER,
    timestamp DATETIME NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ','now')),
    md_file_id INTEGER NOT NULL,
    md_parent_id INTEGER,
    CONSTRAINT crmr_mfi_fk FOREIGN KEY (md_file_id) REFERENCES gpkg_metadata(id),
    CONSTRAINT crmr_mpi_fk FOREIGN KEY (md_parent_id) REFERENCES gpkg_metadata(id)
);

-- Systèmes de référence obligatoires par défaut

-- WGS 84 (EPSG:4326) - requis par le standard
INSERT OR IGNORE INTO gpkg_spatial_ref_sys (
    srs_name, srs_id, organization, organization_coordsys_id, definition, description, definition_12_063
) VALUES (
    'WGS 84',
    4326,
    'EPSG',
    4326,
    'GEOGCS["WGS 84",DATUM["WGS_1984",SPHEROID["WGS 84",6378137,298.257223563]],PRIMEM["Greenwich",0],UNIT["degree",0.0174532925199433]]',
    'Système géodésique mondial WGS84 - Compatible avec tous les territoires français',
    'GEOGCRS["WGS 84",DATUM["World Geodetic System 1984",ELLIPSOID["WGS 84",6378137,298.257223563,LENGTHUNIT["metre",1]]],PRIMEM["Greenwich",0,ANGLEUNIT["degree",0.0174532925199433]],CS[ellipsoidal,2],AXIS["geodetic latitude (Lat)",north,ORDER[1],ANGLEUNIT["degree",0.0174532925199433]],AXIS["geodetic longitude (Lon)",east,ORDER[2],ANGLEUNIT["degree",0.0174532925199433]],USAGE[SCOPE["Horizontal component of 3D system."],AREA["World."],BBOX[-90,-180,90,180]],ID["EPSG",4326]]'
);

-- Undefined Cartesian (srs_id = -1) - requis par le standard
INSERT OR IGNORE INTO gpkg_spatial_ref_sys (
    srs_name, srs_id, organization, organization_coordsys_id, definition, description, definition_12_063
) VALUES (
    'Undefined cartesian SRS',
    -1,
    'NONE',
    -1,
    'undefined',
    'Undefined Cartesian coordinate reference system',
    'undefined'
);

-- Undefined Geographic (srs_id = 0) - requis par le standard
INSERT OR IGNORE INTO gpkg_spatial_ref_sys (
    srs_name, srs_id, organization, organization_coordsys_id, definition, description, definition_12_063
) VALUES (
    'Undefined geographic SRS',
    0,
    'NONE',
    0,
    'undefined',
    'Undefined geographic coordinate reference system',
    'undefined'
);

-- ============================================================================
-- EXTENSION: WKT for Coordinate Reference Systems
-- ============================================================================

-- Activation de l'extension WKT for CRS (OGC GeoPackage Extension)
INSERT OR IGNORE INTO gpkg_extensions (
    table_name, column_name, extension_name, definition, scope
) VALUES (
    'gpkg_spatial_ref_sys', 'definition_12_063', 'gpkg_crs_wkt',
    'http://www.geopackage.org/spec/#extension_crs_wkt',
    'read-write'
);

-- ============================================================================
-- EXTENSION: SCHEMA (OGC GeoPackage Extension)
-- ============================================================================
-- Cette extension permet de définir formellement le schéma de données avec
-- contraintes et documentation pour chaque colonne.
-- Spécification: http://www.geopackage.org/spec/#extension_schema

-- Activation de l'extension Schema
INSERT OR IGNORE INTO gpkg_extensions (
    table_name, column_name, extension_name, definition, scope
) VALUES (
    NULL, NULL, 'gpkg_schema',
    'http://www.geopackage.org/spec/#extension_schema',
    'read-write'
);

-- ============================================================================
-- TABLE: gpkg_data_columns
-- ============================================================================
-- Documentation formelle de chaque colonne importante

CREATE TABLE IF NOT EXISTS gpkg_data_columns (
    table_name TEXT NOT NULL,
    column_name TEXT NOT NULL,
    name TEXT,
    title TEXT,
    description TEXT,
    mime_type TEXT,
    constraint_name TEXT,
    CONSTRAINT pk_gdc PRIMARY KEY (table_name, column_name),
    CONSTRAINT fk_gdc_tn FOREIGN KEY (table_name) REFERENCES gpkg_contents(table_name)
);

-- ============================================================================
-- TABLE: gpkg_data_column_constraints
-- ============================================================================
-- Définition des contraintes de valeurs (énumérations, plages, etc.)

CREATE TABLE IF NOT EXISTS gpkg_data_column_constraints (
    constraint_name TEXT NOT NULL,
    constraint_type TEXT NOT NULL,
    value TEXT,
    min NUMERIC,
    minIsInclusive BOOLEAN,
    max NUMERIC,
    maxIsInclusive BOOLEAN,
    description TEXT,
    CONSTRAINT gdcc_ntv UNIQUE (constraint_name, constraint_type, value)
);

-- ============================================================================
-- DÉFINITION DES SYSTÈMES DE COORDONNÉES FRANÇAIS
-- ============================================================================
-- Conforme à l'arrêté du 5 mars 2019 et couvrant tous les territoires français
--
-- NOTE: Le système WGS84 (EPSG:4326) est disponible par défaut dans tout
-- GeoPackage et n'a pas besoin d'être redéfini ici. Les 16 projections ci-dessous
-- sont les systèmes de référence légaux français ajoutés via l'extension WKT for CRS.

-- ============================================================================
-- FRANCE MÉTROPOLITAINE
-- ============================================================================

-- Lambert 93 (France métropolitaine) - EPSG:2154
INSERT OR REPLACE INTO gpkg_spatial_ref_sys (
    srs_name, srs_id, organization, organization_coordsys_id, 
    definition, description, definition_12_063
) VALUES (
    'RGF93 v1 / Lambert-93',
    2154,
    'EPSG',
    2154,
    'PROJCS["RGF93 v1 / Lambert-93",GEOGCS["RGF93 v1",DATUM["Reseau_Geodesique_Francais_1993_v1",SPHEROID["GRS 1980",6378137,298.257222101]],PRIMEM["Greenwich",0],UNIT["degree",0.0174532925199433]],PROJECTION["Lambert_Conformal_Conic_2SP"],PARAMETER["latitude_of_origin",46.5],PARAMETER["central_meridian",3],PARAMETER["standard_parallel_1",49],PARAMETER["standard_parallel_2",44],PARAMETER["false_easting",700000],PARAMETER["false_northing",6600000],UNIT["metre",1],AXIS["Easting",EAST],AXIS["Northing",NORTH]]',
    'Lambert 93 - Système légal pour la France métropolitaine. Ellipsoïde: GRS 1980. Datum: RGF93.',
    'PROJCRS["RGF93 v1 / Lambert-93",BASEGEOGCRS["RGF93 v1",DATUM["Reseau Geodesique Francais 1993 v1",ELLIPSOID["GRS 1980",6378137,298.257222101,LENGTHUNIT["metre",1]]],PRIMEM["Greenwich",0,ANGLEUNIT["degree",0.0174532925199433]]],CONVERSION["Lambert-93",METHOD["Lambert Conic Conformal (2SP)",ID["EPSG",9802]],PARAMETER["Latitude of false origin",46.5,ANGLEUNIT["degree",0.0174532925199433]],PARAMETER["Longitude of false origin",3,ANGLEUNIT["degree",0.0174532925199433]],PARAMETER["Latitude of 1st standard parallel",49,ANGLEUNIT["degree",0.0174532925199433]],PARAMETER["Latitude of 2nd standard parallel",44,ANGLEUNIT["degree",0.0174532925199433]],PARAMETER["Easting at false origin",700000,LENGTHUNIT["metre",1]],PARAMETER["Northing at false origin",6600000,LENGTHUNIT["metre",1]]],CS[Cartesian,2],AXIS["easting (X)",east,ORDER[1],LENGTHUNIT["metre",1]],AXIS["northing (Y)",north,ORDER[2],LENGTHUNIT["metre",1]],USAGE[SCOPE["Engineering survey, topographic mapping."],AREA["France - onshore and offshore, mainland and Corsica."],BBOX[41.15,-9.86,51.56,10.38]],ID["EPSG",2154]]'
);

-- ============================================================================
-- ANTILLES
-- ============================================================================

-- Guadeloupe & Martinique - RGAF09 / UTM zone 20N - EPSG:5490
INSERT OR REPLACE INTO gpkg_spatial_ref_sys (
    srs_name, srs_id, organization, organization_coordsys_id, 
    definition, description, definition_12_063
) VALUES (
    'RGAF09 / UTM zone 20N',
    5490,
    'EPSG',
    5490,
    'PROJCS["RGAF09 / UTM zone 20N",GEOGCS["RGAF09",DATUM["Reseau_Geodesique_des_Antilles_Francaises_2009",SPHEROID["GRS 1980",6378137,298.257222101]],PRIMEM["Greenwich",0],UNIT["degree",0.0174532925199433]],PROJECTION["Transverse_Mercator"],PARAMETER["latitude_of_origin",0],PARAMETER["central_meridian",-63],PARAMETER["scale_factor",0.9996],PARAMETER["false_easting",500000],PARAMETER["false_northing",0],UNIT["metre",1],AXIS["Easting",EAST],AXIS["Northing",NORTH]]',
    'RGAF09 UTM Nord fuseau 20 - Système légal pour la Guadeloupe et la Martinique. Altimétrie: IGN 1988 (Guadeloupe) / IGN 1987 (Martinique).',
    'PROJCRS["RGAF09 / UTM zone 20N",BASEGEOGCRS["RGAF09",DATUM["Reseau Geodesique des Antilles Francaises 2009",ELLIPSOID["GRS 1980",6378137,298.257222101,LENGTHUNIT["metre",1]]],PRIMEM["Greenwich",0,ANGLEUNIT["degree",0.0174532925199433]]],CONVERSION["UTM zone 20N",METHOD["Transverse Mercator",ID["EPSG",9807]],PARAMETER["Latitude of natural origin",0,ANGLEUNIT["degree",0.0174532925199433]],PARAMETER["Longitude of natural origin",-63,ANGLEUNIT["degree",0.0174532925199433]],PARAMETER["Scale factor at natural origin",0.9996,SCALEUNIT["unity",1]],PARAMETER["False easting",500000,LENGTHUNIT["metre",1]],PARAMETER["False northing",0,LENGTHUNIT["metre",1]]],CS[Cartesian,2],AXIS["easting (E)",east,ORDER[1],LENGTHUNIT["metre",1]],AXIS["northing (N)",north,ORDER[2],LENGTHUNIT["metre",1]],USAGE[SCOPE["Engineering survey, topographic mapping."],AREA["Guadeloupe and Martinique - onshore and offshore."],BBOX[14.08,-64.85,18.19,-57.52]],ID["EPSG",5490]]'
);

-- Saint-Martin & Saint-Barthélemy - RRAF 1991 / UTM zone 20N - EPSG:4559
INSERT OR REPLACE INTO gpkg_spatial_ref_sys (
    srs_name, srs_id, organization, organization_coordsys_id, 
    definition, description, definition_12_063
) VALUES (
    'RRAF 1991 / UTM zone 20N',
    4559,
    'EPSG',
    4559,
    'PROJCS["RRAF 1991 / UTM zone 20N",GEOGCS["RRAF 1991",DATUM["Reseau_de_Reference_des_Antilles_Francaises_1991",SPHEROID["GRS 1980",6378137,298.257222101]],PRIMEM["Greenwich",0],UNIT["degree",0.0174532925199433]],PROJECTION["Transverse_Mercator"],PARAMETER["latitude_of_origin",0],PARAMETER["central_meridian",-63],PARAMETER["scale_factor",0.9996],PARAMETER["false_easting",500000],PARAMETER["false_northing",0],UNIT["metre",1],AXIS["Easting",EAST],AXIS["Northing",NORTH]]',
    'RRAF 1991 UTM Nord fuseau 20 - Système pour Saint-Martin et Saint-Barthélemy.',
    'PROJCRS["RRAF 1991 / UTM zone 20N",BASEGEOGCRS["RRAF 1991",DATUM["Reseau de Reference des Antilles Francaises 1991",ELLIPSOID["GRS 1980",6378137,298.257222101,LENGTHUNIT["metre",1]]],PRIMEM["Greenwich",0,ANGLEUNIT["degree",0.0174532925199433]]],CONVERSION["UTM zone 20N",METHOD["Transverse Mercator",ID["EPSG",9807]],PARAMETER["Latitude of natural origin",0,ANGLEUNIT["degree",0.0174532925199433]],PARAMETER["Longitude of natural origin",-63,ANGLEUNIT["degree",0.0174532925199433]],PARAMETER["Scale factor at natural origin",0.9996,SCALEUNIT["unity",1]],PARAMETER["False easting",500000,LENGTHUNIT["metre",1]],PARAMETER["False northing",0,LENGTHUNIT["metre",1]]],CS[Cartesian,2],AXIS["easting (E)",east,ORDER[1],LENGTHUNIT["metre",1]],AXIS["northing (N)",north,ORDER[2],LENGTHUNIT["metre",1]],USAGE[SCOPE["Engineering survey, topographic mapping."],AREA["Saint Martin and Saint Barthelemy - onshore and offshore."],BBOX[17.62,-63.66,18.54,-62.5]],ID["EPSG",4559]]'
);

-- ============================================================================
-- GUYANE
-- ============================================================================

-- Guyane - RGFG95 / UTM zone 22N - EPSG:2972
INSERT OR REPLACE INTO gpkg_spatial_ref_sys (
    srs_name, srs_id, organization, organization_coordsys_id, 
    definition, description, definition_12_063
) VALUES (
    'RGFG95 / UTM zone 22N',
    2972,
    'EPSG',
    2972,
    'PROJCS["RGFG95 / UTM zone 22N",GEOGCS["RGFG95",DATUM["Reseau_Geodesique_Francais_de_Guyane_1995",SPHEROID["GRS 1980",6378137,298.257222101]],PRIMEM["Greenwich",0],UNIT["degree",0.0174532925199433]],PROJECTION["Transverse_Mercator"],PARAMETER["latitude_of_origin",0],PARAMETER["central_meridian",-51],PARAMETER["scale_factor",0.9996],PARAMETER["false_easting",500000],PARAMETER["false_northing",0],UNIT["metre",1],AXIS["Easting",EAST],AXIS["Northing",NORTH]]',
    'RGFG95 UTM Nord fuseau 22 - Système légal pour la Guyane. Altimétrie: NGG 1977.',
    'PROJCRS["RGFG95 / UTM zone 22N",BASEGEOGCRS["RGFG95",DATUM["Reseau Geodesique Francais Guyane 1995",ELLIPSOID["GRS 1980",6378137,298.257222101,LENGTHUNIT["metre",1]]],PRIMEM["Greenwich",0,ANGLEUNIT["degree",0.0174532925199433]]],CONVERSION["UTM zone 22N",METHOD["Transverse Mercator",ID["EPSG",9807]],PARAMETER["Latitude of natural origin",0,ANGLEUNIT["degree",0.0174532925199433]],PARAMETER["Longitude of natural origin",-51,ANGLEUNIT["degree",0.0174532925199433]],PARAMETER["Scale factor at natural origin",0.9996,SCALEUNIT["unity",1]],PARAMETER["False easting",500000,LENGTHUNIT["metre",1]],PARAMETER["False northing",0,LENGTHUNIT["metre",1]]],CS[Cartesian,2],AXIS["easting (E)",east,ORDER[1],LENGTHUNIT["metre",1]],AXIS["northing (N)",north,ORDER[2],LENGTHUNIT["metre",1]],USAGE[SCOPE["Engineering survey, topographic mapping."],AREA["French Guiana - onshore and offshore."],BBOX[2.11,-54.61,8.88,-49.45]],ID["EPSG",2972]]'
);

-- ============================================================================
-- OCÉAN INDIEN
-- ============================================================================

-- La Réunion - RGR92 / UTM zone 40S - EPSG:2975
INSERT OR REPLACE INTO gpkg_spatial_ref_sys (
    srs_name, srs_id, organization, organization_coordsys_id, 
    definition, description, definition_12_063
) VALUES (
    'RGR92 / UTM zone 40S',
    2975,
    'EPSG',
    2975,
    'PROJCS["RGR92 / UTM zone 40S",GEOGCS["RGR92",DATUM["Reseau_Geodesique_de_la_Reunion_1992",SPHEROID["GRS 1980",6378137,298.257222101]],PRIMEM["Greenwich",0],UNIT["degree",0.0174532925199433]],PROJECTION["Transverse_Mercator"],PARAMETER["latitude_of_origin",0],PARAMETER["central_meridian",57],PARAMETER["scale_factor",0.9996],PARAMETER["false_easting",500000],PARAMETER["false_northing",10000000],UNIT["metre",1],AXIS["Easting",EAST],AXIS["Northing",NORTH]]',
    'RGR92 UTM Sud fuseau 40 - Système légal pour La Réunion. Altimétrie: IGN 1989.',
    'PROJCRS["RGR92 / UTM zone 40S",BASEGEOGCRS["RGR92",DATUM["Reseau Geodesique de la Reunion 1992",ELLIPSOID["GRS 1980",6378137,298.257222101,LENGTHUNIT["metre",1]]],PRIMEM["Greenwich",0,ANGLEUNIT["degree",0.0174532925199433]]],CONVERSION["UTM zone 40S",METHOD["Transverse Mercator",ID["EPSG",9807]],PARAMETER["Latitude of natural origin",0,ANGLEUNIT["degree",0.0174532925199433]],PARAMETER["Longitude of natural origin",57,ANGLEUNIT["degree",0.0174532925199433]],PARAMETER["Scale factor at natural origin",0.9996,SCALEUNIT["unity",1]],PARAMETER["False easting",500000,LENGTHUNIT["metre",1]],PARAMETER["False northing",10000000,LENGTHUNIT["metre",1]]],CS[Cartesian,2],AXIS["easting (E)",east,ORDER[1],LENGTHUNIT["metre",1]],AXIS["northing (N)",north,ORDER[2],LENGTHUNIT["metre",1]],USAGE[SCOPE["Engineering survey, topographic mapping."],AREA["Reunion - onshore and offshore."],BBOX[-24.72,51.83,-18.28,58.24]],ID["EPSG",2975]]'
);

-- Mayotte - RGM04 / UTM zone 38S - EPSG:4471
INSERT OR REPLACE INTO gpkg_spatial_ref_sys (
    srs_name, srs_id, organization, organization_coordsys_id, 
    definition, description, definition_12_063
) VALUES (
    'RGM04 / UTM zone 38S',
    4471,
    'EPSG',
    4471,
    'PROJCS["RGM04 / UTM zone 38S",GEOGCS["RGM04",DATUM["Reseau_Geodesique_de_Mayotte_2004",SPHEROID["GRS 1980",6378137,298.257222101]],PRIMEM["Greenwich",0],UNIT["degree",0.0174532925199433]],PROJECTION["Transverse_Mercator"],PARAMETER["latitude_of_origin",0],PARAMETER["central_meridian",45],PARAMETER["scale_factor",0.9996],PARAMETER["false_easting",500000],PARAMETER["false_northing",10000000],UNIT["metre",1],AXIS["Easting",EAST],AXIS["Northing",NORTH]]',
    'RGM04 UTM Sud fuseau 38 - Système légal pour Mayotte (compatible WGS84). Altimétrie: IGN 1950 / SHOM 1953.',
    'PROJCRS["RGM04 / UTM zone 38S",BASEGEOGCRS["RGM04",DATUM["Reseau Geodesique de Mayotte 2004",ELLIPSOID["GRS 1980",6378137,298.257222101,LENGTHUNIT["metre",1]]],PRIMEM["Greenwich",0,ANGLEUNIT["degree",0.0174532925199433]]],CONVERSION["UTM zone 38S",METHOD["Transverse Mercator",ID["EPSG",9807]],PARAMETER["Latitude of natural origin",0,ANGLEUNIT["degree",0.0174532925199433]],PARAMETER["Longitude of natural origin",45,ANGLEUNIT["degree",0.0174532925199433]],PARAMETER["Scale factor at natural origin",0.9996,SCALEUNIT["unity",1]],PARAMETER["False easting",500000,LENGTHUNIT["metre",1]],PARAMETER["False northing",10000000,LENGTHUNIT["metre",1]]],CS[Cartesian,2],AXIS["easting (E)",east,ORDER[1],LENGTHUNIT["metre",1]],AXIS["northing (N)",north,ORDER[2],LENGTHUNIT["metre",1]],USAGE[SCOPE["Engineering survey, topographic mapping."],AREA["Mayotte - onshore and offshore."],BBOX[-14.49,43.68,-11.33,46.7]],ID["EPSG",4471]]'
);

-- ============================================================================
-- OCÉAN PACIFIQUE
-- ============================================================================

-- Nouvelle-Calédonie - RGNC91-93 / Lambert New Caledonia - EPSG:3163
INSERT OR REPLACE INTO gpkg_spatial_ref_sys (
    srs_name, srs_id, organization, organization_coordsys_id, 
    definition, description, definition_12_063
) VALUES (
    'RGNC91-93 / Lambert New Caledonia',
    3163,
    'EPSG',
    3163,
    'PROJCS["RGNC91-93 / Lambert New Caledonia",GEOGCS["RGNC91-93",DATUM["Reseau_Geodesique_de_Nouvelle_Caledonie_1991-93",SPHEROID["GRS 1980",6378137,298.257222101]],PRIMEM["Greenwich",0],UNIT["degree",0.0174532925199433]],PROJECTION["Lambert_Conformal_Conic_1SP"],PARAMETER["latitude_of_origin",-21.5],PARAMETER["central_meridian",166],PARAMETER["scale_factor",1],PARAMETER["false_easting",400000],PARAMETER["false_northing",300000],UNIT["metre",1],AXIS["Easting",EAST],AXIS["Northing",NORTH]]',
    'RGNC91-93 Lambert Nouvelle-Calédonie - Système légal pour la Nouvelle-Calédonie.',
    'PROJCRS["RGNC91-93 / Lambert New Caledonia",BASEGEOGCRS["RGNC91-93",DATUM["Reseau Geodesique de Nouvelle Caledonie 1991-93",ELLIPSOID["GRS 1980",6378137,298.257222101,LENGTHUNIT["metre",1]]],PRIMEM["Greenwich",0,ANGLEUNIT["degree",0.0174532925199433]]],CONVERSION["Lambert New Caledonia",METHOD["Lambert Conic Conformal (1SP)",ID["EPSG",9801]],PARAMETER["Latitude of natural origin",-21.5,ANGLEUNIT["degree",0.0174532925199433]],PARAMETER["Longitude of natural origin",166,ANGLEUNIT["degree",0.0174532925199433]],PARAMETER["Scale factor at natural origin",1,SCALEUNIT["unity",1]],PARAMETER["False easting",400000,LENGTHUNIT["metre",1]],PARAMETER["False northing",300000,LENGTHUNIT["metre",1]]],CS[Cartesian,2],AXIS["easting (X)",east,ORDER[1],LENGTHUNIT["metre",1]],AXIS["northing (Y)",north,ORDER[2],LENGTHUNIT["metre",1]],USAGE[SCOPE["Engineering survey, topographic mapping."],AREA["New Caledonia - Grande Terre, Iles Loyaute, etc."],BBOX[-23.41,162.84,-17.61,169.2]],ID["EPSG",3163]]'
);

-- Wallis-et-Futuna - RGWF96 / UTM zone 1S - EPSG:8902
INSERT OR REPLACE INTO gpkg_spatial_ref_sys (
    srs_name, srs_id, organization, organization_coordsys_id, 
    definition, description, definition_12_063
) VALUES (
    'RGWF96 / UTM zone 1S',
    8902,
    'EPSG',
    8902,
    'PROJCS["RGWF96 / UTM zone 1S",GEOGCS["RGWF96",DATUM["Reseau_Geodesique_de_Wallis_et_Futuna_1996",SPHEROID["GRS 1980",6378137,298.257222101]],PRIMEM["Greenwich",0],UNIT["degree",0.0174532925199433]],PROJECTION["Transverse_Mercator"],PARAMETER["latitude_of_origin",0],PARAMETER["central_meridian",-177],PARAMETER["scale_factor",0.9996],PARAMETER["false_easting",500000],PARAMETER["false_northing",10000000],UNIT["metre",1],AXIS["Easting",EAST],AXIS["Northing",NORTH]]',
    'RGWF96 UTM Sud fuseau 1 - Système pour Wallis-et-Futuna.',
    'PROJCRS["RGWF96 / UTM zone 1S",BASEGEOGCRS["RGWF96",DATUM["Reseau Geodesique de Wallis et Futuna 1996",ELLIPSOID["GRS 1980",6378137,298.257222101,LENGTHUNIT["metre",1]]],PRIMEM["Greenwich",0,ANGLEUNIT["degree",0.0174532925199433]]],CONVERSION["UTM zone 1S",METHOD["Transverse Mercator",ID["EPSG",9807]],PARAMETER["Latitude of natural origin",0,ANGLEUNIT["degree",0.0174532925199433]],PARAMETER["Longitude of natural origin",-177,ANGLEUNIT["degree",0.0174532925199433]],PARAMETER["Scale factor at natural origin",0.9996,SCALEUNIT["unity",1]],PARAMETER["False easting",500000,LENGTHUNIT["metre",1]],PARAMETER["False northing",10000000,LENGTHUNIT["metre",1]]],CS[Cartesian,2],AXIS["easting (E)",east,ORDER[1],LENGTHUNIT["metre",1]],AXIS["northing (N)",north,ORDER[2],LENGTHUNIT["metre",1]],USAGE[SCOPE["Engineering survey, topographic mapping."],AREA["Wallis and Futuna - onshore and offshore."],BBOX[-15.94,-179.84,-12.92,-175.91]],ID["EPSG",8902]]'
);

-- Polynésie Française - RGPF / UTM zone 6S - EPSG:3297
INSERT OR REPLACE INTO gpkg_spatial_ref_sys (
    srs_name, srs_id, organization, organization_coordsys_id, 
    definition, description, definition_12_063
) VALUES (
    'RGPF / UTM zone 6S',
    3297,
    'EPSG',
    3297,
    'PROJCS["RGPF / UTM zone 6S",GEOGCS["RGPF",DATUM["Reseau_Geodesique_de_la_Polynesie_Francaise",SPHEROID["GRS 1980",6378137,298.257222101]],PRIMEM["Greenwich",0],UNIT["degree",0.0174532925199433]],PROJECTION["Transverse_Mercator"],PARAMETER["latitude_of_origin",0],PARAMETER["central_meridian",-147],PARAMETER["scale_factor",0.9996],PARAMETER["false_easting",500000],PARAMETER["false_northing",10000000],UNIT["metre",1],AXIS["Easting",EAST],AXIS["Northing",NORTH]]',
    'RGPF UTM Sud fuseau 6 - Système pour la Polynésie Française (Îles de la Société et Australes ouest).',
    'PROJCRS["RGPF / UTM zone 6S",BASEGEOGCRS["RGPF",DATUM["Reseau Geodesique de la Polynesie Francaise",ELLIPSOID["GRS 1980",6378137,298.257222101,LENGTHUNIT["metre",1]]],PRIMEM["Greenwich",0,ANGLEUNIT["degree",0.0174532925199433]]],CONVERSION["UTM zone 6S",METHOD["Transverse Mercator",ID["EPSG",9807]],PARAMETER["Latitude of natural origin",0,ANGLEUNIT["degree",0.0174532925199433]],PARAMETER["Longitude of natural origin",-147,ANGLEUNIT["degree",0.0174532925199433]],PARAMETER["Scale factor at natural origin",0.9996,SCALEUNIT["unity",1]],PARAMETER["False easting",500000,LENGTHUNIT["metre",1]],PARAMETER["False northing",10000000,LENGTHUNIT["metre",1]]],CS[Cartesian,2],AXIS["easting (E)",east,ORDER[1],LENGTHUNIT["metre",1]],AXIS["northing (N)",north,ORDER[2],LENGTHUNIT["metre",1]],USAGE[SCOPE["Engineering survey, topographic mapping."],AREA["French Polynesia - Society Islands, Austral Islands (west)."],BBOX[-28.09,-154.73,-16.1,-148.6]],ID["EPSG",3297]]'
);

-- Polynésie Française - RGPF / UTM zone 7S - EPSG:3298
INSERT OR REPLACE INTO gpkg_spatial_ref_sys (
    srs_name, srs_id, organization, organization_coordsys_id, 
    definition, description, definition_12_063
) VALUES (
    'RGPF / UTM zone 7S',
    3298,
    'EPSG',
    3298,
    'PROJCS["RGPF / UTM zone 7S",GEOGCS["RGPF",DATUM["Reseau_Geodesique_de_la_Polynesie_Francaise",SPHEROID["GRS 1980",6378137,298.257222101]],PRIMEM["Greenwich",0],UNIT["degree",0.0174532925199433]],PROJECTION["Transverse_Mercator"],PARAMETER["latitude_of_origin",0],PARAMETER["central_meridian",-141],PARAMETER["scale_factor",0.9996],PARAMETER["false_easting",500000],PARAMETER["false_northing",10000000],UNIT["metre",1],AXIS["Easting",EAST],AXIS["Northing",NORTH]]',
    'RGPF UTM Sud fuseau 7 - Système pour la Polynésie Française (Australes est, Tuamotu ouest).',
    'PROJCRS["RGPF / UTM zone 7S",BASEGEOGCRS["RGPF",DATUM["Reseau Geodesique de la Polynesie Francaise",ELLIPSOID["GRS 1980",6378137,298.257222101,LENGTHUNIT["metre",1]]],PRIMEM["Greenwich",0,ANGLEUNIT["degree",0.0174532925199433]]],CONVERSION["UTM zone 7S",METHOD["Transverse Mercator",ID["EPSG",9807]],PARAMETER["Latitude of natural origin",0,ANGLEUNIT["degree",0.0174532925199433]],PARAMETER["Longitude of natural origin",-141,ANGLEUNIT["degree",0.0174532925199433]],PARAMETER["Scale factor at natural origin",0.9996,SCALEUNIT["unity",1]],PARAMETER["False easting",500000,LENGTHUNIT["metre",1]],PARAMETER["False northing",10000000,LENGTHUNIT["metre",1]]],CS[Cartesian,2],AXIS["easting (E)",east,ORDER[1],LENGTHUNIT["metre",1]],AXIS["northing (N)",north,ORDER[2],LENGTHUNIT["metre",1]],USAGE[SCOPE["Engineering survey, topographic mapping."],AREA["French Polynesia - Austral Islands (east), Tuamotu Archipelago (west)."],BBOX[-28.09,-148.6,-14.2,-137.58]],ID["EPSG",3298]]'
);

-- Polynésie Française - RGPF / UTM zone 5S - EPSG:2976 (Marquises)
INSERT OR REPLACE INTO gpkg_spatial_ref_sys (
    srs_name, srs_id, organization, organization_coordsys_id, 
    definition, description, definition_12_063
) VALUES (
    'RGPF / UTM zone 5S',
    2976,
    'EPSG',
    2976,
    'PROJCS["RGPF / UTM zone 5S",GEOGCS["RGPF",DATUM["Reseau_Geodesique_de_la_Polynesie_Francaise",SPHEROID["GRS 1980",6378137,298.257222101]],PRIMEM["Greenwich",0],UNIT["degree",0.0174532925199433]],PROJECTION["Transverse_Mercator"],PARAMETER["latitude_of_origin",0],PARAMETER["central_meridian",-153],PARAMETER["scale_factor",0.9996],PARAMETER["false_easting",500000],PARAMETER["false_northing",10000000],UNIT["metre",1],AXIS["Easting",EAST],AXIS["Northing",NORTH]]',
    'RGPF UTM Sud fuseau 5 - Système pour la Polynésie Française (Îles Marquises).',
    'PROJCRS["RGPF / UTM zone 5S",BASEGEOGCRS["RGPF",DATUM["Reseau Geodesique de la Polynesie Francaise",ELLIPSOID["GRS 1980",6378137,298.257222101,LENGTHUNIT["metre",1]]],PRIMEM["Greenwich",0,ANGLEUNIT["degree",0.0174532925199433]]],CONVERSION["UTM zone 5S",METHOD["Transverse Mercator",ID["EPSG",9807]],PARAMETER["Latitude of natural origin",0,ANGLEUNIT["degree",0.0174532925199433]],PARAMETER["Longitude of natural origin",-153,ANGLEUNIT["degree",0.0174532925199433]],PARAMETER["Scale factor at natural origin",0.9996,SCALEUNIT["unity",1]],PARAMETER["False easting",500000,LENGTHUNIT["metre",1]],PARAMETER["False northing",10000000,LENGTHUNIT["metre",1]]],CS[Cartesian,2],AXIS["easting (E)",east,ORDER[1],LENGTHUNIT["metre",1]],AXIS["northing (N)",north,ORDER[2],LENGTHUNIT["metre",1]],USAGE[SCOPE["Engineering survey, topographic mapping."],AREA["French Polynesia - Marquesas Islands."],BBOX[-11.03,-140.96,-7.65,-138.39]],ID["EPSG",2976]]'
);

-- Clipperton - RGPF (utilise WGS84 en pratique) - EPSG:4326
-- Note: Clipperton n'a pas de système officiel propre, utilisation de WGS84

-- ============================================================================
-- TERRES AUSTRALES ET ANTARCTIQUES FRANÇAISES (TAAF)
-- ============================================================================

-- Îles Éparses / Terres australes - WGS84 / UTM selon zone
-- Note: Les TAAF utilisent différentes zones UTM selon les îles

-- Kerguelen - RGTAAF07 / UTM zone 42S - EPSG:7073
INSERT OR REPLACE INTO gpkg_spatial_ref_sys (
    srs_name, srs_id, organization, organization_coordsys_id, 
    definition, description, definition_12_063
) VALUES (
    'RGTAAF07 / UTM zone 42S',
    7073,
    'EPSG',
    7073,
    'PROJCS["RGTAAF07 / UTM zone 42S",GEOGCS["RGTAAF07",DATUM["Reseau_Geodesique_des_TAAF_2007",SPHEROID["GRS 1980",6378137,298.257222101]],PRIMEM["Greenwich",0],UNIT["degree",0.0174532925199433]],PROJECTION["Transverse_Mercator"],PARAMETER["latitude_of_origin",0],PARAMETER["central_meridian",69],PARAMETER["scale_factor",0.9996],PARAMETER["false_easting",500000],PARAMETER["false_northing",10000000],UNIT["metre",1],AXIS["Easting",EAST],AXIS["Northing",NORTH]]',
    'RGTAAF07 UTM Sud fuseau 42 - Système pour les Îles Kerguelen.',
    'PROJCRS["RGTAAF07 / UTM zone 42S",BASEGEOGCRS["RGTAAF07",DATUM["Reseau Geodesique des TAAF 2007",ELLIPSOID["GRS 1980",6378137,298.257222101,LENGTHUNIT["metre",1]]],PRIMEM["Greenwich",0,ANGLEUNIT["degree",0.0174532925199433]]],CONVERSION["UTM zone 42S",METHOD["Transverse Mercator",ID["EPSG",9807]],PARAMETER["Latitude of natural origin",0,ANGLEUNIT["degree",0.0174532925199433]],PARAMETER["Longitude of natural origin",69,ANGLEUNIT["degree",0.0174532925199433]],PARAMETER["Scale factor at natural origin",0.9996,SCALEUNIT["unity",1]],PARAMETER["False easting",500000,LENGTHUNIT["metre",1]],PARAMETER["False northing",10000000,LENGTHUNIT["metre",1]]],CS[Cartesian,2],AXIS["easting (E)",east,ORDER[1],LENGTHUNIT["metre",1]],AXIS["northing (N)",north,ORDER[2],LENGTHUNIT["metre",1]],USAGE[SCOPE["Engineering survey, topographic mapping."],AREA["Kerguelen - onshore and offshore."],BBOX[-50.19,67.84,-48.31,71.47]],ID["EPSG",7073]]'
);

-- Crozet - RGTAAF07 / UTM zone 39S - EPSG:7072
INSERT OR REPLACE INTO gpkg_spatial_ref_sys (
    srs_name, srs_id, organization, organization_coordsys_id, 
    definition, description, definition_12_063
) VALUES (
    'RGTAAF07 / UTM zone 39S',
    7072,
    'EPSG',
    7072,
    'PROJCS["RGTAAF07 / UTM zone 39S",GEOGCS["RGTAAF07",DATUM["Reseau_Geodesique_des_TAAF_2007",SPHEROID["GRS 1980",6378137,298.257222101]],PRIMEM["Greenwich",0],UNIT["degree",0.0174532925199433]],PROJECTION["Transverse_Mercator"],PARAMETER["latitude_of_origin",0],PARAMETER["central_meridian",51],PARAMETER["scale_factor",0.9996],PARAMETER["false_easting",500000],PARAMETER["false_northing",10000000],UNIT["metre",1],AXIS["Easting",EAST],AXIS["Northing",NORTH]]',
    'RGTAAF07 UTM Sud fuseau 39 - Système pour les Îles Crozet.',
    'PROJCRS["RGTAAF07 / UTM zone 39S",BASEGEOGCRS["RGTAAF07",DATUM["Reseau Geodesique des TAAF 2007",ELLIPSOID["GRS 1980",6378137,298.257222101,LENGTHUNIT["metre",1]]],PRIMEM["Greenwich",0,ANGLEUNIT["degree",0.0174532925199433]]],CONVERSION["UTM zone 39S",METHOD["Transverse Mercator",ID["EPSG",9807]],PARAMETER["Latitude of natural origin",0,ANGLEUNIT["degree",0.0174532925199433]],PARAMETER["Longitude of natural origin",51,ANGLEUNIT["degree",0.0174532925199433]],PARAMETER["Scale factor at natural origin",0.9996,SCALEUNIT["unity",1]],PARAMETER["False easting",500000,LENGTHUNIT["metre",1]],PARAMETER["False northing",10000000,LENGTHUNIT["metre",1]]],CS[Cartesian,2],AXIS["easting (E)",east,ORDER[1],LENGTHUNIT["metre",1]],AXIS["northing (N)",north,ORDER[2],LENGTHUNIT["metre",1]],USAGE[SCOPE["Engineering survey, topographic mapping."],AREA["Crozet - onshore and offshore."],BBOX[-46.79,49.96,-45.76,52.58]],ID["EPSG",7072]]'
);

-- Amsterdam & Saint-Paul - RGTAAF07 / UTM zone 38S - EPSG:7071
INSERT OR REPLACE INTO gpkg_spatial_ref_sys (
    srs_name, srs_id, organization, organization_coordsys_id, 
    definition, description, definition_12_063
) VALUES (
    'RGTAAF07 / UTM zone 38S',
    7071,
    'EPSG',
    7071,
    'PROJCS["RGTAAF07 / UTM zone 38S",GEOGCS["RGTAAF07",DATUM["Reseau_Geodesique_des_TAAF_2007",SPHEROID["GRS 1980",6378137,298.257222101]],PRIMEM["Greenwich",0],UNIT["degree",0.0174532925199433]],PROJECTION["Transverse_Mercator"],PARAMETER["latitude_of_origin",0],PARAMETER["central_meridian",45],PARAMETER["scale_factor",0.9996],PARAMETER["false_easting",500000],PARAMETER["false_northing",10000000],UNIT["metre",1],AXIS["Easting",EAST],AXIS["Northing",NORTH]]',
    'RGTAAF07 UTM Sud fuseau 38 - Système pour les Îles Amsterdam et Saint-Paul.',
    'PROJCRS["RGTAAF07 / UTM zone 38S",BASEGEOGCRS["RGTAAF07",DATUM["Reseau Geodesique des TAAF 2007",ELLIPSOID["GRS 1980",6378137,298.257222101,LENGTHUNIT["metre",1]]],PRIMEM["Greenwich",0,ANGLEUNIT["degree",0.0174532925199433]]],CONVERSION["UTM zone 38S",METHOD["Transverse Mercator",ID["EPSG",9807]],PARAMETER["Latitude of natural origin",0,ANGLEUNIT["degree",0.0174532925199433]],PARAMETER["Longitude of natural origin",45,ANGLEUNIT["degree",0.0174532925199433]],PARAMETER["Scale factor at natural origin",0.9996,SCALEUNIT["unity",1]],PARAMETER["False easting",500000,LENGTHUNIT["metre",1]],PARAMETER["False northing",10000000,LENGTHUNIT["metre",1]]],CS[Cartesian,2],AXIS["easting (E)",east,ORDER[1],LENGTHUNIT["metre",1]],AXIS["northing (N)",north,ORDER[2],LENGTHUNIT["metre",1]],USAGE[SCOPE["Engineering survey, topographic mapping."],AREA["Amsterdam and Saint Paul - onshore and offshore."],BBOX[-38.77,77.27,-37.73,77.7]],ID["EPSG",7071]]'
);

-- Terre Adélie (Antarctique) - RGTAAF07 / Terre Adélie Polar Stereographic - EPSG:7074
INSERT OR REPLACE INTO gpkg_spatial_ref_sys (
    srs_name, srs_id, organization, organization_coordsys_id, 
    definition, description, definition_12_063
) VALUES (
    'RGTAAF07 / Terre Adelie Polar Stereographic',
    7074,
    'EPSG',
    7074,
    'PROJCS["RGTAAF07 / Terre Adelie Polar Stereographic",GEOGCS["RGTAAF07",DATUM["Reseau_Geodesique_des_TAAF_2007",SPHEROID["GRS 1980",6378137,298.257222101]],PRIMEM["Greenwich",0],UNIT["degree",0.0174532925199433]],PROJECTION["Polar_Stereographic"],PARAMETER["latitude_of_origin",-67],PARAMETER["central_meridian",140],PARAMETER["scale_factor",1],PARAMETER["false_easting",300000],PARAMETER["false_northing",200000],UNIT["metre",1],AXIS["Easting",EAST],AXIS["Northing",NORTH]]',
    'RGTAAF07 Stéréographique Polaire - Système pour la Terre Adélie (Antarctique).',
    'PROJCRS["RGTAAF07 / Terre Adelie Polar Stereographic",BASEGEOGCRS["RGTAAF07",DATUM["Reseau Geodesique des TAAF 2007",ELLIPSOID["GRS 1980",6378137,298.257222101,LENGTHUNIT["metre",1]]],PRIMEM["Greenwich",0,ANGLEUNIT["degree",0.0174532925199433]]],CONVERSION["Terre Adelie Polar Stereographic",METHOD["Polar Stereographic (variant B)",ID["EPSG",9829]],PARAMETER["Latitude of standard parallel",-67,ANGLEUNIT["degree",0.0174532925199433]],PARAMETER["Longitude of origin",140,ANGLEUNIT["degree",0.0174532925199433]],PARAMETER["False easting",300000,LENGTHUNIT["metre",1]],PARAMETER["False northing",200000,LENGTHUNIT["metre",1]]],CS[Cartesian,2],AXIS["easting (X)",north,ORDER[1],LENGTHUNIT["metre",1]],AXIS["northing (Y)",north,ORDER[2],LENGTHUNIT["metre",1]],USAGE[SCOPE["Engineering survey, topographic mapping."],AREA["Terre Adelie - onshore and offshore."],BBOX[-67.13,136.0,-65.61,142.0]],ID["EPSG",7074]]'
);

-- ============================================================================
-- AMÉRIQUE DU NORD
-- ============================================================================

-- Saint-Pierre-et-Miquelon - RGSPM06 / UTM zone 21N - EPSG:4467
INSERT OR REPLACE INTO gpkg_spatial_ref_sys (
    srs_name, srs_id, organization, organization_coordsys_id, 
    definition, description, definition_12_063
) VALUES (
    'RGSPM06 / UTM zone 21N',
    4467,
    'EPSG',
    4467,
    'PROJCS["RGSPM06 / UTM zone 21N",GEOGCS["RGSPM06",DATUM["Reseau_Geodesique_de_Saint_Pierre_et_Miquelon_2006",SPHEROID["GRS 1980",6378137,298.257222101]],PRIMEM["Greenwich",0],UNIT["degree",0.0174532925199433]],PROJECTION["Transverse_Mercator"],PARAMETER["latitude_of_origin",0],PARAMETER["central_meridian",-57],PARAMETER["scale_factor",0.9996],PARAMETER["false_easting",500000],PARAMETER["false_northing",0],UNIT["metre",1],AXIS["Easting",EAST],AXIS["Northing",NORTH]]',
    'RGSPM06 UTM Nord fuseau 21 - Système légal pour Saint-Pierre-et-Miquelon.',
    'PROJCRS["RGSPM06 / UTM zone 21N",BASEGEOGCRS["RGSPM06",DATUM["Reseau Geodesique de Saint Pierre et Miquelon 2006",ELLIPSOID["GRS 1980",6378137,298.257222101,LENGTHUNIT["metre",1]]],PRIMEM["Greenwich",0,ANGLEUNIT["degree",0.0174532925199433]]],CONVERSION["UTM zone 21N",METHOD["Transverse Mercator",ID["EPSG",9807]],PARAMETER["Latitude of natural origin",0,ANGLEUNIT["degree",0.0174532925199433]],PARAMETER["Longitude of natural origin",-57,ANGLEUNIT["degree",0.0174532925199433]],PARAMETER["Scale factor at natural origin",0.9996,SCALEUNIT["unity",1]],PARAMETER["False easting",500000,LENGTHUNIT["metre",1]],PARAMETER["False northing",0,LENGTHUNIT["metre",1]]],CS[Cartesian,2],AXIS["easting (E)",east,ORDER[1],LENGTHUNIT["metre",1]],AXIS["northing (N)",north,ORDER[2],LENGTHUNIT["metre",1]],USAGE[SCOPE["Engineering survey, topographic mapping."],AREA["Saint Pierre and Miquelon - onshore and offshore."],BBOX[43.41,-57.1,47.37,-55.9]],ID["EPSG",4467]]'
);

-- ============================================================================
-- 1. TABLE ATLAS PAYSAGER (obligatoire - 1 seule instance par atlas)
-- ============================================================================

CREATE TABLE atlas_paysager (
    fid INTEGER PRIMARY KEY AUTOINCREMENT,
    emprise MULTIPOLYGON NOT NULL,
    nom TEXT NOT NULL,
    identifiant TEXT NOT NULL UNIQUE,
    maitre_ouvrage TEXT NOT NULL,
    maitre_oeuvre TEXT NOT NULL,
    type_atlas TEXT NOT NULL CHECK (type_atlas IN ('département', 'région', 'parc naturel', 'autre')),
    lien_atlas TEXT NOT NULL, -- URL vers l'atlas en ligne
    date_realisation_atlas DATE NOT NULL,
    date_revision_dynamiques DATE,
    lien_opp TEXT -- URL vers l'Observatoire Photographique des Paysages
);

-- Métadonnées de la table
INSERT INTO gpkg_contents (
    table_name, data_type, identifier, description, 
    last_change, min_x, min_y, max_x, max_y, srs_id
) VALUES (
    'atlas_paysager', 'features', 'atlas-paysager',
    'Un atlas du paysage est un document de connaissance des paysages. Cette classe fournit des informations générales sur l''atlas, ses conditions de réalisation et de mise à jour.',
    strftime('%Y-%m-%dT%H:%M:%fZ', 'now'),
    -180.0, -67.13, 180.0, 51.56, 2154
);

-- Géométrie
INSERT INTO gpkg_geometry_columns (
    table_name, column_name, geometry_type_name, srs_id, z, m
) VALUES (
    'atlas_paysager', 'emprise', 'MULTIPOLYGON', 2154, 0, 0
);

-- Index spatial
CREATE INDEX idx_atlas_paysager_emprise ON atlas_paysager(emprise);

-- ============================================================================
-- 2. TABLE UNITE PAYSAGÈRE (conditionnel - découpage central)
-- ============================================================================

CREATE TABLE unite_paysagere (
    fid INTEGER PRIMARY KEY AUTOINCREMENT,
    geometrie MULTIPOLYGON NOT NULL,
    identifiant_local TEXT NOT NULL,
    identifiant_global TEXT NOT NULL UNIQUE,
    nom TEXT NOT NULL,
    lien_page_atlas TEXT NOT NULL, -- URL vers la page dédiée dans l'atlas
    type_orographie1 TEXT NOT NULL CHECK (type_orographie1 IN (
        'marin', 'littoral', 'lacustre', 'cours d''eau', 'plaine', 
        'plateau', 'coteau', 'vallée', 'montagne', 'autre relief marqué'
    )),
    type_orographie2 TEXT CHECK (type_orographie2 IN (
        'marin', 'littoral', 'lacustre', 'cours d''eau', 'plaine', 
        'plateau', 'coteau', 'vallée', 'montagne', 'autre relief marqué'
    )),
    dominante_paysagere1 TEXT NOT NULL CHECK (dominante_paysagere1 IN (
        'paysage bâti continu', 'paysage bâti discontinu', 
        'paysage d''infrastructures', 'paysage agricole', 'paysage boisé', 
        'paysage d''eau ou humide', 'paysage ouvert naturel'
    )),
    dominante_paysagere2 TEXT CHECK (dominante_paysagere2 IN (
        'paysage bâti continu', 'paysage bâti discontinu', 
        'paysage d''infrastructures', 'paysage agricole', 'paysage boisé', 
        'paysage d''eau ou humide', 'paysage ouvert naturel'
    )),
    type_local TEXT,
    mot_clef_generique TEXT NOT NULL, -- JSON array
    mot_clef_toponymique TEXT NOT NULL, -- JSON array
    description TEXT,
    image TEXT, -- URL
    date_definition DATE,
    date_actualisation DATE,
    lien_atlas_paysage TEXT NOT NULL,
    code_departement TEXT NOT NULL, -- JSON array
    code_region TEXT NOT NULL, -- JSON array
    lien_ep TEXT, -- Lien vers ensemble paysager
    
    -- Contraintes de clés étrangères
    FOREIGN KEY (lien_atlas_paysage) REFERENCES atlas_paysager(identifiant) ON DELETE CASCADE,
    FOREIGN KEY (lien_ep) REFERENCES ensemble_paysager(identifiant_global) ON DELETE SET NULL,
    
    -- Contrainte: identifiant_global = lien_atlas_paysage + '.' + identifiant_local
    CHECK (identifiant_global = lien_atlas_paysage || '.' || identifiant_local)
);

INSERT INTO gpkg_contents (
    table_name, data_type, identifier, description, 
    last_change, min_x, min_y, max_x, max_y, srs_id
) VALUES (
    'unite_paysagere', 'features', 'unite-paysagere',
    'L''unité paysagère est le découpage paysager central. Elle désigne une partie continue de territoire homogène au regard de ses caractéristiques géomorphologiques, écologiques, d''occupation du sol et de perception.',
    strftime('%Y-%m-%dT%H:%M:%fZ', 'now'),
    -180.0, -67.13, 180.0, 51.56, 2154
);

INSERT INTO gpkg_geometry_columns (
    table_name, column_name, geometry_type_name, srs_id, z, m
) VALUES (
    'unite_paysagere', 'geometrie', 'MULTIPOLYGON', 2154, 0, 0
);

CREATE INDEX idx_unite_paysagere_geometrie ON unite_paysagere(geometrie);
CREATE INDEX idx_unite_paysagere_atlas ON unite_paysagere(lien_atlas_paysage);
CREATE INDEX idx_unite_paysagere_ep ON unite_paysagere(lien_ep);

-- ============================================================================
-- 3. TABLE ENSEMBLE PAYSAGER (conditionnel - échelle régionale)
-- ============================================================================

CREATE TABLE ensemble_paysager (
    fid INTEGER PRIMARY KEY AUTOINCREMENT,
    geometrie MULTIPOLYGON NOT NULL,
    identifiant_local TEXT NOT NULL,
    identifiant_global TEXT NOT NULL UNIQUE,
    nom TEXT NOT NULL,
    lien_page_atlas TEXT NOT NULL, -- URL
    mot_clef_generique TEXT NOT NULL, -- JSON array
    mot_clef_toponymique TEXT NOT NULL, -- JSON array
    description TEXT,
    image TEXT, -- URL
    date_definition DATE,
    date_actualisation DATE,
    lien_atlas_paysage TEXT NOT NULL,
    code_departement TEXT NOT NULL, -- JSON array
    code_region TEXT NOT NULL, -- JSON array
    
    FOREIGN KEY (lien_atlas_paysage) REFERENCES atlas_paysager(identifiant) ON DELETE CASCADE,
    CHECK (identifiant_global = lien_atlas_paysage || '.' || identifiant_local)
);

INSERT INTO gpkg_contents (
    table_name, data_type, identifier, description, 
    last_change, min_x, min_y, max_x, max_y, srs_id
) VALUES (
    'ensemble_paysager', 'features', 'ensemble-paysager',
    'Un ensemble paysager est observé à l''échelle d''un territoire régional. Il est issu de l''association de plusieurs unités paysagères dont les caractéristiques sont cohérentes à l''échelle dézoomée.',
    strftime('%Y-%m-%dT%H:%M:%fZ', 'now'),
    -180.0, -67.13, 180.0, 51.56, 2154
);

INSERT INTO gpkg_geometry_columns (
    table_name, column_name, geometry_type_name, srs_id, z, m
) VALUES (
    'ensemble_paysager', 'geometrie', 'MULTIPOLYGON', 2154, 0, 0
);

CREATE INDEX idx_ensemble_paysager_geometrie ON ensemble_paysager(geometrie);
CREATE INDEX idx_ensemble_paysager_atlas ON ensemble_paysager(lien_atlas_paysage);

-- ============================================================================
-- 4. TABLE SOUS-UNITÉ PAYSAGÈRE (conditionnel - subdivision fine)
-- ============================================================================

CREATE TABLE sous_unite_paysagere (
    fid INTEGER PRIMARY KEY AUTOINCREMENT,
    geometrie MULTIPOLYGON NOT NULL,
    identifiant_local TEXT NOT NULL,
    identifiant_global TEXT NOT NULL UNIQUE,
    nom TEXT NOT NULL,
    lien_page_atlas TEXT NOT NULL, -- URL
    mot_clef_generique TEXT NOT NULL, -- JSON array
    mot_clef_toponymique TEXT NOT NULL, -- JSON array
    description TEXT,
    image TEXT, -- URL
    date_definition DATE,
    date_actualisation DATE,
    lien_atlas_paysage TEXT NOT NULL,
    code_departement TEXT NOT NULL, -- JSON array
    code_region TEXT NOT NULL, -- JSON array
    lien_up TEXT NOT NULL, -- Lien vers unité paysagère parent
    
    FOREIGN KEY (lien_atlas_paysage) REFERENCES atlas_paysager(identifiant) ON DELETE CASCADE,
    FOREIGN KEY (lien_up) REFERENCES unite_paysagere(identifiant_global) ON DELETE CASCADE,
    CHECK (identifiant_global = lien_atlas_paysage || '.' || identifiant_local)
);

INSERT INTO gpkg_contents (
    table_name, data_type, identifier, description, 
    last_change, min_x, min_y, max_x, max_y, srs_id
) VALUES (
    'sous_unite_paysagere', 'features', 'sous-unite-paysagere',
    'Une sous-unité paysagère est une subdivision d''une unité paysagère. Le découpage y est réalisé de manière plus fine, avec de légères variations des composantes paysagères.',
    strftime('%Y-%m-%dT%H:%M:%fZ', 'now'),
    -180.0, -67.13, 180.0, 51.56, 2154
);

INSERT INTO gpkg_geometry_columns (
    table_name, column_name, geometry_type_name, srs_id, z, m
) VALUES (
    'sous_unite_paysagere', 'geometrie', 'MULTIPOLYGON', 2154, 0, 0
);

CREATE INDEX idx_sous_unite_paysagere_geometrie ON sous_unite_paysagere(geometrie);
CREATE INDEX idx_sous_unite_paysagere_atlas ON sous_unite_paysagere(lien_atlas_paysage);
CREATE INDEX idx_sous_unite_paysagere_up ON sous_unite_paysagere(lien_up);

-- ============================================================================
-- 5. TABLE LIMITE DÉCOUPAGE PAYSAGER (recommandé - précision des limites)
-- ============================================================================

CREATE TABLE limite_decoupage_paysager (
    fid INTEGER PRIMARY KEY AUTOINCREMENT,
    geometrie LINESTRING NOT NULL,
    identifiant_local TEXT NOT NULL,
    identifiant_global TEXT NOT NULL UNIQUE,
    statut TEXT CHECK (statut IN ('limite franche', 'limite floue')),
    largeur_estimee INTEGER, -- en mètres
    nature_limite TEXT CHECK (nature_limite IN (
        'limite administrative', 'ligne de crête', 'thalweg', 
        'front urbain', 'rupture de pente', 'horizon en mer', 'autre'
    )),
    lien_atlas TEXT NOT NULL,
    
    FOREIGN KEY (lien_atlas) REFERENCES atlas_paysager(identifiant) ON DELETE CASCADE,
    CHECK (identifiant_global = lien_atlas || '.' || identifiant_local)
);

INSERT INTO gpkg_contents (
    table_name, data_type, identifier, description, 
    last_change, min_x, min_y, max_x, max_y, srs_id
) VALUES (
    'limite_decoupage_paysager', 'features', 'limite-decoupage-paysager',
    'Une limite de découpage paysager est une portion du contour d''un découpage paysager. Elle renseigne sur la nature et la précision de la limite.',
    strftime('%Y-%m-%dT%H:%M:%fZ', 'now'),
    -180.0, -67.13, 180.0, 51.56, 2154
);

INSERT INTO gpkg_geometry_columns (
    table_name, column_name, geometry_type_name, srs_id, z, m
) VALUES (
    'limite_decoupage_paysager', 'geometrie', 'LINESTRING', 2154, 0, 0
);

CREATE INDEX idx_limite_decoupage_paysager_geometrie ON limite_decoupage_paysager(geometrie);
CREATE INDEX idx_limite_decoupage_paysager_atlas ON limite_decoupage_paysager(lien_atlas);

-- ============================================================================
-- 6. TABLE DOCUMENT PAYSAGE (facultatif - illustrations)
-- ============================================================================

CREATE TABLE document_paysage (
    fid INTEGER PRIMARY KEY AUTOINCREMENT,
    geometrie POINT NOT NULL,
    nom TEXT NOT NULL,
    date DATE NOT NULL,
    auteur TEXT NOT NULL,
    conditions_utilisation_texte TEXT,
    conditions_utilisation_url TEXT, -- URL
    document TEXT NOT NULL, -- URL
    lien_atlas_paysage TEXT NOT NULL,
    
    FOREIGN KEY (lien_atlas_paysage) REFERENCES atlas_paysager(identifiant) ON DELETE CASCADE
);

INSERT INTO gpkg_contents (
    table_name, data_type, identifier, description, 
    last_change, min_x, min_y, max_x, max_y, srs_id
) VALUES (
    'document_paysage', 'features', 'document-paysage',
    'Un document paysage illustre un découpage paysager. Il peut s''agir d''un bloc-diagramme, d''une coupe, d''un croquis, d''une photographie, etc.',
    strftime('%Y-%m-%dT%H:%M:%fZ', 'now'),
    -180.0, -67.13, 180.0, 51.56, 2154
);

INSERT INTO gpkg_geometry_columns (
    table_name, column_name, geometry_type_name, srs_id, z, m
) VALUES (
    'document_paysage', 'geometrie', 'POINT', 2154, 0, 0
);

CREATE INDEX idx_document_paysage_geometrie ON document_paysage(geometrie);
CREATE INDEX idx_document_paysage_atlas ON document_paysage(lien_atlas_paysage);

-- ============================================================================
-- 7. TABLE DYNAMIQUE (fortement recommandé - évolutions)
-- ============================================================================

CREATE TABLE dynamique (
    fid INTEGER PRIMARY KEY AUTOINCREMENT,
    objet_evolution TEXT NOT NULL CHECK (objet_evolution IN (
        'zones imperméables', 'zones bâties', 'zones non bâties', 
        'matériaux minéraux', 'matériaux composites', 'sols nus',
        'eaux continentales', 'eaux maritimes', 'névés et glaciers',
        'formations arborées', 'peuplement de feuillus', 'peuplement de conifères',
        'formations arbustives', 'landes', 'végétation sclérophylle',
        'haies et formations arbustives organisées', 'fourrés', 'vignes',
        'formations herbacées', 'prairies naturelles', 'pelouses naturelles',
        'pelouses et prairies urbaines', 'terres arables', 'autres formations herbacées',
        'lichens et mousses', 'bananiers, palmiers et bambous', 'trait de côte',
        'écosystème marin fixe', 'énergie', 'pollution lumineuse', 'autre'
    )),
    nature_evolution TEXT NOT NULL CHECK (nature_evolution IN (
        'apparition', 'augmentation', 'diminution', 'disparition', 'stabilisation'
    )),
    description TEXT,
    date_observation DATE,
    date_fin DATE,
    lien_photo_opp TEXT, -- URL
    lien_up TEXT, -- Référence vers unité paysagère
    lien_ep TEXT, -- Référence vers ensemble paysager
    lien_sous_up TEXT, -- Référence vers sous-unité paysagère
    
    FOREIGN KEY (lien_up) REFERENCES unite_paysagere(identifiant_global) ON DELETE CASCADE,
    FOREIGN KEY (lien_ep) REFERENCES ensemble_paysager(identifiant_global) ON DELETE CASCADE,
    FOREIGN KEY (lien_sous_up) REFERENCES sous_unite_paysagere(identifiant_global) ON DELETE CASCADE,
    
    -- Au moins un lien doit être renseigné
    CHECK (lien_up IS NOT NULL OR lien_ep IS NOT NULL OR lien_sous_up IS NOT NULL)
);

-- Pas de géométrie pour Dynamique (table attributaire)
INSERT INTO gpkg_contents (
    table_name, data_type, identifier, description, last_change
) VALUES (
    'dynamique', 'attributes', 'dynamique',
    'Une dynamique est une évolution du paysage en général depuis la dernière version de l''atlas des paysages. Elle peut s''appliquer à tout niveau de découpage paysager.',
    strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
);

CREATE INDEX idx_dynamique_up ON dynamique(lien_up);
CREATE INDEX idx_dynamique_ep ON dynamique(lien_ep);
CREATE INDEX idx_dynamique_sous_up ON dynamique(lien_sous_up);

-- ============================================================================
-- EXTENSION : MÉTADONNEES ISO 19115
-- ============================================================================

-- Activation de l'extension metadata
INSERT OR IGNORE INTO gpkg_extensions (
    table_name, column_name, extension_name, definition, scope
) VALUES (
    NULL, NULL, 'gpkg_metadata',
    'http://www.geopackage.org/spec/#extension_metadata',
    'read-write'
);

-- Métadonnées globales du dataset (ISO 19115)
INSERT INTO gpkg_metadata (
    id, md_scope, md_standard_uri, mime_type, metadata
) VALUES (
    1, 'dataset', 'http://www.isotc211.org/2005/gmd', 'text/xml',
    '<?xml version="1.0" encoding="UTF-8"?>
<gmd:MD_Metadata xmlns:gmd="http://www.isotc211.org/2005/gmd" 
                  xmlns:gco="http://www.isotc211.org/2005/gco"
                  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                  xsi:schemaLocation="http://www.isotc211.org/2005/gmd http://schemas.opengis.net/iso/19139/20060504/gmd/gmd.xsd">
  
  <!-- Identifiant de la fiche -->
  <gmd:fileIdentifier>
    <gco:CharacterString>fr-cnig-standard-paysage-v1.1.0</gco:CharacterString>
  </gmd:fileIdentifier>
  
  <!-- Langue des métadonnées -->
  <gmd:language>
    <gco:CharacterString>fre</gco:CharacterString>
  </gmd:language>
  
  <!-- Jeu de caractères -->
  <gmd:characterSet>
    <gmd:MD_CharacterSetCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_CharacterSetCode" codeListValue="utf8">utf8</gmd:MD_CharacterSetCode>
  </gmd:characterSet>
  
  <!-- Date des métadonnées -->
  <gmd:dateStamp>
    <gco:Date>2025-12-01</gco:Date>
  </gmd:dateStamp>
  
  <!-- Point de contact pour les métadonnées -->
  <gmd:contact>
    <gmd:CI_ResponsibleParty>
      <gmd:organisationName>
        <gco:CharacterString>CNIG - Conseil National de l''Information Géolocalisée</gco:CharacterString>
      </gmd:organisationName>
      <gmd:contactInfo>
        <gmd:CI_Contact>
          <gmd:address>
            <gmd:CI_Address>
              <gmd:electronicMailAddress>
                <gco:CharacterString>cnig@cnig.fr</gco:CharacterString>
              </gmd:electronicMailAddress>
            </gmd:CI_Address>
          </gmd:address>
          <gmd:onlineResource>
            <gmd:CI_OnlineResource>
              <gmd:linkage>
                <gmd:URL>https://github.com/cnigfr/schema-paysage</gmd:URL>
              </gmd:linkage>
            </gmd:CI_OnlineResource>
          </gmd:onlineResource>
        </gmd:CI_Contact>
      </gmd:contactInfo>
      <gmd:role>
        <gmd:CI_RoleCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_RoleCode" codeListValue="pointOfContact">pointOfContact</gmd:CI_RoleCode>
      </gmd:role>
    </gmd:CI_ResponsibleParty>
  </gmd:contact>
  
  <!-- Informations d''identification -->
  <gmd:identificationInfo>
    <gmd:MD_DataIdentification>
      
      <!-- Citation -->
      <gmd:citation>
        <gmd:CI_Citation>
          <gmd:title>
            <gco:CharacterString>Standard Paysages - CNIG</gco:CharacterString>
          </gmd:title>
          <gmd:date>
            <gmd:CI_Date>
              <gmd:date>
                <gco:Date>2024-12-21</gco:Date>
              </gmd:date>
              <gmd:dateType>
                <gmd:CI_DateTypeCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode" codeListValue="publication">publication</gmd:CI_DateTypeCode>
              </gmd:dateType>
            </gmd:CI_Date>
          </gmd:date>
          <gmd:identifier>
            <gmd:MD_Identifier>
              <gmd:code>
                <gco:CharacterString>CNIG-PAYSAGE-V1.0.0</gco:CharacterString>
              </gmd:code>
            </gmd:MD_Identifier>
          </gmd:identifier>
        </gmd:CI_Citation>
      </gmd:citation>
      
      <!-- Résumé -->
      <gmd:abstract>
        <gco:CharacterString>Implémentation du Standard Paysages du CNIG en format GeoPackage avec support complet de tous les territoires français. Ce standard harmonise les modes de numérisation et d''échange des données géographiques relatives aux paysages issues des atlas de paysages. Il comprend les découpages paysagers (ensembles paysagers, unités paysagères, sous-unités paysagères), leurs limites, les dynamiques d''évolution et les documents illustratifs. Extension WKT for CRS activée avec 16 projections légales françaises.</gco:CharacterString>
      </gmd:abstract>
      
      <!-- Point de contact pour la ressource -->
      <gmd:pointOfContact>
        <gmd:CI_ResponsibleParty>
          <gmd:organisationName>
            <gco:CharacterString>Ministère de la Transition Écologique - Direction de l''Habitat, de l''Urbanisme et des Paysages (DHUP)</gco:CharacterString>
          </gmd:organisationName>
          <gmd:role>
            <gmd:CI_RoleCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_RoleCode" codeListValue="owner">owner</gmd:CI_RoleCode>
          </gmd:role>
        </gmd:CI_ResponsibleParty>
      </gmd:pointOfContact>
      
      <!-- Mots-clés thématiques -->
      <gmd:descriptiveKeywords>
        <gmd:MD_Keywords>
          <gmd:keyword>
            <gco:CharacterString>Paysage</gco:CharacterString>
          </gmd:keyword>
          <gmd:keyword>
            <gco:CharacterString>Atlas de paysages</gco:CharacterString>
          </gmd:keyword>
          <gmd:keyword>
            <gco:CharacterString>Unité paysagère</gco:CharacterString>
          </gmd:keyword>
          <gmd:keyword>
            <gco:CharacterString>Ensemble paysager</gco:CharacterString>
          </gmd:keyword>
          <gmd:keyword>
            <gco:CharacterString>Dynamiques paysagères</gco:CharacterString>
          </gmd:keyword>
          <gmd:type>
            <gmd:MD_KeywordTypeCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode" codeListValue="theme">theme</gmd:MD_KeywordTypeCode>
          </gmd:type>
        </gmd:MD_Keywords>
      </gmd:descriptiveKeywords>
      
      <!-- Mots-clés géographiques -->
      <gmd:descriptiveKeywords>
        <gmd:MD_Keywords>
          <gmd:keyword>
            <gco:CharacterString>France métropolitaine</gco:CharacterString>
          </gmd:keyword>
          <gmd:keyword>
            <gco:CharacterString>Guadeloupe</gco:CharacterString>
          </gmd:keyword>
          <gmd:keyword>
            <gco:CharacterString>Martinique</gco:CharacterString>
          </gmd:keyword>
          <gmd:keyword>
            <gco:CharacterString>Saint-Martin</gco:CharacterString>
          </gmd:keyword>
          <gmd:keyword>
            <gco:CharacterString>Saint-Barthélemy</gco:CharacterString>
          </gmd:keyword>
          <gmd:keyword>
            <gco:CharacterString>Guyane</gco:CharacterString>
          </gmd:keyword>
          <gmd:keyword>
            <gco:CharacterString>La Réunion</gco:CharacterString>
          </gmd:keyword>
          <gmd:keyword>
            <gco:CharacterString>Mayotte</gco:CharacterString>
          </gmd:keyword>
          <gmd:keyword>
            <gco:CharacterString>Nouvelle-Calédonie</gco:CharacterString>
          </gmd:keyword>
          <gmd:keyword>
            <gco:CharacterString>Wallis-et-Futuna</gco:CharacterString>
          </gmd:keyword>
          <gmd:keyword>
            <gco:CharacterString>Polynésie Française</gco:CharacterString>
          </gmd:keyword>
          <gmd:keyword>
            <gco:CharacterString>Saint-Pierre-et-Miquelon</gco:CharacterString>
          </gmd:keyword>
          <gmd:keyword>
            <gco:CharacterString>TAAF - Terres Australes et Antarctiques Françaises</gco:CharacterString>
          </gmd:keyword>
          <gmd:keyword>
            <gco:CharacterString>Kerguelen</gco:CharacterString>
          </gmd:keyword>
          <gmd:keyword>
            <gco:CharacterString>Crozet</gco:CharacterString>
          </gmd:keyword>
          <gmd:keyword>
            <gco:CharacterString>Amsterdam</gco:CharacterString>
          </gmd:keyword>
          <gmd:keyword>
            <gco:CharacterString>Saint-Paul</gco:CharacterString>
          </gmd:keyword>
          <gmd:keyword>
            <gco:CharacterString>Terre Adélie</gco:CharacterString>
          </gmd:keyword>
          <gmd:keyword>
            <gco:CharacterString>Clipperton</gco:CharacterString>
          </gmd:keyword>
          <gmd:type>
            <gmd:MD_KeywordTypeCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode" codeListValue="place">place</gmd:MD_KeywordTypeCode>
          </gmd:type>
        </gmd:MD_Keywords>
      </gmd:descriptiveKeywords>
      
      <!-- Contraintes d''accès et d''utilisation -->
      <gmd:resourceConstraints>
        <gmd:MD_LegalConstraints>
          <gmd:useLimitation>
            <gco:CharacterString>Licence Ouverte Etalab 2.0 - https://www.etalab.gouv.fr/licence-ouverte-open-licence</gco:CharacterString>
          </gmd:useLimitation>
          <gmd:accessConstraints>
            <gmd:MD_RestrictionCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_RestrictionCode" codeListValue="otherRestrictions">otherRestrictions</gmd:MD_RestrictionCode>
          </gmd:accessConstraints>
          <gmd:otherConstraints>
            <gco:CharacterString>Pas de restriction d''accès public</gco:CharacterString>
          </gmd:otherConstraints>
        </gmd:MD_LegalConstraints>
      </gmd:resourceConstraints>
      
      <!-- Type de représentation spatiale -->
      <gmd:spatialRepresentationType>
        <gmd:MD_SpatialRepresentationTypeCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_SpatialRepresentationTypeCode" codeListValue="vector">vector</gmd:MD_SpatialRepresentationTypeCode>
      </gmd:spatialRepresentationType>
      
      <!-- Résolution spatiale -->
      <gmd:spatialResolution>
        <gmd:MD_Resolution>
          <gmd:equivalentScale>
            <gmd:MD_RepresentativeFraction>
              <gmd:denominator>
                <gco:Integer>100000</gco:Integer>
              </gmd:denominator>
            </gmd:MD_RepresentativeFraction>
          </gmd:equivalentScale>
        </gmd:MD_Resolution>
      </gmd:spatialResolution>
	  <!-- À modifier selon la résolution spatiale réelle de la donnée -->
      
      <!-- Langue de la ressource -->
      <gmd:language>
        <gco:CharacterString>fre</gco:CharacterString>
      </gmd:language>
      
      <!-- Catégorie thématique -->
      <gmd:topicCategory>
        <gmd:MD_TopicCategoryCode>environment</gmd:MD_TopicCategoryCode>
      </gmd:topicCategory>
      
      <!-- Emprise géographique -->
      <gmd:extent>
        <gmd:EX_Extent>
          <gmd:geographicElement>
            <gmd:EX_GeographicBoundingBox>
              <gmd:westBoundLongitude>
                <gco:Decimal>-180.0</gco:Decimal>
              </gmd:westBoundLongitude>
              <gmd:eastBoundLongitude>
                <gco:Decimal>180.0</gco:Decimal>
              </gmd:eastBoundLongitude>
              <gmd:southBoundLatitude>
                <gco:Decimal>-67.13</gco:Decimal>
              </gmd:southBoundLatitude>
              <gmd:northBoundLatitude>
                <gco:Decimal>51.56</gco:Decimal>
              </gmd:northBoundLatitude>
            </gmd:EX_GeographicBoundingBox>
          </gmd:geographicElement>
        </gmd:EX_Extent>
      </gmd:extent>
      
    </gmd:MD_DataIdentification>
  </gmd:identificationInfo>
  
  <!-- Informations de distribution -->
  <gmd:distributionInfo>
    <gmd:MD_Distribution>
      <gmd:distributionFormat>
        <gmd:MD_Format>
          <gmd:name>
            <gco:CharacterString>GeoPackage</gco:CharacterString>
          </gmd:name>
          <gmd:version>
            <gco:CharacterString>1.3</gco:CharacterString>
          </gmd:version>
        </gmd:MD_Format>
      </gmd:distributionFormat>
      <gmd:transferOptions>
        <gmd:MD_DigitalTransferOptions>
          <gmd:onLine>
            <gmd:CI_OnlineResource>
              <gmd:linkage>
                <gmd:URL>https://github.com/cnigfr/schema-paysage</gmd:URL>
              </gmd:linkage>
              <gmd:protocol>
                <gco:CharacterString>WWW:LINK</gco:CharacterString>
              </gmd:protocol>
              <gmd:name>
                <gco:CharacterString>Standard Paysages - CNIG</gco:CharacterString>
              </gmd:name>
            </gmd:CI_OnlineResource>
          </gmd:onLine>
        </gmd:MD_DigitalTransferOptions>
      </gmd:transferOptions>
    </gmd:MD_Distribution>
  </gmd:distributionInfo>
  
  <!-- Qualité des données -->
  <gmd:dataQualityInfo>
    <gmd:DQ_DataQuality>
      <gmd:scope>
        <gmd:DQ_Scope>
          <gmd:level>
            <gmd:MD_ScopeCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_ScopeCode" codeListValue="dataset">dataset</gmd:MD_ScopeCode>
          </gmd:level>
        </gmd:DQ_Scope>
      </gmd:scope>
      
      <!-- Généalogie -->
      <gmd:lineage>
        <gmd:LI_Lineage>
          <gmd:statement>
            <gco:CharacterString>Données géomatiques issues d''atlas de paysages conformes au Standard Paysages du CNIG version 1.0. Les données sont structurées selon le modèle conceptuel défini dans le standard et utilisent les systèmes de coordonnées légaux français : Lambert 93 (EPSG:2154) pour la métropole, RGAF09/UTM20N (EPSG:5490) pour la Guadeloupe et la Martinique, RRAF1991/UTM20N (EPSG:4559) pour Saint-Martin et Saint-Barthélemy, RGFG95/UTM22N (EPSG:2972) pour la Guyane, RGR92/UTM40S (EPSG:2975) pour La Réunion, RGM04/UTM38S (EPSG:4471) pour Mayotte, RGNC91-93/Lambert (EPSG:3163) pour la Nouvelle-Calédonie, RGWF96/UTM1S (EPSG:8902) pour Wallis-et-Futuna, RGPF/UTM5S-6S-7S (EPSG:2976,3297,3298) pour la Polynésie Française, RGTAAF07 (EPSG:7071-7074) pour les TAAF, et RGSPM06/UTM21N (EPSG:4467) pour Saint-Pierre-et-Miquelon. Format d''encodage : GeoPackage 1.3+ avec extension WKT for CRS.</gco:CharacterString>
          </gmd:statement>
        </gmd:LI_Lineage>
      </gmd:lineage>
      
      <!-- Conformité au standard -->
      <gmd:report>
        <gmd:DQ_DomainConsistency>
          <gmd:result>
            <gmd:DQ_ConformanceResult>
              <gmd:specification>
                <gmd:CI_Citation>
                  <gmd:title>
                    <gco:CharacterString>Standard Paysages - CNIG</gco:CharacterString>
                  </gmd:title>
                  <gmd:date>
                    <gmd:CI_Date>
                      <gmd:date>
                        <gco:Date>2024-12-21</gco:Date>
                      </gmd:date>
                      <gmd:dateType>
                        <gmd:CI_DateTypeCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode" codeListValue="publication">publication</gmd:CI_DateTypeCode>
                      </gmd:dateType>
                    </gmd:CI_Date>
                  </gmd:date>
                </gmd:CI_Citation>
              </gmd:specification>
              <gmd:explanation>
                <gco:CharacterString>Le jeu de données est conforme au Standard Paysages du CNIG</gco:CharacterString>
              </gmd:explanation>
              <gmd:pass>
                <gco:Boolean>true</gco:Boolean>
              </gmd:pass>
            </gmd:DQ_ConformanceResult>
          </gmd:result>
        </gmd:DQ_DomainConsistency>
      </gmd:report>
      
    </gmd:DQ_DataQuality>
  </gmd:dataQualityInfo>
  
  <!-- Système de référence -->
  <gmd:referenceSystemInfo>
    <gmd:MD_ReferenceSystem>
      <gmd:referenceSystemIdentifier>
        <gmd:RS_Identifier>
          <gmd:code>
            <gco:CharacterString>EPSG:2154</gco:CharacterString>
          </gmd:code>
          <gmd:codeSpace>
            <gco:CharacterString>EPSG</gco:CharacterString>
          </gmd:codeSpace>
        </gmd:RS_Identifier>
      </gmd:referenceSystemIdentifier>
    </gmd:MD_ReferenceSystem>
  </gmd:referenceSystemInfo>
  
</gmd:MD_Metadata>'
);

-- Lien metadata -> geopackage
INSERT INTO gpkg_metadata_reference (
    reference_scope, table_name, md_file_id
) VALUES (
    'geopackage', NULL, 1
);

-- ============================================================================
-- EXTENSION SCHEMA - DOCUMENTATION DES COLONNES ET CONTRAINTES
-- ============================================================================

-- ============================================================================
-- ATLAS_PAYSAGER - Documentation des colonnes
-- ============================================================================

INSERT INTO gpkg_data_columns VALUES (
    'atlas_paysager', 'identifiant', 'Identifiant', 'Identifiant de l''atlas',
    'Identifiant unique de l''atlas de paysage. Doit commencer par "AtlasPaysage_".',
    NULL, 'constraint_identifiant_atlas'
);

INSERT INTO gpkg_data_columns VALUES (
    'atlas_paysager', 'nom', 'Nom', 'Nom de l''atlas',
    'Nom complet de l''atlas de paysage (ex: "Atlas des paysages de la Gironde").',
    NULL, NULL
);

INSERT INTO gpkg_data_columns VALUES (
    'atlas_paysager', 'type_atlas', 'Type d''atlas', 'Type d''atlas selon son échelle',
    'Type d''atlas de paysage selon son échelle administrative ou territoriale.',
    NULL, 'enum_type_atlas'
);

INSERT INTO gpkg_data_columns VALUES (
    'atlas_paysager', 'maitre_ouvrage', 'Maître d''ouvrage', 'Organisme maître d''ouvrage',
    'Organisme commanditaire de l''atlas (ex: Conseil Départemental, DREAL).',
    NULL, NULL
);

INSERT INTO gpkg_data_columns VALUES (
    'atlas_paysager', 'maitre_oeuvre', 'Maître d''œuvre', 'Organisme maître d''œuvre',
    'Organisme réalisateur de l''atlas (ex: Bureau d''études).',
    NULL, NULL
);

INSERT INTO gpkg_data_columns VALUES (
    'atlas_paysager', 'date_realisation_atlas', 'Date de réalisation', 'Date de réalisation de l''atlas',
    'Date de réalisation ou de publication de l''atlas au format ISO 8601 (YYYY-MM-DD).',
    NULL, NULL
);

INSERT INTO gpkg_data_columns VALUES (
    'atlas_paysager', 'date_revision_dynamiques', 'Date révision dynamiques', 'Date de révision des dynamiques',
    'Date de dernière mise à jour des dynamiques paysagères au format ISO 8601.',
    NULL, NULL
);

-- ============================================================================
-- UNITE_PAYSAGERE - Documentation des colonnes
-- ============================================================================

INSERT INTO gpkg_data_columns VALUES (
    'unite_paysagere', 'identifiant_local', 'Identifiant local', 'Identifiant local de l''UP',
    'Identifiant de l''unité paysagère au sein de l''atlas (ex: "H1", "A2").',
    NULL, NULL
);

INSERT INTO gpkg_data_columns VALUES (
    'unite_paysagere', 'identifiant_global', 'Identifiant global', 'Identifiant global unique',
    'Identifiant global unique formé par concaténation : atlas.identifiant_local',
    NULL, NULL
);

INSERT INTO gpkg_data_columns VALUES (
    'unite_paysagere', 'nom', 'Nom', 'Nom de l''unité paysagère',
    'Nom descriptif de l''unité paysagère (ex: "La terrasse du Bazadais").',
    NULL, NULL
);

INSERT INTO gpkg_data_columns VALUES (
    'unite_paysagere', 'type_orographie1', 'Type orographie 1', 'Type orographique principal',
    'Caractéristique orographique principale de l''unité paysagère.',
    NULL, 'enum_type_orographie'
);

INSERT INTO gpkg_data_columns VALUES (
    'unite_paysagere', 'type_orographie2', 'Type orographie 2', 'Type orographique secondaire',
    'Caractéristique orographique secondaire de l''unité paysagère (optionnel).',
    NULL, 'enum_type_orographie'
);

INSERT INTO gpkg_data_columns VALUES (
    'unite_paysagere', 'dominante_paysagere1', 'Dominante 1', 'Dominante paysagère principale',
    'Dominante paysagère principale caractérisant l''unité paysagère.',
    NULL, 'enum_dominante_paysagere'
);

INSERT INTO gpkg_data_columns VALUES (
    'unite_paysagere', 'dominante_paysagere2', 'Dominante 2', 'Dominante paysagère secondaire',
    'Dominante paysagère secondaire de l''unité paysagère (optionnel).',
    NULL, 'enum_dominante_paysagere'
);

INSERT INTO gpkg_data_columns VALUES (
    'unite_paysagere', 'mot_clef_generique', 'Mots-clés génériques', 'Mots-clés de description générique',
    'Tableau JSON de mots-clés génériques caractérisant l''unité (ex: ["vallons", "coteaux"]).',
    'application/json', NULL
);

INSERT INTO gpkg_data_columns VALUES (
    'unite_paysagere', 'mot_clef_toponymique', 'Mots-clés toponymiques', 'Mots-clés de toponymie',
    'Tableau JSON de toponymes associés à l''unité (ex: ["Langon", "Garonne"]).',
    'application/json', NULL
);

INSERT INTO gpkg_data_columns VALUES (
    'unite_paysagere', 'type_local', 'Type local', 'Typologie locale',
    'Catégorie locale spécifique à l''atlas (libre).',
    NULL, NULL
);

INSERT INTO gpkg_data_columns VALUES (
    'unite_paysagere', 'description', 'Description', 'Description détaillée',
    'Description textuelle détaillée de l''unité paysagère.',
    'text/plain', NULL
);

INSERT INTO gpkg_data_columns VALUES (
    'unite_paysagere', 'code_departement', 'Code département', 'Codes départements',
    'Tableau JSON des codes départements sur 2 chiffres (ex: ["33", "24"]).',
    'application/json', NULL
);

INSERT INTO gpkg_data_columns VALUES (
    'unite_paysagere', 'code_region', 'Code région', 'Codes régions',
    'Tableau JSON des codes régions sur 2 chiffres (ex: ["75", "76"]).',
    'application/json', NULL
);

-- ============================================================================
-- ENSEMBLE_PAYSAGER - Documentation des colonnes
-- ============================================================================

INSERT INTO gpkg_data_columns VALUES (
    'ensemble_paysager', 'identifiant_local', 'Identifiant local', 'Identifiant local de l''EP',
    'Identifiant de l''ensemble paysager au sein de l''atlas.',
    NULL, NULL
);

INSERT INTO gpkg_data_columns VALUES (
    'ensemble_paysager', 'nom', 'Nom', 'Nom de l''ensemble paysager',
    'Nom descriptif de l''ensemble paysager (niveau supérieur à l''UP).',
    NULL, NULL
);

-- ============================================================================
-- LIMITE_DECOUPAGE_PAYSAGER - Documentation des colonnes
-- ============================================================================

INSERT INTO gpkg_data_columns VALUES (
    'limite_decoupage_paysager', 'statut', 'Statut', 'Statut de la limite',
    'Caractère de la limite : franche (nette) ou floue (progressive).',
    NULL, 'enum_statut_limite'
);

INSERT INTO gpkg_data_columns VALUES (
    'limite_decoupage_paysager', 'largeur_estimee', 'Largeur estimée', 'Largeur de la zone de transition',
    'Largeur estimée de la zone de transition en mètres (pour limites floues).',
    NULL, 'range_largeur_limite'
);

INSERT INTO gpkg_data_columns VALUES (
    'limite_decoupage_paysager', 'nature_limite', 'Nature', 'Nature de la limite',
    'Nature géomorphologique ou anthropique de la limite paysagère.',
    NULL, 'enum_nature_limite'
);

-- ============================================================================
-- DYNAMIQUE - Documentation des colonnes
-- ============================================================================

INSERT INTO gpkg_data_columns VALUES (
    'dynamique', 'objet_evolution', 'Objet d''évolution', 'Type d''objet concerné par l''évolution',
    'Type d''occupation du sol ou d''objet paysager concerné par l''évolution (nomenclature OCS GE).',
    NULL, 'enum_objet_evolution'
);

INSERT INTO gpkg_data_columns VALUES (
    'dynamique', 'nature_evolution', 'Nature d''évolution', 'Nature de l''évolution',
    'Type d''évolution observée : apparition, augmentation, diminution, disparition ou stabilisation.',
    NULL, 'enum_nature_evolution'
);

INSERT INTO gpkg_data_columns VALUES (
    'dynamique', 'description', 'Description', 'Description de la dynamique',
    'Description textuelle détaillée de la dynamique paysagère observée.',
    'text/plain', NULL
);

INSERT INTO gpkg_data_columns VALUES (
    'dynamique', 'date_observation', 'Date observation', 'Date d''observation de la dynamique',
    'Date la plus récente à laquelle la dynamique a été observée au format ISO 8601.',
    NULL, NULL
);

INSERT INTO gpkg_data_columns VALUES (
    'dynamique', 'date_fin', 'Date fin', 'Date de fin de l''évolution',
    'Date de fin ou d''observation de la dynamique au format ISO 8601.',
    NULL, NULL
);

-- ============================================================================
-- DOCUMENT_PAYSAGE - Documentation des colonnes
-- ============================================================================

INSERT INTO gpkg_data_columns VALUES (
    'document_paysage', 'nom', 'Nom', 'Nom du document',
    'Titre ou nom du document illustratif.',
    NULL, NULL
);

INSERT INTO gpkg_data_columns VALUES (
    'document_paysage', 'date', 'Date', 'Date du document',
    'Date de création ou de prise de vue au format ISO 8601.',
    NULL, NULL
);

INSERT INTO gpkg_data_columns VALUES (
    'document_paysage', 'auteur', 'Auteur', 'Auteur du document',
    'Auteur, photographe ou créateur du document.',
    NULL, NULL
);

INSERT INTO gpkg_data_columns VALUES (
    'document_paysage', 'document', 'Document', 'URL du document',
    'URL de localisation du document (photo, rapport, etc.).',
    NULL, NULL
);

-- ============================================================================
-- CONTRAINTES - Type Atlas
-- ============================================================================

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_type_atlas', 'enum', 'département', NULL, NULL, NULL, NULL,
    'Atlas de paysage à l''échelle départementale'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_type_atlas', 'enum', 'région', NULL, NULL, NULL, NULL,
    'Atlas de paysage à l''échelle régionale'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_type_atlas', 'enum', 'parc naturel', NULL, NULL, NULL, NULL,
    'Atlas de paysage d''un parc naturel régional'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_type_atlas', 'enum', 'autre', NULL, NULL, NULL, NULL,
    'Autre type d''atlas (intercommunalité, bassin versant, etc.)'
);

-- ============================================================================
-- CONTRAINTES - Type Orographie
-- ============================================================================

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_type_orographie', 'enum', 'plaine', NULL, NULL, NULL, NULL,
    'Terrain plat ou légèrement ondulé'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_type_orographie', 'enum', 'plateau', NULL, NULL, NULL, NULL,
    'Surface plane en altitude avec ruptures de pente marquées'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_type_orographie', 'enum', 'colline', NULL, NULL, NULL, NULL,
    'Relief de faible à moyenne amplitude (< 500m relatif)'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_type_orographie', 'enum', 'montagne', NULL, NULL, NULL, NULL,
    'Relief de forte amplitude (> 500m relatif)'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_type_orographie', 'enum', 'vallée', NULL, NULL, NULL, NULL,
    'Dépression allongée entre deux reliefs'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_type_orographie', 'enum', 'cuvette', NULL, NULL, NULL, NULL,
    'Dépression fermée ou semi-fermée'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_type_orographie', 'enum', 'estuaire', NULL, NULL, NULL, NULL,
    'Embouchure fluviale sous influence maritime'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_type_orographie', 'enum', 'littoral', NULL, NULL, NULL, NULL,
    'Zone de contact terre-mer (côte, plage, falaise)'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_type_orographie', 'enum', 'marais', NULL, NULL, NULL, NULL,
    'Zone humide caractérisée par un sol gorgé d''eau'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_type_orographie', 'enum', 'zone littorale', NULL, NULL, NULL, NULL,
    'Large bande côtière incluant interface terre-mer'
);

-- ============================================================================
-- CONTRAINTES - Dominante Paysagère
-- ============================================================================

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_dominante_paysagere', 'enum', 'paysage agricole', NULL, NULL, NULL, NULL,
    'Paysage dominé par les activités agricoles (cultures, élevage)'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_dominante_paysagere', 'enum', 'paysage forestier', NULL, NULL, NULL, NULL,
    'Paysage dominé par les espaces boisés'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_dominante_paysagere', 'enum', 'paysage naturel', NULL, NULL, NULL, NULL,
    'Paysage à faible anthropisation (landes, zones humides naturelles)'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_dominante_paysagere', 'enum', 'paysage urbain', NULL, NULL, NULL, NULL,
    'Paysage dominé par l''urbanisation (ville, périurbain)'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_dominante_paysagere', 'enum', 'paysage d''infrastructures', NULL, NULL, NULL, NULL,
    'Paysage marqué par les grandes infrastructures (transport, énergie, industrie)'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_dominante_paysagere', 'enum', 'paysage viticole', NULL, NULL, NULL, NULL,
    'Paysage spécifiquement dominé par la viticulture'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_dominante_paysagere', 'enum', 'paysage littoral', NULL, NULL, NULL, NULL,
    'Paysage côtier avec forte influence maritime'
);

-- ============================================================================
-- CONTRAINTES - Statut Limite
-- ============================================================================

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_statut_limite', 'enum', 'limite franche', NULL, NULL, NULL, NULL,
    'Limite nette et bien identifiable sur le terrain (rupture de pente, cours d''eau, etc.)'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_statut_limite', 'enum', 'limite floue', NULL, NULL, NULL, NULL,
    'Limite progressive avec zone de transition graduelle'
);

-- ============================================================================
-- CONTRAINTES - Nature Limite
-- ============================================================================

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_nature_limite', 'enum', 'rupture de pente', NULL, NULL, NULL, NULL,
    'Changement marqué de l''inclinaison du terrain (talus, versant)'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_nature_limite', 'enum', 'ligne de crête', NULL, NULL, NULL, NULL,
    'Ligne sommitale séparant deux versants'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_nature_limite', 'enum', 'cours d''eau', NULL, NULL, NULL, NULL,
    'Cours d''eau marquant une séparation paysagère'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_nature_limite', 'enum', 'limite forestière', NULL, NULL, NULL, NULL,
    'Transition entre espace boisé et espace ouvert'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_nature_limite', 'enum', 'limite urbaine', NULL, NULL, NULL, NULL,
    'Interface entre espace urbanisé et espace non urbanisé'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_nature_limite', 'enum', 'infrastructure', NULL, NULL, NULL, NULL,
    'Grande infrastructure (autoroute, voie ferrée) créant une coupure'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_nature_limite', 'enum', 'autre', NULL, NULL, NULL, NULL,
    'Autre type de limite non catégorisée'
);

-- ============================================================================
-- CONTRAINTES - Nature Évolution (Dynamique)
-- ============================================================================

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_nature_evolution', 'enum', 'apparition', NULL, NULL, NULL, NULL,
    'Apparition d''un nouvel élément paysager'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_nature_evolution', 'enum', 'augmentation', NULL, NULL, NULL, NULL,
    'Augmentation de la présence d''un élément existant'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_nature_evolution', 'enum', 'diminution', NULL, NULL, NULL, NULL,
    'Diminution de la présence d''un élément existant'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_nature_evolution', 'enum', 'disparition', NULL, NULL, NULL, NULL,
    'Disparition complète d''un élément paysager'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_nature_evolution', 'enum', 'stabilisation', NULL, NULL, NULL, NULL,
    'Stabilisation ou absence d''évolution notable'
);

-- ============================================================================
-- CONTRAINTES - Objet Évolution (Dynamique) - Nomenclature OCS GE
-- ============================================================================

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_objet_evolution', 'enum', 'zones bâties', NULL, NULL, NULL, NULL,
    'Surfaces bâties (habitat, activités économiques)'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_objet_evolution', 'enum', 'zones non bâties', NULL, NULL, NULL, NULL,
    'Surfaces artificialisées non bâties (routes, parkings, chantiers)'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_objet_evolution', 'enum', 'surfaces routes', NULL, NULL, NULL, NULL,
    'Surfaces revêtues des voies de communication routière'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_objet_evolution', 'enum', 'surfaces ferrées', NULL, NULL, NULL, NULL,
    'Emprises ferroviaires (voies, gares, installations)'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_objet_evolution', 'enum', 'surfaces d''activités économiques', NULL, NULL, NULL, NULL,
    'Zones d''activités industrielles, commerciales, portuaires'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_objet_evolution', 'enum', 'aérodromes', NULL, NULL, NULL, NULL,
    'Plateformes aéroportuaires et aérodromes'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_objet_evolution', 'enum', 'chantiers', NULL, NULL, NULL, NULL,
    'Zones en construction ou en travaux'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_objet_evolution', 'enum', 'espaces ouverts artificialisés', NULL, NULL, NULL, NULL,
    'Espaces verts urbains, équipements sportifs et de loisirs'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_objet_evolution', 'enum', 'terres arables', NULL, NULL, NULL, NULL,
    'Surfaces cultivées annuellement (céréales, maraîchage)'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_objet_evolution', 'enum', 'cultures permanentes', NULL, NULL, NULL, NULL,
    'Vergers, vignes, oliveraies'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_objet_evolution', 'enum', 'prairies', NULL, NULL, NULL, NULL,
    'Surfaces herbacées destinées au pâturage ou à la fauche'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_objet_evolution', 'enum', 'zones agricoles hétérogènes', NULL, NULL, NULL, NULL,
    'Mosaïques de cultures et espaces naturels'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_objet_evolution', 'enum', 'forêts de feuillus', NULL, NULL, NULL, NULL,
    'Peuplements forestiers dominés par les feuillus'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_objet_evolution', 'enum', 'forêts de conifères', NULL, NULL, NULL, NULL,
    'Peuplements forestiers dominés par les conifères'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_objet_evolution', 'enum', 'forêts mixtes', NULL, NULL, NULL, NULL,
    'Peuplements forestiers mélangés feuillus-conifères'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_objet_evolution', 'enum', 'pelouses et pâturages naturels', NULL, NULL, NULL, NULL,
    'Formations herbacées naturelles ou semi-naturelles'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_objet_evolution', 'enum', 'landes et broussailles', NULL, NULL, NULL, NULL,
    'Formations arbustives basses (landes, maquis, garrigues)'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_objet_evolution', 'enum', 'végétation sclérophylle', NULL, NULL, NULL, NULL,
    'Végétation méditerranéenne à feuilles coriaces'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_objet_evolution', 'enum', 'forêts et végétation arbustive en mutation', NULL, NULL, NULL, NULL,
    'Zones forestières en transition (coupes, régénération)'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_objet_evolution', 'enum', 'plages, dunes, sables', NULL, NULL, NULL, NULL,
    'Formations sableuses littorales ou continentales'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_objet_evolution', 'enum', 'roches nues', NULL, NULL, NULL, NULL,
    'Affleurements rocheux, falaises, pierriers'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_objet_evolution', 'enum', 'végétation clairsemée', NULL, NULL, NULL, NULL,
    'Zones à couverture végétale très faible (haute montagne, zones arides)'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_objet_evolution', 'enum', 'zones incendiées', NULL, NULL, NULL, NULL,
    'Zones brûlées récemment'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_objet_evolution', 'enum', 'glaciers et neiges éternelles', NULL, NULL, NULL, NULL,
    'Zones englacées permanentes'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_objet_evolution', 'enum', 'marais intérieurs', NULL, NULL, NULL, NULL,
    'Zones humides continentales'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_objet_evolution', 'enum', 'tourbières', NULL, NULL, NULL, NULL,
    'Zones humides acides à accumulation de tourbe'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_objet_evolution', 'enum', 'marais maritimes', NULL, NULL, NULL, NULL,
    'Zones humides côtières sous influence marine'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_objet_evolution', 'enum', 'marais salants', NULL, NULL, NULL, NULL,
    'Bassins d''exploitation du sel marin'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_objet_evolution', 'enum', 'zones intertidales', NULL, NULL, NULL, NULL,
    'Zones de balancement des marées (estrans, vasières)'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_objet_evolution', 'enum', 'cours et voies d''eau', NULL, NULL, NULL, NULL,
    'Réseaux hydrographiques (rivières, fleuves, canaux)'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_objet_evolution', 'enum', 'plans d''eau', NULL, NULL, NULL, NULL,
    'Étendues d''eau continentales (lacs, étangs, réservoirs)'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'enum_objet_evolution', 'enum', 'mers et océans', NULL, NULL, NULL, NULL,
    'Eaux marines et océaniques'
);

-- ============================================================================
-- CONTRAINTES - Plages de valeurs
-- ============================================================================

INSERT INTO gpkg_data_column_constraints VALUES (
    'range_largeur_limite', 'range', NULL, 0, 1, 10000, 1,
    'Largeur de zone de transition entre 0 et 10000 mètres'
);

INSERT INTO gpkg_data_column_constraints VALUES (
    'constraint_identifiant_atlas', 'glob', 'AtlasPaysage_*', NULL, NULL, NULL, NULL,
    'L''identifiant doit commencer par "AtlasPaysage_"'
);

-- ============================================================================
-- VUES UTILITAIRES
-- ============================================================================

-- Vue : Statistiques par atlas
CREATE VIEW v_stats_atlas AS
SELECT 
    a.identifiant,
    a.nom,
    a.type_atlas,
    a.date_realisation_atlas,
    COUNT(DISTINCT up.fid) as nb_unites_paysageres,
    COUNT(DISTINCT ep.fid) as nb_ensembles_paysagers,
    COUNT(DISTINCT sup.fid) as nb_sous_unites,
    COUNT(DISTINCT d.fid) as nb_dynamiques,
    COUNT(DISTINCT doc.fid) as nb_documents,
    COUNT(DISTINCT lim.fid) as nb_limites
FROM atlas_paysager a
LEFT JOIN unite_paysagere up ON a.identifiant = up.lien_atlas_paysage
LEFT JOIN ensemble_paysager ep ON a.identifiant = ep.lien_atlas_paysage
LEFT JOIN sous_unite_paysagere sup ON a.identifiant = sup.lien_atlas_paysage
LEFT JOIN dynamique d ON up.identifiant_global = d.lien_up 
    OR ep.identifiant_global = d.lien_ep 
    OR sup.identifiant_global = d.lien_sous_up
LEFT JOIN document_paysage doc ON a.identifiant = doc.lien_atlas_paysage
LEFT JOIN limite_decoupage_paysager lim ON a.identifiant = lim.lien_atlas
GROUP BY a.identifiant, a.nom, a.type_atlas, a.date_realisation_atlas;

-- Vue : Relations UP <-> EP
CREATE VIEW v_relations_up_ep AS
SELECT 
    up.identifiant_global as up_id,
    up.nom as up_nom,
    up.type_orographie1,
    up.dominante_paysagere1,
    ep.identifiant_global as ep_id,
    ep.nom as ep_nom
FROM unite_paysagere up
LEFT JOIN ensemble_paysager ep ON up.lien_ep = ep.identifiant_global;

-- Vue : Relations SUP <-> UP
CREATE VIEW v_relations_sup_up AS
SELECT 
    sup.identifiant_global as sup_id,
    sup.nom as sup_nom,
    up.identifiant_global as up_id,
    up.nom as up_nom,
    ep.identifiant_global as ep_id,
    ep.nom as ep_nom
FROM sous_unite_paysagere sup
JOIN unite_paysagere up ON sup.lien_up = up.identifiant_global
LEFT JOIN ensemble_paysager ep ON up.lien_ep = ep.identifiant_global;

-- Vue : Synthèse des dynamiques par type
CREATE VIEW v_synthese_dynamiques AS
SELECT 
    objet_evolution,
    nature_evolution,
    COUNT(*) as nombre,
    COUNT(DISTINCT lien_up) as nb_unites_concernees,
    COUNT(DISTINCT lien_ep) as nb_ensembles_concernes,
    COUNT(DISTINCT lien_sous_up) as nb_sous_unites_concernees
FROM dynamique
GROUP BY objet_evolution, nature_evolution
ORDER BY objet_evolution, nature_evolution;

-- Vue d'information sur les projections disponibles
CREATE VIEW v_projections_disponibles AS
SELECT 
    srs_id,
    srs_name,
    organization || ':' || organization_coordsys_id as code_epsg,
    description,
    CASE 
        WHEN srs_id = 2154 THEN 'France métropolitaine'
        WHEN srs_id = 5490 THEN 'Guadeloupe, Martinique'
        WHEN srs_id = 4559 THEN 'Saint-Martin, Saint-Barthélemy'
        WHEN srs_id = 2972 THEN 'Guyane'
        WHEN srs_id = 2975 THEN 'La Réunion'
        WHEN srs_id = 4471 THEN 'Mayotte'
        WHEN srs_id = 3163 THEN 'Nouvelle-Calédonie'
        WHEN srs_id = 8902 THEN 'Wallis-et-Futuna'
        WHEN srs_id = 3297 THEN 'Polynésie Française (zone 6S - Société, Australes ouest)'
        WHEN srs_id = 3298 THEN 'Polynésie Française (zone 7S - Australes est, Tuamotu ouest)'
        WHEN srs_id = 2976 THEN 'Polynésie Française (zone 5S - Marquises)'
        WHEN srs_id = 7073 THEN 'TAAF - Kerguelen'
        WHEN srs_id = 7072 THEN 'TAAF - Crozet'
        WHEN srs_id = 7071 THEN 'TAAF - Amsterdam & Saint-Paul'
        WHEN srs_id = 7074 THEN 'TAAF - Terre Adélie (Antarctique)'
        WHEN srs_id = 4467 THEN 'Saint-Pierre-et-Miquelon'
        ELSE 'Autre'
    END as territoire
FROM gpkg_spatial_ref_sys
WHERE srs_id IN (2154, 5490, 4559, 2972, 2975, 4471, 3163, 8902, 3297, 3298, 2976, 7073, 7072, 7071, 7074, 4467)
ORDER BY 
    CASE 
        WHEN srs_id = 2154 THEN 1
        WHEN srs_id IN (5490, 4559) THEN 2
        WHEN srs_id = 2972 THEN 3
        WHEN srs_id IN (2975, 4471) THEN 4
        WHEN srs_id IN (3163, 8902, 3297, 3298, 2976) THEN 5
        WHEN srs_id IN (7073, 7072, 7071, 7074) THEN 6
        WHEN srs_id = 4467 THEN 7
        ELSE 99
    END,
    srs_id;

-- ============================================================================
-- TRIGGERS DE VALIDATION
-- ============================================================================

-- Trigger : Validation format identifiant atlas
CREATE TRIGGER trg_validate_atlas_identifiant
BEFORE INSERT ON atlas_paysager
FOR EACH ROW
WHEN NEW.identifiant NOT LIKE 'AtlasPaysage_%'
BEGIN
    SELECT RAISE(ABORT, 'L''identifiant doit commencer par "AtlasPaysage_"');
END;

-- Trigger : Validation cohérence identifiants UP
CREATE TRIGGER trg_validate_up_identifiant
BEFORE INSERT ON unite_paysagere
FOR EACH ROW
WHEN NEW.identifiant_global != NEW.lien_atlas_paysage || '.' || NEW.identifiant_local
BEGIN
    SELECT RAISE(ABORT, 'identifiant_global doit être lien_atlas_paysage.identifiant_local');
END;

-- Trigger : Validation cohérence identifiants EP
CREATE TRIGGER trg_validate_ep_identifiant
BEFORE INSERT ON ensemble_paysager
FOR EACH ROW
WHEN NEW.identifiant_global != NEW.lien_atlas_paysage || '.' || NEW.identifiant_local
BEGIN
    SELECT RAISE(ABORT, 'identifiant_global doit être lien_atlas_paysage.identifiant_local');
END;

-- Trigger : Validation cohérence identifiants SUP
CREATE TRIGGER trg_validate_sup_identifiant
BEFORE INSERT ON sous_unite_paysagere
FOR EACH ROW
WHEN NEW.identifiant_global != NEW.lien_atlas_paysage || '.' || NEW.identifiant_local
BEGIN
    SELECT RAISE(ABORT, 'identifiant_global doit être lien_atlas_paysage.identifiant_local');
END;

-- Trigger : Validation format JSON pour mot_clef_generique (UP)
CREATE TRIGGER trg_validate_up_json_motclef_generique
BEFORE INSERT ON unite_paysagere
FOR EACH ROW
WHEN json_valid(NEW.mot_clef_generique) = 0
BEGIN
    SELECT RAISE(ABORT, 'mot_clef_generique doit être un JSON valide (array)');
END;

-- Trigger : Validation format JSON pour mot_clef_toponymique (UP)
CREATE TRIGGER trg_validate_up_json_motclef_toponymique
BEFORE INSERT ON unite_paysagere
FOR EACH ROW
WHEN json_valid(NEW.mot_clef_toponymique) = 0
BEGIN
    SELECT RAISE(ABORT, 'mot_clef_toponymique doit être un JSON valide (array)');
END;

-- ============================================================================
-- INFORMATIONS FINALES
-- ============================================================================

-- Table d'information sur le template
CREATE TABLE _template_info (
    version TEXT DEFAULT 'v1.0.0',
    date_creation TEXT DEFAULT (strftime('%Y-%m-%d', 'now')),
    standard TEXT DEFAULT 'Standard Paysage CNIG',
    standard_version TEXT DEFAULT 'v1.0.0',
    standard_date TEXT DEFAULT '2024-12-21',
    srs_name TEXT DEFAULT 'RGF93 v1 / Lambert-93',
    srs_id INTEGER DEFAULT 2154,
    srs_note TEXT DEFAULT 'Lambert 93 pour France métropolitaine. Toutes projections françaises disponibles : RGAF09/UTM20N (5490), RRAF91/UTM20N (4559), RGFG95/UTM22N (2972), RGR92/UTM40S (2975), RGM04/UTM38S (4471), RGNC91-93 (3163), RGWF96/UTM1S (8902), RGPF/UTM5S-6S-7S (2976,3297,3298), RGTAAF07/UTM38S-39S-42S+PolSter (7071,7072,7073,7074), RGSPM06/UTM21N (4467)',
    license TEXT DEFAULT 'Etalab Licence Ouverte 2.0',
    homepage TEXT DEFAULT 'https://github.com/cnigfr/schema-paysage',
    contact TEXT DEFAULT 'cnig@cnig.fr',
    notes TEXT DEFAULT 'Template GeoPackage avec Lambert 93 par défaut. Support complet de tous les territoires français via WKT for CRS extension (16 projections). Extension Schema activée avec 35+ colonnes documentées et 70+ contraintes d''énumération. Les champs JSON (arrays) doivent contenir des tableaux valides. Compatible GeoPackage 1.3+. Métadonnées ISO 19115 complètes.'
);

INSERT INTO _template_info DEFAULT VALUES;

-- ============================================================================
-- FIN DU SCRIPT
-- ============================================================================
-- 
-- UTILISATION:
-- 
-- 1. Avec ogr2ogr :
--    ogr2ogr -f GPKG paysage_lambert93.gpkg template_paysage_lambert93.sql
-- 
-- 2. Ou avec Python :
--    python3 create_gpkg.py
-- 
-- 3. Ou avec sqlite3 + spatialite :
--    sqlite3 paysage_lambert93.gpkg < template_paysage_lambert93.sql
--    SELECT load_extension('mod_spatialite');
--    SELECT gpkgCreateBaseTables();
--
-- NOTES IMPORTANTES :
-- 
-- PROJECTIONS :
-- - WGS84 (EPSG:4326) : Monde entier [disponible par défaut dans tout GeoPackage]
-- - Lambert 93 (EPSG:2154) : France métropolitaine [défaut du template]
-- - RGAF09/UTM20N (EPSG:5490) : Guadeloupe, Martinique
-- - RRAF1991/UTM20N (EPSG:4559) : Saint-Martin, Saint-Barthélemy
-- - RGFG95/UTM22N (EPSG:2972) : Guyane
-- - RGR92/UTM40S (EPSG:2975) : La Réunion  
-- - RGM04/UTM38S (EPSG:4471) : Mayotte
-- - RGNC91-93/Lambert (EPSG:3163) : Nouvelle-Calédonie
-- - RGWF96/UTM1S (EPSG:8902) : Wallis-et-Futuna
-- - RGPF/UTM5S (EPSG:2976) : Polynésie Française - Marquises
-- - RGPF/UTM6S (EPSG:3297) : Polynésie Française - Société, Australes ouest
-- - RGPF/UTM7S (EPSG:3298) : Polynésie Française - Australes est, Tuamotu
-- - RGTAAF07/UTM38S (EPSG:7071) : TAAF - Amsterdam & Saint-Paul
-- - RGTAAF07/UTM39S (EPSG:7072) : TAAF - Crozet
-- - RGTAAF07/UTM42S (EPSG:7073) : TAAF - Kerguelen
-- - RGTAAF07/PolSter (EPSG:7074) : TAAF - Terre Adélie (Antarctique)
-- - RGSPM06/UTM21N (EPSG:4467) : Saint-Pierre-et-Miquelon
-- 
-- DONNÉES :
-- - Les champs JSON (arrays) : format ["val1", "val2"]
-- - Contraintes CHECK : validité des énumérations
-- - Clés étrangères : activées (PRAGMA foreign_keys = ON)
-- - Triggers : validation automatique des identifiants et JSON
-- 
-- MÉTADONNÉES :
-- - ISO 19115 complètes (gpkg_metadata)
-- - Conformité INSPIRE
-- - Extension metadata activée
-- 
-- QUALITÉ :
-- - Vues utilitaires pour statistiques et relations
-- - Index spatiaux sur toutes les géométries
-- - Validation automatique par triggers
-- 
-- ============================================================================
