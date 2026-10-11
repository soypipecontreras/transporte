-- =============================================================================
-- 0004 · Flujos (RPC): sedes, cargas, ofertas, viaje, GPS, cumplido y pago
--
-- Cada función valida quién llama y en qué estado está el registro. Errores:
-- SQLSTATE P0001 con mensaje "codigo: texto" (ver docs/contrato-front.md).
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Cálculos
-- -----------------------------------------------------------------------------

/** Distancia en metros entre dos puntos (haversine). */
create or replace function private.distance_m(lat1 double precision, lng1 double precision, lat2 double precision, lng2 double precision)
returns double precision
language sql immutable as $$
  select 2 * 6371000 * asin(sqrt(
    power(sin(radians(lat2 - lat1) / 2), 2)
    + cos(radians(lat1)) * cos(radians(lat2)) * power(sin(radians(lng2 - lng1) / 2), 2)
  ))
$$;

/** Horas adicionales sobre las 8 permitidas (cada hora o fracción cuenta). */
create or replace function private.extra_hours(started timestamptz, ended timestamptz) returns int
language sql immutable as $$
  select case
    when started is null or ended is null or ended <= started then 0
    else greatest(0, ceil(extract(epoch from (ended - started)) / 3600.0 - 8))::int
  end
$$;

/**
 * Horas logísticas del viaje (Decreto 1017 de 2025). El reloj arranca en la cita o en
 * la llegada, lo que pase después, y para al salir del sitio (o ahora, si sigue ahí).
 * Recargo por hora adicional: 2 SMLDV (rígido) o 3 SMLDV (articulado).
 */
create or replace function private.trip_logistics(p_trip_id uuid, p_at timestamptz default now())
returns table (
  pickup_started_at timestamptz, pickup_ended_at timestamptz, pickup_hours numeric, pickup_extra_hours int,
  delivery_started_at timestamptz, delivery_ended_at timestamptz, delivery_hours numeric, delivery_extra_hours int,
  hourly_surcharge_cop bigint, surcharge_cop bigint
)
language plpgsql stable security definer set search_path = '' as $$
declare
  t public.trips%rowtype;
  l public.loads%rowtype;
  cfg public.vehicle_configuration;
  rate bigint;
begin
  select * into t from public.trips where id = p_trip_id;
  select * into l from public.loads where id = t.load_id;
  select configuration into cfg from public.vehicles where id = t.vehicle_id;

  if t.arrived_pickup_at is not null then
    pickup_started_at := greatest(l.pickup_at, t.arrived_pickup_at);
    pickup_ended_at := coalesce(t.departed_pickup_at, case when t.status = 'at_pickup' then p_at end);
  end if;
  if t.arrived_delivery_at is not null then
    delivery_started_at := greatest(l.delivery_at, t.arrived_delivery_at);
    delivery_ended_at := coalesce(t.delivered_at, case when t.status = 'at_delivery' then p_at end);
  end if;

  pickup_hours := case when pickup_ended_at > pickup_started_at
    then round((extract(epoch from (pickup_ended_at - pickup_started_at)) / 3600.0)::numeric, 2) else 0 end;
  delivery_hours := case when delivery_ended_at > delivery_started_at
    then round((extract(epoch from (delivery_ended_at - delivery_started_at)) / 3600.0)::numeric, 2) else 0 end;
  pickup_extra_hours := private.extra_hours(pickup_started_at, pickup_ended_at);
  delivery_extra_hours := private.extra_hours(delivery_started_at, delivery_ended_at);

  rate := round(private.monthly_wage_cop(private.today_co(coalesce(t.arrived_pickup_at, p_at))) / 30.0
    * case when private.is_articulated(cfg) then 3 else 2 end);
  hourly_surcharge_cop := rate;
  surcharge_cop := (pickup_extra_hours + delivery_extra_hours) * rate;
  return next;
end $$;

create or replace function private.log_event(p_trip_id uuid, p_kind public.trip_event_kind, p_lat double precision default null,
  p_lng double precision default null, p_note text default null, p_data jsonb default '{}'::jsonb)
returns void
language sql security definer set search_path = '' as $$
  insert into public.trip_events (trip_id, kind, lat, lng, note, data, actor)
  values (p_trip_id, p_kind, p_lat, p_lng, p_note, coalesce(p_data, '{}'::jsonb), auth.uid())
