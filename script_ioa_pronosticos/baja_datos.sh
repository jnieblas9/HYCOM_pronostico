#!/bin/bash
#######
##  Con este Script se bajan los datos de pronostico
#

# Copyright 2011 CCA-UNAM. All rights reserved.
#
WorkDir=/LUSTRE/OPERATIVO/entradas/WRF/dinamicas
##   Borra archivos anteriores de datos

cd $WorkDir
rm gfs.t00z.pgrb*
anio=`date  +%Y`
mes=`date   +%m`
dia=`date  +%d`

##
##   Baja los datos
##
echo gfs.$anio$mes${dia}00
wget -N -q ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.$anio$mes${dia}00/gfs.t00z.pgrb2.0p50.f000
wget -N -q ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.$anio$mes${dia}00/gfs.t00z.pgrb2.0p50.f003
wget -N -q ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.$anio$mes${dia}00/gfs.t00z.pgrb2.0p50.f006
wget -N -q ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.$anio$mes${dia}00/gfs.t00z.pgrb2.0p50.f009
wget -N -q ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.$anio$mes${dia}00/gfs.t00z.pgrb2.0p50.f012
wget -N -q ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.$anio$mes${dia}00/gfs.t00z.pgrb2.0p50.f015
wget -N -q ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.$anio$mes${dia}00/gfs.t00z.pgrb2.0p50.f018
wget -N -q ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.$anio$mes${dia}00/gfs.t00z.pgrb2.0p50.f021
wget -N -q ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.$anio$mes${dia}00/gfs.t00z.pgrb2.0p50.f024
wget -N -q ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.$anio$mes${dia}00/gfs.t00z.pgrb2.0p50.f027
wget -N -q ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.$anio$mes${dia}00/gfs.t00z.pgrb2.0p50.f030
wget -N -q ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.$anio$mes${dia}00/gfs.t00z.pgrb2.0p50.f033
wget -N -q ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.$anio$mes${dia}00/gfs.t00z.pgrb2.0p50.f036
wget -N -q ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.$anio$mes${dia}00/gfs.t00z.pgrb2.0p50.f039
wget -N -q ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.$anio$mes${dia}00/gfs.t00z.pgrb2.0p50.f042
wget -N -q ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.$anio$mes${dia}00/gfs.t00z.pgrb2.0p50.f045
wget -N -q ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.$anio$mes${dia}00/gfs.t00z.pgrb2.0p50.f048
wget -N -q ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.$anio$mes${dia}00/gfs.t00z.pgrb2.0p50.f051
wget -N -q ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.$anio$mes${dia}00/gfs.t00z.pgrb2.0p50.f054
wget -N -q ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.$anio$mes${dia}00/gfs.t00z.pgrb2.0p50.f057
wget -N -q ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.$anio$mes${dia}00/gfs.t00z.pgrb2.0p50.f060
wget -N -q ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.$anio$mes${dia}00/gfs.t00z.pgrb2.0p50.f063
wget -N -q ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.$anio$mes${dia}00/gfs.t00z.pgrb2.0p50.f066
wget -N -q ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.$anio$mes${dia}00/gfs.t00z.pgrb2.0p50.f069
wget -N -q ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.$anio$mes${dia}00/gfs.t00z.pgrb2.0p50.f072
wget -N -q ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.$anio$mes${dia}00/gfs.t00z.pgrb2.0p50.f075
wget -N -q ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.$anio$mes${dia}00/gfs.t00z.pgrb2.0p50.f078
wget -N -q ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.$anio$mes${dia}00/gfs.t00z.pgrb2.0p50.f081
wget -N -q ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.$anio$mes${dia}00/gfs.t00z.pgrb2.0p50.f084
chmod 666 gfs*                  
