#!/bin/sh
#
# Fecha: 18/07/2017
# Descripcion: Script de ejecucion para pase a produccion de componentes (OPER, FORM, XML, JAR, etc.) en el sistema TOPAZ
# Version: 15.1


# Estructura de carpetas para pase a produccion
# -CASO-13457_COMPONENTES_V1.0
#	--componentes
#		---00_ScriptsBD
#		---02_ScriptsSH
#		---03_PATCHS
#		---04_XMLS (Estructura de la carpeta /u01/jboss-as-Edyficar/server/topaz-5.2.1/)
#		---05_ASPs
#		---06_OPERS
#			----TTR
#		---07_FORMS
#			----jasperReports
#			----jtopazspec
#				----imgs
#		---08_KETTLE_JASPER
#		---09_JARS
#			----01-Clients
#			----02-Custom
#			----03-Server
#			----04-Lib
#			----05-LibServer
#			----06-Configuration
#		---10_IMAGES
#		---11_KETTLES
#		---12_PYTHON_CANALES
#		---13_TOPAZ_EAR_SERVICE
#			----server_sar
#				----META-INF
#		---14_KETTLE_FILE_PARAM
# Nota: solo es necesario las carpetas que contienen componentes.

# Variables a cambiar
#		INSTALL_FOLDER	: nombre de la carpeta de componentes (ejm: caso-0001_componentes_v1)
#		INSTALL_FILE  	: nombre de la carpeta de componentes zipeado (ejm: caso-0001_componentes_v1.zip)
#		NUM_CASO	: Numero de caso

# Caso Principal
#NUM_CASO=CASO-13457
#export NUM_CASO

#WCM I Se mueven las variables del JNLP a otro lado
HSTNAME=$(hostname)
IPHSTNAME=$(hostname -i)
#TOPAZ_IPS_PROD="jnlp_ips_prod.txt"
#TOPAZ_NOM_SVR_JNLP="jnlp_nombre.txt"
#TOPAZ_JNLP_2="jnlp_parte2.txt"

export HSTNAME IPHSTNAME
#export TOPAZ_IPS_PROD TOPAZ_NOM_SVR_JNLP TOPAZ_JNLP_2
#WCM F

echo " "
echo "**************************************************************************************************"
echo " "
echo "SCRIPT DE EJECUCION DE PASE A PRODUCCION DE COMPONENTES DEL"
echo "CORE BANKING TOPAZ EN EL SERVIDOR "$HSTNAME "DE IP "$IPHSTNAME
echo " "
echo "**************************************************************************************************"
echo " "

# Formato de fecha
DIA=`date +%d`
MES=`date +%m`
ANHO=`date +%Y`
export DIA MES ANHO
FECHA=$ANHO$MES$DIA
export FECHA
echo "Fecha de pase a produccion: "`date +%d`"/"`date +%m`"/"`date +%Y`
echo " "

echo "Ingrese el numero de CASO principal que pasa a produccion (Por ejemplo XXXX, para el CASO-XXXX):"
read NUM_CASO
echo " "

if [[ $NUM_CASO -lt 10 ]]; then
  if [[ $NUM_CASO == [1-9]* ]]; then
    echo " "
  else
    echo "NO SE HA INGRESADO UN NUMERO DE CASO CORRECTO"
    echo " "
    exit 2
  fi
elif [[ $NUM_CASO -lt 100 ]]; then
  if [[ $NUM_CASO == [1-9][0-9]* ]]; then
    echo " "
  else
    echo "NO SE HA INGRESADO UN NUMERO DE CASO CORRECTO"
    echo " "
    exit 2
  fi
elif [[ $NUM_CASO -lt 1000 ]]; then
  if [[ $NUM_CASO == [1-9][0-9][0-9]* ]]; then
    echo " "
  else
    echo "NO SE HA INGRESADO UN NUMERO DE CASO CORRECTO"
    echo " "
    exit 2
  fi
elif [[ $NUM_CASO -lt 10000 ]]; then
  if [[ $NUM_CASO == [1-9][0-9][0-9][0-9]* ]]; then
    echo " "
  else
    echo "NO SE HA INGRESADO UN NUMERO DE CASO CORRECTO"
    echo " "
    exit 2
  fi
else
  if [[ $NUM_CASO == [1-9][0-9][0-9][0-9][0-9]* ]]; then
    echo " "
  else
    echo "NO SE HA INGRESADO UN NUMERO DE CASO CORRECTO"
    echo " "
    exit 2
  fi
fi

echo "Ingrese la version del instalador que pasa a produccion (Por ejemplo X.0):"
read VERSION
echo " "

if [[ $VERSION == [0-9][0-9]\.[0-9] || $VERSION == [0-9]\.[0-9] ]]; then
echo " "
elif [[ $VERSION == [0-9][0-9] || $VERSION == [0-9] ]]; then
VERSION=$VERSION.0
echo " "
else
echo "NO SE HAN INGRESADO UNA VERSION CON VALORES CORRECTOS"
echo " "
exit 2
fi

echo "Este pase es de ALTO IMPACTO? (SI/NO):"
read ALTO_IMPACTO
echo " "

if [[ $ALTO_IMPACTO == [Ss][Ii] || $ALTO_IMPACTO == [Nn][Oo] ]]; then
echo " "
else
echo "NO SE HA INGRESADO UN VALOR DE IMPACTO CORRECTO"
echo " "
exit 2
fi

echo "**************************************************************************************************"
echo " "

# Definicion de variables de entorno de los archivos de bitacora
echo "Definicion de variables de entorno de los archivos de bitacora"

LOG_PATH=/u01/PASES/CASO-$NUM_CASO/log
export LOG_PATH

if [ -d $LOG_PATH ];
then
echo "El directorio \""$LOG_PATH"\" ya existe"
else
`mkdir -p $LOG_PATH`
fi

INSTALL_LOG=$LOG_PATH/install_$FECHA.`date +%H%M%S`.log
ERROR_LOG=$LOG_PATH/install_error_$FECHA.`date +%H%M%S`.log
export INSTALL_LOG ERROR_LOG

echo "LOG_PATH = "$LOG_PATH
echo "Definicion de variables de entorno de los archivos de bitacora" >> $INSTALL_LOG
echo "LOG_PATH = "$LOG_PATH >> $INSTALL_LOG
echo "Se generan los siguientes archivos de bitacora:"
echo "Se generan los siguientes archivos de bitacora:" >> $INSTALL_LOG
echo "INSTALL_LOG = "$INSTALL_LOG
echo "INSTALL_LOG = "$INSTALL_LOG >> $INSTALL_LOG
echo "ERROR_LOG = "$ERROR_LOG
echo "ERROR_LOG = "$ERROR_LOG >> $INSTALL_LOG
echo " "
echo " " >> $INSTALL_LOG
echo " "
echo " " >> $INSTALL_LOG


# Inicio del proceso
echo "INICIO DEL PROCESO DE INSTALACION DE COMPONENTES"
echo "INICIO DEL PROCESO DE INSTALACION DE COMPONENTES" >> $INSTALL_LOG
echo " "
echo " " >> $INSTALL_LOG
echo "Caso principal: CASO-"$NUM_CASO
echo "Caso principal: CASO-"$NUM_CASO >> $INSTALL_LOG
echo "Casos asociados: "
echo "Casos asociados: " >> $INSTALL_LOG
echo " "
echo " " >> $INSTALL_LOG


# Definicion de variables de entorno
echo "**************************************************************************************************"
echo "**************************************************************************************************" >> $INSTALL_LOG
echo "Definicion de variables de entorno"
echo "Definicion de variables de entorno" >> $INSTALL_LOG
echo " "
echo " " >> $INSTALL_LOG

# Definicion de variables de entorno de la aplicacion
echo "Definicion de variables de entorno de la aplicacion"
echo "Definicion de variables de entorno de la aplicacion" >> $INSTALL_LOG

JBOSS_HOME=/u01/EAP-7.0.0
export JBOSS_HOME
echo "JBOSS_HOME = "$JBOSS_HOME
echo "JBOSS_HOME = "$JBOSS_HOME >> $INSTALL_LOG
echo " "
echo " " >> $INSTALL_LOG

TOPAZ_HOME=$JBOSS_HOME/standalone
export TOPAZ_HOME
echo "TOPAZ_HOME = "$TOPAZ_HOME
echo "TOPAZ_HOME = "$TOPAZ_HOME >> $INSTALL_LOG
echo " "
echo " " >> $INSTALL_LOG

JBOSS_FOLDER=EAP-7.0.0
BIBLIOTECA_FOLDER=biblioteca
export JBOSS_FOLDER BIBLIOTECA_FOLDER

TOPAZ_CONF=$TOPAZ_HOME/conf
TOPAZ_DEPLOY=$TOPAZ_HOME/deployments
TOPAZ_USERLIBRARY=$TOPAZ_HOME/userlibrary
TOPAZ_APP=$TOPAZ_HOME/deployments/jDesktop.war/app
LIB_CLIENT=$TOPAZ_HOME/deployments/jDesktop.war/app/lib
TOPAZ_APP_CONF=$TOPAZ_HOME/userlibrary/default/conf
TOPAZ_APP_PROP=$TOPAZ_HOME/userlibrary/default/conf/properties
TOPAZ_APP_SRV=$TOPAZ_HOME/userlibrary/default/conf/srv
TOPAZ_APP_PYTHON=$TOPAZ_HOME/userlibrary/default/python/topsystems/pos/core
#DRIOS I
TOPAZ_APP_PYTHON_POS=$TOPAZ_HOME/userlibrary/default/python/topsystems/pos
#TOPAZ_APP_PYTHON_GLOBOKAST=$TOPAZ_HOME/userlibrary/default/python/topsystems/pos/core/GLOBOKAST-----
#TOPAZ_APP_PYTHON_UNIBANCA=$TOPAZ_HOME/userlibrary/default/python/topsystems/pos/core/UNIBANCA----
TOPAZ_APP_PYTHON_MDWARE=$TOPAZ_HOME/userlibrary/default/python/topsystems/pos/middleware
#DRIOS F
TOPAZ_APP_KETL=$TOPAZ_HOME/userlibrary/default/tools/kettle/packages
#VCA I
TOPAZ_APP_KETL_PLUG=$TOPAZ_HOME/userlibrary/default/tools/kettle/plugins
#VCA F
TOPAZ_APP_CONF_DATASRV=$TOPAZ_HOME/userlibrary/default/conf/dataserver
TOPAZ_APP_CONF_DATAMPN=$TOPAZ_HOME/userlibrary/default/conf/dataserver/datamapping
TOPAZ_APP_PROCESSMGR=$TOPAZ_HOME/userlibrary/default/python/topsystems/processmgr
TOPAZ_APP_SERVICES=$TOPAZ_HOME/userlibrary/default/services
TOPAZ_APP_SERVICES_LOANS=$TOPAZ_HOME/userlibrary/default/services/loans
TOPAZ_APP_SERVICES_CHARGES=$TOPAZ_HOME/userlibrary/default/services/charges
TOPAZ_APP_TOOLS=$TOPAZ_HOME/userlibrary/default/tools
TOPAZ_LIB_CLIENT=$TOPAZ_HOME/deployments/jDesktop.war/app/topazlib
#TOPAZ_LIB_CUSTOM=$TOPAZ_HOME/deployments/jDesktop.war/custom.sar----
#TOPAZ_LIB_SERVER=$TOPAZ_HOME/deployments/topaz.ear/server.sar--comente
TOPAZ_LIB_SERVER=$TOPAZ_HOME/lib
TOPAZ_IMAGE_SERVER=/u01/biblioteca/IMAGENES
TOPAZ_LIB_CLIENT_PARENT=$TOPAZ_HOME/deployments/jDesktop.war/app
LIB_SERVER=$TOPAZ_HOME/lib
#JBOSS_SERVICE=$TOPAZ_HOME/deployments/topaz.ear/server.sar/META-INF----
JBOSS_SERVICE=$TOPAZ_HOME/deployments/topaz.ear/META-INF
OPERS=/u01/biblioteca/TABLAS
FORMS=/u01/biblioteca/FML
FORMS_XML=/u01/biblioteca/FML/jtopazspec
#DPS I
#FORMS_IMGS=/u01/biblioteca/FML/jtopazspec/imgs----
#DPS F
FORMS_JASPER=/u01/biblioteca/FML/jasperReports
KETTLE_JASPER=/u01/biblioteca/Kettle/JASPER
#VCA I
KETTLE_FILE_PARAM=/u01/biblioteca/Kettle/FILE_PARAM
#VCA F

#RMM I
TOPAZ_HTML=$TOPAZ_HOME/userlibrary/default/mails/html
#RMM F

export TOPAZ_CONF
export TOPAZ_DEPLOY
export TOPAZ_APP
export TOPAZ_USERLIBRARY
export LIB_CLIENT
export TOPAZ_APP_CONF
export TOPAZ_APP_CONF_DATASRV
export TOPAZ_APP_CONF_DATAMPN
export TOPAZ_APP_PROCESSMGR
export TOPAZ_APP_SERVICES
export TOPAZ_APP_SERVICES_LOANS
export TOPAZ_APP_TOOLS
export TOPAZ_APP_PROP
export TOPAZ_APP_SRV
export TOPAZ_APP_SERVICES_CHARGES
export TOPAZ_LIB_CLIENT
export TOPAZ_LIB_CUSTOM
export TOPAZ_LIB_SERVER
export TOPAZ_LIB_CLIENT_PARENT
export FORMS_JASPER
export TOPAZ_APP_PYTHON
#DRIOS I
export TOPAZ_APP_PYTHON_POS
export TOPAZ_APP_PYTHON_GLOBOKAST
export TOPAZ_APP_PYTHON_UNIBANCA
export TOPAZ_APP_PYTHON_MDWARE
#DRIOS F
export TOPAZ_APP_KETL
#VCA I
export TOPAZ_APP_KETL_PLUG
#VCA F
export OPERS
export FORMS
export FORMS_XML
#DPS I
export FORMS_IMGS
#DPS F
export TOPAZ_IMAGE_SERVER
export KETTLE_JASPER
export LIB_SERVER
export JBOSS_SERVICE
#VCA I
export KETTLE_FILE_PARAM
#VCA F
#RMM I
export TOPAZ_HTML
#RMM F

# Definicion de variables de entorno del instalador
echo "Definicion de variables de entorno del instalador"
echo "Definicion de variables de entorno del instalador" >> $INSTALL_LOG

export INSTALL_FOLDER=V$VERSION
export INSTALL_FOLDER=_COMPONENTES_$INSTALL_FOLDER
export INSTALL_FOLDER=CASO-$NUM_CASO$INSTALL_FOLDER
export INSTALL_FILE=$INSTALL_FOLDER.zip

echo "INSTALL_FILE = "$INSTALL_FILE
echo "INSTALL_FILE = "$INSTALL_FILE >> $INSTALL_LOG
echo " "
echo " " >> $INSTALL_LOG

INSTALL_PATH=/u01/PASES/$INSTALL_FOLDER/Componentes
export INSTALL_PATH
echo "INSTALL_PATH = "$INSTALL_PATH
echo "INSTALL_PATH = "$INSTALL_PATH >> $INSTALL_LOG
echo " "
echo " " >> $INSTALL_LOG


# WCM I Si ya existe la carpeta de componentes al instalar, indicar que debe ser borrada para continuar
INSTALL_PATH_VAL=/u01/PASES/$INSTALL_FOLDER/
export INSTALL_PATH_VAL

if [ -d $INSTALL_PATH_VAL ]; then
 echo " "
 echo "El directorio \""$INSTALL_PATH_VAL"\" ya existe, favor de borrarlo para poder instalar"
 exit 2
fi
#WCM F


TOPAZ_SHELL_DIR=$INSTALL_PATH/02_ScriptsSH
#WCM I - Cambios por Harvest
TOPAZ_IPS_PROD="jnlp_ips_prod_CASO-$NUM_CASO.txt"
TOPAZ_NOM_SVR_JNLP="jnlp_nombre_CASO-$NUM_CASO.txt"
TOPAZ_JNLP_2="jnlp_parte2_CASO-$NUM_CASO.txt"
TOPAZ_LIB_LIST_CLIENT=$INSTALL_PATH/02_ScriptsSH/lista_jars_client_CASO-$NUM_CASO.txt
TOPAZ_LIB_LIST_CUSTOM=$INSTALL_PATH/02_ScriptsSH/lista_jars_custom_CASO-$NUM_CASO.txt
TOPAZ_LIB_LIST_SERVER=$INSTALL_PATH/02_ScriptsSH/lista_jars_server_CASO-$NUM_CASO.txt
TOPAZ_IMAGES_LIST_SERVER=$INSTALL_PATH/02_ScriptsSH/lista_images_server_CASO-$NUM_CASO.txt
#WCM F

TOPAZ_CONF_NEW=$INSTALL_PATH/04_XMLS/conf
TOPAZ_DEPLOY_NEW=$INSTALL_PATH/04_XMLS/deploy
TOPAZ_APP_CONF_NEW=$INSTALL_PATH/04_XMLS/userlibrary/default/conf
TOPAZ_APP_PROP_NEW=$INSTALL_PATH/04_XMLS/userlibrary/default/conf/properties
TOPAZ_APP_SRV_NEW=$INSTALL_PATH/04_XMLS/userlibrary/default/conf/srv
TOPAZ_APP_PYTHON_NEW=$INSTALL_PATH/12_PYTHON_CANALES/userlibrary/default/python/topsystems/pos/core
#DRIOS I
TOPAZ_APP_PYTHON_POS_NEW=$INSTALL_PATH/12_PYTHON_CANALES/userlibrary/default/python/topsystems/pos
TOPAZ_APP_PYTHON_GLOBOKAST_NEW=$INSTALL_PATH/12_PYTHON_CANALES/userlibrary/default/python/topsystems/pos/core/GLOBOKAST
TOPAZ_APP_PYTHON_UNIBANCA_NEW=$INSTALL_PATH/12_PYTHON_CANALES/userlibrary/default/python/topsystems/pos/core/UNIBANCA
TOPAZ_APP_PYTHON_MDWARE_NEW=$INSTALL_PATH/12_PYTHON_CANALES/userlibrary/default/python/topsystems/pos/middleware
#DRIOS F
TOPAZ_APP_KETL_NEW=$INSTALL_PATH/11_KETTLES/userlibrary/default/tools/kettle/packages
#VCA I
TOPAZ_APP_KETL_PLUG_NEW=$INSTALL_PATH/11_KETTLES/userlibrary/default/tools/kettle/plugins
#VCA F
TOPAZ_APP_CONF_DATASRV_NEW=$INSTALL_PATH/04_XMLS/userlibrary/default/conf/dataserver
TOPAZ_APP_CONF_DATAMPN_NEW=$INSTALL_PATH/04_XMLS/userlibrary/default/conf/dataserver/datamapping
TOPAZ_APP_PROCESSMGR_NEW=$INSTALL_PATH/04_XMLS/userlibrary/default/python/topsystems/processmgr
TOPAZ_APP_SERVICES_NEW=$INSTALL_PATH/04_XMLS/userlibrary/default/services
TOPAZ_APP_SERVICES_LOANS_NEW=$INSTALL_PATH/04_XMLS/userlibrary/default/services/loans
TOPAZ_APP_SERVICES_CHARGES_NEW=$INSTALL_PATH/04_XMLS/userlibrary/default/services/charges
TOPAZ_APP_TOOLS_NEW=$INSTALL_PATH/04_XMLS/userlibrary/default/tools
JBOSS_SERVICE_NEW=$INSTALL_PATH/13_TOPAZ_EAR_SERVICE/server_sar/META-INF

TOPAZ_LIB_CLIENT_NEW=$INSTALL_PATH/09_JARS/01-Client
TOPAZ_LIB_CUSTOM_NEW=$INSTALL_PATH/09_JARS/02-Custom
TOPAZ_LIB_SERVER_NEW=$INSTALL_PATH/09_JARS/03-Server
TOPAZ_IMAGE_SERVER_NEW=$INSTALL_PATH/10_IMAGES
LIB_CLIENT_NEW=$INSTALL_PATH/09_JARS/04-Lib
TOPAZ_APP_NEW=$INSTALL_PATH/09_JARS/06-Configuration

OPERS_NEW=$INSTALL_PATH/06_OPERS
FORMS_NEW=$INSTALL_PATH/07_FORMS
FORMS_XML_NEW=$INSTALL_PATH/07_FORMS/jtopazspec
#DPS I
FORMS_IMGS_NEW=$INSTALL_PATH/07_FORMS/jtopazspec/imgs
#DPS F
FORMS_JASPER_NEW=$INSTALL_PATH/07_FORMS/jasperReports
KETTLE_JASPER_NEW=$INSTALL_PATH/08_KETTLE_JASPER

