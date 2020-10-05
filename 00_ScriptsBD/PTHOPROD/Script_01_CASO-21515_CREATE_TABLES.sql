--TOPAZ ETL
--===============
CREATE TABLE TOPAZETL.PARAMETROS_CARGA_BDS
(
  FECHAPROCESO      DATE,
  ESTADO_CARGA      VARCHAR2(1),
  CODIGO            VARCHAR2(3),
  DESCRIPCION_CARGA VARCHAR2(250),
  TZ_LOCK           NUMBER(15) DEFAULT (0),
  CONSTRAINT PK_PARAMETROS_CARGA_BDS PRIMARY KEY (FECHAPROCESO, CODIGO)
)
TABLESPACE TOPAZETL_DATA_01
  PCTFREE 10
  INITRANS 1
  MAXTRANS 255
  STORAGE
  (
    INITIAL 64K
    NEXT 1M
    MINEXTENTS 1
    MAXEXTENTS UNLIMITED
  );
-- ADD COMMENTS TO THE TABLE
COMMENT ON TABLE TOPAZETL.PARAMETROS_CARGA_BDS
  IS 'BITACORA DE ESTADO DE CARGA ETL POR FECHAPROCESO Y CODIGO DE DATAMART';
-- ADD COMMENTS TO THE COLUMNS
COMMENT ON COLUMN TOPAZETL.PARAMETROS_CARGA_BDS.FECHAPROCESO
  IS 'FECHA PROCESO DE ETL PARA DATAMARTS';
COMMENT ON COLUMN TOPAZETL.PARAMETROS_CARGA_BDS.ESTADO_CARGA
  IS 'ESTADO DE LA CARGA DEL ETL PARA DATAMARTS';
COMMENT ON COLUMN TOPAZETL.PARAMETROS_CARGA_BDS.CODIGO
  IS 'CODIGO DEL DATAMART';
COMMENT ON COLUMN TOPAZETL.PARAMETROS_CARGA_BDS.DESCRIPCION_CARGA
  IS 'DESCRIPCION DE LA CARGA ETL PARA DATAMARTS';