CREATE OR REPLACE PACKAGE BODY DWHADM.PKG_SPC_BDS_CAPACIDAD_PLANTA
------------------------------------------------------------------------------------------------------------
-- RESUMEN
-- Proyecto : CAPACIDAD PLANTA
-- Nombre :  PKG_SPC_BDS_CAPACIDAD_PLANTA
-- Autor : Diego Zegarra T. (GORA SAC)
-- Fecha de Creación : 15/07/2014
-- Descripción : Paquete para ejecutar el esquema BDS del Proyecto
------------------------------------------------------------------------------------------------------------
-- Modificaciones
-- Responsable : Paul Ramirez Zapata
-- Fecha       : 14/05/2020
-- Descripción : Se renombra el campo FE_VALOR por FE_APER_CUEN en el select de la tabla ODS.HD_DESEMBOLSO
--               para la inserción de la tabla BDS.F_SPC_DESEMBOLSO
------------------------------------------------------------------------------------------------------------
--@001 PRZ CASO-20427: Se cambia el nombre del campo FE_VALOR a FE_APER_CUEN en el select de la tabla ODS.HD_DESEMBOLSO
--@002 PRZ CASO-20427: Se cambia el nombre del campo FE_VALOR a FE_APER_CUEN en el select de la tabla ODS.HD_DESEMBOLSO
--@003 PRZ CASO-20427: Se cambia el nombre del campo FE_VALOR a FE_APER_CUEN en la condición
------------------------------------------------------------------------------------------------------------
 IS
  -------------------------------------------------------------------------------------------------------------
  -- RESUMEN
  -- Descripción : Carga de Fuerza Laboral, Vacaciones y Organico en el esquema BDS
  -- Fecha de Creación : 02/07/2014
  -- Autor : Diego Zegarra Torres - GORA SAC
  -- Tabla Destino : BDS.F_SPC_FUERZA_LABORAL
  --                 BDS.F_SPC_ORGANICO
  --                 BDS.F_SPC_VACACIONES
  -- Tablas Fuentes : ODS.HM_FUERZA_LABORAL
  --                  ODS.HM_ORGANICO
  --                  ODS.HM_VACACIONES
  -- Parametros : V_PERIODO: Periodo de Proceso de la Carga
  --              V_TI_REP : Toma Valores como F:Fuerza Labora,V:Vacaciones, O:Organico o T:Total(Todos los reportes)
  --              V_CODE_ERROR: Codigo oracle de error
  --              V_MENSAJE_ERROR: Mensaje descriptivo del error
  -- Observación: No aplica.
  ------------------------------------------------------------------------------------------------------------

  PROCEDURE SP_LECTURA_ARCHIVO_BDS(V_PERIODO       IN NUMBER,
                                   V_TI_REP        VARCHAR2,
                                   V_CODE_ERROR    OUT VARCHAR2,
                                   V_MENSAJE_ERROR OUT VARCHAR2) IS
    V_CANT      NUMBER;
    V_EJECUCION NUMBER;
    V_EXCEPTION EXCEPTION;
    V_ERROR NUMBER;

  BEGIN

    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT = ''DD/MM/YYYY''';

    SELECT NVL(MAX(A.NU_EJECUCION),1)
      INTO V_EJECUCION
      FROM DWHADM.CONTROL_ETL_CABECERA A
     WHERE A.CO_ETL = 100;

    V_NUM_PROCESO := 30;
    DWHADM.PKG_CONTROL_ETL.SP_CAMBIA_ESTADO_ETL(V_ETL_TIPO_ETL       => 100,
                                                V_ETL_NUM_EJECUCION  => V_EJECUCION,
                                                V_ETL_NUM_PROCESO    => V_NUM_PROCESO,
                                                V_ETL_CIFRA_CONTROL => V_CIFRA_CONTROL,
                                                V_ETL_ESTADO         => 'I',
                                                V_ETL_CODE           => V_CODE_ERROR,
                                                V_ETL_MENSAJE        => V_MENSAJE_ERROR);

    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ''.,''';

  IF V_TI_REP IN ('F','O','V','T') THEN
    -- Proceso fuerza laboral
    BEGIN
    IF V_TI_REP = 'F' or V_TI_REP = 'T' then
      --Particionamiento automatico
      BDS.PKG_BDS_GENERICO.SP_PARTICIONA_AUTOMATICO(TO_DATE(V_PERIODO,
                                                            'YYYYMM'),
                                                    'F_SPC_FUERZA_LABORAL',
                                                    'BDS',
                                                    'P_FUERZA_LABORAL',
                                                    V_CODE_ERROR);

      IF V_CODE_ERROR = -1 THEN
         RAISE V_EXCEPTION;
      END IF;

      -- Si vuelve a ejecutar el mismo mes este periodo se borrara y se volvera a ingresar la actualizacion
      SELECT COUNT(A.NU_PERI_MES)
        INTO V_CANT
        FROM BDS.F_SPC_FUERZA_LABORAL A
       WHERE A.NU_PERI_MES = V_PERIODO
         AND ROWNUM = 1;

      IF V_CANT > 0 THEN
        BDS.PKG_BDS_GENERICO.SP_TRUNCATE_PARTITION('BDS',
                                                   'F_SPC_FUERZA_LABORAL',
                                                   ' P_FUERZA_LABORAL_' ||
                                                   V_PERIODO,
                                                   V_CODE_ERROR);
       IF V_CODE_ERROR = -1 THEN
         RAISE V_EXCEPTION;
       END IF;

      -- Regeneracion de Indices
      BDS.PKG_BDS_GENERICO.SP_REGENERA_INDICE('BDS','F_SPC_FUERZA_LABORAL',V_CODE_ERROR);
      IF V_CODE_ERROR = -1 THEN
         RAISE V_EXCEPTION;
      END IF;

      END IF;
     IF V_CODE_ERROR <> -1 THEN
      INSERT INTO BDS.F_SPC_FUERZA_LABORAL
        (NU_PERI_MES,
         FE_ULTI_DIA_MES,
         NU_MES,
         CO_USUARIO,
         NO_TRABAJADOR,
         DE_CARG_EMPL,
         DE_ESCUELA,
         NU_DOCUMENTO,
         TI_SEXO_EMPL,
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
        SELECT V_PERIODO,
               BDS.FE_ULTI_DIA_MES,
               BDS.NU_MES,
               BDS.CO_USUARIO,
               BDS.NO_TRABAJADOR,
               BDS.DE_CARG_EMPL,
               BDS.DE_ESCUELA,
               BDS.NU_DOCUMENTO,
               BDS.DE_SEXO_EMPL,
               BDS.TI_EMPLEADO,
               BDS.ST_COND_LABO,
               BDS.DE_REGION,
               BDS.NO_GERENCIAS,
               BDS.NO_AGENCIAS,
               BDS.TI_AGENCIAS,
               BDS.NO_CENT_COST,
               BDS.NO_OFICINA,
               BDS.FE_INGRESO,
               BDS.TI_GRUPO,
               BDS.FE_ACTU_MES
          FROM ODS.HM_FUERZA_LABORAL BDS
           WHERE BDS.NU_PERI_MES = V_PERIODO;
          V_CIFRA_CONTROL := SQL%ROWCOUNT;
      COMMIT;
      ELSE
      V_CODE_ERROR    := -1;
      V_MENSAJE_ERROR := 'EL INDICE NO A SIDO REPARADO';
      IF V_CODE_ERROR = -1 THEN
             RAISE V_EXCEPTION;
      END IF;
     END IF;
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

    -- Proceso organico
    BEGIN

    IF V_TI_REP = 'O' or V_TI_REP = 'T' then
      -- Particionamiento automatico organico
      BDS.PKG_BDS_GENERICO.SP_PARTICIONA_AUTOMATICO(TO_DATE(V_PERIODO,
                                                            'YYYYMM'),
                                                    'F_SPC_ORGANICO',
                                                    'BDS',
                                                    'P_ORGANICO',
                                                    V_CODE_ERROR);
     IF V_CODE_ERROR = -1 THEN
         RAISE V_EXCEPTION;
     END IF;

      SELECT COUNT(A.NU_PERI_MES)
        INTO V_CANT
        FROM BDS.F_SPC_ORGANICO A
       WHERE A.NU_PERI_MES = V_PERIODO
         AND ROWNUM = 1;

      IF V_CANT > 0 THEN
        BDS.PKG_BDS_GENERICO.SP_TRUNCATE_PARTITION('BDS',
                                                   'F_SPC_ORGANICO',
                                                   'P_ORGANICO_' ||
                                                   V_PERIODO,
                                                   V_CODE_ERROR);
      IF V_CODE_ERROR = -1 THEN
         RAISE V_EXCEPTION;
      END IF;

       -- Regeneracion de Indices
      BDS.PKG_BDS_GENERICO.SP_REGENERA_INDICE('BDS','F_SPC_ORGANICO',V_CODE_ERROR);
      IF V_CODE_ERROR = -1 THEN
         RAISE V_EXCEPTION;
      END IF;

      END IF;

     IF V_CODE_ERROR <> -1 THEN
      INSERT INTO BDS.F_SPC_ORGANICO
        (NU_PERI_MES,
         FE_ULTI_DIA_MES,
         NO_SUPE_REGI,
         NO_SUPE_TERR,
         NO_GERE_OPER,
         NO_AGEN_MATR,
         NO_OFIC_CORT,
         NO_OFIC_COMP,
         NU_CAJA_OFIC,
         FE_ACTU_MES,
         NU_ASIS_OPER)

        SELECT V_PERIODO,
               TRUNC(LAST_DAY(TO_CHAR(TO_DATE(V_PERIODO, 'YYYYMM'),
                                      'DD/MM/YYYY'))),
               AD.NO_SUPE_REGI,
               AD.NO_SUPE_TERR,
               AD.NO_GERE_OPER,
               AD.NO_AGEN_MATR,
               AD.NO_OFIC_CORT,
               AD.NO_OFIC_COMP,
               AD.NU_CAJA_OFIC,
               AD.FE_ACTU_MES,
               AD.NU_ASIS_OPER
          FROM ODS.HM_ORGANICO AD
          WHERE AD.NU_PERI_MES = V_PERIODO;
          V_CIFRA_CONTROL := SQL%ROWCOUNT;
      COMMIT;
        ELSE
          V_CODE_ERROR    := -1;
          V_MENSAJE_ERROR := 'EL INDICE NO A SIDO REPARADO';
          IF V_CODE_ERROR = -1 THEN
             RAISE V_EXCEPTION;
          END IF;
      END IF;
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
      -- Particionamiento automatico
      BDS.PKG_BDS_GENERICO.SP_PARTICIONA_AUTOMATICO(TO_DATE(V_PERIODO,
                                                            'YYYYMM'),
                                                    'F_SPC_VACACIONES',
                                                    'BDS',
                                                    'P_VACACIONES',
                                                    V_CODE_ERROR);
       IF V_CODE_ERROR = -1 THEN
         RAISE V_EXCEPTION;
       END IF;

      SELECT COUNT(A.NU_PERI_MES)
        INTO V_CANT
        FROM BDS.F_SPC_VACACIONES A
       WHERE A.NU_PERI_MES = V_PERIODO
         AND ROWNUM = 1;

      IF V_CANT > 0 THEN
        BDS.PKG_BDS_GENERICO.SP_TRUNCATE_PARTITION('BDS',
                                                   'F_SPC_VACACIONES',
                                                   'P_VACACIONES_' ||
                                                   V_PERIODO,
                                                   V_CODE_ERROR);
        IF V_CODE_ERROR = -1 THEN
             RAISE V_EXCEPTION;
         END IF;

      -- Regeneracion de Indices
      BDS.PKG_BDS_GENERICO.SP_REGENERA_INDICE('BDS','F_SPC_VACACIONES',V_CODE_ERROR);
      IF V_CODE_ERROR = -1 THEN
         RAISE V_EXCEPTION;
      END IF;

      END IF;

     IF V_CODE_ERROR <> -1 THEN
      INSERT INTO BDS.F_SPC_VACACIONES
        (NU_PERI_MES,
         FE_ULTI_DIA_MES,
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
        SELECT V_PERIODO,
               OD.FE_ULTI_DIA_MES,
               OD.NU_MES,
               OD.CO_USUARIO,
               OD.NO_EMPLEADO,
               OD.DE_CARG_EMPL,
               OD.FE_INGRESO,
               OD.NO_GERE_EMPL,
               OD.NO_AGEN_EMPL,
               OD.NO_CENT_COST,
               OD.NO_OFIC_FUNC,
               OD.NU_ANIO,
               OD.NU_DIAS_GOCE_VACA,
               OD.FE_INIC_VACA,
               OD.FE_FIN_VACA,
               OD.FE_ACTU_MES
          FROM ODS.HM_VACACIONES OD
          WHERE OD.NU_PERI_MES = V_PERIODO;
      V_CIFRA_CONTROL := SQL%ROWCOUNT;
      COMMIT;
       ELSE
           V_CODE_ERROR    := -1;
           V_MENSAJE_ERROR := 'EL INDICE NO A SIDO REPARADO';
           IF V_CODE_ERROR = -1 THEN
             RAISE V_EXCEPTION;
           END IF;
      END IF;
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

    -- Elimina Papelera de BDS
    BDS.PKG_BDS_GENERICO.SP_ELIMINA_PAPELERA;
    --

    V_CODE_ERROR := 1;

    DWHADM.PKG_CONTROL_ETL.SP_CAMBIA_ESTADO_ETL(V_ETL_TIPO_ETL       => 100,
                                                V_ETL_NUM_EJECUCION  => V_EJECUCION,
                                                V_ETL_NUM_PROCESO    => V_NUM_PROCESO,
                                                V_ETL_CIFRA_CONTROL => V_CIFRA_CONTROL,
                                                V_ETL_ESTADO         => 'F',
                                                V_ETL_CODE           => V_CODE_ERROR,
                                                V_ETL_MENSAJE        => V_MENSAJE_ERROR);



     IF V_CODE_ERROR = -1  THEN
        RAISE V_EXCEPTION;
    END IF ;

  EXCEPTION
    WHEN OTHERS THEN
      V_CODE_ERROR    := -1;
      V_MENSAJE_ERROR := 'DWHADM.PKG_SPC_BDS_CAPACIDAD_PLANTA.SP_LECTURA_ARCHIVO_BDS'||'-'||SQLERRM||'-'||V_MENSAJE_ERROR;

      DWHADM.PKG_CONTROL_ETL.SP_CAMBIA_ESTADO_ETL(V_ETL_TIPO_ETL       => 100,
                                                  V_ETL_NUM_EJECUCION  => V_EJECUCION,
                                                  V_ETL_NUM_PROCESO    => V_NUM_PROCESO,
                                                  V_ETL_CIFRA_CONTROL => V_CIFRA_CONTROL,
                                                  V_ETL_ESTADO         => 'E',
                                                  V_ETL_CODE           => V_CODE_ERROR,
                                                  V_ETL_MENSAJE        => V_MENSAJE);

      IF V_MENSAJE IS NULL THEN
         V_MENSAJE_ERROR:= V_MENSAJE_ERROR;
      END IF;

  END SP_LECTURA_ARCHIVO_BDS;

  ---------------------------------------------------------------------------------------------------------------------------------
  -- RESUMEN
  -- Descripción : Carga de presolicitud de prestamos en las oficinas edyficar en el esquema BDS
  -- Fecha de Creación : 08/07/2014
  -- Autor : Diego Zegarra T.
  -- Tabla Destino : BDS.F_SPC_PRESOLICITUD
  -- Tablas Fuentes : ODS.HD_PRESOLICITUD
  -- Parametros : V_FEC_INI: Fecha de Inicio
  --              V_TIPO_EJECUCION: Variable R = Reproceso Mensual y C = Diario
  --              V_CODE_ERROR: Codigo de Error 1(Correcto) o -1(Incorrecto)
  --              V_MENSAJE_ERROR: Mensaje de Error
  -- Observacion : No aplica.
  ---------------------------------------------------------------------------------------------------------------------------------

  PROCEDURE SP_PRE_SOLICITUD_BDS(V_FEC_INI       VARCHAR2,
                                 V_TI_EJECUCION  VARCHAR2,
                                 V_CODE_ERROR    OUT VARCHAR2,
                                 V_MENSAJE_ERROR OUT VARCHAR2) IS

    V_PERIODO   NUMBER;
    V_CANT      NUMBER;
    V_EJECUCION NUMBER;
    V_EXCEPTION EXCEPTION;

  BEGIN

    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT = ''DD/MM/YYYY''';

    SELECT NVL(MAX(A.NU_EJECUCION),1)
      INTO V_EJECUCION
      FROM DWHADM.CONTROL_ETL_CABECERA A
     WHERE A.CO_ETL = 110;

    V_NUM_PROCESO := 30;
    DWHADM.PKG_CONTROL_ETL.SP_CAMBIA_ESTADO_ETL(V_ETL_TIPO_ETL       => 110,
                                                V_ETL_NUM_EJECUCION  => V_EJECUCION,
                                                V_ETL_NUM_PROCESO    => V_NUM_PROCESO,
                                                V_ETL_CIFRA_CONTROL => V_CIFRA_CONTROL,
                                                V_ETL_ESTADO         => 'I',
                                                V_ETL_CODE           => V_CODE_ERROR,
                                                V_ETL_MENSAJE        => V_MENSAJE_ERROR);

    ----Se captura el periodo
    v_periodo := TO_CHAR(TO_DATE(V_FEC_INI, 'DD/MM/YYYY'), 'YYYYMM');

    ----Particionamiento automatico

    BDS.PKG_BDS_GENERICO.SP_PARTICIONA_AUTOMATICO(TO_DATE(V_PERIODO,
                                                          'YYYYMM'),
                                                  'F_SPC_PRESOLICITUD',
                                                  'BDS',
                                                  'P_PRESOLICITUD',
                                                   V_CODE_ERROR);
     IF V_CODE_ERROR = -1 THEN
         RAISE V_EXCEPTION;
     END IF;

    SELECT COUNT(A.NU_PERI_MES)
      INTO V_CANT
      FROM BDS.F_SPC_PRESOLICITUD A
     WHERE A.NU_PERI_MES = V_PERIODO
       AND ROWNUM = 1;

    -- Si el proceso es r es reproceso y si c es diario
    IF V_TI_EJECUCION = 'R' THEN
      IF V_CANT > 0 THEN
        BDS.PKG_BDS_GENERICO.SP_TRUNCATE_PARTITION('BDS',
                                                   'F_SPC_PRESOLICITUD',
                                                   'P_PRESOLICITUD_' ||
                                                   V_PERIODO,
                                                  V_CODE_ERROR);

       IF V_CODE_ERROR = -1 THEN
         RAISE V_EXCEPTION;
       END IF;

     -- Regeneracion de Indices
     BDS.PKG_BDS_GENERICO.SP_REGENERA_INDICE('BDS','F_SPC_PRESOLICITUD',V_CODE_ERROR);
     IF V_CODE_ERROR = -1 THEN
         RAISE V_EXCEPTION;
     END IF;

     END IF;

    IF V_CODE_ERROR <> -1 THEN
      INSERT /*+ APPEND */
      INTO BDS.F_SPC_PRESOLICITUD
        (NU_PERI_MES,
         FE_ULTI_DIA_MES,
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
         DE_ASIENTO,
         NU_OPERACION,
         NO_USUA_DESE_PLAT,
         CO_FUNC_DESE_PRES,
         DE_CARG_FUNC,
         TI_PRESOLICITUD,
         FE_ACTU_MES)
        SELECT V_PERIODO,
               D.FE_ULTI_DIA_MES,
               D.FE_PROCESO,
               D.FE_HORA_INIC,
               D.FE_HORA_FIN,
               D.NU_SOLICITUD,
               D.DE_ESTADO,
               D.CO_SUCURSAL,
               D.NO_SUCU_ORIG,
               D.NU_ASIENTO,
               D.NU_USUA_TOPA,
               D.NO_USUARIO,
               D.CO_ASIENTO,
               D.NU_OPERACION,
               D.NO_USUA_DESE_PLAT,
               D.CO_FUNC_DESE_PRES,
               D.DE_CARG_FUNC,
               D.TI_PRESOLICITUD,
               D.FE_ACTU_MES
          FROM ODS.HD_PRESOLICITUD D
          WHERE D.NU_PERI_MES = V_PERIODO;
         V_CIFRA_CONTROL:= SQL%ROWCOUNT;
        COMMIT;
           ELSE
            V_CODE_ERROR    := -1;
            V_MENSAJE_ERROR := 'EL INDICE NO A SIDO REPARADO';
            IF V_CODE_ERROR = -1 THEN
             RAISE V_EXCEPTION;
            END IF;
    END IF;
    ELSE
     IF V_TI_EJECUCION = 'C' THEN

      IF V_CODE_ERROR <> -1 THEN
        INSERT /*+ APPEND */
        INTO BDS.F_SPC_PRESOLICITUD
          (NU_PERI_MES,
           FE_ULTI_DIA_MES,
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
           DE_ASIENTO,
           NU_OPERACION,
           NO_USUA_DESE_PLAT,
           CO_FUNC_DESE_PRES,
           DE_CARG_FUNC,
           TI_PRESOLICITUD,
           FE_ACTU_MES)
          SELECT V_PERIODO,
                 D.FE_ULTI_DIA_MES,
                 D.FE_PROCESO,
                 D.FE_HORA_INIC,
                 D.FE_HORA_FIN,
                 D.NU_SOLICITUD,
                 D.DE_ESTADO,
                 D.CO_SUCURSAL,
                 D.NO_SUCU_ORIG,
                 D.NU_ASIENTO,
                 D.NU_USUA_TOPA,
                 D.NO_USUARIO,
                 D.CO_ASIENTO,
                 D.NU_OPERACION,
                 D.NO_USUA_DESE_PLAT,
                 D.CO_FUNC_DESE_PRES,
                 D.DE_CARG_FUNC,
                 D.TI_PRESOLICITUD,
                 D.FE_ACTU_MES
            FROM ODS.HD_PRESOLICITUD D
            WHERE D.FE_PROCESO = TO_DATE(TO_CHAR(SYSDATE -1,'DD/MM/YYYY'),'DD/MM/YYYY');
             V_CIFRA_CONTROL := SQL%ROWCOUNT;
            COMMIT;
            ELSE
            V_CODE_ERROR    := -1;
            V_MENSAJE_ERROR := 'EL INDICE NO A SIDO REPARADO';
            IF V_CODE_ERROR = -1 THEN
             RAISE V_EXCEPTION;
            END IF;
         END IF;
      END IF;
    END IF;
    -- Elimina Papelera de BDS
    BDS.PKG_BDS_GENERICO.SP_ELIMINA_PAPELERA;
    --

    V_CODE_ERROR := 1;
    DWHADM.PKG_CONTROL_ETL.SP_CAMBIA_ESTADO_ETL(V_ETL_TIPO_ETL       => 110,
                                                V_ETL_NUM_EJECUCION  => V_EJECUCION,
                                                V_ETL_NUM_PROCESO    => V_NUM_PROCESO,
                                                V_ETL_CIFRA_CONTROL => V_CIFRA_CONTROL,
                                                V_ETL_ESTADO         => 'F',
                                                V_ETL_CODE           => V_CODE_ERROR,
                                                V_ETL_MENSAJE        => V_MENSAJE_ERROR);

  EXCEPTION
    WHEN OTHERS THEN

      V_CODE_ERROR    := -1;
      V_MENSAJE_ERROR := 'DWHADM.PKG_SPC_BDS_CAPACIDAD_PLANTA.SP_PRE_SOLICITUD_BDS'||'-'||SQLERRM||'-'||V_MENSAJE_ERROR;

      INSERT INTO DWHADM.CONTROL_ERROR
        (CO_ETL, NU_EJECUCION,  DE_ERROR, FE_ERROR)
        SELECT 110,
               V_EJECUCION,
               SUBSTR(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, 1, 2000) ||
               SUBSTR(V_MENSAJE_ERROR, 10, 400),
               SYSDATE
          FROM DUAL;
      COMMIT;

      DWHADM.PKG_CONTROL_ETL.SP_CAMBIA_ESTADO_ETL(V_ETL_TIPO_ETL       => 110,
                                                  V_ETL_NUM_EJECUCION  => V_EJECUCION,
                                                  V_ETL_NUM_PROCESO    => V_NUM_PROCESO,
                                                  V_ETL_CIFRA_CONTROL => V_CIFRA_CONTROL,
                                                  V_ETL_ESTADO         => 'E',
                                                  V_ETL_CODE           => V_CODE_ERROR,
                                                  V_ETL_MENSAJE        => V_MENSAJE);


      IF V_MENSAJE IS NULL THEN
         V_MENSAJE_ERROR:= V_MENSAJE_ERROR;
      END IF;

  END SP_PRE_SOLICITUD_BDS;

  ---------------------------------------------------------------------------------------------------------------------------------
  -- RESUMEN
  -- Descripción : Carga de cobros o recaudaciones realizadas en el esquema BDS
  -- Fecha de Creación : 08/07/2014
  -- Autor : Diego Zegarra T.
  -- Tabla Destino: BDS.F_SPC_COBRO
  -- Tablas Fuentes: ODS.HD_COBRO
  -- Parametros : V_FEC_INI: Fecha Inicio de Carga
  --              V_TI_EJECUCION: Variable R = Reproceso Mensual y C = Diario
  --              V_CODE_ERROR: Codigo oracle de error
  --              V_MENSAJE_ERROR: Mensaje descriptivo del error
  -- Observaciones : No aplica.
  ---------------------------------------------------------------------------------------------------------------------------------

  PROCEDURE SP_COBROS_BDS(V_FEC_INI        VARCHAR2,
                          V_TI_EJECUCION  VARCHAR2,
                          V_CODE_ERROR    OUT VARCHAR2,
                          V_MENSAJE_ERROR OUT VARCHAR2) IS

    V_PERIODO   NUMBER;
    V_CANT      NUMBER;
    V_EJECUCION NUMBER;
    V_EXCEPTION EXCEPTION;
  BEGIN

    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT = ''DD/MM/YYYY''';

    SELECT NVL(MAX(A.NU_EJECUCION),1)
      INTO V_EJECUCION
      FROM DWHADM.CONTROL_ETL_CABECERA A
     WHERE A.CO_ETL = 130;

    V_NUM_PROCESO := 30;
    DWHADM.PKG_CONTROL_ETL.SP_CAMBIA_ESTADO_ETL(V_ETL_TIPO_ETL       => 130,
                                                V_ETL_NUM_EJECUCION  => V_EJECUCION,
                                                V_ETL_NUM_PROCESO    => V_NUM_PROCESO,
                                                V_ETL_CIFRA_CONTROL => V_CIFRA_CONTROL,
                                                V_ETL_ESTADO         => 'I',
                                                V_ETL_CODE           => V_CODE_ERROR,
                                                V_ETL_MENSAJE        => V_MENSAJE_ERROR);

    --Se captura el periodo
    V_PERIODO := TO_CHAR(TO_DATE(V_FEC_INI, 'DD/MM/YYYY'), 'YYYYMM');

    -- Particionamiento automatico cobros
    BDS.PKG_BDS_GENERICO.SP_PARTICIONA_AUTOMATICO(TO_DATE(V_PERIODO,
                                                          'YYYYMM'),
                                                  'F_SPC_COBRO',
                                                  'BDS',
                                                  'P_COBROS',
                                                  V_CODE_ERROR);
     IF V_CODE_ERROR = -1 THEN
         RAISE V_EXCEPTION;
     END IF;

    SELECT COUNT(A.NU_PERI_MES)
      INTO V_CANT
      FROM BDS.F_SPC_COBRO A
     WHERE A.NU_PERI_MES = V_PERIODO
       AND ROWNUM = 1;

    IF V_TI_EJECUCION = 'R' THEN
      -- Se borra el periodo y se vuelve a cargar el periodo en ejecucion
      IF V_CANT > 0 THEN
        BDS.PKG_BDS_GENERICO.SP_TRUNCATE_PARTITION('BDS',
                                                   'F_SPC_COBRO',
                                                   'P_COBROS_' || V_PERIODO,
                                                   V_CODE_ERROR);
        IF V_CODE_ERROR = -1 THEN
         RAISE V_EXCEPTION;
        END IF;

         -- Regeneracion de Indices
         BDS.PKG_BDS_GENERICO.SP_REGENERA_INDICE('BDS','F_SPC_PRESOLICITUD',V_CODE_ERROR);
         IF V_CODE_ERROR = -1 THEN
             RAISE V_EXCEPTION;
         END IF;

     END IF;

     IF V_CODE_ERROR <> -1 THEN
      INSERT INTO BDS.F_SPC_COBRO
        (NU_PERI_MES,
         FE_ULTI_DIA_MES,
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
        SELECT R.NU_PERI_MES,
               R.FE_ULTI_DIA_MES,
               R.FE_VALOR,
               R.CO_REGI_UNIC_APLI,
               R.NU_PRESTAMO,
               R.CO_CLIENTE,
               R.NU_ASIE_PAGO,
               R.CO_USUA_COBR,
               R.CO_FUNC_COBR,
               R.CO_SUCU_PAGO_CUOT,
               R.NO_SUCU_PAGO_CUOT,
               R.CO_MONEDA,
               R.MO_PAGO_CUOT,
               R.MO_ITF_MOVI,
               R.MO_OTRO_PAGO,
               R.FE_HORA_PAGO,
               R.FE_PAGO,
               R.CO_SUCU_ORIG,
               R.NO_SUCU_ORIG,
               R.NO_CANAL,
               R.CO_ANALISTA,
               R.NO_ANALISTA,
               R.TI_OPERACION,
               R.DE_OPERACION,
               R.NO_CARG_FUNC,
               R.MO_CAPI_PAGA,
               R.MO_INTE_PAGA,
               R.ST_CREDITO,
               R.MO_SALD_CORT,
               R.ST_COBRO,
               R.CO_SUCU_OFIC_PRES,
               R.NO_SUCU_OFIC_PRES,
               R.FE_ACTU_MES,
               R.NU_SOLICITUD,
               R.FE_PAGO_COBR
          FROM ODS.HD_COBRO R
          WHERE R.NU_PERI_MES = V_PERIODO;
           V_CIFRA_CONTROL := SQL%ROWCOUNT;
           COMMIT;
          ELSE
            V_CODE_ERROR    := -1;
            V_MENSAJE_ERROR := 'EL INDICE NO A SIDO REPARADO';
            IF V_CODE_ERROR = -1 THEN
             RAISE V_EXCEPTION;
            END IF;
       END IF ;
    ELSE
      IF V_TI_EJECUCION = 'C' THEN

       IF V_CODE_ERROR <> -1 THEN
        INSERT INTO BDS.F_SPC_COBRO
          (NU_PERI_MES,
           FE_ULTI_DIA_MES,
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

          SELECT R.NU_PERI_MES,
                 R.FE_ULTI_DIA_MES,
                 R.FE_VALOR,
                 R.CO_REGI_UNIC_APLI,
                 R.NU_PRESTAMO,
                 R.CO_CLIENTE,
                 R.NU_ASIE_PAGO,
                 R.CO_USUA_COBR,
                 R.CO_FUNC_COBR,
                 R.CO_SUCU_PAGO_CUOT,
                 R.NO_SUCU_PAGO_CUOT,
                 R.CO_MONEDA,
                 R.MO_PAGO_CUOT,
                 R.MO_ITF_MOVI,
                 R.MO_OTRO_PAGO,
                 R.FE_HORA_PAGO,
                 R.FE_PAGO,
                 R.CO_SUCU_ORIG,
                 R.NO_SUCU_ORIG,
                 R.NO_CANAL,
                 R.CO_ANALISTA,
                 R.NO_ANALISTA,
                 R.TI_OPERACION,
                 R.DE_OPERACION,
                 R.NO_CARG_FUNC,
                 R.MO_CAPI_PAGA,
                 R.MO_INTE_PAGA,
                 R.ST_CREDITO,
                 R.MO_SALD_CORT,
                 R.ST_COBRO,
                 R.CO_SUCU_OFIC_PRES,
                 R.NO_SUCU_OFIC_PRES,
                 R.FE_ACTU_MES,
                 R.NU_SOLICITUD,
                 R.FE_PAGO_COBR
            FROM ODS.HD_COBRO R
            WHERE R.FE_VALOR = TO_DATE(TO_CHAR(SYSDATE -1,'DD/MM/YYYY'),'DD/MM/YYYY');
              V_CIFRA_CONTROL := SQL%ROWCOUNT;
              COMMIT;
                  ELSE
                    V_CODE_ERROR    := -1;
                    V_MENSAJE_ERROR := 'EL INDICE NO A SIDO REPARADO';
            IF V_CODE_ERROR = -1 THEN
             RAISE V_EXCEPTION;
            END IF;
         END IF;
      END IF;
    END IF;

    -- Elimina Papelera de BDS
    BDS.PKG_BDS_GENERICO.SP_ELIMINA_PAPELERA;
    --
    V_CODE_ERROR:= 1;
    DWHADM.PKG_CONTROL_ETL.SP_CAMBIA_ESTADO_ETL(V_ETL_TIPO_ETL       => 130,
                                                V_ETL_NUM_EJECUCION  => V_EJECUCION,
                                                V_ETL_NUM_PROCESO    => V_NUM_PROCESO,
                                                V_ETL_CIFRA_CONTROL => V_CIFRA_CONTROL,
                                                V_ETL_ESTADO         => 'F',
                                                V_ETL_CODE           => V_CODE_ERROR,
                                                V_ETL_MENSAJE        => V_MENSAJE_ERROR);

  EXCEPTION
    WHEN OTHERS THEN
      V_CODE_ERROR:= -1;
      V_MENSAJE_ERROR := 'DWHADM.PKG_SPC_BDS_CAPACIDAD_PLANTA.SP_COBROS_BDS'||'-'||SQLERRM||'-'||V_MENSAJE_ERROR;

       INSERT INTO DWHADM.CONTROL_ERROR
        (CO_ETL, NU_EJECUCION, DE_ERROR, FE_ERROR)
        SELECT 130,
               V_EJECUCION,
               SUBSTR(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, 1, 2000) ||
               SUBSTR(V_MENSAJE_ERROR, 10, 400),
               SYSDATE
          FROM DUAL;
      COMMIT;

      DWHADM.PKG_CONTROL_ETL.SP_CAMBIA_ESTADO_ETL(V_ETL_TIPO_ETL       => 130,
                                                  V_ETL_NUM_EJECUCION  => V_EJECUCION,
                                                  V_ETL_NUM_PROCESO    => V_NUM_PROCESO,
                                                  V_ETL_CIFRA_CONTROL => V_CIFRA_CONTROL,
                                                  V_ETL_ESTADO         => 'E',
                                                  V_ETL_CODE           => V_CODE_ERROR,
                                                  V_ETL_MENSAJE        => V_MENSAJE);

      IF V_MENSAJE IS NULL THEN
         V_MENSAJE_ERROR:= V_MENSAJE_ERROR;
      END IF;

  END SP_COBROS_BDS;

  ------------------------------------------------------------------------------------------------------------
  -- RESUMEN
  -- Descripción : Carga de desembolsos de prestamos realizados en el esquema BDS
  -- Fecha de Creación : 14/07/2014
  -- Autor : Diego Zegarra Torres - GORA SAC
  -- Tabla Destino : BDS.F_SPC_DESEMBOLSO
  -- Tablas Fuentes : ODS.HD_DESEMBOLSO
  -- Parametros : V_FEC_INI:  Fecha de Inicio de la Carga
  --              V_TI_EJECUCION: Puede ser C= Diario o R= Reproceso Mensual
  --              V_CODE_ERROR: Codigo oracle de error
  --              V_MENSAJE_ERROR: Mensaje descriptivo del error
  -- Observación : No aplica.
  ------------------------------------------------------------------------------------------------------------
  PROCEDURE SP_DESEMBOLSO_BDS(V_FEC_INI       VARCHAR2,
                              V_TI_EJECUCION  VARCHAR2,
                              V_CODE_ERROR    OUT VARCHAR2,
                              V_MENSAJE_ERROR OUT VARCHAR2) IS

    V_CANT      NUMBER;
    V_PERIODO   NUMBER;
    V_EJECUCION NUMBER;
    V_EXCEPTION EXCEPTION;

  BEGIN
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT = ''DD/MM/YYYY''';

    SELECT NVL(MAX(A.NU_EJECUCION),1)
      INTO V_EJECUCION
      FROM DWHADM.CONTROL_ETL_CABECERA A
     WHERE A.CO_ETL = 120;

    V_NUM_PROCESO := 30;
    DWHADM.PKG_CONTROL_ETL.SP_CAMBIA_ESTADO_ETL(V_ETL_TIPO_ETL       => 120,
                                                V_ETL_NUM_EJECUCION  => V_EJECUCION,
                                                V_ETL_NUM_PROCESO    => V_NUM_PROCESO,
                                                V_ETL_CIFRA_CONTROL => V_CIFRA_CONTROL,
                                                V_ETL_ESTADO         => 'I',
                                                V_ETL_CODE           => V_CODE_ERROR,
                                                V_ETL_MENSAJE        => V_MENSAJE_ERROR);

    -- Se captura el periodo
    V_PERIODO := TO_CHAR(TO_DATE(V_FEC_INI, 'DD/MM/YYYY'), 'YYYYMM');

    -- Elimina particiones
    SELECT COUNT(A.NU_PERI_MES)
      INTO V_CANT
      FROM BDS.F_SPC_DESEMBOLSO A
     WHERE A.NU_PERI_MES = V_PERIODO
       AND ROWNUM = 1;

    -- Particionamiento automatico
    BDS.PKG_BDS_GENERICO.SP_PARTICIONA_AUTOMATICO(TO_DATE(V_PERIODO,
                                                          'YYYYMM'),
                                                  'F_SPC_DESEMBOLSO',
                                                  'BDS',
                                                  'P_DESEMBOLSO',
                                                   V_CODE_ERROR);
     IF V_CODE_ERROR = -1 THEN
         RAISE V_EXCEPTION;
     END IF;

    IF V_TI_EJECUCION = 'R' THEN

      IF V_CANT > 0 THEN
        BDS.PKG_BDS_GENERICO.SP_TRUNCATE_PARTITION('BDS',
                                                   'F_SPC_DESEMBOLSO',
                                                   'P_DESEMBOLSO_' ||
                                                   V_PERIODO,
                                                   V_CODE_ERROR);
      IF V_CODE_ERROR = -1 THEN
         RAISE V_EXCEPTION;
      END IF;

       --Regeneracion de Indices
       BDS.PKG_BDS_GENERICO.SP_REGENERA_INDICE('BDS','F_SPC_DESEMBOLSO',V_CODE_ERROR);
       IF V_CODE_ERROR = -1 THEN
           RAISE V_EXCEPTION;
       END IF;

    END IF;

    IF V_CODE_ERROR <> -1 THEN
      INSERT /*+ APPEND */
      INTO BDS.F_SPC_DESEMBOLSO
        (NU_PERI_MES,
         FE_ULTI_DIA_MES,
         FE_VALOR,
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
         DE_CARG_USUA_CAJA)
        SELECT A.NU_PERI_MES,
               A.FE_ULTI_DIA_MES,
			   --@001 ini: Se cambia el nombre del campo FE_VALOR a FE_APER_CUEN en el select de la tabla ODS.HD_DESEMBOLSO
               A.FE_APER_CUEN,
			   --@001 fin
               A.NU_PRESTAMO,
               A.CO_CLIENTE,
               A.MO_APRO_DESE,
               A.MO_DESEMBOLSADO,
               A.DE_MONEDA,
               A.TI_DESEMBOLSO,
               A.MO_RECU_SALD,
               A.MO_DESE_CAJA,
               A.CO_SUCU_ORIG,
               A.MO_SOLICITADO,
               A.NU_DIA_PROG_PAGO,
               A.NO_CLIENTE,
               A.NO_VIA_DESE_PLAT,
               A.NO_SUCU_ORIG,
               A.NU_ASIE_PLAT,
               A.CO_USUA_DESE_PLAT,
               A.CO_FUNC_DESE_PLAT,
               A.NO_USUA_DESE_PLAT,
               A.CO_SUCU_DESE_PLAT,
               A.NO_SUCU_DESE_PLAT,
               A.NU_ASIE_CAJA,
               A.CO_USUA_DESE_CAJA,
               A.CO_FUNC_DESE_CAJA,
               A.NO_USUA_DESE_CAJA,
               A.CO_SUCU_DESE_CAJA,
               A.NO_SUCU_DESE_CAJA,
               A.FE_ACTU_MES,
               A.FE_DESE_PLAT,
               A.FE_DESE_CAJA,
               A.NU_SOLICITUD,
               A.NU_PARTICIPANTES,
               A.DE_CARG_USUA_PLAT,
               A.DE_CARG_USUA_CAJA
          FROM ODS.HD_DESEMBOLSO A
          WHERE A.NU_PERI_MES = V_PERIODO;
            V_CIFRA_CONTROL := SQL%ROWCOUNT;
            COMMIT;
          ELSE
        V_CODE_ERROR    := -1;
        V_MENSAJE_ERROR := 'EL INDICE NO A SIDO REPARADO';
            IF V_CODE_ERROR = -1 THEN
             RAISE V_EXCEPTION;
            END IF;
   END IF;
    ELSE

    IF V_TI_EJECUCION = 'C' THEN
       IF V_CODE_ERROR <> -1 THEN
        INSERT /*+ APPEND */
        INTO BDS.F_SPC_DESEMBOLSO
          (NU_PERI_MES,
           FE_ULTI_DIA_MES,
           FE_VALOR,
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
           DE_CARG_USUA_CAJA)
          SELECT A.NU_PERI_MES,
                 A.FE_ULTI_DIA_MES,
                 --@002 ini: Se cambia el nombre del campo FE_VALOR a FE_APER_CUEN en el select de la tabla ODS.HD_DESEMBOLSO
                 A.FE_APER_CUEN,
                 --@002 fin
                 A.NU_PRESTAMO,
                 A.CO_CLIENTE,
                 A.MO_APRO_DESE,
                 A.MO_DESEMBOLSADO,
                 A.DE_MONEDA,
                 A.TI_DESEMBOLSO,
                 A.MO_RECU_SALD,
                 A.MO_DESE_CAJA,
                 A.CO_SUCU_ORIG,
                 A.MO_SOLICITADO,
                 A.NU_DIA_PROG_PAGO,
                 A.NO_CLIENTE,
                 A.NO_VIA_DESE_PLAT,
                 A.NO_SUCU_ORIG,
                 A.NU_ASIE_PLAT,
                 A.CO_USUA_DESE_PLAT,
                 A.CO_FUNC_DESE_PLAT,
                 A.NO_USUA_DESE_PLAT,
                 A.CO_SUCU_DESE_PLAT,
                 A.NO_SUCU_DESE_PLAT,
                 A.NU_ASIE_CAJA,
                 A.CO_USUA_DESE_CAJA,
                 A.CO_FUNC_DESE_CAJA,
                 A.NO_USUA_DESE_CAJA,
                 A.CO_SUCU_DESE_CAJA,
                 A.NO_SUCU_DESE_CAJA,
                 A.FE_ACTU_MES,
                 A.FE_DESE_PLAT,
                 A.FE_DESE_CAJA,
                 A.NU_SOLICITUD,
                 A.NU_PARTICIPANTES,
                 A.DE_CARG_USUA_PLAT,
                 A.DE_CARG_USUA_CAJA
            FROM ODS.HD_DESEMBOLSO A
            --@003 ini: Se cambia el nombre del campo FE_VALOR a FE_APER_CUEN en la condición
            WHERE A.FE_APER_CUEN = TO_DATE(TO_CHAR(SYSDATE-1,'DD/MM/YYYY'),'DD/MM/YYYY');
            --@003 fin
             V_CIFRA_CONTROL := SQL%ROWCOUNT;
             COMMIT;
            ELSE
                V_CODE_ERROR    := -1;
                V_MENSAJE_ERROR := 'EL INDICE NO A SIDO REPARADO';
                 IF V_CODE_ERROR = -1 THEN
                  RAISE V_EXCEPTION;
                 END IF;
        END IF;
      END IF;
    END IF;

    -- Elimina Papelera de BDS
    BDS.PKG_BDS_GENERICO.SP_ELIMINA_PAPELERA;
    --
    V_CODE_ERROR := 1;
    DWHADM.PKG_CONTROL_ETL.SP_CAMBIA_ESTADO_ETL(V_ETL_TIPO_ETL       => 120,
                                                V_ETL_NUM_EJECUCION  => V_EJECUCION,
                                                V_ETL_NUM_PROCESO    => V_NUM_PROCESO,
                                                V_ETL_CIFRA_CONTROL => V_CIFRA_CONTROL,
                                                V_ETL_ESTADO         => 'F',
                                                V_ETL_CODE           => V_CODE_ERROR,
                                                V_ETL_MENSAJE        => V_MENSAJE_ERROR);

  EXCEPTION
    WHEN OTHERS THEN

      V_CODE_ERROR    := -1;
      V_MENSAJE_ERROR := 'DWHADM.PKG_SPC_BDS_CAPACIDAD_PLANTA.SP_DESEMBOLSO_BDS'||'-'||SQLERRM||'-'||V_MENSAJE_ERROR;

       INSERT INTO DWHADM.CONTROL_ERROR
        (CO_ETL, NU_EJECUCION, DE_ERROR, FE_ERROR)
        SELECT 120,
               V_EJECUCION,
               SUBSTR(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, 1, 2000) ||
               SUBSTR(V_MENSAJE_ERROR, 10, 400),
               SYSDATE
          FROM DUAL;
      COMMIT;

      DWHADM.PKG_CONTROL_ETL.SP_CAMBIA_ESTADO_ETL(V_ETL_TIPO_ETL       => 120,
                                                  V_ETL_NUM_EJECUCION  => V_EJECUCION,
                                                  V_ETL_NUM_PROCESO    => V_NUM_PROCESO,
                                                  V_ETL_CIFRA_CONTROL => V_CIFRA_CONTROL,
                                                  V_ETL_ESTADO         => 'E',
                                                  V_ETL_CODE           => V_CODE_ERROR,
                                                  V_ETL_MENSAJE        => V_MENSAJE);

      IF V_MENSAJE IS NULL THEN
         V_MENSAJE_ERROR:= V_MENSAJE_ERROR;
      END IF;

  END SP_DESEMBOLSO_BDS;

END PKG_SPC_BDS_CAPACIDAD_PLANTA;
/