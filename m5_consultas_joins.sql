-- ============================================================
-- Proyecto RetailPro 
-- Base de datos: Ventas_Tech_DB 
-- Dimensión geográfica usada: clientes.ciudad
-- ============================================================
USE Ventas_Tech_DB;
-- ============================================================
-- Consulta 1: Vista base del proyecto (INNER JOIN)
-- Cruza ventas con sus tres dimensiones (clientes, productos,
-- categorias) para obtener la fila que va a alimentar
-- Power BI en M6/M7: fecha, cliente, ciudad (geográfica), producto,
-- categoría, cantidad, precio unitario y total de venta.
-- ============================================================

SELECT
    v.fecha_venta,
    v.id_cliente,
    c.nombre              AS nombre_cliente,
    c.ciudad,                              -- columna geográfica para filtrar/agrupar en Power BI
    p.nombre_producto,
    cat.nombre_categoria,                  -- columna para agrupar por categoría
    v.cantidad,
    v.precio_unitario,
    v.cantidad * v.precio_unitario AS total_venta
FROM ventas v
INNER JOIN clientes   c   ON v.id_cliente   = c.id_cliente
INNER JOIN productos  p   ON v.id_producto  = p.id_producto
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta;

-- ============================================================
-- Consulta 2: Clientes sin ventas (LEFT JOIN)
-- Clientes registrados que todavía no hicieron ninguna compra.
-- ============================================================

SELECT
    c.nombre,
    c.email,
    c.fecha_registro
FROM clientes c
LEFT JOIN ventas v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;

-- Resultado esperado con los datos de M3: 0 filas. Los 5 clientes
-- de prueba tienen 2 compras cada uno, así que hoy no hay ningún cliente "sin ventas". 
-- La consulta queda lista para detectar este caso apenas se cargue un cliente nuevo sin compras.

-- ============================================================
-- Consulta 3: Productos sin ventas (LEFT JOIN)
-- Productos del catálogo que no tienen ninguna venta registrada.
-- ============================================================

SELECT
    p.nombre_producto,
    cat.nombre_categoria,
    p.precio
FROM productos p
LEFT JOIN categorias cat ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas v        ON p.id_producto  = v.id_producto
WHERE v.id_venta IS NULL;

-- Resultado esperado con los datos de M3: 0 filas. Los 6 productos
-- cargados tienen al menos una venta cada uno. Al igual que en la
-- Consulta 2, la lógica queda validada y lista para cuando el
-- catálogo real tenga productos sin movimiento (candidatos a
-- liquidar o dar de baja).

-- ============================================================
-- Consulta 4: Consolidado por canal (UNION ALL)
-- No hay un canal real en el esquema, así que se genera como
-- valor literal. Se usa como criterio la fecha de venta, partiendo
-- el mes en dos quincenas (antes y después del 10/03), ya que no
-- se modeló todavía una columna de sucursal/origen en M3.
-- ============================================================

WITH ventas_por_periodo AS (
    SELECT fecha_venta,
           cantidad * precio_unitario AS total,
           'Primera quincena' AS periodo
    FROM ventas
    WHERE fecha_venta <= '2024-03-09'

    UNION ALL

    SELECT fecha_venta,
           cantidad * precio_unitario AS total,
           'Segunda quincena' AS periodo
    FROM ventas
    WHERE fecha_venta > '2024-03-09'
)
SELECT
    periodo,
    COUNT(*)      AS cantidad_ventas,
    SUM(total)    AS total_facturado
FROM ventas_por_periodo
GROUP BY periodo;

-- ============================================================
-- Hallazgos sobre los registros de prueba cargados en M3:
--
-- 1. La vista base (Consulta 1) confirma lo que ya veníamos viendo
--    en M4: la Laptop Pro 15 (categoría Computación) aparece dos
--    veces entre las ventas más altas ($2.400 y $1.200), repartida
--    entre clientes de Buenos Aires y Tucumán — dos ciudades sin
--    ninguna otra venta en común.
--
-- 2. Las Consultas 2 y 3 devuelven 0 filas: ni hay clientes sin
--    compras ni productos sin movimiento en los datos de prueba.
--    Esto no es un error, es consistente con que M3 cargó un set
--    de datos armado a propósito para que todo tenga actividad;
--    ambas consultas van a empezar a aportar valor real recién con
--    un catálogo y una base de clientes más grandes.
--
-- 3. Al partir marzo en dos quincenas (Consulta 4), la facturación
--    quedó casi pareja: $3.230 en la primera mitad del mes contra
--    $3.214 en la segunda (diferencia menor al 1%). Con un dataset
--    tan chico esto es más una coincidencia que una tendencia, pero
--    la consulta queda lista para usarse con un canal real
--    (Online/Presencial, o sucursal) cuando el modelo lo incorpore.
-- ============================================================