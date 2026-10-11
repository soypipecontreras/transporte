-- =============================================================================
-- 0003 · Operación: sedes, cargas, ofertas, viajes, eventos, GPS y pagos
--
-- Flujo (las RPC están en 0004):
--   generador pide carga (requested) → transportadora fija flete y publica oferta
--   con valor a pagar ≥ SICE-TAC (published) → un camionero aprobado la toma
--   (assigned, nace el viaje) → va al cargue → carga → tránsito → descargue →
--   entrega (delivered) → la transportadora expide el cumplido (closed) y nace
--   el pago con vencimiento a 5 días hábiles.
--
-- Privacidad del dinero:
--   * El flete (lo que paga el generador) vive en load_pricing: lo ven la
--     transportadora y el generador, nunca el camionero.
--   * El valor a pagar (lo que recibe el camionero) vive en offers y payments: lo
--     ven la transportadora y el camionero, nunca el generador.
-- =============================================================================

create type public.load_status as enum ('requested', 'published', 'assigned', 'in_transit', 'delivered', 'closed', 'cancelled');
create type public.offer_status as enum ('open', 'taken', 'withdrawn', 'expired');
create type public.trip_status as enum (
  'assigned',          -- el camionero tomó la oferta
  'to_pickup',         -- en camino al cargue
  'at_pickup',         -- llegó al cargue (corre el reloj de horas logísticas)
  'in_transit',        -- salió cargado
  'at_delivery',       -- llegó al descargue (corre el reloj)
  'delivered',         -- entregó; falta el cumplido
  'settled',           -- cumplido expedido; nace el pago
  'cancelled'
);
create type public.trip_event_kind as enum (
  'assigned', 'started', 'arrived_pickup', 'departed_pickup', 'arrived_delivery', 'delivered',
  'settled', 'cancelled', 'documents_issued', 'incident', 'note'
);
create type public.trip_document_kind as enum (
  'pickup_photo', 'delivery_photo', 'seal_photo', 'signed_delivery', 'remesa_pdf', 'manifest_pdf', 'other'
);
create type public.payment_status as enum ('pending', 'paid');

-- -----------------------------------------------------------------------------
-- Sedes de cargue y descargue (de los generadores)
-- -----------------------------------------------------------------------------
create table public.sites (
  id uuid primary key default gen_random_uuid(),
  org_id uuid not null references public.organizations (id) on delete cascade,
  name text not null check (char_length(name) between 1 and 120),
  address text not null,
  city text not null,
  dane_code text check (dane_code ~ '^[0-9]{5,8}$'),   -- código DIVIPOLA (lo pide el RNDC)
  lat double precision not null check (lat between -5 and 14),
  lng double precision not null check (lng between -82 and -66),
  geofence_m int not null default 300 check (geofence_m between 50 and 5000),
  contact_name text,
  contact_phone text,
  opening_hours text,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id, org_id)
);
create trigger sites_updated_at before update on public.sites
  for each row execute function private.set_updated_at();
create index sites_org_idx on public.sites (org_id);