LIB_SERVER_NEW=$INSTALL_PATH/09_JARS/05-LibServer
#VCA I
KETTLE_FILE_PARAM_NEW=$INSTALL_PATH/14_KETTLE_FILE_PARAM
#VCA F

#RMM I
TOPAZ_HTML_NEW=$INSTALL_PATH/04_XMLS/userlibrary/default/mails/html
#RMM F

#WCM I Harvest
export TOPAZ_IPS_PROD TOPAZ_NOM_SVR_JNLP TOPAZ_JNLP_2
#WCM F
export TOPAZ_SHELL_DIR
export TOPAZ_LIB_LIST_CLIENT
export TOPAZ_LIB_LIST_CUSTOM
export TOPAZ_LIB_LIST_SERVER
export TOPAZ_CONF_NEW
export TOPAZ_DEPLOY_NEW
export TOPAZ_APP_PROP_NEW
export TOPAZ_APP_PYTHON_NEW
#DRIOS I
export TOPAZ_APP_PYTHON_POS_NEW
export TOPAZ_APP_PYTHON_GLOBOKAST_NEW
export TOPAZ_APP_PYTHON_UNIBANCA_NEW
export TOPAZ_APP_PYTHON_MDWARE_NEW
#DRIOS F
export TOPAZ_APP_SRV_NEW
export TOPAZ_APP_CONF_NEW
export TOPAZ_APP_CONF_DATASRV_NEW
export TOPAZ_APP_CONF_DATAMPN_NEW
export TOPAZ_APP_PROCESSMGR_NEW
export TOPAZ_APP_SERVICES_NEW
export TOPAZ_APP_SERVICES_LOANS_NEW
export TOPAZ_APP_SERVICES_CHARGES_NEW
export TOPAZ_APP_TOOLS_NEW
export TOPAZ_APP_KETL_NEW
export TOPAZ_APP_KETL_PLUG_NEW
export TOPAZ_LIB_CLIENT_NEW
export TOPAZ_LIB_CUSTOM_NEW
export TOPAZ_LIB_SERVER_NEW
export FORMS_JASPER_NEW
export LIB_CLIENT_NEW
export LIB_SERVER_NEW
export OPERS_NEW
export FORMS_NEW
export FORMS_XML_NEW
#DPS I
export FORMS_IMGS_NEW
#DPS F
export TOPAZ_IMAGES_LIST_SERVER
export TOPAZ_IMAGE_SERVER_NEW
export KETTLE_JASPER_NEW
export JBOSS_SERVICE_NEW
export TOPAZ_APP_NEW
#VCA I
export KETTLE_FILE_PARAM_NEW
#VCA F
#RMM I
export TOPAZ_HTML_NEW
#RMM F

# Definicion de variables de entorno del respaldo
echo "Definicion de variables de entorno del respaldo"
echo "Definicion de variables de entorno del respaldo" >> $INSTALL_LOG

BACKUP_PATH=/u01/PASES/CASO-$NUM_CASO/Backup_CASO-$NUM_CASO
export BACKUP_PATH

if [ -d $BACKUP_PATH ];
then
echo ""
echo ""
echo "El directorio \""$BACKUP_PATH"\" ya existe, favor de borrarlo para poder instalar"
exit 2
else
`mkdir -p $BACKUP_PATH`
fi

# Copiar nuevos componentes (Jars TOPAZ Core Server)
echo "BACKUP_PATH = "$BACKUP_PATH
echo "BACKUP_PATH = "$BACKUP_PATH >> $INSTALL_LOG
echo " "
echo " " >> $INSTALL_LOG

BACKUP_JBOSS=$BACKUP_PATH/$JBOSS_FOLDER.tar.gz
export BACKUP_JBOSS
echo "BACKUP_JBOSS = "$BACKUP_JBOSS
echo "BACKUP_JBOSS = "$BACKUP_JBOSS >> $INSTALL_LOG
echo " "
echo " " >> $INSTALL_LOG

BACKUP_BIBLIOTECA=$BACKUP_PATH/$BIBLIOTECA_FOLDER.tar.gz
export BACKUP_BIBLIOTECA
echo "BACKUP_BIBLIOTECA = "$BACKUP_BIBLIOTECA
echo "BACKUP_BIBLIOTECA = "$BACKUP_BIBLIOTECA >> $INSTALL_LOG
echo " "
echo " " >> $INSTALL_LOG

cd /u01/PASES

echo " "
echo " " >> $INSTALL_LOG
echo "**************************************************************************************************"
echo "**************************************************************************************************" >> $INSTALL_LOG
echo "Respaldo de componentes TOPAZ y preparacion de los instaladores"
echo "Respaldo de componentes TOPAZ y preparacion de los instaladores" >> $INSTALL_LOG
echo " "
echo " " >> $INSTALL_LOG

if [[ $ALTO_IMPACTO == [Ss][Ii] ]]; then
echo "Generando respaldo de JBoss - TOPAZ"
echo "Generando respaldo de JBoss - TOPAZ" >> $INSTALL_LOG

echo "tar -czvf "$BACKUP_PATH"/eap709.tar.gz "$JBOSS_FOLDER
echo "tar -czvf "$BACKUP_PATH"/eap709.tar.gz "$JBOSS_FOLDER >> $INSTALL_LOG
tar -czvf /u01/PASES/eap709.tar.gz $JBOSS_FOLDER >> $INSTALL_LOG 2>> $ERROR_LOG
echo "mv /u01/PASES/eap709.tar.gz "$BACKUP_PATH"/."
mv /u01/PASES/eap709.tar.gz $BACKUP_PATH/.

echo " "
echo " " >> $INSTALL_LOG
echo "Generando respaldo de la biblioteca TOPAZ"
echo "Generando respaldo de la biblioteca TOPAZ" >> $INSTALL_LOG

echo "tar -czvf "$BACKUP_PATH"/biblioteca.tar.gz "$BIBLIOTECA_FOLDER
echo "tar -czvf "$BACKUP_PATH"/biblioteca.tar.gz "$BIBLIOTECA_FOLDER >> $INSTALL_LOG
tar -czvf /u01/PASES/biblioteca.tar.gz $BIBLIOTECA_FOLDER >> $INSTALL_LOG 2>> $ERROR_LOG
echo "mv /u01/PASES/biblioteca.tar.gz "$BACKUP_PATH"/."
mv /u01/PASES/biblioteca.tar.gz $BACKUP_PATH/.
elif [[ $ALTO_IMPACTO == [Nn][Oo] ]]; then
echo "NO SE RESPALDA TODA LA CARPETA "$JBOSS_FOLDER" AL NO TRATARSE DE UN PASE DE ALTO IMPACTO"
echo "NO SE RESPALDA TODA LA CARPETA "$JBOSS_FOLDER" AL NO TRATARSE DE UN PASE DE ALTO IMPACTO" >> $INSTALL_LOG
echo " "
echo " " >> $INSTALL_LOG
echo "NO SE RESPALDA TODA LA CARPETA "$BIBLIOTECA_FOLDER" AL NO TRATARSE DE UN PASE DE ALTO IMPACTO"
echo "NO SE RESPALDA TODA LA CARPETA "$BIBLIOTECA_FOLDER" AL NO TRATARSE DE UN PASE DE ALTO IMPACTO" >> $INSTALL_LOG
echo " "
echo " " >> $INSTALL_LOG
fi

if [ -f $INSTALL_FILE ]; then
echo " "
echo " " >> $INSTALL_LOG
echo "Descomprimiendo instaladores "$INSTALL_FILE
echo "Descomprimiendo instaladores "$INSTALL_FILE >> $INSTALL_LOG
echo " "
echo " " >> $INSTALL_LOG

cd /u01/PASES
if [ -d $INSTALL_FOLDER ]; then
rm -rf $INSTALL_FOLDER
echo " "
echo " " >> $INSTALL_LOG
echo "(Se procede a eliminar el directorio antiguo del instalador)"
echo "(Se procede a eliminar el directorio antiguo del instalador)" >> $INSTALL_LOG
echo " "
echo " " >> $INSTALL_LOG
fi
unzip $INSTALL_FILE

#WCM I Seteo permisos de lectura y escritura a los archivos y ademas de ejecucion a los directorios descomprimidos
find $INSTALL_FOLDER -type d -exec chmod 0775 {} \;
find $INSTALL_FOLDER -type f -exec chmod 0664 {} \;
#WCM F

echo " "
echo " " >> $INSTALL_LOG

else
echo " "
echo " " >> $INSTALL_LOG
echo "NO SE ENCUENTRA EL INSTALADOR (ARCHIVO "$INSTALL_FILE") EN LA RUTA /u01/PASES"
echo "NO SE ENCUENTRA EL INSTALADOR (ARCHIVO "$INSTALL_FILE") EN LA RUTA /u01/PASES" >> $INSTALL_LOG 2>> $ERROR_LOG
echo " "
echo " " >> $INSTALL_LOG
echo "SE ABORTA EL PROCESO DE INSTALACION"
echo "SE ABORTA EL PROCESO DE INSTALACION" >> $INSTALL_LOG 2>> $ERROR_LOG
echo " "
echo " " >> $INSTALL_LOG
exit 2
fi

echo " "
echo " " >> $INSTALL_LOG
echo "**************************************************************************************************"
echo "**************************************************************************************************" >> $INSTALL_LOG
echo "Instalacion de operaciones TOPAZ"
echo "Instalacion de operaciones TOPAZ" >> $INSTALL_LOG
echo " "
echo " " >> $INSTALL_LOG

# Respaldar componentes antiguos (Operaciones)
echo "Respaldar componentes antiguos (Operaciones)"
echo "Respaldar componentes antiguos (Operaciones)" >> $INSTALL_LOG

if [ -d $BACKUP_PATH/Componentes/06_OPERS ];
then
echo "Se encontro respaldo componentes antiguos (Operaciones)"
echo "Se encontro respaldo componentes antiguos (Operaciones)" >> $INSTALL_LOG
echo "El directorio \""$BACKUP_PATH"/Componentes/06_OPERS\" ya existe"
echo "El directorio \""$BACKUP_PATH"/Componentes/06_OPERS\" ya existe" >> $INSTALL_LOG
else
mkdir -p $BACKUP_PATH/Componentes/06_OPERS

ls $OPERS_NEW | grep ".\.OPE$" > $BACKUP_PATH/Componentes/06_OPERS/lista_news_opers.txt

for archivo in $(ls $OPERS_NEW | grep ".\.OPE$")
do
	if [ -e $OPERS/$archivo ];
	then
		$(mv $OPERS/$archivo $BACKUP_PATH/Componentes/06_OPERS 2>> $ERROR_LOG)
		if [ $? -eq 0 ]; then
			echo "Se respaldo y elimino el archivo "$OPERS/$archivo
			echo "Se respaldo y elimino el archivo "$OPERS/$archivo >> $INSTALL_LOG
		else
			echo "No se encontro el archivo "$OPERS/$archivo
			echo "No se encontro el archivo "$OPERS/$archivo >> $INSTALL_LOG
		fi
	else
		echo "No se encontro el archivo "$OPERS/$archivo
		echo "No se encontro el archivo "$OPERS/$archivo >> $INSTALL_LOG
	fi
done
fi

echo " "
echo " " >> $INSTALL_LOG

# Copiar nuevos componentes (Operaciones)
echo "Copiar nuevos componentes (Operaciones) a la ruta "$OPERS
echo "Copiar nuevos componentes (Operaciones) a la ruta "$OPERS >> $INSTALL_LOG

for archivo in $(ls $OPERS_NEW | grep ".\.OPE$")
do
	$(mv $OPERS_NEW/$archivo $OPERS 2>> $ERROR_LOG)
	echo "Se copio el archivo "$OPERS_NEW/$archivo
	echo "Se copio el archivo "$OPERS_NEW/$archivo >> $INSTALL_LOG
done

echo " "
echo " " >> $INSTALL_LOG

# Respaldar componentes antiguos (Transacciones)
echo "Respaldar componentes antiguos (Transacciones)"
echo "Respaldar componentes antiguos (Transacciones)" >> $INSTALL_LOG

if [ -d $BACKUP_PATH/Componentes/06_OPERS/TTR ];
then
echo "Se encontro respaldo componentes antiguos (Transacciones)"
echo "Se encontro respaldo componentes antiguos (Transacciones)" >> $INSTALL_LOG
echo "El directorio \""$BACKUP_PATH"/Componentes/06_OPERS/TTR\" ya existe"
echo "El directorio \""$BACKUP_PATH"/Componentes/06_OPERS/TTR\" ya existe" >> $INSTALL_LOG
else
mkdir -p $BACKUP_PATH/Componentes/06_OPERS/TTR

ls $OPERS_NEW/TTR | grep ".\.TTR$" > $BACKUP_PATH/Componentes/06_OPERS/TTR/lista_news_ttrs.txt

for archivo in $(ls $OPERS_NEW/TTR | grep ".\.TTR$")
do
	if [ -e $OPERS/$archivo ];
	then
		$(mv $OPERS/$archivo $BACKUP_PATH/Componentes/06_OPERS/TTR 2>> $ERROR_LOG)
		if [ $? -eq 0 ]; then
			echo "Se respaldo y elimino el archivo "$OPERS/$archivo
			echo "Se respaldo y elimino el archivo "$OPERS/$archivo >> $INSTALL_LOG
		else
			echo "No se encontro el archivo "$OPERS/$archivo
			echo "No se encontro el archivo "$OPERS/$archivo >> $INSTALL_LOG
		fi
	else
		echo "No se encontro el archivo "$OPERS/$archivo
		echo "No se encontro el archivo "$OPERS/$archivo >> $INSTALL_LOG
	fi
done
fi

echo " "
echo " " >> $INSTALL_LOG

# Copiar nuevos componentes (Transacciones)
echo "Copiar nuevos componentes (Transacciones) a la ruta "$OPERS
echo "Copiar nuevos componentes (Transacciones) a la ruta "$OPERS >> $INSTALL_LOG

for archivo in $(ls $OPERS_NEW/TTR | grep ".\.TTR$")
do
	$(mv $OPERS_NEW/TTR/$archivo $OPERS 2>> $ERROR_LOG)
	echo "Se copio el archivo "$OPERS_NEW/$archivo
	echo "Se copio el archivo "$OPERS_NEW/$archivo >> $INSTALL_LOG
done

echo " "
echo " " >> $INSTALL_LOG
echo "**************************************************************************************************"
echo "**************************************************************************************************" >> $INSTALL_LOG
echo "Instalacion de formularios TOPAZ"
echo "Instalacion de formularios TOPAZ" >> $INSTALL_LOG
echo " "
echo " " >> $INSTALL_LOG

# Respaldar componentes antiguos (Formularios)
echo "Respaldar componentes antiguos (Formularios)"
echo "Respaldar componentes antiguos (Formularios)" >> $INSTALL_LOG

if [ -d $BACKUP_PATH/Componentes/07_FORMS ];
then
echo "Se encontro respaldo componentes antiguos (Formularios)"
echo "Se encontro respaldo componentes antiguos (Formularios)" >> $INSTALL_LOG
echo "El directorio \""$BACKUP_PATH"/Componentes/07_FORMS\" ya existe"
echo "El directorio \""$BACKUP_PATH"/Componentes/07_FORMS\" ya existe" >> $INSTALL_LOG
else
mkdir -p $BACKUP_PATH/Componentes/07_FORMS

ls $FORMS_NEW | grep ".\.FRM$" > $BACKUP_PATH/Componentes/07_FORMS/lista_news_forms.txt

for archivo in $(ls $FORMS_NEW | grep ".\.FRM$")
do
	if [ -e $FORMS/$archivo ];
	then
		$(mv $FORMS/$archivo $BACKUP_PATH/Componentes/07_FORMS 2>> $ERROR_LOG)
		if [ $? -eq 0 ]; then
			echo "Se respaldo y elimino el archivo "$FORMS/$archivo
			echo "Se respaldo y elimino el archivo "$FORMS/$archivo >> $INSTALL_LOG
		else
			echo "No se encontro el archivo "$FORMS/$archivo
			echo "No se encontro el archivo "$FORMS/$archivo >> $INSTALL_LOG
		fi
	else
		echo "No se encontro el archivo "$FORMS/$archivo
		echo "No se encontro el archivo "$FORMS/$archivo >> $INSTALL_LOG
	fi
done
fi

echo " "
echo " " >> $INSTALL_LOG

# Copiar nuevos componentes (Formularios)
echo "Copiar nuevos componentes (Formularios) a la ruta "$FORMS
echo "Copiar nuevos componentes (Formularios) a la ruta "$FORMS >> $INSTALL_LOG

for archivo in $(ls $FORMS_NEW | grep ".\.FRM$")
do
	$(mv $FORMS_NEW/$archivo $FORMS 2>> $ERROR_LOG)
	echo "Se copio el archivo "$FORMS_NEW/$archivo
	echo "Se copio el archivo "$FORMS_NEW/$archivo >> $INSTALL_LOG
done

echo " "
echo " " >> $INSTALL_LOG

# Respaldar componentes antiguos (Formularios XML)
echo "Respaldar componentes antiguos (Formularios XML)"
echo "Respaldar componentes antiguos (Formularios XML)" >> $INSTALL_LOG

if [ -d $BACKUP_PATH/Componentes/07_FORMS/jtopazspec ];
then
echo "Se encontro respaldo componentes antiguos (Formularios XML)"
echo "Se encontro respaldo componentes antiguos (Formularios XML)" >> $INSTALL_LOG
echo "El directorio \""$BACKUP_PATH"/Componentes/07_FORMS/jtopazspec\" ya existe"
echo "El directorio \""$BACKUP_PATH"/Componentes/07_FORMS/jtopazspec\" ya existe" >> $INSTALL_LOG
else
mkdir -p $BACKUP_PATH/Componentes/07_FORMS/jtopazspec

ls $FORMS_XML_NEW | grep ".\.XML$" > $BACKUP_PATH/Componentes/07_FORMS/jtopazspec/lista_news_forms_xml.txt

for archivo in $(ls $FORMS_XML_NEW | grep ".\.XML$")
do
	if [ -e $FORMS_XML/$archivo ];
	then
		$(mv $FORMS_XML/$archivo $BACKUP_PATH/Componentes/07_FORMS/jtopazspec 2>> $ERROR_LOG)
		if [ $? -eq 0 ]; then
			echo "Se respaldo y elimino el archivo "$FORMS_XML/$archivo
			echo "Se respaldo y elimino el archivo "$FORMS_XML/$archivo >> $INSTALL_LOG
		else
			echo "No se encontro el archivo "$FORMS_XML/$archivo
			echo "No se encontro el archivo "$FORMS_XML/$archivo >> $INSTALL_LOG
		fi
	else
		echo "No se encontro el archivo "$FORMS_XML/$archivo
		echo "No se encontro el archivo "$FORMS_XML/$archivo >> $INSTALL_LOG
	fi
done
fi

echo " "
echo " " >> $INSTALL_LOG

# Copiar nuevos componentes (Formularios XML)
echo "Copiar nuevos componentes (Formularios XML) a la ruta "$FORMS_XML
echo "Copiar nuevos componentes (Formularios XML) a la ruta "$FORMS_XML >> $INSTALL_LOG

for archivo in $(ls $FORMS_XML_NEW | grep ".\.XML$")
do
	$(mv $FORMS_XML_NEW/$archivo $FORMS_XML 2>> $ERROR_LOG)
	echo "Se copio el archivo "$FORMS_XML_NEW/$archivo
	echo "Se copio el archivo "$FORMS_XML_NEW/$archivo >> $INSTALL_LOG
done

# DRIOS 03 ini

echo " "
echo " " >> $INSTALL_LOG

# Respaldar componentes antiguos (Formularios JASPER)
echo "Respaldar componentes antiguos (Formularios JASPER)"
echo "Respaldar componentes antiguos (Formularios JASPER)" >> $INSTALL_LOG

if [ -d $BACKUP_PATH/Componentes/07_FORMS/jasperReports ];
then
echo "Se encontro respaldo componentes antiguos (Formularios JASPER)"
echo "Se encontro respaldo componentes antiguos (Formularios JASPER)" >> $INSTALL_LOG
echo "El directorio \""$BACKUP_PATH"/Componentes/07_FORMS/jasperReports\" ya existe"
echo "El directorio \""$BACKUP_PATH"/Componentes/07_FORMS/jasperReports\" ya existe" >> $INSTALL_LOG
else
mkdir -p $BACKUP_PATH/Componentes/07_FORMS/jasperReports

