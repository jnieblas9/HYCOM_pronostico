#!/bin/bash

##############################


# Fecha: Julio de 2019       #
##############################

#############################################################
#Etapa 0: Definición de las variables y funciones del script#
#############################################################

# Cargar las variables de configuracion globales
source $RAIZ_SISTEMA/scripts/bash/configuracion/fechas.sh
source $RAIZ_SISTEMA/scripts/bash/configuracion/funciones_ovel.sh
source $RAIZ_SISTEMA/scripts/bash/configuracion/variables_intel.sh
# CORES=24

actualizar_registro "FVCOM. Inicio de modulo_ejecuta_fvcom"

#######################################
#Etapa 1: Ejecucion del modelo FVCOM #
#######################################

for DOMINIO in 3 2 1 4  #gom  pom
do
        actualizar_registro "FVCOM. Inicia script de ejecucion para la configuracion - "$DOMINIO

        # Ejecutar el modelo adcirc para el dominio correspondiente
        cd $RAIZ_SISTEMA/scripts/bash/ejecuta_fvcom
        bash -x ./ejecutar_fvcom.sh $DOMINIO
#        ./ejecutar_adcirc_pgi.sh $DOMINIO

        # Recoger el estado de la ejecución del script anterior
        estado_script=$?
        actualizar_registro "FVCOM. Fin del script de ejecucion para la configuracion - "$DOMINIO
        if [ $estado_script -eq 0 ]; then

                actualizar_registro "FVCOM. Inicia script de graficado para la configuracion - "$DOMINIO

                # Proceder a graficar las salidas
                cd $RAIZ_SISTEMA/scripts/bash/genera_graficas/fvcom
                /usr/bin/time --format="%E" --output=tiempo.txt bash -x ./graficar_marea.sh $DOMINIO

                # Recoger el estado de la ejecución del script anterior
                estado_script=$?

                actualizar_registro "FVCOM. La ejecucion del graficado usando NCL para la configuracion "$DOMINIO"  tardo: "`cat tiempo.txt`" (h:m:s)"
                # Si no hubo error, proceder a subir las graficas
                if [ $estado_script -eq 0 ]; then
                        # Proceder a subir las graficas
                        echo "SE DEBEN SUBIR LAS GRAFICAS A UNA BASE DE DATOS DE SQL?????"
#                         cd $RAIZ_SISTEMA/scripts/bash/subir_graficas/fvcom
                       # ./subir_marea.sh $HORA $ACT_REG_REM $DOMINIO
                else
                        # Notificar al registro de eventos
                        actualizar_registro "FVCOM ERROR.  No se pudieron crear las graficas de marea de tormenta del modelo adcirc para la configuracion -"$DOMINIO
                fi

                actualizar_registro "FVCOM. Fin del script de graficado para la configuracion - "$DOMINIO

#Respaldo de datos 
                actualizar_registro "FVCOM. Inicio de modulo de respaldo de datos"
                /usr/bin/time --format="%E" --output=tiempo.txt bash -x $RAIZ_SISTEMA/scripts/bash/respaldar_datos/respaldar_datos_fvcom.sh $DOMINIO
                actualizar_registro "FVCOM. La ejecucion del modulo de respaldo tardo: "`cat tiempo.txt`" (h:m:s)"
                actualizar_registro "FVCOM. Fin del modulo_ejecuta_fvcom"


        else
                # Notificar al registro de eventos
                actualizar_registro "FVCOM ERROR. El modelo no se ejecuto correctamente para la configuracion -"$DOMINIO
        fi
done

#Respaldo de datos y graficos
#actualizar_registro "ADCIRC. Inicio de modulo de respaldo de datos"
#/usr/bin/time --format="%E" --output=tiempo.txt bash -x $RAIZ_SISTEMA/scripts/bash/respaldar_datos/respaldar_datos_adcirc.sh  
#actualizar_registro "ADCIRC. La ejecucion del modulo de respaldo tardo: "`cat tiempo.txt`" (h:m:s)"
#actualizar_registro "ADCIRC. Fin del modulo_ejecuta_adcirc"

# Quitar modulos de intel
#module unload mpi/intel
#module unload compiladores/intel
                                     

