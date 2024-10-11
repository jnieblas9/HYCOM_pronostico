#!/bin/bash

##############################
# Autor: Octavio Gomez Ramos #
#        Ovel Diaz Garcia    #
#        Esli Jurado         #
# Fecha: Junio de 2017       #
##############################

####################################################
#Definicion de las variables y funciones del script#
####################################################

# Cargar los argumentos del script en variables con nombres mas adecuados
DOMINIO=$1                                      # Dominio para el cual se va a ejecutar el modelo adcirc

RUTA_SISTEMA=$RAIZ_SISTEMA
# Cargar las variables de configuracion globales
source $RUTA_SISTEMA/scripts/bash/configuracion/variables_intel.sh
source $RUTA_SISTEMA/scripts/bash/configuracion/funciones.sh
source $RUTA_SISTEMA/scripts/bash/configuracion/fechas.sh

# Actualizar los registros de eventos
actualizar_registro "ADCIRC. ***INICIO DEL SCRIPT DE EJECUCION DEL MODELO PARA EL DOMINIO - "$DOMINIO" +++"


##########################################
#Etapa 0: Generar los archivos de entrada#
##########################################

# Hay que crear un directorio en /tmp para ejecutar el modelo
mkdir -p $RUTA_SISTEMA/modelos/ADCIRC/tmp/adcirc_$DOMINIO
# Cambiar los permisos
chmod -R 775 $RUTA_SISTEMA/modelos/ADCIRC/tmp/adcirc_$DOMINIO

# Copiar la malla correspondiente al dominio
cp $RUTA_SISTEMA/entradas/ADCIRC/configuracion/fort.14_$DOMINIO $RUTA_SISTEMA/modelos/ADCIRC/tmp/adcirc_$DOMINIO/fort.14
cp $RUTA_SISTEMA/entradas/ADCIRC/configuracion/fort.13_$DOMINIO $RUTA_SISTEMA/modelos/ADCIRC/tmp/adcirc_$DOMINIO/fort.13

# Generar el archivo de viento
SALIDA_WRF="wrfout_d01_"$ANIO_INI"-"$MES_INI"-"$DIA_INI"_"$HORA_INI".nc"
actualizar_registro "ADCIRC. Se usara la salida de WRF: "$RUTA_SISTEMA"/modelos/WRF/WRFV3/test/em_real/"$SALIDA_WRF
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/netcdf-4.1.3-gcc/lib/
actualizar_registro  "ADCIRC. Inicio de ejecucion de pewap para el dominio - "$DOMINIO
/usr/bin/time --format="%E" --output=tiempo.txt $RUTA_SISTEMA/modelos/ADCIRC/pewap/pewap4.exe -b $RUTA_SISTEMA/modelos/WRF/WRFV3/test/em_real/$SALIDA_WRF -p nodefile_$DOMINIO -o $RUTA_SISTEMA/modelos/ADCIRC/tmp/adcirc_$DOMINIO/fort.22

# Verificar si el archivo de viento se generó exitosamente
estado_programa=$?

actualizar_registro "ADCIRC. La ejecucion del pewap4.exe tardo:"`cat tiempo.txt`" (h:m:s)"
if [ $estado_programa -ne 0 ]; then
        # Actualizar los registros de eventos
        actualizar_registro "ADCIRC ERROR. No se pudo generar el archivo de vientos para el dominio - "$DOMINIO

        # Finalizar el script con error
        exit 1
fi

# Ejecutar tidefac
cd $RUTA_SISTEMA/modelos/ADCIRC/tide_fac/Factors
dias=10

./tidefac15.exe <<END_SCRIPT
$dias
$HORA_INI,$DIA_PRE,$MES_PRE,$ANIO_PRE
END_SCRIPT

# Mover la salida de tidefac
mv tidefac.15 $RUTA_SISTEMA/modelos/ADCIRC/tmp/adcirc_$DOMINIO/tidefac.15

# Cortar la salida del modelo para su ejecucion en paralelo
cd $RUTA_SISTEMA/modelos/ADCIRC/tmp/adcirc_$DOMINIO


####################################################
#Etapa 1: Hacer la primera simulacion. 1 dia previo#
####################################################

# Copiar el archivo de configuracion (fort.15)
cp $RUTA_SISTEMA"/entradas/ADCIRC/configuracion/s1_sinhs-fort.15_"$DOMINIO $RUTA_SISTEMA"/modelos/ADCIRC/tmp/adcirc_"$DOMINIO"/fort.15"

# Agregar los potenciales de marea generados por tidefac
sed -i '/TIDEFAC32L/ {
r tidefac.15
d
}' fort.15

#Cambiar la fecha del NCDATE

NCFECHA="${ANIO_PRE}-${MES_PRE}-${DIA_PRE} ${HORA_INI}:00:00"
actualizar_registro "ADCIRC. S1. Se cambia la fecha a: "$NCFECHA
sed "s/FECHA_ACTUAL/${NCFECHA}/g" fort.15 > fort.15.tmp && mv fort.15.tmp fort.15

