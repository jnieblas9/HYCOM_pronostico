#!/bin/bash

##############################


# Fecha: Julio de 2019       #
##############################

####################################################
#Definicion de las variables y funciones del script#
####################################################

# Cargar los argumentos del script en variables con nombres mas adecuados
DOMINIO=$1                                      # Dominio para el cual se va a ejecutar el modelo adcirc

RUTA_SISTEMA=$RAIZ_SISTEMA
# Cargar las variables de configuracion globales
source $RUTA_SISTEMA/scripts/bash/configuracion/variables_intel.sh
source $RUTA_SISTEMA/scripts/bash/configuracion/funciones_ovel.sh
source $RUTA_SISTEMA/scripts/bash/configuracion/fechas.sh
source $RUTA_SISTEMA/modelos/FVCOM/variables-fvcom-41
CORES=110
forecast="True"
hindcast="False"

# Actualizar los registros de eventos
actualizar_registro "FVCOM. ***INICIO DEL SCRIPT DE EJECUCION DEL MODELO PARA LA CONFIGURACION - "$DOMINIO" +++"

if [ $DOMINIO -eq 1 ]; then CASENAME="Sargazo04"; fi
if [ $DOMINIO -eq 2 ]; then CASENAME="GoMOp01"; fi
if [ $DOMINIO -eq 3 ]; then CASENAME="Sargazo05"; fi
if [ $DOMINIO -eq 4 ]; then CASENAME="GoMOp02"; fi

##########################################
#Etapa 0: Generar los archivos de entrada#

##########################################

ANIO_3d=`date -d "$ANIO_INI-$MES_INI-$DIA_INI +3 days" +%Y`
MES_3d=`date -d "$ANIO_INI-$MES_INI-$DIA_INI +3 days" +%m`
DIA_3d=`date -d "$ANIO_INI-$MES_INI-$DIA_INI +3 days" +%d`

# Hay que crear un directorio en /tmp para ejecutar el modelo
rm -rf $RUTA_SISTEMA/modelos/FVCOM/tmp/input_$DOMINIO $RUTA_SISTEMA/modelos/FVCOM/tmp/output_$DOMINIO $RUTA_SISTEMA/modelos/FVCOM/tmp/run_$DOMINIO

mkdir -p $RUTA_SISTEMA/modelos/FVCOM/tmp/input_$DOMINIO
mkdir -p $RUTA_SISTEMA/modelos/FVCOM/tmp/output_$DOMINIO
mkdir -p $RUTA_SISTEMA/modelos/FVCOM/tmp/run_$DOMINIO
# Cambiar los permisos
chmod -R 775 $RUTA_SISTEMA/modelos/FVCOM/tmp/input_$DOMINIO
chmod -R 775 $RUTA_SISTEMA/modelos/FVCOM/tmp/output_$DOMINIO
chmod -R 775 $RUTA_SISTEMA/modelos/FVCOM/tmp/run_$DOMINIO

# Copiar la malla correspondiente al dominio
cp $RUTA_SISTEMA/entradas/FVCOM/configuraciones/configuracion_$DOMINIO/${CASENAME}_* $RUTA_SISTEMA/modelos/FVCOM/tmp/input_$DOMINIO/

# Generar el archivo de viento
SALIDA_WRF="$RUTA_SISTEMA/modelos/WRF/WRFV3/test/em_real/wrfout_d01_"$ANIO_INI"-"$MES_INI"-"$DIA_INI"_"$HORA_INI".nc"
FVCOM_WIND=$RUTA_SISTEMA/modelos/FVCOM/tmp/input_$DOMINIO/${CASENAME}_wind.nc

if  [ -f $SALIDA_WRF ]; then
    actualizar_registro "FVCOM. Se usara la salida de WRF: "$RUTA_SISTEMA"/modelos/WRF/WRFV3/test/em_real/"$SALIDA_WRF
