# Contrato back ↔ front

Este documento es lo que el front necesita para conectarse al backend. El back es Supabase (Postgres + Auth + Storage + Realtime). El front usa `@supabase/supabase-js`: **lee tablas** (la seguridad la pone RLS) y **escribe solo con RPC** (`supabase.rpc(...)`). No hay `insert`/`update` directos sobre tablas de negocio; la base los rechaza.

Las tres apps usan el mismo backend:

| App | Quién la usa | Stack del front | Cómo entra |
|---|---|---|---|
| App camionero | Conductor independiente (y titular del camión) | Expo (React Native), Android primero | Por ahora correo + contraseña; después celular + código |
| App empresas | Generador de carga (cliente) | Next.js | Correo + contraseña |
| SaaS de monitoreo | Operaciones de la transportadora | Next.js | Correo + contraseña |

## 1. Conexión

```ts
import { createClient } from "@supabase/supabase-js";
export const supabase = createClient(process.env.EXPO_PUBLIC_SUPABASE_URL!, process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY!);
```

- **Local:** `supabase start` en la raíz del repo (requiere Docker). Imprime la URL (`http://127.0.0.1:54321`) y la llave `anon`. Después `supabase db reset` carga migraciones y semilla.
- **Tipos TypeScript:** `supabase gen types typescript --local > types/database.ts` y `createClient<Database>(...)`. Así cada RPC y tabla queda tipada.
- Nunca uses la llave `service_role` en el front.

Usuarios de la semilla (`supabase/seed.sql`), todos con la contraseña `demo1234`:

| Usuario | Rol |
|---|---|
| `ops@demo.co` | Dueño de la transportadora "Transportes Demo" |
| `cliente@demo.co` | Dueño del generador "Alimentos Andinos" |
| `camionero@demo.co` | Camionero aprobado (Juan Pérez, camión ABC123) |
| `camionero2@demo.co` | Camionero pendiente de aprobación (Luis Gómez) |

Por ahora todas las apps entran igual. El ingreso por celular con código queda para cuando haya proveedor de SMS o WhatsApp.

```ts
await supabase.auth.signInWithPassword({ email: "camionero@demo.co", password: "demo1234" });
```

## 2. Errores

Las RPC fallan con un mensaje `codigo: texto para la persona`. El código sirve para decidir qué hacer y el texto ya está en español para mostrarlo.

```ts
const { error } = await supabase.rpc("trip_depart", { p_trip_id });
if (error) {
  const [code, ...rest] = error.message.split(": ");
  // code === "manifest_missing" → mostrar rest.join(": ")
}
```

| Código | Significa |
|---|---|
| `auth` | No hay sesión |
| `forbidden` | No tiene permiso sobre ese registro |
| `not_found` | No existe (o no lo puede ver) |
| `invalid` | Dato inválido (el texto dice cuál) |
| `invalid_state` | El registro no está en el estado que permite esa acción |
| `conflict` | Ya existe (por ejemplo, una placa registrada por otra persona) |
| `not_approved` | La transportadora no ha aprobado al conductor o al vehículo |
| `offer_closed` | La oferta ya la tomó otro o venció |
| `vehicle_mismatch` | El vehículo no sirve para esa carga (configuración, carrocería o peso) |
| `license_mismatch` | La licencia no corresponde al vehículo (C2 rígido, C3 articulado) |
| `expired` | Licencia, SOAT o revisión técnico-mecánica vencen antes del viaje |
| `busy` | El conductor o el vehículo ya tienen un viaje en curso |
| `outside_geofence` | El celular no está dentro de la geocerca de la sede |
| `manifest_missing` | No se puede salir del cargue sin manifiesto |
| `proof_missing` | No se puede entregar sin foto o soporte firmado |
| `freight_missing` | No se puede publicar sin flete pactado con el generador |
| `sicetac_missing` / `below_sicetac` | Falta el SICE-TAC o el valor a pagar queda por debajo |

## 3. Estados

**Carga (`loads.status`)**

