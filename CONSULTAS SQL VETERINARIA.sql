-- Este es el archivo con las consultas SQL desarrolladas para el proyecto. 

-- Mascotas más atendidas en el mes actual
select m.nombre mascota, count(c.id_mascota) veces_atendido
from mascota m
join cita c on m.id_mascota = c.id_mascota 
where extract(month from c.fecha) = extract(month from current_date) 
and extract(year from c.fecha) = extract(year from current_date)
group by m.id_mascota, m.nombre  
order by count(c.id_mascota) desc
limit 5; 

-- Veterinarios ordenados segun el mayor numero de citas en el segundo trimestre
select v.nombre veterinario, count(c.id_cita) numero_citas 
from veterinario v 
join cita c on v.id_veterinario = c.id_veterinario 
where extract(month from c.fecha) between 4 and 6
and extract(year from c.fecha) = extract(year from current_date)
group by veterinario, v.id_veterinario 
order by numero_citas desc; 

--  Medicamentos prescritos con mayor frecuencia
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

-- Propietarios con mascotas quehan asistido 
-- a citas en los últimos 6 meses 
-- este sale con un left join dandole where donde todos son null del lado de citas
-- usar nulls first
select p.nombre propietario, m.nombre mascota
from propietario p 
join mascota m on p.id_propietario = m.id_propietario
left join cita c on m.id_mascota = c.id_mascota 
and c.fecha >= current_date - interval '6 months'
order by propietario; 

-- propietarios con más de una mascota
select p.nombre propietario, string_agg(m.nombre, ', ') mascotas,
count(m.id_mascota) cantidad_mascotas
from propietario p 
join mascota m on p.id_propietario = m.id_propietario 
group by propietario
having count(m.id_mascota) > 1
order by cantidad_mascotas desc;