$$;

/** Carga el viaje bloqueándolo y verifica que el usuario sea el conductor (o de la transportadora si se permite). */
create or replace function private.lock_trip(p_trip_id uuid, allow_carrier boolean) returns public.trips
language plpgsql security definer set search_path = '' as $$
declare
  t public.trips%rowtype;
begin
  select * into t from public.trips where id = p_trip_id for update;
  if not found then perform private.fail('not_found', 'Ese viaje no existe.'); end if;
  if not (t.driver_id = auth.uid() or (allow_carrier and private.can_operate(t.carrier_org_id))) then
    perform private.fail('forbidden', 'Ese viaje no es tuyo.');
  end if;
  return t;
end $$;

-- -----------------------------------------------------------------------------
-- Sedes
-- -----------------------------------------------------------------------------

/** Crea o edita una sede del generador. La puede manejar el generador o la transportadora que lo atiende. */
create or replace function public.site_upsert(
  p_org_id uuid,
  p_name text,
  p_address text,
  p_city text,
  p_lat double precision,
  p_lng double precision,
  p_id uuid default null,
  p_dane_code text default null,
  p_geofence_m int default 300,
  p_contact_name text default null,
  p_contact_phone text default null,
  p_opening_hours text default null
) returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  result uuid;
begin
  if not (private.can_operate(p_org_id) or exists (
    select 1 from public.carrier_clients cc
    where cc.shipper_org_id = p_org_id and cc.active and private.can_operate(cc.carrier_org_id)
  )) then
    perform private.fail('forbidden', 'No puedes editar las sedes de esa empresa.');
  end if;
  if p_id is null then
    insert into public.sites (org_id, name, address, city, lat, lng, dane_code, geofence_m, contact_name, contact_phone, opening_hours)
    values (p_org_id, trim(p_name), trim(p_address), trim(p_city), p_lat, p_lng, p_dane_code, p_geofence_m,
      p_contact_name, p_contact_phone, p_opening_hours)
    returning id into result;
  else
    update public.sites set name = trim(p_name), address = trim(p_address), city = trim(p_city), lat = p_lat, lng = p_lng,
      dane_code = p_dane_code, geofence_m = p_geofence_m, contact_name = p_contact_name,
      contact_phone = p_contact_phone, opening_hours = p_opening_hours
    where id = p_id and org_id = p_org_id
    returning id into result;
    if result is null then perform private.fail('not_found', 'Esa sede no existe.'); end if;
  end if;
  return result;
end $$;

-- -----------------------------------------------------------------------------
-- Cargas
-- -----------------------------------------------------------------------------

/** Crea una carga. La pide el generador o la crea la transportadora a nombre de su cliente. */
create or replace function public.load_create(
  p_carrier_org_id uuid,
  p_shipper_org_id uuid,
  p_origin_site_id uuid,
  p_destination_site_id uuid,
  p_cargo_description text,
  p_weight_kg int,
  p_declared_value_cop bigint,
  p_pickup_at timestamptz,
  p_delivery_at timestamptz,
  p_required_configurations public.vehicle_configuration[] default '{}',
  p_required_body_types public.body_type[] default '{}',
  p_volume_m3 numeric default null,
  p_packaging text default null,
  p_merchandise_code text default null,
  p_un_number text default null,
  p_reference text default null,
  p_notes text default null,
  p_freight_cop bigint default null
) returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  result uuid;
  as_carrier boolean := private.can_operate(p_carrier_org_id);