else
    case $MES_INI in
            "01")   CARPETA_MES="01_enero"
                    ;;
            "02")   CARPETA_MES="02_febrero"
                    ;;
            "03")   CARPETA_MES="03_marzo"
                    ;;
            "04")   CARPETA_MES="04_abril"
                    ;;
            "05")   CARPETA_MES="05_mayo"
                    ;;
            "06")   CARPETA_MES="06_junio"
                    ;;
            "07")   CARPETA_MES="07_julio"
                    ;;
            "08")   CARPETA_MES="08_agosto"
                    ;;
            "09")   CARPETA_MES="09_septiembre"
                    ;;
            "10")   CARPETA_MES="10_octubre"
                    ;;
            "11")   CARPETA_MES="11_noviembre"
                    ;;
            "12")   CARPETA_MES="12_diciembre"
                    ;;
    esac
    if [[ -f "$RAIZ_SISTEMA/EXTERNO-salidas/WRF/$ANIO_INI/$CARPETA_MES/wrfout_d01_"$ANIO_INI"-"$MES_INI"-"$DIA_INI"_"$HORA_INI".nc" ]]
    then
        ln -sf "$RAIZ_SISTEMA/EXTERNO-salidas/WRF/$ANIO_INI/$CARPETA_MES/wrfout_d01_"$ANIO_INI"-"$MES_INI"-"$DIA_INI"_"$HORA_INI".nc" $SALIDA_WRF
    else
        actualizar_registro "FVCOM. No existe el fichero de WRF: $RAIZ_SISTEMA/EXTERNO-salidas/WRF/$ANIO_INI/$CARPETA_MES/wrfout_d01_"$ANIO_INI"-"$MES_INI"-"$DIA_INI"_"$HORA_INI".nc"
        exit
    fi

fi

cd $RUTA_SISTEMA/scripts/matlab/FVCOM
actualizar_registro  "FVCOM. Inicio de ejecucion de WRF2FVCOM.m para la configuracion - "$DOMINIO
if [ $forecast = "True" ]; then
/usr/bin/time --format="%E" --output=tiempo.txt /usr/local/MATLAB/R2018a/bin/matlab -nojvm -nodesktop -r "WRF2FVCOM('$SALIDA_WRF','$FVCOM_WIND');quit;"

# Verificar si el archivo de viento se generó exitosamente
estado_programa=$?

actualizar_registro "FVCOM. La ejecucion de WRF2FVCOM.m tardo:"`cat tiempo.txt`" (h:m:s)"
if [ $estado_programa -ne 0 ]; then
        # Actualizar los registros de eventos
        actualizar_registro "FVCOM ERROR. No se pudo generar el archivo de vientos para la configuracion - "$DOMINIO
        # Finalizar el script con error
        exit 1
fi
fi

# Generar el archivo de marea en la frontera  (FALTA agregar el SSH a la zeta en la frontera... esto tiene que hacerse después)
StartDATE=$ANIO_INI"_"$MES_INI"_"$DIA_INI"_"$HORA_INI
EndDATE=$ANIO_3d"_"$MES_3d"_"$DIA_3d"_"$HORA_INI
FVCOM_TIDE=$RUTA_SISTEMA/modelos/FVCOM/tmp/input_$DOMINIO/${CASENAME}_elevtide.nc
cd $RUTA_SISTEMA/scripts/matlab/FVCOM
if [ $forecast = "True" ]; then
/usr/bin/time --format="%E" --output=tiempo.txt /usr/local/MATLAB/R2018a/bin/matlab -nojvm -nodesktop -r "FVCOM_elevation('$StartDATE','$EndDATE','$DOMINIO','$CASENAME','$FVCOM_TIDE');quit;"

# Verificar si el archivo de viento se generó exitosamente
estado_programa=$?

actualizar_registro "FVCOM. La ejecucion de FVCOM_elevation.m tardo:"`cat tiempo.txt`" (h:m:s)"
if [ $estado_programa -ne 0 ]; then
        # Actualizar los registros de eventos
        actualizar_registro "FVCOM ERROR. No se pudo generar el archivo de mareas para la configuracion - "$DOMINIO

        # Finalizar el script con error
        exit 1
fi
fi

