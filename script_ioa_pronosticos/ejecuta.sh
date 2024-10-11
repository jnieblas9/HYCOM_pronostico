#
## ejecuta.sh
# 
# #

# # Copyright 2017 CCA-UNAM. All rights reserved.
# #
# #  Se Ubica en el directorio de trabajo
# #
 cd /LUSTRE/OPERATIVO/scripts/bash/ejecuta_fall
# #
# #   Convierte los datos de GFS a met en WPS
# #
# ./do_wps.sh
# #
# #  Genera los datos de entrada para WRF
# #  
# ./do_real.sh
# #
# #  Corre WRF-Chem
# #
# ./do_wrf.sh
# #
# #  Genera pronostico de vientos
#
# ./do_ARWpost.sh
# #
rm /home/popocatepetl/registro_eventos/p_*.log
#  Genera pronostico de ceniza
#
 cd /LUSTRE/OPERATIVO/scripts/bash/ejecuta_fall
# 
./altura1.sh&
./altura2.sh&
./altura3.sh
#echo Pronostico Colima
#./pronostico_colima.sh
#
#

