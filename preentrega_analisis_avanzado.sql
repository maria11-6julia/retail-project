-- Pre-entrega: Script de análisis avanzado con Window Functions
-- Objetivo: generar un reporte mensual por categoría con ventas, ranking,
-- acumulado histórico y comparación contra el promedio de la categoría.
--
-- Estructura de tablas asumida:
--   ventas(id_producto, fecha_venta, monto)
--   productos(id_producto, id_categoria)
--   categorias(id_categoria, nombre_categoria)
--
-- Si en tu base de datos algún campo tiene otro nombre, habrá que ajustar
-- únicamente ese nombre en los JOIN o en la selección correspondiente.

WITH ventas_mensuales AS (
    -- Agrupa las ventas por mes y categoría.
    SELECT
        DATE_TRUNC('month', v.fecha_venta)::date AS mes,
        c.nombre_categoria AS categoria,
        SUM(v.monto) AS venta_total
    FROM ventas AS v
    INNER JOIN productos AS p
        ON v.id_producto = p.id_producto
    INNER JOIN categorias AS c
        ON p.id_categoria = c.id_categoria
    GROUP BY
        DATE_TRUNC('month', v.fecha_venta)::date,
        c.nombre_categoria
),

metricas_ventana AS (
    -- Calcula el ranking mensual y el acumulado de cada categoría.
    SELECT
        mes,
        categoria,
        venta_total,
        RANK() OVER (
            PARTITION BY mes
            ORDER BY venta_total DESC
        ) AS ranking_categoria,
        SUM(venta_total) OVER (
            PARTITION BY categoria
            ORDER BY mes
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS ventas_acumuladas,
        AVG(venta_total) OVER (
            PARTITION BY categoria
        ) AS promedio_historico_categoria
    FROM ventas_mensuales
)

-- Reporte final: compara la venta mensual con el promedio histórico
-- de la misma categoría y devuelve exactamente las etiquetas solicitadas.
SELECT
    TO_CHAR(mes, 'YYYY-MM') AS mes_venta,
    categoria,
    venta_total,
    ranking_categoria,
    ventas_acumuladas,
    CASE
        WHEN venta_total >= promedio_historico_categoria THEN 'Exitoso'
        ELSE 'Bajo el promedio'
    END AS comparativa
FROM metricas_ventana
ORDER BY
    mes,
    ranking_categoria,
    categoria;
