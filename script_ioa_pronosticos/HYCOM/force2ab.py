#!/opt/miniconda3/bin/python3.6

############################################
# Conversion de forzamientos a formato .ab #
# Basado en el código precmat2ab.m y       #
# prec_WRF_2007.m de Tatis y Oscar C.      #
############################################

#Importar librerias
#from netCDF4 import Dataset
from array import array
import sys
import numpy as np
#import matplotlib
#import matplotlib.pyplot as plt
from scipy import interpolate as intp
from scipy.io import netcdf
from funciones_hycom import *
from rutas_hycom import *

#ARGUMENTOS QUE RECIBE
# 1: FECHA en formato YYYY-MM-DD_HH
# 2: VARIABLE (RAINC,T2,SST,PSFC,GLW,SWDOWN,Q2,U10,V10)
# 3: CARPETA MENSUAL de WRF (01_enero,02_febrero...)

dia_ref='1900-12-31_00'
dia_jul=fecha2jul(dia_ref,sys.argv[1])
#dia_jul=38960.0
Dhr=1/24
#wrfout_d01_2018-08-27_00.nc 

#Rutas necesarias
#ruta_wrf='/home/oscar/forcing_py/salidas_wrf/'
#ruta_frc='/home/oscar/forcing_py/'
#ruta_cnfg='/home/oscar/forcing_py/'

#Leer salida del WRF

ruta_wrf=raiz_wrf+"/"+sys.argv[1][0:4]+"/"+sys.argv[3]+"/wrfout_d01_"+sys.argv[1]+".nc"

if sys.argv[2]=='RAINC':
    nombre_varch='precip'
    nombre_vcont='prec'
    var_local,dim_var=precip_wrf(ruta_wrf,sys.argv[1])
elif sys.argv[2]=='T2':
    nombre_varch='airtmp'
    nombre_vcont='airtmp'
    var_local,dim_var=extrae_nc(ruta_wrf,sys.argv[2])
    var_local=var_local-273.16 #Restar Kelvin
elif sys.argv[2]=='SST':
    nombre_varch='surtmp'
    nombre_vcont='surtmp'
    var_local,dim_var=extrae_nc(ruta_wrf,sys.argv[2])
    var_local=var_local-273.16 #Restar Kelvin
elif sys.argv[2]=='PSFC':
    nombre_varch='mslprs'
    nombre_vcont='psfc'
    var_local,dim_var=extrae_nc(ruta_wrf,sys.argv[2])
elif sys.argv[2]=='SWDOWN':
    nombre_varch='shwflx'
    nombre_vcont='shwflx'
    var_local,dim_var=extrae_nc(ruta_wrf,sys.argv[2]) #Sin albedo
    var_local=var_local*(1-0.06) #Albedo promedio
elif sys.argv[2]=='GLW':
    nombre_varch='radflx'
    nombre_vcont='radflx'
    var_local_SCN,dim_var=extrae_nc(ruta_wrf,sys.argv[2]) #Sin cuerpo negro

    swdown,dim_swdown=extrae_nc(ruta_wrf,'SWDOWN') #Sin cuerpo negro
    swdown=swdown*(1-0.06) #Albedo promedio
    sst,dim_sst=extrae_nc(ruta_wrf,'SST')
    var_local=corr_albedo(var_local_SCN,swdown,sst)

elif sys.argv[2]=='Q2':
    nombre_varch='vapmix'
    nombre_vcont='vapmix'
    var_local,dim_var=extrae_nc(ruta_wrf,sys.argv[2])
elif sys.argv[2]=='U10':
    nombre_varch='wndewd'
    nombre_vcont='wndewd'
    var_local,dim_var=extrae_nc(ruta_wrf,sys.argv[2])
elif sys.argv[2]=='V10':
    nombre_varch='wndnwd'
    nombre_vcont='wndnwd'
    var_local,dim_var=extrae_nc(ruta_wrf,sys.argv[2])
tD=round(dim_var[0]/24)

#Leer coordenadas WRF y HYCOM
arch_coord=netcdf.NetCDFFile(ruta_cnfg+'/coord_wrf2hycom.nc')
laW1=arch_coord.variables['latWRF']
loW1=arch_coord.variables['lonWRF']
laH1=arch_coord.variables['latHY']
loH1=arch_coord.variables['lonHY']
#Coordenadas en variables locales
laW=laW1[:]*1
loW=loW1[:]*1
laH=laH1[:]*1
loH=loH1[:]*1
del laW1; del loW1; del laH1; del loH1
arch_coord.close()

#Encabezado para archivo .b
r1='Campo forzante: '+ nombre_varch
r2='Extraido de salida WRF: ' + sys.argv[2]
r3='JMNP'
r4='Grupo IOA, CCA, UNAM'
r5='i/jdm ='+str(loH.size)+' '+str(laH.size)

r6='  '+nombre_vcont+': day,span,range = '

#Crear archivos .a y .b
nombre_arch_a=ruta_frc+'/forcing.'+nombre_varch+'.a'
nombre_arch_b=ruta_frc+'/forcing.'+nombre_varch+'.b'
arch_a=open(nombre_arch_a,'w')
arch_b=open(nombre_arch_b,'w')
arch_b.write(r1+'\n'+r2+'\n'+r3+'\n'+r4+'\n'+r5+'\n')

#Ciclo para recorrer salida wrf en segmentos de 24 horas
tT=tD*24
for cHH in range(0,tT):
        var_hh=var_local[cHH,:,:]

        #Interpolar al dominio HYCOM
        f_intp=intp.interp2d(loW,laW,var_hh)
        var_hh_int=f_intp(loH,laH)
        var_hh_int=var_hh_int.astype('float32') #Convertir a single, en caso de que no lo sea.
        var_hhb=np.reshape(var_hh_int,(loH.size*laH.size,1))
        max_var=np.amax(var_hhb)
        min_var=np.amin(var_hhb)
        var_swap=var_hhb.byteswap()         #Invertir el orden de los bytes.

        #Escribir archivo .b
        r7='%10.4f %8.6f   %9.6E   %9.6E\n'% (dia_jul,Dhr,min_var,max_var)
        arch_b.write(r6+r7)
        dia_jul+=Dhr

        #Escribir archivo .a
        var_swap.tofile(arch_a)
        ult_linea=np.zeros((dim_var[1]*dim_var[2],1))
        ult_linea=np.zeros((611,1))
        ult_linea=ult_linea.astype('float32')
        ult_linea.tofile(arch_a)

arch_a.close()
arch_b.close()
                                              
