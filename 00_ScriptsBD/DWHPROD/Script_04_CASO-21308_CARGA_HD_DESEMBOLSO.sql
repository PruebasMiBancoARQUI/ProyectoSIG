DECLARE
    ld_fecinicio   DATE := TO_DATE('20161231','YYYYMMDD');
    ld_fecfin      DATE := TO_DATE('20170201','YYYYMMDD');
    ln_ind_existe  NUMBER(1);
BEGIN
    --Se crea un backup de la tabla ODS.HD_DESEMBOLSO
    BEGIN
         SELECT 1 INTO ln_ind_existe
         FROM ALL_TABLES
         WHERE OWNER = 'ODS'
           AND TABLE_NAME = 'TP_HD_DESEMBOLSO_BKP_PRES_FALT';
    EXCEPTION
         WHEN NO_DATA_FOUND THEN NULL;
              EXECUTE IMMEDIATE
              'CREATE TABLE ODS.TP_HD_DESEMBOLSO_BKP_PRES_FALT PCTFREE 0 NOLOGGING TABLESPACE TEMPORAL_PROD AS SELECT * FROM ODS.HD_DESEMBOLSO';
    END;
    
    LOOP
        BEGIN
             SELECT 1 INTO ln_ind_existe
             FROM ALL_TABLES
             WHERE OWNER = 'ODS'
               AND TABLE_NAME = 'TP_DESEMBOLSOS_FALTANTES_01';
              
             EXECUTE IMMEDIATE 'DROP TABLE ODS.TP_DESEMBOLSOS_FALTANTES_01 PURGE';
        EXCEPTION
             WHEN NO_DATA_FOUND THEN NULL;
        END;
        
        EXECUTE IMMEDIATE
        '
        CREATE TABLE ODS.TP_DESEMBOLSOS_FALTANTES_01 NOLOGGING PCTFREE 0 TABLESPACE TEMPORAL_PROD AS
               SELECT C.CUENTA
               FROM DWHADM.SALDOS  C
               WHERE C.TZ_LOCK = 0
                 AND C.C9314 = 5
                 AND C.OPERACION = 0
                 AND C.C1621 > TO_DATE('''||TO_CHAR(ld_fecinicio,'YYYYMMDD')||''',''YYYYMMDD'')
                 AND C.C1621 < TO_DATE('''||TO_CHAR(ld_fecfin,'YYYYMMDD')||''',''YYYYMMDD'')
               MINUS
               SELECT D.NU_PRESTAMO
               FROM ODS.HD_DESEMBOLSO D
        ';
        
        BEGIN
             SELECT 1 INTO ln_ind_existe
             FROM ALL_TABLES
             WHERE OWNER = 'ODS'
               AND TABLE_NAME = 'TP_DESEMBOLSOS_FALTANTES_02';
              
             EXECUTE IMMEDIATE 'DROP TABLE ODS.TP_DESEMBOLSOS_FALTANTES_02 PURGE';
        EXCEPTION
             WHEN NO_DATA_FOUND THEN NULL;
        END;

        EXECUTE IMMEDIATE 
        '
        CREATE TABLE ODS.TP_DESEMBOLSOS_FALTANTES_02 NOLOGGING PCTFREE 0 TABLESPACE TEMPORAL_PROD AS
               SELECT /*+ PARALLEL(B,4) */
                      a.CUENTA, 
                      a.C1620, 
                      a.C1621,
                      a.C1803,
                      a.C1601,
                      a.C1661,
                      a.C1704,
                      a.C9314,
                      a.MONEDA,
                      a.SUCURSAL,
                      a.REFINANCIACION,
                      a.USUTOPAZ,
                      a.OPERACION,
                      a.TZ_LOCK
               FROM ODS.TP_DESEMBOLSOS_FALTANTES_01 B 
               INNER JOIN DWHADM.SALDOS A ON A.CUENTA = B.CUENTA
        ';
        
        BEGIN
             SELECT 1 INTO ln_ind_existe
             FROM ALL_TABLES
             WHERE OWNER = 'ODS'
               AND TABLE_NAME = 'TP_DESEMBOLSOS_FALTANTES_03';
              
             EXECUTE IMMEDIATE 'DROP TABLE ODS.TP_DESEMBOLSOS_FALTANTES_03 PURGE';
        EXCEPTION
             WHEN NO_DATA_FOUND THEN NULL;
        END;

        EXECUTE IMMEDIATE 
        '
        CREATE TABLE ODS.TP_DESEMBOLSOS_FALTANTES_03 NOLOGGING PCTFREE 0 TABLESPACE TEMPORAL_PROD AS
            WITH DESEMBOLSOS_FALTANTES AS
            (
              SELECT *
              FROM ODS.TP_DESEMBOLSOS_FALTANTES_02
              WHERE TZ_LOCK = 0
                AND C9314 = 5
                AND OPERACION = 0 
                AND C1620 < TRUNC(SYSDATE)
            )
            SELECT /*+ PARALLEL(C,4) */
                   NVL(TO_NUMBER(TO_CHAR(C.C1620,''YYYYMM'')),0) AS NU_PERI_MES,
                   --@003 Ini: Se cambia el alias del campo C.C1620 de FE_VALOR a FE_APER_CUEN
                   NVL(C.C1620, to_date(''01010001'', ''DDMMYYYY''))   AS FE_APER_CUEN,
                   --@003 Fin 
                   NVL(C.CUENTA,0) AS NU_PRESTAMO,
                   NVL(C.C1803,0) AS CO_CLIENTE,
                   --@005 Ini: Se invierten campos - D.C5036 insertaba al campo MO_DESEMBOLSADO y C.C1601 insertaba al campo MO_APRO_DESE.
                   NVL(D.C5036,0) MO_APRO_DESE,
                   NVL(C.C1601,0) MO_DESEMBOLSADO,
                   --@005 Fin
                   NVL(CASE
                          WHEN C.MONEDA = 1 THEN ''SOLES''
                          ELSE ''DOLARES''
                       END,''.'') DE_MONEDA,
                   NVL(D.C5004,''.'') AS TI_DESEMBOLSO,
                   NVL(D.DEUDA_ACTUAL,0) AS MO_RECU_SALD,
                   NVL((SELECT IMPORTE
                        --FROM EDYFICAR.CA_PAGOSPORCAJA@DWHPROD_TPZPROD  A
                        FROM DWHADM.CA_PAGOSPORCAJA  A
                        WHERE A.NUMPAGO = D.C5045
                          AND A.ASIENTOSOLICITU = D.NROOPERACION
                          AND TZ_LOCK = 0
                          AND A.REFERENCIA = D.C5000
                       ),0) AS MO_DESE_CAJA,
                   NVL(C.SUCURSAL,0) AS CO_SUCU_ORIG,
                   NVL(D.C5023,0) AS MO_SOLICITADO,
                   NVL(D.DIA_PAGO,0) AS NU_DIA_PROG_PAGO,
                   NVL(F.C1000,''.'') AS NO_CLIENTE,
                   NVL(D.FORMADESEMBOLSO,''.'') AS NO_VIA_DESE_PLAT,
                   NVL(E1.C6020,''.'') AS NO_SUCU_ORIG,
                   NVL(D.NROOPERACION,0) AS NU_ASIE_PLAT,
                   NVL(DA.INIUSR,0) AS CO_USUA_DESE_PLAT,
                   NVL(D.USUDESEMB,0) AS CO_FUNC_DESE_PLAT,
                   NVL((SELECT U1.NOMBRE
                        --FROM EDYFICAR.USUARIOS@DWHPROD_TPZPROD  U1
                        FROM DWHADM.USUARIOS  U1
                        WHERE U1.INICIALES = DA.INIUSR
                   ),''.'') AS NO_USUA_DESE_PLAT,
                   NVL(DA.SUCURSAL,0) AS CO_SUCU_DESE_PLAT,
                   NVL(E2.C6020,''.'') AS NO_SUCU_DESE_PLAT,
                   NVL(P.ASIENTOPAGO,0) AS NU_ASIE_CAJA,
                   NVL(P.USUARIOPAGO,''.'') AS CO_USUA_DESE_CAJA,
                   NVL(M2.CODFUNCIONARIO,0) AS CO_FUNC_DESE_CAJA,
                   NVL((SELECT U2.NOMBRE
                        --FROM EDYFICAR.USUARIOS@DWHPROD_TPZPROD  U2
                        FROM DWHADM.USUARIOS  U2
                        WHERE U2.INICIALES = P.USUARIOPAGO
                       ),''.'') AS NO_USUA_DESE_CAJA,
                   NVL(P.SUCURSAL,0) AS CO_SUCU_DESE_CAJA,
                   NVL(E3.C6020,''.'') AS NO_SUCU_DESE_CAJA,
                   TO_CHAR(SYSDATE, ''DD/MM/YYYY'') AS FE_ACTU_MES,
                   NVL(DA.HORAINICIO,to_date(''01010001'', ''DDMMYYYY'')) AS FE_DESE_PLAT,
                   NVL(PA.HORAINICIO,to_date(''01010001'', ''DDMMYYYY'')) AS FE_DESE_CAJA,
                   NVL(A.NROSOLICITUD,0) AS NU_SOLICITUD,
                   (SELECT COUNT(1)
                        --FROM EDYFICAR.SL_SOLICITUDCREDITOPERSONA@DWHPROD_TPZPROD  P
                        FROM DWHADM.SL_SOLICITUDCREDITOPERSONA  P
                        WHERE P.TZ_LOCK = 0
                          AND P.C5080 = D.C5000
                          AND P.C5084 != ''T''
                   ) AS NU_PARTICIPANTES,
                   ''.'' AS DE_CARG_USUA_PLAT,
                   ''.'' AS DE_CARG_USUA_CAJA,
                   --@004 Ini: Se agregan 6 campos en el select 
                   NVL(C.C1661,0) AS NU_LINE_CRED,
                   NVL(D.C5037,0) AS MO_CUOTA,
                   NVL(D.C5186,0) AS NU_CUOTAS,
                   NVL(C.C1621,to_date(''01010001'', ''DDMMYYYY'')) AS FE_DESEMBOLSO,
                   NVL(C.REFINANCIACION,''.'') AS CO_REFINANCIACION,
                   NVL(C.USUTOPAZ,''.'') AS CO_USUA_TOPA_DESE
                    --@004 Fin
                    --FROM EDYFICAR.SALDOS@DWHPROD_TPZPROD  C
             FROM DESEMBOLSOS_FALTANTES C
             INNER JOIN DWHADM.SL_SOLICITUDCREDITO D ON D.C5000 = C.C1704
             INNER JOIN DWHADM.CL_CLIENTES F ON F.C0902 = C.C1803
             LEFT JOIN DWHADM.CA_PAGOSPORCAJA P ON (P.REFERENCIA = D.C5000) AND P.ESTADO = ''2'' AND P.TZ_LOCK = 0
             LEFT JOIN DWHADM.CR_HISTORICO_SOLICITUDES A ON C5000 = A.NROSOLICITUD AND A.OPERACION IN (2586, 2587, 2588, 2590)
             LEFT JOIN DWHADM.ASIENTOS PA ON P.SUCURSAL = PA.SUCURSAL AND P.ASIENTOPAGO = PA.ASIENTO AND P.FECHAPAGO = PA.FECHAPROCESO
             LEFT JOIN DWHADM.ASIENTOS DA ON A.SUCURSAL = DA.SUCURSAL AND A.ASIENTO = DA.ASIENTO AND A.FECHA = DA.FECHAPROCESO
             LEFT JOIN DWHADM.TC_SUCURSALES  E1 ON (E1.C6021 = D.C5001)
             LEFT JOIN DWHADM.TC_SUCURSALES  E2 ON (E2.C6021 = DA.SUCURSAL)
             LEFT JOIN DWHADM.TC_SUCURSALES  E3 ON (E3.C6021 = P.SUCURSAL)
             LEFT JOIN DWHADM.AU_RELFUNCIONARIOUSR  M2 ON (M2.USUARIOTOPAZ = P.USUARIOPAGO)
       ';
        
        EXECUTE IMMEDIATE
        '
        INSERT /*+ APPEND */ INTO ODS.HD_DESEMBOLSO
            (
             NU_PERI_MES,
             FE_ULTI_DIA_MES,
             --@001 Ini: Se cambia el nombre de FE_VALOR a FE_APER_CUEN en la tabla ODS.HD_DESEMBOLSO
             FE_APER_CUEN,
             --@001 Fin
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
             --@002 Ini: Se agregan 6 campos nuevos a la tabla ODS.HD_DESEMBOLSO
             NU_LINE_CRED,
             MO_CUOTA,
             NU_CUOTAS,
             FE_DESEMBOLSO,
             CO_REFINANCIACION,
             CO_USUA_TOPA_DESE
             --@002 Fin
            )
            SELECT /*+ PARALLEL(T,4) */
                   NVL(T.NU_PERI_MES, 0),
                   TRUNC(LAST_DAY(T.FE_DESEMBOLSO)),
                   --@003 Ini: Se selecciona el campo FE_APER_CUEN para la carga de la tabla ODS.HD_DESEMBOLSO
                   NVL(T.FE_APER_CUEN, to_date(''01010001'', ''DDMMYYYY'')),
                   --@003 Fin
                   NVL(T.NU_PRESTAMO, 0),
                   NVL(T.CO_CLIENTE, 0),
                   NVL(T.MO_APRO_DESE, 0),
                   NVL(T.MO_DESEMBOLSADO, 0),
                   NVL(T.DE_MONEDA, ''.''),
                   NVL(T.TI_DESEMBOLSO, ''.''),
                   NVL(T.MO_RECU_SALD, 0),
                   NVL(T.MO_DESE_CAJA, 0),
                   NVL(T.CO_SUCU_ORIG, 0),
                   NVL(T.MO_SOLICITADO, 0),
                   NVL(T.NU_DIA_PROG_PAGO, 0),
                   NVL(T.NO_CLIENTE, ''.''),
                   NVL(T.NO_VIA_DESE_PLAT, ''.''),
                   NVL(T.NO_SUCU_ORIG, ''.''),
                   NVL(T.NU_ASIE_PLAT, 0),
                   NVL(T.CO_USUA_DESE_PLAT, 0),
                   NVL(T.CO_FUNC_DESE_PLAT, 0),
                   NVL(T.NO_USUA_DESE_PLAT, ''.''),
                   NVL(T.CO_SUCU_DESE_PLAT, 0),
                   NVL(T.NO_SUCU_DESE_PLAT, ''.''),
                   NVL(T.NU_ASIE_CAJA, 0),
                   NVL(T.CO_USUA_DESE_CAJA, ''.''),
                   NVL(T.CO_FUNC_DESE_CAJA, 0),
                   NVL(T.NO_USUA_DESE_CAJA, ''.''),
                   NVL(T.CO_SUCU_DESE_CAJA, 0),
                   NVL(T.NO_SUCU_DESE_CAJA, ''.''),
                   NVL(T.FE_ACTU_MES, to_date(''01010001'', ''DDMMYYYY'')),
                   NVL(T.FE_DESE_PLAT, to_date(''01010001'', ''DDMMYYYY'')),
                   NVL(T.FE_DESE_CAJA, to_date(''01010001'', ''DDMMYYYY'')),
                   NVL(T.NU_SOLICITUD, 0),
                   NVL(T.NU_PARTICIPANTES, 0),
                   NVL(Z.DESCRIPCION, ''.'') AS DE_CARG_USUA_PLAT,
                   NVL(U.DESCRIPCION, ''.'') AS DE_CARG_USUA_CAJA, 
                   --@004 Ini: Se agregan 6 campos en el select para llenar la tabla ODS.HD_DESEMBOLSO
                   NVL(T.NU_LINE_CRED, 0),
                   NVL(T.MO_CUOTA, 0),
                   NVL(T.NU_CUOTAS, 0),
                   NVL(T.FE_DESEMBOLSO, to_date(''01010001'', ''DDMMYYYY'')),
                   NVL(T.CO_REFINANCIACION, ''.''),
                   NVL(T.CO_USUA_TOPA_DESE, ''.'')            
            FROM ODS.TP_DESEMBOLSOS_FALTANTES_03 T
            LEFT JOIN ODS.HD_PUESTO_CARGO_ANALISTA X ON X.FE_PROCESO = T.FE_APER_CUEN AND X.CO_USUA_TOPA = T.CO_USUA_DESE_PLAT
            LEFT JOIN ODS.HD_PUESTO_CARGO_ANALISTA Y ON Y.FE_PROCESO = T.FE_APER_CUEN AND Y.CO_USUA_TOPA = T.CO_USUA_DESE_CAJA
            LEFT JOIN DWHADM.RH_CARGOS Z ON Z.CODCARGO = X.CO_CARGO AND Z.TZ_LOCK = 0
            LEFT JOIN DWHADM.RH_CARGOS U ON U.CODCARGO = Y.CO_CARGO AND U.TZ_LOCK = 0
        ';
        COMMIT;

        EXECUTE IMMEDIATE 'DROP TABLE ODS.TP_DESEMBOLSOS_FALTANTES_01 PURGE';
        EXECUTE IMMEDIATE 'DROP TABLE ODS.TP_DESEMBOLSOS_FALTANTES_02 PURGE';
        EXECUTE IMMEDIATE 'DROP TABLE ODS.TP_DESEMBOLSOS_FALTANTES_03 PURGE';

        --dbms_output.put_line('Inicio: '||to_char(ld_fecinicio,'YYYYMMDD')||' - Fin: '||to_char(ld_fecfin,'YYYYMMDD'));
        EXIT WHEN ld_fecfin = TRUNC(SYSDATE) + 1;
                
        IF  TO_CHAR(ld_fecfin,'YYYYMM') = TO_CHAR(SYSDATE,'YYYYMM') THEN
            ld_fecinicio := ld_fecfin - 1;
            ld_fecfin    := TRUNC(SYSDATE) + 1;
        ELSE
            ld_fecinicio := ld_fecfin - 1;
            ld_fecfin    := LAST_DAY(ld_fecfin) + 1;
        END IF;
    END LOOP;
END;
/
