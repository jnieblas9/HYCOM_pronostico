#!/bin/bash

# Conjunto de variables de ambiente para comppiladores y NetCDF de Intel

# Fecha: 13 de julio de 2017
# Copia del archivo variables-intel.sh.old

# Variables de ambiente referentes al compilador
export PS1="\e[0;34m(Intel-2017.4.196)\e[m [\u@\h \w]$ "
source /opt/intel/compilers_and_libraries_2017.4.196/linux/bin/compilervars.sh intel64
source /opt/intel/compilers_and_libraries_2017.4.196/linux/mpi/bin64/mpivars.sh
export I_MPI_FABRICS=ofa

# Variables de ambiente referentes a NetCDF
export NETCDF=/opt/librerias/intel/netcdf4_intel
export LD_LIBRARY_PATH=/opt/librerias/intel/netcdf4_intel/lib:$LD_LIBRARY_PATH
export PATH=/opt/librerias/intel/netcdf4_intel/bin:$PATH
export NETCDF_LIBDIR=/opt/librerias/intel/netcdf4_intel/lib
export NETCDF_INCDIR=/opt/librerias/intel/netcdf4_intel/include
export NETCDF_CONFIG=/opt/librerias/intel/netcdf4_intel/bin/nc-config
export CORES=110

export LD_LIBRARY_PATH=/opt/librerias/intel/nco/4.6.7/lib:$LD_LIBRARY_PATH
export INCLUDE=/opt/librerias/intel/nco/4.6.7/include:$INCLUDE
~                                                                  
