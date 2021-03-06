--CARGAR ETAPAS
INSERT INTO TOPAZETL.ETAPAS_CARGA_ODS VALUES (201,'CARGA DM FINANZAS','201-Carga_DM_FINANZAS_ETAPAS_202_al_205',0);
INSERT INTO TOPAZETL.ETAPAS_CARGA_ODS VALUES (202,'CARGA ODS BROAD PARA DATAMART FINANZAS','202-Carga_BROAD_ETAPA_202',0);

--CARGAR FASES
INSERT INTO TOPAZETL.FASES_CARGA_ODS VALUES (202,1,'CARGA TABLAS EN STG','202-1-ETAPA_202_FASE_1_Carga_Stage',0);
INSERT INTO TOPAZETL.FASES_CARGA_ODS VALUES (202,2,'CARGA TABLAS TEMPORALES EN ODS','202-2-ETAPA_202_FASE_2_Carga_ODS',0);
INSERT INTO TOPAZETL.FASES_CARGA_ODS VALUES (202,3,'CARGA TABLAS HISTORICAS EN ODS','202-3-ETAPA_202_FASE_3_Carga_Historica',0);

--CARGAR SUB FASES
INSERT INTO TOPAZETL.SUBFASES_CARGA_ODS VALUES (202,1,1,'CARGA TABLAS TOPAZ EN STG','202-1-1-ETAPA_202_FASE_1_SUBFASE_1_Carga_Stage',0);
INSERT INTO TOPAZETL.SUBFASES_CARGA_ODS VALUES (202,2,1,'CARGA TABLAS TEMPORALES DE PROCESO BROAD EN ODS','202-2-1-ETAPA_202_FASE_2_SUBFASE_1_Carga_ODS',0);
INSERT INTO TOPAZETL.SUBFASES_CARGA_ODS VALUES (202,3,1,'CARGA TABLAS HISTORICAS DE PROCESO BROAD CONTABLE EN ODS','202-3-1-ETAPA_202_FASE_3_SUBFASE_1_Carga_Historica',0);
INSERT INTO TOPAZETL.SUBFASES_CARGA_ODS VALUES (200,1,2,'CARGA TABLAS TRADER EN STG','200-1-2-ETAPA_200_FASE_1_SUBFASE_2_Carga_Stage',0);
INSERT INTO TOPAZETL.SUBFASES_CARGA_ODS VALUES (200,3,2,'CARGA TABLAS HISTORICAS TRADER EN ODS','200-3-2-ETAPA_200_FASE_3_SUBFASE_2_Carga_Diaria',0);

--CARGAR TABLAS TRUNCADAS
INSERT INTO TOPAZETL.TABLAS_TRUNCO_RETOMA VALUES (202,1,1,'T_BS_HISTORIA_PLAZO_CONTA','STG',0);
INSERT INTO TOPAZETL.TABLAS_TRUNCO_RETOMA VALUES (202,1,1,'T_CASIENTOMANUAL','STG',0);
INSERT INTO TOPAZETL.TABLAS_TRUNCO_RETOMA VALUES (202,1,1,'T_SALDOS_CONTA','STG',0);
INSERT INTO TOPAZETL.TABLAS_TRUNCO_RETOMA VALUES (202,2,1,'TP_BROAD_ASIENTOS','ODS',0);
INSERT INTO TOPAZETL.TABLAS_TRUNCO_RETOMA VALUES (202,2,1,'TP_BROAD_DETALLE','ODS',0);
INSERT INTO TOPAZETL.TABLAS_TRUNCO_RETOMA VALUES (202,2,1,'TP_BROAD_HISTORIA_PLAZO','ODS',0);
INSERT INTO TOPAZETL.TABLAS_TRUNCO_RETOMA VALUES (202,2,1,'TP_BROAD_MOVIMIENTO_CREDITO','ODS',0);
INSERT INTO TOPAZETL.TABLAS_TRUNCO_RETOMA VALUES (202,2,1,'TP_BROAD_MOVIMIENTO_DEBITO','ODS',0);
INSERT INTO TOPAZETL.TABLAS_TRUNCO_RETOMA VALUES (202,2,1,'TP_BROAD_INFORMACION_AHORROS','ODS',0);
INSERT INTO TOPAZETL.TABLAS_TRUNCO_RETOMA VALUES (200,1,2,'T_TDL_0001_CONTROL_DWH','STG',0);
INSERT INTO TOPAZETL.TABLAS_TRUNCO_RETOMA VALUES (200,1,2,'T_CONTABLE_TRADER','STG',0);
INSERT INTO TOPAZETL.TABLAS_TRUNCO_RETOMA VALUES (200,2,1,'TD_CONTABLE_TRADER','ODS',0);

--CARGA TABLA BASE_TIEMPO PARA LOS TIEMPOS PROMEDIOS
INSERT INTO TOPAZETL.BASE_TIEMPO VALUES (202,1,1,'CARGA TABLAS TOPAZ EN STG',22);
INSERT INTO TOPAZETL.BASE_TIEMPO VALUES (202,2,1,'CARGA TABLAS TEMPORALES DE PROCESO BROAD EN ODS',144);
INSERT INTO TOPAZETL.BASE_TIEMPO VALUES (202,3,1,'CARGA TABLAS HISTORICAS DE PROCESO BROAD CONTABLE EN ODS',85);
INSERT INTO TOPAZETL.BASE_TIEMPO VALUES (200,0,1,'CONTROL FIN DE CADENA',0);
INSERT INTO TOPAZETL.BASE_TIEMPO VALUES (200,1,1,'CARGAS TABLAS DETALLE CONTABLE EN STAGE',28);
INSERT INTO TOPAZETL.BASE_TIEMPO VALUES (200,1,2,'CARGA TABLAS TRADER EN STG',0);
INSERT INTO TOPAZETL.BASE_TIEMPO VALUES (200,2,1,'CARGA TABLAS TEMP DETALLE CONTABLE EN ODS',18);
INSERT INTO TOPAZETL.BASE_TIEMPO VALUES (200,3,1,'CARGAS HISTORICAS DETALLE CONTABLE EN ODS',15);
INSERT INTO TOPAZETL.BASE_TIEMPO VALUES (200,3,2,'CARGA TABLAS HISTORICAS TRADER EN ODS',0);

--CARGAR ESTADISTICAS
INSERT INTO TOPAZETL.TABLAS_GENERAR_ESTADISTICAS VALUES ('ODS','HD_BROAD_CONTABLE','S','P_HD_BROAD_CONTABLE_','MENSUAL');
INSERT INTO TOPAZETL.TABLAS_GENERAR_ESTADISTICAS VALUES ('ODS','HD_CONTABLE_TRADER','S','P_HD_CONTABLE_TRADER_','DIARIA');
COMMIT;
