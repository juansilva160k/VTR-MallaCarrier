####################################################################################################################
# NOMBRE PROCESO : procesoFtp_AltasBajas_Carrier.sh                                                                #
####################################################################################################################
# EMPRESA         : 160K                                                                                           #
# AUTOR           : JS/PB                                                                                          #
# FECHA CREACION  : Abril 2021                                                                                     #
# DESCRIPCION     : mueve archivos altas a servidor externo                                                        #
# FORMA EJECUCION :                                                                                                #
#  ./procesoFtp_AltasBajas_Carrier.sh A                                                                            #
#  ./procesoFtp_AltasBajas_Carrier.sh B                                                                            #
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
MiNombre=procesoFTP
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
	MiNombre=${MiNombre}_altas_carrier
fi
if [ ${TIPO_PROCESO} == "B" ]
then
    ID_PROCESO="BAJAS"
    TIPO_ARCHIVOS_PROCESO="Bajas"
	MiNombre=${MiNombre}_bajas_carrier
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
if [ ! -e confVariablesAmbiente.cfg ]; 
then     
    mensaje="Verificacion : Error, no se puede encontrar archivo configuracion procesoConfAmbiente.cfg: 3"
    error=1
else
    mensaje="Verificacion : OK, encontrado archivo configuracion procesoConfAmbiente.cfg"
    . /ftp/interfaces/OUT/ldiab/proceso/shell/confVariablesAmbiente.cfg
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
#echo "RUTA_DAT_RECEPCION      : $RUTA_DAT_RECEPCION       "
#echo "RUTA_DAT_EN_PROCESO     : $RUTA_DAT_EN_PROCESO      "
#echo "RUTA_DAT_LOADER         : $RUTA_DAT_LOADER          "
#echo "RUTA_DAT_ENTRADA        : $RUTA_DAT_ENTRADA         "
#echo "RUTA_DAT_TRANSFORMACION : $RUTA_DAT_TRANSFORMACION  "
#echo "RUTA_DAT_ALMACENAJE     : $RUTA_DAT_ALMACENAJE      "
#echo "RUTA_DAT_EMPAQUETADO    : $RUTA_DAT_EMPAQUETADO     "
#
#exit 0

ARCHIVOLOG=$HOME_LOG/${MiNombre}_${ID_PROCESO}_${DATE}_DetEje.log
ARCHIVOLOGFTP=$HOME_LOG/${MiNombre}_${ID_PROCESO}_${DATE}_DetFTP.log
NOMBRE_ARCH=$HOME_FTP/ftp_proceso.tmp
#
if [ ${TIPO_PROCESO} == "A" ]
then	
    NAME_PROCESO_CFG="altas.cfg"
fi
if [ ${TIPO_PROCESO} == "B" ]
then	
    NAME_PROCESO_CFG="bajas.cfg"
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
#
if [ ${error} -eq 0 ]
then 
   #-----------------------------------------------------------------------------------------------------------
   #
   #-----------------------------------------------------------------------------------------------------------
   #Variables de conexión
   #
   CFGUSER=$HOME_CFG/ftp_user.cfg
   #
   MAQUINA=`cat ${CFGUSER}|awk '{print $1}'`
   USUARIO=`cat ${CFGUSER}|awk '{print $2}'`
   CLAVE=`cat   ${CFGUSER}|awk '{print $3}'`
   PATH_FTP=`cat   ${CFGUSER}|awk '{print $4}'`
   #-----------------------------------------------------------------------------------------------------------
   #
   #-----------------------------------------------------------------------------------------------------------
   #Variables ruta y archivos copiar via FTP
   #
   CFGARCHIVOSENT=${HOME_CFG}/${NAME_PROCESO_CFG}
   HOME_DATENT_PATH=`cat ${CFGARCHIVOSENT}|awk '{print $1}'`
   FILES_DATENT_PATH=`cat ${CFGARCHIVOSENT}|awk '{print $2}'`
   #-----------------------------------------------------------------------------------------------------------
   #
