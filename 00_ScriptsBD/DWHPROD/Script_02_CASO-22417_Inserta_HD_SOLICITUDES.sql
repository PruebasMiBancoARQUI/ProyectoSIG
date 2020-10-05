DECLARE
    lv_error          NUMBER;
    lv_mensaje_error  VARCHAR2(1000);
BEGIN
    ODS.PKG_ODS_GENERICO.SP_REGENERA_INDICE(V_ESQUEMA => 'ODS',
                                            V_NOMTABLA => 'HD_SOLICITUDES',
                                            V_ERROR => lv_error);

    ODS.PKG_ODS_GENERICO.SP_REGENERA_INDICE(V_ESQUEMA => 'ODS',
                                            V_NOMTABLA => 'HD_DESEMBOLSO',
                                            V_ERROR => lv_error);
											
    ODS.PKG_ODS_GENERICO.SP_REGENERA_INDICE(V_ESQUEMA => 'ODS',
                                            V_NOMTABLA => 'MD_SOLICITUDES',
                                            V_ERROR => lv_error);

	INSERT INTO ODS.HD_SOLICITUDES
	(
	FE_PROCESO, NU_PERI_MES, NU_SOLICITUD, CO_CLIENTE, CO_ESTA_SOLI, CO_TIPO_PRES, NU_METODOLOGIA, CO_ANALISTA, CO_TIPO_SOLI, NU_CUOT_GRAC, 
	NU_DIA_PAGO, NU_DEPENDIENTES, IN_CAMPANAS, NU_PUNT_CUAL, FE_REGI_SOLI, MO_SALARIO, MO_SOLICITADO, NU_PLAZ_SOLI, VL_ENDEUDAMIENTO, VL_TIPO_CAMB_OFI, 
	FE_REGI_PRES, VL_TASA_OPTI, FE_VENC_LINE, MO_TOTA_GAST, CO_MOTI_RECH, DE_COME_RECH, CO_PRODUCTO, CO_COND_CLIE, VL_TASA_MINI, VL_TASA_MAXI, 
	MO_APROBADO, CO_SUCURSAL, VL_TASA, IN_CONGLOMERADO, DE_PROP_DEST, FE_ACTU_DIA, CO_MONEDA, FE_EVAL_SOLI, CO_TIPO_GRAC, CO_FORM_DESE, 
	NU_PLAZ_APROB, FE_APRO_SOLI, CO_TIPO_CRED, MO_DEUD_SOLI, IN_EVALUACION, IN_APROBACION, IN_DESEMBOLSO, CO_USUA_TOPA_REGI, CO_USUA_TOPA_EVAL, 
	CO_USUA_TOPA_APRO, MO_PRESTAMO, MO_CUOTA, NU_CUOTAS
	)
	WITH 
		SUBQ1 AS
		(
		  SELECT e.FE_APER_CUEN as FE_APER_CUEN,
				 e.NU_SOLICITUD as NU_SOLICITUD
		  FROM ODS.HD_DESEMBOLSO e
		  LEFT JOIN ODS.HD_SOLICITUDES f ON f.NU_SOLICITUD = e.NU_SOLICITUD AND f.FE_PROCESO=e.FE_APER_CUEN
		  WHERE e.FE_APER_CUEN>=TO_DATE('06/06/2020','DD/MM/YYYY') AND f.NU_SOLICITUD IS NULL
		)
	SELECT
	  TO_DATE(q1.FE_APER_CUEN,'DD/MM/YYYY') as FE_PROCESO,
	  sol.NU_PERI_MES           ,
	  sol.NU_SOLICITUD          ,
	  sol.CO_CLIENTE            ,
	  sol.CO_ESTA_SOLI          ,
	  sol.CO_TIPO_PRES          ,
	  sol.NU_METODOLOGIA        ,
	  sol.CO_ANALISTA           ,
	  sol.CO_TIPO_SOLI          ,
	  sol.NU_CUOT_GRAC          ,
	  sol.NU_DIA_PAGO           ,
	  sol.NU_DEPENDIENTES       ,
	  sol.IN_CAMPANAS           ,
	  sol.NU_PUNT_CUAL          ,
	  sol.FE_REGI_SOLI          ,
	  sol.MO_SALARIO            ,
	  sol.MO_SOLICITADO         ,
	  sol.NU_PLAZ_SOLI          ,
	  sol.VL_ENDEUDAMIENTO      ,
	  sol.VL_TIPO_CAMB_OFI      ,
	  sol.FE_REGI_PRES          ,
	  sol.VL_TASA_OPTI          ,
	  sol.FE_VENC_LINE          ,
	  sol.MO_TOTA_GAST          ,
	  sol.CO_MOTI_RECH          ,
	  sol.DE_COME_RECH          ,
	  sol.CO_PRODUCTO           ,
	  sol.CO_COND_CLIE          ,
	  sol.VL_TASA_MINI          ,
	  sol.VL_TASA_MAXI          ,
	  sol.MO_APROBADO           ,
	  sol.CO_SUCURSAL           ,
	  sol.VL_TASA               ,
	  sol.IN_CONGLOMERADO       ,
	  sol.DE_PROP_DEST          ,
	  SYSDATE AS FE_ACTU_DIA    ,
	  sol.CO_MONEDA             ,
	  sol.FE_EVAL_SOLI          ,
	  sol.CO_TIPO_GRAC          ,
	  sol.CO_FORM_DESE          ,
	  sol.NU_PLAZ_APROB         ,
	  sol.FE_APRO_SOLI          ,
	  sol.CO_TIPO_CRED          ,
	  sol.MO_DEUD_SOLI          ,
	  sol.IN_EVALUACION         ,
	  sol.IN_APROBACION         ,
	  sol.IN_DESEMBOLSO         ,
	  sol.CO_USUA_TOPA_REGI     ,
	  sol.CO_USUA_TOPA_EVAL     ,
	  sol.CO_USUA_TOPA_APRO     ,
	  sol.MO_PRESTAMO           ,
	  sol.MO_CUOTA              ,
	  sol.NU_CUOTAS
	FROM ODS.MD_SOLICITUDES sol
	INNER JOIN SUBQ1 q1 ON q1.NU_SOLICITUD = sol.NU_SOLICITUD;

	COMMIT;
END;
/