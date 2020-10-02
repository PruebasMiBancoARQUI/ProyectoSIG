DECLARE
    lv_error          NUMBER;
    lv_mensaje_error  VARCHAR2(1000);
	ld_fecproceso     DATE;
	ld_fecinicial     VARCHAR2(25);
	ld_fecfinal       VARCHAR2(25);
	lv_sql            VARCHAR2(1000);
		
	CURSOR C1 IS
	       SELECT TO_CHAR(FE_REGI_SOLI,'YYYYMM') AS MES_REGI_SOLI
		   FROM ODS.MD_SOLICITUDES
		   GROUP BY TO_CHAR(FE_REGI_SOLI,'YYYYMM')
		   ORDER BY 1;
BEGIN
    ODS.PKG_ODS_GENERICO.SP_GEN_PARTICIONES(
                                            V_TABLA_OWNER =>  'ODS',
                                            V_NOM_TABLA => 'HD_SOLICITUDES',
                                            V_CAMPO_PARTICIONADO => 'FE_PROCESO',
                                            V_TIPO_CAMPO_PARTICIONADO => 'DATE',
                                            V_FRECUENCIA_PARTICION => 'DIARIA',
                                            V_NOMBRE_PARTICION => 'P_SOLICITUDES_',
                                            V_NUM_PARTICIONES_MAX => 20000,
                                            V_TABLESPACE_PARTICION => 'ODS_DATA_01',
                                            V_ERROR => lv_error,
                                            V_MENSAJE_ERROR => lv_mensaje_error           
                                           );

    ODS.PKG_ODS_GENERICO.SP_REGENERA_INDICE(V_ESQUEMA => 'ODS',
                                            V_NOMTABLA => 'HD_SOLICITUDES',
                                            V_ERROR => lv_error);
    
	SELECT MIN(FE_PROCESO) INTO ld_fecproceso FROM ODS.HD_SOLICITUDES;
	
	IF  ld_fecproceso IS NULL THEN
	    ld_fecproceso := TRUNC(SYSDATE - 1);
    ELSE
	    ld_fecproceso := ld_fecproceso - 1;
    END IF;
	
	FOR R1 IN C1 LOOP
		IF  R1.MES_REGI_SOLI IS NULL THEN
		    lv_sql := 'WHERE FE_REGI_SOLI IS NULL ';
		ELSE
	        ld_fecinicial := TO_CHAR(TO_DATE(R1.MES_REGI_SOLI||'01 23:59:59','YYYYMMDD HH24:MI:SS')-1,'YYYYMMDD HH24:MI:SS');
		    ld_fecfinal   := TO_CHAR(LAST_DAY(TO_DATE(R1.MES_REGI_SOLI||'01 00:00:00','YYYYMMDD HH24:MI:SS'))+1,'YYYYMMDD HH24:MI:SS');
		    lv_sql := 'WHERE FE_REGI_SOLI > TO_DATE('''||ld_fecinicial||''',''YYYYMMDD HH24:MI:SS'') AND FE_REGI_SOLI < TO_DATE('''||ld_fecfinal||''',''YYYYMMDD HH24:MI:SS'') ';
		END IF;
		
        EXECUTE IMMEDIATE
        '
        INSERT INTO ODS.HD_SOLICITUDES
		(
         NU_PERI_MES,
         NU_SOLICITUD,
         CO_CLIENTE,
         CO_ESTA_SOLI,
         CO_TIPO_PRES,
         NU_METODOLOGIA,
         CO_ANALISTA,
         CO_TIPO_SOLI,
         NU_CUOT_GRAC,
         NU_DIA_PAGO,
         NU_DEPENDIENTES,
         IN_CAMPANAS,
         NU_PUNT_CUAL,
         FE_REGI_SOLI,
         MO_SALARIO,
         MO_SOLICITADO,
         NU_PLAZ_SOLI,
         VL_ENDEUDAMIENTO,
         VL_TIPO_CAMB_OFI,
         FE_REGI_PRES,
         VL_TASA_OPTI,
         FE_VENC_LINE,
         MO_TOTA_GAST,
         CO_MOTI_RECH,
         DE_COME_RECH,
         CO_PRODUCTO,
         CO_COND_CLIE,
         VL_TASA_MINI,
         VL_TASA_MAXI,
         MO_APROBADO,
         CO_SUCURSAL,
         VL_TASA,
         IN_CONGLOMERADO,
         DE_PROP_DEST,
         FE_ACTU_DIA,
         CO_MONEDA,
         FE_EVAL_SOLI,
         CO_TIPO_GRAC,
         CO_FORM_DESE,
         NU_PLAZ_APROB,
         FE_APRO_SOLI,
         CO_TIPO_CRED,
         MO_DEUD_SOLI,
         IN_EVALUACION,
         IN_APROBACION,
         IN_DESEMBOLSO,
         CO_USUA_TOPA_REGI,
         CO_USUA_TOPA_EVAL,
         CO_USUA_TOPA_APRO,
         MO_PRESTAMO,
         MO_CUOTA,
         NU_PLAZOS,
         NU_CUOTAS,
         FE_PROCESO
		)
		SELECT NU_PERI_MES,
               NU_SOLICITUD,
               CO_CLIENTE,
               CO_ESTA_SOLI,
               CO_TIPO_PRES,
               NU_METODOLOGIA,
               CO_ANALISTA,
               CO_TIPO_SOLI,
               NU_CUOT_GRAC,
               NU_DIA_PAGO,
               NU_DEPENDIENTES,
               IN_CAMPANAS,
               NU_PUNT_CUAL,
               FE_REGI_SOLI,
               MO_SALARIO,
               MO_SOLICITADO,
               NU_PLAZ_SOLI,
               VL_ENDEUDAMIENTO,
               VL_TIPO_CAMB_OFI,
               FE_REGI_PRES,
               VL_TASA_OPTI,
               FE_VENC_LINE,
               MO_TOTA_GAST,
               CO_MOTI_RECH,
               DE_COME_RECH,
               CO_PRODUCTO,
               CO_COND_CLIE,
               VL_TASA_MINI,
               VL_TASA_MAXI,
               MO_APROBADO,
               CO_SUCURSAL,
               VL_TASA,
               IN_CONGLOMERADO,
               DE_PROP_DEST,
               FE_ACTU_DIA,
               CO_MONEDA,
               FE_EVAL_SOLI,
               CO_TIPO_GRAC,
               CO_FORM_DESE,
               NU_PLAZ_APROB,
               FE_APRO_SOLI,
               CO_TIPO_CRED,
               MO_DEUD_SOLI,
               IN_EVALUACION,
               IN_APROBACION,
               IN_DESEMBOLSO,
               CO_USUA_TOPA_REGI,
               CO_USUA_TOPA_EVAL,
               CO_USUA_TOPA_APRO,
               MO_PRESTAMO,
               MO_CUOTA,
               NU_PLAZOS,
               NU_CUOTAS,
               TO_DATE('''||TO_CHAR(ld_fecproceso,'YYYYMMDD')||''',''YYYYMMDD'') AS FE_PROCESO
		FROM ODS.MD_SOLICITUDES '||lv_sql;
        COMMIT;
	END LOOP;
	
	ODS.PKG_ODS_GENERICO.SP_ESTADISTICAS_PARTITION(V_FECHA_INICIO => ld_fecproceso,
												   V_FECHA_FIN => ld_fecproceso,
												   V_TABLA_OWNER => 'ODS', 
												   V_NOM_TABLA => 'HD_SOLICITUDES',
												   V_FRECUENCIA_PARTICION => 'DIARIA',
												   V_NOMBRE_PARTICION => 'P_SOLICITUDES_',
												   V_ERROR => lv_error,
												   V_MENSAJE_ERROR => lv_mensaje_error);
	
    ODS.PKG_ODS_GENERICO.SP_REGENERA_INDICE(V_ESQUEMA => 'ODS',
                                            V_NOMTABLA => 'HD_SOLICITUDES',
                                            V_ERROR => lv_error);                      
END;
/