fi
#
#----------------------------------------------------------------------------------------------------------------


echo "ARCHIVOLOG    : $ARCHIVOLOG     "
echo "ARCHIVOLOGFTP    : $ARCHIVOLOGFTP     "
echo "NOMBRE_ARCH    : $NOMBRE_ARCH     "

#if [ ! -e $HOME_FTP ]; 
#then     
	#mensaje="Verificacion : Error, no se puede generar archivo tmp en directorio ftp"    
	#error=4
#fi

#Validar permisos sobre carpeta de lectura de archivos

#echo "HOME_DATENT_PATH    : $HOME_DATENT_PATH     "
#exit


if [ ${error} -eq 0 ]
then
   archivo_dummy=prueba_${DATE}.dummy
   touch  ${HOME_DATENT_PATH}/${archivo_dummy}
   if [ $? -ne 0 ]
   then
      mensaje="No se puede escribir en directorio ${HOME_DATENT_PATH}"
      error=5
   fi
   if [ ${error} -eq 0 ]
   then
      ls ${HOME_DATENT_PATH}
      if [ $? -ne 0 ]
      then
         mensaje="No se puede leer en directorio ${HOME_DATENT_PATH}"
         error=6
      fi     
   fi
   if [ ${error} -eq 0 ]
   then
      rm -f ${HOME_DATENT_PATH}/${archivo_dummy}
      if [ $? -ne 0 ]
      then
         mensaje="No se puede borrar en directorio ${HOME_DATENT_PATH}"
         error=7
      fi     
   fi
   #
   if [ ${error} -eq 0 ]
   then
      out "Hay permisos de lectura y escritura sobre carpeta ${HOME_DATENT_PATH} "| tee -a $ARCHIVOLOG
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
   out "Variables del FTP del proceso                                                                                "| tee -a $ARCHIVOLOG
   out "   MAQUINA          : srvcarrierstg02 ( ${MAQUINA} )                                                         "| tee -a $ARCHIVOLOG
   out "   USUARIO          : ${USUARIO}                                                                             "| tee -a $ARCHIVOLOG
   out "   CLAVE            : *********                                                                              "| tee -a $ARCHIVOLOG
   out "   RUTA DESTINOO    : ${PATH_FTP}                                                                            "| tee -a $ARCHIVOLOG
   out "-------------------------------------------------------------------------------------------------------------"| tee -a $ARCHIVOLOG
   out "Variables de origen de los archivos del proceso                                                              "| tee -a $ARCHIVOLOG
   out "    RUTA ENTRADA      : ${HOME_DATENT_PATH}                                                                  "| tee -a $ARCHIVOLOG
   out "    ARCHIVOS ENTRADA  : ${FILES_DATENT_PATH}                                                                 "| tee -a $ARCHIVOLOG
   out "-------------------------------------------------------------------------------------------------------------"| tee -a $ARCHIVOLOG
   #
   ARCHIVOS=${FILES_DATENT_PATH} 
   RUTA_DAT_RECEPCION=${HOME_DATENT_PATH}
   #
fi

#-------------------------------------------------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------------------------------------------------
if [ ${error} -eq 0 ]
then
   cd ${RUTA_DAT_RECEPCION}
   out "validación de existencia de archivos                                                                             "| tee -a $ARCHIVOLOG
   nCantidadArchivos=`ls -ltr ${ARCHIVOS} | awk '{print $9}'|wc -l`
   if [ ${nCantidadArchivos} -eq 0 ]
   then
      mensaje="No hay archivos <${ARCHIVOS}> a copiar en la ruta  <${RUTA_DAT_RECEPCION}> "
      error=11
   else
       mensaje="Existe(n) ${nCantidadArchivos} archivo(s) <${ARCHIVOS}> a copiar en la ruta  <${RUTA_DAT_RECEPCION}> "
   fi;
   out $mensaje| tee -a $ARCHIVOLOG
