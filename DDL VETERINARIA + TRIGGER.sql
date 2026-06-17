create table Propietario(
	ID_Propietario bigint generated always as identity,
	Nombre varchar(150) not null,
	DUI varchar(10) not null, 
	Correo varchar(150),
	Telefono varchar(20) not null,
	constraint pk_propietario primary key (ID_Propietario),
	constraint uq_propietario_dui unique(DUI),
	constraint ck_propietario_dui_formato check (DUI ~ '^[0-9]{8}-[0-9]$'),
	constraint ck_propietario_correo_formato check (correo ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);



create table Veterinario(
	ID_Veterinario bigint generated always as identity,
	Nombre varchar(150) not null,
	Correo varchar(150) not null,
	constraint pk_veterinario primary key(ID_veterinario),
	constraint uq_veterinario_correo unique(Correo), 
	constraint ck_veterinario_correo_formato check (Correo ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

create table Especialidad(
	ID_Especialidad bigint generated always as identity,
	Nombre varchar(150) not null, 
	Estado varchar (15) not null default 'Activo',
	constraint pk_especialidad primary key (ID_Especialidad),
	constraint ck_especialidad_estado check (Estado in ('Activo', 'Inactivo', 'Suspendido'))
);

create table Veterinario_Especialidad(
	ID_Veterinario bigint not null,
	ID_Especialidad bigint not null,
	constraint pk_veterinario_especialidad primary key(ID_Veterinario, ID_Especialidad),
	constraint fk_ve_veterinario foreign key(ID_veterinario)
		references Veterinario(ID_Veterinario) 
		on update cascade on delete restrict,
	constraint fk_ve_especialidad foreign key(ID_Especialidad)
		references Especialidad(ID_Especialidad)
		on update cascade on delete restrict
);


create table Mascota(
	ID_Mascota bigint generated always as identity,
	Especie varchar(150) not null,
	Nombre varchar(150) not null,
	Raza varchar(150),
	Fecha_Nacimiento date,
	ID_Propietario bigint not null,
	constraint pk_mascota primary key(ID_Mascota),
	constraint ck_mascoa_fecha_nacimiento check(Fecha_Nacimiento <= current_date),
	constraint fk_mascota_propietario foreign key (ID_Propietario)
		references Propietario(ID_Propietario) 
		on update cascade on delete restrict
);

create table Cita(
	ID_Cita bigint generated always as identity,
	Fecha date not null,
	Hora time not null,
	Consultorio varchar(50),
	Estado varchar(15) not null default 'Programada',
	ID_Mascota bigint not null,
	ID_Veterinario bigint not null,
	constraint pk_cita primary key (ID_Cita),
	constraint ck_cita_estado check(Estado in('Programada', 'Completada', 'Cancelada')),
	constraint fk_cita_mascota foreign key(ID_Mascota)
		references Mascota(ID_Mascota)
		on update cascade on delete restrict,
	constraint fk_cita_veterinario foreign key(ID_Veterinario)
		references Veterinario(ID_Veterinario)
		on update cascade on delete restrict
);

create table Diagnostico(
	ID_Diagnostico bigint generated always as identity,
	Descripcion varchar(500) not null,
	ID_Cita bigint not null,
	constraint pk_diagnostico primary key(ID_Diagnostico),
	constraint fk_diagnostico_cita foreign key(ID_Cita)
		references Cita(ID_Cita)
		on update cascade on delete restrict
);

create table Factura(
	Num_Factura bigint generated always as identity,
	Fecha date default current_date,
	Monto numeric(10,2) not null,
	ID_Cita bigint not null,
	ID_Propietario bigint not null,
	constraint pk_factura primary key(Num_Factura),
	constraint uq_factura_cita unique(ID_Cita),
	constraint ck_factura_monto check(Monto > 0),
	constraint fk_factura_cita foreign key(ID_Cita)
		references Cita(ID_Cita) 
		on update cascade on delete restrict,
	constraint fk_factura_propietario foreign key(ID_Propietario)
		references Propietario(ID_Propietario)
		on update cascade on delete restrict
); 

alter table Factura
drop constraint ck_factura_monto;

alter table Factura
add constraint ck_factura_monto
check (Monto >= 0);


create table Item_Facturable(
	ID_Item bigint generated always as identity,
	Descripcion varchar(500) not null,
	Costo numeric(10,2) not null,
	constraint pk_item_facturable primary key(ID_Item),
	constraint ck_Item_Costo check(Costo > 0)
);

create table Detalle_Factura(
	ID_Detalle bigint generated always as identity,
	Precio_Unitario numeric(10,2) not null,
	Cantidad bigint not null,
	Num_Factura bigint not null,
	ID_Item bigint not null,
	constraint pk_detalle_factura primary key(ID_Detalle),
	constraint ck_detallefact_cantidad check(Cantidad > 0),
	constraint ck_detallefact_precio_unitario check(Precio_Unitario > 0),
	constraint fk_detallefact_num_factura foreign key(Num_factura)
		references Factura(Num_Factura) 
		on update cascade on delete restrict,
	constraint fk_detalleF_ID_Item foreign key(ID_Item)
		references Item_Facturable(ID_Item) 
		on update cascade on delete restrict
);

create table Procedimiento(
	ID_Procedimiento bigint not null,
	Riesgo varchar(500) not null,
	Tiempo_Estimado int not null, 
	constraint pk_procedimiento primary key (ID_Procedimiento),
	constraint ck_procedimiento_tiempo check(Tiempo_Estimado >= 0),
	constraint fk_procedimiento_item foreign key (ID_Procedimiento)
		references Item_Facturable(ID_Item)
		on update cascade on delete restrict
); 



create table Medicamento(
	ID_Medicamento bigint not null,
	Via varchar(150) not null,
	Dosis_Recomendada varchar(150) not null,
	Precauciones varchar(500) not null,
	constraint pk_medicamento primary key (ID_Medicamento),
	constraint fk_medicamento_item foreign key (ID_Medicamento)
		references Item_Facturable(ID_Item)
		on update cascade on delete restrict
);

create table Diagnostico_Procedimiento(
	ID_Procedimiento bigint not null,
	ID_Diagnostico bigint not null,
	constraint pk_diagnostico_procedimiento primary key(ID_Procedimiento, ID_Diagnostico),
	constraint fk_dp_procedimiento foreign key(ID_Procedimiento)
		references Procedimiento(ID_Procedimiento)
		on update cascade on delete restrict,
	constraint fk_dp_diagnostico foreign key(ID_Diagnostico)
		references Diagnostico(ID_Diagnostico) 
		on update cascade on delete restrict
);

create table Tratamiento(
	ID_Tratamiento bigint generated always as identity,
	Frecuencia varchar(200) not null,
	Dosis varchar(200) not null, 
	Vigencia date not null,
	Descripcion varchar(500),
	ID_Diagnostico bigint not null,
	ID_Medicamento bigint not null, 
	constraint pk_tratamiento primary key (ID_Tratamiento),
	constraint fk_tratamiento_diagnostico foreign key(ID_Diagnostico)
		references Diagnostico(ID_Diagnostico)
		on update cascade on delete restrict,
	constraint fk_tratamiento_medicamento foreign key(ID_Medicamento)
		references Medicamento(ID_Medicamento)
		on update cascade on delete restrict
);

-- FUNCION TRIGGER PARA QUE EL MONTO EN FACTURA SE CALCULE DE MANERA AUTOMATICA, EVITANDO USAR UPDATE

create or replace function actualizar_monto_factura()
returns trigger as $$
declare
    v_num_factura bigint;
begin

    v_num_factura := coalesce(new.num_factura, old.num_factura);

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

    return null;

end;
$$ language plpgsql;

create trigger trg_actualizar_monto_factura
after insert or update or delete
on detalle_factura
for each row
execute function actualizar_monto_factura();


-- trigger de control de alergias
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
        raise exception 'ALERTA VETERINARIA: La mascota "%" es de especie "%". El medicamento "%" indica contraindicación/alergia: "%". Registro denegado.', 
            v_nombre_mascota, v_especie_mascota, v_nombre_medicamento, v_precauciones_medicamento;
    end if;

    return new;
end;
$$ language plpgsql;

-- Crear el disparador en la tabla Tratamiento
create trigger trg_verificar_alergia_medicamento
before insert or update on Tratamiento
for each row
execute function verificar_alergia_medicamento();


--Trigger de inventaria

create or replace function verificar_inventario_medicamento() 
returns trigger as $$
	declare 
		stock_actual int;
	begin
		select stock into stock_actual
		from item_facturable
		where id_item = new.id_item;
		
		if stock_actual < new.cantidad then 
			raise exception 'Bajo inventario de item ID: %. Disponible: %, Solicitado: %', new.id_item, stock_actual, new.cantidad;
		end if;

		return new;
	end;
$$ language plpgsql;

create trigger actualizar_inventario before insert or update on detalle_factura
for each row
execute function verificar_inventario_medicamento();
