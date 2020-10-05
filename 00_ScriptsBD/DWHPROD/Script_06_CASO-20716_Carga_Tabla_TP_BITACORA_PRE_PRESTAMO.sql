DECLARE
    lv_error          NUMBER;
    lv_mensaje_error  VARCHAR2(1000);
    ln_ind_existe     NUMBER(1);
    ld_fecha_inicio   DATE;
    ld_fecha_fin      DATE;
BEGIN
    ODS.PKG_ODS_GENERICO.SP_TRUNCATE_TABLE(
                                           V_OWNER => 'ODS',
                                           V_TABLA => 'TP_BITACORA_PRE_PRESTAMO',
                                           V_ERROR => lv_error,
                                           V_MENSAJE_ERROR => lv_mensaje_error
                                          );

    ODS.PKG_ODS_GENERICO.SP_REGENERA_INDICE(V_ESQUEMA => 'ODS',
                                            V_NOMTABLA => 'TP_BITACORA_PRE_PRESTAMO',
                                            V_ERROR => lv_error);
  
    EXECUTE IMMEDIATE
    '
     INSERT /*+ APPEND */ INTO ODS.TP_BITACORA_PRE_PRESTAMO
     (NU_SOLICITUD, FE_PROCESO, TX_HORA_PROC, CO_USUA_TOPA, FE_ACTU_DIA)
     SELECT NU_SOLICITUD,
            FE_PROCESO,
            TX_HORA_PROC, 
            CO_USUA_TOPA,
            SYSDATE AS FE_ACTU_DIA
     FROM
          (
           SELECT ROW_NUMBER() OVER (PARTITION BY BS.NU_SOLICITUD ORDER BY BS.FE_PROCESO DESC, BS.TX_HORA_PROC DESC) AS NU_ORDEN,
                  BS.FE_PROCESO AS FE_PROCESO,
                  BS.NU_SOLICITUD AS NU_SOLICITUD,
                  BS.TX_HORA_PROC AS TX_HORA_PROC,
                  BS.CO_USUA_TOPA AS CO_USUA_TOPA
           FROM ODS.TG_BITACORA_PRE_PRESTAMO BS
           WHERE BS.DE_DETALLEDOS LIKE ''%PRE%PREST%''
          )
     WHERE NU_ORDEN = 1
    ';
    COMMIT;
  
    ODS.PKG_ODS_GENERICO.SP_REGENERA_INDICE(V_ESQUEMA => 'ODS',
                                            V_NOMTABLA => 'TP_BITACORA_PRE_PRESTAMO',
                                            V_ERROR => lv_error);                      
END;
/