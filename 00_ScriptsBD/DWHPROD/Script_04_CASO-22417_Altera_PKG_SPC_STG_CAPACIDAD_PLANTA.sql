CREATE OR REPLACE PACKAGE BODY DWHADM.PKG_SPC_STG_CAPACIDAD_PLANTA
------------------------------------------------------------------------------------------------------------
-- RESUMEN
-- Proyecto : CAPACIDAD PLANTA
-- Nombre :  PKG_SPC_STG_CAPACIDAD_PLANTA
-- Autor : Diego Zegarra T. (GORA SAC)
-- Fecha de CreaciÃ³n : 15/07/2014
-- DescripciÃ³n : Paquete para ejecutar el esquema STG del Proyecto
------------------------------------------------------------------------------------------------------------
-- Modificaciones
-- Responsable : Paul Ramirez Zapata
-- Fecha       : 13/03/2020
-- DescripciÃ³n : Se agregan los campos adicionales que serÃ¡n utilizados
--               en la tabla HD_DESEMBOLSO utilizada en el DM Riesgos
------------------------------------------------------------------------------------------------------------
--@001 PRZ CASO-20427: Se cambia el nombre de FE_VALOR a FE_APER_CUEN en la tabla STG.T_DESEMBOLSO
--@002 PRZ CASO-20427: Se agregan 6 campos nuevos a la tabla STG.T_DESEMBOLSO
--@003 PRZ CASO-20427: Se cambia el alias del campo C.C1620 de FE_VALOR a FE_APER_CUEN
--@004 PRZ CASO-20427: Se agregan 6 campos en el select para llenar la tabla STG.T_DESEMBOLSO
--@005 PRZ CASO-20427: Se invierten campos D.C5036 y C.C1601
--@006 AHB CASO-21308: Se cambia el filtro del campo C.C1621 por el C.1620
--@007 CER CASO-22417: Se cambia el campo A.NROSOLICITUD por D.C5000 para corregir los casos con NU_SOLICITUD = 0
------------------------------------------------------------------------------------------------------------
 IS
  ------------------------------------------------------------------------------------------------------------
  -- RESUMEN
  -- DescripciÃ³n : Carga de Fuerza Laboral, Vacaciones y Organico en el esquema STG
  -- Fecha de CreaciÃ³n : 02/07/2014
  -- Autor : Diego Zegarra Torres - GORA SAC
  -- Tabla Destino : STG.T_FUERZA_LABORAL
  --                 STG.T_ORGANICO
  --                 STG.T_VACACIONES
  -- Tablas Fuentes : STG.DE_FUERZA_LABORAL
  --                  STG.DE_ORGANICO
  --                  STG.DE_VACACIONES
  -- Parametros : V_PERIODO: Perido de Proceso de la Carga
  --              V_TI_REP : Toma Valores como F:Fuerza Labora,V:Vacaciones, O:Organico o T:Total(Todos los reportes)
  --              V_CODE_ERROR: Codigo oracle de error
  --              V_MENSAJE_ERROR: Mensaje descriptivo del error
  -- ObservaciÃ³n: No aplica.
  ------------------------------------------------------------------------------------------------------------

  PROCEDURE SP_LECTURA_ARCHIVO_STG(V_PERIODO       IN NUMBER,
                                   V_TI_REP        IN VARCHAR2,
                                   V_CODE_ERROR    OUT NUMBER,
                                   V_MENSAJE_ERROR OUT VARCHAR2) IS

    V_FUERZA_LABORAL VARCHAR2(100);
    V_ORGANICO       VARCHAR2(100);
    V_VACACIONES     VARCHAR2(100);
    V_EJECUCION      NUMBER;
    V_EXCEPTION      EXCEPTION;
    V_ERROR   NUMBER;

  BEGIN

    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT = ''DD/MM/YYYY''';
    --Se captura la ultima ejecucion del ETL
    SELECT NVL(MAX(A.NU_EJECUCION), 1)
      INTO V_EJECUCION
      FROM DWHADM.CONTROL_ETL_CABECERA A
     WHERE A.CO_ETL = 100;

    V_NUM_PROCESO := 10;
    DWHADM.PKG_CONTROL_ETL.SP_CAMBIA_ESTADO_ETL(V_ETL_TIPO_ETL      => 100,
                                                V_ETL_NUM_EJECUCION => V_EJECUCION,
                                                V_ETL_NUM_PROCESO   => V_NUM_PROCESO,
                                                V_ETL_CIFRA_CONTROL => V_CIFRA_CONTROL,
                                                V_ETL_ESTADO        => 'I',
                                                V_ETL_CODE          => V_CODE_ERROR,
                                                V_ETL_MENSAJE       => V_MENSAJE_ERROR);

    -- Se procede a truncar las tablas STG
    STG.PKG_STG_GENERICO.SP_TRUNCATE_TABLE('STG', 'T_VACACIONES', V_CODE_ERROR);
    IF V_CODE_ERROR = -1 THEN
       RAISE V_EXCEPTION;
    END IF;
    STG.PKG_STG_GENERICO.SP_TRUNCATE_TABLE('STG','T_FUERZA_LABORAL',V_CODE_ERROR);
    IF V_CODE_ERROR = -1 THEN
       RAISE V_EXCEPTION;
    END IF;
    STG.PKG_STG_GENERICO.SP_TRUNCATE_TABLE('STG', 'T_ORGANICO', V_CODE_ERROR);
    IF V_CODE_ERROR = -1 THEN
       RAISE V_EXCEPTION;
    END IF;
    --

 IF V_TI_REP IN ('F','O','V','T') THEN
    -- Se Modifica la session de caracteres
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ''.,''';

    BEGIN
    -- Proceso Fuerza Laboral
    IF V_TI_REP = 'F' OR V_TI_REP = 'T' THEN
      V_FUERZA_LABORAL := 'FUERZA_LABORAL_' || V_PERIODO || '.CSV';

      EXECUTE IMMEDIATE 'ALTER TABLE STG.DE_FUERZA_LABORAL LOCATION
                      (' || '''' || V_FUERZA_LABORAL || '''' || ')';

      INSERT /*+ APPEND NOLOGGING */
      INTO STG.T_FUERZA_LABORAL
        (NU_PERI_MES,
         NU_MES,
         CO_USUARIO,
         NO_TRABAJADOR,
         DE_CARG_EMPL,
         DE_ESCUELA,
         NU_DOCUMENTO,
         DE_SEXO_EMPL,
         TI_EMPLEADO,
         ST_COND_LABO,
         NO_REGION,
         NO_GERENCIAS,
         NO_AGENCIAS,
         TI_AGENCIAS,
         NO_CENT_COST,
         NO_OFICINA,
         FE_INGRESO,
         TI_GRUPO,
         FE_ACTU_MES)
        SELECT V_PERIODO AS PERIODO,
               TRIM(DE.NU_MES) AS NU_MES,
               TRIM(DE.CO_USUARIO) AS USUARIO,
               TRIM(DE.NO_TRABAJADOR) AS TRABAJADOR,
               TRIM(DE.DE_CARG_EMPL) AS CARGO,
               TRIM(DE.DE_ESCUELA) AS ESCUELA,
               TRIM(DE.NU_DOCUMENTO) AS DNI,
               TRIM(DE.DE_SEXO_EMPL) AS SEX,
               TRIM(DE.TI_EMPLEADO) AS TIP_TRAB,
               TRIM(DE.ST_COND_LABO) AS COND_LABORAL,
               TRIM(DE.NO_REGION) AS REGION,
               TRIM(DE.NO_GERENCIAS) AS GERENCIA,
               TRIM(DE.NO_AGENCIAS) AS AGENCIA,
               TRIM(DE.TI_AGENCIAS) AS TPAGENCIA,
               TRIM(DE.NO_CENT_COST) AS C_COSTO,
               TRIM(DE.NO_OFICINA) AS NOOFICINA,
               TRIM(DE.FE_INGRESO) AS F_INGRESO,
               TRIM(DE.TI_GRUPO) AS GRUPO,
               TO_CHAR(SYSDATE, 'DD/MM/YYYY') AS FECPRO
          FROM STG.DE_FUERZA_LABORAL DE;
      V_CIFRA_CONTROL := SQL%ROWCOUNT;
      COMMIT;
      END IF;

    EXCEPTION WHEN OTHERS THEN
      V_CODE_ERROR  := -1;
      V_MENSAJE_ERROR := 'FUERZA_LABORAL'||'_'||V_PERIODO||'-'||SQLERRM;
       INSERT INTO DWHADM.CONTROL_ERROR
        (CO_ETL, NU_EJECUCION, DE_ERROR, FE_ERROR)
        SELECT 100,
               V_EJECUCION,
               SUBSTR(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, 1, 2000) ||
               SUBSTR(V_MENSAJE_ERROR, 1, 4000),
               SYSDATE
          FROM DUAL;
     COMMIT;
    END;

    IF  V_CODE_ERROR  = -1 THEN
       V_ERROR := V_CODE_ERROR;
    END IF;

   -- Proceso de Organico
   BEGIN
    IF V_TI_REP = 'O' or V_TI_REP = 'T' then

      V_ORGANICO := 'ORGANICO_' || V_PERIODO || '.CSV';
      EXECUTE IMMEDIATE 'ALTER TABLE STG.DE_ORGANICO LOCATION(' || '''' ||
                        V_ORGANICO || '''' || ')';

      INSERT /*+ APPEND NOLOGGING */
      INTO STG.T_ORGANICO
        (NU_PERI_MES,
         NO_SUPE_REGI,
         NO_SUPE_TERR,
         NO_GERE_OPER,
         NO_AGEN_MATR,
         NO_OFIC_CORT,
         NO_OFIC_COMP,
         NU_CAJA_OFIC,
         FE_ACTU_MES,
         NU_ASIS_OPER)
        SELECT V_PERIODO AS PERIODO,
               TRIM(AA.NO_SUPE_REGI) AS NO_SUPE_REGI,
               TRIM(AA.NO_SUPE_TERR) AS NO_SUPE_TERR,
               TRIM(AA.NO_GERE_OPER) AS NO_GERE_OPER,
               TRIM(AA.NO_AGEN_MATR) AS NO_AGEN_MATR,
               TRIM(AA.NO_OFIC_CORT) AS CO_OFICINA,
               TRIM(AA.NO_OFIC_COMP) AS NO_OFICINA,
               TRIM(AA.NU_CAJA_OFIC) AS NU_CAJA_OFIC,
               TO_CHAR(SYSDATE, 'DD/MM/YYYY') FEC_ACTU_MES,
               TRIM(AA.NU_ASIS_OPER) AS NU_MAX_CAJ
          FROM STG.DE_ORGANICO AA;
      V_CIFRA_CONTROL := SQL%ROWCOUNT;
      COMMIT;
    END IF;

    EXCEPTION WHEN OTHERS THEN
      V_CODE_ERROR  := -1;
      V_MENSAJE_ERROR := 'ORGANICO'||'_'||V_PERIODO||'-'||SQLERRM;

       INSERT INTO DWHADM.CONTROL_ERROR
        (CO_ETL, NU_EJECUCION, DE_ERROR, FE_ERROR)
        SELECT 100,
               V_EJECUCION,
               SUBSTR(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, 1, 2000) ||
               SUBSTR(V_MENSAJE_ERROR, 1, 4000),
               SYSDATE
          FROM DUAL;
     COMMIT;

    END;

    IF  V_CODE_ERROR  = -1 THEN
       V_ERROR := V_CODE_ERROR;
    END IF;

    -- Proceso de Vacaciones
    BEGIN
    IF V_TI_REP = 'V' OR V_TI_REP = 'T' THEN

      V_VACACIONES := 'VACACIONES_' || V_PERIODO || '.CSV';
      EXECUTE IMMEDIATE 'ALTER TABLE STG.DE_VACACIONES LOCATION(' || '''' ||
                        V_VACACIONES || '''' || ')';

      INSERT /*+ APPEND NOLOGGING */
      INTO STG.T_VACACIONES
        (NU_PERI_MES,
         NU_MES,
         CO_USUARIO,
         NO_EMPLEADO,
         DE_CARG_EMPL,
         FE_INGRESO,
         NO_GERE_EMPL,
         NO_AGEN_EMPL,
         NO_CENT_COST,
         NO_OFIC_FUNC,
         NU_ANIO,
         NU_DIAS_GOCE_VACA,
         FE_INIC_VACA,
         FE_FIN_VACA,
         FE_ACTU_MES)
        SELECT V_PERIODO AS PERIODO,
               TRIM(T.NU_MES) AS NU_MES,
               TRIM(T.CO_USUARIO) AS CO_USUARIO,
               TRIM(T.NO_EMPLEADO) AS NO_EMPLEADO,
               TRIM(T.DE_CARG_EMPL) AS DE_CARG_EMPL,
               TRIM(T.FE_INGRESO) AS FE_INGRESO,
               TRIM(T.NO_GERE_EMPL) AS NO_GERE_EMPL,
               TRIM(T.NO_AGEN_EMPL) AS NO_AGEN_EMPL,
               TRIM(T.NO_CENT_COSTO) AS NO_CENT_COSTO,
               TRIM(T.NO_OFIC_FUNC) AS NO_OFIC_FUNC,
               TRIM(T.NU_PERIODO) AS NU_PERIODO,
               TRIM(T.NU_DIAS_GOCE_VACA) AS NU_DIAS_GOCE_VACA,
               TRIM(T.FE_INIC_VACA) AS FE_INI_VACA,
               TRIM(T.FE_FIN_VACA) AS FE_FIN_VACA,
               TO_CHAR(SYSDATE, 'DD/MM/YYYY') AS FEC_ACTU
          FROM STG.DE_VACACIONES T;
      V_CIFRA_CONTROL := SQL%ROWCOUNT;
      COMMIT;
    END IF;
    EXCEPTION WHEN OTHERS THEN
      V_CODE_ERROR  := -1;
      V_MENSAJE_ERROR := 'VACACIONES'||'_'||V_PERIODO||'-'||SQLERRM;
       INSERT INTO DWHADM.CONTROL_ERROR
        (CO_ETL, NU_EJECUCION, DE_ERROR, FE_ERROR)
        SELECT 100,
               V_EJECUCION,
               SUBSTR(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, 1, 2000) ||
               SUBSTR(V_MENSAJE_ERROR, 1, 4000),
               SYSDATE
          FROM DUAL;
     COMMIT;
    END;

    IF  V_CODE_ERROR  = -1 THEN
        V_ERROR := V_CODE_ERROR;
    END IF;

    ELSE
            V_CODE_ERROR  := -1;
            V_MENSAJE_ERROR := 'NO SE A INGRESADO EL PARAMETRO CORRECTO';
            INSERT INTO DWHADM.CONTROL_ERROR
              (CO_ETL, NU_EJECUCION, DE_ERROR, FE_ERROR)
              SELECT 100,
                     V_EJECUCION,
                     SUBSTR(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, 1, 2000) ||
                     SUBSTR(V_MENSAJE_ERROR, 1, 4000),
                     SYSDATE
                FROM DUAL;
               COMMIT;
    END IF;


    IF V_ERROR = -1  THEN
        RAISE V_EXCEPTION;
    END IF ;

    -- Elimina Papelera de Stg
    STG.PKG_STG_GENERICO.SP_ELIMINA_PAPELERA;

    V_CODE_ERROR := 1;
    DWHADM.PKG_CONTROL_ETL.SP_CAMBIA_ESTADO_ETL(V_ETL_TIPO_ETL      => 100,
                                                V_ETL_NUM_EJECUCION => V_EJECUCION,
                                                V_ETL_NUM_PROCESO   => V_NUM_PROCESO,
                                                V_ETL_CIFRA_CONTROL => V_CIFRA_CONTROL,
                                                V_ETL_ESTADO        => 'F',
                                                V_ETL_CODE          => V_CODE_ERROR,
                                                V_ETL_MENSAJE       => V_MENSAJE_ERROR);

  EXCEPTION
    WHEN OTHERS THEN
       V_CODE_ERROR  := -1;
       V_MENSAJE_ERROR := 'DWHADM.PKG_SPC_STG_CAPACIDAD_PLANTA.SP_LECTURA_ARCHIVO_STG'||' - '||'ERROR EN LA CARGA DEL ARCHIVO';

       DWHADM.PKG_CONTROL_ETL.SP_CAMBIA_ESTADO_ETL(V_ETL_TIPO_ETL      => 100,
                                                    V_ETL_NUM_EJECUCION => V_EJECUCION,
                                                    V_ETL_NUM_PROCESO   => V_NUM_PROCESO,
                                                    V_ETL_CIFRA_CONTROL => V_CIFRA_CONTROL,
                                                    V_ETL_ESTADO        => 'E',
                                                    V_ETL_CODE          => V_CODE_ERROR,
                                                    V_ETL_MENSAJE       => V_MENSAJE);

       IF V_MENSAJE IS NULL THEN
           V_MENSAJE_ERROR:= V_MENSAJE_ERROR;
       END IF;

  END SP_LECTURA_ARCHIVO_STG;

  ---------------------------------------------------------------------------------------------------------------------------------
  -- RESUMEN
  -- DescripciÃ³n : Carga de presolicitud de prestamos en las oficinas edyficar en el esquema STG
  -- Fecha de CreaciÃ³n : 08/07/2014
  -- Autor : Diego Zegarra T.
  -- Tabla Destino : EDYFICAR.T_PRESOLICITUD
  -- Tablas Fuentes : EDYFICAR.AU_RELFUNCIONARIOUSR
  --                  EDYFICAR.RH_CARGOS
  --                  EDYFICAR.USUARIOS
  --                  EDYFICAR.OPERACIONES
  --                  EDYFICAR.TC_SUCURSALES
  --                  EDYFICAR.SL_PRESOLICITUDES
  --                  EDYFICAR.OPCIONES
  -- Parametros : V_FEC_INI: Fecha Inicio de Carga
  --              V_FEC_FIN: Fecha Fin de Carga
  --              V_CODE_ERROR: Puede Tomar Valores como 1(Correcto) o -1(Incorrecto)
  --              V_MENSAJE_ERROR: Mensaje de Error
  -- ObservaciÃ³n : No aplica.
  ---------------------------------------------------------------------------------------------------------------------------------

  PROCEDURE SP_PRE_SOLICITUD_STG(V_FEC_INI       IN VARCHAR,
                                 V_FEC_FIN       IN VARCHAR2,
                                 V_CODE_ERROR    OUT NUMBER,
                                 V_MENSAJE_ERROR OUT VARCHAR2) IS

    V_PERIODO   NUMBER;
    V_EJECUCION NUMBER;
    V_EXCEPTION EXCEPTION;
    V_NU_REGI NUMBER;
    V_NU_VAL NUMBER;

  BEGIN

    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT = ''DD/MM/YYYY''';
    --Se captura la ultima ejecucion del ETL
    SELECT NVL(MAX(A.NU_EJECUCION), 1)
      INTO V_EJECUCION
      FROM DWHADM.CONTROL_ETL_CABECERA A
     WHERE A.CO_ETL = 110;
    --

    V_NUM_PROCESO := 10;
    DWHADM.PKG_CONTROL_ETL.SP_CAMBIA_ESTADO_ETL(V_ETL_TIPO_ETL      => 110,
                                                V_ETL_NUM_EJECUCION => V_EJECUCION,
                                                V_ETL_NUM_PROCESO   => V_NUM_PROCESO,
                                                V_ETL_CIFRA_CONTROL => V_CIFRA_CONTROL,
                                                V_ETL_ESTADO        => 'I',
                                                V_ETL_CODE          => V_CODE_ERROR,
                                                V_ETL_MENSAJE       => V_MENSAJE_ERROR);


    -- Se limpia las tablas
    STG.PKG_STG_GENERICO.SP_TRUNCATE_TABLE('STG','T_PRESOLICITUD',V_CODE_ERROR);
    IF V_CODE_ERROR = -1 THEN
       RAISE V_EXCEPTION;
    END IF;

    V_PERIODO := TO_CHAR(TO_DATE(V_FEC_INI, 'DD/MM/YYYY'), 'YYYYMM');

    INSERT /*+ APPEND NOLOGGING */
    INTO STG.T_PRESOLICITUD
      (NU_PERI_MES,
       FE_PROCESO,
       FE_HORA_INIC,
       FE_HORA_FIN,
       NU_SOLICITUD,
       DE_ESTADO,
       CO_SUCURSAL,
       NO_SUCU_ORIG,
       NU_ASIENTO,
       NU_USUA_TOPA,
       NO_USUARIO,
       NU_OPERACION,
       NO_USUA_DESE_PLAT,
       DE_ASIENTO,
       CO_FUNC_DESE_PRES,
       DE_CARG_FUNC,
       TI_PRESOLICITUD,
       FE_ACTU_MES)
      WITH CONSULTA1 AS
       (SELECT A.ASIENTO,
               A.OPERACION,
               A.DESCRIPCION,
               SUBSTR(A.DESCRIPCION, INSTR(A.DESCRIPCION, ':') + 1) SOLICITUD,
               A.FECHAPROCESO,
               A.HORAINICIO,
               A.HORAFIN,
               A.SUCURSAL,
               A.INIUSR
          --FROM EDYFICAR.ASIENTOS@DWHPROD_TPZPROD  A
          FROM ASIENTOS  A
         WHERE A.OPERACION = 1651
           AND A.FECHAPROCESO BETWEEN TO_DATE(V_FEC_INI, 'DD/MM/YYYY') AND
               TO_DATE(V_FEC_FIN, 'DD/MM/YYYY')
           AND A.SUCURSAL = A.SUCURSAL
           AND SUBSTR(A.DESCRIPCION, 1, 16) LIKE 'Alta P%'),
      GRUPO1 AS
       (SELECT MAX(ASIENTO) ASIENTO,
               OPERACION,
               DESCRIPCION,
               SOLICITUD,
               FECHAPROCESO,
               MAX(HORAINICIO) HORAINICIO,
               MAX(HORAFIN) HORAFIN,
               SUCURSAL,
               INIUSR
          FROM CONSULTA1
         GROUP BY OPERACION,
                  DESCRIPCION,
                  SOLICITUD,
                  FECHAPROCESO,
                  SUCURSAL,
                  INIUSR)
      SELECT V_PERIODO AS NUM_PERI_MES,
             S.FECHAPROCESO,
             S.HORAINICIO,
             S.HORAFIN,
             P.NROSOLICITUD AS NUMSOLCLI,
             OP.DESCRIPCION ESTADO,
             S.SUCURSAL COD_SUCURSAL,
             T.C6020 SUCURSAL,
             ASIENTO,
             S.INIUSR USUARIOTOPAZ,
             (SELECT U.NOMBRE
                --FROM EDYFICAR.USUARIOS@DWHPROD_TPZPROD  U
                FROM USUARIOS U
               WHERE U.INICIALES = S.INIUSR) AS USUARIO,
             S.OPERACION COD_OPERACION,
             O.NOMBRE OPERACION,
             S.DESCRIPCION DESC_ASIENTO,
             CODFUNCIONARIO,
             B.DESCRIPCION CARGO,
             'Solicitud' as TIPO,
             TO_CHAR(SYSDATE, 'DD/MM/YYYY')
        --FROM EDYFICAR.SL_PRESOLICITUDES@DWHPROD_TPZPROD  P
        FROM SL_PRESOLICITUDES  P
       INNER JOIN GRUPO1 S
          ON S.SOLICITUD = P.NROSOLICITUD
        --LEFT JOIN EDYFICAR.OPCIONES@DWHPROD_TPZPROD  OP
        LEFT JOIN OPCIONES  OP
          ON OP.NUMERODECAMPO = 2423
         AND OP.IDIOMA = 'E'
         AND OP.OPCIONINTERNA = P.ESTADO
        --LEFT JOIN EDYFICAR.AU_RELFUNCIONARIOUSR@DWHPROD_TPZPROD  FU
        LEFT JOIN AU_RELFUNCIONARIOUSR  FU
          ON FU.USUARIOTOPAZ = S.INIUSR
        --LEFT JOIN EDYFICAR.RH_CARGOS@DWHPROD_TPZPROD  B
        LEFT JOIN RH_CARGOS B
          ON FU.CODCARGO = B.CODCARGO
        --LEFT JOIN EDYFICAR.OPERACIONES@DWHPROD_TPZPROD  O
        LEFT JOIN OPERACIONES  O
          ON S.OPERACION = O.IDENTIFICACION
        --LEFT JOIN EDYFICAR.TC_SUCURSALES@DWHPROD_TPZPROD  T
        LEFT JOIN TC_SUCURSALES T
          ON S.SUCURSAL = T.C6021;
          V_NU_REGI:= SQL%ROWCOUNT;
    COMMIT;

    INSERT /*+ APPEND NOLOGGING */
    INTO STG.T_PRESOLICITUD
      (NU_PERI_MES,
       FE_PROCESO,
       FE_HORA_INIC,
       FE_HORA_FIN,
       NU_SOLICITUD,
       DE_ESTADO,
       CO_SUCURSAL,
       NO_SUCU_ORIG,
       NU_ASIENTO,
       NU_USUA_TOPA,
       NO_USUARIO,
       NU_OPERACION,
       NO_USUA_DESE_PLAT,
       DE_ASIENTO,
       CO_FUNC_DESE_PRES,
       DE_CARG_FUNC,
       TI_PRESOLICITUD,
       FE_ACTU_MES)
    WITH CONSULTA2 AS
       (SELECT A.ASIENTO,
               A.OPERACION,
               A.DESCRIPCION,
               CP.C1430 CODCLIENTE,
               A.FECHAPROCESO,
               A.HORAINICIO,
               A.HORAFIN,
               A.SUCURSAL,
               A.INIUSR
         -- FROM EDYFICAR.ASIENTOS@DWHPROD_TPZPROD  A
          FROM ASIENTOS  A
         --INNER JOIN EDYFICAR.CL_CLIENTPERSONA@DWHPROD_TPZPROD  CP
         INNER JOIN CL_CLIENTPERSONA  CP
            ON CP.C1432 = SUBSTR(DESCRIPCION, 9)
           AND FECHAPROCESO BETWEEN TO_DATE(V_FEC_INI, 'DD/MM/YYYY') AND
               TO_DATE(V_FEC_FIN, 'DD/MM/YYYY')
           AND OPERACION IN (7538, 7539)
           AND SUBSTR(A.DESCRIPCION, 1, 16) LIKE 'Alta%'),
      CONSULTA3 AS
       (SELECT A.ASIENTO,
               A.OPERACION,
               A.DESCRIPCION,
               TO_NUMBER(DECODE(SUBSTR(DESCRIPCION, 12, 7),
                                '0-Perso',
                                0,
                                SUBSTR(DESCRIPCION, 12, 7))) AS CODCLIENTE,
               A.FECHAPROCESO,
               A.HORAINICIO,
               A.HORAFIN,
               A.SUCURSAL,
               A.INIUSR
          --FROM EDYFICAR.ASIENTOS@DWHPROD_TPZPROD  A
          FROM ASIENTOS  A
         WHERE A.OPERACION = 1003
           AND A.FECHAPROCESO BETWEEN TO_DATE(V_FEC_INI, 'DD/MM/YYYY') AND
               TO_DATE(V_FEC_FIN, 'DD/MM/YYYY')
           AND SUBSTR(A.DESCRIPCION, 1, 16) LIKE 'Apert.Clte%'),
      CONSULTA21 AS
       (SELECT MAX(ASIENTO) ASIENTO,
               R.OPERACION,
               R.DESCRIPCION,
               R.CODCLIENTE,
               R.FECHAPROCESO,
               MAX(HORAINICIO) HORAINICIO,
               MAX(HORAFIN) HORAFIN,
               R.SUCURSAL,
               R.INIUSR
          FROM CONSULTA2 R
         GROUP BY R.OPERACION,
                  R.DESCRIPCION,
                  R.CODCLIENTE,
                  R.FECHAPROCESO,
                  R.SUCURSAL,
                  R.INIUSR),
      CONSULTA31 AS
       (SELECT MAX(ASIENTO) ASIENTO,
               H.OPERACION,
               H.DESCRIPCION,
               H.CODCLIENTE,
               H.FECHAPROCESO,
               MAX(HORAINICIO) HORAINICIO,
               MAX(HORAFIN) HORAFIN,
               H.SUCURSAL,
               H.INIUSR
          FROM CONSULTA3 H
         GROUP BY H.OPERACION,
                  H.DESCRIPCION,
                  H.CODCLIENTE,
                  H.FECHAPROCESO,
                  H.SUCURSAL,
                  H.INIUSR),
      CONSULTATOTAL AS
       (SELECT  G.ASIENTO,
                G.OPERACION,
                G.DESCRIPCION,
                G.CODCLIENTE,
                G.FECHAPROCESO,
                G.HORAINICIO,
                G.HORAFIN,
                G.SUCURSAL,
                G.INIUSR
          FROM CONSULTA21 G
        UNION
        SELECT P.ASIENTO,
               P.OPERACION,
               P.DESCRIPCION,
               P.CODCLIENTE,
               P.FECHAPROCESO,
               P.HORAINICIO,
               P.HORAFIN,
               P.SUCURSAL,
               P.INIUSR
        FROM CONSULTA31 P)
      SELECT V_PERIODO,
             S.FECHAPROCESO,
             S.HORAINICIO,
             S.HORAFIN,
             S.CODCLIENTE,
             NULL ESTADO,
             S.SUCURSAL COD_SUCURSAL,
             T.C6020 SUCURSAL,
             S.ASIENTO,
             S.INIUSR USUARIOTOPAZ,
             (SELECT U.NOMBRE
               -- FROM EDYFICAR.USUARIOS@DWHPROD_TPZPROD  U
                FROM USUARIOS U
               WHERE U.INICIALES = S.INIUSR) AS USUARIO,
             S.OPERACION COD_OPERACION,
             O.NOMBRE OPERACION,
             S.DESCRIPCION DESC_ASIENTO,
             FU.CODFUNCIONARIO,
             B.DESCRIPCION CARGO,
             'Persona' as TIPO,
             TO_CHAR(SYSDATE, 'DD/MM/YYYY')
        FROM CONSULTATOTAL S
        --LEFT JOIN EDYFICAR.AU_RELFUNCIONARIOUSR@DWHPROD_TPZPROD  FU
        LEFT JOIN AU_RELFUNCIONARIOUSR  FU
          ON FU.USUARIOTOPAZ = S.INIUSR
        --LEFT JOIN EDYFICAR.RH_CARGOS@DWHPROD_TPZPROD  B
        LEFT JOIN RH_CARGOS  B
          ON FU.CODCARGO = B.CODCARGO
        -- LEFT JOIN EDYFICAR.OPERACIONES@DWHPROD_TPZPROD  O
         LEFT JOIN OPERACIONES O
          ON S.OPERACION = O.IDENTIFICACION
        --LEFT JOIN EDYFICAR.TC_SUCURSALES@DWHPROD_TPZPROD  T
        LEFT JOIN TC_SUCURSALES T
          ON S.SUCURSAL = T.C6021
       ORDER BY 1, 2, 4, 5;
    V_NU_VAL := SQL%ROWCOUNT;
    COMMIT;
    V_CIFRA_CONTROL:= V_NU_VAL + V_NU_REGI;

    -- Elimina Papelera de Stg
    STG.PKG_STG_GENERICO.SP_ELIMINA_PAPELERA;
    --

    V_CODE_ERROR := 1;
    DWHADM.PKG_CONTROL_ETL.SP_CAMBIA_ESTADO_ETL(V_ETL_TIPO_ETL      => 110,
                                                V_ETL_NUM_EJECUCION => V_EJECUCION,
                                                V_ETL_NUM_PROCESO   => V_NUM_PROCESO,
                                                V_ETL_CIFRA_CONTROL => V_CIFRA_CONTROL,
                                                V_ETL_ESTADO        => 'F',
                                                V_ETL_CODE          => V_CODE_ERROR,
                                                V_ETL_MENSAJE       => V_MENSAJE_ERROR);

  EXCEPTION
    WHEN OTHERS THEN

      V_CODE_ERROR    := -1;
      V_MENSAJE_ERROR := 'DWHADM.PKG_SPC_STG_CAPACIDAD_PLANTA.SP_PRE_SOLICITUD_STG'||'-'||SQLERRM||'-'||V_MENSAJE_ERROR;

      INSERT INTO DWHADM.CONTROL_ERROR
        (CO_ETL, NU_EJECUCION,  DE_ERROR, FE_ERROR)
        SELECT 110,
               V_EJECUCION,
               SUBSTR(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, 1, 2000) ||
               SUBSTR(V_MENSAJE_ERROR, 10, 400),
               SYSDATE
          FROM DUAL;
      COMMIT;

      DWHADM.PKG_CONTROL_ETL.SP_CAMBIA_ESTADO_ETL(V_ETL_TIPO_ETL      => 110,
                                                  V_ETL_NUM_EJECUCION => V_EJECUCION,
                                                  V_ETL_NUM_PROCESO   => V_NUM_PROCESO,
                                                  V_ETL_CIFRA_CONTROL => V_CIFRA_CONTROL,
                                                  V_ETL_ESTADO        => 'E',
                                                  V_ETL_CODE          => V_CODE_ERROR,
                                                  V_ETL_MENSAJE       => V_MENSAJE);
     IF V_MENSAJE IS NULL THEN
         V_MENSAJE_ERROR:= V_MENSAJE_ERROR;
     END IF;

  END SP_PRE_SOLICITUD_STG;

  ---------------------------------------------------------------------------------------------------------------------------------
  -- RESUMEN
  -- DescripciÃ³n : Carga de cobros o recaudaciones realizadas en el esquema STG
  -- Fecha de CreaciÃ³n : 08/07/2014
  -- Autor : Diego Zegarra T.
  -- Tabla Destino : EDYFICAR.T_COBRO
  -- Tablas Fuentes : STG.T_COBRO_CANAL_FINAL
  -- Parametros : V_FEC_INI: Fecha Inicio de Carga
  --              V_FEC_FIN: Fecha Fin de Carga
  --              V_CODE_ERROR: Puede Tomar Valores como 1(Correcto) o -1(Incorrecto)
  --              V_MENSAJE_ERROR: Mensaje de Error
  -- Observaciones : No aplica.
  ---------------------------------------------------------------------------------------------------------------------------------

  PROCEDURE SP_COBROS_STG(V_FEC_INI       IN VARCHAR2,
                          V_FEC_FIN       IN VARCHAR2,
                          V_CODE_ERROR    OUT NUMBER,
                          V_MENSAJE_ERROR OUT VARCHAR2) IS

    V_PERIODO   NUMBER;
    V_EJECUCION NUMBER;
    V_EXCEPTION EXCEPTION;

  BEGIN

   EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT = ''DD/MM/YYYY''';

    --Se captura la ultima ejecucion del ETL
    SELECT NVL(MAX(A.NU_EJECUCION), 1)
      INTO V_EJECUCION
      FROM DWHADM.CONTROL_ETL_CABECERA A
     WHERE A.CO_ETL = 130;
    --

  V_NUM_PROCESO := 10;
  DWHADM.PKG_CONTROL_ETL.SP_CAMBIA_ESTADO_ETL(V_ETL_TIPO_ETL      => 130,
                                                V_ETL_NUM_EJECUCION => V_EJECUCION,
                                                V_ETL_NUM_PROCESO   => V_NUM_PROCESO,
                                                V_ETL_CIFRA_CONTROL => V_CIFRA_CONTROL,
                                                V_ETL_ESTADO        => 'I',
                                                V_ETL_CODE          => V_CODE_ERROR,
                                                V_ETL_MENSAJE       => V_MENSAJE_ERROR);


    -- Invocamos el proceso de cobros
    DWHADM.PKG_COBROS.SP_CARGA_COBROS(TO_DATE(V_FEC_INI, 'DD/MM/YYYY'),
                                      TO_DATE(V_FEC_FIN, 'DD/MM/YYYY'),
                                      V_CODE_ERROR,
                                      V_MENSAJE_ERROR);
    IF V_CODE_ERROR = -1 THEN
       RAISE V_EXCEPTION;
    END IF;

    -- Se procede a truncar las tablas STG
    STG.PKG_STG_GENERICO.SP_TRUNCATE_TABLE('STG', 'T_COBRO', V_CODE_ERROR);
    --

    IF V_CODE_ERROR = -1 THEN
      RAISE V_EXCEPTION;
    END IF;

    V_PERIODO := TO_CHAR(TO_DATE(V_FEC_INI, 'DD/MM/YYYY'), 'YYYYMM');

    INSERT /*+ APPEND NOLOGGING */
    INTO STG.T_COBRO
      (NU_PERI_MES,
       FE_VALOR,
       CO_REGI_UNIC_APLI,
       NU_PRESTAMO,
       CO_CLIENTE,
       NU_ASIE_PAGO,
       CO_USUA_COBR,
       CO_FUNC_COBR,
       CO_SUCU_PAGO_CUOT,
       NO_SUCU_PAGO_CUOT,
       CO_MONEDA,
       MO_PAGO_CUOT,
       MO_ITF_MOVI,
       MO_OTRO_PAGO,
       FE_HORA_PAGO,
       FE_PAGO,
       CO_SUCU_ORIG,
       NO_SUCU_ORIG,
       NO_CANAL,
       CO_ANALISTA,
       NO_ANALISTA,
       TI_OPERACION,
       DE_OPERACION,
       NO_CARG_FUNC,
       MO_CAPI_PAGA,
       MO_INTE_PAGA,
       ST_CREDITO,
       MO_SALD_CORT,
       ST_COBRO,
       CO_SUCU_OFIC_PRES,
       NO_SUCU_OFIC_PRES,
       FE_ACTU_MES,
       NU_SOLICITUD,
       FE_PAGO_COBR)
      SELECT V_PERIODO,
             D.FECHAVALOR,
             D.SALDOS_JTS_OID,
             D.PRESTAMO,
             D.COD_CLIENTE,
             D.ASIENTO_PAGO,
             D.USUARIO_COBRO,
             D.CODFUNCIONARIO,
             D.COD_SUCURSAL_PAGO,
             D.SUCURSAL_PAGO,
             D.MONEDA,
             D.IMPORTE_PAGADO,
             D.ITF,
             D.OTROS_PAGOS,
             D.HORA_PAGO,
             D.FECHA_PAGO,
             D.COD_SUCURSAL_ORIGEN,
             D.SUCURSAL_ORIGEN,
             D.CANAL,
             D.COD_ANALISTA,
             D.ANALISTA,
             D.OPERACION,
             D.DESCRIPCION_OPERACION,
             D.CARGO,
             D.CAPITALPAGADO,
             D.INTERESPAGADO,
             D.UNIDAD,
             D.SALDOALCORTE,
             D.ESTADO,
             D.SUC_OFIC_PRESTAMO,
             D.DES_SUC_OFIC_PRESTAMO,
             TO_CHAR(SYSDATE, 'DD/MM/YYYY') AS FE_ACTU_MES,
             D.NUM_SOLICITUD,
             TO_DATE(to_char(D.FECHA_PAGO, 'DD/MM/YYYY') || ' ' ||
                     D.HORA_PAGO,
                     'DD/MM/YYYY HH24:MI:SS')
        FROM STG.T_COBRO_CANAL_FINAL D
       WHERE D.FECHAVALOR BETWEEN TO_DATE(V_FEC_INI, 'DD/MM/YYYY') AND
             TO_DATE(V_FEC_FIN, 'DD/MM/YYYY');
    V_CIFRA_CONTROL := SQL%ROWCOUNT;
    COMMIT;

    -- Elimina Papelera de Stg
    STG.PKG_STG_GENERICO.SP_ELIMINA_PAPELERA;
    --

    V_CODE_ERROR := 1;

    DWHADM.PKG_CONTROL_ETL.SP_CAMBIA_ESTADO_ETL(V_ETL_TIPO_ETL      => 130,
                                                V_ETL_NUM_EJECUCION => V_EJECUCION,
                                                V_ETL_NUM_PROCESO   => V_NUM_PROCESO,
                                                V_ETL_CIFRA_CONTROL => V_CIFRA_CONTROL,
                                                V_ETL_ESTADO        => 'F',
                                                V_ETL_CODE          => V_CODE_ERROR,
                                                V_ETL_MENSAJE       => V_MENSAJE_ERROR);

  EXCEPTION
    WHEN OTHERS THEN

      V_CODE_ERROR    := -1;
      V_MENSAJE_ERROR := 'DWHADM.PKG_SPC_STG_CAPACIDAD_PLANTA.SP_COBROS_STG'||'-'||SQLERRM||'-'||V_MENSAJE_ERROR;

      INSERT INTO DWHADM.CONTROL_ERROR
        (CO_ETL, NU_EJECUCION, DE_ERROR, FE_ERROR)
        SELECT 130,
               V_EJECUCION,
               SUBSTR(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, 1, 2000) ||
               SUBSTR(V_MENSAJE_ERROR, 10, 400),
               SYSDATE
          FROM DUAL;
      COMMIT;

      DWHADM.PKG_CONTROL_ETL.SP_CAMBIA_ESTADO_ETL(V_ETL_TIPO_ETL      => 130,
                                                  V_ETL_NUM_EJECUCION => V_EJECUCION,
                                                  V_ETL_NUM_PROCESO   => V_NUM_PROCESO,
                                                  V_ETL_CIFRA_CONTROL => V_CIFRA_CONTROL,
                                                  V_ETL_ESTADO        => 'E',
                                                  V_ETL_CODE          => V_CODE_ERROR,
                                                  V_ETL_MENSAJE       => V_MENSAJE);

     IF V_MENSAJE IS NULL THEN
         V_MENSAJE_ERROR:= V_MENSAJE_ERROR;
     END IF;

  END SP_COBROS_STG;

  ------------------------------------------------------------------------------------------------------------
  -- RESUMEN
  -- DescripciÃ³n : Carga de desembolsos de prestamos realizados en el esquema STG
  -- Fecha de CreaciÃ³n : 14/07/2014
  -- Autor : Diego Zegarra Torres - GORA SAC
  -- Tabla Destino :   STG.T_DESEMBOLSO
  -- Tablas Fuentes :  EDYFICAR.USUARIOS
  --                   EDYFICAR.CA_PAGOSPORCAJA
  --                   EDYFICAR.SL_SOLICITUDCREDITOPERSONA
  --                   EDYFICAR.RH_CARGOS
  --                   EDYFICAR.AU_RELFUNCIONARIOUSR
  --                   EDYFICAR.SALDOS
  --                   EDYFICAR.CL_CLIENTES
  --                   EDYFICAR.CR_HISTORICO_SOLICITUDES
  --                   EDYFICAR.ASIENTOS
  --                   EDYFICAR.TC_SUCURSALES
  -- Parametros :  V_FEC_INI : Fecha Inicio Carga
  --               V_FEC_FIN : Fecha Fin Carga
  --               V_CODE_ERROR : Puede Tomar Valores como 1(Correcto) o -1(Incorrecto)
  --               V_MENSAJE_ERROR : Mensaje de Error
  -- ObservaciÃ³n : No aplica.
  ------------------------------------------------------------------------------------------------------------
  PROCEDURE SP_DESEMBOLSO_STG(V_FEC_INI       IN VARCHAR2,
                              V_FEC_FIN       IN VARCHAR2,
                              V_CODE_ERROR    OUT NUMBER,
                              V_MENSAJE_ERROR OUT VARCHAR2) IS

    V_PERIODO   NUMBER;
    V_EJECUCION NUMBER;
    V_EXCEPTION EXCEPTION;
  BEGIN

   EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT = ''DD/MM/YYYY''';

    --Se captura la ultima ejecucion del ETL
    SELECT NVL(MAX(A.NU_EJECUCION), 1)
      INTO V_EJECUCION
      FROM DWHADM.CONTROL_ETL_CABECERA A
     WHERE A.CO_ETL = 120;
    --

    V_NUM_PROCESO := 10;
    DWHADM.PKG_CONTROL_ETL.SP_CAMBIA_ESTADO_ETL(V_ETL_TIPO_ETL      => 120,
                                                V_ETL_NUM_EJECUCION => V_EJECUCION,
                                                V_ETL_NUM_PROCESO   => V_NUM_PROCESO,
                                                V_ETL_CIFRA_CONTROL => V_CIFRA_CONTROL,
                                                V_ETL_ESTADO        => 'I',
                                                V_ETL_CODE          => V_CODE_ERROR,
                                                V_ETL_MENSAJE       => V_MENSAJE_ERROR);

    -- Se procede a truncar las tablas STG
    STG.PKG_STG_GENERICO.SP_TRUNCATE_TABLE('STG', 'T_DESEMBOLSO', V_CODE_ERROR);
    --
    IF V_CODE_ERROR = -1 THEN
      RAISE V_EXCEPTION;
    END IF;

    V_PERIODO := TO_CHAR(TO_DATE(V_FEC_INI, 'DD/MM/YYYY'), 'YYYYMM');

    INSERT /*+ APPEND NOLOGGING */
    INTO STG.T_DESEMBOLSO
      ( NU_PERI_MES,
        --@001 Ini: Se cambia el nombre de FE_VALOR a FE_APER_CUEN en la tabla STG.T_DESEMBOLSO
        FE_APER_CUEN,
        --@001 Fin
        NU_PRESTAMO,
        CO_CLIENTE,
        MO_APRO_DESE,
        MO_DESEMBOLSADO,
        DE_MONEDA,
        TI_DESEMBOLSO,
        MO_RECU_SALD,
        MO_DESE_CAJA,
        CO_SUCU_ORIG,
        MO_SOLICITADO,
        NU_DIA_PROG_PAGO,
        NO_CLIENTE,
        NO_VIA_DESE_PLAT,
        NO_SUCU_ORIG,
        NU_ASIE_PLAT,
        CO_USUA_DESE_PLAT,
        CO_FUNC_DESE_PLAT,
        NO_USUA_DESE_PLAT,
        CO_SUCU_DESE_PLAT,
        NO_SUCU_DESE_PLAT,
        NU_ASIE_CAJA,
        CO_USUA_DESE_CAJA,
        CO_FUNC_DESE_CAJA,
        NO_USUA_DESE_CAJA,
        CO_SUCU_DESE_CAJA,
        NO_SUCU_DESE_CAJA,
        FE_ACTU_MES,
        FE_DESE_PLAT,
        FE_DESE_CAJA,
        NU_SOLICITUD,
        NU_PARTICIPANTES,
        DE_CARG_USUA_PLAT,
        DE_CARG_USUA_CAJA,
        --@002 Ini: Se agregan 6 campos nuevos a la tabla STG.T_DESEMBOLSO
        NU_LINE_CRED,
        MO_CUOTA,
        NU_CUOTAS,
        FE_DESEMBOLSO,
        CO_REFINANCIACION,
        CO_USUA_TOPA_DESE
        --@002 Fin
        )
      SELECT V_PERIODO AS NUM_PERI_MES,
             --@003 Ini: Se cambia el alias del campo C.C1620 de FE_VALOR a FE_APER_CUEN
             C.C1620   AS FE_APER_CUEN,
             --@003 Fin
             C.CUENTA AS NU_PRESTAMO,
             C.C1803 AS CO_CLIENTE,
             --@005 Ini: Se invierten campos - D.C5036 insertaba al campo MO_DESEMBOLSADO y C.C1601 insertaba al campo MO_APRO_DESE.
			 D.C5036 MO_APRO_DESE,
             C.C1601 MO_DESEMBOLSADO,
             --@005 Fin
			 (CASE
               WHEN C.MONEDA = 1 THEN
                'SOLES'
               ELSE
                'DOLARES'
             END) DE_MONEDA,
             D.C5004 AS TI_DESEMBOLSO,
             D.DEUDA_ACTUAL AS MO_RECU_SALD,
             (SELECT IMPORTE
                --FROM EDYFICAR.CA_PAGOSPORCAJA@DWHPROD_TPZPROD  A
                FROM CA_PAGOSPORCAJA  A
               WHERE A.NUMPAGO = D.C5045
                 AND A.ASIENTOSOLICITU = D.NROOPERACION
                 AND TZ_LOCK = 0
                 AND A.REFERENCIA = D.C5000) MO_DESE_CAJA,
             C.SUCURSAL CO_SUCU_ORIG,
             D.C5023 MO_SOLICITADO,
             D.DIA_PAGO AS NU_DIA_PROG_PAGO,
             F.C1000 AS NO_CLIENTE,
             D.FORMADESEMBOLSO NO_VIA_DESE_PLAT,
             E1.C6020 AS NO_SUCU_ORIGEN,
             D.NROOPERACION AS NU_ASIE_PLAT,
             DA.INIUSR AS CO_USUA_DESE_PLAT,
             D.USUDESEMB AS CO_FUNC_DESE_PLAT,
             (SELECT U1.NOMBRE
                --FROM EDYFICAR.USUARIOS@DWHPROD_TPZPROD  U1
                FROM USUARIOS  U1
               WHERE U1.INICIALES = DA.INIUSR) NO_USUA_DESE_PLAT,
             DA.SUCURSAL CO_SUCU_DESE_PLAT,
             E2.C6020 AS NO_SUCU_DESE_PLAT,
             P.ASIENTOPAGO AS NU_ASIE_CAJA,
             P.USUARIOPAGO AS CO_USUA_DESE_CAJA,
             M2.CODFUNCIONARIO AS CO_FUNC_DESE_CAJA,
             (SELECT U2.NOMBRE
                --FROM EDYFICAR.USUARIOS@DWHPROD_TPZPROD  U2
                FROM USUARIOS  U2
               WHERE U2.INICIALES = P.USUARIOPAGO) NO_USUA_DESE_CAJA,
             P.SUCURSAL CO_SUCU_DESE_CAJA,
             E3.C6020 AS NO_SUCU_DESE_CAJA,
             TO_CHAR(SYSDATE, 'DD/MM/YYYY') AS FE_ACTU_MES,
             DA.HORAINICIO FE_DESE_PLAT,
             PA.HORAINICIO FE_DESE_CAJA,
             -- @007 Ini: Se cambia el campo A.NROSOLICITUD por D.C5000 para corregir los casos con NU_SOLICITUD = 0
             --A.NROSOLICITUD AS NU_SOLICITUD,
			 D.C5000 AS NU_SOLICITUD,
			 -- @007 Fin
             (SELECT COUNT(1)
                --FROM EDYFICAR.SL_SOLICITUDCREDITOPERSONA@DWHPROD_TPZPROD  P
                FROM SL_SOLICITUDCREDITOPERSONA  P
               WHERE P.TZ_LOCK = 0
                 AND P.C5080 = D.C5000
                 AND P.C5084 != 'T') NUMERO_PARTICIP,
             (SELECT CA.DESCRIPCION
                --FROM EDYFICAR.RH_CARGOS@DWHPROD_TPZPROD  CA
                FROM RH_CARGOS  CA
               WHERE CA.TZ_LOCK = 0
                 AND CA.CODCARGO =
                     (SELECT AU.CODCARGO
                        --FROM EDYFICAR.AU_RELFUNCIONARIOUSR@DWHPROD_TPZPROD  AU
                        FROM AU_RELFUNCIONARIOUSR  AU
                       WHERE AU.USUARIOTOPAZ = DA.INIUSR)) DECARGUSUADESEMBOLSO,
             (SELECT CA.DESCRIPCION
                --FROM EDYFICAR.RH_CARGOS@DWHPROD_TPZPROD  CA
                FROM RH_CARGOS  CA
               WHERE CA.TZ_LOCK = 0
                 AND CA.CODCARGO =
                     (SELECT AU.CODCARGO
                        --FROM EDYFICAR.AU_RELFUNCIONARIOUSR@DWHPROD_TPZPROD  AU
                        FROM AU_RELFUNCIONARIOUSR  AU
                       WHERE AU.USUARIOTOPAZ = P.USUARIOPAGO)) DECARGUSUADESEMBOLSADO
            --@004 Ini: Se agregan 6 campos en el select
            ,
			C.C1661   AS NU_LINE_CRED,
            D.C5037   AS MO_CUOTA,
            D.C5186   AS NU_CUOTAS,
            C.C1621   AS FE_DESEMBOLSO,
            C.REFINANCIACION AS CO_REFINANCIACION,
            C.USUTOPAZ AS CO_USUA_TOPA_DESE
            --@004 Fin

        --FROM EDYFICAR.SALDOS@DWHPROD_TPZPROD  C
        FROM SALDOS  C
       --INNER JOIN EDYFICAR.SL_SOLICITUDCREDITO@DWHPROD_TPZPROD  D
       INNER JOIN SL_SOLICITUDCREDITO  D
          ON D.C5000 = C.C1704
         AND C.TZ_LOCK = 0
         AND C.C9314 = 5
         AND C.OPERACION = 0
		  --@006 Ini: Se cambia el filtro del campo C.C1621 por el C.1620
		  -- AND C.C1621 BETWEEN TO_DATE(V_FEC_INI, 'DD/MM/YYYY') AND
         AND C.C1620 BETWEEN TO_DATE(V_FEC_INI, 'DD/MM/YYYY') AND
             --@006 Fin
             TO_DATE(V_FEC_FIN, 'DD/MM/YYYY')
       --INNER JOIN EDYFICAR.CL_CLIENTES@DWHPROD_TPZPROD  F
       INNER JOIN CL_CLIENTES  F
          ON F.C0902 = C.C1803
        --LEFT JOIN EDYFICAR.CA_PAGOSPORCAJA@DWHPROD_TPZPROD  P
        LEFT JOIN CA_PAGOSPORCAJA P
          ON (P.REFERENCIA = D.C5000)
         AND P.ESTADO = '2'
         AND P.TZ_LOCK = 0
        --LEFT JOIN EDYFICAR.CR_HISTORICO_SOLICITUDES@DWHPROD_TPZPROD  A
        LEFT JOIN CR_HISTORICO_SOLICITUDES A
          ON C5000 = A.NROSOLICITUD
         AND A.OPERACION IN (2586, 2587, 2588, 2590)
        --LEFT JOIN EDYFICAR.ASIENTOS@DWHPROD_TPZPROD  PA
        LEFT JOIN ASIENTOS PA
          ON P.SUCURSAL = PA.SUCURSAL
         AND P.ASIENTOPAGO = PA.ASIENTO
         AND P.FECHAPAGO = PA.FECHAPROCESO
        --LEFT JOIN EDYFICAR.ASIENTOS@DWHPROD_TPZPROD  DA
        LEFT JOIN ASIENTOS DA
          ON A.SUCURSAL = DA.SUCURSAL
         AND A.ASIENTO = DA.ASIENTO
         AND A.FECHA = DA.FECHAPROCESO
        --LEFT JOIN EDYFICAR.TC_SUCURSALES@DWHPROD_TPZPROD  E1
        LEFT JOIN TC_SUCURSALES  E1
          ON (E1.C6021 = D.C5001)
        --LEFT JOIN EDYFICAR.TC_SUCURSALES@DWHPROD_TPZPROD  E2
        LEFT JOIN TC_SUCURSALES  E2
          ON (E2.C6021 = DA.SUCURSAL)
        --LEFT JOIN EDYFICAR.TC_SUCURSALES@DWHPROD_TPZPROD  E3
        LEFT JOIN TC_SUCURSALES  E3
          ON (E3.C6021 = P.SUCURSAL)
        --LEFT JOIN EDYFICAR.AU_RELFUNCIONARIOUSR@DWHPROD_TPZPROD  M2
        LEFT JOIN AU_RELFUNCIONARIOUSR  M2
          ON (M2.USUARIOTOPAZ = P.USUARIOPAGO);
    V_CIFRA_CONTROL := SQL%ROWCOUNT;
    COMMIT;

    -- Elimina Papelera de Stg
    STG.PKG_STG_GENERICO.SP_ELIMINA_PAPELERA;
    --

    V_CODE_ERROR := 1;

    DWHADM.PKG_CONTROL_ETL.SP_CAMBIA_ESTADO_ETL(V_ETL_TIPO_ETL      => 120,
                                                V_ETL_NUM_EJECUCION => V_EJECUCION,
                                                V_ETL_NUM_PROCESO   => V_NUM_PROCESO,
                                                V_ETL_CIFRA_CONTROL => V_CIFRA_CONTROL,
                                                V_ETL_ESTADO        => 'F',
                                                V_ETL_CODE          => V_CODE_ERROR,
                                                V_ETL_MENSAJE       => V_MENSAJE_ERROR);

  EXCEPTION
    WHEN OTHERS THEN

      V_CODE_ERROR    := -1;
      V_MENSAJE_ERROR := 'DWHADM.PKG_SPC_STG_CAPACIDAD_PLANTA.SP_DESEMBOLSO_STG'||'-'||SQLERRM||'-'||V_MENSAJE_ERROR;

       INSERT INTO DWHADM.CONTROL_ERROR
        (CO_ETL, NU_EJECUCION,  DE_ERROR, FE_ERROR)
        SELECT 120,
               V_EJECUCION,
               SUBSTR(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, 1, 2000) ||
               SUBSTR(V_MENSAJE_ERROR, 10, 400),
               SYSDATE
          FROM DUAL;
      COMMIT;

      DWHADM.PKG_CONTROL_ETL.SP_CAMBIA_ESTADO_ETL(V_ETL_TIPO_ETL      => 120,
                                                  V_ETL_NUM_EJECUCION => V_EJECUCION,
                                                  V_ETL_NUM_PROCESO   => V_NUM_PROCESO,
                                                  V_ETL_CIFRA_CONTROL => V_CIFRA_CONTROL,
                                                  V_ETL_ESTADO        => 'E',
                                                  V_ETL_CODE          => V_CODE_ERROR,
                                                  V_ETL_MENSAJE       => V_MENSAJE);

     IF V_MENSAJE IS NULL THEN
         V_MENSAJE_ERROR:= V_MENSAJE_ERROR;
     END IF;

  END SP_DESEMBOLSO_STG;

END PKG_SPC_STG_CAPACIDAD_PLANTA;
/