begin
  if not (as_carrier or private.can_operate(p_shipper_org_id)) then
    perform private.fail('forbidden', 'No puedes crear cargas para esa empresa.');
  end if;
  if not exists (select 1 from public.carrier_clients cc
                 where cc.carrier_org_id = p_carrier_org_id and cc.shipper_org_id = p_shipper_org_id and cc.active) then
    perform private.fail('invalid', 'Esa empresa no es cliente activo de la transportadora.');
  end if;
  if p_pickup_at < now() - interval '1 hour' then
    perform private.fail('invalid', 'La cita de cargue ya pasó.');
  end if;
  if p_pickup_at > now() + interval '30 days' then
    perform private.fail('invalid', 'La cita de cargue no puede estar a más de 30 días.');
  end if;
  if p_delivery_at - p_pickup_at > interval '6 days' then
    perform private.fail('invalid', 'Las citas de cargue y descargue no pueden estar a más de 6 días entre sí.');
  end if;

  insert into public.loads (carrier_org_id, shipper_org_id, reference, origin_site_id, destination_site_id,
    cargo_description, merchandise_code, un_number, packaging, weight_kg, volume_m3, declared_value_cop,
    required_configurations, required_body_types, pickup_at, delivery_at, notes, created_by)
  values (p_carrier_org_id, p_shipper_org_id, p_reference, p_origin_site_id, p_destination_site_id,
    trim(p_cargo_description), p_merchandise_code, p_un_number, p_packaging, p_weight_kg, p_volume_m3, p_declared_value_cop,
    coalesce(p_required_configurations, '{}'), coalesce(p_required_body_types, '{}'), p_pickup_at, p_delivery_at, p_notes, auth.uid())
  returning id into result;

  if p_freight_cop is not null then
    if not as_carrier then perform private.fail('forbidden', 'El flete lo fija la transportadora.'); end if;
    insert into public.load_pricing (load_id, freight_cop, updated_by) values (result, p_freight_cop, auth.uid());
  end if;
  return result;
end $$;

/** La transportadora fija o cambia el flete pactado con el generador. */
create or replace function public.load_set_freight(p_load_id uuid, p_freight_cop bigint) returns void
language plpgsql security definer set search_path = '' as $$
declare
  l public.loads%rowtype;
begin
  select * into l from public.loads where id = p_load_id;
  if not found or not private.can_operate(l.carrier_org_id) then
    perform private.fail('forbidden', 'No puedes fijar el flete de esa carga.');
  end if;
  if l.status in ('closed', 'cancelled') then perform private.fail('invalid_state', 'La carga ya está cerrada.'); end if;
  insert into public.load_pricing (load_id, freight_cop, updated_by) values (p_load_id, p_freight_cop, auth.uid())
  on conflict (load_id) do update set freight_cop = excluded.freight_cop, updated_by = excluded.updated_by, updated_at = now();
end $$;

/**
 * Publica la carga para los camioneros aprobados. El SICE-TAC lo ingresa operaciones
 * (consultado en el sistema del Ministerio) hasta que tengamos integración.
 */
create or replace function public.load_publish(
  p_load_id uuid,
  p_pay_cop bigint,
  p_sicetac_floor_cop bigint,
  p_advance_cop bigint default 0,
  p_expires_at timestamptz default null
) returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  l public.loads%rowtype;
  expires timestamptz;
  result uuid;
begin
  select * into l from public.loads where id = p_load_id for update;
  if not found or not private.can_operate(l.carrier_org_id) then
    perform private.fail('forbidden', 'No puedes publicar esa carga.');
  end if;
  if l.status <> 'requested' then
    perform private.fail('invalid_state', 'Solo se publican cargas pendientes (estado requested).');
  end if;
  if not exists (select 1 from public.load_pricing where load_id = p_load_id) then
    perform private.fail('freight_missing', 'Fija primero el flete con el generador.');
  end if;
  if p_sicetac_floor_cop is null or p_sicetac_floor_cop <= 0 then
    perform private.fail('sicetac_missing', 'Ingresa el valor SICE-TAC de la ruta.');
  end if;
  if p_pay_cop < p_sicetac_floor_cop then
    perform private.fail('below_sicetac', 'El valor a pagar no puede ser inferior al SICE-TAC.');
  end if;
  expires := coalesce(p_expires_at, l.pickup_at);
  if expires <= now() then perform private.fail('invalid', 'La oferta vencería de inmediato.'); end if;
  if expires > l.pickup_at then perform private.fail('invalid', 'La oferta no puede vencer después de la cita de cargue.'); end if;

  insert into public.offers (load_id, carrier_org_id, pay_cop, sicetac_floor_cop, advance_cop, expires_at, created_by)
  values (p_load_id, l.carrier_org_id, p_pay_cop, p_sicetac_floor_cop, coalesce(p_advance_cop, 0), expires, auth.uid())
  returning id into result;
  update public.loads set status = 'published' where id = p_load_id;
  return result;
end $$;