ls $FORMS_JASPER_NEW | grep ".\.jasper$" > $BACKUP_PATH/Componentes/07_FORMS/jasperReports/lista_news_jasper_report.txt

#Reemplaza variable de separador que era espacio en blanco por otro valor para soportar archivos con espacios en blanco en su nombre
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
for archivo in $(ls $FORMS_JASPER_NEW | grep ".\.jasper$")
do
	if [ -e "$FORMS_JASPER/$archivo" ];
	then
		$(mv "$FORMS_JASPER/$archivo" $BACKUP_PATH/Componentes/07_FORMS/jasperReports 2>> $ERROR_LOG)
		if [ $? -eq 0 ]; then
			echo "Se respaldo y elimino el archivo "$FORMS_JASPER/$archivo
			echo "Se respaldo y elimino el archivo "$FORMS_JASPER/$archivo >> $INSTALL_LOG
		else
			echo "No se encontro el archivo "$FORMS_JASPER/$archivo
			echo "No se encontro el archivo "$FORMS_JASPER/$archivo >> $INSTALL_LOG
		fi
	else
		echo "No se encontro el archivo "$FORMS_JASPER/$archivo
		echo "No se encontro el archivo "$FORMS_JASPER/$archivo >> $INSTALL_LOG
	fi
done
IFS=$SAVEIFS

ls $FORMS_JASPER_NEW | grep ".\.jrxml$" > $BACKUP_PATH/Componentes/07_FORMS/jasperReports/lista_news_jrxml.txt

#Reemplaza variable de separador que era espacio en blanco por otro valor para soportar archivos con espacios en blanco en su nombre
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
for archivo in $(ls $FORMS_JASPER_NEW | grep ".\.jrxml$")
do
	if [ -e "$FORMS_JASPER/$archivo" ];
	then
		$(mv "$FORMS_JASPER/$archivo" $BACKUP_PATH/Componentes/07_FORMS/jasperReports 2>> $ERROR_LOG)
		if [ $? -eq 0 ]; then
			echo "Se respaldo y elimino el archivo "$FORMS_JASPER/$archivo
			echo "Se respaldo y elimino el archivo "$FORMS_JASPER/$archivo >> $INSTALL_LOG
		else
			echo "No se encontro el archivo "$FORMS_JASPER/$archivo
			echo "No se encontro el archivo "$FORMS_JASPER/$archivo >> $INSTALL_LOG
		fi
	else
		echo "No se encontro el archivo "$FORMS_JASPER/$archivo
		echo "No se encontro el archivo "$FORMS_JASPER/$archivo >> $INSTALL_LOG
	fi
done
IFS=$SAVEIFS
fi

echo " "
echo " " >> $INSTALL_LOG

# Copiar nuevos componentes (Formularios JASPER)
echo "Copiar nuevos componentes (Formularios JASPER) a la ruta "$FORMS_JASPER
echo "Copiar nuevos componentes (Formularios JASPER) a la ruta "$FORMS_JASPER >> $INSTALL_LOG

#Reemplaza variable de separador que era espacio en blanco por otro valor para soportar archivos con espacios en blanco en su nombre
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
for archivo in $(ls $FORMS_JASPER_NEW | grep ".\.jasper$")
do
	$(mv "$FORMS_JASPER_NEW/$archivo" $FORMS_JASPER 2>> $ERROR_LOG)
	echo "Se copio el archivo "$FORMS_JASPER_NEW/$archivo
	echo "Se copio el archivo "$FORMS_JASPER_NEW/$archivo >> $INSTALL_LOG
done

for archivo in $(ls $FORMS_JASPER_NEW | grep ".\.jrxml$")
do
	$(mv "$FORMS_JASPER_NEW/$archivo" $FORMS_JASPER 2>> $ERROR_LOG)
	echo "Se copio el archivo "$FORMS_JASPER_NEW/$archivo
	echo "Se copio el archivo "$FORMS_JASPER_NEW/$archivo >> $INSTALL_LOG
done
IFS=$SAVEIFS
# DRIOS 03 fin

echo " "
echo " " >> $INSTALL_LOG

echo "**************************************************************************************************"
echo "**************************************************************************************************" >> $INSTALL_LOG
echo "Instalacion de archivos de configuracion TOPAZ"
echo "Instalacion de archivos de configuracion TOPAZ" >> $INSTALL_LOG
echo " "
echo " " >> $INSTALL_LOG

# Respaldar componentes antiguos (Archivos de configuracion XML)
echo "Respaldar componentes antiguos (Archivos de configuracion XML)"
echo "Respaldar componentes antiguos (Archivos de configuracion XML)" >> $INSTALL_LOG

if [ -d $BACKUP_PATH/Componentes/04_XMLS/userlibrary/default/conf ];
then
echo "Se encontro respaldo componentes antiguos (Archivos de configuracion XML)"
echo "Se encontro respaldo componentes antiguos (Archivos de configuracion XML)" >> $INSTALL_LOG
echo "El directorio \""$BACKUP_PATH"/Componentes/04_XMLS/userlibrary/default/conf\" ya existe"
echo "El directorio \""$BACKUP_PATH"/Componentes/04_XMLS/userlibrary/default/conf\" ya existe" >> $INSTALL_LOG
else
mkdir -p $BACKUP_PATH/Componentes/04_XMLS/userlibrary/default/conf

ls $TOPAZ_APP_CONF_NEW | grep ".\.xml$" > $BACKUP_PATH/Componentes/04_XMLS/userlibrary/default/conf/lista_news_app_conf.txt

for archivo in $(ls $TOPAZ_APP_CONF_NEW | grep ".\.xml$")
do
	if [ -e $TOPAZ_APP_CONF/$archivo ];
	then
		$(mv $TOPAZ_APP_CONF/$archivo $BACKUP_PATH/Componentes/04_XMLS/userlibrary/default/conf 2>> $ERROR_LOG)
		if [ $? -eq 0 ]; then
			echo "Se respaldo y elimino el archivo "$TOPAZ_APP_CONF/$archivo
			echo "Se respaldo y elimino el archivo "$TOPAZ_APP_CONF/$archivo >> $INSTALL_LOG
		else
			echo "No se encontro el archivo "$TOPAZ_APP_CONF/$archivo
			echo "No se encontro el archivo "$TOPAZ_APP_CONF/$archivo >> $INSTALL_LOG
		fi
	else
		echo "No se encontro el archivo "$TOPAZ_APP_CONF/$archivo
		echo "No se encontro el archivo "$TOPAZ_APP_CONF/$archivo >> $INSTALL_LOG
	fi
done
fi

echo " "
echo " " >> $INSTALL_LOG

# Copiar nuevos componentes (Archivos de configuracion XML)
echo "Copiar nuevos componentes (Archivos de configuracion XML) a la ruta "$TOPAZ_APP_CONF
echo "Copiar nuevos componentes (Archivos de configuracion XML) a la ruta "$TOPAZ_APP_CONF >> $INSTALL_LOG

for archivo in $(ls $TOPAZ_APP_CONF_NEW | grep ".\.xml$")
do
	$(mv $TOPAZ_APP_CONF_NEW/$archivo $TOPAZ_APP_CONF 2>> $ERROR_LOG)
	echo "Se copio el archivo "$TOPAZ_APP_CONF_NEW/$archivo
	echo "Se copio el archivo "$TOPAZ_APP_CONF_NEW/$archivo >> $INSTALL_LOG
done

echo " "
echo " " >> $INSTALL_LOG

# DRIOS 01 srv ini
# Respaldar componentes antiguos (Archivos de configuracion SRV)
echo "Respaldar componentes antiguos (Archivos de configuracion SRV)"
echo "Respaldar componentes antiguos (Archivos de configuracion SRV)" >> $INSTALL_LOG

if [ -d $BACKUP_PATH/Componentes/04_XMLS/userlibrary/default/conf/srv ];
then
echo "Se encontro respaldo componentes antiguos (Archivos de configuracion SRV)"
echo "Se encontro respaldo componentes antiguos (Archivos de configuracion SRV)" >> $INSTALL_LOG
echo "El directorio \""$BACKUP_PATH"/Componentes/04_XMLS/userlibrary/default/conf/srv\" ya existe"
echo "El directorio \""$BACKUP_PATH"/Componentes/04_XMLS/userlibrary/default/conf/srv\" ya existe" >> $INSTALL_LOG
else
mkdir -p $BACKUP_PATH/Componentes/04_XMLS/userlibrary/default/conf/srv

ls $TOPAZ_APP_SRV_NEW | grep ".\.srv$" > $BACKUP_PATH/Componentes/04_XMLS/userlibrary/default/conf/srv/lista_news_app_srv.txt

for archivo in $(ls $TOPAZ_APP_SRV_NEW | grep ".\.srv$")
do
	if [ -e $TOPAZ_APP_SRV/$archivo ];
	then
		$(mv $TOPAZ_APP_SRV/$archivo $BACKUP_PATH/Componentes/04_XMLS/userlibrary/default/conf/srv 2>> $ERROR_LOG)
		if [ $? -eq 0 ]; then
			echo "Se respaldo y elimino el archivo "$TOPAZ_APP_SRV/$archivo
			echo "Se respaldo y elimino el archivo "$TOPAZ_APP_SRV/$archivo >> $INSTALL_LOG
		else
			echo "No se encontro el archivo "$TOPAZ_APP_SRV/$archivo
			echo "No se encontro el archivo "$TOPAZ_APP_SRV/$archivo >> $INSTALL_LOG
		fi
	else
		echo "No se encontro el archivo "$TOPAZ_APP_SRV/$archivo
		echo "No se encontro el archivo "$TOPAZ_APP_SRV/$archivo >> $INSTALL_LOG
	fi
done
fi

echo " "
echo " " >> $INSTALL_LOG

# Copiar nuevos componentes (Archivos SRV)
echo "Copiar nuevos componentes (Archivos SRV) a la ruta "$TOPAZ_APP_SRV
echo "Copiar nuevos componentes (Archivos SRV) a la ruta "$TOPAZ_APP_SRV >> $INSTALL_LOG

for archivo in $(ls $TOPAZ_APP_SRV_NEW | grep ".\.srv$")
do
	$(mv $TOPAZ_APP_SRV_NEW/$archivo $TOPAZ_APP_SRV 2>> $ERROR_LOG)
	echo "Se copio el archivo "$TOPAZ_APP_SRV_NEW/$archivo
	echo "Se copio el archivo "$TOPAZ_APP_SRV_NEW/$archivo >> $INSTALL_LOG
done

echo " "
echo " " >> $INSTALL_LOG

# DRIOS 01 srv fin

# DRIOS 01 ini
# Respaldar componentes antiguos (Archivos de configuracion PROPERTIES)
echo "Respaldar componentes antiguos (Archivos de configuracion PROPERTIES)"
echo "Respaldar componentes antiguos (Archivos de configuracion PROPERTIES)" >> $INSTALL_LOG

if [ -d $BACKUP_PATH/Componentes/04_XMLS/userlibrary/default/conf/properties ];
then
echo "Se encontro respaldo componentes antiguos (Archivos de configuracion PROPERTIES)"
echo "Se encontro respaldo componentes antiguos (Archivos de configuracion PROPERTIES)" >> $INSTALL_LOG
echo "El directorio \""$BACKUP_PATH"/Componentes/04_XMLS/userlibrary/default/conf/properties\" ya existe"
echo "El directorio \""$BACKUP_PATH"/Componentes/04_XMLS/userlibrary/default/conf/properties\" ya existe" >> $INSTALL_LOG
else
mkdir -p $BACKUP_PATH/Componentes/04_XMLS/userlibrary/default/conf/properties

ls $TOPAZ_APP_PROP_NEW | grep ".\.properties$" > $BACKUP_PATH/Componentes/04_XMLS/userlibrary/default/conf/properties/lista_news_app_prop.txt

for archivo in $(ls $TOPAZ_APP_PROP_NEW | grep ".\.properties$")
do
	if [ -e $TOPAZ_APP_PROP/$archivo ];
	then
		$(mv $TOPAZ_APP_PROP/$archivo $BACKUP_PATH/Componentes/04_XMLS/userlibrary/default/conf/properties 2>> $ERROR_LOG)
		if [ $? -eq 0 ]; then
			echo "Se respaldo y elimino el archivo "$TOPAZ_APP_PROP/$archivo
			echo "Se respaldo y elimino el archivo "$TOPAZ_APP_PROP/$archivo >> $INSTALL_LOG
		else
			echo "No se encontro el archivo "$TOPAZ_APP_PROP/$archivo
			echo "No se encontro el archivo "$TOPAZ_APP_PROP/$archivo >> $INSTALL_LOG
		fi
	else
		echo "No se encontro el archivo "$TOPAZ_APP_PROP/$archivo
		echo "No se encontro el archivo "$TOPAZ_APP_PROP/$archivo >> $INSTALL_LOG
	fi
done
fi

echo " "
echo " " >> $INSTALL_LOG

# Copiar nuevos componentes (Archivos PROPERTIES)
echo "Copiar nuevos componentes (Archivos PROPERTIES) a la ruta "$TOPAZ_APP_PROP
echo "Copiar nuevos componentes (Archivos PROPERTIES) a la ruta "$TOPAZ_APP_PROP >> $INSTALL_LOG

for archivo in $(ls $TOPAZ_APP_PROP_NEW | grep ".\.properties$")
do
	$(mv $TOPAZ_APP_PROP_NEW/$archivo $TOPAZ_APP_PROP 2>> $ERROR_LOG)
	echo "Se copio el archivo "$TOPAZ_APP_PROP_NEW/$archivo
	echo "Se copio el archivo "$TOPAZ_APP_PROP_NEW/$archivo >> $INSTALL_LOG
done

echo " "
echo " " >> $INSTALL_LOG

# DRIOS 01 fin

# Respaldar componentes antiguos (Archivos de configuracion XML)
echo "Respaldar componentes antiguos (Archivos de configuracion XML - dataserver)"
echo "Respaldar componentes antiguos (Archivos de configuracion XML - dataserver)" >> $INSTALL_LOG

if [ -d $BACKUP_PATH/Componentes/04_XMLS/userlibrary/default/conf/dataserver ];
then
echo "Se encontro respaldo componentes antiguos (Archivos de configuracion XML - dataserver)"
echo "Se encontro respaldo componentes antiguos (Archivos de configuracion XML - dataserver)" >> $INSTALL_LOG
echo "El directorio \""$BACKUP_PATH"/Componentes/04_XMLS/userlibrary/default/conf/dataserver\" ya existe"
echo "El directorio \""$BACKUP_PATH"/Componentes/04_XMLS/userlibrary/default/conf/dataserver\" ya existe" >> $INSTALL_LOG
else
mkdir -p $BACKUP_PATH/Componentes/04_XMLS/userlibrary/default/conf/dataserver

ls $TOPAZ_APP_CONF_DATASRV_NEW | grep ".\.xml$" > $BACKUP_PATH/Componentes/04_XMLS/userlibrary/default/conf/dataserver/lista_news_app_datasrv.txt

for archivo in $(ls $TOPAZ_APP_CONF_DATASRV_NEW | grep ".\.xml$")
do
	if [ -e $TOPAZ_APP_CONF_DATASRV/$archivo ];
	then
		$(mv $TOPAZ_APP_CONF_DATASRV/$archivo $BACKUP_PATH/Componentes/04_XMLS/userlibrary/default/conf/dataserver 2>> $ERROR_LOG)
		if [ $? -eq 0 ]; then
			echo "Se respaldo y elimino el archivo "$TOPAZ_APP_CONF_DATASRV/$archivo
			echo "Se respaldo y elimino el archivo "$TOPAZ_APP_CONF_DATASRV/$archivo >> $INSTALL_LOG
		else
			echo "No se encontro el archivo "$TOPAZ_APP_CONF_DATASRV/$archivo
			echo "No se encontro el archivo "$TOPAZ_APP_CONF_DATASRV/$archivo >> $INSTALL_LOG
		fi
	else
		echo "No se encontro el archivo "$TOPAZ_APP_CONF_DATASRV/$archivo
		echo "No se encontro el archivo "$TOPAZ_APP_CONF_DATASRV/$archivo >> $INSTALL_LOG
	fi
done
fi

echo " "
echo " " >> $INSTALL_LOG

# Copiar nuevos componentes (Archivos de configuracion XML)
echo "Copiar nuevos componentes (Archivos de configuracion XML - dataserver) a la ruta "$TOPAZ_APP_CONF_DATASRV
echo "Copiar nuevos componentes (Archivos de configuracion XML - dataserver) a la ruta "$TOPAZ_APP_CONF_DATASRV >> $INSTALL_LOG

for archivo in $(ls $TOPAZ_APP_CONF_DATASRV_NEW | grep ".\.xml$")
do
	$(mv $TOPAZ_APP_CONF_DATASRV_NEW/$archivo $TOPAZ_APP_CONF_DATASRV 2>> $ERROR_LOG)
	echo "Se copio el archivo "$TOPAZ_APP_CONF_DATASRV_NEW/$archivo
	echo "Se copio el archivo "$TOPAZ_APP_CONF_DATASRV_NEW/$archivo >> $INSTALL_LOG
done

echo " "
echo " " >> $INSTALL_LOG

# Respaldar componentes antiguos (Archivos de configuracion XML)
echo "Respaldar componentes antiguos (Archivos de configuracion XML - datamapping)"
echo "Respaldar componentes antiguos (Archivos de configuracion XML - datamapping)" >> $INSTALL_LOG

if [ -d $BACKUP_PATH/Componentes/04_XMLS/userlibrary/default/conf/dataserver/datamapping ];
then
echo "Se encontro respaldo componentes antiguos (Archivos de configuracion XML - datamapping)"
echo "Se encontro respaldo componentes antiguos (Archivos de configuracion XML - datamapping)" >> $INSTALL_LOG
echo "El directorio \""$BACKUP_PATH"/Componentes/04_XMLS/userlibrary/default/conf/dataserver/datamapping\" ya existe"
echo "El directorio \""$BACKUP_PATH"/Componentes/04_XMLS/userlibrary/default/conf/dataserver/datamapping\" ya existe" >> $INSTALL_LOG
else
mkdir -p $BACKUP_PATH/Componentes/04_XMLS/userlibrary/default/conf/dataserver/datamapping

ls $TOPAZ_APP_CONF_DATAMPN_NEW | grep ".\.xml$" > $BACKUP_PATH/Componentes/04_XMLS/userlibrary/default/conf/dataserver/datamapping/lista_news_app_datampn.txt

for archivo in $(ls $TOPAZ_APP_CONF_DATAMPN_NEW | grep ".\.xml$")
do
	if [ -e $TOPAZ_APP_CONF_DATAMPN/$archivo ];
	then
		$(mv $TOPAZ_APP_CONF_DATAMPN/$archivo $BACKUP_PATH/Componentes/04_XMLS/userlibrary/default/conf/dataserver/datamapping 2>> $ERROR_LOG)
		if [ $? -eq 0 ]; then
			echo "Se respaldo y elimino el archivo "$TOPAZ_APP_CONF_DATAMPN/$archivo
			echo "Se respaldo y elimino el archivo "$TOPAZ_APP_CONF_DATAMPN/$archivo >> $INSTALL_LOG
		else
			echo "No se encontro el archivo "$TOPAZ_APP_CONF_DATAMPN/$archivo
			echo "No se encontro el archivo "$TOPAZ_APP_CONF_DATAMPN/$archivo >> $INSTALL_LOG
		fi
	else
		echo "No se encontro el archivo "$TOPAZ_APP_CONF_DATAMPN/$archivo
		echo "No se encontro el archivo "$TOPAZ_APP_CONF_DATAMPN/$archivo >> $INSTALL_LOG
	fi
done
fi

echo " "
echo " " >> $INSTALL_LOG

# Copiar nuevos componentes (Archivos de configuracion XML)
echo "Copiar nuevos componentes (Archivos de configuracion XML - datamapping) a la ruta "$TOPAZ_APP_CONF_DATAMPN
echo "Copiar nuevos componentes (Archivos de configuracion XML - datamapping) a la ruta "$TOPAZ_APP_CONF_DATAMPN >> $INSTALL_LOG

