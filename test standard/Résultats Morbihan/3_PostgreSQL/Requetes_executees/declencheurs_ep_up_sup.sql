-- Création du déclencheur sur la table DecoupagePaysager
CREATE OR REPLACE FUNCTION maj_DecoupagePaysager()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        -- Supprimer toutes les entrées correspondantes dans DecoupagePaysager
        DELETE FROM "travail"."DecoupagePaysager"
        WHERE "identifiantGlobal" = OLD."identifiantGlobal";
    ELSE
        -- Supprimer toutes les entrées correspondantes dans DecoupagePaysager
        DELETE FROM "travail"."DecoupagePaysager"
        WHERE "identifiantGlobal" = OLD."identifiantGlobal";

        -- Insérer la nouvelle entrée
        INSERT INTO "travail"."DecoupagePaysager" ("geometrie", "identifiantLocal", "identifiantGlobal", "nom", "lienPageAtlas", "motClefGenerique", "motClefToponymique", "description", "image", "dateDefinition", "codeRegion", "codeDepartement", "lienAtlas")
        VALUES (NEW."geometrie", NEW."identifiantLocal", NEW."identifiantGlobal", NEW."nom", NEW."lienPageAtlas", NEW."motClefGenerique", NEW."motClefToponymique", NEW."description", NEW."image", NEW."dateDefinition", NEW."codeRegion", NEW."codeDepartement", NEW."lienAtlas");
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;