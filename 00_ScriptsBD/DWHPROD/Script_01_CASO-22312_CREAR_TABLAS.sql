-- ======================
-- Creacion Tabla Externa
-- ======================
---STG.DE_CANAL_COBRANZA
CREATE TABLE STG.DE_CANAL_COBRANZA
(
  PER_PRO        VARCHAR2(256),
  COD_PRE        VARCHAR2(256),
  CAN_REC        VARCHAR2(256),
  CAN_COB        VARCHAR2(256),
  USU_FIN        VARCHAR2(256)
)
ORGANIZATION EXTERNAL
(
  TYPE ORACLE_LOADER
  DEFAULT DIRECTORY DIR_IN_DE_RIE
  ACCESS PARAMETERS
  (
    RECORDS DELIMITED BY NEWLINE
    SKIP 1
    BADFILE '%a_%p.bad'
    LOGFILE '%a_%p.log'
    NOLOGFILE
    FIELDS TERMINATED BY '|' LRTRIM
    MISSING FIELD VALUES ARE NULL
    REJECT ROWS WITH ALL NULL FIELDS
  )
  location (DIR_IN_DE_RIE:'DE_CANAL_COBRANZA.csv')
)
reject limit UNLIMITED;

---STG.DE_CIERRE_32
CREATE  TABLE STG.DE_CIERRE_32
(
  FEC_PROCESO    VARCHAR2(256),
  NRO_PRESTAMO   VARCHAR2(256),
  CODFUN_INICIO  VARCHAR2(256),
  CODAGE_INICIO  VARCHAR2(256),
  CODFUN_CIERRE  VARCHAR2(256),
  CODAGE_CIERRE  VARCHAR2(256)
)
ORGANIZATION EXTERNAL
(
  TYPE ORACLE_LOADER
  DEFAULT DIRECTORY DIR_IN_DE_RIE
  ACCESS PARAMETERS
  (
    RECORDS DELIMITED BY NEWLINE
    SKIP 1
    BADFILE '%a_%p.bad'
    LOGFILE '%a_%p.log'
    NOLOGFILE
    FIELDS TERMINATED BY '|' LRTRIM
    MISSING FIELD VALUES ARE NULL
    REJECT ROWS WITH ALL NULL FIELDS
  )
  location (DIR_IN_DE_RIE:'DE_CIERRE_32.csv')
)
reject limit UNLIMITED;


-- ======================
-- Creacion Tabla Staging
-- ======================

-- Create table STG.T_CANAL_COBRANZA
create table STG.T_CANAL_COBRANZA
(
  PER_PRO        NUMBER(6) DEFAULT (0),
  COD_PRE        NUMBER(15) DEFAULT (0),
  CAN_REC        VARCHAR2(30) DEFAULT ('.'),
  CAN_COB        VARCHAR2(30) DEFAULT ('.'),
  USU_FIN        VARCHAR2(30) DEFAULT ('.'),
  FE_ACTU_DIA    DATE
)
tablespace STG_DATA_01;


-- ADD COMMENTS TO THE TABLE 
COMMENT ON TABLE STG.T_CANAL_COBRANZA IS 'TABLA STAGING QUE CONTIENE INFORMACION DEL DATA ENTRY DE CANALES DE COBRANZA.';
-- ADD COMMENTS TO THE COLUMNS 
COMMENT ON COLUMN STG.T_CANAL_COBRANZA.PER_PRO IS 'NUMERO DE PERIODO DE LA ASIGNACION. SE GENERA A PARTIR DEL AÑO Y MES DE LA FECHA EN FORMATO YYYYMM.';
COMMENT ON COLUMN STG.T_CANAL_COBRANZA.COD_PRE IS 'NUMERO DEL PRESTAMO.';
COMMENT ON COLUMN STG.T_CANAL_COBRANZA.CAN_REC IS 'DESCRIPCION DEL CANAL DE RECUPERACIONES.';
COMMENT ON COLUMN STG.T_CANAL_COBRANZA.CAN_COB IS 'DESCRIPCION DEL CANAL DE COBRANZAS.';
COMMENT ON COLUMN STG.T_CANAL_COBRANZA.USU_FIN IS 'NOMBRE DEL FUNCIONARIO DE COBRANZA/ESTUDIO LEGAL.';

