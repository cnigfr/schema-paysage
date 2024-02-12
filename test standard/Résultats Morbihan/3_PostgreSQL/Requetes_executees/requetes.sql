TRUNCATE TABLE "travail"."DecoupagePaysager" RESTART IDENTITY;
INSERT INTO "travail"."DecoupagePaysager" ("geometrie", "identifiantLocal", "identifiantGlobal", "nom", "lienPageAtlas", "motClefGenerique", "motClefToponymique", "description", "image", "dateDefinition", "codeRegion", "codeDepartement", "lienAtlas")
SELECT "geometrie", "identifiantLocal", "identifiantGlobal", "nom", "lienPageAtlas", "motClefGenerique", "motClefToponymique", "description", "image", "dateDefinition", "codeRegion", "codeDepartement", "lienAtlas" FROM "travail"."EnsemblePaysager"
UNION
SELECT "geometrie", "identifiantLocal", "identifiantGlobal", "nom", "lienPageAtlas", "motClefGenerique", "motClefToponymique", "description", "image", "dateDefinition", "codeRegion", "codeDepartement", "lienAtlas" FROM "travail"."UnitePaysagere"
UNION
SELECT "geometrie", "identifiantLocal", "identifiantGlobal", "nom", "lienPageAtlas", "motClefGenerique", "motClefToponymique", "description", "image", "dateDefinition", "codeRegion", "codeDepartement", "lienAtlas" FROM "travail"."SousUnitePaysagere";

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


-- Création des déclencheurs sur les trois tables
CREATE TRIGGER trigger_SousUnitePaysagere
AFTER INSERT OR UPDATE OR DELETE
ON "travail"."SousUnitePaysagere"
FOR EACH ROW
EXECUTE FUNCTION maj_DecoupagePaysager();

CREATE TRIGGER trigger_UnitePaysagere
AFTER INSERT OR UPDATE OR DELETE
ON "travail"."UnitePaysagere"
FOR EACH ROW
EXECUTE FUNCTION maj_DecoupagePaysager();

CREATE TRIGGER trigger_EnsemblePaysager
AFTER INSERT OR UPDATE OR DELETE
ON "travail"."EnsemblePaysager"
FOR EACH ROW
EXECUTE FUNCTION maj_DecoupagePaysager();