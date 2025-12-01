#!/usr/bin/env python3
"""
Script de création d'un GeoPackage à partir du template Standard Paysage CNIG
Compatible avec template_paysage.sql
"""

import sqlite3
import sys
import os
from pathlib import Path

def create_geopackage(output_path: str, sql_template_path: str = None):
    """Crée un GeoPackage à partir du script SQL template"""
    
    # Déterminer le chemin du script SQL
    if sql_template_path is None:
        # Chercher dans le même dossier
        script_dir = Path(__file__).parent
        possible_names = [
            'template_paysage_lambert93.sql',
            'template_paysage.sql',
            'paysage.sql'
        ]
        
        sql_template_path = None
        for name in possible_names:
            candidate = script_dir / name
            if candidate.exists():
                sql_template_path = candidate
                break
        
        if sql_template_path is None:
            print("❌ Erreur : Aucun fichier SQL trouvé")
            print(f"\n💡 Recherché dans : {script_dir}")
            print(f"   Noms attendus : {', '.join(possible_names)}")
            print("\n📝 Solutions :")
            print("   1. Placez template_paysage_lambert93.sql dans le même dossier")
            print("   2. Ou spécifiez le chemin : python create_gpkg.py mon.gpkg /chemin/vers/template.sql")
            return False
    else:
        sql_template_path = Path(sql_template_path)
    
    # Vérifier l'existence du fichier SQL
    if not sql_template_path.exists():
        print(f"❌ Fichier SQL introuvable : {sql_template_path}")
        return False
    
    # Supprimer le fichier de sortie s'il existe
    if os.path.exists(output_path):
        print(f"⚠️  Le fichier {output_path} existe déjà. Suppression...")
        os.remove(output_path)
    
    print("=" * 70)
    print("📦 Création GeoPackage - Standard Paysage CNIG v1.0.0")
    print("=" * 70)
    print(f"\n📄 Script SQL : {sql_template_path}")
    print(f"📦 Sortie     : {output_path}")
    print()
    
    # Lire le script SQL
    print("📖 Lecture du script SQL...")
    try:
        with open(sql_template_path, 'r', encoding='utf-8') as f:
            sql_script = f.read()
    except UnicodeDecodeError:
        # Essayer avec latin-1 si UTF-8 échoue
        with open(sql_template_path, 'r', encoding='latin-1') as f:
            sql_script = f.read()
    
    nb_lines = sql_script.count('\n') + 1
    print(f"   ✓ {nb_lines} lignes lues")
    
    # Créer le fichier GeoPackage
    print("\n🔧 Création du fichier GeoPackage...")
    try:
        conn = sqlite3.connect(output_path)
        
        # Définir l'Application ID (obligatoire pour GeoPackage)
        # Note: Le script SQL le définit aussi, mais on le fait ici pour garantir
        # que le fichier est bien reconnu comme GeoPackage dès le début
        conn.execute("PRAGMA application_id = 1196437808;")  # 0x47503130 = "GP10"
        conn.execute("PRAGMA user_version = 10300;")  # GeoPackage 1.3.0
        
        print("   ✓ Application ID défini (GeoPackage 1.3.0)")
        
    except sqlite3.Error as e:
        print(f"❌ Erreur création : {e}")
        return False
    
    # Exécuter le script SQL
    print("\n⚙️  Exécution du script SQL...")
    try:
        conn.executescript(sql_script)
        print("   ✓ Script exécuté avec succès")
        
    except sqlite3.Error as e:
        print(f"\n❌ Erreur SQL : {e}")
        
        # Essayer de localiser l'erreur
        error_msg = str(e).lower()
        print("\n🔍 Analyse de l'erreur...")
        
        lines = sql_script.split('\n')
        for i, line in enumerate(lines, 1):
            # Chercher des indices de l'erreur dans les lignes
            if any(keyword in line.lower() for keyword in error_msg.split()[:3]):
                print(f"\n📍 Ligne {i} (possible cause) :")
                start = max(0, i - 3)
                end = min(len(lines), i + 2)
                for j in range(start, end):
                    marker = ">>> " if j == i - 1 else "    "
                    print(f"{marker}Ligne {j+1}: {lines[j][:80]}")
                break
        
        conn.close()
        if os.path.exists(output_path):
            os.remove(output_path)
        return False
    
    # Validation de la structure
    print("\n✅ Validation de la structure...")
    
    try:
        cursor = conn.cursor()
        
        # Vérifier la version GeoPackage
        cursor.execute("PRAGMA application_id")
        app_id = cursor.fetchone()[0]
        
        cursor.execute("PRAGMA user_version")
        user_version = cursor.fetchone()[0]
        
        if app_id == 1196437808:
            major = user_version // 10000
            minor = (user_version % 10000) // 100
            patch = user_version % 100
            print(f"   ✓ Version GeoPackage : {major}.{minor}.{patch}")
        else:
            print(f"   ⚠️  Application ID inattendu : {app_id}")
        
        # Vérifier les extensions
        cursor.execute("SELECT extension_name FROM gpkg_extensions")
        extensions = [row[0] for row in cursor.fetchall()]
        if extensions:
            print(f"   ✓ Extensions : {', '.join(extensions)}")
        
        # Compter les tables
        cursor.execute("""
            SELECT name FROM sqlite_master 
            WHERE type='table' 
            AND name NOT LIKE 'sqlite_%'
            ORDER BY name
        """)
        all_tables = [row[0] for row in cursor.fetchall()]
        
        # Séparer tables système et métier
        system_tables = [t for t in all_tables if t.startswith('gpkg_') or t.startswith('_')]
        user_tables = [t for t in all_tables if not t.startswith('gpkg_') and not t.startswith('_') and not t.startswith('v_')]
        views = [t for t in all_tables if t.startswith('v_')]
        
        print(f"   ✓ Tables métier : {len(user_tables)}")
        print(f"   ✓ Vues : {len(views)}")
        print(f"   ✓ Tables système : {len(system_tables)}")
        
        # Vérifier les projections
        cursor.execute("SELECT COUNT(*) FROM gpkg_spatial_ref_sys WHERE srs_id > 0")
        nb_srs = cursor.fetchone()[0]
        print(f"   ✓ Projections : {nb_srs}")
        
        # Lister les tables métier
        if user_tables:
            print("\n📋 Tables de données créées :")
            for table in user_tables:
                # Vérifier si géographique
                cursor.execute(f"SELECT geometry_type_name FROM gpkg_geometry_columns WHERE table_name = ?", (table,))
                geom = cursor.fetchone()
                if geom:
                    print(f"   🗺️  {table:35} ({geom[0]})")
                else:
                    print(f"   📄 {table:35} (attributaire)")
        
        if views:
            print("\n👁️  Vues utilitaires :")
            for view in views:
                print(f"   • {view}")
        
        # Statistiques finales
        cursor.execute("SELECT COUNT(*) FROM gpkg_contents")
        nb_contents = cursor.fetchone()[0]
        
        file_size = os.path.getsize(output_path) / 1024
        
        print(f"\n📊 Résumé :")
        print(f"   • Couches enregistrées : {nb_contents}")
        print(f"   • Tables + vues : {len(user_tables) + len(views)}")
        print(f"   • Taille fichier : {file_size:.1f} Ko")
        
    except sqlite3.Error as e:
        print(f"   ⚠️  Erreur validation : {e}")
    
    finally:
        conn.commit()
        conn.close()
    
    print(f"\n✅ GeoPackage créé avec succès : {output_path}")
    return True