-----CREATE TABLE STG.T_CIERRE_32
CREATE TABLE STG.T_CIERRE_32
(
  FEC_PROCESO    DATE,
  NRO_PRESTAMO   NUMBER(15),
  CODFUN_INICIO  NUMBER,
  CODAGE_INICIO  NUMBER,
  CODFUN_CIERRE  NUMBER,
  CODAGE_CIERRE  NUMBER,
  FE_ACTU_DIA    DATE
)
tablespace STG_DATA_01;

-- ADD COMMENTS TO THE TABLE 
COMMENT ON TABLE STG.T_CIERRE_32 IS 'TABLA STAGING QUE CONTIENE INFORMACION DEL CIERRE 32.';
-- ADD COMMENTS TO THE COLUMNS 
COMMENT ON COLUMN STG.T_CIERRE_32.FEC_PROCESO  IS 'FECHA EN LA CUAL SE ESTA INGRESANDO EL REGISTRO EN EL ARCHIVO FUENTE.';
COMMENT ON COLUMN STG.T_CIERRE_32.NRO_PRESTAMO IS 'NUMERO DEL PRESTAMO.';
COMMENT ON COLUMN STG.T_CIERRE_32.CODFUN_INICIO IS 'CODIGO DEL FUNCIONARIO INICIAL .';
COMMENT ON COLUMN STG.T_CIERRE_32.CODAGE_INICIO IS 'CODIGO DE LA AGENCIA INICIAL.';
COMMENT ON COLUMN STG.T_CIERRE_32.CODFUN_CIERRE IS 'CODIGO DEL FUNCIONARIO DE CIERRE DEL PERIODO ANTERIOR.';
COMMENT ON COLUMN STG.T_CIERRE_32.CODAGE_CIERRE  IS 'CODIGO DE LA AGENCIA DE CIERRE DEL PERIODO ANTERIOR.';


-- ======================
-- Creacion Tabla ODS
-- ======================
---CREATE TABLE ODS.HM_CANAL_COBRANZA
CREATE TABLE ODS.HM_CANAL_COBRANZA
(  
  NU_PERI_MES     NUMBER(6)    DEFAULT (0),
  NU_PRESTAMO     NUMBER(15)   DEFAULT (0),
  DE_CANA_RECU    VARCHAR2(30) DEFAULT ('.'),
  DE_CANA_COBR    VARCHAR2(30) DEFAULT ('.'),
  NO_USUA_FINA    VARCHAR2(30) DEFAULT ('.'),
  FE_ACTU_MES     DATE         DEFAULT SYSDATE,
  CO_ACTU_USER    VARCHAR2(50)  DEFAULT USER,
  NU_CARGA        INTEGER,
  IN_ESTA_REGI    INTEGER     DEFAULT 0 
)
PARTITION BY RANGE (NU_PERI_MES)
(
 PARTITION P_CANAL_COBRANZA_201401 VALUES LESS THAN (201402)   TABLESPACE ODS_DATA_01,
 PARTITION P_CANAL_COBRANZA_MAX    VALUES LESS THAN (MAXVALUE) TABLESPACE ODS_DATA_01
);

