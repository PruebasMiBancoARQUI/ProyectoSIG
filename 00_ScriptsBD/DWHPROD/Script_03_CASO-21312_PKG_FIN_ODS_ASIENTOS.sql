CREATE OR REPLACE PACKAGE DWHADM.PKG_FIN_ODS_ASIENTOS
------------------------------------------------------------------------------------------------------------
-- RESUMEN
-- PROYECTO : DATAMART FINANZAS
-- NOMBRE   : PKG_FIN_ODS_ASIENTOS
-- AUTOR    : GORA S.A.C
-- FECHA DE CREACIÓN : 22/12/2014
-- DESCRIPCIÓN : PAQUETE PARA EJECUTAR EL ESQUEMA ODS DE ASIENTOS
------------------------------------------------------------------------------------------------------------
-- MODIFICACIONES
-- REQUERIMIENTO RESPONSABLE FECHA DESCRIPCIÓN
------------------------------------------------------------------------------------------------------------
 IS

  V_NUM_EJECUCION NUMBER;
  V_NUM_PROCESO   NUMBER;
  V_CIFRA_CONTROL NUMBER;
  V_MENSAJE        VARCHAR2(4000);

  ---------------------------------------------------------------------------------------------------------------------------------
  -- RESUMEN
  -- DESCRIPCIÓN       : PROCEDIMIENTO PARA CARGAR ASIENTOS, MOVIMIENTOS ODS
  -- FECHA DE CREACIÓN : 22/12/2014
  -- AUTOR             : GORA S.A.C
  -- TABLA DESTINO     : NO APLICA
  -- TABLAS FUENTES    : NO APLICA
  -- PARAMETROS        : V_FE_INICIO     : FECHA INICIO DE CARGA
  --                     V_FE_FIN        : FECHA FIN DE CARGA
  --                     V_CODE_ERROR    : PUEDE TOMAR VALORES COMO 1(CORRECTO) O -1(INCORRECTO)
  --                     V_MENSAJE_ERROR : MENSAJE DE ERROR
  -- OBSERVACION       : PROCEDIMIENTO PRINCIPAL
  ---------------------------------------------------------------------------------------------------------------------------------

  PROCEDURE SP_CARGA_ASIENTOS_ODS(V_FE_INICIO  IN VARCHAR2,
                                  V_FE_FIN     IN VARCHAR2,
                                  V_CODE_ERROR    OUT NUMBER,
                                  V_MENSAJE_ERROR OUT VARCHAR2);

  ---------------------------------------------------------------------------------------------------------------------------------
  -- RESUMEN
  -- DESCRIPCIÓN       : PROCEDIMIENTO PARA CARGAR LA TABLA DE MOVIMIENTOS AL ESQUEMA ODS
  -- FECHA DE CREACIÓN : 22/12/2014
  -- AUTOR             : GORA S.A.C
  -- TABLA DESTINO     : ODS.HD_MOVIMIENTOS
  -- TABLAS FUENTES    : STG.T_MOVIMIENTOS
  -- PARAMETROS        : V_CODE_ERROR : PUEDE TOMAR VALORES COMO 1(CORRECTO) O -1(INCORRECTO)
  --                     V_MENSAJE_ERROR : MENSAJE DE ERROR
  -- OBSERVACION       : NO APLICA
  ---------------------------------------------------------------------------------------------------------------------------------


   PROCEDURE SP_MOVIMIENTOS_ODS(V_CODE_ERROR    OUT NUMBER,
                                V_MENSAJE_ERROR OUT VARCHAR2);

  ---------------------------------------------------------------------------------------------------------------------------------
  -- RESUMEN
  -- DESCRIPCIÓN       : PROCEDIMIENTO PARA CARGAR LA TABLA TEMPORAL DE MOVIMIENTOS AL ESQUEMA ODS
  -- FECHA DE CREACIÓN : 22/12/2014
  -- AUTOR             : GORA S.A.C
  -- TABLA DESTINO     : ODS.TD_MOVIMIENTOS
  -- TABLAS FUENTES    : ODS.HD_MOVIMIENTOS
  -- PARAMETROS        : V_FE_INICIO : FECHA INICIO DE CARGA
  --                     V_FE_FIN : FECHA FIN DE CARGA
  --                     V_CODE_ERROR : PUEDE TOMAR VALORES COMO 1(CORRECTO) O -1(INCORRECTO)
  --                     V_MENSAJE_ERROR : MENSAJE DE ERROR
  -- OBSERVACION       : NO APLICA
  ---------------------------------------------------------------------------------------------------------------------------------


  PROCEDURE SP_TEMP_MOVIMIENTOS_ODS(V_FE_INICIO  IN VARCHAR2,
                                    V_FE_FIN     IN VARCHAR2,
                                    V_CODE_ERROR    OUT NUMBER,
                                    V_MENSAJE_ERROR OUT VARCHAR2);


  ---------------------------------------------------------------------------------------------------------------------------------
  -- RESUMEN
  -- DESCRIPCIÓN       : PROCEDIMIENTO PARA CARGAR LA TABLA HISTÓRICA DE ASIENTOS AL ESQUEMA ODS
  -- FECHA DE CREACIÓN : 22/12/2014
  -- AUTOR             : GORA S.A.C
  -- TABLA DESTINO     : ODS.HD_ASIENTOS
  -- TABLAS FUENTES    : STG.T_MOVIMIENTOS_CONTABLES
  --                     STG.T_ASIENTOS
  --                     STG.T_MOVIMIENTOS
  --                     STG.T_TEMP_ASIENTO
  --                     STG.T_REFERENCIA_ASIENTOS
  -- PARAMETROS        : V_FE_INICIO : FECHA INICIO DE CARGA
  --                     V_FE_FIN : FECHA FIN DE CARGA
  --                     V_CODE_ERROR : PUEDE TOMAR VALORES COMO 1(CORRECTO) O -1(INCORRECTO)
  --                     V_MENSAJE_ERROR : MENSAJE DE ERROR
  -- OBSERVACION       : NO APLICA
  ---------------------------------------------------------------------------------------------------------------------------------

   PROCEDURE SP_ASIENTOS_ODS(V_FE_INICIO  IN VARCHAR2,
                             V_FE_FIN     IN VARCHAR2,
                             V_CODE_ERROR    OUT NUMBER,
                             V_MENSAJE_ERROR OUT VARCHAR2);