for archivo in $(ls $TOPAZ_APP_CONF_DATAMPN_NEW | grep ".\.xml$")
do
	$(mv $TOPAZ_APP_CONF_DATAMPN_NEW/$archivo $TOPAZ_APP_CONF_DATAMPN 2>> $ERROR_LOG)
	echo "Se copio el archivo "$TOPAZ_APP_CONF_DATAMPN_NEW/$archivo
	echo "Se copio el archivo "$TOPAZ_APP_CONF_DATAMPN_NEW/$archivo >> $INSTALL_LOG
done

echo " "
echo " " >> $INSTALL_LOG

# Respaldar componentes antiguos (Archivos de configuracion PY)
echo "Respaldar componentes antiguos (Archivos de configuracion PY - process manager)"
echo "Respaldar componentes antiguos (Archivos de configuracion PY - process manager)" >> $INSTALL_LOG

if [ -d $BACKUP_PATH/Componentes/04_XMLS/userlibrary/default/python/topsystems/processmgr ];
then
echo "Se encontro respaldo componentes antiguos (Archivos de configuracion PY - process manager)"
echo "Se encontro respaldo componentes antiguos (Archivos de configuracion PY - process manager)" >> $INSTALL_LOG
echo "El directorio \""$BACKUP_PATH"/Componentes/04_XMLS/userlibrary/default/python/topsystems/processmgr\" ya existe"
echo "El directorio \""$BACKUP_PATH"/Componentes/04_XMLS/userlibrary/default/python/topsystems/processmgr\" ya existe" >> $INSTALL_LOG
else
mkdir -p $BACKUP_PATH/Componentes/04_XMLS/userlibrary/default/python/topsystems/processmgr

ls $TOPAZ_APP_PROCESSMGR_NEW | grep ".\.py$" > $BACKUP_PATH/Componentes/04_XMLS/userlibrary/default/python/topsystems/processmgr/lista_news_app_processmgr.txt

for archivo in $(ls $TOPAZ_APP_PROCESSMGR_NEW | grep ".\.py$")
do
	$(mv $TOPAZ_APP_PROCESSMGR/$archivo $BACKUP_PATH/Componentes/04_XMLS/userlibrary/default/python/topsystems/processmgr 2>> $ERROR_LOG)
	if [ $? -eq 0 ]; then
		echo "Se respaldo y elimino el archivo "$TOPAZ_APP_PROCESSMGR/$archivo
		echo "Se respaldo y elimino el archivo "$TOPAZ_APP_PROCESSMGR/$archivo >> $INSTALL_LOG
	else
		echo "No se encontro el archivo "$TOPAZ_APP_PROCESSMGR/$archivo
		echo "No se encontro el archivo "$TOPAZ_APP_PROCESSMGR/$archivo >> $INSTALL_LOG
	fi
done
fi

echo " "
echo " " >> $INSTALL_LOG

# Copiar nuevos componentes (Archivos de configuracion PY)
echo "Copiar nuevos componentes (Archivos de configuracion PY - process manager) a la ruta "$TOPAZ_APP_PROCESSMGR
echo "Copiar nuevos componentes (Archivos de configuracion PY - process manager) a la ruta "$TOPAZ_APP_PROCESSMGR >> $INSTALL_LOG

for archivo in $(ls $TOPAZ_APP_PROCESSMGR_NEW | grep ".\.py$")
do
	$(mv $TOPAZ_APP_PROCESSMGR_NEW/$archivo $TOPAZ_APP_PROCESSMGR 2>> $ERROR_LOG)
	echo "Se copio el archivo "$TOPAZ_APP_PROCESSMGR_NEW/$archivo
	echo "Se copio el archivo "$TOPAZ_APP_PROCESSMGR_NEW/$archivo >> $INSTALL_LOG
done

echo " "
echo " " >> $INSTALL_LOG

# WCM 05 Ini
#Borrar Class del Process Manager
echo "Borrar archivos Class del Process Manager de la ruta "$TOPAZ_APP_PROCESSMGR
echo "Borrar archivos Class del Process Manager de la ruta "$TOPAZ_APP_PROCESSMGR >> $INSTALL_LOG

for archivo in $(ls $TOPAZ_APP_PROCESSMGR | grep ".\.class$")
do
	$(rm $TOPAZ_APP_PROCESSMGR/$archivo 2>> $ERROR_LOG)
	echo "Se borro el archivo class "$TOPAZ_APP_PROCESSMGR/$archivo
	echo "Se borro el archivo class "$TOPAZ_APP_PROCESSMGR/$archivo >> $INSTALL_LOG
done

echo " "
echo " " >> $INSTALL_LOG
# WCM 05 Fin

# Respaldar componentes antiguos (Archivos de configuracion XML)
echo "Respaldar componentes antiguos (Archivos de configuracion XML - services)"
echo "Respaldar componentes antiguos (Archivos de configuracion XML - services)" >> $INSTALL_LOG

if [ -d $BACKUP_PATH/Componentes/04_XMLS/userlibrary/default/services ];
then
echo "Se encontro respaldo componentes antiguos (Archivos de configuracion XML - services)"
echo "Se encontro respaldo componentes antiguos (Archivos de configuracion XML - services)" >> $INSTALL_LOG
echo "El directorio \""$BACKUP_PATH"/Componentes/04_XMLS/userlibrary/default/services\" ya existe"
echo "El directorio \""$BACKUP_PATH"/Componentes/04_XMLS/userlibrary/default/services\" ya existe" >> $INSTALL_LOG
else
mkdir -p $BACKUP_PATH/Componentes/04_XMLS/userlibrary/default/services

ls $TOPAZ_APP_SERVICES_NEW | grep ".\.xml$" > $BACKUP_PATH/Componentes/04_XMLS/userlibrary/default/services/lista_news_app_services.txt

for archivo in $(ls $TOPAZ_APP_SERVICES_NEW | grep ".\.xml$")
do
	if [ -e $TOPAZ_APP_SERVICES/$archivo ];
	then
		$(mv $TOPAZ_APP_SERVICES/$archivo $BACKUP_PATH/Componentes/04_XMLS/userlibrary/default/services 2>> $ERROR_LOG)
		if [ $? -eq 0 ]; then
			echo "Se respaldo y elimino el archivo "$TOPAZ_APP_SERVICES/$archivo
			echo "Se respaldo y elimino el archivo "$TOPAZ_APP_SERVICES/$archivo >> $INSTALL_LOG
		else
			echo "No se encontro el archivo "$TOPAZ_APP_SERVICES/$archivo
			echo "No se encontro el archivo "$TOPAZ_APP_SERVICES/$archivo >> $INSTALL_LOG
		fi
	else
		echo "No se encontro el archivo "$TOPAZ_APP_SERVICES/$archivo
		echo "No se encontro el archivo "$TOPAZ_APP_SERVICES/$archivo >> $INSTALL_LOG
	fi
done
fi

echo " "
echo " " >> $INSTALL_LOG

# Copiar nuevos componentes (Archivos de configuracion XML)
echo "Copiar nuevos componentes (Archivos de configuracion XML - services) a la ruta "$TOPAZ_APP_SERVICES
echo "Copiar nuevos componentes (Archivos de configuracion XML - services) a la ruta "$TOPAZ_APP_SERVICES >> $INSTALL_LOG

for archivo in $(ls $TOPAZ_APP_SERVICES_NEW | grep ".\.xml$")
do
	$(mv $TOPAZ_APP_SERVICES_NEW/$archivo $TOPAZ_APP_SERVICES 2>> $ERROR_LOG)
	echo "Se copio el archivo "$TOPAZ_APP_SERVICES_NEW/$archivo
	echo "Se copio el archivo "$TOPAZ_APP_SERVICES_NEW/$archivo >> $INSTALL_LOG
done

echo " "
echo " " >> $INSTALL_LOG

# Respaldar componentes antiguos (Archivos de configuracion XML)
echo "Respaldar componentes antiguos (Archivos de configuracion XML - services loans)"
echo "Respaldar componentes antiguos (Archivos de configuracion XML - services loans)" >> $INSTALL_LOG

if [ -d $BACKUP_PATH/Componentes/04_XMLS/userlibrary/default/services/loans ];
then
echo "Se encontro respaldo componentes antiguos (Archivos de configuracion XML - services loans)"
echo "Se encontro respaldo componentes antiguos (Archivos de configuracion XML - services loans)" >> $INSTALL_LOG
echo "El directorio \""$BACKUP_PATH"/Componentes/04_XMLS/userlibrary/default/services/loans\" ya existe"
echo "El directorio \""$BACKUP_PATH"/Componentes/04_XMLS/userlibrary/default/services/loans\" ya existe" >> $INSTALL_LOG
else
mkdir -p $BACKUP_PATH/Componentes/04_XMLS/userlibrary/default/services/loans

ls $TOPAZ_APP_SERVICES_LOANS_NEW | grep ".\.xml$" > $BACKUP_PATH/Componentes/04_XMLS/userlibrary/default/services/loans/lista_news_app_services_loans.txt

for archivo in $(ls $TOPAZ_APP_SERVICES_LOANS_NEW | grep ".\.xml$")
do
	if [ -e $TOPAZ_APP_SERVICES_LOANS/$archivo ];
	then
		$(mv $TOPAZ_APP_SERVICES_LOANS/$archivo $BACKUP_PATH/Componentes/04_XMLS/userlibrary/default/services/loans 2>> $ERROR_LOG)
		if [ $? -eq 0 ]; then
			echo "Se respaldo y elimino el archivo "$TOPAZ_APP_SERVICES_LOANS/$archivo
			echo "Se respaldo y elimino el archivo "$TOPAZ_APP_SERVICES_LOANS/$archivo >> $INSTALL_LOG
		else
			echo "No se encontro el archivo "$TOPAZ_APP_SERVICES_LOANS/$archivo
			echo "No se encontro el archivo "$TOPAZ_APP_SERVICES_LOANS/$archivo >> $INSTALL_LOG
		fi
	else
		echo "No se encontro el archivo "$TOPAZ_APP_SERVICES_LOANS/$archivo
		echo "No se encontro el archivo "$TOPAZ_APP_SERVICES_LOANS/$archivo >> $INSTALL_LOG
	fi
done
fi

echo " "
echo " " >> $INSTALL_LOG

# Copiar nuevos componentes (Archivos de configuracion XML)
echo "Copiar nuevos componentes (Archivos de configuracion XML - services loans) a la ruta "$TOPAZ_APP_SERVICES_LOANS
echo "Copiar nuevos componentes (Archivos de configuracion XML - services loans) a la ruta "$TOPAZ_APP_SERVICES_LOANS >> $INSTALL_LOG

for archivo in $(ls $TOPAZ_APP_SERVICES_LOANS_NEW | grep ".\.xml$")
do
	$(mv $TOPAZ_APP_SERVICES_LOANS_NEW/$archivo $TOPAZ_APP_SERVICES_LOANS 2>> $ERROR_LOG)
	echo "Se copio el archivo "$TOPAZ_APP_SERVICES_LOANS_NEW/$archivo
	echo "Se copio el archivo "$TOPAZ_APP_SERVICES_LOANS_NEW/$archivo >> $INSTALL_LOG
done

echo " "
echo " " >> $INSTALL_LOG

# Respaldar componentes antiguos (Archivos de configuracion XML)
echo "Respaldar componentes antiguos (Archivos de configuracion XML - services charges)"
echo "Respaldar componentes antiguos (Archivos de configuracion XML - services charges)" >> $INSTALL_LOG

if [ -d $BACKUP_PATH/Componentes/04_XMLS/userlibrary/default/services/charges ];
then
echo "Se encontro respaldo componentes antiguos (Archivos de configuracion XML - services charges)"
echo "Se encontro respaldo componentes antiguos (Archivos de configuracion XML - services charges)" >> $INSTALL_LOG
echo "El directorio \""$BACKUP_PATH"/Componentes/04_XMLS/userlibrary/default/services/charges\" ya existe"
echo "El directorio \""$BACKUP_PATH"/Componentes/04_XMLS/userlibrary/default/services/charges\" ya existe" >> $INSTALL_LOG
else
mkdir -p $BACKUP_PATH/Componentes/04_XMLS/userlibrary/default/services/charges

ls $TOPAZ_APP_SERVICES_CHARGES_NEW | grep ".\.xml$" > $BACKUP_PATH/Componentes/04_XMLS/userlibrary/default/services/charges/lista_news_app_services_charges.txt

for archivo in $(ls $TOPAZ_APP_SERVICES_CHARGES_NEW | grep ".\.xml$")
do
	if [ -e $TOPAZ_APP_SERVICES_CHARGES/$archivo ];
	then
		$(mv $TOPAZ_APP_SERVICES_CHARGES/$archivo $BACKUP_PATH/Componentes/04_XMLS/userlibrary/default/services/charges 2>> $ERROR_LOG)
		if [ $? -eq 0 ]; then
			echo "Se respaldo y elimino el archivo "$TOPAZ_APP_SERVICES_CHARGES/$archivo
			echo "Se respaldo y elimino el archivo "$TOPAZ_APP_SERVICES_CHARGES/$archivo >> $INSTALL_LOG
		else
			echo "No se encontro el archivo "$TOPAZ_APP_SERVICES_CHARGES/$archivo
			echo "No se encontro el archivo "$TOPAZ_APP_SERVICES_CHARGES/$archivo >> $INSTALL_LOG
		fi
	else
		echo "No se encontro el archivo "$TOPAZ_APP_SERVICES_CHARGES/$archivo
		echo "No se encontro el archivo "$TOPAZ_APP_SERVICES_CHARGES/$archivo >> $INSTALL_LOG
	fi
done
fi

echo " "
echo " " >> $INSTALL_LOG

# Copiar nuevos componentes (Archivos de configuracion XML)
echo "Copiar nuevos componentes (Archivos de configuracion XML - services charges) a la ruta "$TOPAZ_APP_SERVICES_CHARGES
echo "Copiar nuevos componentes (Archivos de configuracion XML - services charges) a la ruta "$TOPAZ_APP_SERVICES_CHARGES >> $INSTALL_LOG

for archivo in $(ls $TOPAZ_APP_SERVICES_CHARGES_NEW | grep ".\.xml$")
do
	$(mv $TOPAZ_APP_SERVICES_CHARGES_NEW/$archivo $TOPAZ_APP_SERVICES_CHARGES 2>> $ERROR_LOG)
	echo "Se copio el archivo "$TOPAZ_APP_SERVICES_CHARGES_NEW/$archivo
	echo "Se copio el archivo "$TOPAZ_APP_SERVICES_CHARGES_NEW/$archivo >> $INSTALL_LOG
done


echo " "
echo " " >> $INSTALL_LOG

# Respaldar componentes antiguos (Archivos de configuracion XML)
echo "Respaldar componentes antiguos (Archivos de configuracion XML - tools jasper)"
echo "Respaldar componentes antiguos (Archivos de configuracion XML - tools jasper)" >> $INSTALL_LOG

if [ -d $BACKUP_PATH/Componentes/04_XMLS/userlibrary/default/tools/jasper ];
then
echo "Se encontro respaldo componentes antiguos (Archivos de configuracion XML - tools jasper)"
echo "Se encontro respaldo componentes antiguos (Archivos de configuracion XML - tools jasper)" >> $INSTALL_LOG
echo "El directorio \""$BACKUP_PATH"/Componentes/04_XMLS/userlibrary/default/tools/jasper\" ya existe"
echo "El directorio \""$BACKUP_PATH"/Componentes/04_XMLS/userlibrary/default/tools/jasper\" ya existe" >> $INSTALL_LOG
else
mkdir -p $BACKUP_PATH/Componentes/04_XMLS/userlibrary/default/tools/jasper

ls $TOPAZ_APP_TOOLS_NEW/jasper | grep ".\.properties$" > $BACKUP_PATH/Componentes/04_XMLS/userlibrary/default/tools/jasper/lista_news_app_tools.txt

for archivo in $(ls $TOPAZ_APP_TOOLS_NEW/jasper | grep ".\.properties$")
do
	if [ -e $TOPAZ_APP_TOOLS/jasper/$archivo ];
	then
		$(mv $TOPAZ_APP_TOOLS/jasper/$archivo $BACKUP_PATH/Componentes/04_XMLS/userlibrary/default/tools/jasper 2>> $ERROR_LOG)
		if [ $? -eq 0 ]; then
			echo "Se respaldo y elimino el archivo "$TOPAZ_APP_TOOLS"/jasper/"$archivo
			echo "Se respaldo y elimino el archivo "$TOPAZ_APP_TOOLS"/jasper/"$archivo >> $INSTALL_LOG
		else
			echo "No se encontro el archivo "$TOPAZ_APP_TOOLS"/jasper/"$archivo
			echo "No se encontro el archivo "$TOPAZ_APP_TOOLS"/jasper/"$archivo >> $INSTALL_LOG
		fi
	else
		echo "No se encontro el archivo "$TOPAZ_APP_TOOLS"/jasper/"$archivo
		echo "No se encontro el archivo "$TOPAZ_APP_TOOLS"/jasper/"$archivo >> $INSTALL_LOG
	fi
done
fi

echo " "
echo " " >> $INSTALL_LOG

# Copiar nuevos componentes (Archivos de configuracion XML)
echo "Copiar nuevos componentes (Archivos de configuracion XML - tools jasper) a la ruta "$TOPAZ_APP_TOOLS"/jasper"
echo "Copiar nuevos componentes (Archivos de configuracion XML - tools jasper) a la ruta "$TOPAZ_APP_TOOLS"/jasper" >> $INSTALL_LOG

for archivo in $(ls $TOPAZ_APP_TOOLS_NEW/jasper | grep ".\.properties$")
do
	$(mv $TOPAZ_APP_TOOLS_NEW/jasper/$archivo $TOPAZ_APP_TOOLS/jasper 2>> $ERROR_LOG)
	echo "Se copio el archivo "$TOPAZ_APP_TOOLS_NEW"/jasper/"$archivo
	echo "Se copio el archivo "$TOPAZ_APP_TOOLS_NEW"/jasper/"$archivo >> $INSTALL_LOG
done

echo " "
echo " " >> $INSTALL_LOG

# REFA 16/02/17 INI
# Respaldar componentes antiguos (Archivos de configuracion XML)
echo "Respaldar componentes antiguos (Archivos de configuracion XML - conf)"
echo "Respaldar componentes antiguos (Archivos de configuracion XML - conf)" >> $INSTALL_LOG

if [ -d $BACKUP_PATH/Componentes/04_XMLS/conf ];
then
echo "Se encontro respaldo componentes antiguos (Archivos de configuracion XML - conf)"
echo "Se encontro respaldo componentes antiguos (Archivos de configuracion XML - conf)" >> $INSTALL_LOG
echo "El directorio \""$BACKUP_PATH"/Componentes/04_XMLS/conf\" ya existe"
echo "El directorio \""$BACKUP_PATH"/Componentes/04_XMLS/conf\" ya existe" >> $INSTALL_LOG
else
mkdir -p $BACKUP_PATH/Componentes/04_XMLS/conf

ls $TOPAZ_CONF_NEW | grep ".\.xml$" > $BACKUP_PATH/Componentes/04_XMLS/conf/lista_news_conf.txt

for archivo in $(ls $TOPAZ_CONF_NEW | grep ".\.xml$")
do
	if [ -e $TOPAZ_CONF/$archivo ];
	then
		$(mv $TOPAZ_CONF/$archivo $BACKUP_PATH/Componentes/04_XMLS/conf 2>> $ERROR_LOG)
		if [ $? -eq 0 ]; then
			echo "Se respaldo y elimino el archivo "$TOPAZ_CONF/$archivo
			echo "Se respaldo y elimino el archivo "$TOPAZ_CONF/$archivo >> $INSTALL_LOG
		else
			echo "No se encontro el archivo "$TOPAZ_CONF/$archivo
			echo "No se encontro el archivo "$TOPAZ_CONF/$archivo >> $INSTALL_LOG
		fi
	else
		echo "No se encontro el archivo "$TOPAZ_CONF/$archivo
		echo "No se encontro el archivo "$TOPAZ_CONF/$archivo >> $INSTALL_LOG
	fi
done
fi

echo " "
echo " " >> $INSTALL_LOG

# Copiar nuevos componentes (Archivos de configuracion XML)
echo "Copiar nuevos componentes (Archivos de configuracion XML - conf) a la ruta "$TOPAZ_CONF
echo "Copiar nuevos componentes (Archivos de configuracion XML - conf) a la ruta "$TOPAZ_CONF >> $INSTALL_LOG

for archivo in $(ls $TOPAZ_CONF_NEW | grep ".\.xml$")
do
	$(mv $TOPAZ_CONF_NEW/$archivo $TOPAZ_CONF 2>> $ERROR_LOG)
	echo "Se copio el archivo "$TOPAZ_CONF_NEW/$archivo
	echo "Se copio el archivo "$TOPAZ_CONF_NEW/$archivo >> $INSTALL_LOG
