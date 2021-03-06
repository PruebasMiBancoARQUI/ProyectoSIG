CREATE OR REPLACE PROCEDURE DWHADM.SP_CI_PRESTAMOS_REFINANCIADOS IS
  LV_ERROR          NUMBER;
  LV_MENSAJE_ERROR  VARCHAR2(1000);
BEGIN

  ODS.PKG_ODS_GENERICO.SP_REGENERA_INDICE(V_ESQUEMA  => 'ODS',
                                          V_NOMTABLA => 'HD_PRESTAMOS_REFINANCIADOS',
                                          V_ERROR    => LV_ERROR);

  EXECUTE IMMEDIATE '
  INSERT INTO ODS.HD_PRESTAMOS_REFINANCIADOS (
  NU_SOLICITUD, NU_PRESTAMO, CO_CLIENTE, FE_DESEMBOLSO, CO_REFINANCIADO, NU_PRES_CANC, NU_SOLI_CANC, 
  CO_MONE_CANC, CO_PROD_CANC, CO_CLIE_CANC, MO_CRED_CANC, MO_CRED_INDI_CANC, CO_MOTI_CANC, 
  NU_ORDE_PRES_CANC, VL_PORC_PRES_CANC, FE_ACTU_DIA, FE_PROCESO )
  SELECT  
  A.CRE_NUMSOLICITUD      AS NU_SOLICITUD, 
  FIN.CUENTA              AS NU_PRESTAMO, 
  FIN.C1803               AS CO_CLIENTE, 
  FIN.C1620               AS FE_DESEMBOLSO, 
  FIN.REFINANCIACION      AS CO_REFINANCIADO, 
  INI.CUENTA              AS NU_PRES_CANC, 
  INI.C1704               AS NU_SOLI_CANC, 
  A.CRE_MONEDA            AS CO_MONE_CANC, 
  A.CRE_PRODUCTO          AS CO_PROD_CANC, 
  INI.C1803               AS CO_CLIE_CANC, 
  A.CRE_MONTOCANC         AS MO_CRED_CANC, 
  A.CRE_MONTOCANC         AS MO_CRED_INDI_CANC, 
  A.CRE_MOTIVOCANC        AS CO_MOTI_CANC, 
  ROW_NUMBER() OVER(PARTITION BY FIN.C1704 ORDER BY A.CRE_MONTOCANC) AS NU_ORDE_PRES_CANC, 
  0                       AS VL_PORC_PRES_CANC, 
  SYSDATE                 AS FE_ACTU_DIA, 
  TRUNC(SYSDATE)          AS FE_PROCESO  
  FROM STG.T_SL_SOLICITUDCREDCANCELA A
  INNER JOIN SALDOS FIN ON (FIN.C9314=5 AND FIN.ORDINAL=0 AND FIN.TZ_LOCK=0 AND A.CRE_NUMSOLICITUD=FIN.C1704 AND FIN.OPERACION=0)
  LEFT  JOIN SALDOS INI ON (INI.C9314=5 AND INI.ORDINAL=0 AND INI.TZ_LOCK=0 AND A.CRE_CUENTA=INI.CUENTA      AND INI.OPERACION=0 )  
  WHERE A.CRE_MOTIVOCANC IN (''R'',''P'') 
  ';
  COMMIT;

  ODS.PKG_ODS_GENERICO.SP_REGENERA_INDICE(V_ESQUEMA  => 'ODS',
                                          V_NOMTABLA => 'HD_PRESTAMOS_REFINANCIADOS',
                                          V_ERROR    => LV_ERROR);
                                               
  EXECUTE IMMEDIATE '
  MERGE INTO ODS.HD_PRESTAMOS_REFINANCIADOS RFD USING ODS.HD_PRESTAMOS_REFINANCIADOS RF0 
  ON (RFD.NU_PRESTAMO=RF0.NU_PRESTAMO AND RFD.NU_ORDE_PRES_CANC=RF0.NU_ORDE_PRES_CANC + 1 ) 
  WHEN MATCHED THEN UPDATE SET RFD.MO_CRED_INDI_CANC = RFD.MO_CRED_CANC - RF0.MO_CRED_CANC
  ';
  COMMIT;

  ODS.PKG_ODS_GENERICO.SP_REGENERA_INDICE(V_ESQUEMA  => 'ODS',
                                          V_NOMTABLA => 'HD_PRESTAMOS_REFINANCIADOS',
                                          V_ERROR    => LV_ERROR);
                                                                                        
  EXECUTE IMMEDIATE '                                           
  MERGE INTO ODS.HD_PRESTAMOS_REFINANCIADOS RFD 
  USING (SELECT NU_PRESTAMO, MAX(MO_CRED_CANC) as MON_CAN_TOT 
  FROM ODS.HD_PRESTAMOS_REFINANCIADOS GROUP BY NU_PRESTAMO HAVING MAX(MO_CRED_CANC) > 0 ) MAX
  ON (RFD.NU_PRESTAMO=MAX.NU_PRESTAMO) 
  WHEN MATCHED THEN UPDATE SET RFD.VL_PORC_PRES_CANC=RFD.MO_CRED_INDI_CANC / MAX.MON_CAN_TOT 
  ';
  COMMIT;

  ODS.PKG_ODS_GENERICO.SP_REGENERA_INDICE(V_ESQUEMA  => 'ODS',
                                          V_NOMTABLA => 'HD_PRESTAMOS_REFINANCIADOS',
                                          V_ERROR    => LV_ERROR);                                            

END;
/