END PKG_FIN_ODS_ASIENTOS;
/
CREATE OR REPLACE PACKAGE BODY DWHADM.PKG_FIN_ODS_ASIENTOS
------------------------------------------------------------------------------------------------------------
-- RESUMEN
-- PROYECTO : DATAMART FINANZAS
-- NOMBRE   : PKG_FIN_ODS_ASIENTOS
-- AUTOR    : GORA S.A.C
-- FECHA DE CREACIÓN : 22/12/2014
-- DESCRIPCIÓN : PAQUETE PARA EJECUTAR EL ESQUEMA ODS DE ASIENTOS
------------------------------------------------------------------------------------------------------------
-- MODIFICACIONES
-- REQUERIMIENTO RESPONSABLE FECHA DESCRIPCIÓN
------------------------------------------------------------------------------------------------------------
 IS

  ---------------------------------------------------------------------------------------------------------------------------------
  -- RESUMEN
  -- DESCRIPCIÓN       : PROCEDIMIENTO PARA CARGAR ASIENTOS, MOVIMIENTOS ODS
  -- FECHA DE CREACIÓN : 22/12/2014
  -- AUTOR             : GORA S.A.C
  -- TABLA DESTINO     : NO APLICA
  -- TABLAS FUENTES    : NO APLICA
  -- PARAMETROS        : V_FE_INICIO     : FECHA INICIO DE CARGA
  --                     V_FE_FIN        : FECHA FIN DE CARGA
  --                     V_CODE_ERROR    : PUEDE TOMAR VALORES COMO 1(CORRECTO) O -1(INCORRECTO)
  --                     V_MENSAJE_ERROR : MENSAJE DE ERROR
  -- OBSERVACION       : PROCEDIMIENTO PRINCIPAL
  ---------------------------------------------------------------------------------------------------------------------------------

  PROCEDURE SP_CARGA_ASIENTOS_ODS(V_FE_INICIO  IN VARCHAR2,
                                  V_FE_FIN     IN VARCHAR2,
                                  V_CODE_ERROR    OUT NUMBER,
                                  V_MENSAJE_ERROR OUT VARCHAR2) IS

  V_EXCEPTION EXCEPTION;

  BEGIN

    -- PROCEDIMIENTO PARA CARGAR LA TABLA DE MOVIMIENTOS AL ESQUEMA ODS
    DWHADM.PKG_FIN_ODS_ASIENTOS.SP_MOVIMIENTOS_ODS(V_CODE_ERROR,V_MENSAJE_ERROR);
    IF V_CODE_ERROR = -1 THEN
       RAISE V_EXCEPTION;
    END IF;

    --PROCEDIMIENTO PARA CARGAR LA TABLA HISTÓRICA DE ASIENTOS AL ESQUEMA ODS
    DWHADM.PKG_FIN_ODS_ASIENTOS.SP_TEMP_MOVIMIENTOS_ODS(V_FE_INICIO,V_FE_FIN,V_CODE_ERROR,V_MENSAJE_ERROR);
    IF V_CODE_ERROR = -1 THEN
       RAISE V_EXCEPTION;
    END IF;

    --PROCEDIMIENTO PARA CARGAR LA TABLA HISTÓRICA DE ASIENTOS AL ESQUEMA ODS
    DWHADM.PKG_FIN_ODS_ASIENTOS.SP_ASIENTOS_ODS(V_FE_INICIO,V_FE_FIN,V_CODE_ERROR,V_MENSAJE_ERROR);
    IF V_CODE_ERROR = -1 THEN
       RAISE V_EXCEPTION;
    END IF;

 EXCEPTION
    WHEN OTHERS THEN
      V_CODE_ERROR    := -1;
      V_MENSAJE_ERROR := 'DWHADM.PKG_FIN_ODS_ASIENTOS.SP_CARGA_ASIENTOS_ODS'||'-'||SQLERRM||'-'||V_MENSAJE_ERROR;

 END SP_CARGA_ASIENTOS_ODS;

  ---------------------------------------------------------------------------------------------------------------------------------
  -- RESUMEN
  -- DESCRIPCIÓN       : PROCEDIMIENTO PARA CARGAR LA TABLA DE MOVIMIENTOS AL ESQUEMA ODS
  -- FECHA DE CREACIÓN : 22/12/2014
  -- AUTOR             : GORA S.A.C
  -- TABLA DESTINO     : ODS.HD_MOVIMIENTOS
  -- TABLAS FUENTES    : STG.T_MOVIMIENTOS
  -- PARAMETROS        : V_CODE_ERROR : PUEDE TOMAR VALORES COMO 1(CORRECTO) O -1(INCORRECTO)
  --                     V_MENSAJE_ERROR : MENSAJE DE ERROR
  -- OBSERVACION       : NO APLICA
  ---------------------------------------------------------------------------------------------------------------------------------

   PROCEDURE SP_MOVIMIENTOS_ODS(V_CODE_ERROR    OUT NUMBER,
                                V_MENSAJE_ERROR OUT VARCHAR2) IS

    V_EJECUCION NUMBER;
    V_EXCEPTION EXCEPTION;
    V_CIFRA_CONTROL NUMBER;
    V_FE_CARGA_INICIO   DATE;
    V_FE_CARGA_FIN      DATE;

  BEGIN

    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT = ''DD/MM/YYYY''';

    SELECT NVL(MAX(A.NU_EJECUCION), 1)
      INTO V_EJECUCION
      FROM DWHADM.CONTROL_ETL_CABECERA A
     WHERE A.CO_ETL = 190;

    V_NUM_PROCESO := 10;
    V_CODE_ERROR := 1;
    V_CIFRA_CONTROL := 0;
    DWHADM.PKG_CONTROL_ETL.SP_CAMBIA_ESTADO_ETL(V_ETL_TIPO_ETL      => 190,
                                                V_ETL_NUM_EJECUCION => V_EJECUCION,
                                                V_ETL_NUM_PROCESO   => V_NUM_PROCESO,
                                                V_ETL_CIFRA_CONTROL => V_CIFRA_CONTROL,
                                                V_ETL_ESTADO        => 'I',
                                                V_ETL_CODE          => V_CODE_ERROR,
                                                V_ETL_MENSAJE       => V_MENSAJE_ERROR);

    IF V_CODE_ERROR = -1 THEN
      RAISE V_EXCEPTION;
    END IF;

    V_FE_CARGA_INICIO:=ADD_MONTHS(TO_DATE(TO_CHAR(SYSDATE,'YYYYMM'),'YYYYMM'),-1);
    V_FE_CARGA_FIN   :=TRUNC(SYSDATE);

    ODS.PKG_ODS_GENERICO.SP_GEN_PARTICIONES ('ODS',
                                             'HD_MOVIMIENTOS',
                                             'FE_PROCESO',
                                             'DATE',
                                             'DIARIA',
                                             'P_MOVIMIENTOS_',
                                             20000,
                                             'ODS_DATA_01',
                                             V_CODE_ERROR,
                                             V_MENSAJE_ERROR);
    IF V_CODE_ERROR = -1 THEN
      RAISE V_EXCEPTION;
    END IF;

    ODS.PKG_ODS_GENERICO.SP_TRUNC_PARTITION_PERIODO(V_FE_CARGA_INICIO,V_FE_CARGA_FIN,'ODS','HD_MOVIMIENTOS',
                                                    'P_MOVIMIENTOS_','DIARIA', V_CODE_ERROR,V_MENSAJE_ERROR);
    IF V_CODE_ERROR = -1 THEN
      RAISE V_EXCEPTION;
    END IF;

    INSERT /*+ APPEND*/
    INTO ODS.HD_MOVIMIENTOS NOLOGGING
     SELECT M.ASIENTO,
            M.TRREAL,
            M.ORDINAL,
            M.TIPO,
            TO_NUMBER(M.C0025),
            M.C5158,
            M.SUCURSAL,
            M.FECHAPROCESO,
            M.C4649,
            M.ACTION,
            M.DESCRIPTOR,
            M.C0024,
            SYSDATE
       FROM STG.T_MOVIMIENTOS M
      WHERE M.FECHAPROCESO BETWEEN V_FE_CARGA_INICIO AND V_FE_CARGA_FIN;

    V_CIFRA_CONTROL := SQL%ROWCOUNT;
    COMMIT;

    ODS.PKG_ODS_GENERICO.SP_ESTADISTICAS_PARTITION (V_FE_CARGA_INICIO,
                                                    V_FE_CARGA_FIN,
                                                    'ODS',
                                                    'HD_MOVIMIENTOS',
                                                    'DIARIA',
                                                    'P_MOVIMIENTOS_',
                                                     V_CODE_ERROR,
                                                     V_MENSAJE_ERROR);
    IF V_CODE_ERROR = -1 THEN
      RAISE V_EXCEPTION;
    END IF;

    ODS.PKG_ODS_GENERICO.SP_ELIMINA_PAPELERA;

    DWHADM.PKG_CONTROL_ETL.SP_CAMBIA_ESTADO_ETL(V_ETL_TIPO_ETL      => 190,
                                                V_ETL_NUM_EJECUCION => V_EJECUCION,
                                                V_ETL_NUM_PROCESO   => V_NUM_PROCESO,
                                                V_ETL_CIFRA_CONTROL => V_CIFRA_CONTROL,
                                                V_ETL_ESTADO        => 'F',
                                                V_ETL_CODE          => V_CODE_ERROR,
                                                V_ETL_MENSAJE       => V_MENSAJE_ERROR);

    IF V_CODE_ERROR = -1 THEN
      RAISE V_EXCEPTION;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      V_CODE_ERROR    := -1;
      V_MENSAJE_ERROR := 'DWHADM.PKG_FIN_ODS_ASIENTOS.SP_MOVIMIENTOS_ODS'||'-'||SQLERRM||'-'||V_MENSAJE_ERROR;

      INSERT INTO DWHADM.CONTROL_ERROR
        (CO_ETL, NU_EJECUCION,  DE_ERROR, FE_ERROR)
        SELECT 190,
               V_EJECUCION,
               SUBSTR(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, 1, 2000) ||
               SUBSTR(V_MENSAJE_ERROR, 1, 400),
               SYSDATE
          FROM DUAL;
      COMMIT;

      DWHADM.PKG_CONTROL_ETL.SP_CAMBIA_ESTADO_ETL(V_ETL_TIPO_ETL      => 180,
                                                  V_ETL_NUM_EJECUCION => V_EJECUCION,
                                                  V_ETL_NUM_PROCESO   => V_NUM_PROCESO,
                                                  V_ETL_CIFRA_CONTROL => V_CIFRA_CONTROL,
                                                  V_ETL_ESTADO        => 'E',
                                                  V_ETL_CODE          => V_CODE_ERROR,
                                                  V_ETL_MENSAJE       => V_MENSAJE);

  END SP_MOVIMIENTOS_ODS;

  ---------------------------------------------------------------------------------------------------------------------------------
  -- RESUMEN
  -- DESCRIPCIÓN       : PROCEDIMIENTO PARA CARGAR LA TABLA TEMPORAL DE MOVIMIENTOS AL ESQUEMA ODS
  -- FECHA DE CREACIÓN : 22/12/2014
  -- AUTOR             : GORA S.A.C
  -- TABLA DESTINO     : ODS.TD_MOVIMIENTOS
  -- TABLAS FUENTES    : ODS.HD_MOVIMIENTOS
  -- PARAMETROS        : V_FE_INICIO : FECHA INICIO DE CARGA
  --                     V_FE_FIN : FECHA FIN DE CARGA
  --                     V_CODE_ERROR : PUEDE TOMAR VALORES COMO 1(CORRECTO) O -1(INCORRECTO)
  --                     V_MENSAJE_ERROR : MENSAJE DE ERROR
  -- OBSERVACION       : NO APLICA
  ---------------------------------------------------------------------------------------------------------------------------------

  PROCEDURE SP_TEMP_MOVIMIENTOS_ODS(V_FE_INICIO  IN VARCHAR2,
                                    V_FE_FIN     IN VARCHAR2,
                                    V_CODE_ERROR    OUT NUMBER,
                                    V_MENSAJE_ERROR OUT VARCHAR2) IS

    V_EJECUCION NUMBER;
    V_EXCEPTION EXCEPTION;
    V_CIFRA_CONTROL NUMBER;
    V_FE_CARGA_INICIO   DATE;
    V_FE_CARGA_FIN      DATE;
    V_NU_CARGA_INICIO   NUMBER;
    V_NU_CARGA_FIN      NUMBER;

  BEGIN

    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT = ''DD/MM/YYYY''';

    SELECT NVL(MAX(A.NU_EJECUCION), 1)
      INTO V_EJECUCION
      FROM DWHADM.CONTROL_ETL_CABECERA A
     WHERE A.CO_ETL = 190;

    V_NUM_PROCESO := 20;
    V_CODE_ERROR := 1;
    V_CIFRA_CONTROL := 0;
    DWHADM.PKG_CONTROL_ETL.SP_CAMBIA_ESTADO_ETL(V_ETL_TIPO_ETL      => 190,
                                                V_ETL_NUM_EJECUCION => V_EJECUCION,
                                                V_ETL_NUM_PROCESO   => V_NUM_PROCESO,
                                                V_ETL_CIFRA_CONTROL => V_CIFRA_CONTROL,
                                                V_ETL_ESTADO        => 'I',
                                                V_ETL_CODE          => V_CODE_ERROR,
                                                V_ETL_MENSAJE       => V_MENSAJE_ERROR);
    IF V_CODE_ERROR = -1 THEN
      RAISE V_EXCEPTION;
    END IF;

    IF (V_FE_INICIO IS NULL AND V_FE_FIN IS NULL)THEN
      V_FE_CARGA_INICIO:=ADD_MONTHS(TO_DATE(TO_CHAR(SYSDATE,'YYYYMM'),'YYYYMM'),-1);
      V_FE_CARGA_FIN   :=TRUNC(SYSDATE);
      V_NU_CARGA_INICIO:=TO_NUMBER(TO_CHAR(V_FE_CARGA_INICIO,'YYYYMMDD'));
      V_NU_CARGA_FIN   :=TO_NUMBER(TO_CHAR(V_FE_CARGA_FIN,'YYYYMMDD'));

    ELSE
      V_FE_CARGA_INICIO:=TO_DATE(V_FE_INICIO,'DD/MM/YYYY');
      V_FE_CARGA_FIN   :=TO_DATE(V_FE_FIN,'DD/MM/YYYY');
      V_NU_CARGA_INICIO:=TO_NUMBER(TO_CHAR(V_FE_CARGA_INICIO,'YYYYMMDD'));
      V_NU_CARGA_FIN   :=TO_NUMBER(TO_CHAR(V_FE_CARGA_FIN,'YYYYMMDD'));

    END IF;

    -- TRUNCA TABLA
      ODS.PKG_ODS_GENERICO.SP_TRUNCATE_TABLE('ODS','TD_MOVIMIENTOS',V_CODE_ERROR, V_MENSAJE_ERROR);
      IF V_CODE_ERROR = -1 THEN
         RAISE V_EXCEPTION;
      END IF;

    -- SE GUARDA EL INDICE EN LA TABLA TEMPORAL
    ODS.PKG_ODS_GENERICO.SP_GUARDA_INDICE('ODS','TD_MOVIMIENTOS',V_CODE_ERROR,V_MENSAJE_ERROR);
    IF V_CODE_ERROR = -1 THEN
       RAISE V_EXCEPTION;
    END IF;

    -- SE ELIMINA EL INDICE
    ODS.PKG_ODS_GENERICO.SP_ELIMINA_INDICE('ODS','TD_MOVIMIENTOS',V_CODE_ERROR,V_MENSAJE_ERROR);
    IF V_CODE_ERROR = -1 THEN
       RAISE V_EXCEPTION;
    END IF;

    INSERT /*+ APPEND*/
    INTO ODS.TD_MOVIMIENTOS NOLOGGING
     SELECT M.NU_ASIENTO,
            M.NU_TRANSACCION,
            M.ID_ORDINAL,
            M.DE_TIPO,
            M.FE_VALOR,
            M.CO_CENT_COST,
            M.CO_OFICINA,
            M.FE_PROCESO,
            M.IN_AJUS_MES,
            M.IN_ACTION,
            M.CO_DESCRIPTOR,
            M.IN_CRED_DEBI,
            SYSDATE
       FROM ODS.HD_MOVIMIENTOS M
      WHERE M.IN_ACTION NOT IN ('C','S')
        AND M.CO_DESCRIPTOR = 21
        AND M.IN_CRED_DEBI IN ('C', 'D')
        AND ((M.FE_PROCESO BETWEEN V_FE_CARGA_INICIO AND V_FE_CARGA_FIN AND M.IN_AJUS_MES IS NULL)
             OR (M.FE_VALOR BETWEEN V_NU_CARGA_INICIO AND V_NU_CARGA_FIN AND M.IN_AJUS_MES = 'A'));

    V_CIFRA_CONTROL := SQL%ROWCOUNT;
    COMMIT;

    ODS.PKG_ODS_GENERICO.SP_ELIMINA_PAPELERA;

    ODS.PKG_ODS_GENERICO.SP_CREA_INDICE('ODS','TD_MOVIMIENTOS',V_CODE_ERROR,V_MENSAJE_ERROR);
    IF V_CODE_ERROR = -1 THEN
      RAISE V_EXCEPTION;
    END IF;

    DBMS_STATS.GATHER_TABLE_STATS('ODS','TD_MOVIMIENTOS',ESTIMATE_PERCENT=>5,METHOD_OPT=>NULL,DEGREE=>2,CASCADE=>TRUE);

    DWHADM.PKG_CONTROL_ETL.SP_CAMBIA_ESTADO_ETL(V_ETL_TIPO_ETL      => 190,
                                                V_ETL_NUM_EJECUCION => V_EJECUCION,
                                                V_ETL_NUM_PROCESO   => V_NUM_PROCESO,
                                                V_ETL_CIFRA_CONTROL => V_CIFRA_CONTROL,
                                                V_ETL_ESTADO        => 'F',
                                                V_ETL_CODE          => V_CODE_ERROR,
                                                V_ETL_MENSAJE       => V_MENSAJE_ERROR);
    IF V_CODE_ERROR = -1 THEN
      RAISE V_EXCEPTION;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      V_CODE_ERROR    := -1;
      V_MENSAJE_ERROR := 'DWHADM.PKG_FIN_ODS_ASIENTOS.SP_TEMP_MOVIMIENTOS_ODS'||'-'||SQLERRM||'-'||V_MENSAJE_ERROR;

      INSERT INTO DWHADM.CONTROL_ERROR
        (CO_ETL, NU_EJECUCION,  DE_ERROR, FE_ERROR)
        SELECT 190,
               V_EJECUCION,
               SUBSTR(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, 1, 2000) ||
               SUBSTR(V_MENSAJE_ERROR, 1, 400),
               SYSDATE
          FROM DUAL;
      COMMIT;

      DWHADM.PKG_CONTROL_ETL.SP_CAMBIA_ESTADO_ETL(V_ETL_TIPO_ETL      => 180,
                                                  V_ETL_NUM_EJECUCION => V_EJECUCION,
                                                  V_ETL_NUM_PROCESO   => V_NUM_PROCESO,
                                                  V_ETL_CIFRA_CONTROL => V_CIFRA_CONTROL,
                                                  V_ETL_ESTADO        => 'E',
                                                  V_ETL_CODE          => V_CODE_ERROR,
                                                  V_ETL_MENSAJE       => V_MENSAJE);

  END SP_TEMP_MOVIMIENTOS_ODS;

  ---------------------------------------------------------------------------------------------------------------------------------
  -- RESUMEN
  -- DESCRIPCIÓN       : PROCEDIMIENTO PARA CARGAR LA TABLA HISTÓRICA DE ASIENTOS AL ESQUEMA ODS
  -- FECHA DE CREACIÓN : 22/12/2014
  -- AUTOR             : GORA S.A.C
  -- TABLA DESTINO     : ODS.HD_ASIENTOS
  -- TABLAS FUENTES    : STG.T_MOVIMIENTOS_CONTABLES
  --                     STG.T_ASIENTOS
  --                     STG.T_MOVIMIENTOS
  --                     STG.T_TEMP_ASIENTO
  --                     STG.T_REFERENCIA_ASIENTOS
  -- PARAMETROS        : V_FE_INICIO : FECHA INICIO DE CARGA
  --                     V_FE_FIN : FECHA FIN DE CARGA
  --                     V_CODE_ERROR : PUEDE TOMAR VALORES COMO 1(CORRECTO) O -1(INCORRECTO)
  --                     V_MENSAJE_ERROR : MENSAJE DE ERROR
  -- OBSERVACION       : NO APLICA