/** Retira la oferta abierta; la carga vuelve a pendiente. */
create or replace function public.offer_withdraw(p_offer_id uuid) returns void
language plpgsql security definer set search_path = '' as $$
declare
  o public.offers%rowtype;
begin
  select * into o from public.offers where id = p_offer_id for update;
  if not found or not private.can_operate(o.carrier_org_id) then
    perform private.fail('forbidden', 'No puedes retirar esa oferta.');
  end if;
  if o.status <> 'open' then perform private.fail('invalid_state', 'La oferta ya no está abierta.'); end if;
  update public.offers set status = 'withdrawn' where id = p_offer_id;
  update public.loads set status = 'requested' where id = o.load_id and status = 'published';
end $$;

/** Cancela la carga (generador o transportadora) si el camión todavía no ha salido cargado. */
create or replace function public.load_cancel(p_load_id uuid, p_reason text) returns void
language plpgsql security definer set search_path = '' as $$
declare
  l public.loads%rowtype;
  t public.trips%rowtype;
begin
  select * into l from public.loads where id = p_load_id for update;
  if not found or not (private.can_operate(l.carrier_org_id) or private.can_operate(l.shipper_org_id)) then
    perform private.fail('forbidden', 'No puedes cancelar esa carga.');
  end if;
  if l.status not in ('requested', 'published', 'assigned') then
    perform private.fail('invalid_state', 'La carga ya salió; repórtalo como novedad del viaje.');
  end if;
  update public.offers set status = 'withdrawn' where load_id = p_load_id and status = 'open';
  select * into t from public.trips where load_id = p_load_id and status <> 'cancelled' for update;
  if found then
    if t.status not in ('assigned', 'to_pickup', 'at_pickup') then
      perform private.fail('invalid_state', 'El viaje ya salió del cargue.');
    end if;
    update public.trips set status = 'cancelled', cancelled_at = now(), cancel_reason = p_reason where id = t.id;
    perform private.log_event(t.id, 'cancelled', null, null, p_reason);
  end if;
  update public.loads set status = 'cancelled' where id = p_load_id;
end $$;

-- -----------------------------------------------------------------------------
-- Tomar una oferta (camionero)
-- -----------------------------------------------------------------------------
create or replace function public.offer_take(p_offer_id uuid, p_vehicle_id uuid) returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  o public.offers%rowtype;
  l public.loads%rowtype;
  v public.vehicles%rowtype;
  d public.drivers%rowtype;
  trip_end_day date;
  result uuid;
begin
  select * into o from public.offers where id = p_offer_id for update;
  if not found then perform private.fail('not_found', 'Esa oferta no existe.'); end if;
  if o.status <> 'open' or o.expires_at <= now() then
    perform private.fail('offer_closed', 'La oferta ya no está disponible.');
  end if;
  select * into d from public.drivers where id = me;
  if not found then perform private.fail('invalid', 'Completa tu perfil de conductor.'); end if;
  if not private.driver_approved(o.carrier_org_id, me) then
    perform private.fail('not_approved', 'La transportadora aún no te ha aprobado.');
  end if;
  select * into v from public.vehicles where id = p_vehicle_id;
  if not found or not exists (select 1 from public.vehicle_drivers where vehicle_id = p_vehicle_id and driver_id = me) then
    perform private.fail('forbidden', 'No estás autorizado para manejar ese vehículo.');
  end if;
  if not exists (select 1 from public.carrier_vehicles cv
                 where cv.carrier_org_id = o.carrier_org_id and cv.vehicle_id = p_vehicle_id and cv.status = 'approved') then
    perform private.fail('not_approved', 'La transportadora aún no ha aprobado ese vehículo.');
  end if;

  select * into l from public.loads where id = o.load_id for update;
  trip_end_day := private.today_co(l.delivery_at);
  if cardinality(l.required_configurations) > 0 and not v.configuration = any (l.required_configurations) then
    perform private.fail('vehicle_mismatch', 'La carga pide otra configuración de vehículo.');
  end if;
  if cardinality(l.required_body_types) > 0 and not v.body_type = any (l.required_body_types) then
    perform private.fail('vehicle_mismatch', 'La carga pide otro tipo de carrocería.');
  end if;
  if v.payload_kg < l.weight_kg then
    perform private.fail('vehicle_mismatch', 'La carga pesa más de lo que soporta el vehículo.');
  end if;
  if (d.license_category = 'C2' and private.is_articulated(v.configuration)) or d.license_category = 'C1' then
    perform private.fail('license_mismatch', 'Tu licencia no corresponde a ese vehículo.');
  end if;
  if d.license_expires_on < trip_end_day then perform private.fail('expired', 'Tu licencia vence antes del viaje.'); end if;
  if v.soat_expires_on < trip_end_day then perform private.fail('expired', 'El SOAT vence antes del viaje.'); end if;
  if v.technical_review_expires_on is not null and v.technical_review_expires_on < trip_end_day then
    perform private.fail('expired', 'La revisión técnico-mecánica vence antes del viaje.');
  end if;
  if exists (select 1 from public.trips t
             where (t.driver_id = me or t.vehicle_id = p_vehicle_id)
               and t.status in ('assigned', 'to_pickup', 'at_pickup', 'in_transit', 'at_delivery')) then
    perform private.fail('busy', 'Ya tienes un viaje en curso con ese conductor o vehículo.');
  end if;

  update public.offers set status = 'taken', taken_by = me, taken_at = now() where id = p_offer_id;
  insert into public.trips (load_id, offer_id, carrier_org_id, shipper_org_id, vehicle_id, driver_id, holder_id)
  values (l.id, o.id, l.carrier_org_id, l.shipper_org_id, v.id, me, v.holder_id)
  returning id into result;
  update public.loads set status = 'assigned' where id = l.id;
  perform private.log_event(result, 'assigned', null, null, null,
    jsonb_build_object('vehicle', v.plate, 'driver', d.full_name));
  return result;
