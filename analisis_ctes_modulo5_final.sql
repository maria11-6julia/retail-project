-- ============================================================
-- MODULO 5: ANALISIS DE VENTAS CON CTE
-- Archivo: modulo_5/analisis_ctes.sql
-- Motor: PostgreSQL
-- Proyecto: Retail Project
-- ============================================================

-- OBJETIVO:
-- Obtener el total de ventas por región y mostrar únicamente
-- las regiones cuyo total supera el promedio general de los
-- montos de las ventas individuales.

-- ADAPTACION A LA BASE DEL PROYECTO:
-- En el script anterior de Retail Project, la tabla ventas
-- contiene cantidad y fecha_venta, pero no contiene monto ni
-- id_region. Por eso, este bloque agrega esas columnas y crea
-- la tabla regiones si todavía no existen.
-- El monto se calcula como cantidad * precio del producto.
-- Las regiones de ejemplo se asignan según el id_cliente para
-- que el ejercicio pueda ejecutarse con los datos del proyecto.

BEGIN;

CREATE TABLE IF NOT EXISTS regiones (
    id_region SERIAL PRIMARY KEY,
    nombre_region VARCHAR(100) NOT NULL UNIQUE
);

INSERT INTO regiones (nombre_region)
VALUES
    ('Buenos Aires'),
    ('Centro'),
    ('Norte')
ON CONFLICT (nombre_region) DO NOTHING;

ALTER TABLE ventas
    ADD COLUMN IF NOT EXISTS id_region INTEGER;

ALTER TABLE ventas
    ADD COLUMN IF NOT EXISTS monto DECIMAL(12,2);

-- Completa el monto de cada venta usando la cantidad y el
-- precio vigente del producto correspondiente.
UPDATE ventas AS v
SET monto = v.cantidad * p.precio
FROM productos AS p
WHERE v.id_producto = p.id_producto
  AND v.monto IS NULL;

-- Asigna una región de ejemplo a las ventas que todavía no
-- tienen región. La asignación es reproducible por cliente.
UPDATE ventas AS v
SET id_region = CASE
    WHEN v.id_cliente IN (1, 4) THEN (
        SELECT r.id_region FROM regiones AS r
        WHERE r.nombre_region = 'Buenos Aires'
    )
    WHEN v.id_cliente IN (2, 5) THEN (
        SELECT r.id_region FROM regiones AS r
        WHERE r.nombre_region = 'Centro'
    )
    ELSE (
        SELECT r.id_region FROM regiones AS r
        WHERE r.nombre_region = 'Norte'
    )
END
WHERE v.id_region IS NULL;

COMMIT;

-- ============================================================
-- INFORME DE RENDIMIENTO REGIONAL
-- ============================================================

-- CTE: ventas_por_region
-- Agrupa las ventas por región y calcula el total vendido.
-- Los JOIN permiten relacionar cada venta con su región y
-- con el producto asociado.

WITH ventas_por_region AS (
    SELECT
        r.nombre_region AS region,
        SUM(v.monto) AS total_ventas
    FROM ventas AS v
    INNER JOIN regiones AS r
        ON v.id_region = r.id_region
    INNER JOIN productos AS p
        ON v.id_producto = p.id_producto
    GROUP BY
        r.id_region,
        r.nombre_region
)

-- CONSULTA PRINCIPAL:
-- Compara el total acumulado de cada región con el promedio
-- general de los montos de todas las ventas individuales.
-- Muestra solo las regiones que superan ese promedio y ordena
-- los resultados desde la mayor hasta la menor venta.

SELECT
    region,
    total_ventas
FROM ventas_por_region
WHERE total_ventas > (
    SELECT AVG(v2.monto)
    FROM ventas AS v2
)
ORDER BY total_ventas DESC;
