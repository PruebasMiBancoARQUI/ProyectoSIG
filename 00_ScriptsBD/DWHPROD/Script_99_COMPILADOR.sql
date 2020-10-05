------------------------------------------------------------------------
-- Script para compilar todos los objetos invalidos                   --
-- Editar el esquema correspondiente, en el parametro owner           --
-- Ejemplo: para TOPAZ, parametro_Owner varchar2(20) := 'EDYFICAR' ;  --
------------------------------------------------------------------------

DECLARE
parametro_Owner varchar2(20) := 'DWHADM' ;
BEGIN
  
FOR REC IN (
  SELECT OWNER,OBJECT_NAME,STATUS,DECODE(OBJECT_TYPE,'PACKAGE BODY','PACKAGE',OBJECT_TYPE) OBJECT_TYPE1  
  FROM DBA_OBJECTS WHERE STATUS='INVALID' AND OWNER =upper(parametro_Owner) 
  AND OBJECT_TYPE IN ('FUNCTION','PROCEDURE','PACKAGE BODY','TRIGGER','VIEW')) LOOP

BEGIN
EXECUTE IMMEDIATE 'ALTER '||REC.OBJECT_TYPE1||' '||REC.OWNER||'.'||REC.OBJECT_NAME||' COMPILE';

EXCEPTION 
    WHEN OTHERS THEN 
    NULL;
END;
    END LOOP;
END;
/