#!/usr/bin/env python
# coding: utf-8

# In[4]:


#!/usr/bin/env python
# coding: utf-8

#Se importan paquterías
import numpy as np
import os
import pandas as pd
from datetime import datetime, timedelta, date
from netCDF4 import Dataset

##Se obtienen paths
#netcdf
user_dir=os.path.expanduser('~')
path_nc_pron='/LUSTRE/OPERATIVO/OPERATIVO2/EXTERNO-salidas/WRF_2020/'
path_nc_new='/LUSTRE/OPERATIVO/OPERATIVO2/correccion_por_sesgo/productos/Temps_month_mean_mod/'
path_nc_obs_tmax='/LUSTRE/OPERATIVO/OPERATIVO2/correccion_por_sesgo/Mallas_Temp_RM/temp_TMAX_2020_remallada.nc'
path_nc_obs_tmin='/LUSTRE/OPERATIVO/OPERATIVO2/correccion_por_sesgo/Mallas_Temp_RM/temp_TMIN_2020_remallada.nc'

files_list=[i for i in os.listdir(path_nc_pron) if 'd01' in i]
files_list=sorted(files_list)
#se itera cada mes
for mi in range(1,13):
    month_max_array=[]
    month_min_array=[]
    if mi <10:
        month_s='0'+str(mi)
    else:
        month_s=str(mi)
    #se crea ruta del netcdf donde se guardaran las temps mensuales promedio
    new_nc=os.path.join(path_nc_new,'Temps_mean_'+month_s+'.nc')
#se iteran netcdf del pronostico del mes en cuestion
    for file in files_list:
        file_month=file[16:18]
        print(file)
        if int(file_month) == mi:
            curr_file_pron=os.path.join(path_nc_pron,file)
            #Se lee el netcdf y sus variables
            with Dataset(curr_file_pron,'r') as f:
                #Se obtienen todas las variables
                var=f.variables
                all_vars=[i for i in var]
                temp=var.get('T2')[:].data-273.15
                xlat=var.get('XLAT')[:].data
                xlon=var.get('XLONG')[:].data
                times=var.get('Times')[:].data.astype(str)
                orog=var.get('HGT')[:].data
                temp_nm= temp + ((0.0065) * orog)
                times_st=[''.join(i) for i in times[:]]
                times_dt=np.array([datetime.strptime(time[:13], '%Y-%m-%d_%H')                                        -timedelta(hours=6) for time in times_st])

                # se obtienen los datos de 8 a 8 de cada dia pronosticado
                times_dt2=times_dt[15:-10]
times_st2=times_st[15:-10]
                #dia de pronostico en cuestion
                forecast_ini_date=times_st2[0][:10]
                #mes de pronostico en cuestion
                curr_month=times_dt[0].month

                # Se iteran de cada dias los 5 dias pronosticados
                for i in range(0,120,24):
                    temp_nm2=temp_nm[i:i+24,:,:]
                    tmax_nm=np.nanmax(temp_nm2,axis=0)
                    tmin_nm=np.nanmin(temp_nm2,axis=0)
                    month_max_array.append(tmax_nm)
                    month_min_array.append(tmin_nm)

    max_month_mean=np.nanmean(month_max_array,axis=0)
    min_month_mean=np.nanmean(month_min_array,axis=0)


    #---Se crean netcdfs de temps mensuales promedio---
    dim_list=['Time','south_north','west_east']
    var_list=['XLAT','XLONG']
    with Dataset(curr_file_pron,'r') as fl,Dataset(new_nc,'w',format='NETCDF4') as fm:
        var_or=fl.variables
        for name, dimension in fl.dimensions.items():
            if name in dim_list:
                fm.createDimension(name,(len(dimension)))
        for name, var in var_or.items():
            if name in var_list:
                fm.createVariable(name, var.dtype, var.dimensions)
                fm[name].setncatts(var_or[name].__dict__)
                fm.variables[name][:] = var_or[name][:]

        fm.createVariable('T2max_pot', 'f4', ('south_north','west_east'))
        fm.createVariable('T2min_pot', 'f4', ('south_north','west_east'))
        fm.variables['T2max_pot'][:] = max_month_mean
        fm.variables['T2min_pot'][:] = min_month_mean