def main():
    """Point d'entrée principal"""
    
    # Analyser les arguments
    if len(sys.argv) > 3:
        print("Usage: python create_gpkg.py [output.gpkg] [template.sql]")
        print("\nExemples :")
        print("  python create_gpkg.py")
        print("  python create_gpkg.py mon_atlas.gpkg")
        print("  python ccreate_gpkg.py mon_atlas.gpkg /chemin/vers/template.sql")
        return 1
    
    output_path = sys.argv[1] if len(sys.argv) > 1 else "template_paysage.gpkg"
    sql_template = sys.argv[2] if len(sys.argv) > 2 else None
    
    success = create_geopackage(output_path, sql_template)
    
    if success:
        print("\n💡 Prochaines étapes :")
        print("   1. Ouvrir dans QGIS : Couches → Ajouter une couche GeoPackage")
        print("   2. Ou avec ogrinfo : ogrinfo -so template_paysage.gpkg")
        print("   3. Ou avec Python/geopandas : gpd.read_file('template_paysage.gpkg', layer='unite_paysagere')")
        print("\n📚 Documentation : voir README.md")
        print()
        return 0
    else:
        print("\n❌ Échec de la création. Vérifiez les erreurs ci-dessus.")
        print()
        return 1


if __name__ == "__main__":
    sys.exit(main())