-- ADD COMMENTS TO THE TABLE 
COMMENT ON TABLE ODS.HM_CANAL_COBRANZA IS 'TABLA HISTORICA MENSUAL DE CANAL COBRANZA.';
-- ADD COMMENTS TO THE COLUMNS 
COMMENT ON COLUMN ODS.HM_CANAL_COBRANZA.NU_PERI_MES        IS 'NUMERO DE PERIODO DE LA ASIGNACION. SE GENERA A PARTIR DEL AÑO Y MES DE LA FECHA EN FORMATO YYYYMM.';
COMMENT ON COLUMN ODS.HM_CANAL_COBRANZA.NU_PRESTAMO        IS 'NUMERO DE PRESTAMO.';
COMMENT ON COLUMN ODS.HM_CANAL_COBRANZA.DE_CANA_RECU       IS 'DESCRIPCION DEL CANAL DE RECUPERACIONES.';
COMMENT ON COLUMN ODS.HM_CANAL_COBRANZA.DE_CANA_COBR       IS 'DESCRIPCION DEL CANAL DE COBRANZAS.';
COMMENT ON COLUMN ODS.HM_CANAL_COBRANZA.NO_USUA_FINA       IS 'NOMBRE DEL FUNCIONARIO DE COBRANZA/ESTUDIO LEGAL.';
COMMENT ON COLUMN ODS.HM_CANAL_COBRANZA.FE_ACTU_MES        IS 'FECHA DE ACTUALIZACION MENSUAL DE LA TABLA.';
COMMENT ON COLUMN ODS.HM_CANAL_COBRANZA.CO_ACTU_USER       IS 'USUARIO DE CARGA AL DWH.';
COMMENT ON COLUMN ODS.HM_CANAL_COBRANZA.NU_CARGA           IS 'NUMERO IDENTIFICADOR DE CARGA DWH.';
COMMENT ON COLUMN ODS.HM_CANAL_COBRANZA.IN_ESTA_REGI       IS 'ESTADO DEL REGISTRO.';

---CREATE  TABLE ODS.HM_CIERRE_32

CREATE  TABLE ODS.HM_CIERRE_32
(  
  NU_PERI_MES     NUMBER(6) DEFAULT (0),
  NU_PRESTAMO     NUMBER(15) DEFAULT (0),
  CO_FUNC_INIC    NUMBER(8) DEFAULT (0),
  CO_AGEN_INIC    NUMBER(6) DEFAULT (0),
  CO_FUNC_CIER    NUMBER(8) DEFAULT (0),
  CO_AGEN_CIER    NUMBER(6) DEFAULT (0),
  FE_ACTU_MES     DATE   DEFAULT SYSDATE,
  CO_ACTU_USER    VARCHAR2(50)  DEFAULT USER,
  NU_CARGA        INTEGER,
  IN_ESTA_REGI    INTEGER     DEFAULT 0 
)
PARTITION BY RANGE (NU_PERI_MES)
(
 PARTITION P_CIERRE_32_201401 VALUES LESS THAN (201402)   TABLESPACE ODS_DATA_01,
 PARTITION P_CIERRE_32_MAX    VALUES LESS THAN (MAXVALUE) TABLESPACE ODS_DATA_01
);

-- ADD COMMENTS TO THE TABLE 
COMMENT ON TABLE ODS.HM_CIERRE_32 IS 'TABLA HISTORICA MENSUAL DE CIERRE 32.';
-- ADD COMMENTS TO THE COLUMNS 
COMMENT ON COLUMN ODS.HM_CIERRE_32.NU_PERI_MES        IS 'NUMERO DE PERIODO DE LA ASIGNACION. SE GENERA A PARTIR DEL AÑO Y MES DE LA FECHA EN FORMATO YYYYMM.';
COMMENT ON COLUMN ODS.HM_CIERRE_32.NU_PRESTAMO        IS 'NUMERO DE PRESTAMO.';
COMMENT ON COLUMN ODS.HM_CIERRE_32.CO_FUNC_INIC       IS 'CODIGO DEL FUNCIONARIO INICIAL.';
COMMENT ON COLUMN ODS.HM_CIERRE_32.CO_AGEN_INIC       IS 'CODIGO DE LA AGENCIA INICIAL.';
COMMENT ON COLUMN ODS.HM_CIERRE_32.CO_FUNC_CIER       IS 'CODIGO DEL FUNCIONARIO DE CIERRE DEL PERIODO ANTERIOR.';
COMMENT ON COLUMN ODS.HM_CIERRE_32.CO_AGEN_CIER       IS 'CODIGO DE LA AGENCIA DE CIERRE DEL PERIODO ANTERIOR.';
COMMENT ON COLUMN ODS.HM_CIERRE_32.FE_ACTU_MES        IS 'FECHA DE ACTUALIZACION MENSUAL DE LA TABLA.';
COMMENT ON COLUMN ODS.HM_CIERRE_32.CO_ACTU_USER       IS 'USUARIO DE CARGA AL DWH.';
COMMENT ON COLUMN ODS.HM_CIERRE_32.NU_CARGA           IS 'NUMERO IDENTIFICADOR DE CARGA DWH.';
COMMENT ON COLUMN ODS.HM_CIERRE_32.IN_ESTA_REGI       IS 'ESTADO DEL REGISTRO.';

