CREATE OR REPLACE PACKAGE BODY DWHADM.PKG_GEN_STG_BASE_INTERNA
------------------------------------------------------------------------------------------------------------
-- RESUMEN
-- Proyecto : MIBCO-BI EGP, EGD
-- Nombre :  DWHADM.PKG_GEN_STG_BASE_INTERNA
-- Autor : Guillermo P�rez Cea
-- Fecha de Creaci�n : 15/03/2016
-- Descripci�n : Componentes gen�ricos usados en el esquema STG y ODS a traves de los ETLS.
------------------------------------------------------------------------------------------------------------
-- Modificaciones
-- Requerimiento Responsable Fecha Descripci�n
------------------------------------------------------------------------------------------------------------
IS

----------------------------------------------------------------------------------------------------------------------------------
-- RESUMEN
-- Descripci�n: Funcion que dada la etapa, fase y subfase del ETL , obtiene las tablas y sus respectivos esquemas a truncar para dicho paso y las trunca.
-- Fecha de Creaci�n: 24/02/2016
-- Autor: Guillermo P�rez Cea
-- Tabla Destino: N/A
-- Tablas Fuentes: ODS.T_TABLAS_TRUNCO_RETOMA
-- Par�metros:
--         ENTRADA
--               V_ETAPA: Etapa de ejecuci�n del proceso.
--              V_FASE: Fase de ejecuci�n del proceso.
--               V_SUBFASE: Sub-fase de ejecuci�n del proceso.
--         SALIDA
--               V_STATUS: Resultado de la ejecuci�n.
-- Observaci�n: Se invocar� ODS.PKG_ODS_GENERICO.SP_TRUNCATE_TABLE
----------------------------------------------------------------------------------------------------------------------------------
FUNCTION FN_TRUNCO_TABLAS_RETOMA_ODS(V_ETAPA IN NUMBER,
                             V_FASE IN NUMBER,
                             V_SUBFASE IN NUMBER)
RETURN NUMBER
IS
V_STATUS_X_TABLA NUMBER;
V_STATUS NUMBER;
V_MENSAJE_ERROR VARCHAR2 (200);

CURSOR TABLAS_TRUNCAR
IS
  SELECT TTR.DE_NOMBREFISICO AS DE_NOMBREFISICO,
       TTR.ESQUEMA_TABLA AS ESQUEMA
  FROM   ODS.T_TABLAS_TRUNCO_RETOMA TTR
  WHERE      TTR.ID_ETAPA=V_ETAPA AND
        TTR.ID_FASE=V_FASE   AND
        TTR.ID_SUBFASE=V_SUBFASE;
BEGIN
--INICIALIZAMOS VARIABLES
V_STATUS_X_TABLA:=1; --CASO V_STATUS_X_TABLA = -1 error en SP CASO V_STATUS_X_TABLA = 1 SP corrio correctamente (NO CAMBIA EL ESTADO INICIAL DE LA VARIABLE EN ESTE ULTIMO CASO)
V_STATUS:=1; --CASO SP TRUNCO CORRECTAMENTE (NO CAMBIA EL ESTADO INICIAL DE LA VARIABLE EN ESTE CASO)
  FOR NOMTABLA_REC IN TABLAS_TRUNCAR
  LOOP
      ODS.PKG_ODS_GENERICO.SP_TRUNCATE_TABLE(NOMTABLA_REC.ESQUEMA,NOMTABLA_REC.DE_NOMBREFISICO,V_STATUS_X_TABLA,V_MENSAJE_ERROR);
      IF(V_STATUS_X_TABLA=-1) THEN
        --CASO ERROR EN SP -> V_STATUS GRAL = -1
        V_STATUS:=-1;
      END IF;
  END LOOP;
  RETURN V_STATUS;
  EXCEPTION
             WHEN OTHERS THEN
       --CASO ERROR EJECUCION SP y CURSOR NO TIENE REGISTROS
       V_STATUS:=2;
  RETURN V_STATUS;  --(1:Correcto , -1:Error truncando, -2:Error de datos cursor )
END FN_TRUNCO_TABLAS_RETOMA_ODS;

------------------------------------------------------------------------------------------------------------
-- RESUMEN
-- Descripci�n: Funcion que dada la etapa, fase y subfase del ETL , obtiene las tablas y sus respectivos esquemas a truncar para dicho paso y las trunca.
-- Fecha de Creaci�n: 24/02/2016
-- Autor: Guillermo P�rez Cea
-- Tabla Destino: N/A
-- Tablas Fuentes: STG.T_TABLAS_TRUNCO_RETOMA
-- Par�metros:
--         ENTRADA
--               V_ETAPA: Etapa de ejecuci�n del proceso.
--              V_FASE: Fase de ejecuci�n del proceso.
--               V_SUBFASE: Sub-fase de ejecuci�n del proceso.
--         SALIDA
--               V_STATUS: Resultado de la ejecuci�n.
-- Observaci�n: Se invocar� STG.PKG_STG_GENERICO.SP_TRUNCATE_TABLE
------------------------------------------------------------------------------------------------------------
FUNCTION FN_TRUNCO_TABLAS_RETOMA_STG(V_ETAPA IN NUMBER,
                   V_FASE IN NUMBER,
                   V_SUBFASE IN NUMBER)
