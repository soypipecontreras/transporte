-- =============================================================================
-- 0001 · Núcleo: perfiles, organizaciones, miembros y parámetros
--
-- Hay dos tipos de organización:
--   * carrier: empresa de transporte habilitada (nosotros o el aliado). Es la dueña
--     de la operación: publica viajes, vincula camioneros y monitorea.
--   * shipper: empresa generadora de carga (cliente de un carrier).
-- Los camioneros NO pertenecen a una organización: son usuarios con perfil de
-- conductor que una empresa de transporte aprueba (0002).
--
-- Reglas de la casa:
--   * Lecturas: tablas con RLS. Escrituras de negocio: funciones (RPC) que validan
--     el flujo; el front no hace insert/update directo sobre tablas operativas.
--   * Dinero en COP enteros (bigint, sufijo _cop). Fechas de negocio en America/Bogota.
--   * Identificadores en inglés; textos para personas en español (es-CO).
-- =============================================================================

create schema if not exists private;
revoke all on schema private from public;
grant usage on schema private to authenticated, service_role;

create type public.org_kind as enum ('carrier', 'shipper');
create type public.org_role as enum ('owner', 'admin', 'dispatcher', 'viewer');

-- -----------------------------------------------------------------------------
-- Utilidades
-- -----------------------------------------------------------------------------
create or replace function private.set_updated_at() returns trigger
language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end $$;

/** Error de negocio con código legible para el front (SQLSTATE P0001, mensaje "codigo: texto"). */
create or replace function private.fail(code text, message text) returns void
language plpgsql as $$
begin
  raise exception '%: %', code, message using errcode = 'P0001';
end $$;

/** Fecha de hoy en Colombia. */
create or replace function private.today_co(p_at timestamptz default now()) returns date
language sql stable as $$
  select (p_at at time zone 'America/Bogota')::date
$$;

-- -----------------------------------------------------------------------------
-- Perfiles (uno por usuario de auth)
-- -----------------------------------------------------------------------------
create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  full_name text check (char_length(full_name) <= 120),
  phone text,
  email text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create trigger profiles_updated_at before update on public.profiles
  for each row execute function private.set_updated_at();

create or replace function private.handle_new_user() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles (id, full_name, phone, email)
  values (new.id, nullif(new.raw_user_meta_data ->> 'full_name', ''), new.phone, new.email)
  on conflict (id) do nothing;
  return new;
end $$;

create trigger on_auth_user_created after insert on auth.users
  for each row execute function private.handle_new_user();

-- -----------------------------------------------------------------------------
-- Organizaciones y miembros
-- -----------------------------------------------------------------------------
create table public.organizations (
  id uuid primary key default gen_random_uuid(),
  kind public.org_kind not null,
  name text not null check (char_length(name) between 1 and 160),
  nit text check (nit ~ '^[0-9]{6,12}(-[0-9])?$'),
  city text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (nit, kind)
);
create trigger organizations_updated_at before update on public.organizations
  for each row execute function private.set_updated_at();

create table public.memberships (
  org_id uuid not null references public.organizations (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  role public.org_role not null default 'viewer',
  created_at timestamptz not null default now(),
  primary key (org_id, user_id)
);
create index memberships_user_idx on public.memberships (user_id);

-- Clientes (generadores) que atiende cada empresa de transporte.
create table public.carrier_clients (
  carrier_org_id uuid not null references public.organizations (id) on delete cascade,
  shipper_org_id uuid not null references public.organizations (id) on delete cascade,
  payment_terms_days int not null default 5 check (payment_terms_days between 0 and 120),
  active boolean not null default true,
  created_at timestamptz not null default now(),
  primary key (carrier_org_id, shipper_org_id)
);
create index carrier_clients_shipper_idx on public.carrier_clients (shipper_org_id);

-- -----------------------------------------------------------------------------
-- Ayudantes de permisos (security definer para que RLS no se llame a sí misma)
-- -----------------------------------------------------------------------------
create or replace function private.has_role(org uuid, roles public.org_role[]) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.memberships m
    where m.org_id = org and m.user_id = auth.uid() and m.role = any (roles)
  )
$$;

create or replace function private.is_member(org uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.memberships m where m.org_id = org and m.user_id = auth.uid())
$$;

