#!/bin/bash

# Conjunto de variables de ambiente para compiladores y NetCDF de PGI

# Fecha: 13 de julio de 2017

# Variables de ambiente referentes al compilador
export PS1="\e[0;34m(PGI-17.5)\e[m [\u@\h \w]$ "
export PGI=/opt/pgi
export PATH=/opt/pgi/linux86-64/17.5/bin:/opt/pgi/linux86-64/17.5/mpi/openmpi/bin:$PATH
export MANPATH=/opt/pgi/linux86-64/17.5/man:$MANPATH
export LM_LICENSE_FILE=/opt/pgi/license.dat$LM_LICENSE_FILE
export LD_LIBRARY_PATH=/opt/pgi/linux86-64/17.5/lib:/opt/pgi/linux86-64/17.5/mpi/openmpi/lib:$LD_LIBRARY_PATH

# Variables de ambiente referentes a NetCDF 
export NETCDF=/opt/librerias/pgi/netcdf-4.4.1.1
export LD_LIBRARY_PATH=/opt/librerias/pgi/netcdf-4.4.1.1/lib:$LD_LIBRARY_PATH
export PATH=/opt/librerias/pgi/netcdf-4.4.1.1/bin:$PATH
export NETCDF_LIBDIR=/opt/librerias/pgi/netcdf-4.4.1.1/lib
export NETCDF_INCDIR=/opt/librerias/pgi/netcdf-4.4.1.1/include
export NETCDF_CONFIG=/opt/librerias/pgi/netcdf-4.4.1.1/bin/nc-config
~                                                                         
