# Hotel-Bookings-Analytics
_____________________________________________________________________________________________________________________________________________________________________________________________________________________________

![image](https://github.com/user-attachments/assets/d90dc93c-e43e-4952-88a4-751ca99c5796)

## 1. Requisitos del Negocio - Panel de control de Analisis del Hotel.
### 1.1. Antecedentes

El hotel dispone de datos de reservas sin procesar y poco coherentes, y carece de una visión clara de los ingresos mensuales, las tendencias de reservas y el rendimiento a nivel de ciudad. La dirección necesita información rápida y precisa para la toma de decisiones.

### 1.2. Objetivos

* Limpiar y estandarizar los datos de reservas.
* Mostrar los ingresos mensuales y las reservas mensuales.
* Identificar las ciudades que generan más ingresos.
* Analizar las reservas por tipo y estado.
* Mostrar los indicadores clave de rendimiento (como los ingresos totales y el número total de reservas).

### 1.3. Requisitos Funcionales

* Limpiar el conjunto de datos brutos (corregir datos, duplicados y valores perdidos).
* Transformar los datos en agregados mensuales.
* Crear gráficos:
  - Ingresos por mes (gráfico de líneas).
  - Reservas por mes (gráfico de líneas).
  - Principales ciudades por ingresos (gráfico de barras).  
  - Reservas por tipo (gráfico de barras).
  - Reservas por estado (gráfico de barras).

* Mostrar los KPI en el panel de control.

### 1.4. Entregables

* Indicadores mensuales precisos.
* Indicadores clave de rendimiento (KPIs) correctos.
* Panel de control fácil de interpretar.
* Sin problemas de calidad de los datos en el resultado final.

_____________________________________________________________________________________________________________________________________________________________________________________________________________________________

## 2. Creación del Proyecto en Snowflake.

### 2.1. Creamos un base de datos.
   
     Snowflake:

                CREATE DATABASE HOTEL_DB;


![image](https://github.com/user-attachments/assets/d382bc40-5f70-456e-8673-03e2565d1e80)

![image](https://github.com/user-attachments/assets/059cd231-1769-42c2-a8dc-a88368d6b0a5)

### 2.2. Creamos formato de archivo

     Snowflake:
     
   	            CREATE OR REPLACE FILE FORMAT FF_CSV 
                	   TYPE = 'CSV'
  		          FIELD_OPTIONALLY_ENCLOSED_BY = '"'
   		          SKIP_HEADER = 1
  		          NULL_IF = ('NULL', 'null', '')

![image](https://github.com/user-attachments/assets/0d2628e6-da24-47c5-899b-ab217a39d5b2)

### 2.3. Creamos escenario

     Snowflake:

                CREATE OR REPLACE STAGE STG_HOTEL_BOOKINGS
                FILE_FORMAT = (FORMAT_NAME = FF_CSV)
                ON_ERROR = 'CONTINUE';
                FILE_FORMAT = FF_CSV;

![image](https://github.com/user-attachments/assets/0546953d-c857-4b53-baae-0e42d16035f6)

### 2.4. Importar datos

![image](https://github.com/user-attachments/assets/8c8d50a5-63b5-4b77-8233-b03f4e2d412c)

![image](https://github.com/user-attachments/assets/e625d02a-961d-4c98-b3b5-dfdce04fc0a7)

![image](https://github.com/user-attachments/assets/b15d5a48-ebe2-4e5f-a956-95c103c4d81a)

## 3. Tabla de Bronce
### 3.1. Creamos la tabla Bronce

    Snowflake:
    
               CREATE TABLE BRONZE_HOTEL_BOOKING (
               booking_id STRING,
               hotel_id STRING,
               hotel_city STRING,
               customer_id STRING,
               customer_name STRING,
               customer_email STRING,
               check_in_date STRING,
               check_out_date STRING,
               room_type STRING,
               num_guests STRING,
               total_amount STRING,
               currency STRING,
               booking_status STRING
               );


![image](https://github.com/user-attachments/assets/9d6bbf81-9df8-47c3-a41d-63b5764db748)

### 3.2. Cargamos los datos a la tabla de bronce

Snowflake:

           COPY INTO BRONZE_HOTEL_BOOKING
           FROM @STG_HOTEL_BOOKINGS
           FILE_FORMAT = (FORMAT_NAME = FF_CSV)
           ON_ERROR = 'CONTINUE';

![image](https://github.com/user-attachments/assets/03e25fb2-3071-4fa4-a88c-bbab70e83426)

## 4. Tabla de Plata

     Snowflake:
     
                CREATE TABLE SILVER_HOTEL_BOOKINGS (
                booking_id VARCHAR,
                hotel_id VARCHAR,
                hotel_city VARCHAR,
                customer_id VARCHAR,
                customer_name VARCHAR,
                customer_email VARCHAR,
                check_in_date DATE,
                check_out_date DATE,
                room_type VARCHAR,
                num_guests INTEGER,
                total_amount FLOAT,
                currency VARCHAR,
                booking_status VARCHAR
                );

![image](https://github.com/user-attachments/assets/c0baad40-1f0a-49c7-aff0-c58e7e523d32)

![image](https://github.com/user-attachments/assets/bce77d29-74cf-4757-a3eb-e3eec892173d)

### 4.1. Buscando errores

         Snowflake:

                    SELECT customer_email
                    FROM BRONZE_HOTEL_BOOKING
                    WHERE NOT (customer_email LIKE '%@%.%')
                         OR customer_email IS NULL

                    SELECT total_amount
                    FROM BRONZE_HOTEL_BOOKING
                    WHERE TRY_TO_NUMBER(total_amount) < 0;

                    SELECT check_in_date, check_out_date
                    FROM BRONZE_HOTEL_BOOKING
                    WHERE TRY_TO_DATE(check_out_date) < TRY_TO_DATE(check_in_date);

                    SELECT DISTINCT booking_status
                    FROM BRONZE_HOTEL_BOOKING;

### 4.2. Inserción de datos depurados en la capa Silver

         Snowflake:

                    INSERT INTO SILVER_HOTEL_BOOKINGS
                    SELECT
                         booking_id,
                         hotel_id,
                         INITCAP(TRIM(hotel_city)) AS hotel_city,
                         customer_id,
                    INITCAP(TRIM(customer_name)) AS customer_name,
                    CASE
                       WHEN customer_email LIKE '%@%.%' THEN LOWER(TRIM(customer_email))
                       ELSE NULL
                    END AS customer_email,
                    TRY_TO_DATE(NULLIF(check_in_date, '')) AS check_in_date,
                    TRY_TO_DATE(NULLIF(check_out_date, '')) AS check_out_date,
                    room_type,
                    num_guests,
                    ABS(TRY_TO_NUMBER(total_amount)) AS total_amount,
                    currency,
                    CASE
                       WHEN LOWER(booking_status) in ('confirmeeed', 'confirmd') THEN 'Confirmed'
                       ELSE booking_status
                    END AS booking_status
                    FROM BRONZE_HOTEL_BOOKING
                    WHERE
                        TRY_TO_DATE(check_in_date) IS NOT NULL
                        AND TRY_TO_DATE(check_out_date) IS NOT NULL
                        AND TRY_TO_DATE(check_out_date) >= TRY_TO_DATE(check_in_date);

                    SELECT * FROM SILVER_HOTEL_BOOKINGS LIMIT 30;

## 5. Tablas de Oro.

Snowflake:

           CREATE TABLE GOLD_AGG_DAILY_BOOKING AS
           SELECT
               check_in_date AS date,
               COUNT(*) AS total_booking,
               SUM(total_amount) AS total_revenue
           FROM SILVER_HOTEL_BOOKINGS
           GROUP BY check_in_date
           ORDER BY date;

           CREATE TABLE GOLD_AGG_HOTEL_CITY_SALES AS
           SELECT
           hotel_city,
           SUM(total_amount) AS total_revenue
           FROM SILVER_HOTEL_BOOKINGS
           GROUP BY hotel_city
           ORDER BY total_revenue DESC;

           CREATE TABLE GOLD_BOOKING_CLEAN AS
           SELECT
               booking_id,
               hotel_id,
               hotel_city,
               customer_id,
               customer_name,
               customer_email,
               check_in_date,
               check_out_date,
               room_type,
               num_guests,
               total_amount,
               currency,
               booking_status
          FROM SILVER_HOTEL_BOOKINGS;

          SELECT * FROM GOLD_AGG_DAILY_BOOKING LIMIT 30;

          SELECT * FROM GOLD_AGG_HOTEL_CITY_SALES LIMIT 30;


![image](https://github.com/user-attachments/assets/c8dd2de3-51a3-4c7a-8e4f-faf12f5dc760)

![image](https://github.com/user-attachments/assets/b3bd67ab-0131-4066-9685-6c04ca0d3549)

## 6. Dashboard

Snowflake: 

           --KPI - Valor medio de las reservas
           SELECT AVG(total_amount) as avg_booking_value
           FROM GOLD_BOOKING_CLEAN;

           --KPI - Total Huéspedes
           SELECT SUM(num_guests) AS total_guests
           FROM GOLD_BOOKING_CLEAN;

           --KPI - Total de reservas
           SELECT COUNT(*) as total_bookings
           FROM GOLD_BOOKING_CLEAN;

           --KPI - Ingresos Totales
           SELECT SUM(total_amount) AS total_revenue
           FROM GOLD_BOOKING_CLEAN;

           --Gráfico de líneas: Ingresos Mensuales
           SELECT date, total_revenue
           FROM GOLD_AGG_DAILY_BOOKING
           ORDER BY date;

           --Gráfico de líneas: reservas mensuales
           SELECT date, total_booking
           FROM GOLD_AGG_DAILY_BOOKING
           ORDER BY date;

           --Gráfico de barras: Ingresos por Ciudades
          SELECT hotel_city, total_revenue
          FROM GOLD_AGG_HOTEL_CITY_SALES
          WHERE total_revenue is NOT NULL
          ORDER BY total_revenue DESC
          LIMIT 5;

          --Gráfico de barras: reservas por estado
          SELECT booking_status, COUNT(*) AS total
          FROM GOLD_BOOKING_CLEAN
          GROUP BY booking_status;

         --Gráfico de barras: Tipos de reservas
         SELECT room_type, COUNT(*) AS total_bookings
         FROM GOLD_BOOKING_CLEAN
         GROUP BY room_type
         ORDER BY total_bookings DESC;


![image]()

![image]()

![image]()

![image]()
