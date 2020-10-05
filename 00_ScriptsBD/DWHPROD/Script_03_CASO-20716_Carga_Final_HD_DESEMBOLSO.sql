DECLARE
    CURSOR c1 IS
           SELECT table_owner, table_name, partition_name, z.num_rows
           FROM all_tab_partitions z
           WHERE table_owner = 'ODS'
             AND table_name  = 'HD_DESEMBOLSO'
           ORDER BY 3 ASC;
           
    lv_error          NUMBER;
    lv_mensaje_error  VARCHAR2(1000);
    ln_cant_1         NUMBER;
	ln_cant_2         NUMBER;
BEGIN
    EXECUTE IMMEDIATE 'SELECT COUNT(1) FROM ODS.TM_HD_DESEMBOLSO_CARGA_INICIAL' INTO ln_cant_1;
	
	IF   ln_cant_1 > 0 THEN
         EXECUTE IMMEDIATE 'SELECT COUNT(1) FROM ODS.TP_HD_DESEMBOLSO_BKP_CARGA_INI' INTO ln_cant_2;
	     
	     IF   ln_cant_1 = ln_cant_2 THEN
              EXECUTE IMMEDIATE 'DROP INDEX ODS.HD_DESEMBOLSO_N1';
              EXECUTE IMMEDIATE 'DROP INDEX ODS.HD_DESEMBOLSO_N2';
		 
	          ODS.PKG_ODS_GENERICO.SP_TRUNCATE_TABLE(
                                                    V_OWNER => 'ODS',
                                                    V_TABLA => 'HD_DESEMBOLSO',
                                                    V_ERROR => lv_error,
                                                    V_MENSAJE_ERROR => lv_mensaje_error
                                                   );
												   
              FOR  r1 IN c1 LOOP    
                   EXECUTE IMMEDIATE
                   '
                    INSERT /*+ APPEND */ INTO ODS.HD_DESEMBOLSO
		            SELECT *
		            FROM ODS.TM_HD_DESEMBOLSO_CARGA_INICIAL PARTITION ('||r1.partition_name||') A  
                   ';
                   COMMIT;
        
                   ODS.PKG_ODS_GENERICO.SP_ESTADISTICAS_PARTITION(V_FECHA_INICIO => TO_DATE(SUBSTR(r1.partition_name,14),'YYYYMM'),
                                                                  V_FECHA_FIN => TO_DATE(SUBSTR(r1.partition_name,14),'YYYYMM'),
                                                                  V_TABLA_OWNER => 'ODS', 
                                                                  V_NOM_TABLA => 'HD_DESEMBOLSO',
                                                                  V_FRECUENCIA_PARTICION => 'MENSUAL',
                                                                  V_NOMBRE_PARTICION => 'P_DESEMBOLSO_',
                                                                  V_ERROR => lv_error,
                                                                  V_MENSAJE_ERROR => lv_mensaje_error);
              END LOOP;	

              EXECUTE IMMEDIATE 'CREATE INDEX ODS.HD_DESEMBOLSO_N1 ON ODS.HD_DESEMBOLSO (NU_PERI_MES, FE_APER_CUEN) TABLESPACE ODS_IDX_01';
              EXECUTE IMMEDIATE 'CREATE INDEX ODS.HD_DESEMBOLSO_N2 ON ODS.HD_DESEMBOLSO (NU_SOLICITUD) TABLESPACE ODS_IDX_01';
			  
	     ELSE
	          RAISE_APPLICATION_ERROR(-20010,'NO SE CARGÓ LA CANTIDAD DE REGISTROS CORRECTA EN LA TABLA ODS.TM_HD_DESEMBOLSO_CARGA_INICIAL');
	     END IF;
	ELSE
	     RAISE_APPLICATION_ERROR(-20010,'NO SE CARGÓ REGISTROS EN LA TABLA ODS.TM_HD_DESEMBOLSO_CARGA_INICIAL');
	END IF;
END;
/