# Retail Project

Proyecto de pre-entrega para la creación de una base de datos de un negocio retail utilizando PostgreSQL.

## Contenido

El proyecto incluye:

- Base de datos `retail_project`.
- Tabla `clientes`.
- Tabla `productos`.
- Tabla `ventas`.
- Claves primarias y claves foráneas.
- Restricciones `CHECK` para garantizar la integridad de los datos.
- Carga inicial de datos mediante una transacción `BEGIN ... COMMIT`.
- Actualización masiva de precios utilizando `UPDATE` y `WHERE`.
- Eliminación de una venta específica utilizando `DELETE` y `WHERE`.

## Cómo ejecutar el proyecto

1. Abrir PostgreSQL mediante pgAdmin, DBeaver o una herramienta equivalente.
2. Ejecutar primero:

```sql
CREATE DATABASE retail_project;
```

3. Conectarse a la base de datos `retail_project`.
4. Ejecutar el resto del archivo `retail_project.sql`.
5. Verificar los datos mediante los `SELECT` incluidos al final del script.

## Archivos

- `retail_project.sql`: contiene la creación de la base de datos, tablas, restricciones, carga de datos y operaciones de mantenimiento.
- `README.md`: contiene la descripción y las instrucciones para ejecutar el proyecto.