#Fichero de HYCOM_forecast para condiciones de frontera

ANIO_2d=`date -d "$ANIO_INI-$MES_INI-$DIA_INI -2 days" +%Y`
MES_2d=`date -d "$ANIO_INI-$MES_INI-$DIA_INI -2 days" +%m`
DIA_2d=`date -d "$ANIO_INI-$MES_INI-$DIA_INI -2 days" +%d`

if [ $forecast = "True" ]; then

        cd $RAIZ_SISTEMA/modelos/FVCOM/HYCOM/HYCOM_forecast

#         rm -f GLBv*
        find -type f -size 0  -name "hycom*" -delete

        /usr/bin/time --format="%E" --output=time.txt bash -x ../ncss_expt93.0_forecast.sh $ANIO_2d $MES_2d $DIA_2d
        ejecucion_script=$?

        actualizar_registro "La ejecucion del modulo de descarga de datos HYCOM forecast en total tardo: "`cat time.txt`" (h:m:s)"

        if [ $ejecucion_script -ne 0 ]
        then
            actualizar_registro "FVCOM. HYCOM. ERROR!!! en la descarga de los datos para forecast."
                exit 1
        fi
fi

# Generar el archivo de forzamiento de HYCOM en la frontera  
StartDATE=$ANIO_INI"_"$MES_INI"_"$DIA_INI"_"$HORA_INI
EndDATE=$ANIO_3d"_"$MES_3d"_"$DIA_3d"_"$HORA_INI
cd $RUTA_SISTEMA/scripts/matlab/FVCOM
if [ $forecast = "True" ]; then
/usr/bin/time --format="%E" --output=tiempo.txt /usr/local/MATLAB/R2018a/bin/matlab -nodesktop -r "FVCOM_HYCOM_forecast('$StartDATE','$EndDATE','$DOMINIO','$CASENAME');quit;"
# Verificar si el archivo de viento se generó exitosamente
estado_programa=$?

actualizar_registro "FVCOM. La ejecucion de FVCOM_HYCOM_forecast.m para forecast tardo: "`cat tiempo.txt`" (h:m:s)"
if [ $estado_programa -ne 0 ]; then
        # Actualizar los registros de eventos
        actualizar_registro "FVCOM ERROR. No se pudo generar el archivo de forzamiento de HYCOM forecast para la configuracion - 0"
        # Finalizar el script con error
        exit 1
fi
fi

#Fichero de condiciones iniciales
ANIO_m3d=`date -d "$ANIO_INI-$MES_INI-$DIA_INI -3 days" +%Y`
MES_m3d=`date -d "$ANIO_INI-$MES_INI-$DIA_INI -3 days" +%m`
DIA_m3d=`date -d "$ANIO_INI-$MES_INI-$DIA_INI -3 days" +%d`

ANIO_m2d=`date -d "$ANIO_INI-$MES_INI-$DIA_INI -2 days" +%Y`
MES_m2d=`date -d "$ANIO_INI-$MES_INI-$DIA_INI -2 days" +%m`
DIA_m2d=`date -d "$ANIO_INI-$MES_INI-$DIA_INI -2 days" +%d`

ANIO_m1d=`date -d "$ANIO_INI-$MES_INI-$DIA_INI -1 days" +%Y`
MES_m1d=`date -d "$ANIO_INI-$MES_INI-$DIA_INI -1 days" +%m`
DIA_m1d=`date -d "$ANIO_INI-$MES_INI-$DIA_INI -1 days" +%d`

# IF Verificar si la corrida del día anterior está y existe el restart de las 24 horas.

if [ -e $RUTA_SISTEMA/EXTERNO-salidas/FVCOM/${ANIO_m1d}_${MES_m1d}_${DIA_m1d}_$HORA_INI/salidas/configuracion_$DOMINIO/${CASENAME}_restart_0002.nc ]
then
    cp $RUTA_SISTEMA/EXTERNO-salidas/FVCOM/${ANIO_m1d}_${MES_m1d}_${DIA_m1d}_$HORA_INI/salidas/configuracion_$DOMINIO/${CASENAME}_restart_0002.nc $RUTA_SISTEMA/modelos/FVCOM/tmp/input_${DOMINIO}/${CASENAME}_restart_0001.nc
    actualizar_registro "FVCOM. Para la ejecucion de FVCOM Forecast se utilizara el fichero de restart del dia ${ANIO_m1d}_${MES_m1d}_${DIA_m1d}_$HORA_INI"
