############################################
# Se extraen las variables de WRF para     #
# hacer los forzamientos de HYCOM.         #
# Basado en el codigo *forcing*mat2ab.m y  #
# forcingwrf2mat.m de Oscar Calderón     #

#Importar librerias
from scipy.io import netcdf
from array import array
import sys
import numpy as np
import datetime
import sys
import os
import subprocess
from os.path import basename
import shutil
from glob import glob
from rutas_hycom import *

#ruta_wrf: ruta al archivo nc de la salida WRF
#ruta_hist: ruta al archivo nc de la salida WRF del dia anterior
#fecha_cadena: fecha en formato YYYY-MM-DD_HH, como se pasa al script principal

#Declarar rutas necesarias
#ruta_scr='/media/tatiana/respaldo_tats/PC_cubo/IOA/hycom/scratch_prueba/'  #ruta_scratch prueba
#ruta_wrf='/home/oscar/forcing_py/salidas_wrf/'
#ruta_rst='' #ruta donde se encuentren los restarts de corrida pasada
#Extraccion generica
def extrae_nc(ruta_nc,var_ext):
    #nombre_nc=ruta_nc+'/wrfout_d01_'+fecha_cadena+'.nc'
    arch_nc=netcdf.NetCDFFile(ruta_nc)
    variable=arch_nc.variables[var_ext]
    variable_local=variable[:]*1
    dim_varlocal=variable_local.shape
    del variable
    arch_nc.close()
    return (variable_local,dim_varlocal)

#def extrae_nc(ruta_nc,fecha_cadena,var_ext):
#    nombre_nc=ruta_nc+'wrfout_d01_'+fecha_cadena+'.nc'
#    arch_nc=netcdf.NetCDFFile(nombre_nc)
#    variable=arch_nc.variables[var_ext]
#    variable_local=variable[:]*1
#    dim_varlocal=variable_local.shape
#    del variable
#    arch_nc.close()
#    return (variable_local,dim_varlocal)


#Extraccion de precipitacion
def precip_wrf(ruta_wrf,fecha_cadena):
    rain1,dim_rain1=extrae_nc(ruta_wrf,'RAINC')
    rain2,dim_rain2=extrae_nc(ruta_wrf,'RAINNC')
    rain=np.add(rain1,rain2)                      #Sumar las dos variables de precipitacion 
    rain0=np.zeros([dim_rain1[1],dim_rain1[2]]) #Matriz de zeros de tamano latxlon
  rain_final=np.zeros(dim_rain1)
    for iDD in range(1,dim_rain1[0]):
        rain_notacc=np.subtract(rain[iDD,:,:],rain0) #Para tener la lluvia de esa hora y no la acumulada
        rain_notacc=np.clip(rain_notacc,a_min=0,a_max=None) #Redondear a cero los negativos
        rain_final[iDD,:,:]=(rain_notacc/3600)*0.0001

        del rain0,rain_notacc
        rain0=rain[iDD,:,:] #Se redefine rain0 para que cambie al valor de la hora correspondiente

    return (rain_final,dim_rain1)

# Correccion de albedo
def corr_albedo(glw,swdown,sst):
    epsilon=0.96
    sigma=10e-8
    glw_crr=glw-(epsilon*sigma*np.power(sst,4))+swdown #Se asumen que swdown ya tiene correcion de albedo
    return glw_crr




# Conversion de fecha actual a julianos con # 
# fecha de referencia 31/12/1900 (HYCOM).   #
# Basado en seccion del codigo assim.py     #
# del operativo viejo                       #

def fecha2jul(dia_ref_cadena,fecha_cadena):
    #dia_ref_cadena='1900-12-31_00'
    dia_ref=datetime.datetime.strptime(dia_ref_cadena,'%Y-%m-%d_%H')
    dia_ejec=datetime.datetime.strptime(fecha_cadena,'%Y-%m-%d_%H')
    dif_dias=dia_ejec-dia_ref
    jul_ejec=dif_dias.days
    return jul_ejec


# Conversion de ab a NetCDF          #
# Autor:  a.srinivasan@tendral.com   #
# Modificado por ATHS                #

def doarch2nc(scr_dir,cdtg):

# define locations for netcdf data
    netcdf_dir=ruta_trb+"/salidas/netcdf"
    netcdf_dir_2d=ruta_trb+"/salidas/netcdf/2d/"
    netcdf_dir_3z=ruta_trb+"/salidas/netcdf/3z/"
    arch_dir=ruta_trb#+"/salidas/ab/"

    print("Generating netcdf from subsets: " ,arch_dir)

# set executable

    dumpnc=ruta_scrpt+"/dump2nc"

# move over to forcing directory 

    os.chdir(arch_dir)

# call arch2nc

    try:
       ncgen=subprocess.Popen([dumpnc,arch_dir],stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
       while ncgen.poll() is None:
          output = ncgen.stdout.readline()
          sys.stdout.flush()
          print(output)

    except OSError:
       print('cannot run ',dumpnc,'quitting!')
       sys.exit(0)

# move each 2d netcdf file

    for ncfile in glob('archv*_2d.nc'):
        shutil.move(ncfile,netcdf_dir_2d+ncfile)

# move each 3z netcdf file
    for ncfile in glob('archv*_3z.nc'):
        shutil.move(ncfile,netcdf_dir_3z+ncfile)

