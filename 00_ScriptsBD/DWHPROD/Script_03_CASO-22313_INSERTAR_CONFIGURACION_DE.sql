INSERT INTO DWHADM.PARAMETROS_DE
(ID_DATA_ENTR, CO_MESA, NO_DATA_ENTR, NO_TABL_EXTE, NO_TABL_STG, IN_REPROCESO, IN_ESTADO, TX_FRECUENCIA, DE_OWNER, DE_DESC_CORT)
SELECT (SELECT NVL(MAX(ID_DATA_ENTR),0)+1 FROM DWHADM.PARAMETROS_DE) AS ID_DATA_ENTR,
       100 AS CO_MESA,
       'DISTRIBUCION DE AGENCIAS' AS NO_DATA_ENTR,
       'DE_DISTRIBUCION_AGENCIAS' AS NO_TABL_EXTE,
       'T_DISTRIBUCION_AGENCIAS'  AS NO_TABL_STG,
       0 AS IN_REPROCESO,
       1 AS IN_ESTADO,
       'MENSUAL' AS TX_FRECUENCIA,
       'OPERACIONES DE NEGOCIOS - NEGOCIOS' AS DE_OWNER,
       'DISTRIBUCION DE AGENCIAS' AS DE_DESC_CORT
FROM DUAL;


INSERT INTO DWHADM.PARAMETROS_DE
(ID_DATA_ENTR, CO_MESA, NO_DATA_ENTR, NO_TABL_EXTE, NO_TABL_STG, IN_REPROCESO, IN_ESTADO, TX_FRECUENCIA, DE_OWNER, DE_DESC_CORT)
SELECT (SELECT NVL(MAX(ID_DATA_ENTR),0)+1 FROM DWHADM.PARAMETROS_DE) AS ID_DATA_ENTR,
       100 AS CO_MESA,
       'GEOLOCALIZACION DE AGENCIAS' AS NO_DATA_ENTR,
       'DE_GEO_AGENCIAS' AS NO_TABL_EXTE,
       'T_GEO_AGENCIAS'  AS NO_TABL_STG,
       0 AS IN_REPROCESO,
       1 AS IN_ESTADO,
       'MENSUAL' AS TX_FRECUENCIA,
       'RED DE CANALES - MARKETING' AS DE_OWNER,
       'GEOLOCALIZACION DE AGENCIAS' AS DE_DESC_CORT
FROM DUAL;

COMMIT;