end $$;

-- -----------------------------------------------------------------------------
-- Viaje (camionero)
-- -----------------------------------------------------------------------------
create or replace function public.trip_start(p_trip_id uuid) returns void
language plpgsql security definer set search_path = '' as $$
declare
  t public.trips := private.lock_trip(p_trip_id, false);
begin
  if t.status <> 'assigned' then perform private.fail('invalid_state', 'El viaje ya arrancó.'); end if;
  update public.trips set status = 'to_pickup', started_at = now() where id = t.id;
  perform private.log_event(t.id, 'started');
end $$;

/**
 * Llegada al cargue o al descargue (según el estado). Debe estar dentro de la geocerca
 * de la sede; la transportadora puede forzarla (p_force) si el GPS falla.
 */
create or replace function public.trip_arrive(p_trip_id uuid, p_lat double precision, p_lng double precision, p_force boolean default false)
returns void
language plpgsql security definer set search_path = '' as $$
declare
  t public.trips := private.lock_trip(p_trip_id, true);
  l public.loads%rowtype;
  s public.sites%rowtype;
  dist double precision;
  to_pickup boolean;
begin
  if t.status in ('assigned', 'to_pickup') then
    to_pickup := true;
  elsif t.status = 'in_transit' then
    to_pickup := false;
  else
    perform private.fail('invalid_state', 'En este estado no se registra llegada.');
  end if;
  if p_force and not private.can_operate(t.carrier_org_id) then
    perform private.fail('forbidden', 'Solo operaciones puede forzar la llegada.');
  end if;
  select * into l from public.loads where id = t.load_id;
  select * into s from public.sites where id = case when to_pickup then l.origin_site_id else l.destination_site_id end;
  dist := private.distance_m(p_lat, p_lng, s.lat, s.lng);
  if not p_force and dist > s.geofence_m then
    perform private.fail('outside_geofence', format('Estás a %s m de la sede; acércate para registrar la llegada.', round(dist)));
  end if;

  if to_pickup then
    update public.trips set status = 'at_pickup', arrived_pickup_at = now(), started_at = coalesce(started_at, now()),
      last_lat = p_lat, last_lng = p_lng, last_position_at = now()
    where id = t.id;
    perform private.log_event(t.id, 'arrived_pickup', p_lat, p_lng, null, jsonb_build_object('distance_m', round(dist), 'forced', p_force));
  else
    update public.trips set status = 'at_delivery', arrived_delivery_at = now(),
      last_lat = p_lat, last_lng = p_lng, last_position_at = now()
    where id = t.id;
    perform private.log_event(t.id, 'arrived_delivery', p_lat, p_lng, null, jsonb_build_object('distance_m', round(dist), 'forced', p_force));
  end if;