else
    actualizar_registro "FVCOM. Para la ejecucion de FVCOM Forecast no se encontro el fichero de restart del dia ${ANIO_m1d}_${MES_m1d}_${DIA_m1d}_$HORA_INI"
    if [ -e $RUTA_SISTEMA/EXTERNO-salidas/FVCOM/${ANIO_m2d}_${MES_m2d}_${DIA_m2d}_$HORA_INI/salidas/configuracion_$DOMINIO/${CASENAME}_restart_0003.nc ]
    then
        cp $RUTA_SISTEMA/EXTERNO-salidas/FVCOM/${ANIO_m2d}_${MES_m2d}_${DIA_m2d}_$HORA_INI/salidas/configuracion_$DOMINIO/${CASENAME}_restart_0003.nc $RUTA_SISTEMA/modelos/FVCOM/tmp/input_${DOMINIO}/${CASENAME}_restart_0001.nc
        actualizar_registro "FVCOM. Para la ejecucion de FVCOM Forecast se utilizara el fichero de restart del dia ${ANIO_m2d}_${MES_m2d}_${DIA_m2d}_$HORA_INI"
    else
        actualizar_registro "FVCOM. Para la ejecucion de FVCOM Forecast no se encontro el fichero de restart del dia ${ANIO_m2d}_${MES_m2d}_${DIA_m2d}_$HORA_INI"
        if [ -e $RUTA_SISTEMA/EXTERNO-salidas/FVCOM/${ANIO_m3d}_${MES_m3d}_${DIA_m3d}_$HORA_INI/salidas/configuracion_$DOMINIO/${CASENAME}_restart_0004.nc ]
        then
            cp $RUTA_SISTEMA/EXTERNO-salidas/FVCOM/${ANIO_m3d}_${MES_m3d}_${DIA_m3d}_$HORA_INI/salidas/configuracion_$DOMINIO/${CASENAME}_restart_0004.nc $RUTA_SISTEMA/modelos/FVCOM/tmp/input_${DOMINIO}/${CASENAME}_restart_0001.nc
            actualizar_registro "FVCOM. Para la ejecucion de FVCOM Forecast se utilizara el fichero de restart del dia ${ANIO_m3d}_${MES_m3d}_${DIA_m3d}_$HORA_INI"
        else
            actualizar_registro "FVCOM. Para la ejecucion de FVCOM Forecast no se encontro el fichero de restart del dia ${ANIO_m3d}_${MES_m3d}_${DIA_m3d}_$HORA_INI"
            actualizar_registro "FVCOM. Se necesita hacer una simulacion de Hindcast/Spin-up de 15 dias"
            hindcast="True"
        fi
    fi
fi

#     ELSEIF Si no, buscar la de 2 días antes y el restart de 48 horas.
#         ELSEIF Si no, buscar la de 3 días antes y el restart de 72 horas. 
#             ELSEIF Si no, correr el hindcast de 15 días.

# HYCOM hindcast. 

if [ $hindcast = "True" ]; then

ANIO_15d=`date -d "$ANIO_INI-$MES_INI-$DIA_INI -15 days" +%Y`
MES_15d=`date -d "$ANIO_INI-$MES_INI-$DIA_INI -15 days" +%m`
DIA_15d=`date -d "$ANIO_INI-$MES_INI-$DIA_INI -15 days" +%d`

# Ficheros para corrida de hindcast

# Hay que crear un directorio en /tmp para ejecutar el modelo
rm -rf $RUTA_SISTEMA/modelos/FVCOM/tmp/input_0 $RUTA_SISTEMA/modelos/FVCOM/tmp/output_0 $RUTA_SISTEMA/modelos/FVCOM/tmp/run_0

