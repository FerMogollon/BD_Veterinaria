-- Este es el archivo con las consultas SQL desarrolladas para el proyecto. 

-- Mascotas más atendidas en el mes y año actuales
select m.nombre mascota, count(c.id_mascota) veces_atendido
from mascota m
join cita c on m.id_mascota = c.id_mascota 
where extract(month from c.fecha) = extract(month from current_date) 
and extract(year from c.fecha) = extract(year from current_date)
group by m.id_mascota, m.nombre  
order by count(c.id_mascota) desc
limit 5; 

-- Veterinarios ordenados segun el mayor numero de citas en el segundo trimestre del año actual
select v.nombre veterinario, count(c.id_cita) numero_citas 
from veterinario v 
join cita c on v.id_veterinario = c.id_veterinario 
where extract(month from c.fecha) between 4 and 6
and extract(year from c.fecha) = extract(year from current_date)
group by veterinario, v.id_veterinario 
order by numero_citas desc; 

-- Medicamentos prescritos con mayor frecuencia
select i.descripcion medicamento, count(t.id_medicamento) veces_prescrito
from medicamento m
join tratamiento t on m.id_medicamento = t.id_medicamento
join item_facturable i on m.id_medicamento = i.id_item
group by m.id_medicamento, i.descripcion
order by veces_prescrito desc
limit 3;

-- Ingresos totales por especialidad veterinaria
select e.nombre especialidad,
sum(f.monto) ingresos_totales
from especialidad e
join veterinario_especialidad ve on e.id_especialidad = ve.id_especialidad
join veterinario v on ve.id_veterinario = v.id_veterinario
join cita c on v.id_veterinario = c.id_veterinario
join factura f on c.id_cita = f.id_cita
group by e.id_especialidad, e.nombre
order by ingresos_totales desc;

-- Propietarios con mascotas que han asistido a citas en los últimos 6 meses
select distinct p.nombre propietario, m.nombre mascota
from propietario p
join mascota m on p.id_propietario = m.id_propietario
join cita c on m.id_mascota = c.id_mascota
where c.fecha >= current_date - interval '6 months'
order by propietario;

-- Propietarios con más de una mascota
select p.nombre propietario, string_agg(m.nombre, ', ' order by m.nombre) mascotas,
count(m.id_mascota) cantidad_mascotas
from propietario p 
join mascota m on p.id_propietario = m.id_propietario 
group by propietario
having count(m.id_mascota) > 1
order by cantidad_mascotas desc;


-- Consultas de pruebas

--VER QUE LOS MONTOS COINCIDAN EN LAS FACTURAS
--select
--    f.num_factura,
--    f.monto as monto_guardado,
--    coalesce(sum(df.precio_unitario * df.cantidad),0) as monto_calculado
--from factura f
--left join detalle_factura df
--    on f.num_factura = df.num_factura
--group by f.num_factura, f.monto
--having f.monto <> coalesce(sum(df.precio_unitario * df.cantidad),0);



--ACTUALIZAR CIERTAS FACTURAS
update factura set id_propietario = 13
where id_cita = 15;

-- esta de aqui da error, validando el funcionamiento de nuestro trigger validar dueño factura
-- update factura
-- set id_propietario = 13
-- where id_cita = 13;

update factura set id_propietario = 2
where id_cita = 13;

update factura set id_propietario = 12
where id_cita = 14;



--CONFIRMAR Q LOS IDS DE LAS FACTURAS COINCIDAN CON LOS PROPIETARIOS DE LAS MASCOTAS
select
   f.num_factura,
   f.id_cita,
   c.id_mascota,
   m.id_propietario as propietario_correcto,
   f.id_propietario as propietario_en_factura
from factura f
join cita c on f.id_cita = c.id_cita
join mascota m on c.id_mascota = m.id_mascota
where f.id_propietario <> m.id_propietario;




--REVISAR Q TODOS LOS DIAGNOSTICOS EXISTAN
--select *
--from tratamiento t
--left join diagnostico d
--on t.id_diagnostico = d.id_diagnostico
--where d.id_diagnostico is null;




--REVISAR Q TODOS LOS DIAGNOSTICOS TENGAN PROCEDIMIENTOS VALIDOS
--select *
--from diagnostico_procedimiento dp
--left join procedimiento p
--on dp.id_procedimiento = p.id_procedimiento
--where p.id_procedimiento is null;




--VERIFICAR Q LOS PRECIOS COINCIDAN
--select
--    df.num_factura,
--    df.id_item,
--    df.precio_unitario,
--    i.costo
--from detalle_factura df
--join item_facturable i
--    on df.id_item = i.id_item
--where df.precio_unitario <> i.costo;
--
--select id_item, descripcion, costo
--from item_facturable
--order by id_item;
--
--select id_item, cantidad, precio_unitario, id_detalle    
--from detalle_factura
--order by id_item;

update detalle_factura set precio_unitario = 12 where id_item = 12;
update detalle_factura set precio_unitario = 12 where id_item = 1;
update detalle_factura set precio_unitario = 15 where id_item = 10;
update detalle_factura set precio_unitario = 22 where id_item = 11;
update detalle_factura set precio_unitario = 18 where id_item = 13;
update detalle_factura set precio_unitario = 20 where id_item = 15;
update detalle_factura set precio_unitario = 9 where id_item = 18;
update detalle_factura set precio_unitario = 15 where id_item = 22;
update detalle_factura set precio_unitario = 350 where id_item = 29;
update detalle_factura set precio_unitario = 30 where id_item = 33;