```
requested ──publicar──▶ published ──camionero toma──▶ assigned ──sale cargado──▶ in_transit ──entrega──▶ delivered ──cumplido──▶ closed
    ▲                        │ retirar oferta                │ cancelar viaje
    └────────────────────────┴───────────────────────────────┘
cancelled: se puede cancelar mientras esté en requested, published o assigned.
```

**Viaje (`trips.status`)**

```
assigned ─trip_start─▶ to_pickup ─trip_arrive─▶ at_pickup ─trip_depart─▶ in_transit ─trip_arrive─▶ at_delivery ─trip_deliver─▶ delivered ─trip_settle─▶ settled
   └──────────── trip_cancel (operaciones) / load_cancel ─────────────▶ cancelled   (solo antes de salir del cargue)
```

- En `at_pickup` y `at_delivery` corre el reloj de horas logísticas: máximo 8 horas en cada sitio; desde la novena hay recargo.
- `trip_depart` exige el número de manifiesto (lo registra operaciones con `trip_set_documents`).
- `trip_deliver` exige una foto `delivery_photo` o `signed_delivery`.
- El GPS (`trip_ping`) solo se acepta en `to_pickup`, `at_pickup`, `in_transit` y `at_delivery`: fuera de esos estados la app debe apagar el seguimiento.

## 4. Quién ve el dinero

| Dato | Dónde vive | Transportadora | Generador | Camionero |
|---|---|---|---|---|
| Flete (lo que paga el generador) | `load_pricing.freight_cop` | Sí | Sí | **No** |
| Valor a pagar y anticipo | `offers.pay_cop`, `offers.advance_cop` | Sí | **No** | Sí |
| Pago, recargos y vencimiento | `payments` | Sí | **No** | Sí |

Todo el dinero va en pesos enteros (`bigint`, sufijo `_cop`). Las fechas son `timestamptz` (ISO 8601); muéstralas en hora de Colombia.

## 5. App camionero

| Pantalla | Lee | Escribe (RPC) |
|---|---|---|
| Registro | `drivers` (el mío), `profiles` | `driver_upsert_me` |
| Titular (a quién se le paga) | `holders` | `holder_upsert` (con `p_is_me: true` si es él mismo) |
| Mi camión | `vehicles`, `vehicle_drivers` | `vehicle_upsert` |
| Documentos | `credential_documents` | subir a Storage → `credential_document_add` |
| Postularme a una transportadora | `carrier_drivers`, `carrier_vehicles` (estado de revisión) | `carrier_apply` |
| Ofertas disponibles | `driver_offer_feed(p_vehicle_id)` | `offer_take(p_offer_id, p_vehicle_id)` |
| Viaje en curso | `trips`, `trip_events`, `trip_documents`, `trip_logistics(p_trip_id)` | `trip_start`, `trip_arrive`, `trip_depart`, `trip_add_document`, `trip_deliver`, `trip_report` |
| GPS en segundo plano | — | `trip_ping(p_trip_id, p_points)` cada 1–2 minutos, en lotes |
| Mis pagos | `payments` | — |

`driver_offer_feed` devuelve solo ofertas abiertas de transportadoras que aprobaron al conductor: valor a pagar, anticipo, carga, peso, citas, origen y destino (con coordenadas), distancia en línea recta y `fits_vehicle` (si el camión sirve).

**GPS.** El celular guarda los puntos cuando no hay señal y los manda después, hasta 500 por llamada:

```ts
await supabase.rpc("trip_ping", {
  p_trip_id,
  p_points: [{ lat: 4.71, lng: -74.21, recorded_at: "2026-10-10T10:00:00-05:00", speed_kmh: 60, heading: 90, accuracy_m: 12 }],
});
```

**Llegadas.** `trip_arrive(p_trip_id, p_lat, p_lng)` sirve tanto para el cargue como para el descargue (lo decide el estado). Si el conductor está a más metros que `sites.geofence_m`, responde `outside_geofence` con la distancia.

## 6. App empresas (generador)

