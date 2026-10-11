-- =============================================================================
-- 0005 · Lecturas armadas para las apps: feed de ofertas, tablero de monitoreo,
-- alertas y control de cumplidos.
-- =============================================================================

/** Nombre de una organización (para mostrarle al camionero quién publica). */
create or replace function private.org_name(org uuid) returns text
language sql stable security definer set search_path = '' as $$
  select name from public.organizations where id = org
$$;

-- -----------------------------------------------------------------------------
-- App del camionero: ofertas abiertas que puede tomar
-- -----------------------------------------------------------------------------
create or replace function public.driver_offer_feed(p_vehicle_id uuid default null)
returns table (
  offer_id uuid, load_id uuid, carrier_org_id uuid, carrier_name text,
  pay_cop bigint, advance_cop bigint, expires_at timestamptz,
  cargo_description text, packaging text, weight_kg int, volume_m3 numeric, dangerous boolean,
  required_configurations public.vehicle_configuration[], required_body_types public.body_type[],
  pickup_at timestamptz, delivery_at timestamptz,
  origin_name text, origin_city text, origin_address text, origin_lat double precision, origin_lng double precision,
  destination_name text, destination_city text, destination_address text, destination_lat double precision, destination_lng double precision,
  straight_distance_km int, fits_vehicle boolean
)
language sql stable security definer set search_path = '' as $$
  select o.id, l.id, o.carrier_org_id, private.org_name(o.carrier_org_id),
    o.pay_cop, o.advance_cop, o.expires_at,
    l.cargo_description, l.packaging, l.weight_kg, l.volume_m3, l.un_number is not null,
    l.required_configurations, l.required_body_types,
    l.pickup_at, l.delivery_at,
    so.name, so.city, so.address, so.lat, so.lng,
    sd.name, sd.city, sd.address, sd.lat, sd.lng,
    round(private.distance_m(so.lat, so.lng, sd.lat, sd.lng) / 1000)::int,
    case when v.id is null then null else
      (cardinality(l.required_configurations) = 0 or v.configuration = any (l.required_configurations))
      and (cardinality(l.required_body_types) = 0 or v.body_type = any (l.required_body_types))
      and v.payload_kg >= l.weight_kg
    end
  from public.offers o
  join public.loads l on l.id = o.load_id
  join public.sites so on so.id = l.origin_site_id
  join public.sites sd on sd.id = l.destination_site_id
  left join public.vehicles v on v.id = p_vehicle_id
    and exists (select 1 from public.vehicle_drivers vd where vd.vehicle_id = v.id and vd.driver_id = auth.uid())
  where o.status = 'open' and o.expires_at > now()
    and private.driver_approved(o.carrier_org_id, auth.uid())
  order by l.pickup_at
$$;

-- -----------------------------------------------------------------------------
-- SaaS de monitoreo (y vista de seguimiento del generador)
-- -----------------------------------------------------------------------------

/**
 * Alertas de un viaje en este momento:
 *   late_to_pickup      no ha llegado al cargue y ya pasó la cita
 *   no_signal           en ruta y sin GPS hace más de 30 minutos
 *   manifest_missing    está en el cargue y no hay manifiesto
 *   pickup_6h/pickup_8h, delivery_6h/delivery_8h   horas logísticas (aviso a las 6, recargo desde las 8)
 *   late_delivery       en tránsito y ya pasó la cita de descargue
 *   settlement_pending  entregado hace más de 24 horas sin cumplido
 */
create or replace function private.trip_alerts(t public.trips, l public.loads, p_at timestamptz default now()) returns text[]
language plpgsql stable security definer set search_path = '' as $$
declare
  alerts text[] := '{}';
  lg record;
begin
  if t.status in ('assigned', 'to_pickup') and p_at > l.pickup_at then
    alerts := array_append(alerts, 'late_to_pickup');
  end if;
  if t.status in ('to_pickup', 'in_transit')
     and coalesce(t.last_position_at, t.started_at, t.created_at) < p_at - interval '30 minutes' then
    alerts := array_append(alerts, 'no_signal');
  end if;
  if t.status = 'at_pickup' and t.manifest_number is null then
    alerts := array_append(alerts, 'manifest_missing');
  end if;
  if t.status in ('at_pickup', 'at_delivery') then
    select * into lg from private.trip_logistics(t.id, p_at);
    if t.status = 'at_pickup' then
      if lg.pickup_hours >= 8 then alerts := array_append(alerts, 'pickup_8h');
      elsif lg.pickup_hours >= 6 then alerts := array_append(alerts, 'pickup_6h'); end if;
    else
      if lg.delivery_hours >= 8 then alerts := array_append(alerts, 'delivery_8h');
      elsif lg.delivery_hours >= 6 then alerts := array_append(alerts, 'delivery_6h'); end if;
    end if;
  end if;
  if t.status = 'in_transit' and p_at > l.delivery_at then
    alerts := array_append(alerts, 'late_delivery');
  end if;
  if t.status = 'delivered' and t.delivered_at < p_at - interval '24 hours' then
    alerts := array_append(alerts, 'settlement_pending');
  end if;
  return alerts;
