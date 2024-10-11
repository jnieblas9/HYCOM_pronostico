#!/bin/bash
# DESCARGA FICHEROS GFS16.0 UNICAMENTE PARA MODELO WWIIII

LISTA_DATOS=$(echo {000..120..3})
TIEMPO_GFS="00z"
RESOLUCION="0p25"
HORA_INICIALIZACION="00"

entorno_modulo_descarga_gfs(){
    export RAIZ_SISTEMA="/LUSTRE/OPERATIVO"
    . $RAIZ_SISTEMA/scripts/bash/configuracion/fechas.sh
    . $RAIZ_SISTEMA/scripts/bash/configuracion/actualiza.sh
}

entorno_modulo_descarga_gfs

fecha_gfs(){
    # Generar el archivo de fechas automaticamente si es que asi se ha solicitado
    bash $RAIZ_SISTEMA/scripts/bash/configuracion/generar-fechas.sh $HORA_INICIALIZACION
    DATO=$ANIO_INI$MES_INI$DIA_INI"/"$HORA_INI # Fecha de los datos GFS
}

fecha_gfs

###################################
# Preparar el registro de eventos #
###################################

# Generaci'on del directorio de registro de eventos (log)
if ! [ -e $RAIZ_SISTEMA/registro_eventos_wwiii/$FECHA ]
then
        # Crear el directorio
        mkdir $RAIZ_SISTEMA/registro_eventos_wwiii/$FECHA
        chgrp g.operativo $RAIZ_SISTEMA/registro_eventos_wwiii/$FECHA

        # Actualizar el registro de eventos
        actualizar_registro "-----INICIO DEL SISTEMA DE PRONOSTICO NUMERICO DE METEOROLOGIA, OLEAJE, MAREA DE TORMENTA-----"
        actualizar_registro "--------GRUPO INTERACCION OCEANO ATMOSFERA, CENTRO DE CIENCIAS DE LA ATMOSFERA, UNAM----------"
        actualizar_registro "Se ha creado el archivo de registro de eventos (log file) en "$RAIZ_SISTEMA/registro_eventos_wwiii/$FECHA"."
fi

URL_GFS1="ftp://ftp.ncep.noaa.gov/pub/data/nccf/com/gfs/prod"
URL_GFS2="ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod"
URL_GFS3="https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod"
URL_GFS4="ftp://polar.ncep.noaa.gov/waves/GFS-Wave/gfs.20210118/00/wave/gridded/"gfswave.t$TIEMPO_GFS.global.$RESOLUCION.f$i.grib2

# Ir al directorio donde se colocaran los datos descargados
cd $RAIZ_SISTEMA/entradas/WRF/dinamicas_wave

# Borrar datos anteriores si es que los hay
rm -rf gfswave.t00z*
rm -rf tiempo*.txt

descargado=0
# Establecer un limite de tiempo para intentar la descarga (180 = 1/2 hora)
tiempo_limite=90

for i in $LISTA_DATOS
do

     # Updated FTP URL GFSV16
     # FTP URL PROD GFSV16 
     /usr/bin/time --format="%E" --output=tiempo.txt wget -q ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.$DATO/wave/gridded/gfswave.t$TIEMPO_GFS.global.$RESOLUCION.f$i.grib2

     actualizar_registro "La descarga del archivo "gfswave.t$TIEMPO_GFS.global.$RESOLUCION.f$i.grib2" tardo: "`cat tiempo.txt`" (h:m:s)"
     estado_descarga=$?

     # Verificar si la descarga fue exitosa y el archivo descargado es mayor a cero
        if [ $estado_descarga -eq 0 ] && [ -s gfswave.t$TIEMPO_GFS.global.$RESOLUCION.f$i.grib2 ]
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

rm -f tiempo.txt
actualizar_registro "***FIN DE LA DESCARGA DE DATOS GFS***"

echo $? > /tmp/gfswave.downloaded.txt
ls $RAIZ_SISTEMA/entradas/WRF/dinamicas_wave/gfswave.t00z.global.0p25.* | wc -l >> /tmp/gfswave.downloaded.txt
du -csh $RAIZ_SISTEMA/entradas/WRF/dinamicas_wave >> /tmp/gfswave.downloaded.txt
/bin/mail -s "GFS-WWIII_Operativo CCA" poropeza@atmosfera.unam.mx < /tmp/gfswave.downloaded.txt
~                                                                                                                          
