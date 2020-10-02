CREATE OR REPLACE PACKAGE DWHADM.PKG_GEN_STG_DATAENTRY IS

  -- Author  : EM07878310
  -- Created : 10/08/2020 10:40:52
  -- Purpose :

  -- Public function and procedure declarations
  PROCEDURE SP_CARGA_DATAENTRY (V_IN_REPROCESO  IN NUMBER,
                                V_CO_MESA       IN NUMBER);

  PROCEDURE SP_ACTUALIZA_RESULTADO_DE (V_ID_DATA_ENTR  IN  NUMBER,
                                       V_CO_MESA       IN  NUMBER,
                                       V_NO_DATA_ENTR  IN  VARCHAR2,
                                       V_FE_EJECUCION  IN  DATE,
                                       V_IN_ESTADO     IN  NUMBER,
                                       V_DE_ERROR      IN  VARCHAR2,
                                       V_DE_ERROR_ACTU OUT VARCHAR2);

  FUNCTION FN_EXISTE_ARCHIVO_CARGA (V_DIRECTORIO     IN VARCHAR2,
                                    V_NOMBRE_ARCHIVO IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION FN_MUEVE_ARCHIVO (V_DIR_SOURCE  IN VARCHAR2,
                              V_FILE_SOURCE IN VARCHAR2,
                              V_DIR_TARGET  IN VARCHAR2,
                              V_FILE_TARGET IN VARCHAR2,
                              V_OPERACION   IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION FN_ELIMINA_ARCHIVO(V_DIR  IN VARCHAR2,
                              V_FILE IN VARCHAR2 ) RETURN VARCHAR2;
  PROCEDURE SP_GEN_DATA_MAIL;
  PROCEDURE SP_ENVIA_CORREO(ENVIA     IN VARCHAR2,
   RECIBE    IN VARCHAR2,
   ASUNTO    IN VARCHAR2,
   MENSAJE   IN VARCHAR2,
   HOST      IN VARCHAR2,
   PUERTO    IN VARCHAR2);

END;
/
CREATE OR REPLACE PACKAGE BODY DWHADM.PKG_GEN_STG_DATAENTRY IS
-- Modificaciones
-- Responsable : Abel Delgado
-- Fecha       : 03/09/2020
-- DescripciÃƒÂ³n : Migracion de Tablas DE a T
------------------------------------------------------------------------------------------------------------
--@001 PRZ CASO-22361: Se Modifica el proceso para migracion de Data Entrys
------------------------------------------------------------------------------------------------------------
  PROCEDURE SP_CARGA_DATAENTRY (V_IN_REPROCESO  IN NUMBER,
                                V_CO_MESA       IN NUMBER) IS

        CURSOR C_TABLA_DE IS
               SELECT ID_DATA_ENTR,
                      CO_MESA,
                      NO_DATA_ENTR,
                      NO_TABL_EXTE,
                      NO_TABL_STG
               FROM DWHADM.PARAMETROS_DE
               WHERE IN_ESTADO = 1
                 AND (V_IN_REPROCESO = 0 OR (V_IN_REPROCESO = 1 AND IN_REPROCESO = 1 AND CO_MESA = V_CO_MESA));

        CURSOR C_COLUM_DE(P_NO_TABL VARCHAR2) IS
               SELECT COLUMN_NAME, DATA_TYPE, COLUMN_ID
               FROM ALL_TAB_COLS
               WHERE OWNER = 'STG'
                 AND TABLE_NAME = P_NO_TABL
               ORDER BY COLUMN_NAME;

        CURSOR C_COLUM_STG(P_NO_TABL VARCHAR2) IS
               SELECT COLUMN_NAME, DATA_TYPE, COLUMN_ID
               FROM ALL_TAB_COLS
               WHERE OWNER = 'STG'
                 AND TABLE_NAME = P_NO_TABL
                 AND COLUMN_NAME <> 'FE_ACTU_DIA'
               ORDER BY COLUMN_NAME;

        CURSOR C_DIFE_COLU (P_NO_TABL_DE VARCHAR2, P_NO_TABL_STG VARCHAR2) IS
               SELECT a.COLUMN_NAME
               FROM ALL_TAB_COLS a
               LEFT JOIN ALL_TAB_COLS b ON b.OWNER = 'STG' AND b.TABLE_NAME = P_NO_TABL_STG AND b.COLUMN_NAME = a.COLUMN_NAME
               WHERE a.OWNER = 'STG'
                 AND a.TABLE_NAME = P_NO_TABL_DE
                 AND b.COLUMN_NAME IS NULL
               ORDER BY a.COLUMN_ID;

        V_C_TABLA_DE     C_TABLA_DE%ROWTYPE;
        V_C_COLUM_DE     C_COLUM_DE%ROWTYPE;
        V_C_COLUM_STG    C_COLUM_STG%ROWTYPE;
        V_C_DIFE_COLU    C_DIFE_COLU%ROWTYPE;
        V_NU_CAMPOS_DE   NUMBER(2);
        V_NU_CAMPOS_STG  NUMBER(2);
        V_NO_TABL_STG    VARCHAR2(50);
        V_NO_TABL_DE     VARCHAR2(50);
        V_VA_FE_ACTU     NUMBER(1);
        V_SQL_EXE        CLOB;
        V_TI_DATO_DEST   VARCHAR2(10);
        V_NO_RUTA_DE     VARCHAR2(4000);
        V_NO_FILE_DE     VARCHAR2(4000);
        V_DE_EXISTE_FILE VARCHAR2(1);
        V_FE_EJECUCION   DATE;
        V_DE_ERROR_ACTU  VARCHAR2(1000);
        V_DE_OPERACION   VARCHAR2(1);
        V_DE_BORRA       VARCHAR2(1);
        V_DE_DIFE_COLU   VARCHAR2(4000);
        V_NU_ERROR       NUMBER;
        V_NU_SQLERROR    NUMBER;
        V_DE_SQLERROR    VARCHAR2(1000);

  BEGIN
      OPEN C_TABLA_DE;
      LOOP
          FETCH C_TABLA_DE INTO V_C_TABLA_DE;
          EXIT WHEN C_TABLA_DE%NOTFOUND;

          V_NO_TABL_STG   := V_C_TABLA_DE.NO_TABL_STG;
          V_NO_TABL_DE    := V_C_TABLA_DE.NO_TABL_EXTE;
          V_FE_EJECUCION  := SYSDATE;
          V_DE_ERROR_ACTU := NULL;

          SELECT COUNT(1)
          INTO V_NU_CAMPOS_STG
          FROM ALL_TAB_COLS
          WHERE TABLE_NAME = V_NO_TABL_STG;

          SELECT COUNT(1)
          INTO V_NU_CAMPOS_DE
          FROM ALL_TAB_COLS
          WHERE TABLE_NAME = V_NO_TABL_DE;

          IF    V_NU_CAMPOS_DE = 0 THEN   -- Tabla Externa del DataEntry No Existe
                SP_ACTUALIZA_RESULTADO_DE (V_C_TABLA_DE.ID_DATA_ENTR,
                                           V_C_TABLA_DE.CO_MESA,
                                           V_C_TABLA_DE.NO_DATA_ENTR,
                                           V_FE_EJECUCION,
                                           1,
                                           'NO EXISTE LA TABLA EXTERNA STG.'||V_NO_TABL_DE,
                                           V_DE_ERROR_ACTU);
          ELSIF V_NU_CAMPOS_STG  = 0 THEN   -- Tabla de Staging No Existe
                SP_ACTUALIZA_RESULTADO_DE (V_C_TABLA_DE.ID_DATA_ENTR,
                                           V_C_TABLA_DE.CO_MESA,
                                           V_C_TABLA_DE.NO_DATA_ENTR,
                                           V_FE_EJECUCION,
                                           1,
                                           'NO EXISTE LA TABLA STAGING STG.'||V_NO_TABL_STG,
                                           V_DE_ERROR_ACTU);
          ELSE
                V_DE_DIFE_COLU := '';
                OPEN C_DIFE_COLU(V_NO_TABL_DE, V_NO_TABL_STG);
                LOOP
                   FETCH C_DIFE_COLU INTO V_C_DIFE_COLU;
                   EXIT WHEN C_DIFE_COLU%NOTFOUND;
                   V_DE_DIFE_COLU := V_DE_DIFE_COLU || V_C_DIFE_COLU.COLUMN_NAME || ',';
                END LOOP;
                CLOSE C_DIFE_COLU;

                IF  LENGTH(V_DE_DIFE_COLU) > 0 THEN  -- Columnas de la Tabla Externa No Existen en la tabla STG
                    V_DE_DIFE_COLU := SUBSTR(V_DE_DIFE_COLU,1,LENGTH(V_DE_DIFE_COLU)-1);
                    SP_ACTUALIZA_RESULTADO_DE (V_C_TABLA_DE.ID_DATA_ENTR,
                                               V_C_TABLA_DE.CO_MESA,
                                               V_C_TABLA_DE.NO_DATA_ENTR,
                                               V_FE_EJECUCION,
                                               1,
                                               'CAMPOS DE LA TABLA '||V_NO_TABL_DE||' NO EXISTEN EN LA TABLA '||V_NO_TABL_STG||': '||V_DE_DIFE_COLU,
                                               V_DE_ERROR_ACTU);
                ELSE
                    BEGIN
                        SELECT DIRECTORY_NAME, LOCATION
                        INTO V_NO_RUTA_DE, V_NO_FILE_DE
                        FROM ALL_EXTERNAL_LOCATIONS a
                        WHERE a.OWNER      = 'STG'
                          AND a.TABLE_NAME = V_NO_TABL_DE;

                        V_DE_EXISTE_FILE := FN_EXISTE_ARCHIVO_CARGA(V_NO_RUTA_DE, V_NO_FILE_DE);

                        IF  V_DE_EXISTE_FILE = 'N' THEN  -- El archivo de DataEntry no existe
                            SP_ACTUALIZA_RESULTADO_DE (V_C_TABLA_DE.ID_DATA_ENTR,
                                                       V_C_TABLA_DE.CO_MESA,
                                                       V_C_TABLA_DE.NO_DATA_ENTR,
                                                       V_FE_EJECUCION,
                                                       1,
                                                       'NO EXISTE EL ARCHIVO DE DATAENTRY '||V_NO_RUTA_DE||'/'||V_NO_FILE_DE,
                                                       V_DE_ERROR_ACTU);
                        END IF;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN -- No se encontrÃ³ la ubicaciÃ³n del archivo de DataEntry
                             V_DE_EXISTE_FILE := 'N';
                             SP_ACTUALIZA_RESULTADO_DE (V_C_TABLA_DE.ID_DATA_ENTR,
                                                        V_C_TABLA_DE.CO_MESA,
                                                        V_C_TABLA_DE.NO_DATA_ENTR,
                                                        V_FE_EJECUCION,
                                                        1,
                                                        'NO EXISTE LA DEFINICIÃ“N DE LA RUTA DEL DATAENTRY '||V_NO_TABL_DE,
                                                        V_DE_ERROR_ACTU);
                    END;

                    IF   V_DE_EXISTE_FILE = 'S' THEN   -- Si Existe el archivo de DataEntry
                         IF   V_NU_CAMPOS_STG > V_NU_CAMPOS_DE AND V_NU_CAMPOS_STG - V_NU_CAMPOS_DE = 1 THEN
                              SELECT COUNT(1)
                              INTO V_VA_FE_ACTU
                              FROM ALL_TAB_COLS
                              WHERE TABLE_NAME  = V_NO_TABL_STG
                                AND COLUMN_NAME = 'FE_ACTU_DIA'
                                AND DATA_TYPE   = 'DATE';

                              IF   V_VA_FE_ACTU = 1 THEN
                                   V_SQL_EXE := 'INSERT INTO STG.'||V_NO_TABL_STG||'(';

                                   -- Se leen los campos de la Tabla STG
                                   OPEN C_COLUM_STG(V_NO_TABL_STG);
                                   LOOP
                                      FETCH C_COLUM_STG INTO V_C_COLUM_STG;
                                      EXIT WHEN C_COLUM_STG%NOTFOUND;
                                      V_SQL_EXE := V_SQL_EXE || V_C_COLUM_STG.COLUMN_NAME || ',';
                                   END LOOP;
                                   CLOSE C_COLUM_STG;

                                   V_SQL_EXE := SUBSTR(V_SQL_EXE,1,LENGTH(V_SQL_EXE)-1);
                                   V_SQL_EXE := V_SQL_EXE || ', FE_ACTU_DIA)';
                                   V_SQL_EXE := V_SQL_EXE || ' SELECT ';

                                   -- Se leen los campos de la Tabla Externa
                                   OPEN C_COLUM_DE(V_NO_TABL_DE);
                                   LOOP
                                      FETCH C_COLUM_DE INTO V_C_COLUM_DE;
                                      EXIT WHEN C_COLUM_DE%NOTFOUND;

                                      SELECT DATA_TYPE
                                      INTO V_TI_DATO_DEST
                                      FROM ALL_TAB_COLS
                                      WHERE TABLE_NAME = V_NO_TABL_STG
                                        AND COLUMN_ID  = V_C_COLUM_DE.COLUMN_ID;

                                      IF    V_TI_DATO_DEST = 'NUMBER' THEN
                                            V_SQL_EXE := V_SQL_EXE || 'TO_NUMBER(REPLACE('||V_C_COLUM_DE.COLUMN_NAME || ',''.'','','')),';
                                      ELSIF V_TI_DATO_DEST = 'DATE' THEN
                                            V_SQL_EXE := V_SQL_EXE || 'TO_DATE('||V_C_COLUM_DE.COLUMN_NAME ||',''DD/MM/YYYY HH:MI:SS A.M.'',''NLS_DATE_LANGUAGE=AMERICAN''),';
                                      ELSE
                                            V_SQL_EXE := V_SQL_EXE || V_C_COLUM_DE.COLUMN_NAME || ',';
                                      END IF;
                                   END LOOP;
                                   CLOSE C_COLUM_DE;

                                   STG.PKG_STG_GENERICO.SP_TRUNCATE_TABLE('STG',V_NO_TABL_STG,V_NU_ERROR);

                                   V_SQL_EXE := V_SQL_EXE || ' SYSDATE FROM STG.'||V_NO_TABL_DE;
                                   dbms_output.put_line(V_SQL_EXE);
                                   
                                   V_DE_SQLERROR := NULL;
                                   V_NU_SQLERROR := 0;
                                   BEGIN
                                       EXECUTE IMMEDIATE V_SQL_EXE;
                                   EXCEPTION
                                       WHEN INVALID_NUMBER THEN
                                            V_DE_SQLERROR := 'ERROR AL EJECUTAR LA CARGA:'||TO_CHAR(SQLCODE)||' - '||SQLERRM;
                                            V_NU_SQLERROR := 1;
                                       WHEN OTHERS THEN
                                            V_DE_SQLERROR := 'ERROR AL EJECUTAR LA CARGA:'||TO_CHAR(SQLCODE)||' - '||SQLERRM;
                                            V_NU_SQLERROR := 1;
                                   END;
                                   
                                   IF  V_NU_SQLERROR = 1 THEN  -- Si hubo un error al momento de ejecutar la sentencia INSERT
                                       ROLLBACK;
                                   ELSE
                                       COMMIT;
                                   END IF;
                                   
                                   SP_ACTUALIZA_RESULTADO_DE (V_C_TABLA_DE.ID_DATA_ENTR,
                                                              V_C_TABLA_DE.CO_MESA,
                                                              V_C_TABLA_DE.NO_DATA_ENTR,
                                                              V_FE_EJECUCION,
                                                              V_NU_SQLERROR,
                                                              V_DE_SQLERROR,
                                                              V_DE_ERROR_ACTU);

                              ELSE -- El Ãºltimo campo no es FE_ACTU_DIA
                                 SP_ACTUALIZA_RESULTADO_DE (V_C_TABLA_DE.ID_DATA_ENTR,
                                                            V_C_TABLA_DE.CO_MESA,
                                                            V_C_TABLA_DE.NO_DATA_ENTR,
                                                            V_FE_EJECUCION,
                                                            1,
                                                            'NO EXISTE LA COLUMNA: FE_ACTU_DIA EN LA TABLA STG.'||V_NO_TABL_STG,
                                                            V_DE_ERROR_ACTU);
                             END IF;
                         ELSE -- No corresponde la cantidad de campos entre la tabla Externa y la tabla STG
                            SP_ACTUALIZA_RESULTADO_DE (V_C_TABLA_DE.ID_DATA_ENTR,
                                                       V_C_TABLA_DE.CO_MESA,
                                                       V_C_TABLA_DE.NO_DATA_ENTR,
                                                       V_FE_EJECUCION,
                                                       1,
                                                       'NO CORRESPONDE LA CANTIDAD DE CAMPOS ENTRE LAS TABLAS: '||V_NO_TABL_STG||', '||V_NO_TABL_DE,
                                                       V_DE_ERROR_ACTU);
                         END IF;
                         -- PROCEDIMIENTO PARA MOVER EL ARCHIVO DE DATAENTRY
                         V_DE_OPERACION := FN_MUEVE_ARCHIVO(V_NO_RUTA_DE,
                                                             V_NO_FILE_DE,
                                                             V_NO_RUTA_DE||'_BACKUP',
                                                             REPLACE(UPPER(V_NO_FILE_DE),'.CSV','')||'_'||TO_CHAR(V_FE_EJECUCION,'YYYYMMDDHH24MISS')||'.CSV',
                                                             'MOVE');

                         -- PROCEDIMIENTO ELIMINA ARCHIVOS ANTIGUOS DE LA CARPETA BACKUP
                         V_DE_BORRA := FN_ELIMINA_ARCHIVO(V_NO_RUTA_DE||'_BACKUP',
                                                          V_NO_FILE_DE);
                    END IF;
                END IF;
          END IF;
      END LOOP;
      SP_GEN_DATA_MAIL;
      CLOSE C_TABLA_DE;
  EXCEPTION
      WHEN OTHERS THEN
           DBMS_OUTPUT.PUT_LINE(SQLERRM);
  END;

  ---------------------

  PROCEDURE SP_ACTUALIZA_RESULTADO_DE (V_ID_DATA_ENTR  IN  NUMBER,
                                       V_CO_MESA       IN  NUMBER,
                                       V_NO_DATA_ENTR  IN  VARCHAR2,
                                       V_FE_EJECUCION  IN  DATE,
                                       V_IN_ESTADO     IN  NUMBER,
                                       V_DE_ERROR      IN  VARCHAR2,
                                       V_DE_ERROR_ACTU OUT VARCHAR2) IS
  BEGIN
      UPDATE DWHADM.RESULTADO_CARGA_DE
      SET CO_MESA      = V_CO_MESA,
          NO_DATA_ENTR = V_NO_DATA_ENTR,
          FE_EJECUCION = V_FE_EJECUCION,
          IN_ESTADO    = V_IN_ESTADO,
          DE_ERROR     = V_DE_ERROR
      WHERE ID_DATA_ENTR = V_ID_DATA_ENTR;

      IF  SQL%NOTFOUND THEN
          INSERT INTO DWHADM.RESULTADO_CARGA_DE
          (ID_DATA_ENTR, CO_MESA, NO_DATA_ENTR, FE_EJECUCION, IN_ESTADO, DE_ERROR)
          VALUES
          (V_ID_DATA_ENTR, V_CO_MESA, V_NO_DATA_ENTR, V_FE_EJECUCION, V_IN_ESTADO, V_DE_ERROR);
      END IF;

      INSERT INTO DWHADM.RESULTADO_CARGA_DE_HIST
      (ID_DATA_ENTR, CO_MESA, NO_DATA_ENTR, FE_EJECUCION, IN_ESTADO, DE_ERROR)
      VALUES
      (V_ID_DATA_ENTR, V_CO_MESA, V_NO_DATA_ENTR, V_FE_EJECUCION, V_IN_ESTADO, V_DE_ERROR);

      COMMIT;
      V_DE_ERROR_ACTU := NULL;
  EXCEPTION
      WHEN OTHERS THEN
           V_DE_ERROR_ACTU := SQLERRM;
  END;

-------------

  FUNCTION FN_EXISTE_ARCHIVO_CARGA (V_DIRECTORIO     IN VARCHAR2,
                                    V_NOMBRE_ARCHIVO IN VARCHAR2) RETURN VARCHAR2 IS
      V_FILEHANDLE    UTL_FILE.FILE_TYPE;
  BEGIN
      V_FILEHANDLE := UTL_FILE.FOPEN(V_DIRECTORIO, V_NOMBRE_ARCHIVO, 'r');
      UTL_FILE.FCLOSE(V_FILEHANDLE);
      RETURN 'S';
  EXCEPTION
      WHEN UTL_FILE.INVALID_PATH THEN RETURN 'N';
      WHEN UTL_FILE.INVALID_FILENAME THEN RETURN 'N';
      WHEN UTL_FILE.INVALID_OPERATION THEN RETURN 'N';
  END;

  ------------

  FUNCTION FN_MUEVE_ARCHIVO (V_DIR_SOURCE  IN VARCHAR2,
                              V_FILE_SOURCE IN VARCHAR2,
                              V_DIR_TARGET  IN VARCHAR2,
                              V_FILE_TARGET IN VARCHAR2,
                              V_OPERACION   IN VARCHAR2) RETURN VARCHAR2 IS

      V_ACCION       BOOLEAN;
  BEGIN
      IF   V_OPERACION = 'MOVE' THEN
           V_ACCION := TRUE;
      ELSE
           V_ACCION := FALSE;
      END IF;
      UTL_FILE.FRENAME(V_DIR_SOURCE,V_FILE_SOURCE,V_DIR_TARGET,V_FILE_TARGET,V_ACCION);

      INSERT INTO DWHADM.ARCHIVOS_CARGA_DE (ID_ARCH_CARG,NO_ARCH_ORIG,NO_ARCH_BACK,FE_EJECUCION)
      VALUES (dwhadm.sec_archivos_de.nextval,V_FILE_SOURCE,V_FILE_TARGET,sysdate());

      COMMIT;

      RETURN 'S';
  EXCEPTION
      WHEN UTL_FILE.INVALID_PATH THEN RETURN 'N';
      WHEN UTL_FILE.INVALID_FILENAME THEN RETURN 'N';
      WHEN UTL_FILE.INVALID_OPERATION THEN RETURN 'N';
  END;

 FUNCTION FN_ELIMINA_ARCHIVO (V_DIR  IN VARCHAR2,
                              V_FILE IN VARCHAR2) RETURN VARCHAR2 IS

      CURSOR C_BORRA_ARCHIVO_DE (P_FILE_SOURCE VARCHAR2) IS
             SELECT X.ID_ARCH_CARG,X.NO_ARCH_BACK
                    FROM (
                          SELECT
                                A.ID_ARCH_CARG,
                                A.NO_ARCH_BACK,
                                ROW_NUMBER() OVER (PARTITION BY NO_ARCH_ORIG ORDER BY FE_EJECUCION DESC) AS ORDEN
                          FROM DWHADM.ARCHIVOS_CARGA_DE A
                          WHERE NO_ARCH_ORIG = P_FILE_SOURCE
                           ) X
                      WHERE X.ORDEN > 2;

      V_ACCION       BOOLEAN;
      V_C_BORRA_ARCHIVO_DE C_BORRA_ARCHIVO_DE%ROWTYPE;
      V_NO_ARCHIVO VARCHAR2(50);
      V_ID_ARCH_CARG VARCHAR2(50);

    BEGIN
      OPEN C_BORRA_ARCHIVO_DE (V_FILE);
      LOOP
          FETCH C_BORRA_ARCHIVO_DE INTO V_C_BORRA_ARCHIVO_DE;
          EXIT WHEN C_BORRA_ARCHIVO_DE%NOTFOUND;

          V_NO_ARCHIVO    := V_C_BORRA_ARCHIVO_DE.NO_ARCH_BACK;
          V_ID_ARCH_CARG := V_C_BORRA_ARCHIVO_DE.ID_ARCH_CARG;

      UTL_FILE.FREMOVE (V_DIR,V_NO_ARCHIVO);

      DELETE FROM DWHADM.ARCHIVOS_CARGA_DE WHERE ID_ARCH_CARG=V_ID_ARCH_CARG;

      COMMIT;
      END LOOP;
      RETURN 'S';
  EXCEPTION
      WHEN UTL_FILE.INVALID_PATH THEN RETURN 'N';
      WHEN UTL_FILE.INVALID_FILENAME THEN RETURN 'N';
      WHEN UTL_FILE.INVALID_OPERATION THEN RETURN 'N';
  END;

  ------------

  PROCEDURE SP_GEN_DATA_MAIL IS
    BEGIN
  DECLARE
  CURSOR guru99_det IS SELECT TO_CHAR(A.CO_MESA) as CO_MESA,A.NO_DATA_ENTR,TO_CHAR(A.FE_EJECUCION,'DD/MM/YYYY') as  fe_ejecucion,TO_CHAR(A.IN_ESTADO) as in_estado,A.DE_ERROR
                       FROM DWHADM.RESULTADO_CARGA_DE A
                       WHERE A.IN_ESTADO=1;
  vcursor guru99_det%ROWTYPE;
  v_correo varchar2(8000);
  BEGIN
  OPEN guru99_det;
  v_correo :='<table><tbody><tr><th>MESA</th><th>NOMBRE_DATA_ENTRY</th><th>FECHA_EJECUCION</th><th>ESTADO</th><th>ERROR</th></tr>';
  LOOP
  FETCH guru99_det INTO vcursor;
  IF guru99_det%NOTFOUND
  THEN
  EXIT;
  END IF;
  v_correo := v_correo || '<tr><td>'|| RPAD(vcursor.co_mesa,5) || '</td><td>' ||  RPAD(vcursor.no_data_entr,51) || '</td><td>' ||  RPAD(vcursor.fe_ejecucion,16) || '</td><td>' ||  RPAD(vcursor.in_estado,6) || '</td><td>' ||  RPAD(vcursor.de_error,251) || '</td></tr>' || chr(13) ;
  END LOOP;
  CLOSE guru99_det;
  v_correo := v_correo || '</tbody></table>';
  SP_ENVIA_CORREO('ArquitecturaTI@mibanco.com.pe',
                  'propietariosde@mibanco.com.pe',
                  ' Estimados se les envia los data entrys no procesados ',
                  v_correo,
                  '172.16.5.164',
                  '25');
  END;
  END;


  PROCEDURE SP_ENVIA_CORREO(
   ENVIA     IN VARCHAR2,
   RECIBE    IN VARCHAR2,
   ASUNTO    IN VARCHAR2,
   MENSAJE   IN VARCHAR2,
   HOST      IN VARCHAR2,
   PUERTO    IN VARCHAR2)
    IS
      mailhost     VARCHAR2(30) := ltrim(rtrim(HOST));
      mail_conn    utl_smtp.connection;

      crlf VARCHAR2( 2 ):= CHR( 13 ) || CHR( 10 );
      mesg VARCHAR2( 1000 );
      V_UTL_SMTP UTL_SMTP.CONNECTION;
        V_MENSAJE_CORREO VARCHAR2(10000);

    BEGIN
          V_UTL_SMTP :=  utl_smtp.open_connection(HOST,PUERTO);
                         utl_smtp.helo(V_UTL_SMTP, 'mibanco.com.pe');
                         utl_smtp.mail(V_UTL_SMTP, ENVIA);
                         utl_smtp.rcpt(V_UTL_SMTP, RECIBE);
                         utl_smtp.open_data(V_UTL_SMTP);
                         utl_smtp.write_data(V_UTL_SMTP,'From'|| ': ' || '"[ALERTAS PROCESO DE CARGA DATA ENTRY]" ' ||utl_tcp.CRLF);
                         utl_smtp.write_data(V_UTL_SMTP,'Subject'|| ': ' || ASUNTO  ||  utl_tcp.CRLF);
                         UTL_SMTP.write_data(V_UTL_SMTP, 'Content-Type: text/html; charset="iso-8859-1"' || UTL_TCP.crlf || UTL_TCP.crlf);
                         utl_smtp.write_data(V_UTL_SMTP, utl_tcp.CRLF || MENSAJE ||utl_tcp.CRLF);
                         utl_smtp.close_data(V_UTL_SMTP);
                         utl_smtp.quit(V_UTL_SMTP);
    END;

END;
/