done

echo " "
echo " " >> $INSTALL_LOG
# REFA 16/02/17 FIN

# ABONILLA 09/06/16 Ini
# Respaldar componentes antiguos (Archivos de configuracion XML)
echo "Respaldar componentes antiguos (Archivos de configuracion XML - deploy)"
echo "Respaldar componentes antiguos (Archivos de configuracion XML - deploy)" >> $INSTALL_LOG

if [ -d $BACKUP_PATH/Componentes/04_XMLS/deploy ];
then
echo "Se encontro respaldo componentes antiguos (Archivos de configuracion XML - deploy)"
echo "Se encontro respaldo componentes antiguos (Archivos de configuracion XML - deploy)" >> $INSTALL_LOG
echo "El directorio \""$BACKUP_PATH"/Componentes/04_XMLS/deploy\" ya existe"
echo "El directorio \""$BACKUP_PATH"/Componentes/04_XMLS/deploy\" ya existe" >> $INSTALL_LOG
else
mkdir -p $BACKUP_PATH/Componentes/04_XMLS/deploy

ls $TOPAZ_DEPLOY_NEW | grep ".\.xml$" > $BACKUP_PATH/Componentes/04_XMLS/deploy/lista_news_deploy.txt

for archivo in $(ls $TOPAZ_DEPLOY_NEW | grep ".\.xml$")
do
	if [ -e $TOPAZ_DEPLOY/$archivo ];
	then
		$(mv $TOPAZ_DEPLOY/$archivo $BACKUP_PATH/Componentes/04_XMLS/deploy 2>> $ERROR_LOG)
		if [ $? -eq 0 ]; then
			echo "Se respaldo y elimino el archivo "$TOPAZ_DEPLOY/$archivo
			echo "Se respaldo y elimino el archivo "$TOPAZ_DEPLOY/$archivo >> $INSTALL_LOG
		else
			echo "No se encontro el archivo "$TOPAZ_DEPLOY/$archivo
			echo "No se encontro el archivo "$TOPAZ_DEPLOY/$archivo >> $INSTALL_LOG
		fi
	else
		echo "No se encontro el archivo "$TOPAZ_DEPLOY/$archivo
		echo "No se encontro el archivo "$TOPAZ_DEPLOY/$archivo >> $INSTALL_LOG
	fi
done
fi

echo " "
echo " " >> $INSTALL_LOG

# Copiar nuevos componentes (Archivos de configuracion XML)
echo "Copiar nuevos componentes (Archivos de configuracion XML - deploy) a la ruta "$TOPAZ_DEPLOY
echo "Copiar nuevos componentes (Archivos de configuracion XML - deploy) a la ruta "$TOPAZ_DEPLOY >> $INSTALL_LOG

for archivo in $(ls $TOPAZ_DEPLOY_NEW | grep ".\.xml$")
do
	$(mv $TOPAZ_DEPLOY_NEW/$archivo $TOPAZ_DEPLOY 2>> $ERROR_LOG)
	echo "Se copio el archivo "$TOPAZ_DEPLOY_NEW/$archivo
	echo "Se copio el archivo "$TOPAZ_DEPLOY_NEW/$archivo >> $INSTALL_LOG
done

echo " "
echo " " >> $INSTALL_LOG
# ABONILLA 09/06/16 Fin

# DRIOS 27/06/17 Ini
#Borrar Class Python para Canales
echo "Borrar archivos Class Python para Canales de la ruta "$TOPAZ_APP_PYTHON_POS
echo "Borrar archivos Class Python para Canales de la ruta "$TOPAZ_APP_PYTHON_POS >> $INSTALL_LOG

for archivo in $(ls $TOPAZ_APP_PYTHON_POS | grep ".\.class$")
do
	$(rm $TOPAZ_APP_PYTHON_POS/$archivo 2>> $ERROR_LOG)
	echo "Se borro el archivo class "$TOPAZ_APP_PYTHON_POS/$archivo
	echo "Se borro el archivo class "$TOPAZ_APP_PYTHON_POS/$archivo >> $INSTALL_LOG
done

echo " "
echo " " >> $INSTALL_LOG
# DRIOS 27/06/17 Fin

# DRIOS 27/06/17 Ini
# Respaldar componentes antiguos (Archivos PYTHON Canales Pos)
echo "Respaldar componentes antiguos (Archivos PYTHON Canales Pos)"
echo "Respaldar componentes antiguos (Archivos PYTHON Canales Pos)" >> $INSTALL_LOG

if [ -d $BACKUP_PATH/Componentes/12_PYTHON_CANALES/userlibrary/default/python/topsystems/pos ]; then
  echo "Se encontro respaldo componentes antiguos (Archivos PYTHON Canales Pos)"
  echo "Se encontro respaldo componentes antiguos (Archivos PYTHON Canales Pos)" >> $INSTALL_LOG
  echo "El directorio \""$BACKUP_PATH"/Componentes/12_PYTHON_CANALES/userlibrary/default/python/topsystems/pos\" ya existe"
  echo "El directorio \""$BACKUP_PATH"/Componentes/12_PYTHON_CANALES/userlibrary/default/python/topsystems/pos\" ya existe" >> $INSTALL_LOG
else
  mkdir -p $BACKUP_PATH/Componentes/12_PYTHON_CANALES/userlibrary/default/python/topsystems/pos
fi

ls $TOPAZ_APP_PYTHON_POS_NEW | grep ".\.py$" > $BACKUP_PATH/Componentes/12_PYTHON_CANALES/userlibrary/default/python/topsystems/pos/lista_news_app_pos_py.txt

for archivo in $(ls $TOPAZ_APP_PYTHON_POS_NEW | grep ".\.py$")
do
	if [ -e $TOPAZ_APP_PYTHON_POS/$archivo ];
	then
		$(mv $TOPAZ_APP_PYTHON_POS/$archivo $BACKUP_PATH/Componentes/12_PYTHON_CANALES/userlibrary/default/python/topsystems/pos 2>> $ERROR_LOG)
		if [ $? -eq 0 ]; then
			echo "Se respaldo y elimino el archivo "$TOPAZ_APP_PYTHON_POS/$archivo
			echo "Se respaldo y elimino el archivo "$TOPAZ_APP_PYTHON_POS/$archivo >> $INSTALL_LOG
		else
			echo "No se encontro el archivo "$TOPAZ_APP_PYTHON_POS/$archivo
			echo "No se encontro el archivo "$TOPAZ_APP_PYTHON_POS/$archivo >> $INSTALL_LOG
		fi
	else
		echo "No se encontro el archivo "$TOPAZ_APP_PYTHON_POS/$archivo
		echo "No se encontro el archivo "$TOPAZ_APP_PYTHON_POS/$archivo >> $INSTALL_LOG
	fi
done
#fi

echo " "
echo " " >> $INSTALL_LOG

# Copiar nuevos componentes (Archivos PYTHON Canales Pos)
echo "Copiar nuevos componentes (Archivos PYTHON Canales Pos) a la ruta "$TOPAZ_APP_PYTHON_POS
echo "Copiar nuevos componentes (Archivos PYTHON Canales Pos) a la ruta "$TOPAZ_APP_PYTHON_POS >> $INSTALL_LOG

for archivo in $(ls $TOPAZ_APP_PYTHON_POS_NEW | grep ".\.py$")
do
	$(mv $TOPAZ_APP_PYTHON_POS_NEW/$archivo $TOPAZ_APP_PYTHON_POS 2>> $ERROR_LOG)
	echo "Se copio el archivo "$TOPAZ_APP_PYTHON_POS_NEW/$archivo
	echo "Se copio el archivo "$TOPAZ_APP_PYTHON_POS_NEW/$archivo >> $INSTALL_LOG
done

echo " "
echo " " >> $INSTALL_LOG
# DRIOS 27/06/17 Fin

# DRIOS 15/06/15 Ini
#Borrar Class Python para Canales
echo "Borrar archivos Class Python para Canales de la ruta "$TOPAZ_APP_PYTHON
echo "Borrar archivos Class Python para Canales de la ruta "$TOPAZ_APP_PYTHON >> $INSTALL_LOG

for archivo in $(ls $TOPAZ_APP_PYTHON | grep ".\.class$")
do
	$(rm $TOPAZ_APP_PYTHON/$archivo 2>> $ERROR_LOG)
	echo "Se borro el archivo class "$TOPAZ_APP_PYTHON/$archivo
	echo "Se borro el archivo class "$TOPAZ_APP_PYTHON/$archivo >> $INSTALL_LOG
done

echo " "
echo " " >> $INSTALL_LOG
# DRIOS 15/06/15 Fin

# DRIOS 15/05/2015
# Respaldar componentes antiguos (Archivos PYTHON Canales)
echo "Respaldar componentes antiguos (Archivos PYTHON Canales)"
echo "Respaldar componentes antiguos (Archivos PYTHON Canales)" >> $INSTALL_LOG

if [ -d $BACKUP_PATH/Componentes/12_PYTHON_CANALES/userlibrary/default/python/topsystems/pos/core ]; then
echo "Se encontro respaldo componentes antiguos (Archivos PYTHON Canales)"
echo "Se encontro respaldo componentes antiguos (Archivos PYTHON Canales)" >> $INSTALL_LOG
echo "El directorio \""$BACKUP_PATH"/Componentes/12_PYTHON_CANALES/userlibrary/default/python/topsystems/pos/core\" ya existe"
echo "El directorio \""$BACKUP_PATH"/Componentes/12_PYTHON_CANALES/userlibrary/default/python/topsystems/pos/core\" ya existe" >> $INSTALL_LOG
else
mkdir -p $BACKUP_PATH/Componentes/12_PYTHON_CANALES/userlibrary/default/python/topsystems/pos/core

ls $TOPAZ_APP_PYTHON_NEW | grep ".\.py$" > $BACKUP_PATH/Componentes/12_PYTHON_CANALES/userlibrary/default/python/topsystems/pos/core/lista_news_app_py.txt

for archivo in $(ls $TOPAZ_APP_PYTHON_NEW | grep ".\.py$")
do
	if [ -e $TOPAZ_APP_PYTHON/$archivo ];
	then
		$(mv $TOPAZ_APP_PYTHON/$archivo $BACKUP_PATH/Componentes/12_PYTHON_CANALES/userlibrary/default/python/topsystems/pos/core 2>> $ERROR_LOG)
		if [ $? -eq 0 ]; then
			echo "Se respaldo y elimino el archivo "$TOPAZ_APP_PYTHON/$archivo
			echo "Se respaldo y elimino el archivo "$TOPAZ_APP_PYTHON/$archivo >> $INSTALL_LOG
		else
			echo "No se encontro el archivo "$TOPAZ_APP_PYTHON/$archivo
			echo "No se encontro el archivo "$TOPAZ_APP_PYTHON/$archivo >> $INSTALL_LOG
		fi
	else
		echo "No se encontro el archivo "$TOPAZ_APP_PYTHON/$archivo
		echo "No se encontro el archivo "$TOPAZ_APP_PYTHON/$archivo >> $INSTALL_LOG
	fi
done
fi

echo " "
echo " " >> $INSTALL_LOG

# Copiar nuevos componentes (Archivos PYTHON Canales)
echo "Copiar nuevos componentes (Archivos PYTHON Canales) a la ruta "$TOPAZ_APP_PYTHON
echo "Copiar nuevos componentes (Archivos PYTHON Canales) a la ruta "$TOPAZ_APP_PYTHON >> $INSTALL_LOG

for archivo in $(ls $TOPAZ_APP_PYTHON_NEW | grep ".\.py$")
do
	$(mv $TOPAZ_APP_PYTHON_NEW/$archivo $TOPAZ_APP_PYTHON 2>> $ERROR_LOG)
	echo "Se copio el archivo "$TOPAZ_APP_PYTHON_NEW/$archivo
	echo "Se copio el archivo "$TOPAZ_APP_PYTHON_NEW/$archivo >> $INSTALL_LOG
done

echo " "
echo " " >> $INSTALL_LOG

# DRIOS 28/06/17 Ini
#Borrar Class Python para Canales - Globokast
echo "Borrar archivos Class Python para Canales - Globokast de la ruta "$TOPAZ_APP_PYTHON_GLOBOKAST
echo "Borrar archivos Class Python para Canales - Globokast de la ruta "$TOPAZ_APP_PYTHON_GLOBOKAST >> $INSTALL_LOG

for archivo in $(ls $TOPAZ_APP_PYTHON_GLOBOKAST | grep ".\.class$")
do
	$(rm $TOPAZ_APP_PYTHON_GLOBOKAST/$archivo 2>> $ERROR_LOG)
	echo "Se borro el archivo class "$TOPAZ_APP_PYTHON_GLOBOKAST/$archivo
	echo "Se borro el archivo class "$TOPAZ_APP_PYTHON_GLOBOKAST/$archivo >> $INSTALL_LOG
done

echo " "
echo " " >> $INSTALL_LOG
# DRIOS 28/06/17 Fin

# DRIOS 28/06/17 Ini
# Respaldar componentes antiguos (Archivos PYTHON Canales - Globokast)
echo "Respaldar componentes antiguos (Archivos PYTHON Canales - Globokast)"
echo "Respaldar componentes antiguos (Archivos PYTHON Canales - Globokast)" >> $INSTALL_LOG

if [ -d $BACKUP_PATH/Componentes/12_PYTHON_CANALES/userlibrary/default/python/topsystems/pos/core/GLOBOKAST ]; then
echo "Se encontro respaldo componentes antiguos (Archivos PYTHON Canales - Globokast)"
echo "Se encontro respaldo componentes antiguos (Archivos PYTHON Canales - Globokast)" >> $INSTALL_LOG
echo "El directorio \""$BACKUP_PATH"/Componentes/12_PYTHON_CANALES/userlibrary/default/python/topsystems/pos/core/GLOBOKAST\" ya existe"
echo "El directorio \""$BACKUP_PATH"/Componentes/12_PYTHON_CANALES/userlibrary/default/python/topsystems/pos/core/GLOBOKAST\" ya existe" >> $INSTALL_LOG
else
mkdir -p $BACKUP_PATH/Componentes/12_PYTHON_CANALES/userlibrary/default/python/topsystems/pos/core/GLOBOKAST

ls $TOPAZ_APP_PYTHON_GLOBOKAST_NEW | grep ".\.py$" > $BACKUP_PATH/Componentes/12_PYTHON_CANALES/userlibrary/default/python/topsystems/pos/core/GLOBOKAST/lista_news_app_gk_py.txt

for archivo in $(ls $TOPAZ_APP_PYTHON_GLOBOKAST_NEW | grep ".\.py$")
do
	if [ -e $TOPAZ_APP_PYTHON_GLOBOKAST/$archivo ];
	then
		$(mv $TOPAZ_APP_PYTHON_GLOBOKAST/$archivo $BACKUP_PATH/Componentes/12_PYTHON_CANALES/userlibrary/default/python/topsystems/pos/core/GLOBOKAST 2>> $ERROR_LOG)
		if [ $? -eq 0 ]; then
			echo "Se respaldo y elimino el archivo "$TOPAZ_APP_PYTHON_GLOBOKAST/$archivo
			echo "Se respaldo y elimino el archivo "$TOPAZ_APP_PYTHON_GLOBOKAST/$archivo >> $INSTALL_LOG
		else
			echo "No se encontro el archivo "$TOPAZ_APP_PYTHON_GLOBOKAST/$archivo
			echo "No se encontro el archivo "$TOPAZ_APP_PYTHON_GLOBOKAST/$archivo >> $INSTALL_LOG
		fi
	else
		echo "No se encontro el archivo "$TOPAZ_APP_PYTHON_GLOBOKAST/$archivo
		echo "No se encontro el archivo "$TOPAZ_APP_PYTHON_GLOBOKAST/$archivo >> $INSTALL_LOG
	fi
done
fi

echo " "
echo " " >> $INSTALL_LOG

# Copiar nuevos componentes (Archivos PYTHON Canales - Globokast)
echo "Copiar nuevos componentes (Archivos PYTHON Canales - Globokast) a la ruta "$TOPAZ_APP_PYTHON_GLOBOKAST
echo "Copiar nuevos componentes (Archivos PYTHON Canales - Globokast) a la ruta "$TOPAZ_APP_PYTHON_GLOBOKAST >> $INSTALL_LOG

for archivo in $(ls $TOPAZ_APP_PYTHON_GLOBOKAST_NEW | grep ".\.py$")
do
	$(mv $TOPAZ_APP_PYTHON_GLOBOKAST_NEW/$archivo $TOPAZ_APP_PYTHON_GLOBOKAST 2>> $ERROR_LOG)
	echo "Se copio el archivo "$TOPAZ_APP_PYTHON_GLOBOKAST_NEW/$archivo
	echo "Se copio el archivo "$TOPAZ_APP_PYTHON_GLOBOKAST_NEW/$archivo >> $INSTALL_LOG
done

echo " "
echo " " >> $INSTALL_LOG
# DRIOS 28/06/17 Fin

# DRIOS 28/06/17 Ini
#Borrar Class Python para Canales - Unibanca
echo "Borrar archivos Class Python para Canales - Unibanca de la ruta "$TOPAZ_APP_PYTHON_UNIBANCA
echo "Borrar archivos Class Python para Canales - Unibanca de la ruta "$TOPAZ_APP_PYTHON_UNIBANCA >> $INSTALL_LOG

for archivo in $(ls $TOPAZ_APP_PYTHON_UNIBANCA | grep ".\.class$")
do
	$(rm $TOPAZ_APP_PYTHON_UNIBANCA/$archivo 2>> $ERROR_LOG)
	echo "Se borro el archivo class "$TOPAZ_APP_PYTHON_UNIBANCA/$archivo
	echo "Se borro el archivo class "$TOPAZ_APP_PYTHON_UNIBANCA/$archivo >> $INSTALL_LOG
done

echo " "
echo " " >> $INSTALL_LOG
# DRIOS 28/06/17 Fin

# DRIOS 28/06/17 Ini
# Respaldar componentes antiguos (Archivos PYTHON Canales - Unibanca)
echo "Respaldar componentes antiguos (Archivos PYTHON Canales - Unibanca)"
echo "Respaldar componentes antiguos (Archivos PYTHON Canales - Unibanca)" >> $INSTALL_LOG

if [ -d $BACKUP_PATH/Componentes/12_PYTHON_CANALES/userlibrary/default/python/topsystems/pos/core/UNIBANCA ]; then
echo "Se encontro respaldo componentes antiguos (Archivos PYTHON Canales - Unibanca)"
echo "Se encontro respaldo componentes antiguos (Archivos PYTHON Canales - Unibanca)" >> $INSTALL_LOG
echo "El directorio \""$BACKUP_PATH"/Componentes/12_PYTHON_CANALES/userlibrary/default/python/topsystems/pos/core/UNIBANCA\" ya existe"
echo "El directorio \""$BACKUP_PATH"/Componentes/12_PYTHON_CANALES/userlibrary/default/python/topsystems/pos/core/UNIBANCA\" ya existe" >> $INSTALL_LOG
else
mkdir -p $BACKUP_PATH/Componentes/12_PYTHON_CANALES/userlibrary/default/python/topsystems/pos/core/UNIBANCA

ls $TOPAZ_APP_PYTHON_UNIBANCA_NEW | grep ".\.py$" > $BACKUP_PATH/Componentes/12_PYTHON_CANALES/userlibrary/default/python/topsystems/pos/core/UNIBANCA/lista_news_app_uba_py.txt

for archivo in $(ls $TOPAZ_APP_PYTHON_UNIBANCA_NEW | grep ".\.py$")
do
	if [ -e $TOPAZ_APP_PYTHON_UNIBANCA/$archivo ];
	then
		$(mv $TOPAZ_APP_PYTHON_UNIBANCA/$archivo $BACKUP_PATH/Componentes/12_PYTHON_CANALES/userlibrary/default/python/topsystems/pos/core/UNIBANCA 2>> $ERROR_LOG)
		if [ $? -eq 0 ]; then
			echo "Se respaldo y elimino el archivo "$TOPAZ_APP_PYTHON_UNIBANCA/$archivo
			echo "Se respaldo y elimino el archivo "$TOPAZ_APP_PYTHON_UNIBANCA/$archivo >> $INSTALL_LOG
		else
			echo "No se encontro el archivo "$TOPAZ_APP_PYTHON_UNIBANCA/$archivo
			echo "No se encontro el archivo "$TOPAZ_APP_PYTHON_UNIBANCA/$archivo >> $INSTALL_LOG
		fi
	else
		echo "No se encontro el archivo "$TOPAZ_APP_PYTHON_UNIBANCA/$archivo
		echo "No se encontro el archivo "$TOPAZ_APP_PYTHON_UNIBANCA/$archivo >> $INSTALL_LOG
	fi
