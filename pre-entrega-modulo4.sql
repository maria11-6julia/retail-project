-- PRE-ENTREGA MODULO 4: CONSULTAS MULTICAPA PARA ANALISIS DE NEGOCIO
-- Motor: PostgreSQL

DROP TABLE IF EXISTS ventas;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS categorias;
DROP TABLE IF EXISTS clientes;

CREATE TABLE clientes (
    id_cliente SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    fecha_registro DATE NOT NULL
);

CREATE TABLE categorias (
    id_categoria SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE productos (
    id_producto SERIAL PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    id_categoria INTEGER NOT NULL,
    precio DECIMAL(10,2) NOT NULL CHECK (precio > 0),
    stock INTEGER NOT NULL CHECK (stock >= 0),
    CONSTRAINT fk_producto_categoria FOREIGN KEY (id_categoria)
        REFERENCES categorias(id_categoria)
);

CREATE TABLE ventas (
    id_venta SERIAL PRIMARY KEY,
    id_cliente INTEGER NOT NULL,
    id_producto INTEGER NOT NULL,
    cantidad INTEGER NOT NULL CHECK (cantidad > 0),
    fecha_venta DATE NOT NULL,
    CONSTRAINT fk_venta_cliente FOREIGN KEY (id_cliente)
        REFERENCES clientes(id_cliente),
    CONSTRAINT fk_venta_producto FOREIGN KEY (id_producto)
        REFERENCES productos(id_producto)
);

BEGIN;

INSERT INTO clientes (nombre, apellido, email, fecha_registro) VALUES
('María','Gómez','maria.gomez@email.com','2026-09-01'),
('Juan','Pérez','juan.perez@email.com','2026-09-02'),
('Lucía','Fernández','lucia.fernandez@email.com','2026-09-03'),
('Carlos','Rodríguez','carlos.rodriguez@email.com','2026-09-04'),
('Sofía','Martínez','sofia.martinez@email.com','2026-09-05'),
('Ana','López','ana.lopez@email.com','2026-09-06');

INSERT INTO categorias (nombre) VALUES
('Tecnología'),('Indumentaria'),('Calzado');

INSERT INTO productos (nombre, id_categoria, precio, stock) VALUES
('Notebook Lenovo IdeaPad',1,850000.00,10),
('Mouse Logitech M185',1,25000.00,30),
('Teclado Redragon Kumara',1,75000.00,15),
('Remera básica',2,18000.00,50),
('Zapatillas deportivas',3,95000.00,20);

INSERT INTO ventas (id_cliente, id_producto, cantidad, fecha_venta) VALUES
(1,1,1,'2026-09-06'),
(1,2,2,'2026-09-12'),
(1,2,1,'2026-09-20'),
(2,1,1,'2026-09-07'),
(2,3,2,'2026-09-15'),
(3,4,3,'2026-09-09'),
(3,4,2,'2026-09-18'),
(4,5,1,'2026-09-10'),
(4,5,2,'2026-09-22'),
(5,2,3,'2026-09-11');

COMMIT;

-- 1. RENTABILIDAD POR CATEGORIA
-- Problema de negocio: identificar las categorías con mayor
-- volumen de unidades vendidas e ingreso total para apoyar
-- decisiones comerciales y de stock.
-- Umbral definido en 2 unidades vendidas para mostrar
-- categorías con un volumen relevante en este ejemplo.

SELECT
    c.nombre AS categoria,
    SUM(v.cantidad) AS unidades_vendidas,
    SUM(v.cantidad * p.precio) AS ingreso_total
FROM ventas AS v
INNER JOIN productos AS p ON v.id_producto = p.id_producto
INNER JOIN categorias AS c ON p.id_categoria = c.id_categoria
GROUP BY c.nombre
HAVING SUM(v.cantidad) > 2
ORDER BY ingreso_total DESC;

-- 2. CLIENTES SIN COMPRAS
-- Problema de negocio: detectar clientes registrados que aún
-- no realizaron compras para analizar oportunidades de contacto,
-- fidelización o campañas.
-- COALESCE muestra 0 en lugar de NULL.

SELECT
    c.id_cliente,
    c.nombre,
    c.apellido,
    c.email,
    COALESCE(COUNT(v.id_venta), 0) AS cantidad_compras
FROM clientes AS c
LEFT JOIN ventas AS v ON c.id_cliente = v.id_cliente
GROUP BY c.id_cliente, c.nombre, c.apellido, c.email
HAVING COUNT(v.id_venta) = 0
ORDER BY c.id_cliente;

-- 3. TOP DE COMPRAS POR CLIENTE
-- Problema de negocio: conocer el producto que cada cliente
-- compró con mayor frecuencia y la fecha de su última
-- transacción para comprender hábitos de compra.
-- La primera subconsulta agrupa por cliente y producto;
-- ROW_NUMBER permite elegir el producto principal de cada cliente.

WITH compras_por_cliente_producto AS (
    SELECT
        c.id_cliente,
        c.nombre,
        c.apellido,
        p.nombre AS producto,
        SUM(v.cantidad) AS unidades_compradas,
        MAX(v.fecha_venta) AS ultima_transaccion
    FROM clientes AS c
    INNER JOIN ventas AS v ON c.id_cliente = v.id_cliente
    INNER JOIN productos AS p ON v.id_producto = p.id_producto
    GROUP BY c.id_cliente, c.nombre, c.apellido, p.id_producto, p.nombre
),
ranking_productos AS (
    SELECT
        id_cliente,
        nombre,
        apellido,
        producto,
        unidades_compradas,
        ultima_transaccion,
        ROW_NUMBER() OVER (
            PARTITION BY id_cliente
            ORDER BY unidades_compradas DESC, ultima_transaccion DESC
        ) AS posicion
    FROM compras_por_cliente_producto
)
SELECT
    nombre,
    apellido,
    producto AS producto_mas_comprado,
    unidades_compradas,
    ultima_transaccion
FROM ranking_productos
WHERE posicion = 1
ORDER BY id_cliente;