mkdir -p $RUTA_SISTEMA/modelos/FVCOM/tmp/input_0
mkdir -p $RUTA_SISTEMA/modelos/FVCOM/tmp/output_0
mkdir -p $RUTA_SISTEMA/modelos/FVCOM/tmp/run_0
# Cambiar los permisos
chmod -R 775 $RUTA_SISTEMA/modelos/FVCOM/tmp/input_0
chmod -R 775 $RUTA_SISTEMA/modelos/FVCOM/tmp/output_0
chmod -R 775 $RUTA_SISTEMA/modelos/FVCOM/tmp/run_0

if [ $hindcast = "True" ]; then
        cd $RAIZ_SISTEMA/modelos/FVCOM/HYCOM/HYCOM_hindcast

#         rm -f GLBv*

        /usr/bin/time --format="%E" --output=time.txt bash -x ../ncss_expt93.0_hindcast.sh $ANIO_15d $MES_15d $DIA_15d
        ejecucion_script=$?

        actualizar_registro "La ejecucion del modulo de descarga de datos HYCOM hindcast en total tardo: "`cat time.txt`" (h:m:s)"

        if [ $ejecucion_script -ne 0 ]
        then
            actualizar_registro "FVCOM. HYCOM. ERROR!!! en la descarga de los datos para hindcast."
                exit 1
        fi

#         find -type l -delete
#         
#         cp GLBv* /LUSTRE/OPERATIVO/entradas/FVCOM/HYCOM_hindcast/

#         bash ../procesar_netcdf_time_dimension.sh
fi


# Copiar la malla correspondiente al dominio
cp $RUTA_SISTEMA/entradas/FVCOM/configuraciones/configuracion_$DOMINIO/${CASENAME}_* $RUTA_SISTEMA/modelos/FVCOM/tmp/input_0/
# Preparar el archivo run.mnl y copiarlo a la carpeta run
sed -e s:aaaa:$ANIO_15d:g -e s:bbbb:$MES_15d:g -e s:cccc:$DIA_15d:g -e s:dddd:$HORA_INI:g -e s:eeee:$ANIO_INI:g -e s:ffff:$MES_INI:g -e s:gggg:$DIA_INI:g $RUTA_SISTEMA/entradas/FVCOM/configuraciones/configuracion_$DOMINIO/${CASENAME}_CI_run.nml > $RUTA_SISTEMA/modelos/FVCOM/tmp/run_0/${CASENAME}_run.nml
# cp $RUTA_SISTEMA/entradas/FVCOM/configuraciones/configuracion_$DOMINIO/${CASENAME}_CI_run.nml $RUTA_SISTEMA/modelos/FVCOM/tmp/run_0/${CASENAME}_tmp_run.nml

# Generar el archivo de forzamiento de HYCOM en la frontera  
StartDATE=$ANIO_15d"_"$MES_15d"_"$DIA_15d"_"$HORA_INI
EndDATE=$ANIO_INI"_"$MES_INI"_"$DIA_INI"_"$HORA_INI
cd $RUTA_SISTEMA/scripts/matlab/FVCOM
if [ $hindcast = "True" ]; then
/usr/bin/time --format="%E" --output=tiempo.txt /usr/local/MATLAB/R2018a/bin/matlab -nodesktop -r "FVCOM_HYCOM_hindcast('$StartDATE','$EndDATE','$DOMINIO','$CASENAME');quit;"

# Verificar si el archivo de viento se generó exitosamente
estado_programa=$?

actualizar_registro "FVCOM. La ejecucion de FVCOM_HYCOM_hindcast.m para hindcast tardo: "`cat tiempo.txt`" (h:m:s)"
if [ $estado_programa -ne 0 ]; then
        # Actualizar los registros de eventos
        actualizar_registro "FVCOM ERROR. No se pudo generar el archivo de forzamiento de HYCOM hindcast para la configuracion - 0"
        # Finalizar el script con error
        exit 1