fi
#
if [ ${error} -ne 0 ]
then 
   out "El proceso no puede continuar ya que no hay archivos a copiar al servidor FTP            "| tee -a $ARCHIVOLOG
fi
#-------------------------------------------------------------------------------------------------------------------------
#
if [ ${error} -eq 0 ]
then 
   #
   cd $RUTA_DAT_RECEPCION
   ls -ltr ${ARCHIVOS} | awk '{print $9}' > $NOMBRE_ARCH
   #   
   for FILE in `cat $NOMBRE_ARCH`
   do
      cd $RUTA_DAT_RECEPCION
      #
      cmd=`ls -ltr ${FILE}`
      moverArchivoOK=0
      #
      out ".................................................................................."  | tee -a $ARCHIVOLOG
      out "Ejecución proceso ftp archivo: $FILE                                              "  | tee -a $ARCHIVOLOG
      out "${cmd}                                                                            "  | tee -a $ARCHIVOLOG
      #
      out "    Paso 01: Mover archivo ${FILE} a directorio ${RUTA_DAT_EN_PROCESO}            "  | tee -a $ARCHIVOLOG
      
      mv -f $FILE $RUTA_DAT_EN_PROCESO/       >> $ARCHIVOLOG
	  
	  if [ -e ${RUTA_DAT_EN_PROCESO}/${FILE} ]
      then
         out "            Mover archivo :$FILE - Ejecutado : OK"   | tee -a $ARCHIVOLOG
         moverArchivoOK=1
      else
         out "            Mover archivo :$FILE - Ejecutado : No OK"   | tee -a $ARCHIVOLOG
         moverArchivoOK=0
         error=12
      fi 
      #
      #
      if [ ${moverArchivoOK} -eq 1 ]
      then
         #
         cd ${RUTA_DAT_EN_PROCESO}
         #
         out "    Paso 02: Ejecutar copia FTP hacia el servidor srvcarrierstg02 en la ruta ${PATH_FTP}             "  | tee -a $ARCHIVOLOG
         ftpEjecutadoOK=0
         #------------------------------------------------------------------------------------------------------
         NOMBRE_echo_ftp_FILE=${HOME_FTP}/ftp_copia_echo_${FILE}_${DATE}.tmp
         echo "===============================================================" >  $NOMBRE_echo_ftp_FILE
         echo "******************   Ejecución ftp - copia  *******************" >> $NOMBRE_echo_ftp_FILE
         echo "Archivo a copiar :${FILE}                                      " >> $NOMBRE_echo_ftp_FILE
         echo "                                                               " >> $NOMBRE_echo_ftp_FILE
        
         stty -echo
         (   
          echo "user $USUARIO $CLAVE"
          echo "cd ${PATH_FTP}"
          echo "ascii"
          echo "  "
          echo "put " $FILE
          echo "  "
          echo "bye"
         ) |ftp -i -n -v $MAQUINA >> $NOMBRE_echo_ftp_FILE
		 #
		 #*****************************
         #CLAVE=${CLAVE_ANT}
		 #*****************************
         #
         echo "****************** Fin Ejecución ftp - copia  ***************" >> $NOMBRE_echo_ftp_FILE
         echo "===============================================================" >> $NOMBRE_echo_ftp_FILE
        		 
		 procesoFTPPutOK=0
         codResultadoFTP_125=`grep 125 $NOMBRE_echo_ftp_FILE|wc -l` 
         codResultadoFTP_226=`grep 226 $NOMBRE_echo_ftp_FILE|wc -l`
		 echo "codResultadoFTP_125 $codResultadoFTP_125"
		 echo "codResultadoFTP_226 $codResultadoFTP_226"
         if [ ${codResultadoFTP_125} -eq 1 ]
         then
            if [ ${codResultadoFTP_226} -eq 1 ]
            then 
               procesoFTPPutOK=1
            fi
         fi
         if [ ${procesoFTPPutOK} -eq 1 ]
         then
            out "             Resultado copia FTP OK        "  | tee -a $ARCHIVOLOG
         else
            out "             Resultado copia FTP Tiene errores consultar log: ${ARCHIVOLOGFTP}        "  | tee -a $ARCHIVOLOG
            error=13
         fi
         cat $NOMBRE_echo_ftp_FILE                                              >> $ARCHIVOLOGFTP
         rm -f $NOMBRE_echo_ftp_FILE
         out "            Termino copia de archivo :$FILE a servidor remoto via ftp "  | tee -a $ARCHIVOLOG
         #------------------------------------------------------------------------------------------------------
         #
         #------------------------------------------------------------------------------------------------------
         if [ ${error} -eq 0 ]
         then 	
            out "    Paso 03: copiar archivo :$FILE desde servidor srvcarrierstg02 en la ruta ${PATH_FTP}   "  | tee -a $ARCHIVOLOG
            NOMBRE_echo_ftp_FILE=${HOME_FTP}/ftp_get_echo_${FILE}_${DATE}.tmp
            echo "===============================================================" >  $NOMBRE_echo_ftp_FILE
            echo "******************   Ejecución ftp - get    *******************" >> $NOMBRE_echo_ftp_FILE
            echo "Archivo a copiar :${FILE}                                      " >> $NOMBRE_echo_ftp_FILE
            echo "                                                               " >> $NOMBRE_echo_ftp_FILE
           
            cd ${RUTA_DAT_EN_PROCESO}
            stty -echo
            (   
             echo "user $USUARIO $CLAVE"
             echo "cd ${PATH_FTP}"
             echo "ascii"
             echo "  "
             echo "get " $FILE $FILE.ftp
             echo "  "
             echo "bye"
            ) |ftp -i -n -v $MAQUINA >> $NOMBRE_echo_ftp_FILE
			#
			#*****************************
            #CLAVE=${CLAVE_ANT}
			#*****************************
            #
            echo "****************** Fin Ejecución ftp - Get  ***************" >> $NOMBRE_echo_ftp_FILE
            echo "===============================================================" >> $NOMBRE_echo_ftp_FILE
    			
            codResultadoFTP_125=`grep 125 $NOMBRE_echo_ftp_FILE|wc -l`
            codResultadoFTP_226=`grep 226 $NOMBRE_echo_ftp_FILE|wc -l`
		    echo "codResultadoFTP_125 $codResultadoFTP_125"
		    echo "codResultadoFTP_226 $codResultadoFTP_226"
            procesoFTPGetOK=0
            if [ ${codResultadoFTP_125} -eq 1 ]
            then
               if [ ${codResultadoFTP_226} -eq 1 ]
               then 
                  procesoFTPGetOK=1
               fi
            fi
            if [ ${procesoFTPGetOK} -eq 1 ]
            then
               out "             Resultado copia FTP Get OK        "  | tee -a $ARCHIVOLOG
            else
               out "             Resultado copia FTP Get Tiene errores consultar log: ${ARCHIVOLOGFTP}        "  | tee -a $ARCHIVOLOG
               error=14
            fi
            cat $NOMBRE_echo_ftp_FILE                     >> $ARCHIVOLOGFTP
            rm -f $NOMBRE_echo_ftp_FILE
         fi 
         #------------------------------------------------------------------------------------------------------
         #
         #------------------------------------------------------------------------------------------------------
         if [ ${error} -eq 0 ]
         then 
            out "    Paso 04: Validacion (comparación) entre archivo :$FILE de la ruta ${RUTA_DAT_EN_PROCESO} con archivo enviado al servidor FTP "  | tee -a $ARCHIVOLOG
            
			
			cd ${RUTA_DAT_EN_PROCESO}
            diff ${FILE} ${FILE}.ftp > ${FILE}.diff
					 
            CANTIDAD_LINEAS=`wc -l  ${FILE}.diff|awk '{print $1}'`		
			
            if [ $CANTIDAD_LINEAS -eq 0 ]
            then
               out "            Validación OK: El archivo $FILE se copio correctamente al servidor srvcarrierstg02 en la ruta \Cuenta\InputPath\Andes  "| tee -a $ARCHIVOLOG
               ftpEjecutadoOK=1
            else
               out "            Error en la copia de archivos via ftp, favor revisar archivo $FILE.diff en ${RUTA_DAT_EN_PROCESO} "| tee -a $ARCHIVOLOG
               error=15
            fi 
            rm -f ${FILE}.diff 
            rm -f ${FILE}.ftp
         fi
         #------------------------------------------------------------------------------------------------------
         #
         #------------------------------------------------------------------------------------------------------
         if [ ${error} -ne 0 ] 
         then
		    echo "Hubo un error ahora se devolvera el archivo a ruta de entrada"
			sleep 60
            #Mover archivo desde directorio EnProceso a directorio de entrada
            cd ${RUTA_DAT_EN_PROCESO}
            mv -f $FILE $RUTA_DAT_RECEPCION/       >> $ARCHIVOLOG
			
			if [ -e ${RUTA_DAT_RECEPCION}/${FILE} ]
            then
               out "            Mover archivo a ruta Entrada: $FILE - Ejecutado : OK"   | tee -a $ARCHIVOLOG
               moverArchivoOK=1
            else
               out "            Mover archivo a ruta Entrada: $FILE - Ejecutado : No OK"   | tee -a $ARCHIVOLOG
               moverArchivoOK=0
               error=12
            fi 
			#
            if [ ${error} -ne 13 ] 
            then
               NOMBRE_echo_ftp_FILE=${HOME_FTP}/ftp_delete_echo_${FILE}_${DATE}.tmp
               echo "==============================================================="    >  $NOMBRE_echo_ftp_FILE
               echo "******************   Ejecución ftp - delete    *******************" >> $NOMBRE_echo_ftp_FILE
               echo "Eliminar a copiar :${FILE}                                        " >> $NOMBRE_echo_ftp_FILE
               echo "                                                                  " >> $NOMBRE_echo_ftp_FILE
            
               stty -echo
               (  
                echo "user $USUARIO $CLAVE"
                echo "cd ${PATH_FTP}"
                echo "ascii"
                echo "pwd " 
                echo "ls " $FILE
                echo "  " 
                echo "delete " $FILE
                echo "  " 
                echo "bye"
               ) |ftp -i -n -v $MAQUINA >> $NOMBRE_echo_ftp_FILE
               stty echo 
               echo "****************** Fin Ejecución ftp - Get  ***************"     >> $NOMBRE_echo_ftp_FILE
               echo "===============================================================" >> $NOMBRE_echo_ftp_FILE
               cat $NOMBRE_echo_ftp_FILE                                              >> $ARCHIVOLOGFTP
               rm -f $NOMBRE_echo_ftp_FILE
            fi
         fi
         #------------------------------------------------------------------------------------------------------
         #
		 
		
			
         #------------------------------------------------------------------------------------------------------
         if [ ${ftpEjecutadoOK} -eq 1 ]
         then
            out "    Paso 05: eliminar archivo :$FILE desde directorio ${RUTA_DAT_EN_PROCESO}"  | tee -a $ARCHIVOLOG
            cd ${RUTA_DAT_EN_PROCESO}
            rm -f $FILE 	
			
		    if [ -e ${FILE} ]
            then
               out "             Resultado : Ejecutado con errores - no se pudo eliminar el archivo (Warning 21)"   | tee -a $ARCHIVOLOG
               #error=21            
            else
               out "             Resultado : Ejecutado OK"   | tee -a $ARCHIVOLOG
            fi 
         fi 
         #------------------------------------------------------------------------------------------------------
      fi
      out ".................................................................................."  | tee -a $ARCHIVOLOG
      out "                                                                                  "  | tee -a $ARCHIVOLOG
      #
   done
fi
rm -f $NOMBRE_ARCH
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





