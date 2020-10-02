TRUNCATE TABLE BDS.D_GEN_FUNCIONARIO;

ALTER TABLE BDS.D_GEN_FUNCIONARIO DROP (CO_CARGO, NO_CARGO, FE_ACTU_DIA);

ALTER TABLE BDS.D_GEN_FUNCIONARIO MODIFY CO_USUA_TOPA   VARCHAR2(10); 
ALTER TABLE BDS.D_GEN_FUNCIONARIO MODIFY CO_FUNCIONARIO NUMBER(8);
ALTER TABLE BDS.D_GEN_FUNCIONARIO MODIFY NO_FUNCIONARIO VARCHAR(150);

ALTER TABLE BDS.D_GEN_FUNCIONARIO ADD
(
 FE_INGRESO         DATE,
 CO_PUESTO          VARCHAR2(10) DEFAULT '.',
 CO_CARGO           NUMBER(5)    DEFAULT 0,
 NU_ANTI_LABO       NUMBER(5)    DEFAULT 0,
 DE_RANG_ANTI_LABO  VARCHAR2(10) DEFAULT '.',
 FE_ACTU_DIA        DATE         DEFAULT SYSDATE
);

COMMENT ON TABLE BDS.D_GEN_FUNCIONARIO IS 'TABLA DIMENSION GENERICA DE FUNCIONARIO.';
COMMENT ON COLUMN BDS.D_GEN_FUNCIONARIO.CO_FUNCIONARIO    IS 'CODIGO DEL FUNCIONARIO.';
COMMENT ON COLUMN BDS.D_GEN_FUNCIONARIO.NO_FUNCIONARIO    IS 'NOMBRE DEL FUNCIONARIO.';
COMMENT ON COLUMN BDS.D_GEN_FUNCIONARIO.FE_INGRESO        IS 'FECHA DE INGRESO DEL FUNCIONARIO.';
COMMENT ON COLUMN BDS.D_GEN_FUNCIONARIO.CO_PUESTO         IS 'CODIGO DEL PUESTO DEL FUNCIONARIO.';
COMMENT ON COLUMN BDS.D_GEN_FUNCIONARIO.CO_CARGO          IS 'CODIGO DEL CARGO DEL FUNCIONARIO.';
COMMENT ON COLUMN BDS.D_GEN_FUNCIONARIO.CO_USUA_TOPA      IS 'CODIGO DEL USUARIO DE TOPAZ DEL FUNCIONARIO.';
COMMENT ON COLUMN BDS.D_GEN_FUNCIONARIO.NU_ANTI_LABO      IS 'ANTIGUEDAD LABORAL DEL FUNCIONARIO EN MESES.';
COMMENT ON COLUMN BDS.D_GEN_FUNCIONARIO.DE_RANG_ANTI_LABO IS 'DESCRIPCION DEL RANGO DE ANTIGUEDAD LABORAL DEL FUNCIONARIO.';
COMMENT ON COLUMN BDS.D_GEN_FUNCIONARIO.FE_ACTU_DIA       IS 'FECHA DE ACTUALIZACION DEL REGISTRO.';