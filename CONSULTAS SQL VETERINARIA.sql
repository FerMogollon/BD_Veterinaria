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