end $$;

/** Sale cargado. Exige el manifiesto expedido: sin manifiesto el viaje no puede rodar. */
create or replace function public.trip_depart(p_trip_id uuid, p_lat double precision default null, p_lng double precision default null)
returns void
language plpgsql security definer set search_path = '' as $$
declare
  t public.trips := private.lock_trip(p_trip_id, true);
begin
  if t.status <> 'at_pickup' then perform private.fail('invalid_state', 'Primero registra la llegada al cargue.'); end if;
  if t.manifest_number is null then
    perform private.fail('manifest_missing', 'La transportadora todavía no ha expedido el manifiesto.');
  end if;
  update public.trips set status = 'in_transit', departed_pickup_at = now() where id = t.id;
  update public.loads set status = 'in_transit' where id = t.load_id;
  perform private.log_event(t.id, 'departed_pickup', p_lat, p_lng);
end $$;

/** Entrega: exige al menos una foto de entrega o el soporte firmado. */
create or replace function public.trip_deliver(p_trip_id uuid, p_delivered_weight_kg int default null,
  p_lat double precision default null, p_lng double precision default null)
returns void
language plpgsql security definer set search_path = '' as $$
declare
  t public.trips := private.lock_trip(p_trip_id, true);
  l public.loads%rowtype;
begin
  if t.status <> 'at_delivery' then perform private.fail('invalid_state', 'Primero registra la llegada al descargue.'); end if;
  if not exists (select 1 from public.trip_documents where trip_id = t.id and kind in ('delivery_photo', 'signed_delivery')) then
    perform private.fail('proof_missing', 'Sube la foto de la entrega o el soporte firmado.');
  end if;
  select * into l from public.loads where id = t.load_id;
  update public.trips set status = 'delivered', delivered_at = now(),
    delivered_weight_kg = coalesce(p_delivered_weight_kg, l.weight_kg)
  where id = t.id;
  update public.loads set status = 'delivered' where id = t.load_id;
  perform private.log_event(t.id, 'delivered', p_lat, p_lng, null,
    jsonb_build_object('delivered_weight_kg', coalesce(p_delivered_weight_kg, l.weight_kg)));
end $$;

/**
 * Puntos de GPS en lote (el celular guarda los puntos sin señal y los manda después).
 * p_points: [{"lat":4.6,"lng":-74.1,"recorded_at":"2026-10-10T10:00:00-05:00","speed_kmh":60,"heading":90,"accuracy_m":12}]
 */
create or replace function public.trip_ping(p_trip_id uuid, p_points jsonb) returns int
language plpgsql security definer set search_path = '' as $$
declare
  t public.trips%rowtype;
  inserted int;
  latest record;
begin
  select * into t from public.trips where id = p_trip_id;
  if not found or t.driver_id <> auth.uid() then perform private.fail('forbidden', 'Ese viaje no es tuyo.'); end if;
  if t.status not in ('to_pickup', 'at_pickup', 'in_transit', 'at_delivery') then
    perform private.fail('invalid_state', 'El viaje no está en curso; apaga el seguimiento.');
  end if;
  if jsonb_typeof(p_points) <> 'array' or jsonb_array_length(p_points) = 0 or jsonb_array_length(p_points) > 500 then
    perform private.fail('invalid', 'Envía entre 1 y 500 puntos.');
  end if;

  insert into public.positions (trip_id, lat, lng, speed_kmh, heading, accuracy_m, recorded_at)
  select p_trip_id, (p ->> 'lat')::double precision, (p ->> 'lng')::double precision,
    (p ->> 'speed_kmh')::real, (p ->> 'heading')::real, (p ->> 'accuracy_m')::real,
    least((p ->> 'recorded_at')::timestamptz, now())
  from jsonb_array_elements(p_points) p;
  get diagnostics inserted = row_count;

  select (p ->> 'lat')::double precision as lat, (p ->> 'lng')::double precision as lng,
    least((p ->> 'recorded_at')::timestamptz, now()) as at
  into latest
  from jsonb_array_elements(p_points) p
  order by (p ->> 'recorded_at')::timestamptz desc limit 1;

  update public.trips set last_lat = latest.lat, last_lng = latest.lng, last_position_at = latest.at
  where id = p_trip_id and (last_position_at is null or last_position_at < latest.at);
  return inserted;