end $$;

/**
 * Tablero de viajes de una organización (transportadora o generador). Por defecto,
 * los viajes en curso y los cerrados en las últimas 48 horas.
 */
create or replace function public.trip_board(p_org_id uuid, p_include_closed boolean default false)
returns table (
  trip_id uuid, load_id uuid, status public.trip_status, alerts text[],
  carrier_org_id uuid, carrier_name text, shipper_org_id uuid, shipper_name text, reference text,
  cargo_description text, weight_kg int,
  origin_name text, origin_city text, origin_lat double precision, origin_lng double precision,
  destination_name text, destination_city text, destination_lat double precision, destination_lng double precision,
  pickup_at timestamptz, delivery_at timestamptz,
  plate text, configuration public.vehicle_configuration, driver_name text, driver_phone text,
  remesa_number text, manifest_number text,
  last_lat double precision, last_lng double precision, last_position_at timestamptz,
  arrived_pickup_at timestamptz, departed_pickup_at timestamptz, arrived_delivery_at timestamptz,
  delivered_at timestamptz, settled_at timestamptz
)
language plpgsql stable security definer set search_path = '' as $$
begin
  if not private.is_member(p_org_id) then perform private.fail('forbidden', 'No perteneces a esa organización.'); end if;
  return query
  select t.id, l.id, t.status, private.trip_alerts(t, l),
    t.carrier_org_id, private.org_name(t.carrier_org_id), t.shipper_org_id, private.org_name(t.shipper_org_id), l.reference,
    l.cargo_description, l.weight_kg,
    so.name, so.city, so.lat, so.lng,
    sd.name, sd.city, sd.lat, sd.lng,
    l.pickup_at, l.delivery_at,
    v.plate, v.configuration, d.full_name, d.phone,
    t.remesa_number, t.manifest_number,
    t.last_lat, t.last_lng, t.last_position_at,
    t.arrived_pickup_at, t.departed_pickup_at, t.arrived_delivery_at,
    t.delivered_at, t.settled_at
  from public.trips t
  join public.loads l on l.id = t.load_id
  join public.sites so on so.id = l.origin_site_id
  join public.sites sd on sd.id = l.destination_site_id
  join public.vehicles v on v.id = t.vehicle_id
  join public.drivers d on d.id = t.driver_id
  where (t.carrier_org_id = p_org_id or t.shipper_org_id = p_org_id)
    and (p_include_closed
      or t.status not in ('settled', 'cancelled')
      or coalesce(t.settled_at, t.cancelled_at) > now() - interval '48 hours')
  order by cardinality(private.trip_alerts(t, l)) desc, l.pickup_at;
end $$;

/**
 * Control de cumplidos (Resolución RNDC 2026): si los manifiestos sin cumplir superan el
 * 20 % de los expedidos en los últimos 30 días, el RNDC bloquea nuevos manifiestos.
 */
create or replace function public.carrier_compliance(p_carrier_org_id uuid) returns jsonb
language plpgsql stable security definer set search_path = '' as $$
declare
  issued int;
  open_count int;
  ratio numeric;
begin
  if not private.is_member(p_carrier_org_id) then perform private.fail('forbidden', 'No perteneces a esa organización.'); end if;
  select count(*), count(*) filter (where status not in ('settled', 'cancelled'))
  into issued, open_count
  from public.trips
  where carrier_org_id = p_carrier_org_id and manifest_issued_at > now() - interval '30 days';
  ratio := case when issued = 0 then 0 else round(open_count::numeric / issued, 4) end;
  return jsonb_build_object(
    'manifests_30d', issued,
    'unsettled', open_count,
    'ratio', ratio,
    'limit', 0.2,
    'level', case when ratio >= 0.2 then 'blocked' when ratio >= 0.15 then 'warning' else 'ok' end,
    'payments_overdue', (select count(*) from public.payments
                         where carrier_org_id = p_carrier_org_id and status = 'pending' and due_on < private.today_co()),
    'payments_due_soon', (select count(*) from public.payments
                          where carrier_org_id = p_carrier_org_id and status = 'pending'
                            and due_on between private.today_co() and private.today_co() + 2)
  );
end $$;

revoke execute on function private.org_name(uuid), private.trip_alerts(public.trips, public.loads, timestamptz)
  from public, anon, authenticated;
revoke execute on all functions in schema public from public, anon;
