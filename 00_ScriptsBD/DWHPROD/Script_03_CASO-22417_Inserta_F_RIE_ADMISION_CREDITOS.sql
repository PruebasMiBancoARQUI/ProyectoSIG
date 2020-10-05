DECLARE
    lv_error          NUMBER;
    lv_mensaje_error  VARCHAR2(1000);
BEGIN
    BDS.PKG_BDS_GENERICO.SP_REGENERA_INDICE(V_OWNER => 'BDS',
                                            V_TABLA => 'F_RIE_ADMISION_CREDITOS',
                                            V_ERROR => lv_error);
											
    EXECUTE IMMEDIATE 'TRUNCATE TABLE BDS.F_RIE_ADMISION_CREDITOS REUSE STORAGE';
    EXECUTE IMMEDIATE 'ALTER TABLE BDS.F_RIE_ADMISION_CREDITOS DEALLOCATE UNUSED';

    BDS.PKG_BDS_GENERICO.SP_GEN_PARTICIONES(
                                            V_TABLA_OWNER =>  'BDS',
                                            V_NOM_TABLA => 'F_RIE_ADMISION_CREDITOS',
                                            V_CAMPO_PARTICIONADO => 'NU_PERI_MES',
                                            V_TIPO_CAMPO_PARTICIONADO => 'NUMBER',
                                            V_FRECUENCIA_PARTICION => 'MENSUAL',
                                            V_NOMBRE_PARTICION => 'P_RIE_ADMISION_CREDITOS_',
                                            V_NUM_PARTICIONES_MAX => 20000,
                                            V_TABLESPACE_PARTICION => 'BDS_DATA_01',
                                            V_ERROR => lv_error,
                                            V_MENSAJE_ERROR => lv_mensaje_error           
                                           );

    BDS.PKG_BDS_GENERICO.SP_REGENERA_INDICE(V_OWNER => 'BDS',
                                            V_TABLA => 'T_RIE_ADMISION_CREDITOS',
                                            V_ERROR => lv_error);

    INSERT INTO BDS.F_RIE_ADMISION_CREDITOS 
    (NU_SOLICITUD,
     NU_PRESTAMO,
     NU_PERI_MES,
     FE_INGR_SOLI,
     FE_EVAL_SOLI,
     FE_APRO_SOLI,
     FE_DESEMBOLSO,
     FE_APER_CUEN,
     IN_EVALUACION,
     IN_APROBACION,
     IN_DESEMBOLSO,
     IN_REFINANCIADO,
     IN_GARANTIA,
     IN_PRES_PREP,
     IN_CODEUDORES,
     CO_CLIENTE,
     CO_ESTA_SOLI,
     CO_MONEDA,
     CO_TIPO_SOLI,
     CO_TIPO_PRES,
     CO_TIPO_GRAC,
     CO_TIPO_CRED,
     CO_PRODUCTO,
     IN_PRES_MIGR,
     NU_LINE_CRED,
     NU_SOLI_LINE_CRED,
     CO_FORM_DESE,
     CO_AGENCIA,
     CO_ACTI_INTE,
     CO_GRUP_EXCE,
     NU_PERI_GRAC,
     VL_TASA_DESE,
     MO_SOLICITADO,
     MO_APROBADO,
     MO_DESEMBOLSADO,
     MO_DEUD_SOLI,
     MO_CUOTA,
     MO_SALD_CRED_CANC,
     NU_PLAZ_SOLI,
     NU_PLAZ_APRO,
     NU_CUOTAS,
     NU_DISP_LINE_CRED,
     NU_CANT_GARA,
     NU_CANT_CODE,
     NU_CANT_ENTI_ACRE,
     NU_DIAS_MORA_RCC,
     MO_DEUD_SIST_FINA,
     NU_DIAS_PROC_EVAL,
     NU_DIAS_PROC_APRO,
     NU_DIAS_PROC_DESE,
     CO_CONV_SOLI,
     FE_ACTU_DIA
    ) 
     WITH
         SUBQ1 AS
         (
          SELECT NU_SOLICITUD
          FROM BDS.T_RIE_ADMISION_CREDITOS
          GROUP BY NU_SOLICITUD
          HAVING COUNT(1)>1      
          UNION      
          SELECT NU_SOLICITUD AS NU_SOLICITUD 
          FROM ODS.HD_SOLICITUDES
          WHERE FE_PROCESO >= TO_DATE('07/08/2020','DD/MM/YYYY') --Solicitudes que se han registrado desde la deshabilitación
            OR TO_CHAR(FE_ACTU_DIA,'YYYYMMDDHH24') >= TO_CHAR(SYSDATE,'YYYYMMDD')||'14' --Solicitudes recientemente insertadas por la corrección a la HD_SOLICITUDES, desembolsos que no contaban con información de la solicitud.
          GROUP BY NU_SOLICITUD      
         ),
         SUBQ2 AS
         (
          SELECT NU_SOLICITUD, NU_PRESTAMO, SUM(MO_CRED_INDI_CANC) AS MO_CANCELADO
          FROM ODS.HD_PRESTAMOS_REFINANCIADOS
          GROUP BY NU_SOLICITUD, NU_PRESTAMO
         ),
         SUBQ3 AS
         (
          SELECT NU_SOLICITUD, COUNT(1) AS NU_CANT_GARA 
          FROM ODS.MD_PERSONAS_SOLICITUD
          WHERE CO_ROL_PERS = 'G'
          GROUP BY NU_SOLICITUD
         ),
         SUBQ4 AS
         (
          SELECT NU_SOLICITUD, COUNT(1) AS NU_CANT_CODE 
      FROM ODS.MD_PERSONAS_SOLICITUD
      WHERE CO_ROL_PERS = 'O'
      GROUP BY NU_SOLICITUD
     ),
     SUBQ5 AS
     (
      SELECT d.NU_SOLICITUD, 
             l.NU_DISP_LINE_CRED - (rank() over (PARTITION BY d.nu_line_cred ORDER BY d.FE_DESEMBOLSO DESC) - 1) NU_DISP_LINE_CRED
      FROM (SELECT b.NU_LINE_CRED
            FROM ODS.HD_SOLICITUDES a
            INNER JOIN ODS.HD_DESEMBOLSO b ON b.NU_SOLICITUD = a.NU_SOLICITUD AND b.FE_APER_CUEN = a.FE_PROCESO and a.co_esta_soli=88
            WHERE a.FE_PROCESO >= TO_DATE('07/08/2020','DD/MM/YYYY')  -- Periodo desde que se necesita volver a cargar la información
            AND b.NU_LINE_CRED<>0
            GROUP BY b.NU_LINE_CRED
            HAVING COUNT(DISTINCT b.NU_SOLICITUD)>1) a
      INNER JOIN ODS.HD_DESEMBOLSO d ON d.NU_LINE_CRED = a.NU_LINE_CRED and d.FE_APER_CUEN >= TO_DATE('07/08/2020','DD/MM/YYYY')
      LEFT JOIN ODS.MD_EXTORNOS_DESEMBOLSOS e on e.NU_PRESTAMO = d.NU_PRESTAMO
      INNER JOIN ODS.MD_LINEA_CREDITO l ON l.NU_LINE_CRED = a.NU_LINE_CRED
      WHERE e.NU_PRESTAMO IS NULL     
      ),
      SUBQ6 AS
	  (
        SELECT NU_SOLICITUD, NU_PRESTAMO
        FROM (SELECT NU_SOLICITUD, 
                     NU_PRESTAMO, 
                     FE_APER_CUEN, 
                     ROW_NUMBER() OVER (PARTITION BY NU_SOLICITUD ORDER BY FE_APER_CUEN DESC) AS ROW_NUM
              FROM ODS.HD_DESEMBOLSO
             )
        WHERE ROW_NUM = 1
	  )
    SELECT  a.NU_SOLICITUD,
            a.NU_PRESTAMO,
            a.NU_PERI_MES,
            a.FE_INGR_SOLI,
            a.FE_EVAL_SOLI,
            a.FE_APRO_SOLI,
            a.FE_DESEMBOLSO,
            a.FE_APER_CUEN,
            a.IN_EVALUACION,
            a.IN_APROBACION,
            a.IN_DESEMBOLSO,
            a.IN_REFINANCIADO,
            a.IN_GARANTIA,
            a.IN_PRES_PREP,
            a.IN_CODEUDORES,
            a.CO_CLIENTE,
            a.CO_ESTA_SOLI,
            a.CO_MONEDA,
            a.CO_TIPO_SOLI,
            a.CO_TIPO_PRES,
            a.CO_TIPO_GRAC,
            a.CO_TIPO_CRED,
            a.CO_PRODUCTO,
            a.IN_PRES_MIGR,
            a.NU_LINE_CRED,
            a.NU_SOLI_LINE_CRED,
            a.CO_FORM_DESE,
            a.CO_AGENCIA,
            a.CO_ACTI_INTE,
            a.CO_GRUP_EXCE,
            a.NU_PERI_GRAC,
            a.VL_TASA_DESE,
            a.MO_SOLICITADO,
            a.MO_APROBADO,
            a.MO_DESEMBOLSADO,
            a.MO_DEUD_SOLI,
            a.MO_CUOTA,
            a.MO_SALD_CRED_CANC,
            a.NU_PLAZ_SOLI,
            a.NU_PLAZ_APRO,
            a.NU_CUOTAS,
            a.NU_DISP_LINE_CRED,
            a.NU_CANT_GARA,
            a.NU_CANT_CODE,
            a.NU_CANT_ENTI_ACRE,
            a.NU_DIAS_MORA_RCC,
            a.MO_DEUD_SIST_FINA,
            a.NU_DIAS_PROC_EVAL,
            a.NU_DIAS_PROC_APRO,
            a.NU_DIAS_PROC_DESE,
            a.CO_CONV_SOLI,
            a.FE_ACTU_DIA
    FROM BDS.T_RIE_ADMISION_CREDITOS a
    LEFT JOIN SUBQ1 b ON b.NU_SOLICITUD = a.NU_SOLICITUD
    WHERE b.NU_SOLICITUD IS NULL
    UNION ALL
    --Procesa las solicitudes duplicadas
    SELECT w.NU_SOLICITUD,
           b.NU_PRESTAMO AS NU_PRESTAMO,
           NVL(TO_NUMBER(TO_CHAR(a.FE_REGI_SOLI,'YYYYMM')),0) AS NU_PERI_MES,
           a.FE_REGI_SOLI AS FE_INGR_SOLI, 
           NVL(a.FE_EVAL_SOLI, k.FE_EVAL_SOLI) AS FE_EVAL_SOLI, 
           NVL(a.FE_APRO_SOLI, k.FE_APRO_SOLI) AS FE_APRO_SOLI, 
           b.FE_DESEMBOLSO AS FE_DESEMBOLSO, --Se está manejando valores por default?
           b.FE_APER_CUEN AS FE_APER_CUEN, --Se está manejando valores por default?
           DECODE(NVL(a.FE_EVAL_SOLI, k.FE_EVAL_SOLI),NULL,0,1) AS IN_EVALUACION,
           DECODE(NVL(a.FE_APRO_SOLI, k.FE_APRO_SOLI),NULL,0,1) AS IN_APROBACION,
           DECODE(b.FE_DESEMBOLSO,NULL,0,1) AS IN_DESEMBOLSO, 
           DECODE(TRIM(a.CO_TIPO_PRES),'REFINANCIADO',1,0) AS IN_REFINANCIADO,
           CASE
              WHEN f.NU_CANT_GARA > 0 THEN 1 
              ELSE 0
           END AS IN_GARANTIA,
           CASE
              WHEN b.CO_REFINANCIACION NOT IN ('R','P') AND UPPER(h.DE_PRODUCTO) LIKE '%PRE%PAG%' THEN 1 
              ELSE 0 
           END AS IN_PRES_PREP,
           CASE
              WHEN g.NU_CANT_CODE > 0 THEN 1
              ELSE 0 
           END AS IN_CODEUDORES,
           a.CO_CLIENTE AS CO_CLIENTE,
           a.CO_ESTA_SOLI AS CO_ESTA_SOLI,
           a.CO_MONEDA AS CO_MONEDA,
           a.CO_TIPO_SOLI AS CO_TIPO_SOLI,
           a.CO_TIPO_PRES AS CO_TIPO_PRES,
           a.CO_TIPO_GRAC AS CO_TIPO_GRAC,
           a.CO_TIPO_CRED AS CO_TIPO_CRED,
           a.CO_PRODUCTO AS CO_PRODUCTO,
           0 AS IN_PRES_MIGR,
           b.NU_LINE_CRED AS NU_LINE_CRED,     
           e.NU_SOLICITUD AS NU_SOLI_LINE_CRED,
           a.CO_FORM_DESE AS CO_FORM_DESE,     
           a.CO_SUCURSAL AS CO_AGENCIA,       
           c.CO_ACTIVIDAD AS CO_ACTI_INTE,     
           b.CO_GRUP_EXCE AS CO_GRUP_EXCE,     
           a.NU_CUOT_GRAC AS NU_PERI_GRAC,     
           a.VL_TASA AS VL_TASA_DESE,     
           a.MO_SOLICITADO AS MO_SOLICITADO,    
           a.MO_APROBADO AS MO_APROBADO,      
           b.MO_DESEMBOLSADO AS MO_DESEMBOLSADO,  
           a.MO_DEUD_SOLI AS MO_DEUD_SOLI,     
           b.MO_CUOTA AS MO_CUOTA,
           d.MO_CANCELADO AS MO_SALD_CRED_CANC,
           a.NU_PLAZ_SOLI AS NU_PLAZ_SOLI,
           a.NU_PLAZ_APROB AS NU_PLAZ_APRO,
           b.NU_CUOTAS AS NU_CUOTAS,
    --------------------------------------------------------
           NVL(l.NU_DISP_LINE_CRED,e.NU_DISP_LINE_CRED),
    --------------------------------------------------------       
           f.NU_CANT_GARA AS NU_CANT_GARA,
           g.NU_CANT_CODE AS NU_CANT_CODE,
           NULL AS NU_CANT_ENTI_ACRE,
           NULL AS NU_DIAS_MORA_RCC,
           NULL AS MO_DEUD_SIST_FINA,
           CASE
              WHEN a.FE_EVAL_SOLI IS NOT NULL THEN TRUNC(a.FE_EVAL_SOLI) - TRUNC(a.FE_REGI_SOLI)
              WHEN k.FE_EVAL_SOLI IS NOT NULL THEN TRUNC(k.FE_EVAL_SOLI) - TRUNC(k.FE_REGI_SOLI)
              ELSE NULL
           END AS NU_DIAS_PROC_EVAL,
           CASE
              WHEN a.FE_APRO_SOLI IS NOT NULL AND a.FE_EVAL_SOLI IS NOT NULL THEN TRUNC(a.FE_APRO_SOLI) - TRUNC(a.FE_EVAL_SOLI)
              WHEN k.FE_APRO_SOLI IS NOT NULL AND k.FE_EVAL_SOLI IS NOT NULL THEN TRUNC(k.FE_APRO_SOLI) - TRUNC(k.FE_EVAL_SOLI)
              ELSE NULL
           END AS NU_DIAS_PROC_APRO,      
           CASE
              WHEN b.FE_DESEMBOLSO IS NOT NULL AND a.FE_APRO_SOLI IS NOT NULL THEN TRUNC(b.FE_DESEMBOLSO) - TRUNC(a.FE_APRO_SOLI)
              WHEN b.FE_DESEMBOLSO IS NOT NULL AND a.FE_REGI_SOLI IS NOT NULL THEN TRUNC(b.FE_DESEMBOLSO) - TRUNC(a.FE_REGI_SOLI)
              ELSE NULL
           END AS NU_DIAS_PROC_DESE,     
           j.CO_MEDI_ORIG AS CO_CONV_SOLI,
           SYSDATE AS FE_ACTU_DIA
    FROM SUBQ1 w
         INNER JOIN ODS.MD_SOLICITUDES a ON a.NU_SOLICITUD = w.NU_SOLICITUD
	     LEFT JOIN SUBQ6 m ON m.NU_SOLICITUD = a.NU_SOLICITUD and a.CO_ESTA_SOLI=88
         LEFT JOIN ODS.HD_DESEMBOLSO b ON b.NU_PRESTAMO = m.NU_PRESTAMO
         LEFT JOIN ODS.MD_EXTORNOS_DESEMBOLSOS ed ON ed.NU_PRESTAMO = b.NU_PRESTAMO
         LEFT JOIN ODS.MD_CLIENTES c ON c.CO_CLIENTE = a.CO_CLIENTE
         LEFT JOIN SUBQ2 d ON d.NU_SOLICITUD = a.NU_SOLICITUD AND d.NU_PRESTAMO = b.NU_PRESTAMO
         LEFT JOIN ODS.MD_LINEA_CREDITO e ON e.NU_LINE_CRED = b.NU_LINE_CRED
         LEFT JOIN SUBQ3 f ON ((f.NU_SOLICITUD = a.NU_SOLICITUD AND b.NU_LINE_CRED = 0) OR (f.NU_SOLICITUD = e.NU_SOLICITUD AND b.NU_LINE_CRED <> 0))
         LEFT JOIN SUBQ4 g ON ((g.NU_SOLICITUD = a.NU_SOLICITUD AND b.NU_LINE_CRED = 0) OR (g.NU_SOLICITUD = e.NU_SOLICITUD AND b.NU_LINE_CRED <> 0))
         LEFT JOIN ODS.MD_PRODUCTO_01 h ON h.CO_PRODUCTO = a.CO_PRODUCTO
         LEFT JOIN ODS.MD_LINEA_CREDITO i ON i.NU_SOLICITUD = a.NU_SOLICITUD
         LEFT JOIN ODS.MD_APERTURA_PRESOLICITUD j ON j.NU_SOLICITUD = a.NU_SOLICITUD
         LEFT JOIN ODS.MD_SOLICITUDES k ON k.NU_SOLICITUD = e.NU_SOLICITUD
    ---------------------------------------------------------
         LEFT JOIN SUBQ5 l ON l.NU_SOLICITUD = a.NU_SOLICITUD
    ---------------------------------------------------------     
         WHERE ed.NU_PRESTAMO IS NULL;
	 
    COMMIT;
	
    BDS.PKG_BDS_GENERICO.SP_REGENERA_INDICE(V_OWNER => 'BDS',
                                            V_TABLA => 'F_RIE_ADMISION_CREDITOS',
                                            V_ERROR => lv_error);
											
END;
/