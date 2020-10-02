CREATE OR REPLACE PACKAGE DWHADM.PKG_GEN_STG_BASE_INTERNA
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
RETURN NUMBER;

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
RETURN NUMBER;
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
RETURN NUMBER;
------------------------------------------------------------------------------------------------------------
END PKG_GEN_STG_BASE_INTERNA;
/
