CREATE OR REPLACE PROCEDURE DWHADM.SP_CARGA_INICIAL_HD_DESEMBOLSO IS
    CURSOR c1 IS
           SELECT table_owner, table_name, partition_name, z.num_rows
           FROM all_tab_partitions z
           WHERE table_owner = 'ODS'
             AND table_name  = 'HD_DESEMBOLSO'
           ORDER BY 3 ASC;
           
    lv_error          NUMBER;
    lv_mensaje_error  VARCHAR2(1000);
    ln_ind_existe     NUMBER(1);
BEGIN	
    ODS.PKG_ODS_GENERICO.SP_TRUNCATE_TABLE(
                                           V_OWNER => 'ODS',
                                           V_TABLA => 'TM_HD_DESEMBOLSO_CARGA_INICIAL',
                                           V_ERROR => lv_error,
                                           V_MENSAJE_ERROR => lv_mensaje_error
                                          );

    ODS.PKG_ODS_GENERICO.SP_GEN_PARTICIONES(
                                            V_TABLA_OWNER =>  'ODS',
                                            V_NOM_TABLA => 'TM_HD_DESEMBOLSO_CARGA_INICIAL',
                                            V_CAMPO_PARTICIONADO => 'NU_PERI_MES',
                                            V_TIPO_CAMPO_PARTICIONADO => 'NUMBER',
                                            V_FRECUENCIA_PARTICION => 'MENSUAL',
                                            V_NOMBRE_PARTICION => 'P_DESEMBOLSO_',
                                            V_NUM_PARTICIONES_MAX => 20000,
                                            V_TABLESPACE_PARTICION => 'ODS_DATA_01',
                                            V_ERROR => lv_error,
                                            V_MENSAJE_ERROR => lv_mensaje_error           
                                           );

    BDS.PKG_BDS_GENERICO.SP_REGENERA_INDICE(V_OWNER => 'ODS',
                                            V_TABLA => 'HD_DESEMBOLSO',
                                            V_ERROR => lv_error);   
    FOR r1 IN c1 LOOP    
        EXECUTE IMMEDIATE
        '
        INSERT /*+ APPEND */ INTO ODS.TM_HD_DESEMBOLSO_CARGA_INICIAL
        (
         NU_PERI_MES,
         FE_ULTI_DIA_MES,
         FE_APER_CUEN,
         NU_PRESTAMO,
         CO_CLIENTE,
         MO_APRO_DESE,
         MO_DESEMBOLSADO,
         DE_MONEDA,
         TI_DESEMBOLSO,
         MO_RECU_SALD,
         MO_DESE_CAJA,
         CO_SUCU_ORIG,
         MO_SOLICITADO,
         NU_DIA_PROG_PAGO,
         NO_CLIENTE,
         NO_VIA_DESE_PLAT,
         NO_SUCU_ORIG,
         NU_ASIE_PLAT,
         CO_USUA_DESE_PLAT,
         CO_FUNC_DESE_PLAT,
         NO_USUA_DESE_PLAT,
         CO_SUCU_DESE_PLAT,
         NO_SUCU_DESE_PLAT,
         NU_ASIE_CAJA,
         CO_USUA_DESE_CAJA,
         CO_FUNC_DESE_CAJA,
         NO_USUA_DESE_CAJA,
         CO_SUCU_DESE_CAJA,
         NO_SUCU_DESE_CAJA,
         FE_ACTU_MES,
         FE_DESE_PLAT,
         FE_DESE_CAJA,
         NU_SOLICITUD,
         NU_PARTICIPANTES,
         DE_CARG_USUA_PLAT,
         DE_CARG_USUA_CAJA,
         NU_LINE_CRED,
         MO_CUOTA,
         NU_CUOTAS,
         FE_DESEMBOLSO,
         CO_REFINANCIACION,
         CO_GRUP_EXCE,
		 CO_USUA_TOPA_DESE
        )
        SELECT A.NU_PERI_MES,
               A.FE_ULTI_DIA_MES,
               A.FE_APER_CUEN,
               A.NU_PRESTAMO,
               A.CO_CLIENTE,
               A.MO_DESEMBOLSADO,
               A.MO_APRO_DESE,
               A.DE_MONEDA,
               A.TI_DESEMBOLSO,
               A.MO_RECU_SALD,
               A.MO_DESE_CAJA,
               A.CO_SUCU_ORIG,
               A.MO_SOLICITADO,
               A.NU_DIA_PROG_PAGO,
               A.NO_CLIENTE,
               A.NO_VIA_DESE_PLAT,
               A.NO_SUCU_ORIG,
               A.NU_ASIE_PLAT,
               A.CO_USUA_DESE_PLAT,
               A.CO_FUNC_DESE_PLAT,
               A.NO_USUA_DESE_PLAT,
               A.CO_SUCU_DESE_PLAT,
               A.NO_SUCU_DESE_PLAT,
               A.NU_ASIE_CAJA,
               A.CO_USUA_DESE_CAJA,
               A.CO_FUNC_DESE_CAJA,
               A.NO_USUA_DESE_CAJA,
               A.CO_SUCU_DESE_CAJA,
               A.NO_SUCU_DESE_CAJA,
               A.FE_ACTU_MES,
               A.FE_DESE_PLAT,
               A.FE_DESE_CAJA,
               A.NU_SOLICITUD,
               A.NU_PARTICIPANTES,
               A.DE_CARG_USUA_PLAT,
               A.DE_CARG_USUA_CAJA,
               B.C1661   AS NU_LINE_CRED,
               C.C5037   AS MO_CUOTA,
               C.C5186   AS NU_CUOTAS,
               B.C1621   AS FE_DESEMBOLSO,
               B.REFINANCIACION AS CO_REFINANCIACION,
               NULL AS CO_GRUP_EXCE,
			   B.USUTOPAZ AS CO_USUA_TOPA_DESE
        FROM ODS.HD_DESEMBOLSO PARTITION ('||r1.partition_name||') A   
        LEFT JOIN SALDOS B ON B.CUENTA = A.NU_PRESTAMO AND B.TZ_LOCK = 0 AND B.C9314 = 5 AND B.OPERACION = 0   -- SALDOS es un sinónimo/vista que apunta a EDYFICAR.SALDOS@DWHPROD_TPZPROD
        LEFT JOIN SL_SOLICITUDCREDITO C ON C.C5000 = A.NU_SOLICITUD                                            -- SL_SOLICITUDCREDITO es un sinónimo/vista que apunta a EDYFICAR.SL_SOLICITUDCREDITO@DWHPROD_TPZPROD
        ';
        COMMIT;
        
        ODS.PKG_ODS_GENERICO.SP_ESTADISTICAS_PARTITION(V_FECHA_INICIO => TO_DATE(SUBSTR(r1.partition_name,14),'YYYYMM'),
                                                       V_FECHA_FIN => TO_DATE(SUBSTR(r1.partition_name,14),'YYYYMM'),
                                                       V_TABLA_OWNER => 'ODS', 
                                                       V_NOM_TABLA => 'TM_HD_DESEMBOLSO_CARGA_INICIAL',
                                                       V_FRECUENCIA_PARTICION => 'MENSUAL',
                                                       V_NOMBRE_PARTICION => 'P_DESEMBOLSO_',
                                                       V_ERROR => lv_error,
                                                       V_MENSAJE_ERROR => lv_mensaje_error);
            
    END LOOP;
END;
/