DECLARE
    ln_ind_existe    NUMBER(1);
BEGIN
    BEGIN
	    SELECT 1
	    INTO ln_ind_existe
	    FROM ALL_OBJECTS
        WHERE owner = 'DWHADM'
          AND object_name = 'SP_CI_PRESTAMOS_REFINANCIADOS';
		  
        EXECUTE IMMEDIATE 'DROP PROCEDURE DWHADM.SP_CI_PRESTAMOS_REFINANCIADOS';
	EXCEPTION
	    WHEN NO_DATA_FOUND THEN NULL;
    END;
END;
/

DECLARE
    ln_ind_existe    NUMBER(1);
BEGIN
    BEGIN
	    SELECT 1
	    INTO ln_ind_existe
	    FROM ALL_OBJECTS
        WHERE owner = 'ODS'
          AND object_name = 'T_MD_SOLICITUDES_N1';
		  
        EXECUTE IMMEDIATE 'DROP INDEX ODS.T_MD_SOLICITUDES_N1';
	EXCEPTION
	    WHEN NO_DATA_FOUND THEN NULL;
    END;
END;
/


