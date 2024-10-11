#!/bin/bash
ml load herramientas/nco

mes_nmb=('enero' 'febrero' 'marzo' 'abril' 'mayo' 'junio' 'julio' 'agosto' 'septiembre' 'octubre' 'noviembre' 'diciembre')
mes_id=('00' '01'    '02'     '03'     '04'     '05'     '06'     '07'     '08'     '09'     '10'    '11')
mes_id_corr=('01'    '02'     '03'     '04'     '05'     '06'     '07'     '08'     '09'     '10'    '11' '12')
fecha_act=$(date '+%Y-%m-%d')
for mm in `seq 0 11`
do
        mes=${mes_id[$mm]}
        mes_n=${mes_nmb[$mm]}
        mes_c=${mes_id_corr[$mm]}
        ncatted -O -h -a history,global,d,, "prom_mes_"$mes".nc"
        ncatted -O -h -a history,global,d,, "prom_mes_"$mes"_prof.nc"


        ncks -h -d Depth,0 -d Depth,10 -d Depth,27 -v Latitude,Longitude,Depth,pot_temp,salinity,u,v "prom_mes_"$mes".nc" "prom_mes_"$mes_c"-HR.nc"
        ncks -h -d Depth,12 -v Latitude,Longitude,Depth,pot_temp,salinity,u,v  "prom_mes_"$mes"_prof.nc" "prom_mes_"$mes_c"-DR.nc"

        ncpdq -O -h -a Depth,MT "prom_mes_"$mes_c"-HR.nc" "prom_mes_"$mes_c"-HR.nc"
        ncpdq -O -h -a Depth,MT "prom_mes_"$mes_c"-DR.nc" "prom_mes_"$mes_c"-DR.nc"

        ncrcat -h "prom_mes_"$mes_c"-HR.nc" "prom_mes_"$mes_c"-DR.nc" "PROM_MES_"$mes_c".nc"

        rm "prom_mes_"$mes_c"-HR.nc" "prom_mes_"$mes_c"-DR.nc"

        ncatted -O -h -a Conventions,global,d,, PROM_MES_$mes_c.nc
        ncatted -O -h -a NCO,global,d,, PROM_MES_$mes_c.nc
        ncatted -O -h -a source,global,d,, PROM_MES_$mes_c.nc
        ncatted -O -h -a experiment,global,d,, PROM_MES_$mes_c.nc
        ncatted -O -h -a nco_openmp_thread_number,global,d,, PROM_MES_$mes_c.nc

        ncatted -O -h -a id,global,c,c,"uvts-grid-dataset" PROM_MES_$mes_c.nc
        ncatted -O -h -a naming_authority,global,c,c,"cigom.org" PROM_MES_$mes_c.nc
        ncatted -O -h -a institution,global,m,c,"CCA-CIGOM" PROM_MES_$mes_c.nc
        ncatted -O -h -a project,global,c,c,"CONACyT - SENER - Hidrocarburos, proyecto 201441" PROM_MES_$mes_c.nc
        ncatted -O -h -a conventions,global,c,c,"CF-1.6, ACDD-1.3" PROM_MES_$mes_c.nc
        ncatted -O -h -a title,global,m,c,"Climatologia UVTS de $mes_n" PROM_MES_$mes_c.nc
        ncatted -O -h -a summary,global,c,c,"Climatologia mensual para el mes de $mes_n de temperatura potencial, salinidad y componentes horizontales de velocidad, calculada a partir de datos del modelo HYCOM para el periodo de 2000 a 2012" PROM_MES_$mes_c.nc
        ncatted -O -h -a featureType,global,c,c,"grid" PROM_MES_$mes_c.nc
        ncatted -O -h -a cdm_data_type,global,c,c,"Grid" PROM_MES_$mes_c.nc
        ncatted -O -h -a creator_name,global,c,c,"Grupo de Interaccion Oceano Atmosfera" PROM_MES_$mes_c.nc
        ncatted -O -h -a creator_email,global,c,c,"ioa@atmosfera.unam.mx" PROM_MES_$mes_c.nc
        ncatted -O -h -a creator_url,global,c,c,"http://grupo-ioa.atmosfera.unam.mx/index.php/cigom" PROM_MES_$mes_c.nc
        ncatted -O -h -a publisher_name,global,c,c,"" PROM_MES_$mes_c.nc
        ncatted -O -h -a publisher_email,global,c,c,"" PROM_MES_$mes_c.nc
        ncatted -O -h -a publisher_url,global,c,c,"" PROM_MES_$mes_c.nc
        ncatted -O -h -a date_created,global,c,c,"$fecha_act" PROM_MES_$mes_c.nc

        rm "prom_mes_"$mes".nc" "prom_mes_"$mes"_prof.nc"
done

