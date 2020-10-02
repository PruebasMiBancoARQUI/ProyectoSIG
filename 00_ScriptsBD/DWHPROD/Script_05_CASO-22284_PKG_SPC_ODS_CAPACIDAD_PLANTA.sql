CREATE OR REPLACE PACKAGE DWHADM.PKG_SPC_ODS_CAPACIDAD_PLANTA
------------------------------------------------------------------------------------------------------------
-- RESUMEN
-- Proyecto : CAPACIDAD PLANTA
-- Nombre :  PKG_SPC_ODS_CAPACIDAD_PLANTA
-- Autor : Diego Zegarra T. (GORA SAC)
-- Fecha de Creación : 15/07/2014
-- Descripción : Paquete para ejecutar el esquema ODS del Proyecto
------------------------------------------------------------------------------------------------------------
-- Modificaciones
-- Requerimiento Responsable Fecha Descripción
------------------------------------------------------------------------------------------------------------
 IS
  -- Variable Locales
  V_NUM_PROCESO NUMBER;
  V_CIFRA_CONTROL NUMBER;
  V_MENSAJE VARCHAR2(100);

  ------------------------------------------------------------------------------------------------------------
  -- RESUMEN
  -- Descripción : Carga de Fuerza Laboral, Vacaciones y Organico en el esquema ODS
  -- Fecha de Creación : 02/07/2014
  -- Autor : Diego Zegarra Torres - GORA SAC
  -- Tabla Destino : ODS.HM_FUERZA_LABORAL
  --                 ODS.HM_ORGANICO
  --                 ODS.HM_VACACIONES
  -- Tablas Fuentes : STG.T_FUERZA_LABORAL
  --                  STG.T_ORGANICO
  --                  STG.T_VACACIONES
  -- Parametros : V_PERIODO: Periodo de Proceso de la Carga
  --              V_TI_REP: Toma Valores como F:Fuerza Labora,V:Vacaciones, O:Organico o T:Total(Todos los reportes)
  --              V_CODE_ERROR: Toma Valores como 1(Correcto) o -1(Incorrecto)
  --              V_MENSAJE_ERROR: Mensaje de Error Oracle
  -- Observación: No aplica.
  ------------------------------------------------------------------------------------------------------------
  PROCEDURE SP_LECTURA_ARCHIVO_ODS(V_PERIODO       IN NUMBER,
                                   V_TI_REP        IN VARCHAR2,
                                   V_CODE_ERROR    OUT NUMBER,
                                   V_MENSAJE_ERROR OUT VARCHAR2);
  ---------------------------------------------------------------------------------------------------------------------------------
  -- RESUMEN
  -- Descripción : Carga de presolicitud de prestamos en las oficinas edyficar en el esquema ODS
  -- Fecha de Creación : 08/07/2014
  -- Autor : Diego Zegarra T.
  -- Tabla Destino :  ODS.HD_PRESOLICITUD
  -- Tablas Fuentes: STG.T_PRESOLICITU
  -- Parametros  : V_FEC_INI: Fecha Inicio de Carga
  --               V_TIPO_EJECUCION: Variable R = Reproceso Mensual y C = Diario
  --               V_CODE_ERROR: Toma Valores como 1(Correcto) o -1(Incorrecto)
  --               V_MENSAJE_ERROR: Mensaje de Error Oracle
  -- Observacion : No aplica.
  ---------------------------------------------------------------------------------------------------------------------------------
  PROCEDURE SP_PRE_SOLICITUD_ODS(V_FEC_INI       IN VARCHAR2,
                                 V_TI_EJECUCION  IN VARCHAR2,
                                 V_CODE_ERROR    OUT VARCHAR2,
                                 V_MENSAJE_ERROR OUT VARCHAR2);
  ---------------------------------------------------------------------------------------------------------------------------------
  -- RESUMEN
  -- Descripción : Carga de cobros o recaudaciones realizadas en el esquema ODS
  -- Fecha de Creación : 08/07/2014
  -- Autor : Diego Zegarra T.
  -- Tabla Destino : ODS.HD_COBRO
  -- Tablas Fuentes : STG.T_COBRO
  -- Parametros : V_FEC_INI: Fecha Inicio de Carga
  --              V_TI_EJECUCION: Tiene 2 opciones R= Reproceso y C: Diario
  --              V_CODE_ERROR: Toma Valores como 1(Correcto) o -1(Incorrecto)
  --              V_MENSAJE_ERROR: Mensaje de Error Oracle
  -- Observaciones : No aplica
  ---------------------------------------------------------------------------------------------------------------------------------
  PROCEDURE SP_COBROS_ODS(V_FEC_INI       IN VARCHAR2,
                          V_TI_EJECUCION  IN VARCHAR2,
                          V_CODE_ERROR    OUT NUMBER,
                          V_MENSAJE_ERROR OUT VARCHAR2);
  ------------------------------------------------------------------------------------------------------------
  -- RESUMEN
  -- Descripción : PCarga de desembolsos de prestamos realizados en el esquema ODS
  -- Fecha de Creación : 14/07/2014
  -- Autor : Diego Zegarra Torres - GORA SAC
  -- Tabla Destino :  ODS.HD_DESEMBOLSO
  -- Tablas Fuentes : STG.T_DESEMBOLSO
  -- Parametros : V_FEC_INI: Fecha de carga inicio
  --              V_TI_EJECUCION: Puede ser C : Diaria o R:Reproceso
  --              V_CODE_ERROR: Toma Valores como 1(Correcto) o -1(Incorrecto)
  --              V_MENSAJE_ERROR: Mensaje de Error Oracle
  -- Observación : No aplica.
  ------------------------------------------------------------------------------------------------------------
  PROCEDURE SP_DESEMBOLSO_ODS(V_FEC_INI       IN VARCHAR2,
                              V_TI_EJECUCION  IN VARCHAR2,
                              V_CODE_ERROR    OUT VARCHAR2,
                              V_MENSAJE_ERROR OUT VARCHAR2);

