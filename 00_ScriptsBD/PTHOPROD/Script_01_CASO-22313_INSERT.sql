-- Matricula componente Kettle en tabla SUBFASES_CARGA_ODS

-- SubFases ODS DATA ENTRY RIESGOS

INSERT INTO TOPAZETL.SUBFASES_CARGA_ODS (ID_ETAPA, ID_FASE, ID_SUBFASE, DE_SUBFASE, COMPONENTE_KETTLE)
VALUES ( 101, 1, 3, 'CARGA ODS DATA ENTRY AGENCIA NEGOCIOS', '101-1-3-ETAPA_101_FASE_1_SUBFASE_3_Carga_ODS_Agencia_Negocios'); 

INSERT INTO TOPAZETL.SUBFASES_CARGA_ODS (ID_ETAPA, ID_FASE, ID_SUBFASE, DE_SUBFASE, COMPONENTE_KETTLE)
VALUES ( 101, 1, 4, 'CARGA ODS DATA ENTRY GEOLOCALIZACION AGENCIA', '101-1-4-ETAPA_101_FASE_1_SUBFASE_4_Carga_ODS_Geolocalizacion_Agencia'); 

-- SubFases BDS DATA ENTRY RIESGOS

INSERT INTO TOPAZETL.SUBFASES_CARGA_ODS (ID_ETAPA, ID_FASE, ID_SUBFASE, DE_SUBFASE, COMPONENTE_KETTLE)
VALUES ( 101, 2, 3, 'CARGA BDS DATA ENTRY AGENCIA NEGOCIOS', '101-2-3-ETAPA_101_FASE_2_SUBFASE_3_Carga_BDS_Agencia_Negocios'); 

-- NUEVOS REGISTROS EN TOPAZETL.TABLAS_TRUNCO_RETOMA PARA ODS

INSERT INTO TOPAZETL.TABLAS_TRUNCO_RETOMA (ID_ETAPA, ID_FASE, ID_SUBFASE, DE_NOMBREFISICO, ESQUEMA_TABLA, TZ_LOCK)
VALUES (101, 1, 4, 'MD_GEOLOCALIZACION_AGENCIA', 'ODS', 0);

-- Control de tiempo

INSERT INTO TOPAZETL.BASE_TIEMPO (ID_ETAPA, ID_FASE, ID_SUBFASE, DE_SUB_FASE, MINUTOS) 
VALUES (101, 1, 3, 'CARGA ODS DATA ENTRY AGENCIA NEGOCIOS', 3);

INSERT INTO TOPAZETL.BASE_TIEMPO (ID_ETAPA, ID_FASE, ID_SUBFASE, DE_SUB_FASE, MINUTOS) 
VALUES (101, 1, 4, 'CARGA ODS DATA ENTRY GEOLOCALIZACION AGENCIA', 3);

INSERT INTO TOPAZETL.BASE_TIEMPO (ID_ETAPA, ID_FASE, ID_SUBFASE, DE_SUB_FASE, MINUTOS) 
VALUES (101, 2, 3, 'CARGA BDS DATA ENTRY AGENCIA NEGOCIOS', 3);

COMMIT;