/** Puede operar (crear cargas, publicar, aprobar): owner, admin o dispatcher. */
create or replace function private.can_operate(org uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select private.has_role(org, array['owner', 'admin', 'dispatcher']::public.org_role[])
$$;

create or replace function private.org_kind_of(org uuid) returns public.org_kind
language sql stable security definer set search_path = '' as $$
  select kind from public.organizations where id = org
$$;

-- -----------------------------------------------------------------------------
-- Parámetros: salario mínimo y festivos (para recargos y plazos de pago)
-- -----------------------------------------------------------------------------
create table public.minimum_wages (
  year int primary key,
  monthly_cop bigint not null check (monthly_cop > 0)
);

create table public.holidays (
  day date primary key,
  name text not null
);

/** SMMLV vigente en una fecha (el último año cargado que no sea posterior). */
create or replace function private.monthly_wage_cop(d date) returns bigint
language sql stable security definer set search_path = '' as $$
  select monthly_cop from public.minimum_wages
  where year <= extract(year from d)::int
  order by year desc limit 1
$$;

create or replace function private.is_business_day(d date) returns boolean
language sql stable security definer set search_path = '' as $$
  select extract(isodow from d) < 6 and not exists (select 1 from public.holidays h where h.day = d)
$$;

/** Suma n días hábiles a una fecha (sábados, domingos y festivos no cuentan). */
create or replace function private.add_business_days(d date, n int) returns date
language plpgsql stable security definer set search_path = '' as $$
declare
  result date := d;
  added int := 0;
begin
  while added < n loop
    result := result + 1;
    if private.is_business_day(result) then
      added := added + 1;
    end if;
  end loop;
  return result;
end $$;

-- -----------------------------------------------------------------------------
-- RLS
-- -----------------------------------------------------------------------------
alter table public.profiles enable row level security;
alter table public.organizations enable row level security;
alter table public.memberships enable row level security;
alter table public.carrier_clients enable row level security;
alter table public.minimum_wages enable row level security;
alter table public.holidays enable row level security;

create policy "Mi perfil" on public.profiles for select to authenticated
  using (id = auth.uid());
create policy "Edito mi perfil" on public.profiles for update to authenticated
  using (id = auth.uid()) with check (id = auth.uid());

create policy "Mis organizaciones y las relacionadas" on public.organizations for select to authenticated
  using (
    private.is_member(id)
    or exists (
      select 1 from public.carrier_clients cc
      where (cc.carrier_org_id = id and private.is_member(cc.shipper_org_id))
         or (cc.shipper_org_id = id and private.is_member(cc.carrier_org_id))
    )
  );
create policy "Admins editan su organización" on public.organizations for update to authenticated
  using (private.has_role(id, array['owner', 'admin']::public.org_role[]))
  with check (private.has_role(id, array['owner', 'admin']::public.org_role[]));

create policy "Miembros de mis organizaciones" on public.memberships for select to authenticated
  using (user_id = auth.uid() or private.is_member(org_id));

create policy "Clientes y transportadoras" on public.carrier_clients for select to authenticated
  using (private.is_member(carrier_org_id) or private.is_member(shipper_org_id));

create policy "Parámetros públicos" on public.minimum_wages for select to authenticated using (true);
create policy "Festivos públicos" on public.holidays for select to authenticated using (true);

-- Las escrituras de negocio pasan por funciones; se quitan los permisos directos.
revoke insert, update, delete on public.organizations, public.memberships, public.carrier_clients,
  public.minimum_wages, public.holidays from anon, authenticated;
revoke all on public.profiles from anon;
revoke insert, delete on public.profiles from authenticated;
revoke all on public.organizations, public.memberships, public.carrier_clients from anon;

-- -----------------------------------------------------------------------------
-- RPC: organizaciones
-- -----------------------------------------------------------------------------

/** Crea una organización y deja al usuario como dueño. */
create or replace function public.organization_create(p_kind public.org_kind, p_name text, p_nit text default null, p_city text default null)
returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  org uuid;
begin
  if auth.uid() is null then perform private.fail('auth', 'Inicia sesión.'); end if;
  insert into public.organizations (kind, name, nit, city) values (p_kind, trim(p_name), p_nit, p_city)
  returning id into org;
  insert into public.memberships (org_id, user_id, role) values (org, auth.uid(), 'owner');
  return org;
end $$;

/** La empresa de transporte agrega como cliente a un generador por su NIT. */
create or replace function public.carrier_add_client(p_carrier_org_id uuid, p_shipper_nit text, p_payment_terms_days int default 5)
returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  shipper uuid;
begin
  if not private.has_role(p_carrier_org_id, array['owner', 'admin']::public.org_role[])
     or private.org_kind_of(p_carrier_org_id) <> 'carrier' then
    perform private.fail('forbidden', 'Solo un administrador de la empresa de transporte agrega clientes.');
  end if;
  select id into shipper from public.organizations where nit = p_shipper_nit and kind = 'shipper';
  if shipper is null then perform private.fail('not_found', 'No hay una empresa generadora con ese NIT.'); end if;
  insert into public.carrier_clients (carrier_org_id, shipper_org_id, payment_terms_days)
  values (p_carrier_org_id, shipper, p_payment_terms_days)
  on conflict (carrier_org_id, shipper_org_id) do update set active = true, payment_terms_days = excluded.payment_terms_days;
  return shipper;
end $$;

/** Agrega (o cambia el rol de) un miembro por su correo. El usuario ya debe tener cuenta. */
create or replace function public.organization_add_member(p_org_id uuid, p_email text, p_role public.org_role)
returns uuid
language plpgsql security definer set search_path = '' as $$
declare
  member uuid;
begin
  if not private.has_role(p_org_id, array['owner', 'admin']::public.org_role[]) then
    perform private.fail('forbidden', 'Solo un administrador agrega miembros.');
  end if;
  if p_role = 'owner' and not private.has_role(p_org_id, array['owner']::public.org_role[]) then
    perform private.fail('forbidden', 'Solo un dueño nombra otro dueño.');
  end if;
  select id into member from auth.users where lower(email) = lower(trim(p_email));
  if member is null then perform private.fail('not_found', 'Esa persona todavía no tiene cuenta.'); end if;
  insert into public.memberships (org_id, user_id, role) values (p_org_id, member, p_role)
  on conflict (org_id, user_id) do update set role = excluded.role;
  return member;
end $$;
