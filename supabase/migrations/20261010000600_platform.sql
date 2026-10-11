-- pglite:skip
-- =============================================================================
-- 0006 · Piezas propias de Supabase: archivos (Storage) y tiempo real (Realtime)
--
-- No corre en PGlite (las pruebas): allá no existen los esquemas storage ni la
-- publicación supabase_realtime. Se valida con `supabase start` (Docker) o en la nube.
--
-- Rutas de archivos:
--   credentials/<user_id>/<archivo>        documentos del camionero, su vehículo y titular
--   trip-documents/<trip_id>/<archivo>     fotos de cargue/entrega, soportes y PDF del viaje
-- =============================================================================

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('credentials', 'credentials', false, 10485760, array['image/jpeg', 'image/png', 'image/webp', 'application/pdf']),
  ('trip-documents', 'trip-documents', false, 10485760, array['image/jpeg', 'image/png', 'image/webp', 'application/pdf'])
on conflict (id) do nothing;

-- Credenciales: cada quien sube a su carpeta; las leen el dueño y la transportadora que ve el documento.
create policy "Subo mis credenciales" on storage.objects for insert to authenticated
  with check (bucket_id = 'credentials' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "Leo credenciales visibles" on storage.objects for select to authenticated
  using (
    bucket_id = 'credentials' and (
      (storage.foldername(name))[1] = auth.uid()::text
      or exists (select 1 from public.credential_documents cd where cd.storage_path = name)
    )
  );

-- Documentos del viaje: suben el conductor y operaciones; leen las partes del viaje.
create policy "Subo documentos de mi viaje" on storage.objects for insert to authenticated
  with check (
    bucket_id = 'trip-documents' and exists (
      select 1 from public.trips t
      where t.id::text = (storage.foldername(name))[1]
        and (t.driver_id = auth.uid() or private.can_operate(t.carrier_org_id))
    )
  );

create policy "Leo documentos de mis viajes" on storage.objects for select to authenticated
  using (
    bucket_id = 'trip-documents'
    and (storage.foldername(name))[1] ~ '^[0-9a-f-]{36}$'
    and private.can_see_trip(((storage.foldername(name))[1])::uuid)
  );

-- Tiempo real: el tablero y la app del generador escuchan cambios de viajes, eventos y GPS (respeta RLS).
alter publication supabase_realtime add table public.trips, public.trip_events, public.positions, public.offers;
