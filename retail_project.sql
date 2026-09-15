-- ============================================================
-- PRE-ENTREGA: TABLAS PRINCIPALES CON RESTRICCIONES Y DATOS
-- Proyecto: Retail Project
-- Motor: PostgreSQL
-- ============================================================

-- 1. CREACIÓN DE LA BASE DE DATOS
CREATE DATABASE retail_project;

-- Luego de crear la base, conectarse a retail_project
-- y ejecutar el resto del script.

-- 2. CREACIÓN DE TABLAS

-- Tabla clientes
CREATE TABLE clientes (
    id_cliente SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    edad INTEGER NOT NULL CHECK (edad >= 18),
    fecha_registro DATE NOT NULL
);

-- Tabla productos
CREATE TABLE productos (
    id_producto SERIAL PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    categoria VARCHAR(100) NOT NULL,
    precio DECIMAL(10,2) NOT NULL CHECK (precio > 0),
    stock INTEGER NOT NULL CHECK (stock >= 0)
);

-- Tabla ventas: se crea después de clientes y productos
CREATE TABLE ventas (
    id_venta SERIAL PRIMARY KEY,
    id_cliente INTEGER NOT NULL,
    id_producto INTEGER NOT NULL,
    cantidad INTEGER NOT NULL CHECK (cantidad > 0),
    fecha_venta DATE NOT NULL,

    CONSTRAINT fk_venta_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES clientes(id_cliente),

    CONSTRAINT fk_venta_producto
        FOREIGN KEY (id_producto)
        REFERENCES productos(id_producto)
);

-- 3. CARGA INICIAL DE DATOS
BEGIN;

-- Clientes
INSERT INTO clientes
    (nombre, apellido, email, edad, fecha_registro)
VALUES
    ('María', 'Gómez', 'maria.gomez@email.com', 28, '2026-09-01'),
    ('Juan', 'Pérez', 'juan.perez@email.com', 35, '2026-09-02'),
    ('Lucía', 'Fernández', 'lucia.fernandez@email.com', 24, '2026-09-03'),
    ('Carlos', 'Rodríguez', 'carlos.rodriguez@email.com', 42, '2026-09-04'),
    ('Sofía', 'Martínez', 'sofia.martinez@email.com', 31, '2026-09-05');

-- Productos
INSERT INTO productos
    (nombre, categoria, precio, stock)
VALUES
    ('Notebook Lenovo IdeaPad', 'Tecnología', 850000.00, 10),
    ('Mouse Logitech M185', 'Tecnología', 25000.00, 30),
    ('Teclado Redragon Kumara', 'Tecnología', 75000.00, 15),
    ('Remera básica', 'Indumentaria', 18000.00, 50),
    ('Zapatillas deportivas', 'Calzado', 95000.00, 20);

-- Ventas
INSERT INTO ventas
    (id_cliente, id_producto, cantidad, fecha_venta)
VALUES
    (1, 1, 1, '2026-09-06'),
    (2, 2, 2, '2026-09-07'),
    (3, 3, 1, '2026-09-08'),
    (4, 4, 3, '2026-09-09'),
    (5, 5, 1, '2026-09-10');

COMMIT;

-- 4. CONSULTAS PREVIAS
SELECT *
FROM productos
WHERE categoria = 'Tecnología';

SELECT *
FROM ventas
WHERE id_venta = 5;

-- 5. UPDATE MASIVO DE PRECIOS
UPDATE productos
SET precio = precio * 1.10
WHERE categoria = 'Tecnología';

SELECT *
FROM productos
WHERE categoria = 'Tecnología';

-- 6. DELETE DE UNA VENTA ESPECÍFICA
DELETE FROM ventas
WHERE id_venta = 5;

SELECT *
FROM ventas
WHERE id_venta = 5;

-- 7. CONSULTAS FINALES DE VERIFICACIÓN
SELECT * FROM clientes;
SELECT * FROM productos;
SELECT * FROM ventas;