done
fi

echo " "
echo " " >> $INSTALL_LOG

# Copiar nuevos componentes (Archivos PYTHON Canales - Unibanca)
echo "Copiar nuevos componentes (Archivos PYTHON Canales - Unibanca) a la ruta "$TOPAZ_APP_PYTHON_UNIBANCA
echo "Copiar nuevos componentes (Archivos PYTHON Canales - Unibanca) a la ruta "$TOPAZ_APP_PYTHON_UNIBANCA >> $INSTALL_LOG

for archivo in $(ls $TOPAZ_APP_PYTHON_UNIBANCA_NEW | grep ".\.py$")
do
	$(mv $TOPAZ_APP_PYTHON_UNIBANCA_NEW/$archivo $TOPAZ_APP_PYTHON_UNIBANCA 2>> $ERROR_LOG)
	echo "Se copio el archivo "$TOPAZ_APP_PYTHON_UNIBANCA_NEW/$archivo
	echo "Se copio el archivo "$TOPAZ_APP_PYTHON_UNIBANCA_NEW/$archivo >> $INSTALL_LOG
done

echo " "
echo " " >> $INSTALL_LOG
# DRIOS 28/06/17 Fin

# DRIOS 28/06/17 Ini
#Borrar Class Python para Canales - Middleware
echo "Borrar archivos Class Python para Canales - Middleware de la ruta "$TOPAZ_APP_PYTHON_MDWARE
echo "Borrar archivos Class Python para Canales - Middleware de la ruta "$TOPAZ_APP_PYTHON_MDWARE >> $INSTALL_LOG

for archivo in $(ls $TOPAZ_APP_PYTHON_MDWARE | grep ".\.class$")
do
	$(rm $TOPAZ_APP_PYTHON_MDWARE/$archivo 2>> $ERROR_LOG)
	echo "Se borro el archivo class "$TOPAZ_APP_PYTHON_MDWARE/$archivo
	echo "Se borro el archivo class "$TOPAZ_APP_PYTHON_MDWARE/$archivo >> $INSTALL_LOG
done

echo " "
echo " " >> $INSTALL_LOG
# DRIOS 28/06/17 Fin

# DRIOS 28/06/17 Ini
# Respaldar componentes antiguos (Archivos PYTHON Canales - Middleware)
echo "Respaldar componentes antiguos (Archivos PYTHON Canales - Middleware)"
echo "Respaldar componentes antiguos (Archivos PYTHON Canales - Middleware)" >> $INSTALL_LOG

if [ -d $BACKUP_PATH/Componentes/12_PYTHON_CANALES/userlibrary/default/python/topsystems/pos/middleware ]; then
echo "Se encontro respaldo componentes antiguos (Archivos PYTHON Canales - Middleware)"
echo "Se encontro respaldo componentes antiguos (Archivos PYTHON Canales - Middleware)" >> $INSTALL_LOG
echo "El directorio \""$BACKUP_PATH"/Componentes/12_PYTHON_CANALES/userlibrary/default/python/topsystems/pos/middleware\" ya existe"
echo "El directorio \""$BACKUP_PATH"/Componentes/12_PYTHON_CANALES/userlibrary/default/python/topsystems/pos/middleware\" ya existe" >> $INSTALL_LOG
else
mkdir -p $BACKUP_PATH/Componentes/12_PYTHON_CANALES/userlibrary/default/python/topsystems/pos/middleware

ls $TOPAZ_APP_PYTHON_MDWARE_NEW | grep ".\.py$" > $BACKUP_PATH/Componentes/12_PYTHON_CANALES/userlibrary/default/python/topsystems/pos/middleware/lista_news_app_mdw_py.txt

for archivo in $(ls $TOPAZ_APP_PYTHON_MDWARE_NEW | grep ".\.py$")
do
	if [ -e $TOPAZ_APP_PYTHON_MDWARE/$archivo ];
	then
		$(mv $TOPAZ_APP_PYTHON_MDWARE/$archivo $BACKUP_PATH/Componentes/12_PYTHON_CANALES/userlibrary/default/python/topsystems/pos/middleware 2>> $ERROR_LOG)
		if [ $? -eq 0 ]; then
			echo "Se respaldo y elimino el archivo "$TOPAZ_APP_PYTHON_MDWARE/$archivo
			echo "Se respaldo y elimino el archivo "$TOPAZ_APP_PYTHON_MDWARE/$archivo >> $INSTALL_LOG
		else
			echo "No se encontro el archivo "$TOPAZ_APP_PYTHON_MDWARE/$archivo
			echo "No se encontro el archivo "$TOPAZ_APP_PYTHON_MDWARE/$archivo >> $INSTALL_LOG
		fi
	else
		echo "No se encontro el archivo "$TOPAZ_APP_PYTHON_MDWARE/$archivo
		echo "No se encontro el archivo "$TOPAZ_APP_PYTHON_MDWARE/$archivo >> $INSTALL_LOG
	fi
done
fi

echo " "
echo " " >> $INSTALL_LOG

# Copiar nuevos componentes (Archivos PYTHON Canales - Middleware)
echo "Copiar nuevos componentes (Archivos PYTHON Canales - Middleware) a la ruta "$TOPAZ_APP_PYTHON_MDWARE
echo "Copiar nuevos componentes (Archivos PYTHON Canales - Middleware) a la ruta "$TOPAZ_APP_PYTHON_MDWARE >> $INSTALL_LOG

for archivo in $(ls $TOPAZ_APP_PYTHON_MDWARE_NEW | grep ".\.py$")
do
	$(mv $TOPAZ_APP_PYTHON_MDWARE_NEW/$archivo $TOPAZ_APP_PYTHON_MDWARE 2>> $ERROR_LOG)
	echo "Se copio el archivo "$TOPAZ_APP_PYTHON_MDWARE_NEW/$archivo
	echo "Se copio el archivo "$TOPAZ_APP_PYTHON_MDWARE_NEW/$archivo >> $INSTALL_LOG
done

echo " "
echo " " >> $INSTALL_LOG
# DRIOS 28/06/17 Fin

echo "**************************************************************************************************"
echo "**************************************************************************************************" >> $INSTALL_LOG
echo "Instalacion de librerias Java de TOPAZ"
echo "Instalacion de librerias Java de TOPAZ" >> $INSTALL_LOG
echo " "
echo " " >> $INSTALL_LOG

# Respaldar componentes antiguos (Jars del Cliente TOPAZ)
echo "Respaldar componentes antiguos (Jars del Cliente TOPAZ)"
echo "Respaldar componentes antiguos (Jars del Cliente TOPAZ)" >> $INSTALL_LOG

if [ -d $BACKUP_PATH/Componentes/09_JARS/01-Client ];
then
echo "Se encontro respaldo componentes antiguos (Jars del Cliente TOPAZ)"
echo "Se encontro respaldo componentes antiguos (Jars del Cliente TOPAZ)" >> $INSTALL_LOG
echo "El directorio \""$BACKUP_PATH"/Componentes/09_JARS/01-Client\" ya existe"
echo "El directorio \""$BACKUP_PATH"/Componentes/09_JARS/01-Client\" ya existe" >> $INSTALL_LOG
else
mkdir -p $BACKUP_PATH/Componentes/09_JARS/01-Client

ls $TOPAZ_LIB_CLIENT_NEW > $BACKUP_PATH/Componentes/09_JARS/01-Client/lista_news_jars_client.txt

for archivo in $(ls $TOPAZ_LIB_CLIENT_NEW | grep ".\.jnlp$")
do
	$(mv $TOPAZ_LIB_CLIENT_PARENT/$archivo $BACKUP_PATH/Componentes/09_JARS/01-Client 2>> $ERROR_LOG)
	if [ $? -eq 0 ]; then
		echo "Se respaldo y elimino el archivo "$TOPAZ_LIB_CLIENT_PARENT/$archivo
		echo "Se respaldo y elimino el archivo "$TOPAZ_LIB_CLIENT_PARENT/$archivo >> $INSTALL_LOG
	else
		echo "El archivo "$TOPAZ_LIB_CLIENT_PARENT/$archivo", no se encontro"
		echo "El archivo "$TOPAZ_LIB_CLIENT_PARENT/$archivo", no se encontro" >> $INSTALL_LOG
	fi
done


# WCM I Cambios por Harvest - Si el archivo no existe, lo creo para que el Shell continue como si nada
if ! [ -f $TOPAZ_LIB_LIST_CLIENT ]; then
	touch $TOPAZ_LIB_LIST_CLIENT
fi
# WCM F

for archivo in $(tr -d "\r" < $TOPAZ_LIB_LIST_CLIENT | grep ".\.jar" 2>> $ERROR_LOG)
do
	$(mv $TOPAZ_LIB_CLIENT/$archivo $BACKUP_PATH/Componentes/09_JARS/01-Client 2>> $ERROR_LOG)
	if [ $? -eq 0 ]; then
		echo "Se respaldo y elimino el archivo "$TOPAZ_LIB_CLIENT/$archivo
		echo "Se respaldo y elimino el archivo "$TOPAZ_LIB_CLIENT/$archivo >> $INSTALL_LOG
	else
		echo "El archivo "$TOPAZ_LIB_CLIENT/$archivo", no se encontro"
		echo "El archivo "$TOPAZ_LIB_CLIENT/$archivo", no se encontro" >> $INSTALL_LOG
	fi
done
fi

echo " "
echo " " >> $INSTALL_LOG

# Copiar nuevos componentes (Jars del Cliente TOPAZ)
echo "Copiar nuevos componentes (Jars del Cliente TOPAZ) a la ruta "$TOPAZ_LIB_CLIENT
echo "Copiar nuevos componentes (Jars del Cliente TOPAZ) a la ruta "$TOPAZ_LIB_CLIENT >> $INSTALL_LOG

for archivo in $(ls $TOPAZ_LIB_CLIENT_NEW)
do
	if [[ $archivo == *.jnlp ]]; then
		$(mv $TOPAZ_LIB_CLIENT_NEW/$archivo $TOPAZ_LIB_CLIENT_PARENT 2>> $ERROR_LOG)

		#Busco si el IP actual esta en alguno de los 8 IPs de produccion, si estuviera cargo la lista completa
		#y sino estuviera cargo solo la IP del servidor
		$(grep -q $IPHSTNAME $TOPAZ_SHELL_DIR/$TOPAZ_IPS_PROD 2>> $ERROR_LOG)
		if [ $? -eq 0 ]; then
			echo "$(<$TOPAZ_SHELL_DIR/$TOPAZ_IPS_PROD)" >> $TOPAZ_LIB_CLIENT_PARENT/$archivo
		else
			echo "	<property name=\"java.naming.provider.url\" value=\""$IPHSTNAME":1300\"/>" >> $TOPAZ_LIB_CLIENT_PARENT/$archivo
		fi

		echo "$(<$TOPAZ_SHELL_DIR/$TOPAZ_NOM_SVR_JNLP)" >> $TOPAZ_LIB_CLIENT_PARENT/$archivo
		echo "	<property name=\"topaz.server.rmi.host\" value=\""$IPHSTNAME"\"/>" >> $TOPAZ_LIB_CLIENT_PARENT/$archivo
		echo "$(<$TOPAZ_SHELL_DIR/$TOPAZ_JNLP_2)" >> $TOPAZ_LIB_CLIENT_PARENT/$archivo

		echo "Se copio el archivo "$TOPAZ_LIB_CLIENT_NEW/$archivo" a la ruta "$TOPAZ_LIB_CLIENT_PARENT
		echo "Se copio el archivo "$TOPAZ_LIB_CLIENT_NEW/$archivo" a la ruta "$TOPAZ_LIB_CLIENT_PARENT >> $INSTALL_LOG
	elif [[ $archivo == *.jar ]]; then
		$(mv $TOPAZ_LIB_CLIENT_NEW/$archivo $TOPAZ_LIB_CLIENT 2>> $ERROR_LOG)
		echo "Se copio el archivo "$TOPAZ_LIB_CLIENT_NEW/$archivo
		echo "Se copio el archivo "$TOPAZ_LIB_CLIENT_NEW/$archivo >> $INSTALL_LOG
	fi
done

echo " "
echo " " >> $INSTALL_LOG

# Respaldar componentes antiguos (Jars TOPAZ personalizados para EDYFICAR)
echo "Respaldar componentes antiguos (Jars TOPAZ personalizados para EDYFICAR)"
echo "Respaldar componentes antiguos (Jars TOPAZ personalizados para EDYFICAR)" >> $INSTALL_LOG

if [ -d $BACKUP_PATH/Componentes/09_JARS/02-Custom ];
then
echo "Se encontro respaldo componentes antiguos (Jars TOPAZ personalizados para EDYFICAR)"
echo "Se encontro respaldo componentes antiguos (Jars TOPAZ personalizados para EDYFICAR)" >> $INSTALL_LOG
echo "El directorio \""$BACKUP_PATH"/Componentes/09_JARS/02-Custom\" ya existe"
echo "El directorio \""$BACKUP_PATH"/Componentes/09_JARS/02-Custom\" ya existe" >> $INSTALL_LOG
else
mkdir -p $BACKUP_PATH/Componentes/09_JARS/02-Custom

ls $TOPAZ_LIB_CUSTOM_NEW | grep ".\.jar$" > $BACKUP_PATH/Componentes/09_JARS/02-Custom/lista_news_jars_custom.txt

# WCM I Cambios por Harvest - Si el archivo no existe, lo creo para que el Shell continue como si nada
if ! [ -f $TOPAZ_LIB_LIST_CUSTOM ]; then
	touch $TOPAZ_LIB_LIST_CUSTOM
fi
# WCM F

for archivo in $(tr -d "\r" < $TOPAZ_LIB_LIST_CUSTOM | grep ".\.jar" 2>> $ERROR_LOG)
do
	$(mv $TOPAZ_LIB_CUSTOM/$archivo $BACKUP_PATH/Componentes/09_JARS/02-Custom 2>> $ERROR_LOG)
	if [ $? -eq 0 ]; then
		echo "Se respaldo y elimino el archivo "$TOPAZ_LIB_CUSTOM/$archivo
		echo "Se respaldo y elimino el archivo "$TOPAZ_LIB_CUSTOM/$archivo >> $INSTALL_LOG
	else
		echo "El archivo "$TOPAZ_LIB_CUSTOM/$archivo", no se encontro"
		echo "El archivo "$TOPAZ_LIB_CUSTOM/$archivo", no se encontro" >> $INSTALL_LOG
	fi
done
fi

echo " "
echo " " >> $INSTALL_LOG

# Copiar nuevos componentes (Jars TOPAZ personalizados para EDYFICAR)
echo "Copiar nuevos componentes (Jars TOPAZ personalizados para EDYFICAR) a la ruta "$TOPAZ_LIB_CUSTOM
echo "Copiar nuevos componentes (Jars TOPAZ personalizados para EDYFICAR) a la ruta "$TOPAZ_LIB_CUSTOM >> $INSTALL_LOG

for archivo in $(ls $TOPAZ_LIB_CUSTOM_NEW | grep ".\.jar$")
do
	$(mv $TOPAZ_LIB_CUSTOM_NEW/$archivo $TOPAZ_LIB_CUSTOM 2>> $ERROR_LOG)
	echo "Se copio el archivo "$TOPAZ_LIB_CUSTOM_NEW/$archivo
	echo "Se copio el archivo "$TOPAZ_LIB_CUSTOM_NEW/$archivo >> $INSTALL_LOG
done

echo " "
echo " " >> $INSTALL_LOG

# Respaldar componentes antiguos (Jars TOPAZ Core Server)
echo "Respaldar componentes antiguos (Jars TOPAZ Core Server)"
echo "Respaldar componentes antiguos (Jars TOPAZ Core Server)" >> $INSTALL_LOG

if [ -d $BACKUP_PATH/Componentes/09_JARS/03-Server ];
then
echo "Se encontro respaldo componentes antiguos (Jars TOPAZ Core Server)"
echo "Se encontro respaldo componentes antiguos (Jars TOPAZ Core Server)" >> $INSTALL_LOG
echo "El directorio \""$BACKUP_PATH"/Componentes/09_JARS/03-Server\" ya existe"
echo "El directorio \""$BACKUP_PATH"/Componentes/09_JARS/03-Server\" ya existe" >> $INSTALL_LOG
else
mkdir -p $BACKUP_PATH/Componentes/09_JARS/03-Server

ls $TOPAZ_LIB_SERVER_NEW | grep ".\.jar$" > $BACKUP_PATH/Componentes/09_JARS/03-Server/lista_news_jars_server.txt

# WCM I Cambios por Harvest - Si el archivo no existe, lo creo para que el Shell continue como si nada
if ! [ -f $TOPAZ_LIB_LIST_SERVER ]; then
	touch $TOPAZ_LIB_LIST_SERVER
fi
# WCM F

for archivo in $(tr -d "\r" < $TOPAZ_LIB_LIST_SERVER | grep ".\.jar" 2>> $ERROR_LOG)
do
	$(mv $TOPAZ_LIB_SERVER/$archivo $BACKUP_PATH/Componentes/09_JARS/03-Server 2>> $ERROR_LOG)
	if [ $? -eq 0 ]; then
		echo "Se respaldo y elimino el archivo "$TOPAZ_LIB_SERVER/$archivo
		echo "Se respaldo y elimino el archivo "$TOPAZ_LIB_SERVER/$archivo >> $INSTALL_LOG
	else
		echo "No se encontro el archivo "$TOPAZ_LIB_SERVER/$archivo
		echo "No se encontro el archivo "$TOPAZ_LIB_SERVER/$archivo >> $INSTALL_LOG
	fi
done
fi

echo " "
echo " " >> $INSTALL_LOG

# Copiar nuevos componentes (Jars TOPAZ Core Server)
echo "Copiar nuevos componentes (Jars TOPAZ Core Server) a la ruta "$TOPAZ_LIB_SERVER
echo "Copiar nuevos componentes (Jars TOPAZ Core Server) a la ruta "$TOPAZ_LIB_SERVER >> $INSTALL_LOG

for archivo in $(ls $TOPAZ_LIB_SERVER_NEW | grep ".\.jar$")
do
	$(mv $TOPAZ_LIB_SERVER_NEW/$archivo $TOPAZ_LIB_SERVER 2>> $ERROR_LOG)
	echo "Se copio el archivo "$TOPAZ_LIB_SERVER_NEW/$archivo
	echo "Se copio el archivo "$TOPAZ_LIB_SERVER_NEW/$archivo >> $INSTALL_LOG
done

echo " "
echo " " >> $INSTALL_LOG

# DRIOS 28/06/2017 INI
# Respaldar componentes antiguos (Xmls TOPAZ Core Server)
echo "Respaldar componentes antiguos (Xmls TOPAZ Core Server)"
echo "Respaldar componentes antiguos (Xmls TOPAZ Core Server)" >> $INSTALL_LOG

#Ya se hace esto para los "Jars TOPAZ Core Server"
#if [ -d $BACKUP_PATH/Componentes/09_JARS/03-Server ];
#then
#  echo "Se encontro respaldo componentes antiguos (Xmls TOPAZ Core Server)"
#  echo "Se encontro respaldo componentes antiguos (Xmls TOPAZ Core Server)" >> $INSTALL_LOG
#  echo "El directorio \""$BACKUP_PATH"/Componentes/09_JARS/03-Server\" ya existe"
#  echo "El directorio \""$BACKUP_PATH"/Componentes/09_JARS/03-Server\" ya existe" >> $INSTALL_LOG
#else
#  mkdir -p $BACKUP_PATH/Componentes/09_JARS/03-Server
#fi

ls $TOPAZ_LIB_SERVER_NEW | grep ".\.xml$" > $BACKUP_PATH/Componentes/09_JARS/03-Server/lista_news_xml_server.txt

for archivo in $(tr -d "\r" < $TOPAZ_LIB_LIST_SERVER | grep ".\.xml" 2>> $ERROR_LOG)
do
	$(mv $TOPAZ_LIB_SERVER/$archivo $BACKUP_PATH/Componentes/09_JARS/03-Server 2>> $ERROR_LOG)
	if [ $? -eq 0 ]; then
		echo "Se respaldo y elimino el archivo "$TOPAZ_LIB_SERVER/$archivo
		echo "Se respaldo y elimino el archivo "$TOPAZ_LIB_SERVER/$archivo >> $INSTALL_LOG
	else
		echo "No se encontro el archivo "$TOPAZ_LIB_SERVER/$archivo
		echo "No se encontro el archivo "$TOPAZ_LIB_SERVER/$archivo >> $INSTALL_LOG
	fi
