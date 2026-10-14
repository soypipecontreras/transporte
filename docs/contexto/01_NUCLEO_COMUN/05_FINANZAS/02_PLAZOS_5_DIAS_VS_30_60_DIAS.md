# El problema de los plazos: 5 días hábiles contra 30 o 60 días

## 1. Lo que dice la norma
| Relación | Plazo legal | Fuente |
|---|---|---|
| Generador → empresa (flete) | 5 días hábiles desde el recibo de la mercancía, **salvo pacto en contrario** | Decreto 1017 de 2025, art. 14 |
| Empresa → propietario (valor a pagar) | **Máximo 5 días hábiles** desde el día siguiente al cumplido | Decreto 1017 de 2025, art. 10 |
| Cargue, descargue y espera → propietario | Mismo término, **haya o no pagado el generador** | Decreto 1017 de 2025, art. 14 |
| Pago entre empresas (general) | Máximo **45 días calendario** desde la recepción del servicio, **excepto entre grandes empresas** | Ley 2024 de 2020 |

**Conclusión:** sí se puede dar crédito de 30 días a un generador. A 60 días solo si **ambos son grandes empresas** (o según las excepciones de la Ley 2024 ⚠️ validar con un abogado). **Pero el camionero cobra a los 5 días hábiles de todos modos.** Quien da el plazo debe financiarlo.

## 2. Tabla de plazos permitidos en la app (🔧 parámetros)

| Tamaño del generador (según la clasificación legal: Decreto 957 de 2019, por ingresos) | Tamaño de la empresa habilitada | Plazo máximo configurable |
|---|---|---|
| Cualquiera | Cualquiera | Contado / 5 días hábiles |
| Micro, pequeña o mediana | Cualquiera | Hasta 45 días calendario (Ley 2024) |
| Grande | Grande | Hasta 60 días o más, por pacto (excepción de la Ley 2024) |
| Grande | Micro, pequeña o mediana | ⚠️ Máximo 45 días (la ley protege al proveedor pequeño) |

RN-201: la app **impide** configurar un plazo superior al permitido según el tamaño de las partes.

## 3. Cómo se financia la brecha

| Mecanismo | Quién pone el dinero | Costo para | Detalle |
|---|---|---|---|
| **A. Factoring de la factura electrónica** | Factor (fintech o banco) | La empresa (descuento) o el generador (si lo asume en el precio) | La factura aceptada en RADIAN se endosa al factor; el factor paga hoy; el generador paga al factor al vencimiento |
| **B. Confirming / pago anticipado a proveedores** | Banco del generador | El generador | Programa del banco de un generador grande |
| **C. Línea de crédito de la empresa habilitada** | Banco (con garantía del FNG ⚠️) | La empresa | Capital de trabajo para pagar a los 5 días |
| **D. Fondo propio de la plataforma o de los socios** | Capital propio (**no del público**) | — | Solo con recursos propios; máximo legal: tasa de usura |
| **E. Pronto pago con descuento** | El generador paga antes | El generador recibe un descuento | Incentivo para no usar el plazo |

La recomendación por etapas está en `06_CREDITO_Y_RIESGO/01_ESTRATEGIA_DE_CREDITO.md`.
