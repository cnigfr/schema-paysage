# Template GeoPackage - Standard Paysages CNIG

**Version 1.0.0** - Décembre 2025

---

## Table des matières

1. [Vue d'ensemble](#vue-densemble)
2. [Fichiers fournis](#fichiers-fournis)
3. [Installation et Utilisation](#installation-et-utilisation)
4. [Script Python d'installation](#script-python-dinstallation)
5. [Projections supportées](#projections-supportees)
6. [Extension Schema](#extension-schema)
7. [Vues utilitaires et Validation](#vues-utilitaires-et-validation)
8. [Exemples d'utilisation](#exemples-dutilisation)
9. [Validation et tests](#validation-et-tests)
10. [Problèmes courants](#problemes-courants)
11. [Utilisation dans QGIS](#utilisation-dans-qgis)
12. [Références](#references)

---

## Vue d'ensemble

Ce template GeoPackage implémente le **Standard Paysages du CNIG** version 1.0.0 avec :

### Caractéristiques principales

- **Projection par défaut** : Lambert 93 (EPSG:2154) pour la France métropolitaine
- **16 projections françaises** : tous territoires couverts (métropole + outre-mer) + WGS84
- **3 extensions OGC** : WKT for CRS, Metadata, Schema
- **Métadonnées ISO 19115** complètes
- **Documentation formelle** : 34 colonnes et 69 contraintes documentées
- **Auto-documentation** : schéma interrogeable par les applications
- **Validation automatique** : 8 triggers de contrôle
- **Compatible QGIS** : formulaires automatiques avec listes déroulantes

### Structure des Données

Le GeoPackage contient **7 tables principales** :

| Table | Type | Géométrie | Description |
|-------|------|-----------|-------------|
| `atlas_paysager` | Polygone | MULTIPOLYGON | Métadonnées générales de l'atlas (emprise territoriale) |
| `unite_paysagere` | Polygone | MULTIPOLYGON | Découpage paysager central (échelle locale) |
| `ensemble_paysagere` | Polygone | MULTIPOLYGON | Échelle régionale (association d'UP) |
| `sous_unite_paysagere` | Polygone | MULTIPOLYGON | Subdivision fine d'une UP |
| `limite_decoupage_paysager` | Ligne | LINESTRING | Nature et précision des limites entre entités |
| `document_paysage` | Point | POINT | Photos, croquis, blocs-diagrammes géolocalisés |
| `dynamique` | Attributaire | - | Évolutions temporelles du paysage |

**+ 5 vues utilitaires** :
- `v_stats_atlas` : Statistiques complètes par atlas (nb UP, EP, SUP, dynamiques, documents)
- `v_relations_up_ep` : Relations hiérarchiques Unités ↔ Ensembles paysagers
- `v_relations_sup_up` : Hiérarchie complète SUP → UP → EP
- `v_synthese_dynamiques` : Analyse des dynamiques paysagères par type
- `v_projections_disponibles` : Liste des 17 projections supportées

---

## Fichiers fournis

### Script SQL

**`template_paysage.sql`**
- Script complet de création du GeoPackage
- Conforme Standard Paysages CNIG v1.0.0
- GeoPackage 1.3.0
- Prêt à l'emploi

### Fichier GeoPackage vide

**`template_paysage.gpkg`**
- GeoPackage vide pré-configuré
- Créé à partir du script SQL
- Prêt à être utilisé directement
- Aucune installation requise
- *Ce fichier de documentation le décrit*

### Fichiers Shapefile vides

Dossier **`template_paysage.shp`**
- Shapefile vides pré-configurés
- Créés à partir du Geopackage
- Prêts à être utilisés directement
- Aucune installation requise
- *Voir la documentation spécifique dans le dossier [Shapefile](../Shapefile)*

### Script d'installation

**`create_gpkg.py`**
- Script Python autonome sans dépendances externes
- Crée un GeoPackage à partir du script SQL
- Utilise uniquement la bibliothèque standard Python (sqlite3)
- Compatible Python 3.6+

### Documentation

**`README.md`** (ce fichier)
- Documentation complète consolidée
- Guide d'utilisation
- Exemples et références

---

## Installation et utilisation

### Prérequis

**Minimaux** (pour utilisation directe) :
- Aucun prérequis ! Le fichier `template_paysage.gpkg` est prêt à l'emploi

**Pour création/modification** :
- **Python** 3.6+ (avec sqlite3 - inclus par défaut)
- OU **SQLite** 3.35+
- OU **GDAL/OGR** 3.5+

**Recommandé pour utilisation** :
- **QGIS** 3.28+ (visualisation et édition)

### Méthode 1 : Utilisation directe du GeoPackage vide (RECOMMANDÉE)

```bash
# Le fichier est prêt à l'emploi !
# Ouvrez simplement template_paysage.gpkg dans QGIS
# ou copiez-le pour créer votre propre atlas :
cp template_paysage.gpkg mon_atlas_paysage.gpkg
```

### Méthode 2 : avec le script Python (sans dépendances externes)

```bash
# Créer un nouveau GeoPackage à partir du script SQL
python3 create_gpkg.py
```

### Méthode 3 : avec SQLite

```bash
sqlite3 template_paysage.gpkg < template_paysage.sql
```

### Méthode 4 : avec ogr2ogr

```bash
ogr2ogr -f GPKG template_paysage.gpkg template_paysage.sql
```

---

## Script Python d'installation

### Description

Le script `create_gpkg.py` est un **outil autonome** qui crée un GeoPackage à partir du script SQL sans nécessiter d'installation de GDAL ou d'autres dépendances externes.

### Caractéristiques

- **Sans dépendances externes** : utilise uniquement `sqlite3` (bibliothèque standard Python)
- **Portable** : fonctionne sur Windows, macOS, Linux
- **Compatible** : Python 3.6+
- **Validation automatique** : vérifie la structure créée
- **Messages clairs** : affiche les statistiques de création

### Utilisation

```bash
# Créer avec le nom par défaut (paysage.gpkg)
python3 create_gpkg.py

# Créer avec un nom personnalisé
python3 create_gpkg.py mon_atlas.gpkg

# Spécifier le chemin du script SQL
python3 create_gpkg.py mon_atlas.gpkg /chemin/vers/template.sql
```

### Fonctionnement

Le script :
1. Lit le fichier SQL `template_paysage.sql`
2. Crée un nouveau fichier GeoPackage
3. Définit l'Application ID (GP10) et la version (1.3.0)
4. Exécute le script SQL complet
5. Valide la structure (extensions, tables, projections)
6. Affiche les statistiques

### Exemple de sortie

```
======================================================================
📦 Création GeoPackage - Standard Paysage CNIG v1.2.1
======================================================================

📄 Script SQL : template_paysage.sql
📦 Sortie     : mon_atlas.gpkg

📖 Lecture du script SQL...
   ✓ 2052 lignes lues

🔧 Création du fichier GeoPackage...
   ✓ Application ID défini (GeoPackage 1.3.0)

⚙️  Exécution du script SQL...
   ✓ Script exécuté avec succès

✅ Validation de la structure...
   ✓ Version GeoPackage : 1.3.0
   ✓ Extensions : gpkg_metadata, gpkg_schema, gpkg_crs_wkt
   ✓ Tables métier : 7
   ✓ Projections : 17

📊 Résumé :
   • Couches enregistrées : 7
   • Taille fichier : 272 Ko

✅ GeoPackage créé avec succès : mon_atlas.gpkg
```

---

## Projections supportées

### 17 Systèmes de Coordonnées

Le template supporte **17 projections** couvrant tous les territoires français :

#### WGS84 (projection universelle par défaut)

| Code EPSG | Projection | Territoire |
|-----------|------------|------------|
| **4326** | **WGS84 géographique** | **Monde entier** (projection par défaut GeoPackage) |

#### France Métropolitaine

| Code EPSG | Projection | Datum | Territoire |
|-----------|------------|-------|------------|
| **2154** | **Lambert-93** | RGF93 | **France métropolitaine** (projection par défaut du template) |

#### Antilles

| Code EPSG | Projection | Datum | Territoire |
|-----------|------------|-------|------------|
| 5490 | UTM 20N | RGAF09 | Guadeloupe, Martinique |
| 4559 | UTM 20N | RRAF 1991 | Saint-Martin, Saint-Barthélemy |

#### Guyane

| Code EPSG | Projection | Datum | Territoire |
|-----------|------------|-------|------------|
| 2972 | UTM 22N | RGFG95 | Guyane |

#### Océan Indien

| Code EPSG | Projection | Datum | Territoire |
|-----------|------------|-------|------------|
| 2975 | UTM 40S | RGR92 | La Réunion |
| 4471 | UTM 38S | RGM04 | Mayotte |

#### Océan Pacifique

| Code EPSG | Projection | Datum | Territoire |
|-----------|------------|-------|------------|
| 3163 | Lambert NC | RGNC91-93 | Nouvelle-Calédonie |
| 8902 | UTM 1S | RGWF96 | Wallis-et-Futuna |
| 2976 | UTM 5S | RGPF | Polynésie - Marquises |
| 3297 | UTM 6S | RGPF | Polynésie - Société, Australes ouest |
| 3298 | UTM 7S | RGPF | Polynésie - Australes est, Tuamotu |

#### TAAF (Terres Australes et Antarctiques Françaises)

| Code EPSG | Projection | Datum | Territoire |
|-----------|------------|-------|------------|
| 7071 | UTM 38S | RGTAAF07 | Amsterdam & Saint-Paul |
| 7072 | UTM 39S | RGTAAF07 | Crozet |
| 7073 | UTM 42S | RGTAAF07 | Kerguelen |
| 7074 | Polar Stereo | RGTAAF07 | Terre Adélie (Antarctique) |

#### Amérique du Nord

| Code EPSG | Projection | Datum | Territoire |
|-----------|------------|-------|------------|
| 4467 | UTM 21N | RGSPM06 | Saint-Pierre-et-Miquelon |

### Emprise géographique globale

- **Longitude** : -180° à +180°
- **Latitude** : -67,13°S (Terre Adélie) à 51,56°N (France métropolitaine)

### Conversion entre projections

```bash
# WGS84 vers Lambert 93
ogr2ogr -f GPKG sortie_l93.gpkg entree_wgs84.gpkg \
    -s_srs EPSG:4326 -t_srs EPSG:2154

# Lambert 93 vers RGPF (Polynésie)
ogr2ogr -f GPKG sortie_polynesie.gpkg entree_l93.gpkg \
    -s_srs EPSG:2154 -t_srs EPSG:3297
```

---

## Extension Schema

### Qu'est-ce que c'est ?

L'**extension Schema** (OGC GeoPackage Extension) fournit une **documentation formelle et interrogeable** de toutes les colonnes et contraintes.

### Avantages

1. **Auto-documentation** : Le GeoPackage contient sa propre documentation
2. **Validation formelle** : Les énumérations sont déclaratives et vérifiables
3. **Interopérabilité** : QGIS génère automatiquement des formulaires de saisie
4. **Développement facilité** : Les applications peuvent interroger le schéma

### Requêtes utiles

```sql
-- Obtenir les valeurs d'une énumération
SELECT value, description 
FROM gpkg_data_column_constraints 
WHERE constraint_name = 'enum_type_atlas'
ORDER BY value;

-- Valider une valeur avant insertion
SELECT EXISTS (
    SELECT 1 FROM gpkg_data_column_constraints
    WHERE constraint_name = 'enum_type_orographie'
    AND value = 'montagne'
) as est_valide;

-- Statistiques sur le schéma
SELECT 
    table_name,
    COUNT(*) as nb_colonnes_documentees
FROM gpkg_data_columns
GROUP BY table_name;
```

---

## Vues utilitaires et Validation

### 1. v_stats_atlas
Statistiques complètes par atlas :
```sql
SELECT * FROM v_stats_atlas WHERE identifiant = 'AtlasPaysage_dept_33_2021';
-- Résultat : nb UP, EP, SUP, dynamiques, documents, limites
```

### 2. v_relations_up_ep
Relations hiérarchiques UP ↔ EP :
```sql
SELECT * FROM v_relations_up_ep WHERE ep_id = 'AtlasPaysage_dept_33_2021.EP01';
```

### 3. v_relations_sup_up
Hiérarchie complète SUP → UP → EP :
```sql
SELECT * FROM v_relations_sup_up ORDER BY ep_nom, up_nom, sup_nom;
```

### 4. v_synthese_dynamiques
Analyse des dynamiques paysagères :
```sql
SELECT objet_evolution, nature_evolution, COUNT(*) as nb
FROM v_synthese_dynamiques
GROUP BY objet_evolution, nature_evolution;
```

### 5. v_projections_disponibles
Liste des 17 projections :
```sql
SELECT * FROM v_projections_disponibles ORDER BY territoire;
```

### 6. Triggers de validation

1. **trg_validate_atlas_identifiant** : Format "AtlasPaysage_*"
2. **trg_validate_up_identifiant** : Cohérence identifiant_global
3. **trg_validate_ep_identifiant** : Idem pour EP
4. **trg_validate_sup_identifiant** : Idem pour SUP
5. **trg_validate_up_json_motclef_generique** : Validation JSON
6. **trg_validate_up_json_motclef_toponymique** : Validation JSON
7. **trg_validate_ep_json_motclef_generique** : Validation JSON
8. **trg_validate_ep_json_motclef_toponymique** : Validation JSON

---

## Exemples d'utilisation

### Insérer un Atlas

```sql
INSERT INTO atlas_paysager (
    emprise, nom, identifiant, type_atlas,
    maitre_ouvrage, maitre_oeuvre,
    date_realisation_atlas, lien_atlas
) VALUES (
    ST_GeomFromText('MULTIPOLYGON(((0 44, 1 44, 1 45, 0 45, 0 44)))', 2154),
    'Atlas des paysages de la Gironde',
    'AtlasPaysage_dept_33_2021',
    'département',
    'Conseil Départemental de la Gironde',
    'Bureau d''études Paysage XYZ',
    '2021-10-31',
    'https://www.gironde.fr/atlas-paysages'
);
```

### Insérer une Unité Paysagère

```sql
INSERT INTO unite_paysagere (
    geometrie, identifiant_local, identifiant_global, nom,
    type_orographie1, dominante_paysagere1,
    mot_clef_generique, mot_clef_toponymique,
    lien_atlas_paysage, code_departement, code_region
) VALUES (
    ST_GeomFromText('MULTIPOLYGON(((0 44, 0.5 44, 0.5 44.5, 0 44.5, 0 44)))', 2154),
    'H1',
    'AtlasPaysage_dept_33_2021.H1',
    'La terrasse du Bazadais',
    'plaine',
    'paysage agricole',
    '["vallons", "coteaux", "terres labourées"]',
    '["Langon", "Garonne", "Lisos"]',
    'AtlasPaysage_dept_33_2021',
    '["33"]',
    '["75"]'
);
```

### Insérer une Dynamique

```sql
INSERT INTO dynamique (
    objet_evolution, nature_evolution, description,
    date_observation, date_fin,
    lien_up
) VALUES (
    'zones bâties',
    'augmentation',
    'Extension de la zone pavillonnaire au nord de Langon',
    '2015-01-01',
    '2021-12-31',
    'AtlasPaysage_dept_33_2021.H1'
);
```

### Ordre d'insertion recommandé (respecter les dépendances) :

```sql
-- 1. Atlas (parent racine)
INSERT INTO atlas_paysager (emprise, nom, identifiant, ...) VALUES (...);

-- 2. Ensembles paysagers (optionnel)
INSERT INTO ensemble_paysager (geometrie, identifiant_global, lien_atlas_paysage, ...) VALUES (...);

-- 3. Unités paysagères (référence atlas + optionnellement EP)
INSERT INTO unite_paysagere (geometrie, identifiant_global, lien_atlas_paysage, lien_ep, ...) VALUES (...);

-- 4. Sous-unités paysagères (référence UP)
INSERT INTO sous_unite_paysagere (geometrie, identifiant_global, lien_up, ...) VALUES (...);

-- 5. Éléments complémentaires
INSERT INTO limite_decoupage_paysager (...) VALUES (...);
INSERT INTO document_paysage (...) VALUES (...);
INSERT INTO dynamique (...) VALUES (...);
```

### Règles de nommage des identifiants

```
atlas_paysager.identifiant → AtlasPaysage_{code}_{année}
  Exemple : "AtlasPaysage_dept_33_2020"

unite_paysagere.identifiant_global → {lien_atlas}.{identifiant_local}
  Exemple : "AtlasPaysage_dept_33_2020.UP01"

ensemble_paysager.identifiant_global → {lien_atlas}.{identifiant_local}
  Exemple : "AtlasPaysage_dept_33_2020.E1"
```

**⚠️ Contrainte** : Les triggers SQL vérifient automatiquement la cohérence des identifiants.

### Format des champs JSON

Certains champs stockent des **tableaux** au format JSON :

```sql
-- ✅ CORRECT
mot_clef_generique = '["bocage", "vallée", "vignoble"]'
code_departement = '["33", "47"]'
code_region = '["75"]'

-- ❌ INCORRECT
mot_clef_generique = 'bocage, vallée'  -- Pas un JSON valide
code_departement = '[33, 47]'          -- Nombres non quotés
```

### Énumérations (valeurs autorisées)

Les contraintes `CHECK` imposent des valeurs fixes :

```sql
-- type_atlas
'département' | 'région' | 'parc naturel' | 'autre'

-- dominante_paysagere1/2
'paysage bâti continu' | 'paysage bâti discontinu' | 
'paysage d''infrastructures' | 'paysage agricole' | 
'paysage boisé' | 'paysage d''eau ou humide' | 
'paysage ouvert naturel'

-- nature_evolution (dynamique)
'apparition' | 'augmentation' | 'diminution' | 
'disparition' | 'stabilisation'
```

### Requêtes d'analyse

```sql
-- Compter les UP par type d'orographie
SELECT type_orographie1, COUNT(*) as nb
FROM unite_paysagere
GROUP BY type_orographie1
ORDER BY nb DESC;

-- Trouver les dynamiques d'augmentation des zones bâties
SELECT 
    d.objet_evolution,
    d.nature_evolution,
    up.nom as unite,
    d.description
FROM dynamique d
JOIN unite_paysagere up ON d.lien_up = up.identifiant_global
WHERE d.objet_evolution = 'zones bâties'
  AND d.nature_evolution = 'augmentation';

-- Statistiques par atlas
SELECT 
    nom,
    nb_unites_paysageres,
    nb_ensembles_paysagers,
    nb_dynamiques
FROM v_stats_atlas
ORDER BY nb_unites_paysageres DESC;
```

**→ Voir le script SQL ou le standard pour la liste complète des énumérations**

---

## Validation et tests

### Vérifier l'intégrité du GeoPackage

```bash
# Avec Python (inclus par défaut)
python -c "import sqlite3; conn = sqlite3.connect('paysage.gpkg'); print('Intégrité:', conn.execute('PRAGMA integrity_check').fetchone()[0]); conn.close()"

# Résultat attendu : "Intégrité: ok"
```

### Tests SQL recommandés

```sql
-- 1. Vérifier les métadonnées du template
SELECT * FROM _template_info;
-- Attendu : version v1.0.0, srs_id 4326

-- 2. Compter les couches
SELECT COUNT(*) FROM gpkg_contents;
-- Attendu : 7 couches

-- 3. Vérifier les contraintes de clés étrangères
PRAGMA foreign_key_check;
-- Attendu : aucun résultat (= pas d'erreur)

-- 4. Lister tous les triggers
SELECT name FROM sqlite_master WHERE type='trigger';
-- Attendu : trg_validate_atlas_identifiant, trg_validate_up_identifiant, etc.
```

### Tests unitaires recommandés

1. **Contraintes de clés étrangères** : Tenter d'insérer une UP avec un `lien_atlas` inexistant (doit échouer)
2. **Triggers d'identifiants** : Vérifier que les identifiants composés sont cohérents
3. **Énumérations** : Tester l'insertion de valeurs invalides dans les `CHECK` (doit échouer)
4. **Géométries** : Valider que toutes les géométries utilisent EPSG:4326

```sql
-- Test : Insertion avec mauvais lien_atlas (doit échouer)
INSERT INTO unite_paysagere (
    geometrie, identifiant_local, identifiant_global, 
    lien_atlas_paysage, nom, type_orographie1, dominante_paysagere1,
    mot_clef_generique, mot_clef_toponymique, 
    code_departement, code_region, lien_page_atlas
) VALUES (
    ST_GeomFromText('MULTIPOLYGON(((0 0, 1 0, 1 1, 0 1, 0 0)))', 4326),
    'UP01', 'AtlasInexistant.UP01', 
    'AtlasInexistant',  -- ❌ Erreur : atlas inexistant
    'Test', 'plaine', 'paysage agricole',
    '["test"]', '["test"]',
    '["33"]', '["75"]', 'http://example.com'
);
-- Résultat attendu : FOREIGN KEY constraint failed
```

---

## Problèmes courants

### Erreur : "FOREIGN KEY constraint failed"

**Cause** : Tentative d'insertion d'un enfant avant son parent.

**Solution** : Respecter l'ordre d'insertion (atlas → ensembles → unités → sous-unités).

### Erreur : "CHECK constraint failed"

**Cause** : Valeur invalide dans une énumération.

**Solution** : Vérifier que la valeur fait partie de la liste autorisée (voir script SQL).

```sql
-- Exemple : Voir les valeurs autorisées pour type_atlas
SELECT sql FROM sqlite_master WHERE name='atlas_paysager';
-- Chercher la ligne CHECK (type_atlas IN ...)
```

### Géométries non affichées dans QGIS

**Cause** : Géométries invalides ou corrompues.

**Solution** :
```sql
-- Vérifier les géométries
SELECT fid, ST_IsValid(geometrie) FROM unite_paysagere WHERE NOT ST_IsValid(geometrie);

-- Réparer les géométries
UPDATE unite_paysagere SET geometrie = ST_MakeValid(geometrie) WHERE NOT ST_IsValid(geometrie);
```

### Performances lentes sur les requêtes spatiales

**Cause** : Index spatial manquant.

**Solution** : Les index sont créés automatiquement par le script. Vérifier avec :
```sql
SELECT * FROM sqlite_master WHERE type='index' AND name LIKE 'idx_%';
```

---

## Utilisation dans QGIS

### Ouverture du GeoPackage

1. **QGIS** → **Couche** → **Ajouter une couche** → **Ajouter une couche vecteur**
2. Sélectionner `template_paysage_lambert93.gpkg`
3. Choisir les couches à afficher

### Formulaires automatiques

QGIS lit automatiquement l'extension Schema et génère des formulaires de saisie :

1. **Clic droit sur la couche** → **Propriétés**
2. Onglet **Formulaire d'attributs**
3. QGIS a automatiquement configuré :
   - **Listes déroulantes** pour `type_atlas`, `type_orographie`, `dominante_paysagere`, etc.
   - **Info-bulles** avec descriptions
   - **Validation** : seules les valeurs autorisées

### Édition de données

1. Activer l'édition (crayon) sur une couche
2. Ajouter une entité
3. Le formulaire affiche automatiquement les listes déroulantes
4. Saisir les données avec validation automatique
5. Enregistrer

---

## Références

### Standards et Normes

- **Standard Paysages CNIG v1.0.0** : https://cnig.gouv.fr/ressources-paysages-a26250.html
- **OGC GeoPackage 1.3** : http://www.geopackage.org/spec/
- **Extension WKT for CRS** : http://www.geopackage.org/spec/#extension_crs_wkt
- **Extension Schema** : http://www.geopackage.org/spec/#extension_schema
- **ISO 19115:2003** : Métadonnées géographiques
- **ISO 19162:2015** : WKT for Coordinate Reference Systems
- **INSPIRE** : https://inspire.ec.europa.eu/

### Outils

- **QGIS** : https://qgis.org/
- **GDAL/OGR** : https://gdal.org/
- **SQLite** : https://www.sqlite.org/
- **EPSG Registry** : https://epsg.org/
- **IGN Géodésie** : https://geodesie.ign.fr/

### Support

- **Email** : cnig@cnig.fr
- **GitHub** : https://github.com/cnigfr/schema-paysage
- **Issues** : https://github.com/cnigfr/schema-paysage/issues
- **Schema.data.gouv.fr** : https://schema.data.gouv.fr/cnigfr/schema-paysage/

---

## Contact et Contributions

**Maintenu par** : CNIG (Conseil National de l'Information Géolocalisée)  
**Licence** : Etalab Licence Ouverte 2.0  
**Version** : 1.0.0 - Décembre 2025

Pour toute question, suggestion ou contribution :
- **Email** : cnig@cnig.fr
- **GitHub Issues** : https://github.com/cnigfr/schema-paysage/issues