RETURN NUMBER
IS
V_STATUS_X_TABLA NUMBER;
V_STATUS NUMBER;

CURSOR TABLAS_TRUNCAR
IS
  SELECT TTR.DE_NOMBREFISICO AS DE_NOMBREFISICO,
       TTR.ESQUEMA_TABLA AS ESQUEMA
  FROM   STG.T_TABLAS_TRUNCO_RETOMA TTR
  WHERE      TTR.ID_ETAPA=V_ETAPA AND
        TTR.ID_FASE=V_FASE   AND
        TTR.ID_SUBFASE=V_SUBFASE;
BEGIN
--INICIALIZAMOS VARIABLES
V_STATUS_X_TABLA:=1; --CASO V_STATUS_X_TABLA = -1 error en SP CASO V_STATUS_X_TABLA = 1 SP corrio correctamente (NO CAMBIA EL ESTADO INICIAL DE LA VARIABLE EN ESTE ULTIMO CASO)
V_STATUS:=1; --CASO SP TRUNCO CORRECTAMENTE (NO CAMBIA EL ESTADO INICIAL DE LA VARIABLE EN ESTE CASO)
  FOR NOMTABLA_REC IN TABLAS_TRUNCAR
  LOOP
      STG.PKG_STG_GENERICO.SP_TRUNCATE_TABLE(NOMTABLA_REC.ESQUEMA,NOMTABLA_REC.DE_NOMBREFISICO,V_STATUS_X_TABLA);
      IF(V_STATUS_X_TABLA=-1) THEN
        --CASO ERROR EN SP -> V_STATUS GRAL = -1
        V_STATUS:=-1;
      END IF;
  END LOOP;
  RETURN V_STATUS;
  EXCEPTION
             WHEN OTHERS THEN
       --CASO ERROR EJECUCION SP y CURSOR NO TIENE REGISTROS
       V_STATUS:=2;
  RETURN V_STATUS;  --(1:Correcto , -1:Error truncando, -2:Error de datos cursor )
END FN_TRUNCO_TABLAS_RETOMA_STG;
------------------------------------------------------------------------------------------------------------

-- RESUMEN
-- Descripci�n: Funcion que dada la etapa, fase y subfase del ETL , obtiene las tablas y sus respectivos esquemas a truncar para dicho paso y las trunca.
-- Fecha de Creaci�n: 27/05/2020
-- Autor: Ciprian Huaquisto Colqui
-- Tabla Destino: N/A
-- Tablas Fuentes: BDS.T_TABLAS_TRUNCO_RETOMA
-- Par�metros:
--         ENTRADA
--              V_ETAPA: Etapa de ejecuci�n del proceso.
--              V_FASE: Fase de ejecuci�n del proceso.
--              V_SUBFASE: Sub-fase de ejecuci�n del proceso.
--         SALIDA
--              V_STATUS: Resultado de la ejecuci�n.
-- Observaci�n: Se invocar� BDS.PKG_STG_GENERICO.SP_TRUNCATE_TABLE
------------------------------------------------------------------------------------------------------------
FUNCTION FN_TRUNCO_TABLAS_RETOMA_BDS(V_ETAPA IN NUMBER,
                   V_FASE IN NUMBER,
                   V_SUBFASE IN NUMBER)
RETURN NUMBER
IS
V_STATUS_X_TABLA NUMBER;
V_STATUS NUMBER;
V_MENSAJE_ERROR VARCHAR2(500);

CURSOR TABLAS_TRUNCAR
IS
  SELECT TTR.DE_NOMBREFISICO AS DE_NOMBREFISICO,
       TTR.ESQUEMA_TABLA AS ESQUEMA
  FROM   BDS.T_TABLAS_TRUNCO_RETOMA TTR
  WHERE      TTR.ID_ETAPA=V_ETAPA AND
        TTR.ID_FASE=V_FASE   AND
        TTR.ID_SUBFASE=V_SUBFASE;
BEGIN
--INICIALIZAMOS VARIABLES
V_STATUS_X_TABLA:=1;
V_STATUS:=1;
  FOR NOMTABLA_REC IN TABLAS_TRUNCAR
  LOOP
      BDS.PKG_BDS_GENERICO.SP_TRUNCATE_TABLE( NOMTABLA_REC.ESQUEMA, NOMTABLA_REC.DE_NOMBREFISICO, V_STATUS_X_TABLA, V_MENSAJE_ERROR);

      IF(V_STATUS_X_TABLA=-1) THEN
        V_STATUS:=-1;
      END IF;
  END LOOP;
  RETURN V_STATUS;
  EXCEPTION
             WHEN OTHERS THEN
       --CASO ERROR EJECUCION SP y CURSOR NO TIENE REGISTROS
       V_STATUS:=2;
  RETURN V_STATUS;  --(1:Correcto , -1:Error truncando, -2:Error de datos cursor )
END FN_TRUNCO_TABLAS_RETOMA_BDS;
------------------------------------------------------------------------------------------------------------
END PKG_GEN_STG_BASE_INTERNA;
/
