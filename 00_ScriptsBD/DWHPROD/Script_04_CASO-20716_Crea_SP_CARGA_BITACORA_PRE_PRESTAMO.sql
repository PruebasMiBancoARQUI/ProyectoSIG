CREATE OR REPLACE PROCEDURE DWHADM.SP_CARGA_BITACORA_PRE_PRESTAMO IS
    lv_error          NUMBER;
    lv_mensaje_error  VARCHAR2(1000);
BEGIN
    ODS.PKG_ODS_GENERICO.SP_TRUNCATE_TABLE(
                                           V_OWNER => 'ODS',
                                           V_TABLA => 'TG_BITACORA_PRE_PRESTAMO',
                                           V_ERROR => lv_error,
                                           V_MENSAJE_ERROR => lv_mensaje_error
                                          );

    EXECUTE IMMEDIATE
    '
     INSERT /*+ APPEND */ INTO ODS.TG_BITACORA_PRE_PRESTAMO
     (NU_SOLICITUD, FE_PROCESO, TX_HORA_PROC, CO_USUA_TOPA, DE_DETALLEDOS)
     SELECT NUMSOLICITUD,
            FECHA,
            HORA,
            USUARIO,
            DETALLEDOS
     FROM SL_BITACORASOLICITUD A  -- SL_BITACORASOLICITUD es un sinónimo/vista que apunta a EDYFICAR.SL_BITACORASOLICITUD@DWHPROD_TPZPROD
	 WHERE A.DETALLEDOS LIKE ''%PRE%PREST%''
    ';
    COMMIT; 
END;
/