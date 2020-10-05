DECLARE
  LV_ERROR          NUMBER;
  LV_MENSAJE_ERROR  VARCHAR2(1000);
BEGIN
  
--TRUNCADO DE TABLA ODS.HD_PRESTAMOS_REFINANCIADOS

  ODS.PKG_ODS_GENERICO.SP_TRUNCATE_TABLE(  V_OWNER => 'ODS',
                                           V_TABLA => 'HD_PRESTAMOS_REFINANCIADOS',
                                           V_ERROR => LV_ERROR,
                                           V_MENSAJE_ERROR => LV_MENSAJE_ERROR
                                          );										  
										  									  
END;
/
