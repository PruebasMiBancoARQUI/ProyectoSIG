DECLARE
        LV_FILA           NUMBER(5):=0;      
        LV_ERROR          VARCHAR2(1000);
        LV_MENSAJE_ERROR  VARCHAR2(1000); 
        LV_COMANDO        VARCHAR2(1000);        
        
        CURSOR REF_EXT IS 
            SELECT  
            ref.NU_PRES_ORIG          AS NU_PRES_ORIG, 
            TO_CHAR(pre.C1621,'YYYYMM') AS NU_PERI_MES_ORIG,
            pre.PRODUCTO              AS CO_PROD_ORIG,
            ref.NU_PRESTAMO           AS NU_PRES_FIN,
            ref.NU_PERI_MES_FIN       AS NU_PERI_MES_FIN, 
            SUBSTR(REPLACE(ref.VL_PORC_PART,',','.'),2,LENGTH(VL_PORC_PART)) AS VL_PORC_PART
            FROM (SELECT 
                  NU_PRES_CANC                                 AS NU_PRES_CANC, 
                  NU_PRESTAMO                                  AS NU_PRESTAMO, 
                  LEVEL                                        AS NIVEL, 
                  VL_PORC_PRES_CANC                            AS VL_PORC_PRES_CANC,
                  TO_NUMBER(TO_CHAR(FE_DESEMBOLSO,'YYYYMM'))   AS NU_PERI_MES_FIN,
                  SYS_CONNECT_BY_PATH (VL_PORC_PRES_CANC,'*')  AS VL_PORC_PART,
                  CONNECT_BY_ROOT NU_PRES_CANC                 AS NU_PRES_ORIG
                  FROM ODS.HD_PRESTAMOS_REFINANCIADOS CONNECT BY NU_PRES_CANC = PRIOR NU_PRESTAMO
                  ) ref                 
            INNER JOIN (
                  SELECT 
                  NU_PRES_ORIG     AS NU_PRES_ORIG, 
                  MAX(nivel)       AS NIVEL 
                  FROM ( 
                       SELECT 
                       CONNECT_BY_ROOT NU_PRES_CANC AS NU_PRES_ORIG, 
                       LEVEL                        AS NIVEL    
                       FROM ODS.HD_PRESTAMOS_REFINANCIADOS CONNECT BY NU_PRES_CANC = PRIOR NU_PRESTAMO
                       ) ref_1 
                  GROUP BY NU_PRES_ORIG) ref_2 
                  ON ref.NU_PRES_ORIG=ref_2.NU_PRES_ORIG AND ref.NIVEL=ref_2.NIVEL
            LEFT JOIN STG.T_SALDOS pre                            
                 ON pre.CUENTA=ref_2.NU_PRES_ORIG and pre.OPERACION=0 and pre.C9314=5
            LEFT JOIN ODS.MD_EXTORNOS_DESEMBOLSOS ext ON ext.NU_PRESTAMO = ref.NU_PRESTAMO
            WHERE ext.NU_PRESTAMO IS NULL;

        FUNCTION MULT_CADENA(S_PORC_PART   VARCHAR2) 
        RETURN NUMBER IS
        V_RESULTADO   NUMBER;
        BEGIN
            EXECUTE IMMEDIATE 'SELECT '||S_PORC_PART||' FROM dual' INTO V_RESULTADO;
            RETURN V_RESULTADO;
        END;   

BEGIN
    BDS.PKG_BDS_GENERICO.SP_TRUNCATE_TABLE(
                                           V_OWNER => 'BDS',
                                           V_TABLA => 'F_RIE_REF_EXTREMO',
                                           V_ERROR => lv_error,
                                           V_MENSAJE_ERROR => lv_mensaje_error
                                          );  
                                          
    FOR R1 IN REF_EXT LOOP

       LV_COMANDO := 'INSERT INTO BDS.F_RIE_REF_EXTREMO ( NU_PRES_ORIG, NU_PERI_MES_ORIG, CO_PROD_ORIG, NU_PRES_FINA, NU_PERI_MES_FINA, VL_PORC_PART, FE_ACTU_DIA)
       VALUES ( '||NVL(R1.NU_PRES_ORIG,0)||', '||NVL(R1.NU_PERI_MES_ORIG,0)||', '||NVL(R1.CO_PROD_ORIG,0)||', '
                 ||NVL(R1.NU_PRES_FIN ,0)||', '||NVL( R1.NU_PERI_MES_FIN,0)||', '||NVL(R1.VL_PORC_PART,0)||', SYSDATE )'
       ;
       EXECUTE IMMEDIATE LV_COMANDO;
       
       
       LV_FILA := LV_FILA +1;
       IF LV_FILA >= 5000 THEN
          LV_FILA := 0;
          COMMIT;
       END IF;
            
    END LOOP;
    COMMIT;
END;
/