-- -----------------------------------------------------------------------------
-- Cargas
-- -----------------------------------------------------------------------------
create table public.loads (
  id uuid primary key default gen_random_uuid(),
  carrier_org_id uuid not null references public.organizations (id),
  shipper_org_id uuid not null references public.organizations (id),
  reference text,                                   -- número de pedido del generador
  origin_site_id uuid not null,
  destination_site_id uuid not null,
  cargo_description text not null check (char_length(cargo_description) between 3 and 500),
  merchandise_code text,                            -- código de mercancía del RNDC
  un_number text check (un_number ~ '^[0-9]{4}$'),  -- solo mercancías peligrosas
  packaging text,
  weight_kg int not null check (weight_kg > 0),
  volume_m3 numeric(8, 2) check (volume_m3 > 0),
  declared_value_cop bigint not null check (declared_value_cop > 0),
  required_configurations public.vehicle_configuration[] not null default '{}',  -- vacío: cualquiera
  required_body_types public.body_type[] not null default '{}',
  pickup_at timestamptz not null,                   -- cita de cargue
  delivery_at timestamptz not null,                 -- cita de descargue
  notes text,
  status public.load_status not null default 'requested',
  created_by uuid not null references auth.users (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  foreign key (origin_site_id, shipper_org_id) references public.sites (id, org_id),
  foreign key (destination_site_id, shipper_org_id) references public.sites (id, org_id),
  foreign key (carrier_org_id, shipper_org_id) references public.carrier_clients (carrier_org_id, shipper_org_id),
  check (origin_site_id <> destination_site_id),
  check (delivery_at > pickup_at),
  -- Resolución RNDC: las citas no pueden estar a más de 6 días entre sí.
  check (delivery_at - pickup_at <= interval '6 days')
);
create trigger loads_updated_at before update on public.loads
  for each row execute function private.set_updated_at();
create index loads_carrier_status_idx on public.loads (carrier_org_id, status);
create index loads_shipper_idx on public.loads (shipper_org_id, created_at desc);

-- Flete pactado con el generador (no lo ve el camionero).
create table public.load_pricing (
  load_id uuid primary key references public.loads (id) on delete cascade,
  freight_cop bigint not null check (freight_cop > 0),
  updated_by uuid not null references auth.users (id),
  updated_at timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- Ofertas al camionero
-- -----------------------------------------------------------------------------
create table public.offers (
  id uuid primary key default gen_random_uuid(),
  load_id uuid not null references public.loads (id) on delete cascade,
  carrier_org_id uuid not null references public.organizations (id),
  pay_cop bigint not null check (pay_cop > 0),                 -- valor a pagar al titular
  sicetac_floor_cop bigint not null check (sicetac_floor_cop > 0),
  advance_cop bigint not null default 0 check (advance_cop >= 0),
  expires_at timestamptz not null,
  status public.offer_status not null default 'open',
  created_by uuid not null references auth.users (id),
  taken_by uuid references public.drivers (id),
  taken_at timestamptz,
  created_at timestamptz not null default now(),
  -- Decreto 1017 de 2025: el valor a pagar nunca puede ser inferior al SICE-TAC.
  constraint offers_pay_not_below_sicetac check (pay_cop >= sicetac_floor_cop),
  check (advance_cop <= pay_cop)
);
create unique index offers_one_open_per_load on public.offers (load_id) where status = 'open';
create index offers_carrier_status_idx on public.offers (carrier_org_id, status);

-- -----------------------------------------------------------------------------
-- Viajes
-- -----------------------------------------------------------------------------
create table public.trips (
  id uuid primary key default gen_random_uuid(),
  load_id uuid not null references public.loads (id),
  offer_id uuid not null unique references public.offers (id),
  carrier_org_id uuid not null references public.organizations (id),
  shipper_org_id uuid not null references public.organizations (id),
  vehicle_id uuid not null references public.vehicles (id),
  driver_id uuid not null references public.drivers (id),
  holder_id uuid not null references public.holders (id),
  status public.trip_status not null default 'assigned',
  remesa_number text,
  manifest_number text,
  manifest_issued_at timestamptz,
  started_at timestamptz,
  arrived_pickup_at timestamptz,
  departed_pickup_at timestamptz,
  arrived_delivery_at timestamptz,
  delivered_at timestamptz,
  delivered_weight_kg int check (delivered_weight_kg >= 0),
  settled_at timestamptz,
  cancelled_at timestamptz,
  cancel_reason text,
  last_lat double precision,
  last_lng double precision,
  last_position_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create trigger trips_updated_at before update on public.trips
  for each row execute function private.set_updated_at();
create unique index trips_one_active_per_load on public.trips (load_id) where status <> 'cancelled';
create index trips_carrier_status_idx on public.trips (carrier_org_id, status);
create index trips_shipper_idx on public.trips (shipper_org_id, created_at desc);
create index trips_driver_idx on public.trips (driver_id, created_at desc);
create index trips_vehicle_idx on public.trips (vehicle_id, status);

create table public.trip_events (
  id bigint generated always as identity primary key,
  trip_id uuid not null references public.trips (id) on delete cascade,
  kind public.trip_event_kind not null,
  occurred_at timestamptz not null default now(),
  lat double precision,
  lng double precision,
  note text,
  data jsonb not null default '{}'::jsonb,
  actor uuid references auth.users (id),
  created_at timestamptz not null default now()
);
create index trip_events_trip_idx on public.trip_events (trip_id, occurred_at);

-- Puntos de GPS del celular del camionero.
create table public.positions (
  id bigint generated always as identity primary key,
  trip_id uuid not null references public.trips (id) on delete cascade,
  lat double precision not null check (lat between -90 and 90),
  lng double precision not null check (lng between -180 and 180),
  speed_kmh real check (speed_kmh >= 0),
  heading real,
  accuracy_m real,
  recorded_at timestamptz not null,     -- hora del celular (puede llegar tarde si no había señal)
  received_at timestamptz not null default now()
);
create index positions_trip_time_idx on public.positions (trip_id, recorded_at);

create table public.trip_documents (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references public.trips (id) on delete cascade,
  kind public.trip_document_kind not null,
  storage_path text not null,           -- bucket "trip-documents"
  lat double precision,
  lng double precision,
  taken_at timestamptz,
  uploaded_by uuid not null references auth.users (id),
  created_at timestamptz not null default now()
);
create index trip_documents_trip_idx on public.trip_documents (trip_id);

-- -----------------------------------------------------------------------------
-- Pagos al titular del manifiesto
-- -----------------------------------------------------------------------------
create table public.payments (
  trip_id uuid primary key references public.trips (id),
  carrier_org_id uuid not null references public.organizations (id),
  holder_id uuid not null references public.holders (id),
  pay_cop bigint not null check (pay_cop >= 0),
  pickup_extra_hours int not null default 0,
  delivery_extra_hours int not null default 0,
  surcharge_cop bigint not null default 0 check (surcharge_cop >= 0),
  advance_cop bigint not null default 0 check (advance_cop >= 0),
  total_cop bigint not null,
  due_on date not null,
  status public.payment_status not null default 'pending',
  paid_at timestamptz,
  reference text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (total_cop = pay_cop + surcharge_cop - advance_cop)
);
create trigger payments_updated_at before update on public.payments
  for each row execute function private.set_updated_at();
create index payments_carrier_due_idx on public.payments (carrier_org_id, status, due_on);

-- -----------------------------------------------------------------------------
-- Ayudantes de visibilidad
-- -----------------------------------------------------------------------------

/** El camionero puede ver la carga: hay oferta abierta de una transportadora que lo aprobó, o es su viaje. */
create or replace function private.driver_can_see_load(l uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.offers o
    where o.load_id = l and o.status = 'open' and o.expires_at > now()
      and private.driver_approved(o.carrier_org_id, auth.uid())
  ) or exists (
    select 1 from public.trips t where t.load_id = l and t.driver_id = auth.uid()
  )
$$;

create or replace function private.can_see_load(l uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.loads x
    where x.id = l and (private.is_member(x.carrier_org_id) or private.is_member(x.shipper_org_id))
  ) or private.driver_can_see_load(l)
$$;

/** Partes del viaje: transportadora, generador o el camionero asignado. */
create or replace function private.can_see_trip(t uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.trips x
    where x.id = t and (x.driver_id = auth.uid() or private.is_member(x.carrier_org_id) or private.is_member(x.shipper_org_id))
  )
$$;

-- -----------------------------------------------------------------------------
-- RLS
-- -----------------------------------------------------------------------------
alter table public.sites enable row level security;
alter table public.loads enable row level security;
alter table public.load_pricing enable row level security;
alter table public.offers enable row level security;
alter table public.trips enable row level security;
alter table public.trip_events enable row level security;
alter table public.positions enable row level security;
alter table public.trip_documents enable row level security;
alter table public.payments enable row level security;

create policy "Sedes visibles" on public.sites for select to authenticated
  using (
    private.is_member(org_id)
    or exists (select 1 from public.carrier_clients cc where cc.shipper_org_id = org_id and private.is_member(cc.carrier_org_id))
    or exists (
      select 1 from public.loads l
      where (l.origin_site_id = id or l.destination_site_id = id) and private.driver_can_see_load(l.id)
    )
  );

create policy "Cargas visibles" on public.loads for select to authenticated
  using (private.is_member(carrier_org_id) or private.is_member(shipper_org_id) or private.driver_can_see_load(id));

create policy "Flete: transportadora y generador" on public.load_pricing for select to authenticated
  using (exists (
    select 1 from public.loads l
    where l.id = load_id and (private.is_member(l.carrier_org_id) or private.is_member(l.shipper_org_id))
  ));

create policy "Ofertas: transportadora o camionero aprobado" on public.offers for select to authenticated
  using (
    private.is_member(carrier_org_id)
    or taken_by = auth.uid()
    or (status = 'open' and expires_at > now() and private.driver_approved(carrier_org_id, auth.uid()))
  );

create policy "Viajes: partes" on public.trips for select to authenticated
  using (driver_id = auth.uid() or private.is_member(carrier_org_id) or private.is_member(shipper_org_id));

create policy "Eventos: partes del viaje" on public.trip_events for select to authenticated
  using (private.can_see_trip(trip_id));

create policy "GPS: partes del viaje" on public.positions for select to authenticated
  using (private.can_see_trip(trip_id));

create policy "Documentos del viaje: partes" on public.trip_documents for select to authenticated
  using (private.can_see_trip(trip_id));

create policy "Pagos: transportadora, titular o conductor" on public.payments for select to authenticated
  using (
    private.is_member(carrier_org_id)
    or exists (select 1 from public.holders h where h.id = holder_id and h.user_id = auth.uid())
    or exists (select 1 from public.trips t where t.id = trip_id and t.driver_id = auth.uid())
  );

revoke insert, update, delete on public.sites, public.loads, public.load_pricing, public.offers, public.trips,
  public.trip_events, public.positions, public.trip_documents, public.payments from anon, authenticated;
revoke all on public.sites, public.loads, public.load_pricing, public.offers, public.trips,
  public.trip_events, public.positions, public.trip_documents, public.payments from anon;
