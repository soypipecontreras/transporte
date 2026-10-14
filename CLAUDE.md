# Transporte: plataforma de carga pesada en Colombia

App de camioneros + app de empresas (generadores) + SaaS de monitoreo para la transportadora, sobre un solo backend Supabase. El usuario hace el back; su socio hace el front (Expo + Next.js) siguiendo `docs/contrato-front.md`.

Contexto legal y operativo del negocio (RNDC, SICE-TAC, Decreto 1017 de 2025): Claude Doc "App de transporte de carga pesada en Colombia: marco legal, logístico y operativo". El tema legal y financiero queda para el final; ahora se construye producto.

Especificación de la app y contexto del negocio: `docs/contexto/` (empezar por su `README.md` y por `05_ESPECIFICACION_APP/`).

## Comandos

```bash
pnpm check        # typecheck + pruebas (PGlite, sin Docker): correr antes de dar algo por terminado
```

## Reglas

1. Las migraciones son la fuente de verdad. Nunca edites una migración ya aplicada en la nube: crea otra.
2. Lecturas por tablas con RLS; escrituras de negocio solo por RPC (`security definer`, `set search_path = ''`), que validan quién llama y el estado. Sin insert/update directos desde el front.
3. Errores de RPC con `private.fail('codigo', 'texto en español')`. Si agregas un código, documéntalo en `docs/contrato-front.md`.
4. Privacidad del dinero: el camionero nunca ve el flete (`load_pricing`); el generador nunca ve el valor a pagar (`offers`, `payments`).
5. Dinero en COP enteros (`bigint`, sufijo `_cop`). Fechas de negocio en `America/Bogota` (`private.today_co`).
6. El valor a pagar nunca baja del SICE-TAC (check en `offers`). Recargo de horas logísticas: 2 SMLDV (rígido) o 3 SMLDV (articulado) por hora o fracción sobre 8. Pago al camionero: 5 días hábiles tras el cumplido.
7. Cada diciembre: migración nueva con el salario mínimo y los festivos del año siguiente.
8. Toda RPC o política nueva lleva prueba en `packages/db/test` (flujo y aislamiento).
9. Migraciones que usan Storage o Realtime empiezan con `-- pglite:skip` (no corren en las pruebas).

## Convenciones

Identificadores en inglés; textos, documentación y commits en español (es-CO). Commits pequeños en imperativo.
