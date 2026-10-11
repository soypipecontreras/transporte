-- =============================================================================
-- 0002 · Flota: conductores, titulares, vehículos y vinculación
--
-- Un camionero se registra en la app (con su celular) y carga sus datos, los de
-- su camión y los del titular del manifiesto (propietario, poseedor o tenedor,
-- que muchas veces es él mismo). Después se postula a una empresa de transporte,
-- que lo revisa (estudio de seguridad) y lo aprueba. Solo los aprobados ven
-- ofertas de esa empresa.
--
-- Validaciones contra RUNT/SIMIT: pendientes de proveedor; por ahora la revisión
-- la hace una persona de operaciones con los documentos cargados.
-- =============================================================================

create type public.license_category as enum ('C1', 'C2', 'C3');
-- Configuraciones de la Resolución 4100 de 2004 que vamos a operar.
create type public.vehicle_configuration as enum ('C2', 'C3', 'C4', '2S2', '2S3', '3S2', '3S3');
create type public.body_type as enum (
  'van',           -- furgón
  'reefer',        -- furgón refrigerado
  'stake',         -- estacas
  'flatbed',       -- plancha
  'dump',          -- volco
  'tanker',        -- tanque
  'container',     -- portacontenedor
  'lowboy',        -- cama baja
  'other'
);
create type public.review_status as enum ('pending', 'approved', 'rejected', 'blocked');
create type public.holder_kind as enum ('person', 'company');
create type public.document_type as enum ('CC', 'CE', 'PPT', 'NIT');
create type public.credential_kind as enum (
  'id_card',            -- cédula
  'driver_license',     -- licencia de conducción
  'social_security',    -- planilla PILA
  'vehicle_license',    -- licencia de tránsito
  'trailer_license',    -- licencia del remolque
  'soat',
  'technical_review',   -- revisión técnico-mecánica
  'insurance_policy',
  'bank_certificate',
  'rut',
  'other'
);

/** Articulados (tractocamión + remolque): recargo de 3 SMLDV por hora; rígidos: 2. */
create or replace function private.is_articulated(c public.vehicle_configuration) returns boolean
language sql immutable as $$
  select c in ('2S2', '2S3', '3S2', '3S3')
$$;

-- -----------------------------------------------------------------------------
-- Conductores (1:1 con el usuario)
-- -----------------------------------------------------------------------------
create table public.drivers (
  id uuid primary key references auth.users (id) on delete cascade,
  full_name text not null check (char_length(full_name) between 3 and 120),
  document_type public.document_type not null default 'CC',
  document_number text not null check (document_number ~ '^[0-9A-Za-z]{4,15}$'),
  phone text not null,
  license_category public.license_category not null,
  license_expires_on date not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (document_type, document_number)
);
create trigger drivers_updated_at before update on public.drivers
  for each row execute function private.set_updated_at();