| Pantalla | Lee | Escribe (RPC) |
|---|---|---|
| Crear mi empresa | `organizations`, `memberships` | `organization_create(p_kind: 'shipper', ...)` |
| Equipo | `memberships` | `organization_add_member` |
| Sedes | `sites` | `site_upsert` |
| Pedir carga | `carrier_clients` (con qué transportadora trabaja) | `load_create` (sin `p_freight_cop`) |
| Mis cargas | `loads`, `load_pricing` | `load_cancel` |
| Seguimiento | `trip_board(p_org_id)`, `positions`, `trip_events`, `trip_documents`, `trip_logistics` | — |

## 7. SaaS de monitoreo (transportadora)

| Pantalla | Lee | Escribe (RPC) |
|---|---|---|
| Clientes | `carrier_clients`, `organizations` | `carrier_add_client(p_carrier_org_id, p_shipper_nit)` |
| Revisión de conductores y vehículos | `carrier_drivers`, `carrier_vehicles`, `drivers`, `vehicles`, `holders`, `credential_documents` | `carrier_review_driver`, `carrier_review_vehicle` |
| Cargas | `loads`, `load_pricing`, `offers` | `load_create`, `load_set_freight`, `load_publish`, `offer_withdraw`, `load_cancel` |
| Tablero en vivo | `trip_board(p_org_id)` + Realtime | `trip_set_documents`, `trip_report`, `trip_arrive(p_force: true)`, `trip_cancel` |
| Cumplidos y pagos | `payments` | `trip_settle`, `payment_mark_paid` |
| Indicadores | `carrier_compliance(p_carrier_org_id)` | — |

`trip_board` devuelve una fila por viaje, con las alertas primero:

| Alerta | Cuándo |
|---|---|
| `late_to_pickup` | No ha llegado al cargue y ya pasó la cita |
| `no_signal` | En ruta y sin GPS hace más de 30 minutos |
| `manifest_missing` | Está en el cargue y no hay manifiesto |
| `pickup_6h` / `pickup_8h` | Lleva 6 / 8 horas en el cargue |
| `delivery_6h` / `delivery_8h` | Lleva 6 / 8 horas en el descargue |
| `late_delivery` | En tránsito y ya pasó la cita de descargue |
| `settlement_pending` | Entregado hace más de 24 horas sin cumplido |

`carrier_compliance` devuelve los manifiestos de los últimos 30 días, cuántos siguen sin cumplir, la proporción y un `level` (`ok`, `warning` desde 15 %, `blocked` desde 20 %, que es cuando el RNDC bloquea nuevos manifiestos). También devuelve los pagos vencidos y los que vencen en los próximos 2 días.

**SICE-TAC.** Mientras no haya integración, operaciones consulta el valor en el sistema del Ministerio y lo escribe al publicar (`p_sicetac_floor_cop`). La base rechaza cualquier valor a pagar por debajo de ese piso.

## 8. Tiempo real

Las tablas `trips`, `trip_events`, `positions` y `offers` emiten cambios (respetan RLS: cada quien recibe solo lo que puede leer).

```ts
supabase
  .channel("tablero")
  .on("postgres_changes", { event: "*", schema: "public", table: "trips", filter: `carrier_org_id=eq.${orgId}` }, refetchBoard)
  .on("postgres_changes", { event: "INSERT", schema: "public", table: "positions", filter: `trip_id=eq.${tripId}` }, movePin)
  .subscribe();
```

## 9. Archivos (Storage)

| Bucket | Ruta | Quién sube | Después de subir |
|---|---|---|---|
| `credentials` | `<user_id>/<archivo>` | El camionero, en su carpeta | `credential_document_add` |
| `trip-documents` | `<trip_id>/<archivo>` | El conductor del viaje u operaciones | `trip_add_document` |

Formatos: JPG, PNG, WEBP o PDF, máximo 10 MB. Los buckets son privados: para mostrar un archivo usa `createSignedUrl`.

## 10. Lo que todavía no está

- Integraciones: RNDC (remesa y manifiesto por web service), SICE-TAC, RUNT/SIMIT, facturación electrónica y empresa de monitoreo GPS. Hoy operaciones registra a mano los números de remesa y manifiesto, y el SICE-TAC.
- Notificaciones (push y WhatsApp) cuando hay ofertas nuevas o alertas.
- Edición de cargas ya publicadas (hoy: retirar la oferta, ajustar y publicar de nuevo).
