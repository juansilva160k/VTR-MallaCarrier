####################################################################################################################
# NOMBRE PROCESO : procesoGenera_AltasBajas_Carrier.sh                                                                    #
####################################################################################################################
# EMPRESA         : 160K                                                                                           #
# AUTOR           : Pedro Barrios Zúñiga                                                                           #
# FECHA CREACION  : Abril 2021                                                                                   #
# DESCRIPCION     : Proceso de Generación de archvios de alta y/o bajas                                            #
# FORMA EJECUCION :                                                                                                #
#  ./procesoGenera_AltasBajas_Carrier.sh A                                                                                #
#  ./procesoGenera_AltasBajas_Carrier.sh B                                                                                #
# PARAMETROS :   A (para proceso Altas)                                                                            #
#                B (para proceso Bajas)                                                                            # -----------------------------------------------------------------------------------------------------------------#
# CONTROL DE CAMBIOS                                                                                               #
# -----------------------------------------------------------------------------------------------------------------#
#                                                                                                                  #
# FECHA MODIFICACION :                                                                                             #
# AUTOR              :                                                                                             #
# DESCRIPCION        :                                                                                             #
#                                                                                                                  #
#                                                                                                                  #
# -----------------------------------------------------------------------------------------------------------------#
#                                                                                                                  #
# -----------------------------------------------------------------------------------------------------------------#
####################################################################################################################
#
#==================================================================================================================
MiNombre=procesoGenera
NAM=${MiNombre}
out(){ echo "$(date +%H:%M:%S) $NAM: $*"; }
#==================================================================================================================

#
#==================================================================================================================
#----------------------------------------------------------------------------------------------------------
#Variables Iniciales
#
DATE=`date +%Y%m%d_%H%M%S`

#-----------------------------------------------------------------------------------------------------------
#
#------------------------------------------------------------------------------------------------------
## VALIDACION PARAMETROS
#
error=0

