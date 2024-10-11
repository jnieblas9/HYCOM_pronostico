#!/bin/bash
#SBATCH -J OP_HYCOM                     # Nombre del trabajo
#SBATCH -p cigom                    # Cola id, operativo o cigom
#SBATCH -w node11                       # Nodo en el que se correra
#SBATCH -N 1                            # Numero de nodos
#SBATCH --ntasks-per-node 24            # Numero de tareas por nodo
#SBATCH -t 1-23:59                      # Tiempo (D-HH:MM)
#SBATCH -o /LUSTRE/HOME/tatiana/HYCOM_team/informes_operativo/hycom.%x_%j.out      # STDOUT Salida estandar (tag name, id)

########################################
#Cargar variables necesarias

export ruta_scripts=/LUSTRE/HOME/tatiana/HYCOM_team/scripts_operativo
#export PATH="/home/olmozavala/miniconda2/bin:$PATH"
export RAIZ_SISTEMA="/LUSTRE/OPERATIVO/"
#source activate netcdf4
#source $ruta_scripts/variables_ambiente.sh
source $RAIZ_SISTEMA/scripts/bash/configuracion/fechas.sh
source $RAIZ_SISTEMA/scripts/bash/configuracion/funciones.sh
source $ruta_scripts/rutas_hycom.py
source $ruta_scripts/funciones_hycom_bash.sh
ml load herramientas/python/3.7 #anteriormente 3.6
#actualizar_registro "***INICIO DEL MODULO DE EJECUCION DEL MODELO HYCOM***"

#Limpiar directorio de trabajo
rm -rf $ruta_trb/*

#Hacer limits
FECHA_REF="1900-12-31_00"
FECHA_py=$ANIO_INI"-"$MES_INI"-"$DIA_INI"_"$HORA_INI
FECHA_FIN_py=$ANIO_FIN"-"$MES_FIN"-"$DIA_FIN"_00"

cd $ruta_scripts #hacer carpeta con funciones y configuracion (coord_nc,funciones_python,blk,patch,ports)
jul_in=`python -c "import funciones_hycom; print('%10.4f'% funciones_hycom.fecha2jul('$FECHA_REF','$FECHA_py'))"`
jul_fin=`python -c "import funciones_hycom; print('%10.4f'% funciones_hycom.fecha2jul('$FECHA_REF','$FECHA_FIN_py'))"`
echo "$jul_in $jul_fin" > $ruta_trb/limits

#Ligar nest
mkdir -p $ruta_trb/nest
sed -e s:aaaaa.aaaa:$jul_in:g -e s:bbbbb.bbbb:$jul_fin:g -e s:yy:$ANIO_INI:g $ruta_scripts/GeneraNest.sh.TEMPLATE > $ruta_trb/GeneraNest.sh
chmod 755 $ruta_trb/GeneraNest.sh
bash $ruta_trb/GeneraNest.sh $ruta_trb
bash $ruta_scripts/read365.sh $ruta_trb"/lista"$ANIO_INI".txt" $ruta_trb/nest
ln -s $ruta_cnfg/rmu.* $ruta_trb/nest/.

#Ligar archivos de config y forzantes
ln -s $ruta_cnfg/regional* $ruta_trb/.
#ln -s /home/tatiana/HYCOM_team/hycom_tatiana/hycom/GOMt0.04/topo/regional* $ruta_trb/.
ln -s $ruta_cnfg/relax* $ruta_trb/.
ln -s $ruta_cnfg/blkdat* $ruta_trb/.
ln -s $ruta_cnfg/patch* $ruta_trb/.
ln -s $ruta_cnfg/ports* $ruta_trb/.
ln -s $ruta_cnfg/forcing* $ruta_trb/.

#Ligar restart
#cp $ruta_rst/restart_out.a $ruta_trb/restart_in.a
#cp $ruta_rst/restart_out.b $ruta_trb/restart_in.b
sed -e s:ddddd.dddd:$jul_in:g $ruta_cnfg/restart_in.b.TEMPLATE > $ruta_trb/restart_in.b
ln -s $ruta_cnfg/restart_in.a $ruta_trb/.

#Copiar ejecutable
cp $ruta_cnfg/hycom $ruta_trb/.
#cp /LUSTRE/ID/HPC/hycom/HYCOM-CCA_mpi/hycom $ruta_trb/.
#cp /LUSTRE/HOME/tatiana/HYCOM_team/hycom_tatiana/hycom_rest_modif/src_2.2.98/hycom/RELO/src_2.2.98ZA-07Tsig0-i-sm-sse_relo_mpi/hycom $ruta_trb/.
#Crear forzamientos del dia
carpeta_mes $MES_INI #Obetener nombre de carpeta mensual de la salida WRF

for VAR in "RAINC" "T2" "SST" "PSFC" "GLW" "SWDOWN" "Q2" "U10" "V10"
do
        python force2ab.py $FECHA_py $VAR $CARPETA_MES
done

#Ejecutar modelo
source /home/tatiana/HYCOM_team/scripts_operativo/variables_ambiente.sh
#ml purge
#ml core/intel/2019u4/compilers   mpi/intel/19.4.243
monitor_restart $ruta_trb $ruta_inf $FECHA_py & #Monitorea la carpeta scratch para mover el restart_out necesario
/usr/bin/time --format="%E" --output=tiempo.txt mpirun -np 24 --mca mpi_cuda_support 0 --wdir $ruta_trb hycom > $ruta_inf/salida_hycom.log
#cd $ruta_trb
#/usr/bin/time --format="%E" --output=tiempo.txt mpiexec -np 24 ./hycom > $ruta_inf/salida_hycom.log
kill $(pgrep -f inotifywait)

#Convertir salidas a NetCDF
#mkdir -p $ruta_trb/salidas/ab
#python convertAB2NC.py > $ruta_inf/ab2nc.log
#mv $ruta_trb/arch* $ruta_trb/salidas/ab/.

#Graficado                                       