-- ======================
-- Creacion Tabla BDS
-- ======================
---CREATE TABLE BDS.L_RIE_CANAL_COBRANZ
CREATE TABLE BDS.L_RIE_CANAL_COBRANZA
(  
  NU_PERI_MES    NUMBER(6)    DEFAULT (0),
  NU_PRESTAMO    NUMBER(15)   DEFAULT (0),
  DE_CANA_COBR   VARCHAR2(30) DEFAULT ('.'),
  DE_CANA_RECU   VARCHAR2(30) DEFAULT ('.'),
  NO_USUA_FINA   VARCHAR2(30) DEFAULT ('.'),
  FE_ACTU_MES    DATE         DEFAULT SYSDATE,
  CO_ACTU_USER   VARCHAR2(50)  DEFAULT USER,
  NU_CARGA       INTEGER,
  IN_ESTA_REGI   INTEGER     DEFAULT 0 
)
PARTITION BY RANGE (NU_PERI_MES)
(
 PARTITION P_RIE_CANAL_COBRANZA_201401 VALUES LESS THAN (201402)   TABLESPACE BDS_DATA_01,
 PARTITION P_RIE_CANAL_COBRANZA_MAX    VALUES LESS THAN (MAXVALUE) TABLESPACE BDS_DATA_01
);

-- ADD COMMENTS TO THE TABLE 
COMMENT ON TABLE BDS.L_RIE_CANAL_COBRANZA IS 'TABLA LISTADO DE CANAL COBRANZA.';
-- ADD COMMENTS TO THE COLUMNS 
COMMENT ON COLUMN BDS.L_RIE_CANAL_COBRANZA.NU_PERI_MES   IS 'NUMERO DE PERIODO DE LA ASIGNACION. SE GENERA A PARTIR DEL AÑO Y MES DE LA FECHA EN FORMATO YYYYMM.';
COMMENT ON COLUMN BDS.L_RIE_CANAL_COBRANZA.NU_PRESTAMO   IS 'NUMERO DE PRESTAMO.';
COMMENT ON COLUMN BDS.L_RIE_CANAL_COBRANZA.DE_CANA_RECU  IS 'DESCRIPCION DEL CANAL DE RECUPERACIONES.';
COMMENT ON COLUMN BDS.L_RIE_CANAL_COBRANZA.DE_CANA_COBR  IS 'DESCRIPCION DEL CANAL DE COBRANZAS.';
COMMENT ON COLUMN BDS.L_RIE_CANAL_COBRANZA.NO_USUA_FINA  IS 'NOMBRE DEL FUNCIONARIO DE COBRANZA/ESTUDIO LEGAL.';
COMMENT ON COLUMN BDS.L_RIE_CANAL_COBRANZA.FE_ACTU_MES   IS 'FECHA DE ACTUALIZACION MENSUAL DE LA TABLA.';
COMMENT ON COLUMN BDS.L_RIE_CANAL_COBRANZA.CO_ACTU_USER  IS 'USUARIO DE CARGA AL DWH.';
COMMENT ON COLUMN BDS.L_RIE_CANAL_COBRANZA.NU_CARGA      IS 'NUMERO IDENTIFICADOR DE CARGA DWH.';
COMMENT ON COLUMN BDS.L_RIE_CANAL_COBRANZA.IN_ESTA_REGI  IS 'ESTADO DEL REGISTRO.';

