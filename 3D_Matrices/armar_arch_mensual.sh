#!/bin/bash

d_mes=(31 29 31 30 31 30 31 31 30 31 30 31) #Solo para anios no bisiestos
c_dias=1

#2001 2002 2003 2010 2011
for anio in $1
do
        for mm in `seq 0 11`
        do
        if [ $mm -lt 10 ]
        then
        mes="0"$mm
        else
        mes=$mm
        fi
                for dd in `seq 1 ${d_mes[$mm]}`
                do
                if [ $c_dias -lt 10 ]
                then
                dia="00"$c_dias
                elif [ $c_dias -ge 10 ] && [ $c_dias -lt 100 ]
                then
                dia="0"$c_dias
                else
                dia=$c_dias
                fi

                        for hh in `seq 0 23`
                        do
                        if [ $hh -lt 10 ]
                        then
                        hr="0"$hh
                        else
                        hr=$hh
                        fi


                        mkdir -p "/LUSTRE/CIGOM/salidas/netcdf_horarias/promedios_tatiana/"$mes"/"$hr"/"
                        if [ -f "/LUSTRE/CIGOM/salidas/netcdf_horarias/NChr_"$anio"/3z/archv."$anio"_"$dia"_"$hr"_3z.nc" ]
                        then
                                ln -s "/LUSTRE/CIGOM/salidas/netcdf_horarias/NChr_"$anio"/3z/archv."$anio"_"$dia"_"$hr"_3z.nc" "/LUSTRE/CIGOM/salidas/netcdf_horarias/promedios_tatiana/"$mes"/"$hr"/"
                        fi
                        done
                c_dias=$[$c_dias+1]
                done
        done
done

