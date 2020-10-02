----INSERT DATA ENTRY CIERRE_32 
INSERT INTO DWHADM.PARAMETROS_DE
(ID_DATA_ENTR, CO_MESA, NO_DATA_ENTR, NO_TABL_EXTE, NO_TABL_STG, IN_REPROCESO, IN_ESTADO, TX_FRECUENCIA, DE_OWNER, DE_DESC_CORT)
SELECT (SELECT NVL(MAX(ID_DATA_ENTR),0)+1 FROM DWHADM.PARAMETROS_DE) AS ID_DATA_ENTR,
       100 AS CO_MESA,
       'CIERRE_32' AS NO_DATA_ENTR,
       'DE_CIERRE_32' AS NO_TABL_EXTE,
       'T_CIERRE_32'  AS NO_TABL_STG,
       0 AS IN_REPROCESO,
       1 AS IN_ESTADO,
       'MENSUAL' AS TX_FRECUENCIA,
       'PLANEAMIENTO' AS DE_OWNER,
       'CIERRE 32' AS DE_DESC_CORT
FROM DUAL;


----INSERT DATA ENTRY CANAL DE COBRANZA
INSERT INTO DWHADM.PARAMETROS_DE
(ID_DATA_ENTR, CO_MESA,NO_DATA_ENTR, NO_TABL_EXTE, NO_TABL_STG, IN_REPROCESO, IN_ESTADO, TX_FRECUENCIA, DE_OWNER, DE_DESC_CORT)
SELECT (SELECT NVL(MAX(ID_DATA_ENTR),0)+1 FROM DWHADM.PARAMETROS_DE) AS ID_DATA_ENTR,
       100 AS CO_MESA,
       'CANAL_COBRANZA' AS NO_DATA_ENTR,
       'DE_CANAL_COBRANZA' AS NO_TABL_EXTE,
       'T_CANAL_COBRANZA'  AS NO_TABL_STG,
       0 AS IN_REPROCESO,
       1 AS IN_ESTADO,
       'MENSUAL' AS TX_FRECUENCIA,
       'PLANEAMIENTO' AS DE_OWNER,
       'CANAL DE COBRANZA DE PRESTAMOS' AS DE_DESC_CORT
FROM DUAL;