done
#fi

echo " "
echo " " >> $INSTALL_LOG

# Copiar nuevos componentes (Xmls TOPAZ Core Server)
echo "Copiar nuevos componentes (Xmls TOPAZ Core Server) a la ruta "$TOPAZ_LIB_SERVER
echo "Copiar nuevos componentes (Xmls TOPAZ Core Server) a la ruta "$TOPAZ_LIB_SERVER >> $INSTALL_LOG

for archivo in $(ls $TOPAZ_LIB_SERVER_NEW | grep ".\.xml$")
do
	$(mv $TOPAZ_LIB_SERVER_NEW/$archivo $TOPAZ_LIB_SERVER 2>> $ERROR_LOG)
	echo "Se copio el archivo "$TOPAZ_LIB_SERVER_NEW/$archivo
	echo "Se copio el archivo "$TOPAZ_LIB_SERVER_NEW/$archivo >> $INSTALL_LOG
done

echo " "
echo " " >> $INSTALL_LOG
# DRIOS 28/06/2017 FIN

# DRIOS 02 ini
# Respaldar componentes antiguos (Imagenes de Reporte Jasper)
echo "Respaldar componentes antiguos (Imagenes de Reporte Jasper)"
echo "Respaldar componentes antiguos (Imagenes de Reporte Jasper)" >> $INSTALL_LOG

if [ -d $BACKUP_PATH/Componentes/10_IMAGES ];
then
echo "Se encontro respaldo componentes antiguos (Imagenes de Reporte Jasper)"
echo "Se encontro respaldo componentes antiguos (Imagenes de Reporte Jasper)" >> $INSTALL_LOG
echo "El directorio \""$BACKUP_PATH"/Componentes/10_IMAGES\" ya existe"
echo "El directorio \""$BACKUP_PATH"/Componentes/10_IMAGES\" ya existe" >> $INSTALL_LOG
else
mkdir -p $BACKUP_PATH/Componentes/10_IMAGES

ls $TOPAZ_IMAGE_SERVER_NEW | grep ".\.png$" > $BACKUP_PATH/Componentes/10_IMAGES/lista_news_png_images.txt
ls $TOPAZ_IMAGE_SERVER_NEW | grep ".\.jpg$" > $BACKUP_PATH/Componentes/10_IMAGES/lista_news_jpg_images.txt

# WCM I Cambios por Harvest - Si el archivo no existe, lo creo para que el Shell continue como si nada
if ! [ -f $TOPAZ_IMAGES_LIST_SERVER ]; then
	touch $TOPAZ_IMAGES_LIST_SERVER
fi
# WCM F

for archivo in $(tr -d "\r" < $TOPAZ_IMAGES_LIST_SERVER | grep ".\.png" 2>> $ERROR_LOG)
do
	$(mv $TOPAZ_IMAGE_SERVER/$archivo $BACKUP_PATH/Componentes/10_IMAGES 2>> $ERROR_LOG)
	if [ $? -eq 0 ]; then
		echo "Se respaldo y elimino el archivo "$TOPAZ_IMAGE_SERVER/$archivo
		echo "Se respaldo y elimino el archivo "$TOPAZ_IMAGE_SERVER/$archivo >> $INSTALL_LOG
	else
		echo "El archivo "$TOPAZ_IMAGE_SERVER/$archivo", no se encontro"
		echo "El archivo "$TOPAZ_IMAGE_SERVER/$archivo", no se encontro" >> $INSTALL_LOG
	fi
done

for archivo in $(tr -d "\r" < $TOPAZ_IMAGES_LIST_SERVER | grep ".\.jpg" 2>> $ERROR_LOG)
do
	$(mv $TOPAZ_IMAGE_SERVER/$archivo $BACKUP_PATH/Componentes/10_IMAGES 2>> $ERROR_LOG)
	if [ $? -eq 0 ]; then
		echo "Se respaldo y elimino el archivo "$TOPAZ_IMAGE_SERVER/$archivo
		echo "Se respaldo y elimino el archivo "$TOPAZ_IMAGE_SERVER/$archivo >> $INSTALL_LOG
	else
		echo "El archivo "$TOPAZ_IMAGE_SERVER/$archivo", no se encontro"
		echo "El archivo "$TOPAZ_IMAGE_SERVER/$archivo", no se encontro" >> $INSTALL_LOG
	fi
done
fi

echo " "
echo " " >> $INSTALL_LOG

# Copiar nuevos componentes (Imagenes de Reporte Jasper)
echo "Copiar nuevos componentes (Imagenes de Reporte Jasper) a la ruta "$TOPAZ_IMAGE_SERVER
echo "Copiar nuevos componentes (Imagenes de Reporte Jasper) a la ruta "$TOPAZ_IMAGE_SERVER >> $INSTALL_LOG

for archivo in $(ls $TOPAZ_IMAGE_SERVER_NEW | grep ".\.png$")
do
	$(mv $TOPAZ_IMAGE_SERVER_NEW/$archivo $TOPAZ_IMAGE_SERVER 2>> $ERROR_LOG)
	echo "Se copio el archivo "$TOPAZ_IMAGE_SERVER_NEW/$archivo
	echo "Se copio el archivo "$TOPAZ_IMAGE_SERVER_NEW/$archivo >> $INSTALL_LOG
done

for archivo in $(ls $TOPAZ_IMAGE_SERVER_NEW | grep ".\.jpg$")
do
	$(mv $TOPAZ_IMAGE_SERVER_NEW/$archivo $TOPAZ_IMAGE_SERVER 2>> $ERROR_LOG)
	echo "Se copio el archivo "$TOPAZ_IMAGE_SERVER_NEW/$archivo
	echo "Se copio el archivo "$TOPAZ_IMAGE_SERVER_NEW/$archivo >> $INSTALL_LOG
done
# DRIOS 02 fin

echo " "
echo " " >> $INSTALL_LOG

# DRIOS 03 ini
# Respaldar componentes antiguos (Jars Lib del Cliente TOPAZ)
echo "Respaldar componentes antiguos (Jars Lib del Cliente TOPAZ)"
echo "Respaldar componentes antiguos (Jars Lib del Cliente TOPAZ)" >> $INSTALL_LOG

if [ -d $BACKUP_PATH/Componentes/09_JARS/04-Lib ];
then
echo "Se encontro respaldo componentes antiguos (Jars Lib del Cliente TOPAZ)"
echo "Se encontro respaldo componentes antiguos (Jars Lib del Cliente TOPAZ)" >> $INSTALL_LOG
echo "El directorio \""$BACKUP_PATH"/Componentes/09_JARS/04-Lib\" ya existe"
echo "El directorio \""$BACKUP_PATH"/Componentes/09_JARS/04-Lib\" ya existe" >> $INSTALL_LOG
else
mkdir -p $BACKUP_PATH/Componentes/09_JARS/04-Lib

ls $LIB_CLIENT_NEW | grep ".\.jar$" > $BACKUP_PATH/Componentes/09_JARS/04-Lib/lista_news_jars_lib.txt

for archivo in $(ls $LIB_CLIENT_NEW | grep ".\.jar$")
do
	$(mv $LIB_CLIENT/$archivo $BACKUP_PATH/Componentes/09_JARS/04-Lib 2>> $ERROR_LOG)
	if [ $? -eq 0 ]; then
		echo "Se respaldo y elimino el archivo "$LIB_CLIENT/$archivo
		echo "Se respaldo y elimino el archivo "$LIB_CLIENT/$archivo >> $INSTALL_LOG
	else
		echo "El archivo "$LIB_CLIENT/$archivo", no se encontro"
		echo "El archivo "$LIB_CLIENT/$archivo", no se encontro" >> $INSTALL_LOG
	fi
done
fi

echo " "
echo " " >> $INSTALL_LOG

# Copiar nuevos componentes (Jars Lib del Cliente TOPAZ)
echo "Copiar nuevos componentes (Jars Lib del Cliente TOPAZ) a la ruta "$LIB_CLIENT
echo "Copiar nuevos componentes (Jars Lib del Cliente TOPAZ) a la ruta "$LIB_CLIENT >> $INSTALL_LOG

for archivo in $(ls $LIB_CLIENT_NEW | grep ".\.jar$")
do
	$(mv $LIB_CLIENT_NEW/$archivo $LIB_CLIENT 2>> $ERROR_LOG)
	echo "Se copio el archivo "$LIB_CLIENT_NEW/$archivo
	echo "Se copio el archivo "$LIB_CLIENT_NEW/$archivo >> $INSTALL_LOG
done

echo " "
echo " " >> $INSTALL_LOG
# DRIOS 03 fin

# JDELRIO 04 ini
# Respaldar componentes antiguos (Jars Lib del Servidor TOPAZ)
echo "Respaldar componentes antiguos (Jars Lib del Servidor TOPAZ)"
echo "Respaldar componentes antiguos (Jars Lib del Servidor TOPAZ)" >> $INSTALL_LOG

if [ -d $BACKUP_PATH/Componentes/09_JARS/05-LibServer ];
then
echo "Se encontro respaldo componentes antiguos (Jars Lib del Servidor TOPAZ)"
echo "Se encontro respaldo componentes antiguos (Jars Lib del Servidor TOPAZ)" >> $INSTALL_LOG
echo "El directorio \""$BACKUP_PATH"/Componentes/09_JARS/05-LibServer\" ya existe"
echo "El directorio \""$BACKUP_PATH"/Componentes/09_JARS/05-LibServer\" ya existe" >> $INSTALL_LOG
else
mkdir -p $BACKUP_PATH/Componentes/09_JARS/05-LibServer

ls $LIB_SERVER_NEW | grep ".\.jar$" > $BACKUP_PATH/Componentes/09_JARS/05-LibServer/lista_news_jars_lib_server.txt

for archivo in $(ls $LIB_SERVER_NEW | grep ".\.jar$")
do
	$(mv $LIB_SERVER/$archivo $BACKUP_PATH/Componentes/09_JARS/05-LibServer 2>> $ERROR_LOG)
	if [ $? -eq 0 ]; then
		echo "Se respaldo y elimino el archivo "$LIB_SERVER/$archivo
		echo "Se respaldo y elimino el archivo "$LIB_SERVER/$archivo >> $INSTALL_LOG
	else
		echo "El archivo "$LIB_SERVER/$archivo", no se encontro"
		echo "El archivo "$LIB_SERVER/$archivo", no se encontro" >> $INSTALL_LOG
	fi
done
fi

echo " "
echo " " >> $INSTALL_LOG

# Copiar nuevos componentes (Jars Lib del Servidor TOPAZ)
echo "Copiar nuevos componentes (Jars Lib del Servidor TOPAZ) a la ruta "$LIB_SERVER
echo "Copiar nuevos componentes (Jars Lib del Servidor TOPAZ) a la ruta "$LIB_SERVER >> $INSTALL_LOG

for archivo in $(ls $LIB_SERVER_NEW | grep ".\.jar$")
do
	$(mv $LIB_SERVER_NEW/$archivo $LIB_SERVER 2>> $ERROR_LOG)
	echo "Se copio el archivo "$LIB_SERVER_NEW/$archivo
	echo "Se copio el archivo "$LIB_SERVER_NEW/$archivo >> $INSTALL_LOG
done

echo " "
echo " " >> $INSTALL_LOG
# JDELRIO 04 fin


# DRIOS 04 ini
# Respaldar componentes antiguos (Archivos KETTLE)
echo "Respaldar componentes antiguos (Archivos KETTLE)"
echo "Respaldar componentes antiguos (Archivos KETTLE)" >> $INSTALL_LOG

if [ -d $BACKUP_PATH/Componentes/11_KETTLES/userlibrary/default/tools/kettle/packages ];
then
echo "Se encontro respaldo componentes antiguos (Archivos KETTLE)"
echo "Se encontro respaldo componentes antiguos (Archivos KETTLE)" >> $INSTALL_LOG
echo "El directorio \""$BACKUP_PATH"/Componentes/11_KETTLES/userlibrary/default/tools/kettle/packages\" ya existe"
echo "El directorio \""$BACKUP_PATH"/Componentes/11_KETTLES/userlibrary/default/tools/kettle/packages\" ya existe" >> $INSTALL_LOG
else
mkdir -p $BACKUP_PATH/Componentes/11_KETTLES/userlibrary/default/tools/kettle/packages

ls $TOPAZ_APP_KETL_NEW > $BACKUP_PATH/Componentes/11_KETTLES/userlibrary/default/tools/kettle/packages/lista_news_app_kettle.txt

#WCM I Reemplaza variable de separador que era espacio en blanco por otro valor para soportar archivos con espacios en blanco en su nombre
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
for archivo in $(ls $TOPAZ_APP_KETL_NEW)
do
	if [ -e $TOPAZ_APP_KETL/$archivo ];
	then
		$(mv $TOPAZ_APP_KETL/$archivo $BACKUP_PATH/Componentes/11_KETTLES/userlibrary/default/tools/kettle/packages 2>> $ERROR_LOG)
		if [ $? -eq 0 ]; then
			echo "Se respaldo y elimino el archivo "$TOPAZ_APP_KETL/$archivo
			echo "Se respaldo y elimino el archivo "$TOPAZ_APP_KETL/$archivo >> $INSTALL_LOG
		else
			echo "No se encontro el archivo "$TOPAZ_APP_KETL/$archivo
			echo "No se encontro el archivo "$TOPAZ_APP_KETL/$archivo >> $INSTALL_LOG
		fi
	else
		echo "No se encontro el archivo "$TOPAZ_APP_KETL/$archivo
		echo "No se encontro el archivo "$TOPAZ_APP_KETL/$archivo >> $INSTALL_LOG
	fi
done
IFS=$SAVEIFS
#WCM F
fi

echo " "
echo " " >> $INSTALL_LOG

# Copiar nuevos componentes (Archivos KETTLE)
echo "Copiar nuevos componentes (Archivos KETTLE) a la ruta "$TOPAZ_APP_KETL
echo "Copiar nuevos componentes (Archivos KETTLE) a la ruta "$TOPAZ_APP_KETL >> $INSTALL_LOG

#WCM I Reemplaza variable de separador que era espacio en blanco por otro valor para soportar archivos con espacios en blanco en su nombre
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
for archivo in $(ls $TOPAZ_APP_KETL_NEW)
do
	$(mv $TOPAZ_APP_KETL_NEW/$archivo $TOPAZ_APP_KETL 2>> $ERROR_LOG)
	echo "Se copio el archivo "$TOPAZ_APP_KETL_NEW/$archivo
	echo "Se copio el archivo "$TOPAZ_APP_KETL_NEW/$archivo >> $INSTALL_LOG
done
IFS=$SAVEIFS
#WCM F

echo " "
echo " " >> $INSTALL_LOG
# DRIOS 04 fin

# VCA KettlePlugin Ini
# Respaldar componentes antiguos (Archivos KETTLE plugins)
echo "Respaldar componentes antiguos (Archivos KETTLE plugins)"
echo "Respaldar componentes antiguos (Archivos KETTLE plugins)" >> $INSTALL_LOG

if [ -d $BACKUP_PATH/Componentes/11_KETTLES/userlibrary/default/tools/kettle/plugins ];
then
echo "Se encontro respaldo componentes antiguos (Archivos KETTLE plugins)"
echo "Se encontro respaldo componentes antiguos (Archivos KETTLE plugins)" >> $INSTALL_LOG
echo "El directorio \""$BACKUP_PATH"/Componentes/11_KETTLES/userlibrary/default/tools/kettle/plugins\" ya existe"
echo "El directorio \""$BACKUP_PATH"/Componentes/11_KETTLES/userlibrary/default/tools/kettle/plugins\" ya existe" >> $INSTALL_LOG
else
mkdir -p $BACKUP_PATH/Componentes/11_KETTLES/userlibrary/default/tools/kettle/plugins

ls $TOPAZ_APP_KETL_PLUG_NEW > $BACKUP_PATH/Componentes/11_KETTLES/userlibrary/default/tools/kettle/plugins/lista_news_app_plugins.txt

#Reemplaza variable de separador que era espacio en blanco por otro valor para soportar archivos con espacios en blanco en su nombre
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
for archivo in $(ls $TOPAZ_APP_KETL_PLUG_NEW)
do
	if [ -e $TOPAZ_APP_KETL_PLUG/$archivo ];
	then
		$(mv $TOPAZ_APP_KETL_PLUG/$archivo $BACKUP_PATH/Componentes/11_KETTLES/userlibrary/default/tools/kettle/plugins 2>> $ERROR_LOG)
		if [ $? -eq 0 ]; then
			echo "Se respaldo y elimino el archivo "$TOPAZ_APP_KETL_PLUG/$archivo
			echo "Se respaldo y elimino el archivo "$TOPAZ_APP_KETL_PLUG/$archivo >> $INSTALL_LOG
		else
			echo "No se encontro el archivo "$TOPAZ_APP_KETL_PLUG/$archivo
			echo "No se encontro el archivo "$TOPAZ_APP_KETL_PLUG/$archivo >> $INSTALL_LOG
		fi
	else
		echo "No se encontro el archivo "$TOPAZ_APP_KETL_PLUG/$archivo
		echo "No se encontro el archivo "$TOPAZ_APP_KETL_PLUG/$archivo >> $INSTALL_LOG
	fi
done
IFS=$SAVEIFS

fi

echo " "
echo " " >> $INSTALL_LOG

# Copiar nuevos componentes (Archivos KETTLE plugins)
echo "Copiar nuevos componentes (Archivos KETTLE plugins) a la ruta "$TOPAZ_APP_KETL_PLUG
echo "Copiar nuevos componentes (Archivos KETTLE plugins) a la ruta "$TOPAZ_APP_KETL_PLUG >> $INSTALL_LOG

#Reemplaza variable de separador que era espacio en blanco por otro valor para soportar archivos con espacios en blanco en su nombre
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
for archivo in $(ls $TOPAZ_APP_KETL_PLUG_NEW)
do
	$(mv $TOPAZ_APP_KETL_PLUG_NEW/$archivo $TOPAZ_APP_KETL_PLUG 2>> $ERROR_LOG)
	echo "Se copio el archivo "$TOPAZ_APP_KETL_PLUG_NEW/$archivo
	echo "Se copio el archivo "$TOPAZ_APP_KETL_PLUG_NEW/$archivo >> $INSTALL_LOG
done
IFS=$SAVEIFS

echo " "
echo " " >> $INSTALL_LOG
# VCA KettlePlugin fin

# ALDOM KettleJasper ini
# Respaldar componentes antiguos (Kettle jasper)
echo "Respaldar componentes antiguos (Kettle jasper)"
echo "Respaldar componentes antiguos (Kettle jasper)" >> $INSTALL_LOG

if [ -d $BACKUP_PATH/Componentes/08_KETTLE_JASPER ];
then
echo "Se encontro respaldo componentes antiguos (Kettle jasper)"
echo "Se encontro respaldo componentes antiguos (Kettle jasper)" >> $INSTALL_LOG
echo "El directorio \""$BACKUP_PATH"/Componentes/08_KETTLE_JASPER\" ya existe"
echo "El directorio \""$BACKUP_PATH"/Componentes/08_KETTLE_JASPER\" ya existe" >> $INSTALL_LOG
else
mkdir -p $BACKUP_PATH/Componentes/08_KETTLE_JASPER

ls $KETTLE_JASPER_NEW | grep ".\.jasper$" > $BACKUP_PATH/Componentes/08_KETTLE_JASPER/lista_news_kettle_jasper.txt

#Reemplaza variable de separador que era espacio en blanco por otro valor para soportar archivos con espacios en blanco en su nombre
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
for archivo in $(ls $KETTLE_JASPER_NEW | grep ".\.jasper$")
do
	if [ -e "$KETTLE_JASPER/$archivo" ];
	then
		$(mv "$KETTLE_JASPER/$archivo" $BACKUP_PATH/Componentes/08_KETTLE_JASPER 2>> $ERROR_LOG)
		if [ $? -eq 0 ]; then
			echo "Se respaldo y elimino el archivo "$KETTLE_JASPER/$archivo
			echo "Se respaldo y elimino el archivo "$KETTLE_JASPER/$archivo >> $INSTALL_LOG
		else
			echo "No se encontro el archivo "$KETTLE_JASPER/$archivo
			echo "No se encontro el archivo "$KETTLE_JASPER/$archivo >> $INSTALL_LOG
		fi
	else
		echo "No se encontro el archivo "$KETTLE_JASPER/$archivo
		echo "No se encontro el archivo "$KETTLE_JASPER/$archivo >> $INSTALL_LOG
	fi
