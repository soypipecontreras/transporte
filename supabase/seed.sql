-- =============================================================================
-- Semilla de desarrollo (NO va a producción)
--
-- Usuarios de prueba:
--   ops@demo.co        / demo1234   dueño de la transportadora "Transportes Demo"
--   cliente@demo.co    / demo1234   dueño del generador "Alimentos Andinos"
--   +57 300 111 2233   código 123456   camionero aprobado (Juan Pérez, camión ABC123)
--   +57 300 444 5566   código 123456   camionero pendiente de aprobación (Luis Gómez)
-- Las fechas se calculan desde el momento en que se carga la semilla.
-- =============================================================================

insert into auth.users (id, email, phone, raw_user_meta_data) values
  ('a0000000-0000-4000-8000-000000000001', 'ops@demo.co', null, '{"full_name": "Operaciones Demo"}'),
  ('a0000000-0000-4000-8000-000000000002', 'cliente@demo.co', null, '{"full_name": "Carolina Ruiz"}'),
  ('a0000000-0000-4000-8000-000000000003', null, '573001112233', '{"full_name": "Juan Pérez"}'),
  ('a0000000-0000-4000-8000-000000000004', null, '573004445566', '{"full_name": "Luis Gómez"}');

-- En Supabase real (no en las pruebas) se completan las columnas que necesita el login.
do $$
begin
  if exists (select 1 from information_schema.columns
             where table_schema = 'auth' and table_name = 'users' and column_name = 'encrypted_password') then
    execute $sql$
      update auth.users set
        instance_id = '00000000-0000-0000-0000-000000000000',
        aud = 'authenticated', role = 'authenticated',
        encrypted_password = case when email is not null then extensions.crypt('demo1234', extensions.gen_salt('bf')) else '' end,
        email_confirmed_at = case when email is not null then now() end,
        phone_confirmed_at = case when phone is not null then now() end,
        confirmation_token = '', recovery_token = '', email_change = '', email_change_token_new = '',
        email_change_token_current = '', phone_change = '', phone_change_token = '', reauthentication_token = '',
        raw_app_meta_data = case when email is not null
          then '{"provider": "email", "providers": ["email"]}'::jsonb
          else '{"provider": "phone", "providers": ["phone"]}'::jsonb end,
        created_at = now(), updated_at = now()
      where id::text like 'a0000000-0000-4000-8000-%'
    $sql$;
    execute $sql$
      insert into auth.identities (id, user_id, provider_id, provider, identity_data, created_at, updated_at, last_sign_in_at)
      select gen_random_uuid(), u.id, u.id::text, case when u.email is not null then 'email' else 'phone' end,
        jsonb_build_object('sub', u.id::text, 'email', u.email, 'phone', u.phone), now(), now(), now()
      from auth.users u where u.id::text like 'a0000000-0000-4000-8000-%'
    $sql$;
  end if;
end $$;

-- Organizaciones
insert into public.organizations (id, kind, name, nit, city) values
  ('c0000000-0000-4000-8000-000000000001', 'carrier', 'Transportes Demo S.A.S.', '900123456-1', 'Bogotá'),
  ('50000000-0000-4000-8000-000000000001', 'shipper', 'Alimentos Andinos S.A.S.', '900765432-1', 'Funza');

insert into public.memberships (org_id, user_id, role) values
  ('c0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001', 'owner'),
  ('50000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000002', 'owner');

insert into public.carrier_clients (carrier_org_id, shipper_org_id, payment_terms_days) values
  ('c0000000-0000-4000-8000-000000000001', '50000000-0000-4000-8000-000000000001', 30);

insert into public.sites (id, org_id, name, address, city, dane_code, lat, lng, geofence_m, contact_name, contact_phone) values
  ('5e000000-0000-4000-8000-000000000001', '50000000-0000-4000-8000-000000000001', 'Planta Funza',
   'Parque Industrial San Diego, Bodega 12', 'Funza', '25286', 4.7163, -74.2110, 400, 'Portería', '3105550001'),
  ('5e000000-0000-4000-8000-000000000002', '50000000-0000-4000-8000-000000000001', 'CEDI Itagüí',
   'Cra 50 # 12 Sur-30', 'Itagüí', '05360', 6.1719, -75.6110, 300, 'Recibo', '3105550002');