end $$;

/** Registra un archivo del viaje ya subido a Storage (fotos del conductor; PDF de remesa/manifiesto de operaciones). */
create or replace function public.trip_add_document(p_trip_id uuid, p_kind public.trip_document_kind, p_storage_path text,
  p_lat double precision default null, p_lng double precision default null, p_taken_at timestamptz default null)
returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  t public.trips%rowtype;
  result uuid;
begin
  select * into t from public.trips where id = p_trip_id;
  if not found or not (t.driver_id = auth.uid() or private.can_operate(t.carrier_org_id)) then
    perform private.fail('forbidden', 'Ese viaje no es tuyo.');
  end if;
  if t.status in ('settled', 'cancelled') then perform private.fail('invalid_state', 'El viaje ya está cerrado.'); end if;
  if p_kind in ('remesa_pdf', 'manifest_pdf') and not private.can_operate(t.carrier_org_id) then
    perform private.fail('forbidden', 'La remesa y el manifiesto los carga la transportadora.');
  end if;
  insert into public.trip_documents (trip_id, kind, storage_path, lat, lng, taken_at, uploaded_by)
  values (p_trip_id, p_kind, p_storage_path, p_lat, p_lng, p_taken_at, auth.uid())
  returning id into result;
  return result;
end $$;

/** Novedad del viaje (varado, retén, accidente, demora…) o nota de operaciones. */
create or replace function public.trip_report(p_trip_id uuid, p_note text, p_incident boolean default true,
  p_lat double precision default null, p_lng double precision default null)
returns void
language plpgsql security definer set search_path = '' as $$
declare
  t public.trips%rowtype;
begin
  select * into t from public.trips where id = p_trip_id;
  if not found or not (t.driver_id = auth.uid() or private.can_operate(t.carrier_org_id)) then
    perform private.fail('forbidden', 'Ese viaje no es tuyo.');
  end if;
  perform private.log_event(p_trip_id, case when p_incident then 'incident' else 'note' end::public.trip_event_kind,
    p_lat, p_lng, p_note);
end $$;

-- -----------------------------------------------------------------------------
-- Viaje (transportadora)
-- -----------------------------------------------------------------------------

/** Registra los números de remesa y manifiesto expedidos en el RNDC. */
create or replace function public.trip_set_documents(p_trip_id uuid, p_remesa_number text, p_manifest_number text)
returns void
language plpgsql security definer set search_path = '' as $$
declare
  t public.trips%rowtype;
begin
  select * into t from public.trips where id = p_trip_id for update;
  if not found or not private.can_operate(t.carrier_org_id) then
    perform private.fail('forbidden', 'No puedes editar ese viaje.');
  end if;
  if t.status in ('settled', 'cancelled') then perform private.fail('invalid_state', 'El viaje ya está cerrado.'); end if;
  update public.trips set remesa_number = trim(p_remesa_number), manifest_number = trim(p_manifest_number),
    manifest_issued_at = coalesce(manifest_issued_at, now())
  where id = p_trip_id;
  perform private.log_event(p_trip_id, 'documents_issued', null, null, null,
    jsonb_build_object('remesa', p_remesa_number, 'manifest', p_manifest_number));
end $$;

/** Cancela el viaje antes de que salga cargado; la carga vuelve a pendiente para publicarla de nuevo. */
create or replace function public.trip_cancel(p_trip_id uuid, p_reason text) returns void
language plpgsql security definer set search_path = '' as $$
declare
  t public.trips%rowtype;
begin
  select * into t from public.trips where id = p_trip_id for update;
  if not found or not private.can_operate(t.carrier_org_id) then
    perform private.fail('forbidden', 'No puedes cancelar ese viaje.');
  end if;
  if t.status not in ('assigned', 'to_pickup', 'at_pickup') then
    perform private.fail('invalid_state', 'El viaje ya salió del cargue; repórtalo como novedad.');
  end if;
  update public.trips set status = 'cancelled', cancelled_at = now(), cancel_reason = p_reason where id = p_trip_id;
  update public.loads set status = 'requested' where id = t.load_id;
  perform private.log_event(p_trip_id, 'cancelled', null, null, p_reason);
