# Transporte

Plataforma de transporte de carga pesada en Colombia, con tres apps sobre el mismo backend:

- **App camionero** (Expo): registro, ofertas, viaje, GPS, fotos y pagos.
- **App empresas** (Next.js): el generador de carga pide cargas y sigue sus camiones.
- **SaaS de monitoreo** (Next.js): la transportadora aprueba camioneros, publica, monitorea y paga.

El backend es Supabase. El contrato para el front está en [`docs/contrato-front.md`](docs/contrato-front.md).

## Comandos

```bash
pnpm install
pnpm check                  # tipos + pruebas del esquema (Postgres embebido, sin Docker)
supabase start              # Supabase local completo (requiere Docker): API, Auth, Storage, Realtime
supabase db reset           # aplica migraciones y semilla en el Supabase local
supabase gen types typescript --local > types/database.ts   # tipos para el front
```

## Estructura

| Ruta | Qué es |
|---|---|
| `supabase/migrations` | Esquema, permisos (RLS) y funciones de negocio (RPC). Es la fuente de verdad |
| `supabase/seed.sql` | Datos demo y usuarios de prueba |
| `packages/db` | Pruebas del esquema con PGlite: flujo completo, permisos y cálculos |
| `docs/contrato-front.md` | Cómo conectarse, qué leer, qué RPC llamar, estados, errores y archivos |
| `apps/mockups` | Mockups navegables de las tres apps. Se publican solos en https://transporte-mockups.vercel.app con cada push a `main` |
