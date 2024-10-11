#!/bin/bash

LISTA_DATOS=$(echo {000..120..3})
TIEMPO_GFS="00z"
RESOLUCION="0p25"
HORA_INICIALIZACION="00"

entorno_modulo_descarga_gfs(){
    export RAIZ_SISTEMA="/LUSTRE/OPERATIVO"
    . $RAIZ_SISTEMA/scripts/bash/configuracion/fechas.sh
    . $RAIZ_SISTEMA/scripts/bash/configuracion/funciones.sh
    PATH_GFS_IOA="/DATOS4/Pronosticos/Salidas/GFS"
}

entorno_modulo_descarga_gfs

fecha_gfs(){
    # Generar el archivo de fechas automaticamente si es que asi se ha solicitado
    bash $RAIZ_SISTEMA/scripts/bash/configuracion/generar-fechas.sh $HORA_INICIALIZACION
    DATO=$ANIO_INI$MES_INI$DIA_INI"/"$HORA_INI # Fecha de los datos GFS
    DIRECTORIOFECHA=$ANIO_INI"_"$MES_INI"_"$DIA_INI"_"$HORA_INI
}

fecha_gfs

###################################
# Preparar el registro de eventos #
###################################

# Generaci'on del directorio de registro de eventos (log)
if ! [ -e $RAIZ_SISTEMA/registro_eventos/$FECHA ]
then
        # Crear el directorio
        mkdir $RAIZ_SISTEMA/registro_eventos/$FECHA
        chgrp g.operativo2 $RAIZ_SISTEMA/registro_eventos/$FECHA

        # Actualizar el registro de eventos
        actualizar_registro "-----INICIO DEL SISTEMA DE PRONOSTICO NUMERICO DE METEOROLOGIA, OLEAJE, MAREA DE TORMENTA-----"
        actualizar_registro "--------GRUPO INTERACCION OCEANO ATMOSFERA, CENTRO DE CIENCIAS DE LA ATMOSFERA, UNAM----------"
        actualizar_registro "Se ha creado el archivo de registro de eventos (log file) en "$RAIZ_SISTEMA/registro_eventos/$FECHA"."
        actualizar_registro "Datos de la ejecucion. ID del trabajo: "$SLURM_JOB_ID" Nombre del trabajo: "$SLURM_JOB_NAME
fi

# Ir al directorio donde se colocaran los datos descargados
cd $RAIZ_SISTEMA/entradas/WRF/dinamicas
# Borrar datos anteriores si es que los hay
rm -rf gfs.t00z*
rm -rf wget_log.txt
rm -rf tiempo_axel_*.txt

descargado=0
# Establecer un limite de tiempo para intentar la descarga (180 = 1/2 hora)
tiempo_limite=90

for i in $LISTA_DATOS
do

     # GFS - OPERATIVO IOA  - TO TEST
     /usr/bin/time --format="%E" --output=/LUSTRE/HOME/octavio/time.txt rsync -t kraken:$PATH_GFS_IOA/$DIRECTORIOFECHA/gfs.t$TIEMPO_GFS.pgrb2.$RESOLUCION.f$i .

     actualizar_registro "La descarga del archivo "gfs.t$TIEMPO_GFS.pgrb2.$RESOLUCION.f$i" tardo: "`cat /LUSTRE/HOME/operativo2/home/time.txt`" (h:m:s)"
     estado_descarga=$?
     # Verificar si la descarga fue exitosa y el archivo descargado es mayor a cero
        if [ $estado_descarga -eq 0 ] && [ -s gfs.t$TIEMPO_GFS.pgrb2.$RESOLUCION.f$i ]
        then
                # Modificar el valor de la bandera de control de la descarga
                descargado=1

                # Actualizar los registros de eventos
                actualizar_registro "Se ha descargado el archivo GFS "$i"."

        else
                # Hacer tiempo hasta el siguiente intento de descarga (10 segundos)
                sleep 10
        fi
        # Incrementar el contador de tiempo
        let contador_tiempo+=1

        if [ $contador_tiempo -eq $tiempo_limite ]
        then
        # Actualizar el registro de eventos
        actualizar_registro "***ERROR GRAVE*** No se ha podido descargar el archivo GFS "$i". Limite de tiempo alcanzado." tiempo.txt
        exit 1
        fi
done

actualizar_registro "***FIN DE LA DESCARGA DE DATOS GFS***"
                                                                                                                             88,1        Final

