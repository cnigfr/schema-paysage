SELECT 
    * 
FROM 
    "travail"."Dynamique" 
INNER JOIN 
    "travail"."UnitePaysagere"
ON 
    ( 
        "travail"."Dynamique"."lienUP" = "travail"."UnitePaysagere"."identifiantGlobal") 
INNER JOIN 
    "travail"."EnsemblePaysager" 
ON 
    ( 
        "travail"."Dynamique"."lienEP" = "travail"."EnsemblePaysager"."identifiantGlobal") 
INNER JOIN 
    "travail"."SousUnitePaysagere" 
ON 
    ( 
        "travail"."Dynamique"."lienSousUP" = "travail"."SousUnitePaysagere"."identifiantGlobal");