# Ejecutar adcprep para dividir los datos de viento

$RUTA_SISTEMA/modelos/ADCIRC/adcirc-v52.30.13/work/adcprep --np $CORES --partmesh
/usr/bin/time --format="%E" --output=tiempo.txt $RUTA_SISTEMA/modelos/ADCIRC/adcirc-v52.30.13/work/adcprep --np $CORES --prepall
actualizar_registro "ADCIRC. S1. La ejecucion del segundo adcprep tardo: "`cat tiempo.txt`" (h:m:s)"

# Ejecutar el modelo adcirc en paralelo
actualizar_registro "ADCIRC. S1. Inicio de la ejecucion de padcirc para el dominio - "$DOMINIO
/usr/bin/time --format="%E" --output=tiempo.txt  mpiexec.hydra -launcher slurm -np $CORES $RUTA_SISTEMA/modelos/ADCIRC/adcirc-v52.30.13/work/padcirc

# Verificar si el modelo se ejecuto exitosamente
estado_modelo=$?

actualizar_registro "ADCIRC. S1. La ejecucion del padcirc tardo: "`cat tiempo.txt`" (h:m:s)"
if [ $estado_programa -ne 0 ]; then
        # Actualizar los registros de eventos
        actualizar_registro "ADCIRC. S1. ***ERROR*** No se pudo ejecutar correctamente el modelo para el dominio - "$DOMINIO

        # Finalizar el script con error
        exit 1
fi

# Mover el archivo fort.67 fuera de la carpetita
if [ -e $RUTA_SISTEMA/modelos/ADCIRC/tmp/adcirc_$DOMINIO/PE0000/fort.67 ]; then
        #Mover al directorio superior el fort.67
        mv $RUTA_SISTEMA/modelos/ADCIRC/tmp/adcirc_$DOMINIO/PE0000/fort.67 $RUTA_SISTEMA/modelos/ADCIRC/tmp/adcirc_$DOMINIO/fort.68
fi

#########################################################
#Etapa 2: Hacer la segunda simulacion. 5 dias pronostico#
#########################################################

# Copiar el archivo de configuracion (fort.15)
cp $RUTA_SISTEMA"/entradas/ADCIRC/configuracion/s2_conhs-fort.15_"$DOMINIO $RUTA_SISTEMA"/modelos/ADCIRC/tmp/adcirc_"$DOMINIO"/fort.15"

# Agregar los potenciales de marea generados por tidefac
sed -i '/TIDEFAC32L/ {
r tidefac.15
d
}' fort.15

#Cambiar la fecha del NCDATE

NCFECHA="${ANIO_PRE}-${MES_PRE}-${DIA_PRE} ${HORA_INI}:00:00"
actualizar_registro "ADCIRC. S2. Se cambia la fecha a: "$NCFECHA
sed "s/FECHA_ACTUAL/${NCFECHA}/g" fort.15 > fort.15.tmp && mv fort.15.tmp fort.15

# Ejecutar adcprep para dividir los datos de viento

#$RUTA_SISTEMA/modelos/ADCIRC/adcirc-v52.30.13/work/adcprep --np $CORES --partmesh
/usr/bin/time --format="%E" --output=tiempo.txt $RUTA_SISTEMA/modelos/ADCIRC/adcirc-v52.30.13/work/adcprep --np $CORES --prepall
actualizar_registro "ADCIRC. S2. La ejecucion del segundo adcprep tardo: "`cat tiempo.txt`" (h:m:s)"

# Si existe archivo de restart, partirlo tambien
if [ -e fort.68 ]; then

# Partir el fort.68 con adcprep
opcion=6
ihot=68

$RUTA_SISTEMA/modelos/ADCIRC/adcirc-v52.30.13/work/adcprep <<END_SCRIPT
$CORES
$opcion
$ihot
END_SCRIPT

fi

# Ejecutar el modelo adcirc en paralelo
actualizar_registro "ADCIRC. S2. Inicio de la ejecucion de padcirc para el dominio - "$DOMINIO
/usr/bin/time --format="%E" --output=tiempo.txt  mpiexec.hydra -launcher slurm -np $CORES $RUTA_SISTEMA/modelos/ADCIRC/adcirc-v52.30.13/work/padcirc

# Verificar si el modelo se ejecuto exitosamente
estado_modelo=$?

actualizar_registro "ADCIRC. S2. La ejecucion del padcirc tardo: "`cat tiempo.txt`" (h:m:s)"
if [ $estado_programa -ne 0 ]; then
        # Actualizar los registros de eventos
        actualizar_registro "ADCIRC. S2. ***ERROR*** No se pudo ejecutar correctamente el modelo para el dominio - "$DOMINIO

        # Finalizar el script con error
        exit 1
fi

chmod -R 775 $RUTA_SISTEMA/modelos/ADCIRC/tmp/adcirc_$DOMINIO

actualizar_registro "ADCIRC. Fin de la ejecucion de padcirc para el dominio - "$DOMINIO