EXIT_COD=0
PARAMETROS_OK=1
#
if [ $# -ne 1 ]; then
   mensajeError="El script no recibió 1 parámetro                            "
   EXIT_COD=1
   PARAMETROS_OK=0
fi
#
if [ $EXIT_COD -eq 0 ]
then
   TIPO_PROCESO=$1
fi
#
ID_PROCESO="ND"
TIPO_ARCHIVOS_PROCESO="ND"
if [ ${TIPO_PROCESO} == "A" ]
then
    ID_PROCESO="ALTAS"
    TIPO_ARCHIVOS_PROCESO="Altas"
    MiNombre=${MiNombre}_altas
fi
if [ ${TIPO_PROCESO} == "B" ]
then
    ID_PROCESO="BAJAS"
    TIPO_ARCHIVOS_PROCESO="Bajas"
    MiNombre=${MiNombre}_bajas
fi
#----------------------------------------------------------------------------------------------------------
#
#==================================================================================================================
#
#-----------------------------------------------------------------------------------------------------------
#Variable de Entorno
#
#
cd /ftp/interfaces/OUT/ldiab/proceso/shell
#
if [ ! -e confVariablesAmbiente_Carrier.cfg ]; 
then     
    mensaje="Verificacion : Error, no se puede encontrar archivo configuracion procesoConfAmbiente.cfg: 3"
    error=1
else
    mensaje="Verificacion : OK, encontrado archivo configuracion procesoConfAmbiente.cfg"
    . /ftp/interfaces/OUT/ldiab/proceso/shell/confVariablesAmbiente_Carrier.cfg
fi;
#-----------------------------------------------------------------------------------------------------------
#
#-----------------------------------------------------------------------------------------------------------
#Variable de ARCHIVOS
#

#echo "HOME_PROCESO            : $HOME_PROCESO             "
#echo "HOME_FTP                : $HOME_FTP                 "
#echo "HOME_LOG                : $HOME_LOG                 "
#echo "HOME_SHELL              : $HOME_SHELL               "
#echo "HOME_CFG                : $HOME_CFG                 "
#echo "HOME_AWK                : $HOME_AWK                 "
#echo "HOME_DAT                : $HOME_DAT                 "
#echo "RUTA_DAT_SALIDA      : $RUTA_DAT_SALIDA       "
#echo "RUTA_DAT_EN_PROCESO     : $RUTA_DAT_EN_PROCESO      "
#echo "RUTA_DAT_LOADER         : $RUTA_DAT_LOADER          "
#echo "RUTA_DAT_ENTRADA        : $RUTA_DAT_ENTRADA         "
#echo "RUTA_DAT_TRANSFORMACION : $RUTA_DAT_TRANSFORMACION  "
#echo "RUTA_DAT_ALMACENAJE     : $RUTA_DAT_ALMACENAJE      "
#echo "RUTA_DAT_EMPAQUETADO    : $RUTA_DAT_EMPAQUETADO     "
#
#exit 0

ARCHIVOLOG=$HOME_LOG/${MiNombre}_${ID_PROCESO}_${DATE}_DetEje.log
#
if [ ${TIPO_PROCESO} == "A" ]
then    
    NAME_PROCESO_CFG="genera_altas_carrier.cfg"
fi
if [ ${TIPO_PROCESO} == "B" ]
then    
    NAME_PROCESO_CFG="genera_bajas_carrier.cfg"
fi


#-----------------------------------------------------------------------------------------------------------

out "============================================================================================================="| tee -a $ARCHIVOLOG
out "Ejecución Proceso copia via FTP de archivos de Carrier                                                       "| tee -a $ARCHIVOLOG
out "   Tipo de proceco a copiar: ${TIPO_ARCHIVOS_PROCESO}                                                        "| tee -a $ARCHIVOLOG
out "_____________________________________________________________________________________________________________"| tee -a $ARCHIVOLOG
out "Inicio Proceso                                                                                               "| tee -a $ARCHIVOLOG
out "                                                                                                             "| tee -a $ARCHIVOLOG
out "-------------------------------------------------------------------------------------------------------------"| tee -a $ARCHIVOLOG
out "Validación Archivos de configuración                                                                         "| tee -a $ARCHIVOLOG
#----------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------
#
if [ ${error} -eq 0 ]
then 
   #
   mensaje="Archivo ${HOME_CFG}/ftp_user.cfg. "
   if [ ! -e $HOME_CFG/ftp_user.cfg ]; 
   then     
       mensaje=${mensaje}" Resultado validación existencia : Error, no se puede encontrar archivo"
       error=2
   else
       mensaje=${mensaje}" Resultado validación existencia : OK"
   fi;
   out $mensaje| tee -a $ARCHIVOLOG
   #   
   mensaje="Archivo  ${HOME_CFG}/${NAME_PROCESO_CFG}. "
   if [ ! -e ${HOME_CFG}/${NAME_PROCESO_CFG} ]; 
   then     
       mensaje=${mensaje}" Resultado validación existencia : Error, no se puede encontrar archivo"
      error=3
   else
       mensaje=${mensaje}" Resultado validación existencia : OK"
   fi;
   out $mensaje| tee -a $ARCHIVOLOG
   #   
fi
out "-------------------------------------------------------------------------------------------------------------"| tee -a $ARCHIVOLOG
#
if [ ${error} -ne 0 ]
then 
   out "El proceso no puede continuar ya que no están disponibles todos los archivos de configuración             "| tee -a $ARCHIVOLOG
fi
#----------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------------
#Lectura de parametros de archivos de salida (path y archivos)
#
if [ ${error} -eq 0 ]
then 
   #
   #-----------------------------------------------------------------------------------------------------------
   #Variables ruta y archivos copiar via FTP
   #
   CFGARCHIVOSENT=${HOME_CFG}/${NAME_PROCESO_CFG}
   HOME_DATSAL_PATH=`cat ${CFGARCHIVOSENT}|awk '{print $1}'`
   FILES_DATSAL_PATH=`cat ${CFGARCHIVOSENT}|awk '{print $2}'`
   TIPO_PROCESO=`cat ${CFGARCHIVOSENT}|awk '{print $3}'`
   #-----------------------------------------------------------------------------------------------------------
   #
fi
#----------------------------------------------------------------------------------------------------------------
#
#----------------------------------------------------------------------------------------------------------
#Validar permisos sobre carpeta de salida de archivos

echo "ARCHIVOLOG    : $ARCHIVOLOG     "


if [ ${error} -eq 0 ]
then
   archivo_dummy=prueba_${DATE}.dummy
   touch  ${HOME_DATSAL_PATH}/${archivo_dummy}
   if [ $? -ne 0 ]
   then
      mensaje="No se puede escribir en directorio ${HOME_DATSAL_PATH}"
      error=5
   fi
   if [ ${error} -eq 0 ]
   then
      ls ${HOME_DATSAL_PATH}
      if [ $? -ne 0 ]
      then
         mensaje="No se puede leer en directorio ${HOME_DATSAL_PATH}"
         error=6
      fi     
   fi
   if [ ${error} -eq 0 ]
   then
      rm -f ${HOME_DATSAL_PATH}/${archivo_dummy}
      if [ $? -ne 0 ]
      then
         mensaje="No se puede borrar en directorio ${HOME_DATSAL_PATH}"
         error=7
      fi     
   fi
   #
   if [ ${error} -eq 0 ]
   then
      out "Hay permisos de lectura y escritura sobre carpeta ${HOME_DATSAL_PATH} "| tee -a $ARCHIVOLOG
   else 
       out $mensaje| tee -a $ARCHIVOLOG
   fi
   
fi 
#----------------------------------------------------------------------------------------------------------------

#
#==================================================================================================================
#
#==================================================================================================================
#Proceso
if [ ${error} -eq 0 ]
then 
   #
   out "-------------------------------------------------------------------------------------------------------------"| tee -a $ARCHIVOLOG
   out "Variables de ambiente del proceso                                                                        "| tee -a $ARCHIVOLOG
   out "    HOME_SHELL        : ${HOME_SHELL}                                                                        "| tee -a $ARCHIVOLOG
   out "    HOME_LOG          : ${HOME_LOG}                                                                          "| tee -a $ARCHIVOLOG
   out "    HOME_FTP          : ${HOME_FTP}                                                                          "| tee -a $ARCHIVOLOG
   out "    RUTA_DAT_EN_PROCESO : ${RUTA_DAT_EN_PROCESO}                                                             "| tee -a $ARCHIVOLOG
   out "    RUTA_DAT_ALMACENAJE : ${RUTA_DAT_ALMACENAJE}                                                             "| tee -a $ARCHIVOLOG
   out "-------------------------------------------------------------------------------------------------------------"| tee -a $ARCHIVOLOG
   out "Variables de origen de los archivos del proceso                                                              "| tee -a $ARCHIVOLOG
   out "    RUTA SALIDA       : ${HOME_DATSAL_PATH}                                                                  "| tee -a $ARCHIVOLOG
   out "    ARCHIVOS SALIDA   : ${FILES_DATSAL_PATH}                                                                 "| tee -a $ARCHIVOLOG
   out "-------------------------------------------------------------------------------------------------------------"| tee -a $ARCHIVOLOG
   #
   ARCHIVOS=${FILES_DATSAL_PATH} 
   RUTA_DAT_SALIDA=${HOME_DATSAL_PATH}
   #
fi

#------------------------------------------------------------------------------------------------------
#Limpeza de directorio
#Falta validar que hizo la limpieza
echo ${RUTA_DAT_SALIDA}

ls -ltr ${RUTA_DAT_SALIDA}/*

rm -f ${RUTA_DAT_SALIDA}/*


if [ ${error} -ne 0 ]
then 
   out "El proceso no puede continuar ya que puedo limpiar el directorio de salida de archivos  ${RUTA_DAT_SALIDA}  "| tee -a $ARCHIVOLOG
fi

ls -ltr ${RUTA_DAT_SALIDA}/*
#
#-------------------------------------------------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------------------------------------------------
if [ ${error} -eq 0 ]
then 
   #
   #----------------------------------------------------------------------------------------------------
   #
   DATE_AYER=`date --date='-1 day' +%Y%m%d`
   #
   java -jar /ftp/interfaces/OUT/ldiab/proceso/jar/ObtenerDatosClienteLdi.jar ${TIPO_PROCESO} ${DATE_AYER} ${DATE_AYER}
   STATUS=$?

   echo "STATUS  ${STATUS}"
   
   error=${STATUS}
   #----------------------------------------------------------------------------------------------------
   #
   #----------------------------------------------------------------------------------------------------
   #Errores de paramatros
   if [ ${error} -eq 100 ]
   then
      #100 - Argumento ingresado no corresponde ... debe ser VENTAS o BAJAS
      error=12
   fi

   if [ ${error} -eq 105 ]
   then
      #105 - Formato de fecha desde incorrecto 
      error=13
   fi

   if [ ${error} -eq 106 ]
   then
      #105 - Formato de fecha hasta incorrecto 
      error=14
   fi
   #------------------------------------------------------------------------------------------------------
   #
   #------------------------------------------------------------------------------------------------------
   #Errores de Base de Datos
   #
   if [ ${error} -eq 101 ]
   then
      #101 - Error al cargar driver de conexión a la BD 
      error=15
   fi
   #
   if [ ${error} -eq 102 ]
   then
      #102 - Error en realizar la conexión a la BD 
      error=16
   fi
   #
   if [ ${error} -eq 103 ]
   then
      #103 - Error interno de la BD 
      error=17
   fi
   #------------------------------------------------------------------------------------------------------
   #
   #------------------------------------------------------------------------------------------------------
   #Errores de escritura de archivo

   if [ ${error} -eq 61 ]
   then
      #51 - Error al escribir en archivo
      error=18
   fi
   #
   if [ ${error} -eq 104 ]
   then
      #104 - Error al guardar archivo
      error=19
   fi
   #------------------------------------------------------------------------------------------------------

fi
#
out "_____________________________________________________________________________________________________________"| tee -a $ARCHIVOLOG
out "Fin del proceso                                                                                              "| tee -a $ARCHIVOLOG    
out "                                                                                                             "| tee -a $ARCHIVOLOG





if [ ${error} -eq 0 ]
then
   out "El proceso termino sin errores                                                                               "| tee -a $ARCHIVOLOG    
else
   out "El proceso termino con errores : ${error}                                                                    "| tee -a $ARCHIVOLOG    
fi
#
out "============================================================================================================="| tee -a $ARCHIVOLOG

exit ${error}