end PKG_SPC_ODS_CAPACIDAD_PLANTA;
/
CREATE OR REPLACE PACKAGE BODY DWHADM.PKG_SPC_ODS_CAPACIDAD_PLANTA
------------------------------------------------------------------------------------------------------------
-- RESUMEN
-- Proyecto : CAPACIDAD PLANTA
-- Nombre :  PKG_SPC_ODS_CAPACIDAD_PLANTA
-- Autor : Diego Zegarra T. (GORA SAC)
-- Fecha de CreaciÃ³n : 15/07/2014
-- DescripciÃ³n : Paquete para ejecutar el esquema ODS del Proyecto
------------------------------------------------------------------------------------------------------------
-- Modificaciones
-- Responsable : Jorge Chinchay
-- Fecha       : 13/08/2020
-- DescripciÃ³n : Se agregan y cargan los campos adicionales
--               en la tabla HD_DESEMBOLSO utilizada en CRM
------------------------------------------------------------------------------------------------------------
--@001 PRZ CASO-20427: Se cambia el nombre de FE_VALOR a FE_APER_CUEN en la tabla ODS.HD_DESEMBOLSO
--@002 PRZ CASO-20427: Se agregan 6 campos nuevos a la tabla ODS.HD_DESEMBOLSO
--@003 PRZ CASO-20427: Se selecciona el campo FE_APER_CUEN para la carga de la tabla ODS.HD_DESEMBOLSO
--@004 PRZ CASO-20427: Se agregan 6 campos en el select para llenar la tabla ODS.HD_DESEMBOLSO
--@005 PRZ CASO-20427: Se cambia el nombre de FE_VALOR a FE_APER_CUEN en la tabla ODS.HD_DESEMBOLSO
--@006 PRZ CASO-20427: Se agregan 6 campos nuevos a la tabla ODS.HD_DESEMBOLSO
--@007 PRZ CASO-20427: Se selecciona el campo FE_APER_CUEN para la carga de la tabla ODS.HD_DESEMBOLSO
--@008 PRZ CASO-20427: Se agregan 6 campos en el select para llenar la tabla STG.T_DESEMBOLSO
--@009 PRZ CASO-22284: Se agregam 4 campos en el select para llenar la tabla STG.T_DESEMBOLSO (COD_ANA - COD_PRO - VL_TCEA - NU_PLA_DIAS)
------------------------------------------------------------------------------------------------------------
 IS
  ------------------------------------------------------------------------------------------------------------
  -- RESUMEN
  -- DescripciÃ³n : Carga de Fuerza Laboral, Vacaciones y Organico en el esquema ODS
  -- Fecha de CreaciÃ³n : 02/07/2014
  -- Autor : Diego Zegarra Torres - GORA SAC
  -- Tabla Destino : ODS.HM_FUERZA_LABORAL
  --                 ODS.HM_ORGANICO
  --                 ODS.HM_VACACIONES
  -- Tablas Fuentes : STG.T_FUERZA_LABORAL
  --                  STG.T_ORGANICO
  --                  STG.T_VACACIONES
  -- Parametros : V_PERIODO: Periodo de Proceso de la Carga
  --              V_TI_REP : Toma Valores como F:Fuerza Labora,V:Vacaciones, O:Organico o T:Total(Todos los reportes)
  --              V_CODE_ERROR: Toma Valores como 1(Correcto) o -1(Incorrecto)
  --              V_MENSAJE_ERROR: Mensaje de Error Oracle
  -- ObservaciÃ³n: No aplica.
  ------------------------------------------------------------------------------------------------------------

  PROCEDURE SP_LECTURA_ARCHIVO_ODS(V_PERIODO       IN NUMBER,
                                   V_TI_REP        IN VARCHAR2,
                                   V_CODE_ERROR    OUT NUMBER,
                                   V_MENSAJE_ERROR OUT VARCHAR2) IS

    V_CANT      NUMBER;
    V_ERROR     NUMBER;
    V_EJECUCION NUMBER;
    V_EXCEPTION EXCEPTION;
  BEGIN

   EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT = ''DD/MM/YYYY''';

    SELECT NVL(MAX(A.NU_EJECUCION),1)
      INTO V_EJECUCION
      FROM DWHADM.CONTROL_ETL_CABECERA A
     WHERE A.CO_ETL = 100;

    V_NUM_PROCESO := 20;
    DWHADM.PKG_CONTROL_ETL.SP_CAMBIA_ESTADO_ETL(V_ETL_TIPO_ETL       => 100,
                                                V_ETL_NUM_EJECUCION  => V_EJECUCION,
                                                V_ETL_NUM_PROCESO    => V_NUM_PROCESO,
                                                V_ETL_CIFRA_CONTROL => V_CIFRA_CONTROL,
                                                V_ETL_ESTADO         => 'I',
                                                V_ETL_CODE           => V_CODE_ERROR,
                                                V_ETL_MENSAJE        => V_MENSAJE_ERROR);

    -- Se Modifica la session de caracteres
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ''.,''';

 IF V_TI_REP IN ('F','O','V','T') THEN
 BEGIN

    IF V_TI_REP = 'F' or V_TI_REP = 'T' then
      -- Particionamiento automatico
      ODS.PKG_ODS_GENERICO.SP_PARTICIONA_AUTOMATICO(TO_DATE(V_PERIODO,'YYYYMM'),'HM_FUERZA_LABORAL','ODS','P_FUERZA_LABORAL',V_CODE_ERROR);

      IF V_CODE_ERROR = -1 THEN
               RAISE V_EXCEPTION;
      END IF;

      -- Proceso fuerza laboral
      SELECT COUNT(A.NU_PERI_MES)
        INTO V_CANT
        FROM ODS.HM_FUERZA_LABORAL A
       WHERE A.NU_PERI_MES = V_PERIODO
         AND ROWNUM = 1;

    IF V_CANT > 0 THEN
      ODS.PKG_ODS_GENERICO.SP_TRUNCATE_PARTITION('ODS','HM_FUERZA_LABORAL','P_FUERZA_LABORAL_'||V_PERIODO,V_CODE_ERROR);

      IF V_CODE_ERROR = -1 THEN
               RAISE V_EXCEPTION;
      END IF;

    -- Regeneracion de Indices
    ODS.PKG_ODS_GENERICO.SP_REGENERA_INDICE('ODS','HM_FUERZA_LABORAL',V_CODE_ERROR);
    --
    IF V_CODE_ERROR = -1 THEN
           RAISE V_EXCEPTION;
    END IF;

    END IF;

   IF  V_CODE_ERROR <> -1 THEN
    INSERT /*+ APPEND */
      INTO ODS.HM_FUERZA_LABORAL ODS
        (NU_PERI_MES,
         FE_ULTI_DIA_MES,
         NU_MES,
         CO_USUARIO,
         NO_TRABAJADOR,
         DE_CARG_EMPL,
         DE_ESCUELA,
         NU_DOCUMENTO,
         DE_SEXO_EMPL,
         TI_EMPLEADO,
         ST_COND_LABO,
         DE_REGION,
         NO_GERENCIAS,
         NO_AGENCIAS,
         TI_AGENCIAS,
         NO_CENT_COST,
         NO_OFICINA,
         FE_INGRESO,
         TI_GRUPO,
         FE_ACTU_MES)

        SELECT V_PERIODO,
               TRUNC(LAST_DAY(TO_CHAR(TO_DATE(V_PERIODO, 'YYYYMM'),
                                      'DD/MM/YYYY'))),
               NVL(ODS.NU_MES, 0),
               NVL(ODS.CO_USUARIO, '.'),
               NVL(ODS.NO_TRABAJADOR, '.'),
               NVL(ODS.DE_CARG_EMPL, '.'),
               NVL(ODS.DE_ESCUELA, '.'),
               NVL(ODS.NU_DOCUMENTO, 0),
               NVL(ODS.DE_SEXO_EMPL, '.'),
               NVL(ODS.TI_EMPLEADO, '.'),
               NVL(ODS.ST_COND_LABO, '.'),
               NVL(ODS.NO_REGION, '.'),
               NVL(ODS.NO_GERENCIAS, '.'),
               NVL(ODS.NO_AGENCIAS, '.'),
               NVL(ODS.TI_AGENCIAS, '.'),
               NVL(ODS.NO_CENT_COST, '.'),
               NVL(ODS.NO_OFICINA, '.'),
               NVL(ODS.FE_INGRESO, TO_DATE('01010001', 'DDMMYYYY')),
               NVL(ODS.TI_GRUPO, '.'),
               NVL(ODS.FE_ACTU_MES, TO_DATE('01010001', 'DDMMYYYY'))
          FROM STG.T_FUERZA_LABORAL ODS;
          V_CIFRA_CONTROL := SQL%ROWCOUNT;
      COMMIT;
       ELSE
        V_CODE_ERROR    := -1;
        V_MENSAJE_ERROR := 'EL INDICE NO A SIDO REGENERADO';
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

    BEGIN

    IF V_TI_REP = 'O' or V_TI_REP = 'T' then

      -- Particionamiento automatico Organico
      ODS.PKG_ODS_GENERICO.SP_PARTICIONA_AUTOMATICO(TO_DATE(V_PERIODO,'YYYYMM'),
                                                            'HM_ORGANICO',
                                                            'ODS',
                                                            'P_ORGANICO',
                                                            V_CODE_ERROR);
      IF V_CODE_ERROR = -1 THEN
         RAISE V_EXCEPTION;
      END IF;

      -- Proceso Organico
      SELECT COUNT(A.NU_PERI_MES)
        INTO V_CANT
        FROM ODS.HM_ORGANICO A
       WHERE A.NU_PERI_MES = V_PERIODO
         AND ROWNUM = 1;

      IF V_CANT > 0 THEN
        ODS.PKG_ODS_GENERICO.SP_TRUNCATE_PARTITION('ODS',
                                                   'HM_ORGANICO',
                                                   'P_ORGANICO_' ||
                                                   V_PERIODO,
                                                   V_CODE_ERROR);
        IF V_CODE_ERROR = -1 THEN
             RAISE V_EXCEPTION;
        END IF;

       -- Regeneracion de Indices
       ODS.PKG_ODS_GENERICO.SP_REGENERA_INDICE('ODS','HM_ORGANICO',V_CODE_ERROR);
       --
        IF V_CODE_ERROR = -1 THEN
               RAISE V_EXCEPTION;
        END IF;

      END IF;

     IF  V_CODE_ERROR <> -1 THEN
      INSERT INTO ODS.HM_ORGANICO
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
               NVL(ORG.NO_SUPE_REGI, '.'),
               NVL(ORG.NO_SUPE_TERR, '.'),
               NVL(ORG.NO_GERE_OPER, '.'),
               NVL(ORG.NO_AGEN_MATR, '.'),
               NVL(ORG.NO_OFIC_CORT, '.'),
               NVL(ORG.NO_OFIC_COMP, '.'),
               NVL(ORG.NU_CAJA_OFIC, 0),
               NVL(ORG.FE_ACTU_MES, to_date('01010001', 'DDMMYYYY')),
               NVL(ORG.NU_ASIS_OPER, 0)
          FROM STG.T_ORGANICO ORG;
          V_CIFRA_CONTROL := SQL%ROWCOUNT;
      COMMIT;
         ELSE
          V_CODE_ERROR    := -1;
          V_MENSAJE_ERROR := 'EL INDICE NO A SIDO REGENERADO';
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

    BEGIN

    IF V_TI_REP = 'V' or V_TI_REP = 'T' then

      -- Particionamiento automatico vacaciones
      ODS.PKG_ODS_GENERICO.SP_PARTICIONA_AUTOMATICO(TO_DATE(V_PERIODO,
                                                            'YYYYMM'),
                                                    'HM_VACACIONES',
                                                    'ODS',
                                                    'P_VACACIONES',
                                                    V_CODE_ERROR);
      IF V_CODE_ERROR = -1 THEN
         RAISE V_EXCEPTION;
      END IF;

      -- Proceso vacaciones
      SELECT COUNT(A.NU_PERI_MES)
        INTO V_CANT
        FROM ODS.HM_VACACIONES A
       WHERE A.NU_PERI_MES = V_PERIODO
         AND ROWNUM = 1;

      IF V_CANT > 0 THEN
        ODS.PKG_ODS_GENERICO.SP_TRUNCATE_PARTITION('ODS',
                                                   'HM_VACACIONES',
                                                   'P_VACACIONES_' ||
                                                   V_PERIODO,
                                                   V_ERROR);

         -- Regeneracion de Indices
         ODS.PKG_ODS_GENERICO.SP_REGENERA_INDICE('ODS','HM_VACACIONES',V_CODE_ERROR);
         --
       END IF;

     IF V_CODE_ERROR <> -1 THEN
       INSERT INTO ODS.HM_VACACIONES
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
               TRUNC(LAST_DAY(TO_CHAR(TO_DATE(V_PERIODO, 'YYYYMM'),
                                      'DD/MM/YYYY'))),
               NVL(U.NU_MES, 0),
               NVL(U.CO_USUARIO, '.'),
               NVL(U.NO_EMPLEADO, '.'),
               NVL(U.DE_CARG_EMPL, '.'),
               NVL(U.FE_INGRESO, to_date('01010001', 'DDMMYYYY')),
               NVL(U.NO_GERE_EMPL, '.'),
               NVL(U.NO_AGEN_EMPL, '.'),
               NVL(U.NO_CENT_COST, '.'),
               NVL(U.NO_OFIC_FUNC, '.'),
               NVL(U.NU_ANIO, 0),
               NVL(U.NU_DIAS_GOCE_VACA, 0),
               NVL(TO_DATE(U.FE_INIC_VACA, 'DD/MM/YYYY'),
                   TO_DATE('01010001', 'DDMMYYYY')),
               NVL(TO_DATE(U.FE_FIN_VACA, 'DD/MM/YYYY'),
                   TO_DATE('01010001', 'DDMMYYYY')),
               NVL(U.FE_ACTU_MES, TO_DATE('01010001', 'DDMMYYYY'))
          FROM STG.T_VACACIONES U;
      V_CIFRA_CONTROL := SQL%ROWCOUNT;
      COMMIT;
    ELSE
       V_CODE_ERROR    := -1;
       V_MENSAJE_ERROR := 'EL INDICE NO A SIDO REGENERADO';
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

      INSERT INTO DWHADM.CONTROL_ERROR (CO_ETL, NU_EJECUCION,  DE_ERROR, FE_ERROR)
            SELECT 100,
                   V_EJECUCION,
                   SUBSTR(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE, 1, 2000) ||
                   SUBSTR(V_MENSAJE_ERROR, 1, 4000),
                   SYSDATE
              FROM DUAL;
          COMMIT;

   END IF;

    IF V_ERROR = -1  THEN
        V_MENSAJE_ERROR := ' ERROR EN CARGA DE ARCHIVOS';
        RAISE V_EXCEPTION;
    END IF ;

    -- Elimina Papelera de ODS
    ODS.PKG_ODS_GENERICO.SP_ELIMINA_PAPELERA;
    --

    V_CODE_ERROR := 1;
    DWHADM.PKG_CONTROL_ETL.SP_CAMBIA_ESTADO_ETL(V_ETL_TIPO_ETL       => 100,
                                                V_ETL_NUM_EJECUCION  => V_EJECUCION,
                                                V_ETL_NUM_PROCESO    => V_NUM_PROCESO,
                                                V_ETL_CIFRA_CONTROL => V_CIFRA_CONTROL,
                                                V_ETL_ESTADO         => 'F', --- Fin
                                                V_ETL_CODE           => V_CODE_ERROR,
                                                V_ETL_MENSAJE        => V_MENSAJE_ERROR);

  EXCEPTION
    WHEN OTHERS THEN

      V_CODE_ERROR    := -1;
      V_MENSAJE_ERROR := 'DWHADM.PKG_SPC_ODS_CAPACIDAD_PLANTA.SP_LECTURA_ARCHIVO_ODS'||'-'||SQLERRM||'-'||V_MENSAJE_ERROR;

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

  END SP_LECTURA_ARCHIVO_ODS;

  ---------------------------------------------------------------------------------------------------------------------------------
  -- RESUMEN
  -- DescripciÃ³n : Carga de presolicitud de prestamos en las oficinas edyficar en el esquema ODS
  -- Fecha de CreaciÃ³n : 08/07/2014
  -- Autor : Diego Zegarra T.
  -- Tabla Destino : ODS.HD_PRESOLICITUD
  -- Tablas Fuentes: STG.T_PRESOLICITU
  -- Parametros  : V_FEC_INI: Fecha Inicio de Carga
  --               V_TIPO_EJECUCION: Variable R = Reproceso Mensual y C = Diario
  --               V_CODE_ERROR: Toma Valores como 1(Correcto) o -1(Incorrecto)
  --               V_MENSAJE_ERROR: Mensaje de Error Oracle
  -- Observacion : No aplica.
  ---------------------------------------------------------------------------------------------------------------------------------

  PROCEDURE SP_PRE_SOLICITUD_ODS(V_FEC_INI       IN VARCHAR2,
                                 V_TI_EJECUCION  IN VARCHAR2,
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

    V_NUM_PROCESO := 20;
    DWHADM.PKG_CONTROL_ETL.SP_CAMBIA_ESTADO_ETL(V_ETL_TIPO_ETL       => 110,
                                                V_ETL_NUM_EJECUCION  => V_EJECUCION,
                                                V_ETL_NUM_PROCESO    => V_NUM_PROCESO,
                                                V_ETL_CIFRA_CONTROL => V_CIFRA_CONTROL,
                                                V_ETL_ESTADO         => 'I',
                                                V_ETL_CODE           => V_CODE_ERROR,
                                                V_ETL_MENSAJE        => V_MENSAJE_ERROR);

    -- Se obtiene el periodo
    V_PERIODO := TO_CHAR(TO_DATE(V_FEC_INI, 'DD/MM/YYYY'), 'YYYYMM');

    SELECT COUNT(A.NU_PERI_MES)
      INTO V_CANT
      FROM ODS.HD_PRESOLICITUD A
     WHERE A.NU_PERI_MES = V_PERIODO
       AND ROWNUM = 1;

    -- Particionamiento automatico
    ODS.PKG_ODS_GENERICO.SP_PARTICIONA_AUTOMATICO(TO_DATE(V_PERIODO,'YYYYMM'),'HD_PRESOLICITUD','ODS','P_PRESOLICITUD',V_CODE_ERROR);
    --

    IF V_CODE_ERROR = -1 THEN
             RAISE V_EXCEPTION;
    END IF;

    -- Tomar en Cuenta que Si es R habra reproceso Mensual pero cuando aya C diaria
    IF V_TI_EJECUCION = 'R' THEN
       -- Reproceso mensual
       IF V_CANT > 0 THEN
       ODS.PKG_ODS_GENERICO.SP_TRUNCATE_PARTITION('ODS','HD_PRESOLICITUD','P_PRESOLICITUD_' ||V_PERIODO,V_CODE_ERROR);

       IF V_CODE_ERROR = -1 THEN
                 RAISE V_EXCEPTION;
       END IF;

       -- Reparador de indices
       ODS.PKG_ODS_GENERICO.SP_REGENERA_INDICE('ODS','HD_PRESOLICITUD',V_CODE_ERROR);
       --
       IF V_CODE_ERROR = -1 THEN
                 RAISE V_EXCEPTION;
       END IF;

     END IF;

 IF V_CODE_ERROR <> -1 THEN
   INSERT /*+ APPEND */
      INTO ODS.HD_PRESOLICITUD
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
         CO_ASIENTO,
         NU_OPERACION,
         NO_USUA_DESE_PLAT,
         CO_FUNC_DESE_PRES,
         DE_CARG_FUNC,
         TI_PRESOLICITUD,
         FE_ACTU_MES)
        SELECT v_periodo,
               TRUNC(LAST_DAY(TO_DATE(V_FEC_INI, 'DD/MM/YYYY'))) AS FE_ULTI_DIA_MES,
               NVL(B.FE_PROCESO, to_date('01010001', 'DDMMYYYY')),
               NVL(B.FE_HORA_INIC, to_date('01010001', 'DDMMYYYY')),
               NVL(B.FE_HORA_FIN, to_date('01010001', 'DDMMYYYY')),
               NVL(B.NU_SOLICITUD, 0),
               NVL(B.DE_ESTADO, '.'),
               NVL(B.CO_SUCURSAL, 0),
               NVL(B.NO_SUCU_ORIG, '.'),
               NVL(B.NU_ASIENTO, 0),
               NVL(B.NU_USUA_TOPA, 0),
               NVL(B.NO_USUARIO, '.'),
               NVL(B.DE_ASIENTO, '.'),
               NVL(B.NU_OPERACION, 0),
               NVL(B.NO_USUA_DESE_PLAT, '.'),
               NVL(B.CO_FUNC_DESE_PRES, 0),
               NVL(B.DE_CARG_FUNC, '.'),
               NVL(B.TI_PRESOLICITUD, '.'),
               NVL(B.FE_ACTU_MES, to_date('01010001', 'DDMMYYYY'))
          FROM STG.T_PRESOLICITUD B
          WHERE B.NU_PERI_MES = V_PERIODO;
           V_CIFRA_CONTROL:= SQL%ROWCOUNT;
          COMMIT;
        ELSE

        V_CODE_ERROR    := -1;
        V_MENSAJE_ERROR := 'EL INDICE NO A SIDO REGENERADO';
         IF V_CODE_ERROR = -1 THEN
             RAISE V_EXCEPTION;
         END IF;
  END IF;

  ELSE
      -- EjecuciÃ³n Diaria
      IF V_TI_EJECUCION = 'C' THEN
         IF V_CODE_ERROR <> -1 THEN

        INSERT /*+ APPEND */
        INTO ODS.HD_PRESOLICITUD
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
           CO_ASIENTO,
           NU_OPERACION,
           NO_USUA_DESE_PLAT,
           CO_FUNC_DESE_PRES,
           DE_CARG_FUNC,
           TI_PRESOLICITUD,
           FE_ACTU_MES)
          SELECT V_PERIODO,
                 TRUNC(LAST_DAY(TO_DATE(V_FEC_INI, 'DD/MM/YYYY'))) AS FE_ULTI_DIA_MES,
                 NVL(B.FE_PROCESO, to_date('01010001', 'DDMMYYYY')),
                 NVL(B.FE_HORA_INIC, to_date('01010001', 'DDMMYYYY')),
                 NVL(B.FE_HORA_FIN, to_date('01010001', 'DDMMYYYY')),
                 NVL(B.NU_SOLICITUD, 0),
                 NVL(B.DE_ESTADO, '.'),
                 NVL(B.CO_SUCURSAL, 0),
                 NVL(B.NO_SUCU_ORIG, '.'),
                 NVL(B.NU_ASIENTO, 0),
                 NVL(B.NU_USUA_TOPA, 0),
                 NVL(B.NO_USUARIO, '.'),
                 NVL(B.DE_ASIENTO, '.'),
                 NVL(B.NU_OPERACION, 0),
                 NVL(B.NO_USUA_DESE_PLAT, '.'),
                 NVL(B.CO_FUNC_DESE_PRES, 0),
                 NVL(B.DE_CARG_FUNC, '.'),
                 NVL(B.TI_PRESOLICITUD, '.'),
                 NVL(B.FE_ACTU_MES, to_date('01010001', 'DDMMYYYY'))
            FROM STG.T_PRESOLICITUD B;
           V_CIFRA_CONTROL := SQL%ROWCOUNT;
          COMMIT;
          ELSE
             V_CODE_ERROR    := -1;
             V_MENSAJE_ERROR := 'EL INDICE NO A SIDO REGENERADO';
              IF V_CODE_ERROR = -1 THEN
                 RAISE V_EXCEPTION;
              END IF;
          END IF;
       END IF ;
    END IF;

    -- Elimina Papelera de ODS
    ODS.PKG_ODS_GENERICO.SP_ELIMINA_PAPELERA;
    --

    V_CODE_ERROR := 1;
    DWHADM.PKG_CONTROL_ETL.SP_CAMBIA_ESTADO_ETL(V_ETL_TIPO_ETL       => 110,
                                                V_ETL_NUM_EJECUCION  => V_EJECUCION,
                                                V_ETL_NUM_PROCESO    => V_NUM_PROCESO,
                                                V_ETL_CIFRA_CONTROL => V_CIFRA_CONTROL,
                                                V_ETL_ESTADO         => 'F', --- Fin
                                                V_ETL_CODE           => V_CODE_ERROR,
                                                V_ETL_MENSAJE        => V_MENSAJE_ERROR);

  EXCEPTION
    WHEN OTHERS THEN

      V_CODE_ERROR    := -1;
      V_MENSAJE_ERROR := 'DWHADM.PKG_SPC_ODS_CAPACIDAD_PLANTA.SP_PRE_SOLICITUD_ODS'||'-'||SQLERRM||'-'||V_MENSAJE_ERROR;

      INSERT INTO DWHADM.CONTROL_ERROR
        (CO_ETL, NU_EJECUCION, DE_ERROR, FE_ERROR)
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


  END SP_PRE_SOLICITUD_ODS;
  ---------------------------------------------------------------------------------------------------------------------------------
  -- RESUMEN
  -- DescripciÃ³n : Carga de cobros o recaudaciones realizadas en el esquema ODS
  -- Fecha de CreaciÃ³n : 08/07/2014
  -- Autor : Diego Zegarra T.
  -- Tabla Destino : ODS.HD_COBRO
  -- Tablas Fuentes : STG.T_COBRO
  -- Parametros : V_FEC_INI: Fecha Inicio de Carga
  --              V_TI_EJECUCION: Tiene 2 opciones R= Reproceso y C: Diario
  --              V_CODE_ERROR: Toma Valores como 1(Correcto) o -1(Incorrecto)
  --              V_MENSAJE_ERROR: Mensaje de Error Oracle
  -- Observaciones : No aplica.
  ---------------------------------------------------------------------------------------------------------------------------------
  PROCEDURE SP_COBROS_ODS(V_FEC_INI       IN VARCHAR2,
                          V_TI_EJECUCION  IN VARCHAR2,
                          V_CODE_ERROR    OUT NUMBER,
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

    V_NUM_PROCESO := 20;
    DWHADM.PKG_CONTROL_ETL.SP_CAMBIA_ESTADO_ETL(V_ETL_TIPO_ETL       => 130,
                                                V_ETL_NUM_EJECUCION  => V_EJECUCION,
                                                V_ETL_NUM_PROCESO    => V_NUM_PROCESO,
                                                V_ETL_CIFRA_CONTROL => V_CIFRA_CONTROL,
                                                V_ETL_ESTADO         => 'I',
                                                V_ETL_CODE           => V_CODE_ERROR,
                                                V_ETL_MENSAJE        => V_MENSAJE_ERROR);


    -- Se captura el periodo
    V_PERIODO := TO_CHAR(TO_DATE(V_FEC_INI, 'DD/MM/YYYY'), 'YYYYMM');

    -- Particionamiento automatico
    ODS.PKG_ODS_GENERICO.SP_PARTICIONA_AUTOMATICO(TO_DATE(V_PERIODO,'YYYYMM'),'HD_COBRO','ODS','P_COBROS',V_CODE_ERROR);
    --

    IF V_CODE_ERROR = -1 THEN
             RAISE V_EXCEPTION;
    END IF;

    SELECT COUNT(A.NU_PERI_MES)
      INTO V_CANT
      FROM ODS.HD_COBRO A
     WHERE A.NU_PERI_MES = V_PERIODO
       AND ROWNUM = 1;

    IF V_TI_EJECUCION = 'R' THEN
      -- Trunca la particion si cumple con las condiciones
      IF V_CANT > 0 THEN
         ODS.PKG_ODS_GENERICO.SP_TRUNCATE_PARTITION('ODS','HD_COBRO','P_COBROS_' || V_PERIODO,V_CODE_ERROR);
         IF V_CODE_ERROR = -1 THEN
                 RAISE V_EXCEPTION;
         END IF;

        -- Reparador de indices
         ODS.PKG_ODS_GENERICO.SP_REGENERA_INDICE('ODS','HD_COBRO',V_CODE_ERROR);
         IF V_CODE_ERROR = -1 THEN
                 RAISE V_EXCEPTION;
         END IF;

      END IF;

    IF V_CODE_ERROR <> -1 THEN
      INSERT INTO ODS.HD_COBRO
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
        SELECT NVL(C.NU_PERI_MES, 0),
               TRUNC(LAST_DAY(TO_DATE(V_FEC_INI, 'DD/MM/YYYY'))) AS FE_ULTI_DIA_MES,
               NVL(C.FE_VALOR, to_date('01010001', 'DDMMYYYY')),
               NVL(C.CO_REGI_UNIC_APLI, 0),
               NVL(C.NU_PRESTAMO, 0),
               NVL(C.CO_CLIENTE, 0),
               NVL(C.NU_ASIE_PAGO, 0),
               NVL(C.CO_USUA_COBR, 0),
               NVL(C.CO_FUNC_COBR, 0),
               NVL(C.CO_SUCU_PAGO_CUOT, 0),
               NVL(C.NO_SUCU_PAGO_CUOT, '.'),
               NVL(C.CO_MONEDA, 0),
               NVL(C.MO_PAGO_CUOT, 0),
               NVL(C.MO_ITF_MOVI, 0),
               NVL(C.MO_OTRO_PAGO, 0),
               NVL(C.FE_HORA_PAGO, to_date('01010001', 'DDMMYYYY')),
               NVL(C.FE_PAGO, to_date('01010001', 'DDMMYYYY')),
               NVL(C.CO_SUCU_ORIG, 0),
               NVL(C.NO_SUCU_ORIG, '.'),
               NVL(C.NO_CANAL, '.'),
               NVL(C.CO_ANALISTA, 0),
               NVL(C.NO_ANALISTA, '.'),
               NVL(C.TI_OPERACION, 0),
               NVL(C.DE_OPERACION, '.'),
               NVL(C.NO_CARG_FUNC, '.'),
               NVL(C.MO_CAPI_PAGA, 0),
               NVL(C.MO_INTE_PAGA, 0),
               NVL(C.ST_CREDITO, '.'),
               NVL(C.MO_SALD_CORT, 0),
               NVL(C.ST_COBRO, '.'),
               NVL(C.CO_SUCU_OFIC_PRES, 0),
               NVL(C.NO_SUCU_OFIC_PRES, 0),
               NVL(C.FE_ACTU_MES, to_date('01010001', 'DDMMYYYY')),
               NVL(C.NU_SOLICITUD, 0),
               NVL(C.FE_PAGO_COBR, to_date('01010001', 'DDMMYYYY'))
          FROM STG.T_COBRO C
          WHERE C.NU_PERI_MES = V_PERIODO;
          V_CIFRA_CONTROL := SQL%ROWCOUNT;
          COMMIT;
          ELSE
            V_CODE_ERROR    := -1;
            V_MENSAJE_ERROR := 'EL INDICE NO A SIDO REGENERADO';
             IF V_CODE_ERROR = -1 THEN
                 RAISE V_EXCEPTION;
             END IF;
     END IF;
    -- Proceso que ejecuta de manera diaria el proceso
    ELSE
    IF V_TI_EJECUCION = 'C' THEN

      IF V_CODE_ERROR <>  -1 THEN
        INSERT INTO ODS.HD_COBRO
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
          SELECT NVL(C.NU_PERI_MES, 0),
                 TRUNC(LAST_DAY(TO_DATE(V_FEC_INI, 'DD/MM/YYYY'))) AS FE_ULTI_DIA_MES,
                 NVL(C.FE_VALOR, to_date('01010001', 'DDMMYYYY')),
                 NVL(C.CO_REGI_UNIC_APLI, 0),
                 NVL(C.NU_PRESTAMO, 0),
                 NVL(C.CO_CLIENTE, 0),
                 NVL(C.NU_ASIE_PAGO, 0),
                 NVL(C.CO_USUA_COBR, 0),
                 NVL(C.CO_FUNC_COBR, 0),
                 NVL(C.CO_SUCU_PAGO_CUOT, 0),
                 NVL(C.NO_SUCU_PAGO_CUOT, '.'),
                 NVL(C.CO_MONEDA, 0),
                 NVL(C.MO_PAGO_CUOT, 0),
                 NVL(C.MO_ITF_MOVI, 0),
                 NVL(C.MO_OTRO_PAGO, 0),
                 NVL(C.FE_HORA_PAGO, to_date('01010001', 'DDMMYYYY')),
                 NVL(C.FE_PAGO, to_date('01010001', 'DDMMYYYY')),
                 NVL(C.CO_SUCU_ORIG, 0),
                 NVL(C.NO_SUCU_ORIG, '.'),
                 NVL(C.NO_CANAL, '.'),
                 NVL(C.CO_ANALISTA, 0),
                 NVL(C.NO_ANALISTA, '.'),
                 NVL(C.TI_OPERACION, 0),
                 NVL(C.DE_OPERACION, '.'),
                 NVL(C.NO_CARG_FUNC, '.'),
                 NVL(C.MO_CAPI_PAGA, 0),
                 NVL(C.MO_INTE_PAGA, 0),
                 NVL(C.ST_CREDITO, '.'),
                 NVL(C.MO_SALD_CORT, 0),
                 NVL(C.ST_COBRO, '.'),
                 NVL(C.CO_SUCU_OFIC_PRES, 0),
                 NVL(C.NO_SUCU_OFIC_PRES, 0),
                 NVL(C.FE_ACTU_MES, to_date('01010001', 'DDMMYYYY')),
                 NVL(C.NU_SOLICITUD, 0),
                 NVL(C.FE_PAGO_COBR, to_date('01010001', 'DDMMYYYY'))
            FROM STG.T_COBRO C;
            V_CIFRA_CONTROL := SQL%ROWCOUNT;
            COMMIT;
            ELSE
              V_CODE_ERROR    := -1;
              V_MENSAJE_ERROR := 'EL INDICE NO A SIDO REGENERADO';
               IF V_CODE_ERROR = -1 THEN
                 RAISE V_EXCEPTION;
              END IF;
          END IF ;
      END IF;
    END IF;

    -- Elimina Papelera de ODS
    ODS.PKG_ODS_GENERICO.SP_ELIMINA_PAPELERA;
    --
    V_CODE_ERROR    := 1;
    DWHADM.PKG_CONTROL_ETL.SP_CAMBIA_ESTADO_ETL(V_ETL_TIPO_ETL       => 130,
                                                V_ETL_NUM_EJECUCION  => V_EJECUCION,
                                                V_ETL_NUM_PROCESO    => V_NUM_PROCESO,
                                                V_ETL_CIFRA_CONTROL => V_CIFRA_CONTROL,
                                                V_ETL_ESTADO         => 'F', --- Fin
                                                V_ETL_CODE           => V_CODE_ERROR,
                                                V_ETL_MENSAJE        => V_MENSAJE_ERROR);

  EXCEPTION
    WHEN OTHERS THEN

      V_CODE_ERROR    := -1;
      V_MENSAJE_ERROR := 'DWHADM.PKG_SPC_ODS_CAPACIDAD_PLANTA.SP_COBROS_ODS'||'-'||SQLERRM||'-'||V_MENSAJE_ERROR;

      INSERT INTO DWHADM.CONTROL_ERROR
        (CO_ETL, NU_EJECUCION,  DE_ERROR, FE_ERROR)
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


  END SP_COBROS_ODS;

  ------------------------------------------------------------------------------------------------------------
  -- RESUMEN
  -- DescripciÃ³n : Carga de desembolsos de prestamos realizados en el esquema ODS
  -- Fecha de CreaciÃ³n : 14/07/2014
  -- Autor : Diego Zegarra Torres - GORA SAC
  -- Tabla Destino :  ODS.HD_DESEMBOLSO
  -- Tablas Fuentes : STG.T_DESEMBOLSO
  -- Parametros : V_FEC_INI: Fecha de Inicio
  --              V_TI_EJECUCION: Puede ser C : Diaria o R:Reproceso
  --              V_CODE_ERROR: Toma Valores como 1(Correcto) o -1(Incorrecto)
  --              V_MENSAJE_ERROR: Mensaje de Error Oracle
  -- ObservaciÃ³n : No aplica.
  ------------------------------------------------------------------------------------------------------------
  PROCEDURE SP_DESEMBOLSO_ODS(V_FEC_INI       IN VARCHAR2,
                              V_TI_EJECUCION  IN VARCHAR2,
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

    V_NUM_PROCESO := 20;
    DWHADM.PKG_CONTROL_ETL.SP_CAMBIA_ESTADO_ETL(V_ETL_TIPO_ETL       => 120,
                                                V_ETL_NUM_EJECUCION  => V_EJECUCION,
                                                V_ETL_NUM_PROCESO    => V_NUM_PROCESO,
                                                V_ETL_CIFRA_CONTROL => V_CIFRA_CONTROL,
                                                V_ETL_ESTADO         => 'I',
                                                V_ETL_CODE           => V_CODE_ERROR,
                                                V_ETL_MENSAJE        => V_MENSAJE_ERROR);

    -- Se captura el periodo
    V_PERIODO := TO_CHAR(TO_DATE(V_FEC_INI, 'DD/MM/YYYY'), 'YYYYMM');

    SELECT COUNT(A.NU_PERI_MES)
      INTO V_CANT
      FROM ODS.HD_DESEMBOLSO A
     WHERE A.NU_PERI_MES = V_PERIODO
       AND ROWNUM = 1;

    -- Particionamiento automatico
    ODS.PKG_ODS_GENERICO.SP_PARTICIONA_AUTOMATICO(TO_DATE(V_PERIODO,'YYYYMM'),'HD_DESEMBOLSO','ODS','P_DESEMBOLSO',V_CODE_ERROR);
    IF V_CODE_ERROR = -1 THEN
         RAISE V_EXCEPTION;
    END IF;

    IF V_TI_EJECUCION = 'R' THEN
      -- Elimina particiones
      IF V_CANT > 0 THEN
       ODS.PKG_ODS_GENERICO.SP_TRUNCATE_PARTITION('ODS','HD_DESEMBOLSO','P_DESEMBOLSO_'||V_PERIODO,V_CODE_ERROR);
       IF V_CODE_ERROR = -1 THEN
               RAISE V_EXCEPTION;
       END IF;

       -- Reparador de indices
       ODS.PKG_ODS_GENERICO.SP_REGENERA_INDICE('ODS','HD_DESEMBOLSO',V_CODE_ERROR);
       IF V_CODE_ERROR = -1 THEN
               RAISE V_EXCEPTION;
       END IF;

   END IF;

    IF V_CODE_ERROR <> -1 THEN
      INSERT /*+ APPEND */
      INTO ODS.HD_DESEMBOLSO
        (NU_PERI_MES,
         FE_ULTI_DIA_MES,
         --@001 Ini: Se cambia el nombre de FE_VALOR a FE_APER_CUEN en la tabla ODS.HD_DESEMBOLSO
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
         --@002 Ini: Se agregan 6 campos nuevos a la tabla ODS.HD_DESEMBOLSO
		 NU_LINE_CRED,
		 MO_CUOTA,
		 NU_CUOTAS,
		 FE_DESEMBOLSO,
		 CO_REFINANCIACION,
		 CO_USUA_TOPA_DESE,
		 --@002 Fin
		 --@009 Ini: Se agregan 4 campos nuevos a la tabla ODS.HD_DESEMBOLSO
		 CO_ANALISTA, 
		 CO_PRODUCTO,
		 VL_TCEA,
		 NU_PLAZ_DIAS
		 --@009 Fin
	)
        SELECT NVL(T.NU_PERI_MES, 0),
               TRUNC(LAST_DAY(TO_DATE(V_FEC_INI, 'DD/MM/YYYY'))),
               --@003 Ini: Se selecciona el campo FE_APER_CUEN para la carga de la tabla ODS.HD_DESEMBOLSO
               NVL(T.FE_APER_CUEN, to_date('01010001', 'DDMMYYYY')),
               --@003 Fin
               NVL(T.NU_PRESTAMO, 0),
               NVL(T.CO_CLIENTE, 0),
               NVL(T.MO_APRO_DESE, 0),
               NVL(T.MO_DESEMBOLSADO, 0),
               NVL(T.DE_MONEDA, '.'),
               NVL(T.TI_DESEMBOLSO, '.'),
               NVL(T.MO_RECU_SALD, 0),
               NVL(T.MO_DESE_CAJA, 0),
               NVL(T.CO_SUCU_ORIG, 0),
               NVL(T.MO_SOLICITADO, 0),
               NVL(T.NU_DIA_PROG_PAGO, 0),
               NVL(T.NO_CLIENTE, '.'),
               NVL(T.NO_VIA_DESE_PLAT, '.'),
               NVL(T.NO_SUCU_ORIG, '.'),
               NVL(T.NU_ASIE_PLAT, 0),
               NVL(T.CO_USUA_DESE_PLAT, 0),
               NVL(T.CO_FUNC_DESE_PLAT, 0),
               NVL(T.NO_USUA_DESE_PLAT, '.'),
               NVL(T.CO_SUCU_DESE_PLAT, 0),
               NVL(T.NO_SUCU_DESE_PLAT, '.'),
               NVL(T.NU_ASIE_CAJA, 0),
               NVL(T.CO_USUA_DESE_CAJA, '.'),
               NVL(T.CO_FUNC_DESE_CAJA, 0),
               NVL(T.NO_USUA_DESE_CAJA, '.'),
               NVL(T.CO_SUCU_DESE_CAJA, 0),
               NVL(T.NO_SUCU_DESE_CAJA, '.'),
               NVL(T.FE_ACTU_MES, to_date('01010001', 'DDMMYYYY')),
               NVL(T.FE_DESE_PLAT, to_date('01010001', 'DDMMYYYY')),
               NVL(T.FE_DESE_CAJA, to_date('01010001', 'DDMMYYYY')),
               NVL(T.NU_SOLICITUD, 0),
               NVL(T.NU_PARTICIPANTES, 0),
               NVL(T.DE_CARG_USUA_PLAT, '.'),
               NVL(T.DE_CARG_USUA_CAJA, '.'),
               --@004 Ini: Se agregan 6 campos en el select para llenar la tabla ODS.HD_DESEMBOLSO
               NVL(T.NU_LINE_CRED, 0),
               NVL(T.MO_CUOTA, 0),
               NVL(T.NU_CUOTAS, 0),
               NVL(T.FE_DESEMBOLSO, to_date('01010001', 'DDMMYYYY')),
               NVL(T.CO_REFINANCIACION, '.'),
               NVL(T.CO_USUA_TOPA_DESE, '.'),
			   --@004 Fin
			   --@009 Ini: Se agregan 4 campos en el select para llenar la tabla ODS.HD_DESEMBOLSO
               NVL(T.COD_ANA, 0), 
               NVL(T.COD_PRO, 0),
               NVL(T.VL_TCEA, 0), 
               NVL(T.NU_PLA_DIAS, 0)
               --@009 Fin

          FROM STG.T_DESEMBOLSO T
          WHERE T.NU_PERI_MES = V_PERIODO;
        V_CIFRA_CONTROL := SQL%ROWCOUNT;
        COMMIT;
        ELSE
            V_CODE_ERROR    := -1;
            V_MENSAJE_ERROR := 'EL INDICE NO A SIDO REGENERADO';
            IF V_CODE_ERROR = -1 THEN
                 RAISE V_EXCEPTION;
            END IF;
     END IF ;
    ELSE
     IF V_TI_EJECUCION = 'C' THEN
        IF V_CODE_ERROR <> -1 THEN

        INSERT /*+ APPEND */
        INTO ODS.HD_DESEMBOLSO
          (NU_PERI_MES,
           FE_ULTI_DIA_MES,
          --@005 Ini: Se cambia el nombre de FE_VALOR a FE_APER_CUEN en la tabla ODS.HD_DESEMBOLSO
           FE_APER_CUEN,
          --@005 Fin
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
          --@006 Ini: Se agregan 6 campos nuevos a la tabla ODS.HD_DESEMBOLSO
           NU_LINE_CRED,
          --@006 Fin
           MO_CUOTA,
           NU_CUOTAS,
           FE_DESEMBOLSO,
           CO_REFINANCIACION,
		       CO_USUA_TOPA_DESE,
          --@009 Ini: Se agregan 4 campos nuevos a la tabla ODS.HD_DESEMBOLSO
           CO_ANALISTA, 
           CO_PRODUCTO,
           VL_TCEA,
           NU_PLAZ_DIAS
          --@009 Fin
)
          SELECT NVL(T.NU_PERI_MES, 0),
                 TRUNC(LAST_DAY(TO_DATE(V_FEC_INI, 'DD/MM/YYYY'))),
                 --@007 Ini: Se selecciona el campo FE_APER_CUEN para la carga de la tabla ODS.HD_DESEMBOLSO
                 NVL(T.FE_APER_CUEN, to_date('01010001', 'DDMMYYYY')),
                 --@007 Fin
                 NVL(T.NU_PRESTAMO, 0),
                 NVL(T.CO_CLIENTE, 0),
                 NVL(T.MO_APRO_DESE, 0),
                 NVL(T.MO_DESEMBOLSADO, 0),
                 NVL(T.DE_MONEDA, '.'),
                 NVL(T.TI_DESEMBOLSO, '.'),
                 NVL(T.MO_RECU_SALD, 0),
                 NVL(T.MO_DESE_CAJA, 0),
                 NVL(T.CO_SUCU_ORIG, 0),
                 NVL(T.MO_SOLICITADO, 0),
                 NVL(T.NU_DIA_PROG_PAGO, 0),
                 NVL(T.NO_CLIENTE, '.'),
                 NVL(T.NO_VIA_DESE_PLAT, '.'),
                 NVL(T.NO_SUCU_ORIG, '.'),
                 NVL(T.NU_ASIE_PLAT, 0),
                 NVL(T.CO_USUA_DESE_PLAT, 0),
                 NVL(T.CO_FUNC_DESE_PLAT, 0),
                 NVL(T.NO_USUA_DESE_PLAT, '.'),
                 NVL(T.CO_SUCU_DESE_PLAT, 0),
                 NVL(T.NO_SUCU_DESE_PLAT, '.'),
                 NVL(T.NU_ASIE_CAJA, 0),
                 NVL(T.CO_USUA_DESE_CAJA, '.'),
                 NVL(T.CO_FUNC_DESE_CAJA, 0),
                 NVL(T.NO_USUA_DESE_CAJA, '.'),
                 NVL(T.CO_SUCU_DESE_CAJA, 0),
                 NVL(T.NO_SUCU_DESE_CAJA, '.'),
                 NVL(T.FE_ACTU_MES, to_date('01010001', 'DDMMYYYY')),
                 NVL(T.FE_DESE_PLAT, to_date('01010001', 'DDMMYYYY')),
                 NVL(T.FE_DESE_CAJA, to_date('01010001', 'DDMMYYYY')),
                 NVL(T.NU_SOLICITUD, 0),
                 NVL(T.NU_PARTICIPANTES, 0),
                 NVL(T.DE_CARG_USUA_PLAT, '.'),
                 NVL(T.DE_CARG_USUA_CAJA, '.'),
                 --@008 Ini: Se agregan 6 campos en el select para llenar la tabla ODS.HD_DESEMBOLSO
                 NVL(T.NU_LINE_CRED, 0),
                 NVL(T.MO_CUOTA, 0),
                 NVL(T.NU_CUOTAS, 0),
                 NVL(T.FE_DESEMBOLSO, to_date('01010001', 'DDMMYYYY')),
                 NVL(T.CO_REFINANCIACION, '.'),
			     NVL(T.CO_USUA_TOPA_DESE, '.'),
				 --@008 Fin
                 --@009 Ini: Se agregan 4 campos en el select para llenar la tabla ODS.HD_DESEMBOLSO
				 NVL(T.COD_ANA, 0), 
				 NVL(T.COD_PRO, 0),
				 NVL(T.VL_TCEA, 0), 
				 NVL(T.NU_PLA_DIAS, 0)
				 --@009 Fin
            FROM STG.T_DESEMBOLSO T;
             V_CIFRA_CONTROL := SQL%ROWCOUNT;
             COMMIT;
             ELSE

                V_CODE_ERROR    := -1;
                V_MENSAJE_ERROR := 'EL INDICE NO A SIDO REGENERADO';
                IF V_CODE_ERROR = -1 THEN
                 RAISE V_EXCEPTION;
                END IF;
           END IF;
      END IF;
    END IF;

     -- Elimina Papelera de ODS
    ODS.PKG_ODS_GENERICO.SP_ELIMINA_PAPELERA;
    --

    V_CODE_ERROR := 1;

    DWHADM.PKG_CONTROL_ETL.SP_CAMBIA_ESTADO_ETL(V_ETL_TIPO_ETL       => 120,
                                                V_ETL_NUM_EJECUCION  => V_EJECUCION,
                                                V_ETL_NUM_PROCESO    => V_NUM_PROCESO,
                                                V_ETL_CIFRA_CONTROL => V_CIFRA_CONTROL,
                                                V_ETL_ESTADO         => 'F', --- Fin
                                                V_ETL_CODE           => V_CODE_ERROR,
                                                V_ETL_MENSAJE        => V_MENSAJE_ERROR);

  EXCEPTION
    WHEN OTHERS THEN

     V_CODE_ERROR    := -1;
     V_MENSAJE_ERROR := 'DWHADM.PKG_SPC_ODS_CAPACIDAD_PLANTA.SP_DESEMBOLSO_ODS'||'-'||SQLERRM||'-'||V_MENSAJE_ERROR;

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

  END SP_DESEMBOLSO_ODS;

end PKG_SPC_ODS_CAPACIDAD_PLANTA;
/