fi
fi

# exit

# Generar el archivo de marea en la frontera  
StartDATE=$ANIO_15d"_"$MES_15d"_"$DIA_15d"_"$HORA_INI
EndDATE=$ANIO_INI"_"$MES_INI"_"$DIA_INI"_"$HORA_INI
FVCOM_TIDE=$RUTA_SISTEMA/modelos/FVCOM/tmp/input_0/${CASENAME}_elevtide.nc
cd $RUTA_SISTEMA/scripts/matlab/FVCOM
if [ $hindcast = "True" ]; then
/usr/bin/time --format="%E" --output=tiempo.txt /usr/local/MATLAB/R2018a/bin/matlab -nodesktop -r "FVCOM_elevation('$StartDATE','$EndDATE','$DOMINIO','$CASENAME','$FVCOM_TIDE');quit;"

# Verificar si el archivo de viento se generó exitosamente
estado_programa=$?

actualizar_registro "FVCOM. La ejecucion de FVCOM_elevation.m para hindcast tardo: "`cat tiempo.txt`" (h:m:s)"
if [ $estado_programa -ne 0 ]; then
        # Actualizar los registros de eventos
        actualizar_registro "FVCOM ERROR. No se pudo generar el archivo de mareas hindcast para la configuracion - 0"

        # Finalizar el script con error
        exit 1
fi
fi

if [ $hindcast = "True" ]; then
cd $RUTA_SISTEMA/modelos/FVCOM/tmp/run_0/
# /usr/bin/time --format="%E" --output=tiempo.txt  mpiexec.hydra -bootstrap slurm -np 8 $RUTA_SISTEMA/modelos/FVCOM/FVCOM41/FVCOM_source/fvcom --casename=$CASENAME --LOGFILE=log_hindcast15d.txt 
/usr/bin/time --format="%E" --output=tiempo.txt  mpiexec.hydra -np 8 $RUTA_SISTEMA/modelos/FVCOM/FVCOM41/FVCOM_source/fvcom --casename=$CASENAME --LOGFILE=log_hindcast15d.txt


# Verificar si el modelo corrio exitosamente
estado_programa=$?

actualizar_registro "FVCOM. La ejecucion de FVCOM CI hindcast tardo:"`cat tiempo.txt`" (h:m:s)"
if [ $estado_programa -ne 0 ]; then
        # Actualizar los registros de eventos
        actualizar_registro "FVCOM ERROR. No se pudo generar el archivo de CI hindcast para la configuracion - 0"

        # Finalizar el script con error
        exit 1
fi

cp $RUTA_SISTEMA/modelos/FVCOM/tmp/output_0/${CASENAME}_restart_0001.nc $RUTA_SISTEMA/modelos/FVCOM/tmp/input_0/${CASENAME}_restart_0001.nc
fi

# Generar el archivo de Condicion Inicial con actualizacion de datos de HYCOM 
StartDATE=$ANIO_15d"_"$MES_15d"_"$DIA_15d"_"$HORA_INI
cd $RUTA_SISTEMA/scripts/matlab/FVCOM
if [ $hindcast = "True" ]; then
/usr/bin/time --format="%E" --output=tiempo.txt /usr/local/MATLAB/R2018a/bin/matlab -nodesktop -r "FVCOM_HYCOM_hindcast_CI('$StartDATE','$DOMINIO','$CASENAME');quit;"


# Verificar si el archivo de Condicion Inicial se genero exitosamente
estado_programa=$?

actualizar_registro "FVCOM. La ejecucion de FVCOM_HYCOM_hindcast_CI.m para hindcast tardo:"`cat tiempo.txt`" (h:m:s)"
if [ $estado_programa -ne 0 ]; then
        # Actualizar los registros de eventos
        actualizar_registro "FVCOM ERROR. No se pudo generar el archivo de CI para HYCOM hindcast para la configuracion - 0"
        # Finalizar el script con error
        exit 1
fi

# exit
#fi

