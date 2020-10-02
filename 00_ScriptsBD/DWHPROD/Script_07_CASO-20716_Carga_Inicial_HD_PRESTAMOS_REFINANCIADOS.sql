DECLARE
  lv_error          NUMBER;
  lv_mensaje_error  VARCHAR2(1000);
BEGIN
  
  ODS.PKG_ODS_GENERICO.SP_TRUNCATE_TABLE(
                                           V_OWNER => 'ODS',
                                           V_TABLA => 'HD_PRESTAMOS_REFINANCIADOS',
                                           V_ERROR => lv_error,
                                           V_MENSAJE_ERROR => lv_mensaje_error
                                          );


  ODS.PKG_ODS_GENERICO.SP_REGENERA_INDICE(V_ESQUEMA  => 'ODS',
                                          V_NOMTABLA => 'HD_PRESTAMOS_REFINANCIADOS',
                                             V_ERROR => lv_error);

  EXECUTE IMMEDIATE '
  INSERT INTO ODS.HD_PRESTAMOS_REFINANCIADOS (
  NU_SOLICITUD, NU_PRESTAMO, CO_CLIENTE, FE_DESEMBOLSO, CO_TIPO_REFI, NU_PRES_CANC, NU_SOLI_CANC, 
  CO_MONE_CANC, CO_PROD_CANC, CO_CLIE_CANC, MO_CRED_CANC, MO_CRED_IND_CANC, CO_MOTI_CANC, DE_MOTI_CANC,
  NU_ORDE_PRES_CANC, VL_PORC_PRES_CANC, FE_ACTU_DIA, FE_PROCESO  
  )
  Select 
  CRE_NUMSOLICITUD        AS NU_SOLICITUD, 
  FIN.NU_PRESTAMO         AS NU_PRESTAMO, 
  FIN.CO_CLIENTE          AS CO_CLIENTE, 
  FIN.FE_DESEMBOLSO       AS FE_DESEMBOLSO, 
  FIN.CO_REFINANCIACION   AS CO_TIPO_REFI, 
  A.CRE_CUENTA            AS NU_PRES_CANC, 
  INI.NU_SOLICITUD        AS NU_SOLI_CANC, 
  CRE_MONEDA              AS CO_MONE_CANC, 
  CRE_PRODUCTO            AS CO_PROD_CANC, 
  INI.CO_CLIENTE          AS CO_CLIE_CANC, 
  CRE_MONTOCANC           AS MO_CRED_CANC, 
  CRE_MONTOCANC           AS MO_CRED_IND_CANC, 
  CRE_MOTIVOCANC          AS CO_MOTI_CANC,
  (SELECT DESCRIPCION FROM STG.T_OPCIONES WHERE NUMERODECAMPO = 1977 AND OPCIONINTERNA = a.CRE_MOTIVOCANC) AS DE_MOTI_CANC, 
  ROW_NUMBER() OVER(PARTITION BY FIN.Nu_Solicitud ORDER BY A.CRE_MONTOCANC)                                AS NU_ORDE_PRES_CANC, 
  NULL                    AS VL_PORC_PRES_CANC, 
  SYSDATE                 AS FE_ACTU_DIA, 
  SYSDATE                 AS FE_PROCESO  
  FROM STG.T_SL_SOLICITUDCREDCANCELA a
  INNER JOIN ods.hd_desembolso FIN on a.cre_numsolicitud = fin.Nu_Solicitud AND FIN.CO_REFINANCIACION IN (''R'',''P'')
  LEFT  JOIN ods.hd_desembolso INI on a.cre_cuenta = ini.Nu_Prestamo
  ';
  COMMIT;

  ODS.PKG_ODS_GENERICO.SP_REGENERA_INDICE(V_ESQUEMA  => 'ODS',
                                          V_NOMTABLA => 'HD_PRESTAMOS_REFINANCIADOS',
                                             V_ERROR => lv_error);
                                               
  EXECUTE IMMEDIATE '
  MERGE INTO ODS.HD_PRESTAMOS_REFINANCIADOS RFD USING ODS.HD_PRESTAMOS_REFINANCIADOS RF0 
  ON (RFD.NU_PRESTAMO=RF0.NU_PRESTAMO AND RFD.NU_ORDE_PRES_CANC=RF0.NU_ORDE_PRES_CANC+1 ) 
  WHEN MATCHED THEN UPDATE SET RFD.MO_CRED_IND_CANC = RFD.MO_CRED_CANC-RF0.MO_CRED_CANC
  ';
  COMMIT;

  ODS.PKG_ODS_GENERICO.SP_REGENERA_INDICE(V_ESQUEMA  => 'ODS',
                                          V_NOMTABLA => 'HD_PRESTAMOS_REFINANCIADOS',
                                             V_ERROR => lv_error);
                                                                                        
  EXECUTE IMMEDIATE '                                           
  MERGE INTO ODS.HD_PRESTAMOS_REFINANCIADOS RFD 
  USING (SELECT NU_PRESTAMO, MAX(MO_CRED_CANC) as MON_CAN_TOT 
  FROM ODS.HD_PRESTAMOS_REFINANCIADOS GROUP BY NU_PRESTAMO HAVING MAX(MO_CRED_CANC) > 0 ) MAX
  ON (RFD.NU_PRESTAMO=MAX.NU_PRESTAMO) 
  WHEN MATCHED THEN UPDATE SET RFD.VL_PORC_PRES_CANC=RFD.MO_CRED_IND_CANC/MAX.MON_CAN_TOT 
  ';
  COMMIT;

  ODS.PKG_ODS_GENERICO.SP_REGENERA_INDICE(V_ESQUEMA  => 'ODS',
                                          V_NOMTABLA => 'HD_PRESTAMOS_REFINANCIADOS',
                                             V_ERROR => lv_error);                                            

END;
/
