
# VETERINARIA 

Esta base de datos está diseñada para gestionar de manera integral las operaciones de una clínica veterinaria. Permite el almacenamiento seguro y centralizado de la información de los pacientes (mascotas) y sus propietarios, el seguimiento detallado de las consultas médicas, diagnósticos y tratamientos, así como la programación de citas y el control del historial clínico completo de cada animal.


# Configuración de la base de datos


Sigue los pasos descritos a continuación para crear la base de datos, generar el esquema completo y cargar los datos iniciales necesarios para el funcionamiento del sistema de gestión de la veterinaria. El proyecto emplea PostgreSQL como sistema gestor de base de datos, ejecutado en Docker y administrado a través de DBeaver.


## 1. Crear la base de datos

Ejecuta el siguiente comando:

```bash
docker exec -it [NOMBRE_CONTENEDOR] psql -U postgres -c "CREATE DATABASE [NOMBRE_BASE];"
```

## 2. Crear el esquema (tablas)

1. Abre la terminal y navega hasta la carpeta del repositorio ocupando:
```bash
cd .\BD_Veterinaria\
```
o directamente abre la terminal en la carpeta.

**Nota:** Si estás utilizando Docker, antepone `docker` a los comandos `cp` y `exec`.

2. Ejecuta el siguiente comando en la teminal:
```bash
cp '.\DDL VETERINARIA' [NOMBRE CONTENEDOR]:/tmp/script1.sql
```

*Si se ejecuto correctamente recibiras el siguiente mensaje:*
```bash
Successfully copied 7.56kB (transferred 9.22kB) to postgres-db:/tmp/script1.sql
 ```

3. Ejecuta el siguiente comando en la terminal:
```bash
exec -it [NOMBRE CONTENEDOR] psql -U postgres -d [NOMBRE BASE] -f /tmp/script1.sql 
```

*Si el script se ejecutó correctamente, deberías obtener una salida similar a la siguiente:*
```bash
CREATE TABLE
CREATE TABLE
ALTER TABLE
ALTER TABLE
.
.
.
CREATE TABLE
CREATE TABLE
CREATE FUNCTION
CREATE TRIGGER
```

## 3. Agregar las restricciones y triggers

1. Abre la terminal y navega hasta la carpeta del repositorio ocupando:
```bash
cd .\BD_Veterinaria\
```
o directamente abre la terminal en la carpeta.

**Nota:** Si estás utilizando Docker, antepone `docker` a los comandos `cp` y `exec`.

2. Ejecuta el siguiente comando en la teminal:
```bash
cp '.\TRIGGERS VETERINARIA.sql'  [NOMBRE CONTENEDOR]:/tmp/script2.sql
```

*Si se ejecuto correctamente recibiras el siguiente mensaje:*
```bash
Successfully copied 7.56kB (transferred 9.22kB) to postgres-db:/tmp/script2.sql
 ```

3. Ejecuta el siguiente comando en la terminal:
```bash
exec -it [NOMBRE CONTENEDOR] psql -U postgres -d [NOMBRE BASE] -f /tmp/script2.sql 
```

*Si el script se ejecutó correctamente, deberías obtener una salida similar a la siguiente:*
```bash
CREATE FUNCTION
CREATE TRIGGER
CREATE FUNCTION
.
.
.
CREATE TRIGGER
CREATE FUNCTION
CREATE TRIGGER
```
## 4. Cargar los datos iniciales

1. Verifica que la terminal sigua en la carpeta del repositorio, en caso de contrario abre la terminal y navega hasta la carpeta del repositorio ocupando:
```bash
cd .\BD_Veterinaria\
```
o directamente abre la terminal en la carpeta.

**Nota:** Si estás utilizando Docker, antepone `docker` a los comandos `cp` y `exec`.

2. Ejecuta el siguiente comando en la teminal:
```bash
cp '.\DML VETERINARIA.sql' [NOMBRE CONTENEDOR]:/tmp/script3.sql
```

*Si se ejecuto correctamente recibiras el siguiente mensaje:*
```bash
Successfully copied 41.1kB (transferred 43kB) to postgres-db:/tmp/script3.sql
 ```

3. Ejecuta el siguiente comando en la terminal:
```bash
exec -it [NOMBRE CONTENEDOR] psql -U postgres -d [NOMBRE BASE] -f /tmp/script3.sql
```

*Si el script se ejecutó correctamente, deberías obtener una salida similar a la siguiente:*
```bash
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
.
.
.
UPDATE 6
UPDATE 1
UPDATE 2
UPDATE 1
UPDATE 1
```
