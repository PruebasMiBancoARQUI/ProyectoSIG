DECLARE
    CURSOR c1 IS
           SELECT table_owner, table_name, partition_name, z.num_rows
           FROM all_tab_partitions z
           WHERE table_owner = 'ODS'
             AND table_name  = 'HD_DESEMBOLSO'
           ORDER BY 3 ASC;
           
    lv_error          NUMBER;
    lv_mensaje_error  VARCHAR2(1000);
    ln_ind_existe     NUMBER(1);
    ln_cant_1         NUMBER;
    ln_cant_2         NUMBER;
BEGIN
    -- PRIMERA PARTE
    BEGIN
        SELECT 1 
        INTO ln_ind_existe
		FROM ALL_TABLES
        WHERE OWNER      = 'ODS'
          AND TABLE_NAME = 'TP_HD_DESEMBOLSO_CASO22417';
        
        -- Si existe la tabla, se elimina											  
        EXECUTE IMMEDIATE 'DROP TABLE ODS.TP_HD_DESEMBOLSO_CASO22417 PURGE';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN NULL; -- Si la tabla no existe en el siguiente paso se creará
    END;
    
    EXECUTE IMMEDIATE
    '
     CREATE TABLE ODS.TP_HD_DESEMBOLSO_CASO22417
     (
       NU_PERI_MES       NUMBER(15)    DEFAULT 0,
       FE_ULTI_DIA_MES   DATE          DEFAULT TO_DATE(''01010001'',''DDMMYYYY''),
       FE_APER_CUEN      DATE          DEFAULT TO_DATE(''01010001'',''DDMMYYYY''),
       NU_PRESTAMO       NUMBER(15)    DEFAULT 0,
       CO_CLIENTE        NUMBER(15)    DEFAULT 0,
       MO_APRO_DESE      NUMBER(15,2)  DEFAULT 0,
       MO_DESEMBOLSADO   NUMBER(15,2)  DEFAULT 0,
       DE_MONEDA         VARCHAR2(150) DEFAULT ''.'',
       TI_DESEMBOLSO     VARCHAR2(100) DEFAULT ''.'',
       MO_RECU_SALD      NUMBER(15,2)  DEFAULT 0,
       MO_DESE_CAJA      NUMBER(15,2)  DEFAULT 0,
       CO_SUCU_ORIG      NUMBER(15)    DEFAULT 0,
       MO_SOLICITADO     NUMBER(15,2)  DEFAULT 0,
       NU_DIA_PROG_PAGO  NUMBER(15)    DEFAULT 0,
       NO_CLIENTE        VARCHAR2(100) DEFAULT ''.'',
       NO_VIA_DESE_PLAT  VARCHAR2(100) DEFAULT ''.'',
       NO_SUCU_ORIG      VARCHAR2(100) DEFAULT ''.'',
       NU_ASIE_PLAT      NUMBER(15)    DEFAULT 0,
       CO_USUA_DESE_PLAT VARCHAR2(50)  DEFAULT ''.'',
       CO_FUNC_DESE_PLAT NUMBER(15)    DEFAULT 0,
       NO_USUA_DESE_PLAT VARCHAR2(100) DEFAULT ''.'',
       CO_SUCU_DESE_PLAT NUMBER(15)    DEFAULT 0,
       NO_SUCU_DESE_PLAT VARCHAR2(100) DEFAULT ''.'',
       NU_ASIE_CAJA      NUMBER(15)    DEFAULT 0,
       CO_USUA_DESE_CAJA VARCHAR2(50)  DEFAULT ''.'',
       CO_FUNC_DESE_CAJA NUMBER(15)    DEFAULT 0,
       NO_USUA_DESE_CAJA VARCHAR2(100) DEFAULT ''.'',
       CO_SUCU_DESE_CAJA NUMBER(15)    DEFAULT 0,
       NO_SUCU_DESE_CAJA VARCHAR2(100) DEFAULT ''.'',
       FE_ACTU_MES       DATE          DEFAULT TO_DATE(''01010001'',''DDMMYYYY''),
       FE_DESE_PLAT      DATE          DEFAULT TO_DATE(''01010001'',''DDMMYYYY''),
       FE_DESE_CAJA      DATE          DEFAULT TO_DATE(''01010001'',''DDMMYYYY''),
       NU_SOLICITUD      NUMBER(15)    DEFAULT 0,
       NU_PARTICIPANTES  NUMBER(15)    DEFAULT 0,
       DE_CARG_USUA_PLAT VARCHAR2(150) DEFAULT ''.'',
       DE_CARG_USUA_CAJA VARCHAR2(150) DEFAULT ''.'',
       NU_LINE_CRED      NUMBER(15),
       MO_CUOTA          NUMBER(15,2),
       NU_CUOTAS         NUMBER(15),
       FE_DESEMBOLSO     DATE,
       CO_REFINANCIACION VARCHAR2(1),
       CO_GRUP_EXCE      NUMBER(15),
       CO_USUA_TOPA_DESE VARCHAR2(10) 
     )
     PARTITION BY RANGE (NU_PERI_MES)
     (
       PARTITION P_DESEMBOLSO_201401 VALUES LESS THAN (201402) TABLESPACE ODS_DATA_01
     )
	  ';
    
    ODS.PKG_ODS_GENERICO.SP_GEN_PARTICIONES(
                                            V_TABLA_OWNER =>  'ODS',
                                            V_NOM_TABLA => 'TP_HD_DESEMBOLSO_CASO22417',
                                            V_CAMPO_PARTICIONADO => 'NU_PERI_MES',
                                            V_TIPO_CAMPO_PARTICIONADO => 'NUMBER',
                                            V_FRECUENCIA_PARTICION => 'MENSUAL',
                                            V_NOMBRE_PARTICION => 'P_DESEMBOLSO_',
                                            V_NUM_PARTICIONES_MAX => 20000,
                                            V_TABLESPACE_PARTICION => 'ODS_DATA_01',
                                            V_ERROR => lv_error,
                                            V_MENSAJE_ERROR => lv_mensaje_error           
                                           );
    
    ODS.PKG_ODS_GENERICO.SP_REGENERA_INDICE(V_ESQUEMA => 'ODS',
                                            V_NOMTABLA => 'HD_DESEMBOLSO',
                                            V_ERROR => lv_error);

    BEGIN
        SELECT 1
        INTO ln_ind_existe
        FROM ALL_TABLES
        WHERE OWNER      = 'ODS'
          AND TABLE_NAME = 'TP_HD_DESEMBOLSO_BKP_CASO22417';
        
        -- Si existe la tabla, se elimina											  
        EXECUTE IMMEDIATE 'DROP TABLE ODS.TP_HD_DESEMBOLSO_BKP_CASO22417 PURGE';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN NULL; -- Si la tabla no existe en el siguiente paso se creará
    END;

    -- Se crea la tabla backup de ODS.HD_DESEMBOLSO
    EXECUTE IMMEDIATE 'CREATE TABLE ODS.TP_HD_DESEMBOLSO_BKP_CASO22417 PCTFREE 0 NOLOGGING TABLESPACE TEMPORAL_PROD AS SELECT * FROM ODS.HD_DESEMBOLSO';    
		
    -- Se carga la tabla ODS.TP_HD_DESEMBOLSO_CASO22417 desde la tabla ODS.HD_DESEMBOLSO con datos corregidos - Partición por partición
    FOR r1 IN c1 LOOP    
        EXECUTE IMMEDIATE
        '
         INSERT /*+ APPEND */ INTO ODS.TP_HD_DESEMBOLSO_CASO22417
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
         WITH SUBQ1 AS
              (
               SELECT t.NU_PRESTAMO, 
                      s.C1661 AS NU_LINE_CRED,
                      s.C1621 AS FE_DESEMBOLSO,
                      s.REFINANCIACION AS CO_REFINANCIACION,
                      s.USUTOPAZ AS CO_USUA_TOPA_DESE
               FROM ODS.HD_DESEMBOLSO t
               INNER JOIN DWHADM.SALDOS s ON s.CUENTA = t.NU_PRESTAMO AND s.C9314 = 5 AND s.OPERACION = 0
               WHERE t.FE_DESEMBOLSO IS NULL
              )
         SELECT a.NU_PERI_MES,
                a.FE_ULTI_DIA_MES,
                a.FE_APER_CUEN,
                a.NU_PRESTAMO,
                a.CO_CLIENTE,
                a.MO_DESEMBOLSADO,
                a.MO_APRO_DESE,
                a.DE_MONEDA,
                a.TI_DESEMBOLSO,
                a.MO_RECU_SALD,
                a.MO_DESE_CAJA,
                a.CO_SUCU_ORIG,
                a.MO_SOLICITADO,
                a.NU_DIA_PROG_PAGO,
                a.NO_CLIENTE,
                a.NO_VIA_DESE_PLAT,
                a.NO_SUCU_ORIG,
                a.NU_ASIE_PLAT,
                a.CO_USUA_DESE_PLAT,
                a.CO_FUNC_DESE_PLAT,
                a.NO_USUA_DESE_PLAT,
                a.CO_SUCU_DESE_PLAT,
                a.NO_SUCU_DESE_PLAT,
                a.NU_ASIE_CAJA,
                a.CO_USUA_DESE_CAJA,
                a.CO_FUNC_DESE_CAJA,
                a.NO_USUA_DESE_CAJA,
                a.CO_SUCU_DESE_CAJA,
                a.NO_SUCU_DESE_CAJA,
                a.FE_ACTU_MES,
                a.FE_DESE_PLAT,
                a.FE_DESE_CAJA,
                CASE
                   WHEN a.NU_SOLICITUD = 0 THEN b.C1704
                   ELSE a.NU_SOLICITUD
                END AS NU_SOLICITUD,
                a.NU_PARTICIPANTES,
                a.DE_CARG_USUA_PLAT,
                a.DE_CARG_USUA_CAJA,
                CASE
                   WHEN d.NU_PRESTAMO IS NOT NULL THEN d.NU_LINE_CRED
                   ELSE a.NU_LINE_CRED
                END AS NU_LINE_CRED, 
                C.C5037   AS MO_CUOTA,
                C.C5186   AS NU_CUOTAS,
                CASE
                   WHEN d.NU_PRESTAMO IS NOT NULL THEN d.FE_DESEMBOLSO
                   ELSE a.FE_DESEMBOLSO
                END AS FE_DESEMBOLSO,
                CASE
                   WHEN d.NU_PRESTAMO IS NOT NULL THEN d.CO_REFINANCIACION
                   ELSE a.CO_REFINANCIACION
                END AS CO_REFINANCIACION,
                a.CO_GRUP_EXCE, 
                CASE
                   WHEN d.NU_PRESTAMO IS NOT NULL THEN d.CO_USUA_TOPA_DESE
                   ELSE a.CO_USUA_TOPA_DESE
                END AS CO_USUA_TOPA_DESE
         FROM ODS.HD_DESEMBOLSO PARTITION ('||r1.partition_name||') a   
         LEFT JOIN STG.T_TMP_MONTOS_SALDOS b ON b.CUENTA = a.NU_PRESTAMO
         LEFT JOIN DWHADM.SL_SOLICITUDCREDITO c ON c.C5000 = b.C1704 -- SL_SOLICITUDCREDITO es un sinónimo/vista que apunta a EDYFICAR.SL_SOLICITUDCREDITO@DWHPROD_TPZPROD
         LEFT JOIN SUBQ1 d ON d.NU_PRESTAMO = a.NU_PRESTAMO
        ';
        COMMIT;
        
        ODS.PKG_ODS_GENERICO.SP_ESTADISTICAS_PARTITION(V_FECHA_INICIO => TO_DATE(SUBSTR(r1.partition_name,14),'YYYYMM'),
                                                       V_FECHA_FIN => TO_DATE(SUBSTR(r1.partition_name,14),'YYYYMM'),
                                                       V_TABLA_OWNER => 'ODS', 
                                                       V_NOM_TABLA => 'TP_HD_DESEMBOLSO_CASO22417',
                                                       V_FRECUENCIA_PARTICION => 'MENSUAL',
                                                       V_NOMBRE_PARTICION => 'P_DESEMBOLSO_',
                                                       V_ERROR => lv_error,
                                                       V_MENSAJE_ERROR => lv_mensaje_error);            
    END LOOP;
	  
    -- SEGUNDA PARTE
    EXECUTE IMMEDIATE 'SELECT COUNT(1) FROM ODS.TP_HD_DESEMBOLSO_CASO22417' INTO ln_cant_1;	
    IF   ln_cant_1 > 0 THEN
         EXECUTE IMMEDIATE 'SELECT COUNT(1) FROM ODS.TP_HD_DESEMBOLSO_BKP_CASO22417' INTO ln_cant_2;
         
         -- Se verifica que la cantidad de registro de la tabla temporal cargada sea igual a la tabla backup de ODS.HD_DESEMBOLSO
         IF   ln_cant_1 = ln_cant_2 THEN
              EXECUTE IMMEDIATE 'DROP INDEX ODS.HD_DESEMBOLSO_N1';
              EXECUTE IMMEDIATE 'DROP INDEX ODS.HD_DESEMBOLSO_N2';
              
              -- Se trunca la tabla ODS.HD_DESEMBOLSO
              ODS.PKG_ODS_GENERICO.SP_TRUNCATE_TABLE(
                                                     V_OWNER => 'ODS',
                                                     V_TABLA => 'HD_DESEMBOLSO',
                                                     V_ERROR => lv_error,
                                                     V_MENSAJE_ERROR => lv_mensaje_error
                                                    );
              
              -- Se carga la tabla ODS.HD_DESEMBOLSO desde la tabla ODS.TP_HD_DESEMBOLSO_CASO22417 partición por partición  
              FOR  r1 IN c1 LOOP 
                   EXECUTE IMMEDIATE
                   '
                    INSERT /*+ APPEND */ INTO ODS.HD_DESEMBOLSO
                          (NU_PERI_MES,
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
                           CO_USUA_TOPA_DESE)
                    SELECT NU_PERI_MES,
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
                    FROM ODS.TP_HD_DESEMBOLSO_CASO22417 PARTITION ('||r1.partition_name||') A  
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
              
              EXECUTE IMMEDIATE 'DROP TABLE ODS.TP_HD_DESEMBOLSO_CASO22417 PURGE';
         ELSE
	            RAISE_APPLICATION_ERROR(-20010,'NO SE CARGO LA CANTIDAD DE REGISTROS CORRECTA EN LA TABLA ODS.TP_HD_DESEMBOLSO_CASO22417');
	     END IF;
	  ELSE
	       RAISE_APPLICATION_ERROR(-20010,'NO SE CARGO REGISTROS EN LA TABLA ODS.TP_HD_DESEMBOLSO_CASO22417');
	  END IF;
END;
/
