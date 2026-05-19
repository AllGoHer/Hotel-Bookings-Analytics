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