/*===================================================================================================================================
REQUERIMIENTO		RESPONSABLE		FECHA		DESCRIPCION 		
===================================================================================================================================
CASO-21312		CHRISTIAN RUIZ	   13/05/2020	ADICION DE CAMPOS A LA TABLA DESTINO
===================================================================================================================================*/

  PROCEDURE SP_ASIENTOS_ODS(V_FE_INICIO  IN VARCHAR2,
                             V_FE_FIN     IN VARCHAR2,
                             V_CODE_ERROR    OUT NUMBER,
                             V_MENSAJE_ERROR OUT VARCHAR2) IS

    V_EJECUCION NUMBER;
    V_EXCEPTION EXCEPTION;
    V_CIFRA_CONTROL NUMBER;
    V_FE_CARGA_INICIO   DATE;
    V_FE_CARGA_FIN      DATE;

  BEGIN

    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT = ''DD/MM/YYYY''';

    SELECT NVL(MAX(A.NU_EJECUCION), 1)
      INTO V_EJECUCION
      FROM DWHADM.CONTROL_ETL_CABECERA A
     WHERE A.CO_ETL = 190;

    V_NUM_PROCESO := 30;
    V_CODE_ERROR := 1;
    V_CIFRA_CONTROL := 0;
    DWHADM.PKG_CONTROL_ETL.SP_CAMBIA_ESTADO_ETL(V_ETL_TIPO_ETL      => 190,
                                                V_ETL_NUM_EJECUCION => V_EJECUCION,
                                                V_ETL_NUM_PROCESO   => V_NUM_PROCESO,
                                                V_ETL_CIFRA_CONTROL => V_CIFRA_CONTROL,
                                                V_ETL_ESTADO        => 'I',
                                                V_ETL_CODE          => V_CODE_ERROR,
                                                V_ETL_MENSAJE       => V_MENSAJE_ERROR);
    IF V_CODE_ERROR = -1 THEN
      RAISE V_EXCEPTION;
    END IF;

    IF (V_FE_INICIO IS NULL AND V_FE_FIN IS NULL)THEN
      V_FE_CARGA_INICIO:=ADD_MONTHS(TO_DATE(TO_CHAR(SYSDATE,'YYYYMM'),'YYYYMM'),-1);
      V_FE_CARGA_FIN   :=TRUNC(SYSDATE);

    ELSE

      V_FE_CARGA_INICIO:=TO_DATE(V_FE_INICIO,'DD/MM/YYYY');
      V_FE_CARGA_FIN   :=TO_DATE(V_FE_FIN,'DD/MM/YYYY');

    END IF;

    ODS.PKG_ODS_GENERICO.SP_TRUNCATE_TABLE('ODS','TD_ASIENTOS',V_CODE_ERROR, V_MENSAJE_ERROR);
    IF V_CODE_ERROR = -1 THEN
      RAISE V_EXCEPTION;
    END IF;

    ODS.PKG_ODS_GENERICO.SP_GEN_PARTICIONES ('ODS',
                                             'HD_ASIENTOS',
                                             'FE_CONTABLE',
                                             'DATE',
                                             'DIARIA',
                                             'P_ASIENTOS_',
                                             20000,
                                             'ODS_DATA_01',
                                             V_CODE_ERROR,
                                             V_MENSAJE_ERROR);
    IF V_CODE_ERROR = -1 THEN
      RAISE V_EXCEPTION;
    END IF;

    ODS.PKG_ODS_GENERICO.SP_TRUNC_PARTITION_PERIODO(V_FE_CARGA_INICIO,V_FE_CARGA_FIN,'ODS','HD_ASIENTOS',
                                                      'P_ASIENTOS_','DIARIA', V_CODE_ERROR,V_MENSAJE_ERROR);
    IF V_CODE_ERROR = -1 THEN
       RAISE V_EXCEPTION;
    END IF;

    INSERT /*+ APPEND*/
    INTO ODS.TD_ASIENTOS NOLOGGING(FE_PROCESO,FE_CONTABLE,CO_MONEDA,CO_OPERACION,CO_OFIC_ORIG,CO_OFICINA,ID_CUEN_CONT,CO_TIPO_CUEN,CO_CENT_COST,CO_PRODUCTO,CO_CLIENTE,CO_RUBR_OPER,
                         CO_USUA_TOPA,NU_ASIENTO,NO_ASIENTO,DE_ASIENTO,DE_REFE_ASIE,VL_TEMP_1,VL_TEMP_2,VL_TEMP_3,VL_TEMP_4,ID_CUO,ID_LINEA_CUO,NU_TRVIRTUAL,
						 NU_TRREAL, NU_ORDINAL, NU_TRTIPO, TI_MOVI_CONTA, NU_CUENTA, IN_SIGNO, FE_VALOR, MO_IMPORTE, MO_IMPO_MN, IN_AJUSTE) --@CASO-21312 13/05/2020   se agrega los campos necesarios para la generacion de las broad contables
     SELECT /*+ PARALLEL(A,4) */
            M.FECHAPROCESO FE_PROCESO,
            (CASE WHEN TRIM(M.AJUSTEFM) IS NULL THEN M.FECHAPROCESO
                  WHEN TRIM(M.AJUSTEFM) = 'A' THEN M.V0025 END) FE_CONTABLE,
            M.V0003 CO_MONEDA,
            M.OPERACION CO_OPERACION,
            M.SUCURSAL CO_OFIC_ORIG,
            M.V0001 CO_OFICINA,
            M.V6326 ID_CUEN_CONT,
            TO_NUMBER(SUBSTR(M.V6326,1,1)) TI_CUENTA,
            NVL(V.CO_CENT_COST,0) CO_CENT_COST,
            M.V0007 ID_PRODUCTO,
            M.V0002 CO_CLIENTE,
            M.V0004 CO_RUBR_OPER,
            M.V9505 CO_USUA_TOPA,
            A.ASIENTO NU_ASIENTO,
            DECODE(A.DESCRIPCION,'.',NULL,A.DESCRIPCION) NO_ASIENTO,
            DECODE(M.V0028,'.',NULL,M.V0028) DE_ASIENTO,
            (M.FECHAPROCESO || '-' || M.SUCURSAL || '-' || M.ASIENTO || '-' || M.TRREAL || '-' || M.ORDINAL || '-' || M.TIPO) DE_REFE_ASIE,
            DECODE(M.V0024, 'D', 1, 0) VL_TEMP_1,
            TRUNC(M.V0200, 2) VL_TEMP_2,
            DECODE(M.V0024, 'C', 1, 0) VL_TEMP_3,
            TRUNC(M.V0030, 2) VL_TEMP_4,
            (TO_CHAR(M.FECHAPROCESO,'DDMMYYYY')||
            LPAD(M.SUCURSAL, 3, '0')||
            LPAD(A.INIUSR, 8, '0')  ||
            LPAD(TO_CHAR(A.ASIENTO), 10, '0')) ID_CUO,
            ('M'||LPAD(TO_CHAR(M.TRREAL),5,'0')||LPAD(TO_CHAR(M.ORDINAL),4,'0')) ID_LINEA_CUO,
            M.TRVIRTUAL,
			--@CASO-21312 INI : 13/05/2020   se agrega los campos necesarios para la generacion de las broad contables
			M.TRREAL,
			M.ORDINAL,
			M.TRTIPO,
			M.TIPO,
			M.V0005,
			M.V0024,
			M.V0025,
			M.V0200,
			M.V0030,
			M.AJUSTEFM
			--@CASO-21312 FIN : 13/05/2020   se agrega los campos necesarios para la generacion de las broad contables
       FROM STG.T_ASIENTOS A
      INNER JOIN STG.T_MOVIMIENTOS_CONTABLES M
         ON M.FECHAPROCESO = A.FECHAPROCESO
        AND M.SUCURSAL = A.SUCURSAL
        AND M.ASIENTO = A.ASIENTO
       LEFT JOIN ODS.TD_MOVIMIENTOS V
         ON M.FECHAPROCESO=V.FE_PROCESO
        AND M.SUCURSAL=V.CO_OFICINA
        AND M.ASIENTO=V.NU_ASIENTO
        AND M.TRREAL=V.NU_TRANSACCION
        AND M.ORDINAL=V.ID_ORDINAL
        AND M.TIPO=V.DE_TIPO
        AND V.IN_ACTION NOT IN ('C','S')
        AND V.CO_DESCRIPTOR = 21
        AND V.IN_CRED_DEBI IN ('C', 'D')
      WHERE A.TZ_LOCK = 0
        AND A.ESTADO = 77
        AND ((M.FECHAPROCESO BETWEEN V_FE_CARGA_INICIO AND V_FE_CARGA_FIN AND TRIM(M.AJUSTEFM) IS NULL)
            OR (M.V0025 BETWEEN V_FE_CARGA_INICIO AND V_FE_CARGA_FIN AND TRIM(M.AJUSTEFM) = 'A'));

    COMMIT;

    INSERT /*+ APPEND*/
    INTO ODS.HD_ASIENTOS NOLOGGING (FE_PROCESO,FE_CONTABLE,NU_PERI_MES,CO_MONEDA,CO_OPERACION,CO_OFIC_ORIG,CO_OFICINA,ID_CUEN_CONT,CO_TIPO_CUEN,CO_CENT_COST,CO_CONC_GAST,CO_PROYECTO,
                         CO_PRODUCTO,CO_CLIENTE,CO_RUBR_OPER,CO_USUA_TOPA,MO_DEBI_INGR,MO_CRED_INGR,MO_SALD_INGR,MO_DEBI_FUNC,MO_CRED_FUNC,MO_SALD_FUNC,NU_ASIENTO,NO_ASIENTO,
                         DE_ASIENTO,DE_REFE_ASIE,CO_SIST_ORIG,DE_GLOSA,DE_REFE_PROV,NU_REFE_FACT,NU_TRAN_INVE,CO_REFE_ARTI,DE_REFE_ARTI,FE_ACTU_DIA,NU_TRVIRTUAL,
						 NU_TRREAL, NU_ORDINAL, NU_TRTIPO, TI_MOVI_CONTA, NU_CUENTA, IN_SIGNO, FE_VALOR, MO_IMPORTE, MO_IMPO_MN, IN_AJUSTE) --@CASO-21312: 13/05/2020   se agrega los campos necesarios para la generacion de las broad contables
       SELECT /*+ PARALLEL(A,4) */
              A.FE_PROCESO,
              A.FE_CONTABLE,
              TO_CHAR(A.FE_CONTABLE,'YYYYMM') NU_PERI_MES,
              A.CO_MONEDA,
              A.CO_OPERACION,
              A.CO_OFIC_ORIG,
              A.CO_OFICINA,
              A.ID_CUEN_CONT,
              A.CO_TIPO_CUEN,
              A.CO_CENT_COST,
              NVL((CASE WHEN T.SISTEMA='EBS' THEN T.GASTO
                        ELSE 0 END),0) CO_CONC_GAST,
              NVL((CASE WHEN T.SISTEMA='EBS' THEN T.PROYECTO
                        ELSE 0 END),0) CO_PROYECTO,
              A.CO_PRODUCTO,
              A.CO_CLIENTE,
              A.CO_RUBR_OPER,
              NVL(A.CO_USUA_TOPA,'.'),
              A.VL_TEMP_1 * A.VL_TEMP_2 MO_DEBI_INGR,
              A.VL_TEMP_3 * A.VL_TEMP_2 MO_CRED_INGR,
             (A.VL_TEMP_1 * A.VL_TEMP_2) - (A.VL_TEMP_3 * A.VL_TEMP_2) MO_SALD_INGR,
              A.VL_TEMP_1 * A.VL_TEMP_4 MO_DEBI_FUNC,
              A.VL_TEMP_3 * A.VL_TEMP_4 MO_CRED_FUNC,
             (A.VL_TEMP_1 * A.VL_TEMP_4) - (A.VL_TEMP_3 * A.VL_TEMP_4) MO_SALD_FUNC,
              A.NU_ASIENTO,
              NVL(TRIM(A.NO_ASIENTO),NVL(O.DESCRIPCION, O.NOMBRE)) NO_ASIENTO,
              NVL(TRIM((CASE WHEN T.SISTEMA='EBS' THEN T.DETALLE
                        ELSE A.DE_ASIENTO END)),
                          NVL(O.DESCRIPCION, O.NOMBRE)) DE_ASIENTO,
              NVL(A.DE_REFE_ASIE,'.'),
              (CASE WHEN T.SISTEMA='EBS' THEN 2
                    WHEN T.SISTEMA='TRADERLIVE' THEN 3
                    ELSE 1 END) CO_SIST_ORIG,
              NVL((CASE WHEN T.SISTEMA='EBS' THEN T.GLOSA
                   END),NVL(O.DESCRIPCION, O.NOMBRE)) DE_GLOSA,
              NVL((CASE WHEN T.SISTEMA='EBS' THEN R.REF_PROVEEDOR
                   ELSE '.' END),'.') DE_REFE_PROV,
              NVL((CASE WHEN T.SISTEMA='EBS' THEN R.REF_NRO_FC
                   ELSE '.' END),'.') NU_REFE_FACT,
              NVL((CASE WHEN T.SISTEMA='EBS' THEN R.REF_INV_TRX_ID
                   ELSE '.' END),'.') NU_TRAN_INVE,
              NVL((CASE WHEN T.SISTEMA='EBS' THEN R.REF_COD_ITEM
                   ELSE '.' END),'.') CO_REFE_ARTI,
              NVL((CASE WHEN T.SISTEMA='EBS' THEN R.REF_DESC_ITEM
                   ELSE '.' END),'.') DE_REFE_ARTI,
              SYSDATE,
              A.NU_TRVIRTUAL,
			  --@CASO-21312 INI : 13/05/2020   se agrega los campos necesarios para la generacion de las broad contables
			  A.NU_TRREAL,
			  A.NU_ORDINAL,
			  A.NU_TRTIPO,
			  A.TI_MOVI_CONTA,
			  A.NU_CUENTA,
			  A.IN_SIGNO,
			  A.FE_VALOR,
			  A.MO_IMPORTE,
			  A.MO_IMPO_MN,
			  A.IN_AJUSTE
			  --@CASO-21312 FIN : 13/05/2020   se agrega los campos necesarios para la generacion de las broad contables
         FROM ODS.TD_ASIENTOS A
         LEFT JOIN STG.T_TEMP_ASIENTO T        ON A.ID_CUO=T.IDCUO        AND A.ID_LINEA_CUO=T.IDLINEACUO AND T.SISTEMA = 'EBS'
         LEFT JOIN STG.T_REFERENCIA_ASIENTOS R ON T.IDASIENTO=R.IDASIENTO AND T.IDLINEAASIENTO=R.IDLINEAASIENTO
		 LEFT JOIN STG.T_OPERACIONES O         ON O.IDENTIFICACION=A.CO_OPERACION;

    V_CIFRA_CONTROL := SQL%ROWCOUNT;

    COMMIT;

    ODS.PKG_ODS_GENERICO.SP_ESTADISTICAS_PARTITION (V_FE_CARGA_INICIO,
                                                    V_FE_CARGA_FIN,
                                                    'ODS',
                                                    'HD_ASIENTOS',
                                                    'DIARIA',
                                                    'P_ASIENTOS_',
                                                     V_CODE_ERROR,
                                                     V_MENSAJE_ERROR);
    IF V_CODE_ERROR = -1 THEN
      RAISE V_EXCEPTION;
    END IF;

    ODS.PKG_ODS_GENERICO.SP_ELIMINA_PAPELERA;

    DWHADM.PKG_CONTROL_ETL.SP_CAMBIA_ESTADO_ETL(V_ETL_TIPO_ETL      => 190,
                                                V_ETL_NUM_EJECUCION => V_EJECUCION,
                                                V_ETL_NUM_PROCESO   => V_NUM_PROCESO,
                                                V_ETL_CIFRA_CONTROL => V_CIFRA_CONTROL,
                                                V_ETL_ESTADO        => 'F',
                                                V_ETL_CODE          => V_CODE_ERROR,
                                                V_ETL_MENSAJE       => V_MENSAJE_ERROR);
    IF V_CODE_ERROR = -1 THEN
      RAISE V_EXCEPTION;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      V_CODE_ERROR    := -1;
      V_MENSAJE_ERROR := 'DWHADM.PKG_FIN_ODS_ASIENTOS.SP_ASIENTOS_ODS'||'-'||SQLERRM||'-'||V_MENSAJE_ERROR;

      INSERT INTO DWHADM.CONTROL_ERROR
        (CO_ETL, NU_EJECUCION,  DE_ERROR, FE_ERROR)
        SELECT 190,
               V_EJECUCION,
               SUBSTR(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, 1, 2000) ||
               SUBSTR(V_MENSAJE_ERROR, 1, 400),
               SYSDATE
          FROM DUAL;
      COMMIT;

      DWHADM.PKG_CONTROL_ETL.SP_CAMBIA_ESTADO_ETL(V_ETL_TIPO_ETL      => 180,
                                                  V_ETL_NUM_EJECUCION => V_EJECUCION,
                                                  V_ETL_NUM_PROCESO   => V_NUM_PROCESO,
                                                  V_ETL_CIFRA_CONTROL => V_CIFRA_CONTROL,
                                                  V_ETL_ESTADO        => 'E',
                                                  V_ETL_CODE          => V_CODE_ERROR,
                                                  V_ETL_MENSAJE       => V_MENSAJE);

  END SP_ASIENTOS_ODS;

END PKG_FIN_ODS_ASIENTOS;
/
