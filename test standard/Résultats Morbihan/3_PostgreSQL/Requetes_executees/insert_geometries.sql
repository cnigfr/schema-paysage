UPDATE "travail"."EnsemblePaysager"
SET "geometrie" = "travail"."Regroupee"."geom"
FROM "travail"."Regroupee"
WHERE "travail"."EnsemblePaysager"."identifiantGlobal" = "travail"."Regroupee"."identifiantGlobal";
