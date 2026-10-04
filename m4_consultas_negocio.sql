-- ============================================================
-- Proyecto RetailPro
-- Base de datos: Ventas_Tech_DB
-- ============================================================
-- Consulta 1: Resumen ejecutivo mensual
-- Total facturado, cantidad de pedidos y ticket promedio, por mes.
-- ============================================================

SELECT
    MONTH(fecha_venta)                     AS mes,
    SUM(cantidad * precio_unitario)        AS total_facturado,
    COUNT(*)                               AS cantidad_pedidos,
    AVG(cantidad * precio_unitario)        AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;

-- ============================================================
-- Consulta 2: Ranking de productos
-- Top 5 de id_producto por total facturado, con unidades vendidas.
-- ============================================================
SELECT TOP 5
    id_producto,
    SUM(cantidad)                          AS unidades_vendidas,
    SUM(cantidad * precio_unitario)        AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC;

-- ============================================================
-- Consulta 3: Clientes recurrentes
-- Clientes con más de un pedido, con cantidad de pedidos y total gastado.
-- ============================================================
SELECT
    id_cliente,
    COUNT(*)                               AS cantidad_pedidos,
    SUM(cantidad * precio_unitario)        AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;

-- ============================================================
-- Consulta 4: Meses por encima / por debajo del promedio
-- Total facturado por mes, etiquetado contra el promedio mensual general.
-- ============================================================
WITH ventas_por_mes AS (
    SELECT
        MONTH(fecha_venta)                 AS mes,
        SUM(cantidad * precio_unitario)    AS total_facturado
    FROM ventas
    GROUP BY MONTH(fecha_venta)
)
SELECT
    mes,
    total_facturado,
    CASE
        WHEN total_facturado > (SELECT AVG(total_facturado) FROM ventas_por_mes)
            THEN 'Por encima'
        ELSE 'Por debajo'
    END AS comparacion_promedio
FROM ventas_por_mes
ORDER BY mes;

-- ============================================================
-- Hallazgos (a partir de los resultados obtenidos sobre los 10
-- registros de prueba cargados en M3):
--
-- 1. El producto 1 (Laptop Pro 15) concentra $3.600 de los $6.444
--    facturados en total (≈56%), a pesar de ser una sola de las
--    seis referencias activas: es, por lejos, el principal motor
--    de ingresos y el primer candidato a monitorear si cae su venta.
--
-- 2. Los 5 clientes cargados hicieron exactamente 2 pedidos cada
--    uno, así que el 100% de la cartera actual aparece como
--    "recurrente" (>1 pedido). Esto es esperable porque M3 cargó
--    datos de prueba, no un historial real: en producción, lo
--    interesante de esta consulta va a ser detectar qué porcentaje
--    de clientes NO vuelve a comprar.
--
-- 3. Las 10 ventas cargadas caen todas dentro de marzo de 2024,
--    por lo que la Consulta 4 todavía no puede mostrar variación
--    real entre meses: el único mes registrado coincide con el
--    promedio general y queda etiquetado "Por debajo" (por no ser
--    estrictamente mayor). Esta consulta va a aportar valor real
--    recién cuando se cargue un historial de ventas de varios meses.
-- ============================================================