-- Camioneros, titular y vehículo
insert into public.drivers (id, full_name, document_type, document_number, phone, license_category, license_expires_on) values
  ('a0000000-0000-4000-8000-000000000003', 'Juan Pérez', 'CC', '79123456', '573001112233', 'C3', current_date + 700),
  ('a0000000-0000-4000-8000-000000000004', 'Luis Gómez', 'CC', '80123456', '573004445566', 'C2', current_date + 400);

insert into public.holders (id, kind, name, document_type, document_number, phone, bank_name, bank_account_type,
  bank_account_number, user_id, created_by) values
  ('b0000000-0000-4000-8000-000000000001', 'person', 'Juan Pérez', 'CC', '79123456', '573001112233', 'Bancolombia',
   'savings', '12345678901', 'a0000000-0000-4000-8000-000000000003', 'a0000000-0000-4000-8000-000000000003');

insert into public.vehicles (id, plate, trailer_plate, configuration, body_type, brand, model_year, gross_weight_kg,
  payload_kg, soat_expires_on, technical_review_expires_on, holder_id, registered_by) values
  ('7e000000-0000-4000-8000-000000000001', 'ABC123', 'R12345', '3S2', 'van', 'Kenworth', 2018, 48000, 34000,
   current_date + 200, current_date + 150, 'b0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000003');

insert into public.vehicle_drivers (vehicle_id, driver_id) values
  ('7e000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000003');

insert into public.carrier_drivers (carrier_org_id, driver_id, status, reviewed_by, reviewed_at) values
  ('c0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000003', 'approved', 'a0000000-0000-4000-8000-000000000001', now()),
  ('c0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000004', 'pending', null, null);

insert into public.carrier_vehicles (carrier_org_id, vehicle_id, status, reviewed_by, reviewed_at) values
  ('c0000000-0000-4000-8000-000000000001', '7e000000-0000-4000-8000-000000000001', 'approved', 'a0000000-0000-4000-8000-000000000001', now());

-- Cargas: una publicada (con oferta abierta) y una pendiente de precio
insert into public.loads (id, carrier_org_id, shipper_org_id, reference, origin_site_id, destination_site_id,
  cargo_description, merchandise_code, packaging, weight_kg, volume_m3, declared_value_cop,
  required_configurations, required_body_types, pickup_at, delivery_at, status, created_by) values
  ('10ad0000-0000-4000-8000-000000000001', 'c0000000-0000-4000-8000-000000000001', '50000000-0000-4000-8000-000000000001',
   'PED-1001', '5e000000-0000-4000-8000-000000000001', '5e000000-0000-4000-8000-000000000002',
   'Pasabocas empacados en cajas', '009880', 'Cajas sobre estibas', 18000, 60, 180000000,
   '{3S2,3S3}', '{van}', date_trunc('day', now()) + interval '1 day 13 hours', date_trunc('day', now()) + interval '2 days 13 hours',
   'published', 'a0000000-0000-4000-8000-000000000002'),
  ('10ad0000-0000-4000-8000-000000000002', 'c0000000-0000-4000-8000-000000000001', '50000000-0000-4000-8000-000000000001',
   'PED-1002', '5e000000-0000-4000-8000-000000000001', '5e000000-0000-4000-8000-000000000002',
   'Aceite vegetal en cajas', '009880', 'Cajas sobre estibas', 30000, 45, 250000000,
   '{}', '{van}', date_trunc('day', now()) + interval '3 days 12 hours', date_trunc('day', now()) + interval '4 days 14 hours',
   'requested', 'a0000000-0000-4000-8000-000000000002');

insert into public.load_pricing (load_id, freight_cop, updated_by) values
  ('10ad0000-0000-4000-8000-000000000001', 7600000, 'a0000000-0000-4000-8000-000000000001');

insert into public.offers (id, load_id, carrier_org_id, pay_cop, sicetac_floor_cop, advance_cop, expires_at, created_by) values
  ('0ff00000-0000-4000-8000-000000000001', '10ad0000-0000-4000-8000-000000000001', 'c0000000-0000-4000-8000-000000000001',
   6500000, 6200000, 1500000, date_trunc('day', now()) + interval '1 day 11 hours', 'a0000000-0000-4000-8000-000000000001');
