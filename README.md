# HYCOM_pronostico
En este repositorio se encuentran algunos códigos sh y py para la ejecució de los distintos modelos numéricos que corren el pronóstico IOA/UNAM en el Cluster Ometeotl.

En ../3D_Matrices - Se arman las diferentes matrices con las salidas numéricas de la simulación HYCOM ordenada anual y mensualmente. Igualmente se configuran los metadatos de cada archivo promediado mensualmente con la paquetería NCO para el uso de arcvhiso netcdf.

Para ../script_ioa_pronosticos/ - Se encuentran los códigos para ejecutar los modelos adcirc y fvcom, así como los modulos de descarga de gfs para el modelo wwiii y el graficado final de las salidas.

