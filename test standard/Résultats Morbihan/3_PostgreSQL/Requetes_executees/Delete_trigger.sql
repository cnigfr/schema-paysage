-- Supprimer le déclencheur sur la première table
DROP TRIGGER IF EXISTS trigger_SousUnitePaysagere ON "travail"."SousUnitePaysagere";

-- Supprimer le déclencheur sur la deuxième table
DROP TRIGGER IF EXISTS trigger_UnitePaysagere ON "travail"."UnitePaysagere";

-- Supprimer le déclencheur sur la troisième table
DROP TRIGGER IF EXISTS trigger_EnsemblePaysager ON "travail"."EnsemblePaysager";

-- Supprimer la fonction plpgsql
DROP FUNCTION IF EXISTS maj_DecoupagePaysager();