-- Titular del manifiesto: a quien se le paga el valor a pagar.
create table public.holders (
  id uuid primary key default gen_random_uuid(),
  kind public.holder_kind not null default 'person',
  name text not null check (char_length(name) between 3 and 160),
  document_type public.document_type not null default 'CC',
  document_number text not null check (document_number ~ '^[0-9A-Za-z-]{4,15}$'),
  phone text,
  bank_name text,
  bank_account_type text check (bank_account_type in ('savings', 'checking')),
  bank_account_number text,
  user_id uuid references auth.users (id) on delete set null, -- si el titular usa la app
  created_by uuid not null references auth.users (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (document_type, document_number)
);
create trigger holders_updated_at before update on public.holders
  for each row execute function private.set_updated_at();

create table public.vehicles (
  id uuid primary key default gen_random_uuid(),
  plate text not null unique check (plate ~ '^[A-Z]{3}[0-9]{3}$'),
  trailer_plate text check (trailer_plate ~ '^[A-Z]{1,2}[0-9]{4,5}$'),
  configuration public.vehicle_configuration not null,
  body_type public.body_type not null,
  brand text,
  model_year int check (model_year between 1950 and 2100),
  gross_weight_kg int check (gross_weight_kg > 0),      -- PBV de la ficha de homologación
  payload_kg int not null check (payload_kg > 0),       -- capacidad de carga útil
  soat_expires_on date not null,
  technical_review_expires_on date,                      -- null: vehículo nuevo, aún no la requiere
  holder_id uuid not null references public.holders (id),
  registered_by uuid not null references auth.users (id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create trigger vehicles_updated_at before update on public.vehicles
  for each row execute function private.set_updated_at();
create index vehicles_holder_idx on public.vehicles (holder_id);

-- Quién puede manejar cada vehículo.
create table public.vehicle_drivers (
  vehicle_id uuid not null references public.vehicles (id) on delete cascade,
  driver_id uuid not null references public.drivers (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (vehicle_id, driver_id)
);
create index vehicle_drivers_driver_idx on public.vehicle_drivers (driver_id);

-- Revisión y aprobación por cada empresa de transporte.
create table public.carrier_drivers (
  carrier_org_id uuid not null references public.organizations (id) on delete cascade,
  driver_id uuid not null references public.drivers (id) on delete cascade,
  status public.review_status not null default 'pending',
  notes text,
  reviewed_by uuid references auth.users (id),
  reviewed_at timestamptz,
  created_at timestamptz not null default now(),
  primary key (carrier_org_id, driver_id)
);
create index carrier_drivers_driver_idx on public.carrier_drivers (driver_id);

create table public.carrier_vehicles (
  carrier_org_id uuid not null references public.organizations (id) on delete cascade,
  vehicle_id uuid not null references public.vehicles (id) on delete cascade,
  status public.review_status not null default 'pending',
  notes text,
  reviewed_by uuid references auth.users (id),
  reviewed_at timestamptz,
  created_at timestamptz not null default now(),
  primary key (carrier_org_id, vehicle_id)
);
create index carrier_vehicles_vehicle_idx on public.carrier_vehicles (vehicle_id);

-- Documentos del conductor, del vehículo o del titular (archivos en Storage, bucket "credentials").
create table public.credential_documents (
  id uuid primary key default gen_random_uuid(),
  kind public.credential_kind not null,
  driver_id uuid references public.drivers (id) on delete cascade,
  vehicle_id uuid references public.vehicles (id) on delete cascade,
  holder_id uuid references public.holders (id) on delete cascade,
  storage_path text not null,
  expires_on date,
  uploaded_by uuid not null references auth.users (id),
  created_at timestamptz not null default now(),
  check (num_nonnulls(driver_id, vehicle_id, holder_id) = 1)
);
create index credential_documents_driver_idx on public.credential_documents (driver_id);
create index credential_documents_vehicle_idx on public.credential_documents (vehicle_id);
create index credential_documents_holder_idx on public.credential_documents (holder_id);

-- -----------------------------------------------------------------------------
-- Ayudantes
-- -----------------------------------------------------------------------------

/** El usuario registró el vehículo, lo maneja o es su titular. */
create or replace function private.owns_vehicle(v uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.vehicles x
    left join public.holders h on h.id = x.holder_id
    where x.id = v and (x.registered_by = auth.uid() or h.user_id = auth.uid()
      or exists (select 1 from public.vehicle_drivers vd where vd.vehicle_id = v and vd.driver_id = auth.uid()))
  )
$$;

create or replace function private.can_see_holder(h uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.holders x
    where x.id = h and (x.created_by = auth.uid() or x.user_id = auth.uid()
      or exists (select 1 from public.vehicles v where v.holder_id = h and private.owns_vehicle(v.id))
      or exists (
        select 1 from public.vehicles v join public.carrier_vehicles cv on cv.vehicle_id = v.id
        where v.holder_id = h and private.is_member(cv.carrier_org_id)
      ))
  )
$$;

/** El conductor está aprobado por la empresa de transporte. */
create or replace function private.driver_approved(carrier uuid, d uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.carrier_drivers cd
    where cd.carrier_org_id = carrier and cd.driver_id = d and cd.status = 'approved'
  )
$$;

-- -----------------------------------------------------------------------------
-- RLS
-- -----------------------------------------------------------------------------
alter table public.drivers enable row level security;
alter table public.holders enable row level security;
alter table public.vehicles enable row level security;
alter table public.vehicle_drivers enable row level security;
alter table public.carrier_drivers enable row level security;
alter table public.carrier_vehicles enable row level security;
alter table public.credential_documents enable row level security;

create policy "Conductor: yo o mi transportadora" on public.drivers for select to authenticated
  using (
    id = auth.uid()
    or exists (select 1 from public.carrier_drivers cd where cd.driver_id = id and private.is_member(cd.carrier_org_id))
  );

create policy "Titulares visibles" on public.holders for select to authenticated
  using (private.can_see_holder(id));

create policy "Vehículos visibles" on public.vehicles for select to authenticated
  using (
    private.owns_vehicle(id)
    or exists (select 1 from public.carrier_vehicles cv where cv.vehicle_id = id and private.is_member(cv.carrier_org_id))
  );

create policy "Conductores de vehículos visibles" on public.vehicle_drivers for select to authenticated
  using (
    driver_id = auth.uid() or private.owns_vehicle(vehicle_id)
    or exists (select 1 from public.carrier_vehicles cv where cv.vehicle_id = vehicle_id and private.is_member(cv.carrier_org_id))
  );

create policy "Postulaciones de conductores" on public.carrier_drivers for select to authenticated
  using (driver_id = auth.uid() or private.is_member(carrier_org_id));

create policy "Postulaciones de vehículos" on public.carrier_vehicles for select to authenticated
  using (private.owns_vehicle(vehicle_id) or private.is_member(carrier_org_id));

create policy "Documentos de credenciales" on public.credential_documents for select to authenticated
  using (
    uploaded_by = auth.uid()
    or (driver_id is not null and (driver_id = auth.uid() or exists (
      select 1 from public.carrier_drivers cd where cd.driver_id = credential_documents.driver_id and private.is_member(cd.carrier_org_id))))
    or (vehicle_id is not null and (private.owns_vehicle(vehicle_id) or exists (
      select 1 from public.carrier_vehicles cv where cv.vehicle_id = credential_documents.vehicle_id and private.is_member(cv.carrier_org_id))))
    or (holder_id is not null and private.can_see_holder(holder_id))
  );

revoke insert, update, delete on public.drivers, public.holders, public.vehicles, public.vehicle_drivers,
  public.carrier_drivers, public.carrier_vehicles, public.credential_documents from anon, authenticated;
revoke all on public.drivers, public.holders, public.vehicles, public.vehicle_drivers,
  public.carrier_drivers, public.carrier_vehicles, public.credential_documents from anon;

-- -----------------------------------------------------------------------------
-- RPC: registro del camionero
-- -----------------------------------------------------------------------------

/** Crea o actualiza mi perfil de conductor. */
create or replace function public.driver_upsert_me(
  p_full_name text,
  p_document_number text,
  p_license_category public.license_category,
  p_license_expires_on date,
  p_document_type public.document_type default 'CC',
  p_phone text default null
) returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  phone_value text;
  before public.drivers%rowtype;
begin
  if me is null then perform private.fail('auth', 'Inicia sesión.'); end if;
  select coalesce(p_phone, u.phone) into phone_value from auth.users u where u.id = me;
  if phone_value is null then perform private.fail('invalid', 'Falta el celular.'); end if;
  select * into before from public.drivers where id = me;
  insert into public.drivers (id, full_name, document_type, document_number, phone, license_category, license_expires_on)
  values (me, trim(p_full_name), p_document_type, p_document_number, phone_value, p_license_category, p_license_expires_on)
  on conflict (id) do update set
    full_name = excluded.full_name, document_type = excluded.document_type, document_number = excluded.document_number,
    phone = excluded.phone, license_category = excluded.license_category, license_expires_on = excluded.license_expires_on;
  update public.profiles set full_name = trim(p_full_name), phone = phone_value where id = me;
  -- Si cambian datos clave (documento o licencia), las aprobaciones vuelven a revisión.
  if before.id is not null and (before.document_number, before.document_type, before.license_category)
     is distinct from (p_document_number, p_document_type, p_license_category) then
    update public.carrier_drivers set status = 'pending', reviewed_at = null, reviewed_by = null
    where driver_id = me and status = 'approved';
  end if;
  return me;
end $$;

/** Registra un titular (o devuelve el existente con el mismo documento). */
create or replace function public.holder_upsert(
  p_name text,
  p_document_number text,
  p_document_type public.document_type default 'CC',
  p_kind public.holder_kind default 'person',
  p_phone text default null,
  p_bank_name text default null,
  p_bank_account_type text default null,
  p_bank_account_number text default null,
  p_is_me boolean default false
) returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  existing public.holders%rowtype;
  result uuid;
begin
  if me is null then perform private.fail('auth', 'Inicia sesión.'); end if;
  select * into existing from public.holders where document_type = p_document_type and document_number = p_document_number;
  if found then
    if existing.created_by <> me and coalesce(existing.user_id, '00000000-0000-0000-0000-000000000000') <> me then
      -- Ya existe y lo registró otra persona: no se pisa (datos bancarios), solo se reutiliza.
      return existing.id;
    end if;
    update public.holders set
      name = trim(p_name), kind = p_kind, phone = coalesce(p_phone, phone),
      bank_name = coalesce(p_bank_name, bank_name), bank_account_type = coalesce(p_bank_account_type, bank_account_type),
      bank_account_number = coalesce(p_bank_account_number, bank_account_number),
      user_id = case when p_is_me then me else user_id end
    where id = existing.id;
    return existing.id;
  end if;
  insert into public.holders (kind, name, document_type, document_number, phone, bank_name, bank_account_type,
    bank_account_number, user_id, created_by)
  values (p_kind, trim(p_name), p_document_type, p_document_number, p_phone, p_bank_name, p_bank_account_type,
    p_bank_account_number, case when p_is_me then me end, me)
  returning id into result;
  return result;
end $$;

/** Registra (o actualiza) un vehículo; quien lo registra queda como conductor autorizado si es conductor. */
create or replace function public.vehicle_upsert(
  p_plate text,
  p_configuration public.vehicle_configuration,
  p_body_type public.body_type,
  p_payload_kg int,
  p_soat_expires_on date,
  p_holder_id uuid,
  p_technical_review_expires_on date default null,
  p_trailer_plate text default null,
  p_gross_weight_kg int default null,
  p_brand text default null,
  p_model_year int default null
) returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  me uuid := auth.uid();
  plate_value text := upper(replace(trim(p_plate), ' ', ''));
  existing public.vehicles%rowtype;
  result uuid;
begin
  if me is null then perform private.fail('auth', 'Inicia sesión.'); end if;
  if not private.can_see_holder(p_holder_id) then perform private.fail('forbidden', 'Ese titular no es tuyo.'); end if;
  select * into existing from public.vehicles where plate = plate_value;
  if found then
    if not private.owns_vehicle(existing.id) then
      perform private.fail('conflict', 'Esa placa ya está registrada por otra persona.');
    end if;
    update public.vehicles set
      configuration = p_configuration, body_type = p_body_type, payload_kg = p_payload_kg,
      soat_expires_on = p_soat_expires_on, technical_review_expires_on = p_technical_review_expires_on,
      holder_id = p_holder_id, trailer_plate = upper(nullif(trim(p_trailer_plate), '')),
      gross_weight_kg = p_gross_weight_kg, brand = p_brand, model_year = p_model_year
    where id = existing.id;
    result := existing.id;
    update public.carrier_vehicles set status = 'pending', reviewed_at = null, reviewed_by = null
    where vehicle_id = result and status = 'approved';
  else
    insert into public.vehicles (plate, trailer_plate, configuration, body_type, payload_kg, gross_weight_kg,
      soat_expires_on, technical_review_expires_on, holder_id, brand, model_year, registered_by)
    values (plate_value, upper(nullif(trim(p_trailer_plate), '')), p_configuration, p_body_type, p_payload_kg,
      p_gross_weight_kg, p_soat_expires_on, p_technical_review_expires_on, p_holder_id, p_brand, p_model_year, me)
    returning id into result;
  end if;
  if exists (select 1 from public.drivers where id = me) then
    insert into public.vehicle_drivers (vehicle_id, driver_id) values (result, me) on conflict do nothing;
  end if;
  return result;
end $$;

/** Registra el archivo (ya subido a Storage) de un documento. */
create or replace function public.credential_document_add(
  p_kind public.credential_kind,
  p_storage_path text,
  p_driver_id uuid default null,
  p_vehicle_id uuid default null,
  p_holder_id uuid default null,
  p_expires_on date default null
) returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  result uuid;
begin
  if auth.uid() is null then perform private.fail('auth', 'Inicia sesión.'); end if;
  if (p_driver_id is not null and p_driver_id <> auth.uid())
     or (p_vehicle_id is not null and not private.owns_vehicle(p_vehicle_id))
     or (p_holder_id is not null and not private.can_see_holder(p_holder_id)) then
    perform private.fail('forbidden', 'No puedes cargar documentos de otra persona.');
  end if;
  insert into public.credential_documents (kind, driver_id, vehicle_id, holder_id, storage_path, expires_on, uploaded_by)
  values (p_kind, p_driver_id, p_vehicle_id, p_holder_id, p_storage_path, p_expires_on, auth.uid())
  returning id into result;
  return result;
end $$;

/** El camionero se postula (con su vehículo) a una empresa de transporte. */
create or replace function public.carrier_apply(p_carrier_org_id uuid, p_vehicle_id uuid default null)
returns void
language plpgsql security definer set search_path = '' as $$
begin
  if not exists (select 1 from public.drivers where id = auth.uid()) then
    perform private.fail('invalid', 'Primero completa tu perfil de conductor.');
  end if;
  if private.org_kind_of(p_carrier_org_id) is distinct from 'carrier' then
    perform private.fail('not_found', 'Esa empresa de transporte no existe.');
  end if;
  insert into public.carrier_drivers (carrier_org_id, driver_id) values (p_carrier_org_id, auth.uid())
  on conflict do nothing;
  if p_vehicle_id is not null then
    if not private.owns_vehicle(p_vehicle_id) then perform private.fail('forbidden', 'Ese vehículo no es tuyo.'); end if;
    insert into public.carrier_vehicles (carrier_org_id, vehicle_id) values (p_carrier_org_id, p_vehicle_id)
    on conflict do nothing;
  end if;
end $$;

-- -----------------------------------------------------------------------------
-- RPC: revisión por la empresa de transporte (SaaS)
-- -----------------------------------------------------------------------------
create or replace function public.carrier_review_driver(p_carrier_org_id uuid, p_driver_id uuid, p_status public.review_status, p_notes text default null)
returns void
language plpgsql security definer set search_path = '' as $$
begin
  if not private.can_operate(p_carrier_org_id) then perform private.fail('forbidden', 'No puedes revisar conductores.'); end if;
  update public.carrier_drivers set status = p_status, notes = p_notes, reviewed_by = auth.uid(), reviewed_at = now()
  where carrier_org_id = p_carrier_org_id and driver_id = p_driver_id;
  if not found then perform private.fail('not_found', 'Ese conductor no se ha postulado.'); end if;
end $$;

create or replace function public.carrier_review_vehicle(p_carrier_org_id uuid, p_vehicle_id uuid, p_status public.review_status, p_notes text default null)
returns void
language plpgsql security definer set search_path = '' as $$
begin
  if not private.can_operate(p_carrier_org_id) then perform private.fail('forbidden', 'No puedes revisar vehículos.'); end if;
  update public.carrier_vehicles set status = p_status, notes = p_notes, reviewed_by = auth.uid(), reviewed_at = now()
  where carrier_org_id = p_carrier_org_id and vehicle_id = p_vehicle_id;
  if not found then perform private.fail('not_found', 'Ese vehículo no se ha postulado.'); end if;
end $$;
