ALTER TABLE paysage."UnitePaysagere" ADD FOREIGN KEY ("typeOrographie1") REFERENCES paysage."TypeOrographie"("TypeOrographie"); 
ALTER TABLE paysage."UnitePaysagere" ADD FOREIGN KEY ("typeOrographie2") REFERENCES paysage."TypeOrographie"("TypeOrographie"); 
ALTER TABLE paysage."UnitePaysagere" ADD FOREIGN KEY ("dominantePaysagere1") REFERENCES paysage."DominantePaysagere"("DominantePaysagere"); 
ALTER TABLE paysage."UnitePaysagere" ADD FOREIGN KEY ("dominantePaysagere2") REFERENCES paysage."DominantePaysagere"("DominantePaysagere");

---

ALTER TABLE paysage."UnitePaysagere" ADD FOREIGN KEY ("typeOrographie1") REFERENCES paysage."TypeOrographie"("TypeOrographie"); 
ALTER TABLE paysage."UnitePaysagere" ADD FOREIGN KEY ("typeOrographie2") REFERENCES paysage."TypeOrographie"("TypeOrographie"); 
ALTER TABLE paysage."UnitePaysagere" ADD FOREIGN KEY ("dominantePaysagere1") REFERENCES paysage."DominantePaysagere"("DominantePaysagere"); 
ALTER TABLE paysage."UnitePaysagere" ADD FOREIGN KEY ("dominantePaysagere2") REFERENCES paysage."DominantePaysagere"("DominantePaysagere"); 


-- FUNCTION

CREATE OR REPLACE FUNCTION paysage.f_UnitePaysagere_insert()

RETURNS trigger
LANGUAGE 'plpgsql'
COST 100
VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
UPDATE paysage."UnitePaysagere" SET "opSaisie"=session_user WHERE id=new.id;
UPDATE paysage."UnitePaysagere" SET "dateCrea"=current_timestamp WHERE id=new.id;
RETURN NEW;
END;

$BODY$;

CREATE OR REPLACE FUNCTION paysage.f_UnitePaysagere_update()

RETURNS trigger
LANGUAGE 'plpgsql'
COST 100
VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
UPDATE paysage."UnitePaysagere" SET "opSaisie"=session_user WHERE id=OLD.id;
UPDATE paysage."UnitePaysagere" SET "dateModif"=current_timestamp WHERE id=OLD.id;
RETURN NEW;
END;

$BODY$;

-- TRIGGER

CREATE OR REPLACE TRIGGER tr_UnitePaysagere_insert
AFTER INSERT
ON paysage."UnitePaysagere"
FOR EACH ROW
EXECUTE FUNCTION paysage.f_UnitePaysagere_insert();


CREATE OR REPLACE TRIGGER tr_UnitePaysagere_update
AFTER UPDATE
ON paysage."UnitePaysagere"
FOR EACH ROW
WHEN (old.geometrie IS DISTINCT FROM new.geometrie OR old.nom::text IS DISTINCT FROM new.nom::text)
EXECUTE FUNCTION paysage.f_UnitePaysagere_update();