# Preparar el archivo run.mnl y copiarlo a la carpeta run
sed -e s:aaaa:$ANIO_15d:g -e s:bbbb:$MES_15d:g -e s:cccc:$DIA_15d:g -e s:dddd:$HORA_INI:g -e s:eeee:$ANIO_INI:g -e s:ffff:$MES_INI:g -e s:gggg:$DIA_INI:g $RUTA_SISTEMA/entradas/FVCOM/configuraciones/configuracion_$DOMINIO/${CASENAME}_hindcast_run.nml > $RUTA_SISTEMA/modelos/FVCOM/tmp/run_0/${CASENAME}_run.nml

cd $RUTA_SISTEMA/modelos/FVCOM/tmp/run_0/
/usr/bin/time --format="%E" --output=tiempo.txt  mpiexec.hydra -bootstrap slurm -np $CORES $RUTA_SISTEMA/modelos/FVCOM/FVCOM41/FVCOM_source/fvcom --casename=$CASENAME --LOGFILE=log_hindcast15d.txt
# /usr/bin/time --format="%E" --output=tiempo.txt  mpiexec.hydra -np $CORES $RUTA_SISTEMA/modelos/FVCOM/FVCOM41/FVCOM_source/fvcom --casename=$CASENAME --LOGFILE=log_hindcast15d.txt 


# Verificar si el modelo corrio exitosamente
estado_programa=$?

actualizar_registro "FVCOM. La ejecucion de FVCOM hindcast 15d tardo:"`cat tiempo.txt`" (h:m:s)"
if [ $estado_programa -ne 0 ]; then
        # Actualizar los registros de eventos
        actualizar_registro "FVCOM ERROR. Al ejecutar el hindcast 15d para la configuracion - $DOMINIO"

        # Finalizar el script con error
        exit 1
fi

cp $RUTA_SISTEMA/modelos/FVCOM/tmp/output_0/${CASENAME}_restart_0016.nc $RUTA_SISTEMA/modelos/FVCOM/tmp/input_$DOMINIO/${CASENAME}_restart_0001.nc

fi

fi

# exit

# EJECUTAR EL FORECAST

sed -e s:aaaa:$ANIO_INI:g -e s:bbbb:$MES_INI:g -e s:cccc:$DIA_INI:g -e s:dddd:$HORA_INI:g -e s:eeee:$ANIO_3d:g -e s:ffff:$MES_3d:g -e s:gggg:$DIA_3d:g $RUTA_SISTEMA/entradas/FVCOM/configuraciones/configuracion_$DOMINIO/${CASENAME}_forecast_run.nml > $RUTA_SISTEMA/modelos/FVCOM/tmp/run_$DOMINIO/${CASENAME}_run.nml

cd $RUTA_SISTEMA/modelos/FVCOM/tmp/run_$DOMINIO/
/usr/bin/time --format="%E" --output=tiempo.txt  mpiexec.hydra -bootstrap slurm -np $CORES $RUTA_SISTEMA/modelos/FVCOM/FVCOM41/FVCOM_source/fvcom --casename=$CASENAME --LOGFILE=log_forecast3d.txt
# /usr/bin/time --format="%E" --output=tiempo.txt  mpiexec.hydra -np $CORES $RUTA_SISTEMA/modelos/FVCOM/FVCOM41/FVCOM_source/fvcom --casename=$CASENAME --LOGFILE=log_forecast3d.txt 


# Verificar si el modelo corrio exitosamente
estado_programa=$?

actualizar_registro "FVCOM. La ejecucion de FVCOM forecast de 72h tardo:"`cat tiempo.txt`" (h:m:s)"
if [ $estado_programa -ne 0 ]; then
        # Actualizar los registros de eventos
        actualizar_registro "FVCOM ERROR. Al ejecutar el forecast de 72h para la configuracion - "$DOMINIO

        # Finalizar el script con error
        exit 1
fi

chmod -R 775 $RUTA_SISTEMA/modelos/FVCOM/tmp/output_$DOMINIO

actualizar_registro "FVCOM. Fin de la ejecucion de FVCOM para la configuracion - "$DOMINIO


