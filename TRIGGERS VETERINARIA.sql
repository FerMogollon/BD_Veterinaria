-- Triggers para regular integridad referencial, automatizacion y procesamiento de los datos

-- Calcular el monto total en la factura al utilizar la cantidad y el precio unitario de detalle_factura
create or replace function actualizar_monto_factura()
returns trigger as $$
declare
    v_num_factura bigint;
begin
    -- Evaluar que tipo de operacion se está haciendo para evitar el error de NEW
    if TG_OP = 'DELETE' then
        v_num_factura := OLD.num_factura;
    else
        v_num_factura := NEW.num_factura;
    end if;

    -- Recalcular el total de la factura
    update factura
    set monto = (
        select coalesce(
            sum(precio_unitario * cantidad),
            0
        )
        from detalle_factura
        where num_factura = v_num_factura
    )
    where num_factura = v_num_factura;

    -- Retornar la variable correcta segun la operación
    if TG_OP = 'DELETE' then
        return OLD;
    else
        return NEW;
    end if;
end;
$$ language plpgsql;

create trigger trg_actualizar_monto_factura
after insert or update or delete
on detalle_factura
for each row
execute function actualizar_monto_factura();


-- Controlar posibles alergias al cruzar la especie de la mascota con las precauciones del medicamento
create or replace function verificar_alergia_medicamento()
returns trigger as $$
declare
    v_especie_mascota varchar(150);
    v_nombre_mascota varchar(150);
    v_precauciones_medicamento varchar(500);
    v_nombre_medicamento varchar(500);
begin
    select m.Especie, m.Nombre 
    into v_especie_mascota, v_nombre_mascota
    from Diagnostico d
    join Cita c on d.ID_Cita = c.ID_Cita
    join Mascota m on c.ID_Mascota = m.ID_Mascota
    where d.ID_Diagnostico = new.ID_Diagnostico;

    select med.Precauciones, item.Descripcion 
    into v_precauciones_medicamento, v_nombre_medicamento
    from Medicamento med
    join Item_Facturable item on med.ID_Medicamento = item.ID_Item
    where med.ID_Medicamento = new.ID_Medicamento;

    if v_precauciones_medicamento ilike '%' || v_especie_mascota || '%' then
        raise exception 'ALERTA VETERINARIA: La mascota "%" es de especie "%". El medicamento "%" indica contraindicacion/alergia: "%". Registro denegado.', 
            v_nombre_mascota, v_especie_mascota, v_nombre_medicamento, v_precauciones_medicamento;
    end if;

    return new;
end;
$$ language plpgsql;

-- Asignar el disparador de alergias a la tabla Tratamiento
create trigger trg_verificar_alergia_medicamento
before insert or update on Tratamiento
for each row
execute function verificar_alergia_medicamento();


-- Verificar disponibilidad y descontar existencias del inventario de medicamentos
create or replace function verificar_inventario_medicamento() 
returns trigger as $$
declare 
    v_stock_actual int;
begin
    select stock into v_stock_actual
    from Medicamento
    where ID_Medicamento = new.ID_Item;
    
    if v_stock_actual is not null then 
        if v_stock_actual < new.cantidad then 
            raise exception 'Inventario insuficiente para el medicamento ID: %. Disponible: %, Solicitado: %', new.ID_Item, v_stock_actual, new.cantidad;
        end if;

        update Medicamento
        set stock = stock - new.cantidad
        where ID_Medicamento = new.ID_Item;
    end if;

	-- Permitir el registro sin alterar inventario al tratarse de un procedimiento medico
    return new;
end;
$$ language plpgsql;

-- Ejecutar validacion de inventario al insertar un detalle en la factura
create trigger trg_actualizar_inventario 
before insert on detalle_factura
for each row
execute function verificar_inventario_medicamento();


-- Actualizar automaticamente el estado de las citas al validar la fecha actual
create or replace function actualizacion_citas()
returns trigger as $$
begin
    -- Respetar la informacion al recibir la cita con estado terminal previo
    if new.estado in ('Cancelada', 'Completada') then 
        return new;
    end if;

    if new.fecha < current_date then 
        new.estado := 'Cancelada';
    end if;
    
    return new;
end;
$$ language plpgsql;

create trigger actualizar_citas before insert or update on cita
for each row 
execute function actualizacion_citas();


-- Evaluar citas pasadas en bloque para modificar el estado a 'Cancelada' al vencer el tiempo
create or replace procedure citas_completadas_portiempo_vencido() 
as $$
	begin
		update cita
		set estado = 'Cancelada'
    	where fecha < current_date and estado not in ('Completada', 'Cancelada');
	end;
$$ language plpgsql;


-- Validar la propiedad de la mascota para evitar facturar a clientes equivocados
create or replace function fn_validar_dueño_factura()
returns trigger as $$
declare
    v_propietario_real bigint;
begin
    -- Buscar al dueño legitimo al cruzar los datos de la cita y la mascota
    select m.ID_Propietario into v_propietario_real
    from Cita c
    join Mascota m on c.ID_Mascota = m.ID_Mascota
    where c.ID_Cita = new.ID_Cita;

    -- Bloquear la transaccion al detectar incongruencia entre el cliente facturado y el dueño real
    if new.ID_Propietario != v_propietario_real then
        raise exception 'VIOLACIÓN DE LOGICA DE NEGOCIO: Intento de fraude o error. El cliente (ID: %) no es el dueño de la mascota de la cita %. El dueño legitimo es el cliente (ID: %).',
		new.ID_Propietario, new.ID_Cita, v_propietario_real;
    end if;
    
    -- Permitir la operacion al confirmar la coincidencia de los identificadores
    return new;
end;
$$ language plpgsql;

-- Vigilar la insercion de datos en la tabla Factura
create trigger trg_seguridad_facturacion
before insert or update on Factura
for each row
execute function fn_validar_dueño_factura();


-- Procesar el pago para calcular saldos y finalzar la cita medica
create or replace function procesar_pago_y_estado() 
returns trigger as $$
declare
    v_id_cita bigint;
    v_monto_total numeric(10,2);
    v_total_pagado numeric(10,2);
begin
    -- Obtener informacion generl de la factura
    select id_cita, monto into v_id_cita, v_monto_total
    from factura
    where num_factura = new.num_factura;

    -- Sumar el total de los pagos registrados para esta misma factura
    select coalesce(sum(monto), 0) into v_total_pagado
    from pago
    where num_factura = new.num_factura;

    -- Evaluar el total pagado contra el monto cobrado para actualizar el estado financiero
    if v_total_pagado >= v_monto_total then
        update factura set estado_pago = 'Pagado' where num_factura = new.num_factura;
    else
        update factura set estado_pago = 'Parcial' where num_factura = new.num_factura;
    end if;

    -- Modificar el registro de la cita para dar por finalizada la atención médica
    update cita
    set estado = 'Completada'
    where id_cita = v_id_cita and estado != 'Completada';

    return new;
end;
$$ language plpgsql;

-- Asignar el nuevo disparador a la tabla de pagos
create trigger trg_procesar_pago_estado 
after insert on pago
for each row 
execute function procesar_pago_y_estado();