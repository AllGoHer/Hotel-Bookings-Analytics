# Hotel-Bookings-Analytics
______________________________________________________________________________________________________________________________________________________________________________________________________________________________
## 1. Requisitos del Negocio - Panel de control de Analisis del Hotel.
## 1.1. Antecedentes

El hotel dispone de datos de reservas sin procesar y poco coherentes, y carece de una visión clara de los ingresos mensuales, las tendencias de reservas y el rendimiento a nivel de ciudad. La dirección necesita información rápida y precisa para la toma de decisiones.

## 1.2. Objetivos

* Limpiar y estandarizar los datos de reservas.
* Mostrar los ingresos mensuales y las reservas mensuales.
* Identificar las ciudades que generan más ingresos.
* Analizar las reservas por tipo y estado.
* Mostrar los indicadores clave de rendimiento (como los ingresos totales y el número total de reservas).

## 1.3. Requisitos Funcionales

* Limpiar el conjunto de datos brutos (corregir datos, duplicados y valores perdidos).
* Transformar los datos en agregados mensuales.
* Crear gráficos:
  - Ingresos por mes (gráfico de líneas).
  - Reservas por mes (gráfico de líneas).
  - Principales ciudades por ingresos (gráfico de barras).  
  - Reservas por tipo (gráfico de barras).
  - Reservas por estado (gráfico de barras).

* Mostrar los KPI en el panel de control.

## 1.4. Entregables

* Indicadores mensuales precisos.
* Indicadores clave de rendimiento (KPIs) correctos.
* Panel de control fácil de interpretar.
* Sin problemas de calidad de los datos en el resultado final.

_____________________________________________________________________________________________________________________________________________________________________________________________________________________________

![image](https://github.com/user-attachments/assets/d90dc93c-e43e-4952-88a4-751ca99c5796)

2. Creación del Proyecto en Snowflake.
2.1. Creamos un base de datos.
     Snowflake:

                CREATE DATABASE HOTEL_DB;