--REVISAR LAS FACTURAS
--select f.num_factura, f.fecha, p.nombre as propietario,m.nombre as mascota,
--    string_agg(i.descripcion || ' (x' || df.cantidad || ', $' || df.precio_unitario || ')', ' | ' order by df.id_detalle) as detalles, f.monto
--from factura f
--join cita c
--    on f.id_cita = c.id_cita
--join mascota m
--    on c.id_mascota = m.id_mascota
--join propietario p
--    on m.id_propietario = p.id_propietario
--join detalle_factura df
--    on f.num_factura = df.num_factura
--join item_facturable i
--    on df.id_item = i.id_item
--group by
--    f.num_factura,
--    f.fecha,
--    p.nombre,
--    m.nombre,
--    f.monto
--order by f.num_factura;



-- SELECTS DE PRUEBA PARA VALIDAR EL FUNCIONAMIENTO DE LOS TRIGGERS

-- PROBAR EL TRIGGER actualizar_monto_factura
-- Consultar el monto actual de la Factura 1
select num_factura, monto from factura where num_factura = 1;

-- Insertar un nuevo detalle de $50 (2 unidades a $25)
insert into detalle_factura (precio_unitario, cantidad, num_factura, id_item) 
values (25.00, 2, 1, 1);

-- Verificar que el monto de la Factura 1 sumó esos $50 exactos
select num_factura, monto from factura where num_factura = 1;

-- Borrar el detalle que acabamos de meter y ver como el monto vuelve a bajar
delete from detalle_factura where id_item = 1 and cantidad = 2 and num_factura = 1;

select num_factura, monto from factura where num_factura = 1;



-- PROBAR TRIGGER verificar_alerta_medicamento
-- Agregar 'Perro' a las precauciones del medicamento 12
update medicamento 
set precauciones = 'Totalmente contraindicado para Perro' 
where id_medicamento = 12;

-- Intentar recetarlo al diagnóstico 1 que sabemos que le pertenece al perro Max
insert into tratamiento (frecuencia, dosis, vigencia, descripcion, id_diagnostico, id_medicamento) 
values ('Cada 8 horas', '1 pastilla', '2026-12-31', 'Prueba de bloqueo por alergia', 1, 12);

-- Revertir cambios
update medicamento 
set precauciones = 'No administrar a animales con historial de alergia a la penicilina.' 
where id_medicamento = 12;



-- PROBAR TRIGGER actualizar_inventario
-- Ver el stock actual del medicamento 13
select id_medicamento, stock from medicamento where id_medicamento = 13;

-- Escenario A: Compra exitosa (descuenta 5 unidades)
insert into detalle_factura (precio_unitario, cantidad, num_factura, id_item) 
values (15.00, 5, 1, 13);

-- Comprobar que el stock ha bajado
select id_medicamento, stock from medicamento where id_medicamento = 13;

-- Escenario B: Intento de compra masiva sin stock
insert into detalle_factura (precio_unitario, cantidad, num_factura, id_item) 
values (15.00, 5000, 1, 13);



-- PROBAR TRIGGER actualizacion_citas 
-- Insertar una cita con fecha del anio pasado, pero mandando el estado como 'Programada'
insert into cita (fecha, hora, consultorio, estado, id_mascota, id_veterinario) 
values ('2023-01-01', '10:00:00', 'Consultorio X', 'Programada', 1, 1);

-- Verificar que hizo la base con dicho registro
select id_cita, fecha, estado 
from cita 
order by id_cita desc limit 1;


-- PROBAR TRIGGER seguridad_facturacion
-- La cita 1 le pertenece a Max el dueño es Cyndi Beggini de ID 1.
-- Intentar meterle esa factura al Propietario 99.
insert into Factura (fecha, monto, id_cita, id_propietario) 
values ('2026-06-19', 0, 1, 99);




-- PROBAR TRIGGER procesar_pago_estado
-- Crear una cita nueva
insert into cita (fecha, hora, consultorio, estado, id_mascota, id_veterinario) 
values ('2026-06-28', '12:00:00', 'Consultorio B', 'Programada', 1, 1);

-- Crear su factura correspondiente (Monto inicia en 0)
insert into factura (fecha, monto, id_cita, id_propietario) 
values ('2026-06-28', 0, (select max(id_cita) from cita), 1);

-- Cargarle una "Esterilización felina" que cuesta $160
insert into detalle_factura (precio_unitario, cantidad, num_factura, id_item) 
values (160.00, 1, (select max(num_factura) from factura), 24);

-- El cliente pasa a caja pero solo abona $50 en efectivo
insert into pago (monto, metodo_pago, num_factura) 
values (50.00, 'Efectivo', (select max(num_factura) from factura));

-- Revisar el resultado, debe de mostrar estado_pago parcial
select f.num_factura, f.monto as total_a_pagar, sum(p.monto) as total_abonado, f.estado_pago, c.estado as estado_cita
from factura f 
left join pago p on f.num_factura = p.num_factura 
join cita c on f.id_cita = c.id_cita
where f.num_factura = (select max(num_factura) from factura)
group by f.num_factura, f.monto, f.estado_pago, c.estado;