# Mapa de actores y flujo general

## 1. Actores

```
                 ┌──────────────────────────┐
                 │  GENERADOR DE CARGA      │  (empresa que necesita mover mercancía)
                 │  App Generador           │
                 └────────────┬─────────────┘
          contrato de         │  flete (paga en 5 días hábiles,
          transporte          │  salvo pacto en contrario: 30/60 días)
                 ┌────────────▼─────────────┐
                 │  EMPRESA HABILITADA      │  ← expide manifiesto en RNDC
                 │  Panel Empresa           │  ← responde ante Supertransporte
                 └────────────┬─────────────┘
          vinculación         │  valor a pagar (≥ SICE-TAC,
          (permanente o       │  máx. 5 días hábiles después del cumplido)
          transitoria)        │
                 ┌────────────▼─────────────┐
                 │  PROPIETARIO (titular)   │──── CONDUCTOR (puede ser la misma persona)
                 │  App Transportista       │
                 └────────────┬─────────────┘
                              │ entrega
                 ┌────────────▼─────────────┐
                 │  DESTINATARIO / CLIENTE  │  App Cliente (seguimiento, recepción, firma)
                 └──────────────────────────┘

 ALIADOS: puertos y terminales · navieras · DIAN · aseguradoras · bancos/fintech/factoring
          · proveedores GPS · centrales de riesgo · proveedor de facturación electrónica
 PLATAFORMA (dueños de la app): tecnología, reglas, pagos, scoring, antifraude
```

## 2. Las cinco aplicaciones o interfaces

| Interfaz | Usuario | Para qué sirve |
|---|---|---|
| **App Generador** (web y móvil) | Empresas que mueven carga | Publicar cargas, ver ofertas, seguir viajes, pagar, pedir crédito |
| **App Transportista** (móvil) | Propietario y conductor | Ver cargas, ofertar o aceptar, documentos, GPS, cumplido, cobrar, anticipos |
| **App Cliente** (web y móvil, liviana) | Destinatario | Ver el ETA, recibir, firmar la entrega, reportar novedades |
| **Panel Empresa Habilitada** (web) | Despachadores y gerencia | Vincular vehículos, expedir manifiestos, pagar, cumplimiento normativo |
| **Panel Plataforma / Admin** (web) | Equipo de la plataforma | Aprobar usuarios, antifraude, crédito, parámetros, soporte |

## 3. Flujo resumido de un viaje (nacional)

1. **Registro y validación (KYC/KYB)** de todos los actores (ver `01_NUCLEO_COMUN/04_ACTORES_Y_VINCULACION`).
2. El **generador publica la carga**: origen, destino, tipo, peso, fechas, requisitos y flete ofrecido.
3. La app **calcula el SICE-TAC** de la ruta y **bloquea** fletes cuyo valor a pagar quede por debajo (RN-010).
4. **Transportistas habilitados ofertan o aceptan.** El generador o la empresa asignan.
5. La **empresa habilitada** vincula el vehículo (transitoria o permanente) y **expide el manifiesto en el RNDC** (por integración).
6. **Anticipo** opcional al transportista.
7. **Cargue** con control de horas logísticas (RN-030).
8. **Viaje** con GPS y eventos, y alertas de desvío o detención.
9. **Descargue y entrega**: firma del destinatario, fotos, novedades.
10. **Cumplido en el RNDC**, que calcula el valor a pagar final.
11. **Pago al propietario en máximo 5 días hábiles** (RN-040), con o sin que el generador haya pagado.
12. **Factura electrónica** al generador y **cobro** a 5 días o al plazo pactado. Si es a plazo, el **crédito o factoring** cubre la diferencia.
13. **Calificación** mutua y actualización de los scores.

El detalle de cada paso está en `01_NUCLEO_COMUN/03_LOGISTICA_Y_OPERACION/01_CICLO_DE_VIDA_DEL_VIAJE.md`. Los flujos de puerto e internacional se describen en sus carpetas.

## 4. El problema financiero central (por qué existe el módulo de crédito)

```
Día 0: cargue → Día 2: entrega/cumplido → Día 9 (≈5 hábiles): EMPRESA DEBE PAGAR AL CAMIONERO
                                             ↑ obligación legal (Decreto 1017 de 2025)
Día 30 / 60: GENERADOR PAGA A LA EMPRESA (si pactaron plazo)
             ═══════════════════════════════
             BRECHA DE 21 A 51 DÍAS QUE ALGUIEN DEBE FINANCIAR
```

La app resuelve esta brecha así (ver `01_NUCLEO_COMUN/06_CREDITO_Y_RIESGO`):
- **Cupo de crédito** al generador, solo si pasa los filtros antifraude y el scoring.
- **Factoring** de la factura electrónica aceptada en RADIAN.
- **Aliados financieros** vigilados que pongan el capital. La plataforma no capta dinero del público.
