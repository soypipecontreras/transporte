# Flujo del dinero

## 1. Conceptos y quién recibe qué

```
GENERADOR paga FLETE + servicios adicionales
   │
   ▼
EMPRESA HABILITADA (factura el flete; transporte de carga excluido de IVA)
   ├─► PROPIETARIO: VALOR A PAGAR (≥ SICE-TAC) − anticipo − retención en la fuente − descuentos permitidos
   │                + horas logísticas adicionales + cargue/descargue si los asumió
   ├─► FOPAT 0,1 % (vigente desde el 01-04-2026; base: valor a pagar ⚠️ confirmar; PBV > 10,5 t)
   ├─► Margen propio
   └─► PLATAFORMA: comisión / licencia (factura aparte con IVA 19 %)
```

## 2. Recaudo: cuenta de pagos controlada

**Recomendación:** que el dinero del viaje no pase por cuentas operativas libres. Opciones:

| Opción | Descripción | Ventaja | ⚠️ |
|---|---|---|---|
| **Cuenta recaudadora de la empresa habilitada** con reglas automáticas (dispersión programada) | El banco dispersa al propietario según las instrucciones de la app | Simple | La plataforma no controla los fondos |
| **Encargo fiduciario o patrimonio autónomo** (fiducia de administración y pagos) | El generador paga a la fiducia, que paga al propietario, a la empresa y a la plataforma según las instrucciones | **Máxima confianza:** el dinero del camionero queda protegido aunque la empresa quiebre | Costo; requiere contrato con una fiduciaria vigilada |
| **Pasarela / proveedor de pagos** con cuentas segregadas | Para pagos menores y anticipos | Rapidez | Revisar que el proveedor sea vigilado o esté bajo la regulación aplicable |

> La plataforma **no debe** tener el dinero de terceros en sus propias cuentas sin una figura regulada, para no exponerse a la captación o a la custodia no autorizada.

## 3. Medios de pago
- Transferencias inmediatas (sistema de pagos inmediatos del Banco de la República, **Bre-B** ⚠️ verificar la cobertura) y ACH tradicional.
- PSE para el recaudo de generadores.
- Billeteras para conductores sin cuenta bancaria tradicional (siempre a nombre del titular).

## 4. Reglas
- **RN-040:** el pago al propietario se programa automáticamente para `fecha_cumplido + 5 días hábiles` (o antes). **No depende de que el generador haya pagado.**
- **RN-042:** el anticipo sale del valor a pagar, queda registrado en el manifiesto y su máximo se define por política 🔧 (por ejemplo, 50 %).
- **RN-043:** solo se permiten los descuentos de la lista: retención en la fuente, anticipo, ICA si aplica y otros autorizados por norma o por el contrato de vinculación firmado. Todo lo demás está prohibido. El catálogo de descuentos es cerrado y lo administra cumplimiento.
- **RN-044:** si se paga tarde, se calcula automáticamente el **interés de mora a la tasa máxima legal** (C. Co. art. 884) y se paga junto con el capital.
- **RN-045:** extracto discriminado por viaje y mensual para cada propietario (Decreto 1017 de 2025, art. 6).
