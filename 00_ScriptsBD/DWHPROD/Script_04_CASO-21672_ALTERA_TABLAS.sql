--CREACION DE NUEVOS CAMPOS
---------------------------

--T_SALDOS
ALTER TABLE STG.T_SALDOS ADD INTE_COMP NUMBER(15,2);
ALTER TABLE STG.T_SALDOS ADD MORA_CONT NUMBER(15,2);
COMMENT ON COLUMN STG.T_SALDOS.INTE_COMP IS 'INTERES COMPENSATORIO MORA CONTABILIZADA.';
COMMENT ON COLUMN STG.T_SALDOS.MORA_CONT IS 'MORA CONTABILIZADA.';

ALTER TABLE STG.T_SALDOS MODIFY INTE_COMP DEFAULT 0;
ALTER TABLE STG.T_SALDOS MODIFY MORA_CONT DEFAULT 0;

--T_SALDOS_SL_SOLICITUDCREDITO
ALTER TABLE STG.T_SALDOS_SL_SOLICITUDCREDITO ADD INTE_COMP NUMBER(15,2);
ALTER TABLE STG.T_SALDOS_SL_SOLICITUDCREDITO ADD MORA_CONT NUMBER(15,2);
COMMENT ON COLUMN STG.T_SALDOS_SL_SOLICITUDCREDITO.INTE_COMP IS 'INTERES COMPENSATORIO MORA CONTABILIZADA.';
COMMENT ON COLUMN STG.T_SALDOS_SL_SOLICITUDCREDITO.MORA_CONT IS 'MORA CONTABILIZADA.';

ALTER TABLE STG.T_SALDOS_SL_SOLICITUDCREDITO MODIFY INTE_COMP DEFAULT 0;
ALTER TABLE STG.T_SALDOS_SL_SOLICITUDCREDITO MODIFY MORA_CONT DEFAULT 0;

--TMP_EGP_3
ALTER TABLE STG.TMP_EGP_3 ADD INTE_COMP NUMBER(15,2);
ALTER TABLE STG.TMP_EGP_3 ADD MORA_CONT NUMBER(15,2);
COMMENT ON COLUMN STG.TMP_EGP_3.INTE_COMP IS 'INTERES COMPENSATORIO MORA CONTABILIZADA.';
COMMENT ON COLUMN STG.TMP_EGP_3.MORA_CONT IS 'MORA CONTABILIZADA.';

ALTER TABLE STG.TMP_EGP_3 MODIFY INTE_COMP DEFAULT 0;
ALTER TABLE STG.TMP_EGP_3 MODIFY MORA_CONT DEFAULT 0;

----ALTERA TABLA HM_EGP
ALTER TABLE ODS.HM_EGP
ADD (
  MO_INTE_COMP_ATRA NUMBER(15,2),
  MO_INTE_MORA_PEND NUMBER(15,2) 
  );
COMMENT ON COLUMN  ODS.HM_EGP.MO_INTE_COMP_ATRA  IS 'MONTO DE INTERES COMPENSATORIO EN ATRASO.';
COMMENT ON COLUMN  ODS.HM_EGP.MO_INTE_MORA_PEND IS 'MONTO DE INTERES DE MORA PENDIENTE';

ALTER TABLE ODS.HM_EGP MODIFY MO_INTE_COMP_ATRA DEFAULT 0;
ALTER TABLE ODS.HM_EGP MODIFY MO_INTE_MORA_PEND DEFAULT 0;

----ALTERA TABLA HD_EGP
ALTER TABLE ODS.HD_EGP
ADD(
  MO_INTE_COMP_ATRA NUMBER(15,2),
  MO_INTE_MORA_PEND NUMBER(15,2) 
  );
COMMENT ON COLUMN  ODS.HD_EGP.MO_INTE_COMP_ATRA  IS 'MONTO DE INTERES COMPENSATORIO EN ATRASO.';
COMMENT ON COLUMN  ODS.HD_EGP.MO_INTE_MORA_PEND IS 'MONTO DE INTERES DE MORA PENDIENTE';

ALTER TABLE ODS.HD_EGP MODIFY MO_INTE_COMP_ATRA DEFAULT 0;
ALTER TABLE ODS.HD_EGP MODIFY MO_INTE_MORA_PEND DEFAULT 0;

---ALTERA TABLA UD_EGP
ALTER TABLE ODS.UD_EGP
ADD (
  MO_INTE_COMP_ATRA NUMBER(15,2),
  MO_INTE_MORA_PEND NUMBER(15,2)
  );
COMMENT ON COLUMN  ODS.UD_EGP.MO_INTE_COMP_ATRA  IS 'MONTO DE INTERES COMPENSATORIO EN ATRASO.';
COMMENT ON COLUMN  ODS.UD_EGP.MO_INTE_MORA_PEND IS 'MONTO DE INTERES DE MORA PENDIENTE';

ALTER TABLE ODS.UD_EGP MODIFY MO_INTE_COMP_ATRA DEFAULT 0;
ALTER TABLE ODS.UD_EGP MODIFY MO_INTE_MORA_PEND DEFAULT 0;