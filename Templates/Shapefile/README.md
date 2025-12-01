# Shapefiles - Standard Paysages CNIG

**Version 1.0.0** - Décembre 2025

---

## ⚠️ Avertissement Important

Ces shapefiles ont été créés à partir du GeoPackage `template_paysage.gpkg` et présentent des **limitations intrinsèques** au format Shapefile :

### Limitations du format Shapefile

1. **Noms de colonnes limités à 10 caractères** : Les noms originaux ont été tronqués
2. **Pas de contraintes de validation** : Les contraintes CHECK et triggers SQL ne sont pas supportés
3. **Pas de relations hiérarchiques automatiques** : Les clés étrangères ne sont pas enforced
4. **Encodage des caractères** : Possibles problèmes d'accents selon le logiciel utilisé
5. **Géométries NULL** : La table `dynamique` n'a pas de géométrie (fichier .dbf seulement)
6. **Pas de métadonnées ISO 19115** : Les métadonnées standardisées sont perdues
7. **Pas d'extension Schema** : Les listes déroulantes QGIS ne fonctionnent pas automatiquement

**→ Pour un usage professionnel, il est fortement recommandé d'utiliser le GeoPackage d'origine.**

---

## Table des matières

1. [Fichiers fournis](#fichiers-fournis)
2. [Correspondance des noms de colonnes](#correspondance-des-noms-de-colonnes)
3. [Structure des données](#structure-des-donnees)
4. [Règles de validation manuelle](#regles-de-validation-manuelle)
5. [Utilisation dans QGIS](#utilisation-dans-qgis)
6. [Conversion vers GeoPackage](#conversion-vers-geopackage)
7. [Projections](#projections)

---

## Fichiers fournis

Le dossier contient **7 shapefiles** (un par table du GeoPackage) :

```
template_paysage.shp/
├── atlas_paysager.shp/.dbf/.shx/.prj
├── ensemble_paysager.shp/.dbf/.shx/.prj
├── unite_paysagere.shp/.dbf/.shx/.prj
├── sous_unite_paysagere.shp/.dbf/.shx/.prj
├── limite_decoupage_paysager.shp/.dbf/.shx/.prj
├── document_paysage.shp/.dbf/.shx/.prj
├── dynamique.dbf  (pas de .shp car table attributaire)
└── README_shapefiles.md (ce fichier)
```

**Note** : Le fichier `dynamique.dbf` est une table attributaire sans géométrie.

---

## Correspondance des noms de colonnes

### Table : `atlas_paysager`

| Nom GeoPackage (original) | Nom Shapefile | Type | Description |
|---------------------------|---------------|------|-------------|
| `identifiant` | `identifian` | TEXT | Identifiant unique de l'atlas |
| `nom` | `nom` | TEXT | Nom de l'atlas |
| `type_atlas` | `typeAtlas` | TEXT | Type : département, région, parc naturel, autre |
| `maitrise_ouvrage` | `maitreOuvr` | TEXT | Maître d'ouvrage |
| `maitrise_oeuvre` | `maitreOeuv` | TEXT | Maître d'œuvre |
| `lien_page_atlas` | `lienAtlas` | TEXT | URL de l'atlas en ligne |
| `date_realisation` | `dateRealis` | DATE | Date de réalisation de l'atlas |
| `date_revision` | `dateRevisi` | DATE | Date de révision de l'atlas |
| `lien_opp` | `lienOPP` | TEXT | Lien vers l'Observatoire Photographique des Paysages |

**Valeurs autorisées pour `typeAtlas`** :
- `département`
- `région`
- `parc naturel`
- `autre`

---

### Table : `ensemble_paysager`

| Nom GeoPackage (original) | Nom Shapefile | Type | Description |
|---------------------------|---------------|------|-------------|
| `identifiant_local` | `idLocal` | TEXT | ID local (ex: E1) |
| `identifiant_global` | `idGlobal` | TEXT | ID global = {atlas}.{local} |
| `lien_atlas_paysage` | `lienAtlas` | TEXT | Référence vers atlas |
| `nom` | `nom` | TEXT | Nom de l'ensemble |
| `lien_page_atlas` | `lienPageAt` | TEXT | URL de la page |
| `description` | `descriptio` | TEXT | Description |
| `mot_clef_generique` | `motClefGen` | TEXT | Mots-clés (JSON) : ["bocage","vallée"] |
| `mot_clef_toponymique` | `motClefTop` | TEXT | Toponymes (JSON) : ["Médoc"] |
| `image` | `image` | TEXT | Lien vers image représentative |
| `date_definition` | `dateDefini` | DATE | Date de définition de l'ensemble |
| `date_actualisation` | `dateActual` | DATE | Date d'actualisation |
| `code_departement` | `codeDepar` | TEXT | Codes département (JSON) |
| `code_region` | `codeRegion` | TEXT | Codes région (JSON) |

---

### Table : `unite_paysagere`

| Nom GeoPackage (original) | Nom Shapefile | Type | Description |
|---------------------------|---------------|------|-------------|
| `identifiant_local` | `idLocal` | TEXT | ID local (ex: UP01) |
| `identifiant_global` | `idGlobal` | TEXT | ID global = {atlas}.{local} |
| `lien_atlas_paysage` | `lienAtlas` | TEXT | Référence vers atlas |
| `lien_ep` | `lienEP` | TEXT | Référence vers ensemble (optionnel) |
| `nom` | `nom` | TEXT | Nom de l'unité |
| `lien_page_atlas` | `lienPageAt` | TEXT | URL de la page |
| `type_orographie1` | `typeOro1` | TEXT | Type d'orographie principal |
| `type_orographie2` | `typeOro2` | TEXT | Type d'orographie secondaire |
| `dominante_paysagere1` | `dominante1` | TEXT | Dominante paysagère principale |
| `dominante_paysagere2` | `dominante2` | TEXT | Dominante paysagère secondaire |
| `type_localisation` | `typeLocal` | TEXT | Type de localisation |
| `description` | `descriptio` | TEXT | Description |
| `mot_clef_generique` | `motClefGen` | TEXT | Mots-clés (JSON) |
| `mot_clef_toponymique` | `motClefTop` | TEXT | Toponymes (JSON) |
| `image` | `image` | TEXT | Lien vers image représentative |
| `date_definition` | `dateDefini` | DATE | Date de définition de l'unité |
| `date_actualisation` | `dateActual` | DATE | Date d'actualisation |
| `code_departement` | `codeDepar` | TEXT | Codes département (JSON) |
| `code_region` | `codeRegion` | TEXT | Codes région (JSON) |

**Valeurs autorisées pour `typeOro1` et `typeOro2`** :
- `plaine`
- `vallée`
- `plateau`
- `colline`
- `montagne`
- `littoral`

**Valeurs autorisées pour `dominante1` et `dominante2`** :
- `paysage bâti continu`
- `paysage bâti discontinu`
- `paysage d'infrastructures`
- `paysage agricole`
- `paysage boisé`
- `paysage d'eau ou humide`
- `paysage ouvert naturel`

---

### Table : `sous_unite_paysagere`

| Nom GeoPackage (original) | Nom Shapefile | Type | Description |
|---------------------------|---------------|------|-------------|
| `identifiant_local` | `idLocal` | TEXT | ID local (ex: SUP01) |
| `identifiant_global` | `idGlobal` | TEXT | ID global = {up}.{local} |
| `lien_up` | `lienUP` | TEXT | Référence vers unité paysagère |
| `lien_atlas_paysage` | `lienAtlas` | TEXT | Référence vers atlas |
| `nom` | `nom` | TEXT | Nom de la sous-unité |
| `lien_page_atlas` | `lienPageAt` | TEXT | URL de la page |
| `description` | `descriptio` | TEXT | Description |
| `mot_clef_generique` | `motClefGen` | TEXT | Mots-clés (JSON) |
| `mot_clef_toponymique` | `motClefTop` | TEXT | Toponymes (JSON) |
| `image` | `image` | TEXT | Lien vers image représentative |
| `date_definition` | `dateDefini` | DATE | Date de définition de la sous-unité |
| `date_actualisation` | `dateActual` | DATE | Date d'actualisation |
| `code_departement` | `codeDepar` | TEXT | Codes département (JSON) |
| `code_region` | `codeRegion` | TEXT | Codes région (JSON) |

---

### Table : `limite_decoupage_paysager`

| Nom GeoPackage (original) | Nom Shapefile | Type | Description |
|---------------------------|---------------|------|-------------|
| `identifiant_local` | `idLocal` | TEXT | ID local |
| `identifiant_global` | `idGlobal` | TEXT | Identifiant global |
| `lien_atlas_paysage` | `lienAtlas` | TEXT | Référence vers atlas |
| `statut` | `statut` | TEXT | Statut de la limite |
| `largeur_estimee` | `largeurEst` | NUMERIC | Largeur estimée de la limite (en mètres) |
| `nature_limite` | `natureLim` | TEXT | Nature de la limite |

**Valeurs autorisées pour `natureLim`** :
- `cours d'eau`
- `ligne de crête`
- `ligne de rupture de pente`
- `lisière forestière`
- `infrastructure`
- `limite administrative`
- `autre`

---

### Table : `document_paysage`

| Nom GeoPackage (original) | Nom Shapefile | Type | Description |
|---------------------------|---------------|------|-------------|
| `lien_atlas_paysage` | `lienAtlas` | TEXT | Référence vers atlas |
| `nom` | `nom` | TEXT | Nom du document |
| `date` | `date` | DATE | Date de prise de vue ou création |
| `auteur` | `auteur` | TEXT | Auteur du document |
| `conditions_texte` | `condText` | TEXT | Conditions d'utilisation (texte) |
| `conditions_url` | `condURL` | TEXT | URL des conditions d'utilisation |
| `document` | `document` | TEXT | URL du document |

---

### Table : `dynamique` (fichier .dbf uniquement, pas de géométrie)

| Nom GeoPackage (original) | Nom Shapefile | Type | Description |
|---------------------------|---------------|------|-------------|
| `objet_evolution` | `objetEvo` | TEXT | Objet de l'évolution |
| `nature_evolution` | `natureEvo` | TEXT | Nature de l'évolution |
| `description` | `descriptio` | TEXT | Description |
| `date_observation_debut` | `dateObserv` | DATE | Date de début d'observation |
| `date_observation_fin` | `dateFin` | DATE | Date de fin d'observation |
| `lien_photographie` | `lienPhoto` | TEXT | Lien vers photographie illustrant l'évolution |
| `lien_up` | `lienUP` | TEXT | Référence vers unité paysagère |
| `lien_ep` | `lienEP` | TEXT | Référence vers ensemble paysager |
| `lien_sous_up` | `lienSousUP` | TEXT | Référence vers sous-unité paysagère |

**Valeurs autorisées pour `natureEvo`** :
- `apparition`
- `augmentation`
- `diminution`
- `disparition`
- `stabilisation`

---

## Structure des données

### Hiérarchie des entités

```
atlas_paysager
    ├── ensemble_paysager (optionnel)
    │       └── unite_paysagere
    │               └── sous_unite_paysagere
    └── unite_paysagere (si pas d'ensemble)
            └── sous_unite_paysagere

limite_decoupage_paysager → référence atlas
document_paysage → référence atlas (+ optionnellement UP ou EP)
dynamique → référence atlas + UP
```

### Relations entre tables (non imposées automatiquement)

**⚠️ Important** : Contrairement au GeoPackage, les shapefiles ne peuvent pas valider automatiquement ces relations. Vous devez les respecter manuellement lors de la saisie.

| Table enfant | Colonne | Référence vers | Colonne parent |
|-------------|---------|----------------|----------------|
| `ensemble_paysager` | `lienAtlas` | `atlas_paysager` | `identifian` |
| `unite_paysagere` | `lienAtlas` | `atlas_paysager` | `identifian` |
| `unite_paysagere` | `lienEP` | `ensemble_paysager` | `idGlobal` |
| `sous_unite_paysagere` | `lienUP` | `unite_paysagere` | `idGlobal` |
| `limite_decoupage_paysager` | `lienAtlas` | `atlas_paysager` | `identifian` |
| `document_paysage` | `lienAtlas` | `atlas_paysager` | `identifian` |
| `dynamique` | `lienUP` | `unite_paysagere` | `idGlobal` |
| `dynamique` | `lienEP` | `ensemble_paysager` | `idGlobal` |
| `dynamique` | `lienSousUP` | `sous_unite_paysagere` | `idGlobal` |

---

## Règles de validation manuelle

### Format des champs JSON

Les champs `motClefGen`, `motClefTop`, `codeDepar`, `codeRegion` doivent contenir des tableaux JSON valides :

```
✅ CORRECT :
["bocage", "vallée", "vignoble"]
["33", "47"]

❌ INCORRECT :
bocage, vallée
[33, 47]
```

### Règles de nommage des identifiants

```
atlas_paysager.identifian → AtlasPaysage_{code}_{année}
  Exemple : "AtlasPaysage_dept_33_2020"

unite_paysagere.idGlobal → {lienAtlas}.{idLocal}
  Exemple : "AtlasPaysage_dept_33_2020.UP01"

ensemble_paysager.idGlobal → {lienAtlas}.{idLocal}
  Exemple : "AtlasPaysage_dept_33_2020.E1"

sous_unite_paysagere.idGlobal → {lienUP}.{idLocal}
  Exemple : "AtlasPaysage_dept_33_2020.UP01.SUP01"
```

### Ordre d'insertion obligatoire

1. **`atlas_paysager`** (d'abord)
2. **`ensemble_paysager`** (optionnel, si groupement d'UP)
3. **`unite_paysagere`** (référence atlas + optionnellement EP)
4. **`sous_unite_paysagere`** (référence UP)
5. **`limite_decoupage_paysager`**, **`document_paysage`**, **`dynamique`** (références atlas/UP/EP)

### Contraintes à respecter manuellement

| Champ | Contrainte | Exemple valide |
|-------|-----------|----------------|
| `typeAtlas` | Liste fermée | `département`, `région`, `parc naturel`, `autre` |
| `typeOro1/2` | Liste fermée | `plaine`, `vallée`, `plateau`, `colline`, `montagne`, `littoral` |
| `dominante1/2` | Liste fermée | `paysage bâti continu`, `paysage agricole`, etc. |
| `natureLim` | Liste fermée | `cours d'eau`, `ligne de crête`, etc. |
| `natureEvo` | Liste fermée | `apparition`, `augmentation`, `diminution`, `disparition`, `stabilisation` |
| `dateRealis`, `dateRevisi`, `dateDefini`, `dateActual`, `dateObserv`, `dateFin`, `date` | Format date | `YYYY-MM-DD` (ex: `2020-06-15`) |
| `lienAtlas`, `lienPageAt`, `lienOPP`, `condURL`, `document`, `lienPhoto` | Format URL | `http://...` ou `https://...` |

---

## Utilisation dans QGIS

### Ouverture des shapefiles

1. **QGIS** → **Couche** → **Ajouter une couche vecteur**
2. Sélectionner les fichiers `.shp` souhaités
3. Les couches s'affichent automatiquement

### Vérification de l'intégrité des données

Utilisez des requêtes SQL dans QGIS pour valider les relations :

```sql
-- Trouver les UP sans atlas valide
SELECT * FROM unite_paysagere 
WHERE lienAtlas NOT IN (SELECT identifian FROM atlas_paysager);

-- Trouver les SUP sans UP valide
SELECT * FROM sous_unite_paysagere 
WHERE lienUP NOT IN (SELECT idGlobal FROM unite_paysagere);

-- Trouver les dates invalides
SELECT * FROM atlas_paysager 
WHERE dateRealis NOT LIKE '____-__-__';
```

---

## Conversion vers GeoPackage

Si vous souhaitez convertir vos shapefiles édités vers le format GeoPackage (recommandé) :

### Méthode 1 : avec ogr2ogr (ligne de commande)

```bash
# Créer un nouveau GeoPackage vide
ogr2ogr -f GPKG mon_atlas.gpkg atlas_paysager.shp

# Ajouter les autres couches
ogr2ogr -f GPKG -update -append mon_atlas.gpkg ensemble_paysager.shp -nln ensemble_paysager
ogr2ogr -f GPKG -update -append mon_atlas.gpkg unite_paysagere.shp -nln unite_paysagere
ogr2ogr -f GPKG -update -append mon_atlas.gpkg sous_unite_paysagere.shp -nln sous_unite_paysagere
ogr2ogr -f GPKG -update -append mon_atlas.gpkg limite_decoupage_paysager.shp -nln limite_decoupage_paysager
ogr2ogr -f GPKG -update -append mon_atlas.gpkg document_paysage.shp -nln document_paysage

# Pour la table dynamique (sans géométrie)
ogr2ogr -f GPKG -update -append mon_atlas.gpkg dynamique.dbf -nln dynamique
```

### Méthode 2 : avec QGIS

1. Charger tous les shapefiles dans QGIS
2. **Clic droit sur chaque couche** → **Exporter** → **Sauvegarder les entités sous...**
3. Format : **GeoPackage**
4. Fichier : `mon_atlas.gpkg`
5. Nom de couche : conserver le nom original
6. Pour les couches suivantes, cocher **Ajouter au GeoPackage existant**

**⚠️ Note** : Cette conversion ne restaure **pas** les contraintes, triggers et métadonnées du GeoPackage d'origine. Pour cela, utilisez le template GeoPackage original et importez vos données dedans.

---

## Projections

### Projection par défaut

Tous les shapefiles utilisent **Lambert 93 (EPSG:2154)** pour la France métropolitaine.

Le fichier `.prj` de chaque shapefile contient la définition WKT de Lambert 93 :

```
PROJCS["RGF93 / Lambert-93",
    GEOGCS["RGF93",
        DATUM["Reseau_Geodesique_Francais_1993",
            SPHEROID["GRS 1980",6378137,298.257222101]],
        PRIMEM["Greenwich",0],
        UNIT["degree",0.0174532925199433]],
    PROJECTION["Lambert_Conformal_Conic_2SP"],
    PARAMETER["standard_parallel_1",49],
    PARAMETER["standard_parallel_2",44],
    PARAMETER["latitude_of_origin",46.5],
    PARAMETER["central_meridian",3],
    PARAMETER["false_easting",700000],
    PARAMETER["false_northing",6600000],
    UNIT["metre",1]]
```

### Reprojection vers d'autres systèmes

Si vous devez travailler avec d'autres projections (outre-mer, WGS84, etc.) :

```bash
# Reprojeter vers WGS84 (EPSG:4326)
ogr2ogr -f "ESRI Shapefile" -t_srs EPSG:4326 atlas_wgs84.shp atlas_paysager.shp

# Reprojeter vers UTM 20N Guadeloupe (EPSG:5490)
ogr2ogr -f "ESRI Shapefile" -t_srs EPSG:5490 atlas_utm20.shp atlas_paysager.shp

# Reprojeter vers UTM 40S Réunion (EPSG:2975)
ogr2ogr -f "ESRI Shapefile" -t_srs EPSG:2975 atlas_utm40.shp atlas_paysager.shp
```

Voir le README principal du GeoPackage pour la liste complète des 17 projections supportées.

---

## Références

### Documentation complète

- **README principal (GeoPackage)** : Voir `template_paysage.gpkg/README.md`
- **Standard Paysages CNIG v1.0.0** : https://cnig.gouv.fr/ressources-paysages-a26250.html
- **QGIS** : https://qgis.org/
- **GDAL/OGR** : https://gdal.org/

### Support

- **Email** : cnig@cnig.fr
- **GitHub** : https://github.com/cnigfr/schema-paysage
- **Issues** : https://github.com/cnigfr/schema-paysage/issues

---

**Maintenu par** : CNIG (Conseil National de l'Information Géolocalisée)  
**Licence** : Etalab Licence Ouverte 2.0  
**Version** : 1.0.0 - Décembre 2025