---CREATE  TABLE BDS.L_RIE_CIERRE_32

CREATE  TABLE BDS.L_RIE_CIERRE_32
(  
  NU_PERI_MES     NUMBER(6) DEFAULT (0),
  NU_PRESTAMO     NUMBER(15) DEFAULT (0),
  CO_FUNC_INIC    NUMBER(8) DEFAULT (0),
  CO_AGEN_INIC    NUMBER(6) DEFAULT (0),
  CO_FUNC_CIER    NUMBER(8) DEFAULT (0),
  CO_AGEN_CIER    NUMBER(6) DEFAULT (0),
  FE_ACTU_MES     DATE   DEFAULT SYSDATE,
  CO_ACTU_USER    VARCHAR2(50)  DEFAULT USER,
  NU_CARGA        INTEGER,
  IN_ESTA_REGI    INTEGER     DEFAULT 0 
)
PARTITION BY RANGE (NU_PERI_MES)
(
 PARTITION P_RIE_CIERRE_32_201401 VALUES LESS THAN (201402)   TABLESPACE BDS_DATA_01,
 PARTITION P_RIE_CIERRE_32_MAX    VALUES LESS THAN (MAXVALUE) TABLESPACE BDS_DATA_01
);

-- ADD COMMENTS TO THE TABLE 
COMMENT ON TABLE BDS.L_RIE_CIERRE_32 IS 'TABLA HISTORICA MENSUAL DE CIERRE 32.';
-- ADD COMMENTS TO THE COLUMNS 
COMMENT ON COLUMN BDS.L_RIE_CIERRE_32.NU_PERI_MES        IS 'NUMERO DE PERIODO DE LA ASIGNACION. SE GENERA A PARTIR DEL AÑO Y MES DE LA FECHA EN FORMATO YYYYMM.';
COMMENT ON COLUMN BDS.L_RIE_CIERRE_32.NU_PRESTAMO        IS 'NUMERO DE PRESTAMO.';
COMMENT ON COLUMN BDS.L_RIE_CIERRE_32.CO_FUNC_INIC       IS 'CODIGO DEL FUNCIONARIO INICIAL.';
COMMENT ON COLUMN BDS.L_RIE_CIERRE_32.CO_AGEN_INIC       IS 'CODIGO DE LA AGENCIA INICIAL.';
COMMENT ON COLUMN BDS.L_RIE_CIERRE_32.CO_FUNC_CIER       IS 'CODIGO DEL FUNCIONARIO DE CIERRE DEL PERIODO ANTERIOR.';
COMMENT ON COLUMN BDS.L_RIE_CIERRE_32.CO_AGEN_CIER       IS 'CODIGO DE LA AGENCIA DE CIERRE DEL PERIODO ANTERIOR.';
COMMENT ON COLUMN BDS.L_RIE_CIERRE_32.FE_ACTU_MES        IS 'FECHA DE ACTUALIZACION MENSUAL DE LA TABLA.';
COMMENT ON COLUMN BDS.L_RIE_CIERRE_32.CO_ACTU_USER       IS 'USUARIO DE CARGA AL DWH.';
COMMENT ON COLUMN BDS.L_RIE_CIERRE_32.NU_CARGA           IS 'NUMERO IDENTIFICADOR DE CARGA DWH.';
COMMENT ON COLUMN BDS.L_RIE_CIERRE_32.IN_ESTA_REGI       IS 'ESTADO DEL REGISTRO.';