end $$;

/**
 * Expide el cumplido: calcula recargos por horas logísticas y crea el pago al titular,
 * con vencimiento a 5 días hábiles (Decreto 1017 de 2025).
 */
create or replace function public.trip_settle(p_trip_id uuid) returns date
language plpgsql security definer set search_path = '' as $$
declare
  t public.trips%rowtype;
  o public.offers%rowtype;
  lg record;
  due date;
begin
  select * into t from public.trips where id = p_trip_id for update;
  if not found or not private.can_operate(t.carrier_org_id) then
    perform private.fail('forbidden', 'No puedes expedir el cumplido de ese viaje.');
  end if;
  if t.status <> 'delivered' then perform private.fail('invalid_state', 'El viaje todavía no se ha entregado.'); end if;
  select * into o from public.offers where id = t.offer_id;
  select * into lg from private.trip_logistics(p_trip_id);
  due := private.add_business_days(private.today_co(), 5);

  insert into public.payments (trip_id, carrier_org_id, holder_id, pay_cop, pickup_extra_hours, delivery_extra_hours,
    surcharge_cop, advance_cop, total_cop, due_on)
  values (t.id, t.carrier_org_id, t.holder_id, o.pay_cop, lg.pickup_extra_hours, lg.delivery_extra_hours,
    lg.surcharge_cop, o.advance_cop, o.pay_cop + lg.surcharge_cop - o.advance_cop, due);

  update public.trips set status = 'settled', settled_at = now() where id = t.id;
  update public.loads set status = 'closed' where id = t.load_id;
  perform private.log_event(t.id, 'settled', null, null, null,
    jsonb_build_object('surcharge_cop', lg.surcharge_cop, 'due_on', due));
  return due;
end $$;

create or replace function public.payment_mark_paid(p_trip_id uuid, p_reference text) returns void
language plpgsql security definer set search_path = '' as $$
declare
  p public.payments%rowtype;
begin
  select * into p from public.payments where trip_id = p_trip_id for update;
  if not found or not private.has_role(p.carrier_org_id, array['owner', 'admin']::public.org_role[]) then
    perform private.fail('forbidden', 'Solo un administrador registra pagos.');
  end if;
  if p.status = 'paid' then perform private.fail('invalid_state', 'Ese pago ya está registrado.'); end if;
  update public.payments set status = 'paid', paid_at = now(), reference = p_reference where trip_id = p_trip_id;
end $$;

/** Horas logísticas en vivo para cualquier parte del viaje (el dinero solo para transportadora y conductor). */
create or replace function public.trip_logistics(p_trip_id uuid) returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare
  t public.trips%rowtype;
  lg record;
  money boolean;
begin
  select * into t from public.trips where id = p_trip_id;
  if not found or not private.can_see_trip(p_trip_id) then perform private.fail('forbidden', 'Ese viaje no es tuyo.'); end if;
  select * into lg from private.trip_logistics(p_trip_id);
  money := t.driver_id = auth.uid() or private.is_member(t.carrier_org_id);
  return jsonb_build_object(
    'pickup', jsonb_build_object('started_at', lg.pickup_started_at, 'ended_at', lg.pickup_ended_at,
      'hours', lg.pickup_hours, 'extra_hours', lg.pickup_extra_hours),
    'delivery', jsonb_build_object('started_at', lg.delivery_started_at, 'ended_at', lg.delivery_ended_at,
      'hours', lg.delivery_hours, 'extra_hours', lg.delivery_extra_hours),
    'limit_hours', 8,
    'hourly_surcharge_cop', case when money then lg.hourly_surcharge_cop end,
    'surcharge_cop', case when money then lg.surcharge_cop end
  );
end $$;

-- Las funciones internas no se exponen por la API.
revoke execute on all functions in schema private from public, anon, authenticated;
grant execute on function private.has_role(uuid, public.org_role[]), private.is_member(uuid), private.can_operate(uuid),
  private.org_kind_of(uuid), private.owns_vehicle(uuid), private.can_see_holder(uuid), private.driver_approved(uuid, uuid),
  private.driver_can_see_load(uuid), private.can_see_load(uuid), private.can_see_trip(uuid)
  to authenticated;
revoke execute on all functions in schema public from public, anon;