done
IFS=$SAVEIFS

ls $KETTLE_JASPER_NEW | grep ".\.jrxml$" > $BACKUP_PATH/Componentes/08_KETTLE_JASPER/lista_news_kettle_jrxml.txt

#Reemplaza variable de separador que era espacio en blanco por otro valor para soportar archivos con espacios en blanco en su nombre
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
for archivo in $(ls $KETTLE_JASPER_NEW | grep ".\.jrxml$")
do
	if [ -e "$KETTLE_JASPER/$archivo" ];
	then
		$(mv "$KETTLE_JASPER/$archivo" $BACKUP_PATH/Componentes/08_KETTLE_JASPER 2>> $ERROR_LOG)
		if [ $? -eq 0 ]; then
			echo "Se respaldo y elimino el archivo "$KETTLE_JASPER/$archivo
			echo "Se respaldo y elimino el archivo "$KETTLE_JASPER/$archivo >> $INSTALL_LOG
		else
			echo "No se encontro el archivo "$KETTLE_JASPER/$archivo
			echo "No se encontro el archivo "$KETTLE_JASPER/$archivo >> $INSTALL_LOG
		fi
	else
		echo "No se encontro el archivo "$KETTLE_JASPER/$archivo
		echo "No se encontro el archivo "$KETTLE_JASPER/$archivo >> $INSTALL_LOG
	fi
done
IFS=$SAVEIFS

ls $KETTLE_JASPER_NEW | grep ".\.gif$" > $BACKUP_PATH/Componentes/08_KETTLE_JASPER/lista_news_kettle_gif.txt

#Reemplaza variable de separador que era espacio en blanco por otro valor para soportar archivos con espacios en blanco en su nombre
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
for archivo in $(ls $KETTLE_JASPER_NEW | grep ".\.gif$")
do
	if [ -e "$KETTLE_JASPER/$archivo" ];
	then
		$(mv "$KETTLE_JASPER/$archivo" $BACKUP_PATH/Componentes/08_KETTLE_JASPER 2>> $ERROR_LOG)
		if [ $? -eq 0 ]; then
			echo "Se respaldo y elimino el archivo "$KETTLE_JASPER/$archivo
			echo "Se respaldo y elimino el archivo "$KETTLE_JASPER/$archivo >> $INSTALL_LOG
		else
			echo "No se encontro el archivo "$KETTLE_JASPER/$archivo
			echo "No se encontro el archivo "$KETTLE_JASPER/$archivo >> $INSTALL_LOG
		fi
	else
		echo "No se encontro el archivo "$KETTLE_JASPER/$archivo
		echo "No se encontro el archivo "$KETTLE_JASPER/$archivo >> $INSTALL_LOG
	fi
done
IFS=$SAVEIFS

fi

echo " "
echo " " >> $INSTALL_LOG

# Copiar nuevos componentes (Kettle jasper)
echo "Copiar nuevos componentes (Kettle jasper) a la ruta "$KETTLE_JASPER
echo "Copiar nuevos componentes (Kettle jasper) a la ruta "$KETTLE_JASPER >> $INSTALL_LOG

#Reemplaza variable de separador que era espacio en blanco por otro valor para soportar archivos con espacios en blanco en su nombre
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
for archivo in $(ls $KETTLE_JASPER_NEW | grep ".\.jasper$")
do
	$(mv "$KETTLE_JASPER_NEW/$archivo" $KETTLE_JASPER 2>> $ERROR_LOG)
	echo "Se copio el archivo "$KETTLE_JASPER_NEW/$archivo
	echo "Se copio el archivo "$KETTLE_JASPER_NEW/$archivo >> $INSTALL_LOG
done

for archivo in $(ls $KETTLE_JASPER_NEW | grep ".\.jrxml$")
do
	$(mv "$KETTLE_JASPER_NEW/$archivo" $KETTLE_JASPER 2>> $ERROR_LOG)
	echo "Se copio el archivo "$KETTLE_JASPER_NEW/$archivo
	echo "Se copio el archivo "$KETTLE_JASPER_NEW/$archivo >> $INSTALL_LOG
done

for archivo in $(ls $KETTLE_JASPER_NEW | grep ".\.gif$")
do
	$(mv "$KETTLE_JASPER_NEW/$archivo" $KETTLE_JASPER 2>> $ERROR_LOG)
	echo "Se copio el archivo "$KETTLE_JASPER_NEW/$archivo
	echo "Se copio el archivo "$KETTLE_JASPER_NEW/$archivo >> $INSTALL_LOG
done
IFS=$SAVEIFS

echo " "
echo " " >> $INSTALL_LOG
# ALDOM KettleJasper fin


# JZUNIGA jboss-service ini
# Respaldar componentes antiguos (jboss-service)
echo "Respaldar componentes antiguos (jboss-service)"
echo "Respaldar componentes antiguos (jboss-service)" >> $INSTALL_LOG

if [ -d $BACKUP_PATH/Componentes/13_TOPAZ_EAR_SERVICE/server_sar/META-INF ];
then
echo "Se encontro respaldo componentes antiguos (jboss-service)"
echo "Se encontro respaldo componentes antiguos (jboss-service)" >> $INSTALL_LOG
echo "El directorio \""$BACKUP_PATH"/Componentes/13_TOPAZ_EAR_SERVICE/server_sar/META-INF\" ya existe"
echo "El directorio \""$BACKUP_PATH"/Componentes/13_TOPAZ_EAR_SERVICE/server_sar/META-INF\" ya existe" >> $INSTALL_LOG
else
mkdir -p $BACKUP_PATH/Componentes/13_TOPAZ_EAR_SERVICE/server_sar/META-INF

ls $JBOSS_SERVICE_NEW > $BACKUP_PATH/Componentes/13_TOPAZ_EAR_SERVICE/server_sar/META-INF/lista_news_jboss-service.txt

#Reemplaza variable de separador que era espacio en blanco por otro valor para soportar archivos con espacios en blanco en su nombre
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
for archivo in $(ls $JBOSS_SERVICE_NEW)
do
	if [ -e "$JBOSS_SERVICE/$archivo" ];
	then
		$(mv "$JBOSS_SERVICE/$archivo" $BACKUP_PATH/Componentes/13_TOPAZ_EAR_SERVICE/server_sar/META-INF 2>> $ERROR_LOG)
		if [ $? -eq 0 ]; then
			echo "Se respaldo y elimino el archivo "$JBOSS_SERVICE/$archivo
			echo "Se respaldo y elimino el archivo "$JBOSS_SERVICE/$archivo >> $INSTALL_LOG
		else
			echo "No se encontro el archivo "$JBOSS_SERVICE/$archivo
			echo "No se encontro el archivo "$JBOSS_SERVICE/$archivo >> $INSTALL_LOG
		fi
	else
		echo "No se encontro el archivo "$JBOSS_SERVICE/$archivo
		echo "No se encontro el archivo "$JBOSS_SERVICE/$archivo >> $INSTALL_LOG
	fi
done
IFS=$SAVEIFS

fi

echo " "
echo " " >> $INSTALL_LOG

# Copiar nuevos componentes (jboss-service)
echo "Copiar nuevos componentes (jboss-service) a la ruta "$JBOSS_SERVICE
echo "Copiar nuevos componentes (jboss-service) a la ruta "$JBOSS_SERVICE >> $INSTALL_LOG

#Reemplaza variable de separador que era espacio en blanco por otro valor para soportar archivos con espacios en blanco en su nombre
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
for archivo in $(ls $JBOSS_SERVICE_NEW )
do
	$(mv "$JBOSS_SERVICE_NEW/$archivo" $JBOSS_SERVICE 2>> $ERROR_LOG)
	echo "Se copio el archivo "$JBOSS_SERVICE_NEW/$archivo
	echo "Se copio el archivo "$JBOSS_SERVICE_NEW/$archivo >> $INSTALL_LOG
done

IFS=$SAVEIFS

echo " "
echo " " >> $INSTALL_LOG
# JZUNIGA jboss-service fin

#DPS I
# Respaldar componentes antiguos (Imagenes de Formularios)
echo "Respaldar componentes antiguos (Imagenes de Formularios)"
echo "Respaldar componentes antiguos (Imagenes de Formularios)" >> $INSTALL_LOG

if [ -d $BACKUP_PATH/Componentes/07_FORMS/jtopazspec/imgs ];
then
echo "Se encontro respaldo componentes antiguos (Imagenes de Formularios)"
echo "Se encontro respaldo componentes antiguos (Imagenes de Formularios)" >> $INSTALL_LOG
echo "El directorio \""$BACKUP_PATH"/Componentes/07_FORMS/jtopazspec/imgs\" ya existe"
echo "El directorio \""$BACKUP_PATH"/Componentes/07_FORMS/jtopazspec/imgs\" ya existe" >> $INSTALL_LOG
else
mkdir -p $BACKUP_PATH/Componentes/07_FORMS/jtopazspec/imgs

ls $FORMS_IMGS_NEW | grep ".\." > $BACKUP_PATH/Componentes/07_FORMS/jtopazspec/imgs/lista_news_forms_imgs.txt

for archivo in $(ls $FORMS_IMGS_NEW | grep ".\.")
do
	if [ -e $FORMS_IMGS/$archivo ];
	then
		$(mv $FORMS_IMGS/$archivo $BACKUP_PATH/Componentes/07_FORMS/jtopazspec/imgs 2>> $ERROR_LOG)
		if [ $? -eq 0 ]; then
			echo "Se respaldo y elimino el archivo "$FORMS_IMGS/$archivo
			echo "Se respaldo y elimino el archivo "$FORMS_IMGS/$archivo >> $INSTALL_LOG
		else
			echo "No se encontro el archivo "$FORMS_XML/$archivo
			echo "No se encontro el archivo "$FORMS_XML/$archivo >> $INSTALL_LOG
		fi
	else
		echo "No se encontro el archivo "$FORMS_IMGS/$archivo
		echo "No se encontro el archivo "$FORMS_IMGS/$archivo >> $INSTALL_LOG
	fi
done
fi

echo " "
echo " " >> $INSTALL_LOG

# Copiar nuevos componentes (Imagenes de Formularios)
echo "Copiar nuevos componentes (Imagenes de Formularios) a la ruta "$FORMS_IMGS
echo "Copiar nuevos componentes (Imagenes de Formularios) a la ruta "$FORMS_IMGS >> $INSTALL_LOG

for archivo in $(ls $FORMS_IMGS_NEW | grep ".\.")
do
	$(mv $FORMS_IMGS_NEW/$archivo $FORMS_IMGS 2>> $ERROR_LOG)
	echo "Se copio el archivo "$FORMS_IMGS_NEW/$archivo
	echo "Se copio el archivo "$FORMS_IMGS_NEW/$archivo >> $INSTALL_LOG
done
#DPS F

echo " "
echo " " >> $INSTALL_LOG

# VCA KettleFileParam ini
# Respaldar componentes antiguos (Kettle file_param)
echo "Respaldar componentes antiguos (Kettle file_param)"
echo "Respaldar componentes antiguos (Kettle file_param)" >> $INSTALL_LOG

if [ -d $BACKUP_PATH/Componentes/14_KETTLE_FILE_PARAM ];
then
echo "Se encontro respaldo componentes antiguos (Kettle file_param)"
echo "Se encontro respaldo componentes antiguos (Kettle file_param)" >> $INSTALL_LOG
echo "El directorio \""$BACKUP_PATH"/Componentes/14_KETTLE_FILE_PARAM\" ya existe"
echo "El directorio \""$BACKUP_PATH"/Componentes/14_KETTLE_FILE_PARAM\" ya existe" >> $INSTALL_LOG
else
mkdir -p $BACKUP_PATH/Componentes/14_KETTLE_FILE_PARAM

ls $KETTLE_FILE_PARAM_NEW | grep ".\.properties$" > $BACKUP_PATH/Componentes/14_KETTLE_FILE_PARAM/lista_news_kettle_file_param.txt

#Reemplaza variable de separador que era espacio en blanco por otro valor para soportar archivos con espacios en blanco en su nombre
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
for archivo in $(ls $KETTLE_FILE_PARAM_NEW | grep ".\.properties$")
do
	if [ -e "$KETTLE_FILE_PARAM/$archivo" ];
	then
		$(mv "$KETTLE_FILE_PARAM/$archivo" $BACKUP_PATH/Componentes/14_KETTLE_FILE_PARAM 2>> $ERROR_LOG)
		if [ $? -eq 0 ]; then
			echo "Se respaldo y elimino el archivo "$KETTLE_FILE_PARAM/$archivo
			echo "Se respaldo y elimino el archivo "$KETTLE_FILE_PARAM/$archivo >> $INSTALL_LOG
		else
			echo "No se encontro el archivo "$KETTLE_FILE_PARAM/$archivo
			echo "No se encontro el archivo "$KETTLE_FILE_PARAM/$archivo >> $INSTALL_LOG
		fi
	else
		echo "No se encontro el archivo "$KETTLE_FILE_PARAM/$archivo
		echo "No se encontro el archivo "$KETTLE_FILE_PARAM/$archivo >> $INSTALL_LOG
	fi
done
IFS=$SAVEIFS
fi

echo " "
echo " " >> $INSTALL_LOG

# Copiar nuevos componentes (Kettle file_param)
echo "Copiar nuevos componentes (Kettle file_param) a la ruta "$KETTLE_FILE_PARAM
echo "Copiar nuevos componentes (Kettle file_param) a la ruta "$KETTLE_FILE_PARAM >> $INSTALL_LOG

#Reemplaza variable de separador que era espacio en blanco por otro valor para soportar archivos con espacios en blanco en su nombre
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
for archivo in $(ls $KETTLE_FILE_PARAM_NEW | grep ".\.properties$")
do
	$(mv $KETTLE_FILE_PARAM_NEW/$archivo $KETTLE_FILE_PARAM 2>> $ERROR_LOG)
	echo "Se copio el archivo "$KETTLE_FILE_PARAM_NEW/$archivo
	echo "Se copio el archivo "$KETTLE_FILE_PARAM_NEW/$archivo >> $INSTALL_LOG
done
IFS=$SAVEIFS

echo " "
echo " " >> $INSTALL_LOG
# VCA KettleFileParam fin

# DRIOS INI
# Respaldar componentes antiguos (APP Jar)
echo "Respaldar componentes antiguos (APP Jar)"
echo "Respaldar componentes antiguos (APP Jar)" >> $INSTALL_LOG

if [ -d $BACKUP_PATH/Componentes/09_JARS/06-Configuration ];
then
echo "Se encontro respaldo componentes antiguos (APP Jar)"
echo "Se encontro respaldo componentes antiguos (APP Jar)" >> $INSTALL_LOG
echo "El directorio \""$BACKUP_PATH"/Componentes/09_JARS/06-Configuration\" ya existe"
echo "El directorio \""$BACKUP_PATH"/Componentes/09_JARS/06-Configuration\" ya existe" >> $INSTALL_LOG
else
mkdir -p $BACKUP_PATH/Componentes/09_JARS/06-Configuration

ls $TOPAZ_APP_NEW | grep ".\.jar$" > $BACKUP_PATH/Componentes/09_JARS/06-Configuration/lista_news_jars_topaz_app.txt

for archivo in $(ls $TOPAZ_APP_NEW | grep ".\.jar$")
do
	if [ -e $TOPAZ_APP/$archivo ];
	then
		$(mv $TOPAZ_APP/$archivo $BACKUP_PATH/Componentes/09_JARS/06-Configuration 2>> $ERROR_LOG)
		if [ $? -eq 0 ]; then
			echo "Se respaldo y elimino el archivo "$TOPAZ_APP/$archivo
			echo "Se respaldo y elimino el archivo "$TOPAZ_APP/$archivo >> $INSTALL_LOG
		else
			echo "No se encontro el archivo "$TOPAZ_APP/$archivo
			echo "No se encontro el archivo "$TOPAZ_APP/$archivo >> $INSTALL_LOG
		fi
	else
		echo "No se encontro el archivo "$TOPAZ_APP/$archivo
		echo "No se encontro el archivo "$TOPAZ_APP/$archivo >> $INSTALL_LOG
	fi
done
fi

echo " "
echo " " >> $INSTALL_LOG

# Copiar nuevos componentes (APP Jar)
echo "Copiar nuevos componentes (APP Jar) a la ruta "$TOPAZ_APP
echo "Copiar nuevos componentes (APP Jar) a la ruta "$TOPAZ_APP >> $INSTALL_LOG

for archivo in $(ls $TOPAZ_APP_NEW | grep ".\.jar$")
do
	$(mv $TOPAZ_APP_NEW/$archivo $TOPAZ_APP 2>> $ERROR_LOG)
	echo "Se copio el archivo "$TOPAZ_APP_NEW/$archivo
	echo "Se copio el archivo "$TOPAZ_APP_NEW/$archivo >> $INSTALL_LOG
done

echo " "
echo " " >> $INSTALL_LOG
# DRIOS FIN

# RMM 13/06/17 INI
# Respaldar componentes antiguos (Archivos de configuracion XML)
echo "Respaldar componentes antiguos (Archivos de configuracion XML - HTML)"
echo "Respaldar componentes antiguos (Archivos de configuracion XML - HTML)" >> $INSTALL_LOG

if [ -d $BACKUP_PATH/Componentes/04_XMLS/userlibrary/default/mails/html ];
then
echo "Se encontro respaldo componentes antiguos (Archivos de configuracion XML - HTML)"
echo "Se encontro respaldo componentes antiguos (Archivos de configuracion XML - HTML)" >> $INSTALL_LOG
echo "El directorio \""$BACKUP_PATH"/Componentes/04_XMLS/userlibrary/default/mails/html" ya existe"
echo "El directorio \""$BACKUP_PATH"/Componentes/04_XMLS/userlibrary/default/mails/html" ya existe" >> $INSTALL_LOG
else
mkdir -p $BACKUP_PATH/Componentes/04_XMLS/userlibrary/default/mails/html

ls $TOPAZ_HTML_NEW | grep ".\.xml$" > $BACKUP_PATH/Componentes/04_XMLS/userlibrary/default/mails/html/lista_news_html.txt

#Reemplaza variable de separador que era espacio en blanco por otro valor para soportar archivos con espacios en blanco en su nombre
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
for archivo in $(ls $TOPAZ_HTML_NEW | grep ".\.html$")
do
	if [ -e $TOPAZ_HTML/$archivo ];
	then
		$(mv $TOPAZ_HTML/$archivo $BACKUP_PATH/Componentes/04_XMLS/userlibrary/default/mails/html 2>> $ERROR_LOG)
		if [ $? -eq 0 ]; then
			echo "Se respaldo y elimino el archivo "$TOPAZ_HTML/$archivo
			echo "Se respaldo y elimino el archivo "$TOPAZ_HTML/$archivo >> $INSTALL_LOG
		else
			echo "No se encontro el archivo "$TOPAZ_HTML/$archivo
			echo "No se encontro el archivo "$TOPAZ_HTML/$archivo >> $INSTALL_LOG
		fi
	else
		echo "No se encontro el archivo "$TOPAZ_HTML/$archivo
		echo "No se encontro el archivo "$TOPAZ_HTML/$archivo >> $INSTALL_LOG
	fi
done
IFS=$SAVEIFS
fi

echo " "
echo " " >> $INSTALL_LOG

# Copiar nuevos componentes (Archivos de configuracion XML)
echo "Copiar nuevos componentes (Archivos de configuracion XML - HTML) a la ruta "$TOPAZ_HTML
echo "Copiar nuevos componentes (Archivos de configuracion XML - HTML) a la ruta "$TOPAZ_HTML >> $INSTALL_LOG

#Reemplaza variable de separador que era espacio en blanco por otro valor para soportar archivos con espacios en blanco en su nombre
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
for archivo in $(ls $TOPAZ_HTML_NEW | grep ".\.html$")
do
	$(mv $TOPAZ_HTML_NEW/$archivo $TOPAZ_HTML 2>> $ERROR_LOG)
	echo "Se copio el archivo "$TOPAZ_HTML_NEW/$archivo
	echo "Se copio el archivo "$TOPAZ_HTML_NEW/$archivo >> $INSTALL_LOG
done
IFS=$SAVEIFS

echo " "
echo " " >> $INSTALL_LOG
# RMM 13/06/17 FIN

