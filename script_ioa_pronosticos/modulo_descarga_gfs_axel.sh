#!/bin/bash

#################################

# Fecha: Septiebre de 2017      #
# Pavel. Octubre 2019           #
# Pavel. Marzo, 2021 GFSv16     #
#################################

# Modulo que descarga los datos GFS para el modelo WRF en el caso de que las fechas sean generadas automaticamente

# Parametros del script:
# $1: resolución de los datos GFS a descargar
#       1:   descargar datos de un grado
#       .5:  descargar datos de medio grado
#       .25: descargar datos de un cuarto de grado
# Cargar las variables y funciones del sistema
#

entorno_modulo_descarga_gfs(){
    export RAIZ_SISTEMA="/LUSTRE/OPERATIVO"
    export PATH=$RAIZ_SISTEMA/bin:$PATH # Carga el acelerador
    . $RAIZ_SISTEMA/scripts/bash/configuracion/fechas.sh
    . $RAIZ_SISTEMA/scripts/bash/configuracion/funciones.sh
    # Ir al directorio donde se colocaran los datos descargados
    cd $RAIZ_SISTEMA/entradas/WRF/dinamicas
    # FTP URL 
    URL_GFS1="ftp://ftp.ncep.noaa.gov/pub/data/nccf/com/gfs/prod"
    URL_GFS2="ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod"
    URL_GFS3="https://nomads.ncep.noaa.gov/pub/data/nccf/com/gfs/prod"
}

entorno_modulo_descarga_gfs

if [[ ${?} -eq 0 ]]
then
resolucion_gfs(){
# Establecer un valor por defecto
    if [ -z ${1+x} ]; then RESOLUCION="0p25"; else RESOLUCION=$1; fi

    # Establecer la resolucion de los datos a descargar
    case "$1" in
            "1") RESOLUCION=1p00
            ;;

            ".5") RESOLUCION=0p50
            ;;

            ".25") RESOLUCION=0p25
            ;;
    esac
}
resolucion_gfs
else
    echo "Could not load configuration"
    exit 1
fi

if [[ ${?} -eq 0 ]]
then
    fecha_gfs(){
        DATO=$ANIO_INI$MES_INI$DIA_INI"/"$HORA_INI              # Fecha de los datos GFS
        TIEMPO_GFS=$HORA_INI"z"                                 # Tiempo de los datos GFS
    }

    fecha_gfs
    # Borrar datos anteriores si es que los hay
    borrar_anteriores(){
        rm -rf gfs.*
        rm -rf tiempo.txt
    }

    borrar_anteriores
fi

if [[ ${?} -eq 0 ]]
then
    gfs_descarga(){
        # Lista de datos a descargar
        #LISTA_DATOS="000 003 006 009 012 015 018 021 024 027 030 033 036 039 042 045 048 051 054  
        #             057 060 063 066 069 072 075 078 081 084 087 090 093 096 099 102 105 108 111 114 117 120"
        LISTA_DATOS=$(echo {000..120..3})

        # Descargar los datos de LISTA_DATOS
        for i in $LISTA_DATOS
        do
            # Crear una bandera de control de la descarga
            descargado=0
            #
            # Establecer un limite de tiempo para intentar la descarga (180 = 1/2 hora)
            tiempo_limite=90
            #
            # Inicializar un contador para el control de tiempo
            contador_tiempo=0
            actualizar_registro "Se va a iniciar con la descarga del archivo GFS "$i"."
            #
            # Intentar descargar el archivo hasta lograrlo o hasta que haya transcurrido el tiempo limite
            while [ $descargado -ne 1 ] && [ $contador_tiempo -lt $tiempo_limite ]
                  do
            # Intentar descargar el archivo y almacenar el registro de eventos
                      # FTP URL GFSV16 (PROD)
                      #/usr/bin/time --format="%E" --output=tiempo.txt axel -n 8 -q ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.$DATO/atmos/gfs.t$TIEMPO_GFS.pgrb2.$RESOLUCION.f$i
                      # TESTING FTP URL
                      /usr/bin/time --format="%E" --output=tiempo.txt axel -n 8 -q $URL_GFS3/gfs.$DATO/atmos/gfs.t$TIEMPO_GFS.pgrb2.$RESOLUCION.f$i
                      # URL GFS BEFORE GFSV16
                      #/usr/bin/time --format="%E" --output=tiempo.txt axel -n 8 -q ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.$DATO/gfs.t$TIEMPO_GFS.pgrb2.$RESOLUCION.f$i
                      actualizar_registro "La descarga del archivo "gfs.t$TIEMPO_GFS.pgrb2.$RESOLUCION.f$i" tardo: "`cat tiempo.txt`" (h:m:s)"
                      # Almacenar en una variable el estado de salida de la descarga
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
                  done
                if [ $contador_tiempo -eq $tiempo_limite ]
                then
                # Actualizar el registro de eventos
                    actualizar_registro "***ERROR GRAVE*** No se ha podido descargar el archivo GFS "$i". Limite de tiempo alcanzado."
                    exit 1
                fi
        done
}

fi

# Actualizar el registro de eventos
actualizar_registro "***INICIO DEL MODULO DE DESCARGA DE DATOS GFS***"
gfs_descarga
actualizar_registro "***FIN DEL MODULO DE DESCARGA DE DATOS GFS***"
~                                                                   
