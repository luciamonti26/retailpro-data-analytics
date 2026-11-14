# RetailPro · Análisis de datos de ventas de tecnología

Proyecto del curso de **Data Analytics (Coderhouse)**. Recorre el ciclo completo de un análisis: definición del problema de negocio, modelado de datos, SQL, limpieza con Power Query, modelo en estrella con medidas DAX y diseño de un dashboard ejecutivo.

**Autora:** Lucía Monti

## Contenido del repositorio

| Archivo | Qué contiene |
|---|---|
| `ventas_tech_db.sql` | M3: crea la base `Ventas_Tech_DB` (categorias, clientes, productos y ventas) y carga datos de prueba |
| `m4_consultas_negocio.sql` | M4: resumen mensual, ranking de productos, clientes recurrentes y meses sobre/bajo el promedio |
| `m5_consultas_joins.sql` | M5: vista base con INNER JOIN, clientes y productos sin ventas (LEFT JOIN) y consolidado con UNION ALL |
| `Pipeline_ETL_Monti_Lucia.pbix` | M6: pipeline ETL en Power Query (limpieza y Merge) |
| `Monti_Lucia_Checkpoint2.pbix` | M8: modelo en estrella con relaciones 1:N, tabla calendario y tabla `_Medidas` |

## Herramientas

- **SQL Server y SSMS** (T-SQL) para la base de datos y las consultas
- **Power BI Desktop** con Power Query (M) y DAX
- **GitHub** para versionar y entregar el trabajo

## Cómo ejecutar los scripts SQL

1. Abrí **SQL Server Management Studio (SSMS)** y conectate a tu servidor local.
2. Ejecutá **primero** `ventas_tech_db.sql`: abrilo con *Archivo > Abrir > Archivo*, hacé clic en **Ejecutar** y verificá que las cuatro consultas finales devuelvan 4, 5, 6 y 10 filas. El script se puede correr varias veces porque borra y recrea las tablas.
3. Después ejecutá `m4_consultas_negocio.sql` y `m5_consultas_joins.sql`, que usan `USE Ventas_Tech_DB`. Las consultas usan sintaxis T-SQL (`MONTH()` y `TOP`, no `EXTRACT` ni `LIMIT`).

## Sobre los datos

Los datos de las bases son **ficticios y de prueba**: las consultas de M3 a M5 trabajan sobre 10 ventas de marzo de 2024. El pipeline de M6 y el modelo de M8 parten del archivo `Pipeline_ETL_Dataset.xlsx` (50 ventas entre enero de 2023 y julio de 2024), no de la base SQL.

## Modelo de datos (M8)

Esquema en estrella con `Fact_Ventas` conectada a `Dim_Clientes`, `Dim_Productos`, `Dim_Categorias` y `Dim_Fechas`, mediante relaciones 1:N con filtro en una sola dirección. La relación de categorías usa `Dim_Categorias[nombre_categoria]` → `Dim_Productos[categoria]` porque `Dim_Productos` conserva la categoría como texto y no como `id_categoria`; se verificó que los 4 nombres de categoría son únicos y que los 12 productos tienen correspondencia. La tabla `_Medidas` reúne las medidas DAX: Total Ventas, Ventas Online, Ventas YTD, Ventas LY, % Crecimiento Anual, Ticket Promedio, Clientes Activos y Participación Categoría %.
