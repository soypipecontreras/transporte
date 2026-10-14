# Advertencias y puntos pendientes de verificar

Estos puntos deben revisarse con un abogado o contador **antes de programarlos como reglas fijas**. Todos deben quedar como 🔧 parámetros en la app.

## A. Riesgos legales del concepto "sin intermediarios"

1. **La plataforma no puede actuar como empresa de transporte sin habilitación.** Si la app fija precios, asigna vehículos y responde por la carga sin ser empresa habilitada, puede considerarse que presta el servicio sin autorización (Ley 336 de 1996, arts. 9 y 46 en adelante: sanciones de la Supertransporte). Por eso:
   - En el **Modelo A** (venta de la app), la app es una herramienta tecnológica de la empresa habilitada.
   - En el **Modelo B** (socio), la empresa habilitada es la operadora y la app es su canal.
2. **El Ministerio de Transporte ha dicho que no "autoriza" plataformas tecnológicas.** Las empresas habilitadas pueden usar tecnología, pero solo para el servicio que tienen autorizado. ⚠️ Verificar si en 2026 avanzó regulación de plataformas que alcance a la carga. El Proyecto de Ley 347 de 2026 trata de pasajeros. Fuente en `07_FUENTES`.
3. **Captación ilegal de dinero.** La plataforma **no** puede recibir dinero del público para prestarlo (Decreto 1981 de 1988, Código Penal art. 316). El crédito se hace con capital propio limitado o con aliados vigilados por la Superintendencia Financiera.

## B. Decreto 1017 de 2025 (vigente desde septiembre de 2025)

| Punto | Estado |
|---|---|
| Pago del flete del generador a la empresa en 5 días hábiles **"salvo pacto en contrario"** | ✅ texto del decreto. Permite pactar 30 o 60 días con el generador. |
| Pago de la empresa al propietario en máximo 5 días hábiles después del cumplido | ✅ texto del decreto (art. 10, numerales del manifiesto). ⚠️ Confirmar con un abogado si el "pacto en contrario" puede extender este plazo. Este documento asume que **NO**. |
| Valor a pagar ≥ SICE-TAC, con bloqueo en el RNDC | ✅ |
| Horas logísticas: máximo 8 h; exceso a 3 SMLDV/h (articulado) o 2 SMLDV/h (rígido) | ✅ (art. 15) |
| Retención del 0,1 % para el FOPAT | ✅ **Vigente desde el 1 de abril de 2026** (Ley 2251 de 2022, art. 21; Res. DIAN 0008 de 2026). Aplica a vehículos con PBV > 10,5 t; base: el valor a pagar; F490 concepto 81. *(Actualizado en oct. 2026)* |
| Demanda de Fenalco ante el Consejo de Estado | Solo contra los **arts. 17 y 18** (registro inicial de vehículos y aporte al FOPAT del 15 % al 25 %). **No** afecta el pago a 5 días, el SICE-TAC ni la retención. Sin decisión conocida a oct. 2026 |
| Capital mínimo de 1.000 SMMLV; empresas de propietarios con 250 SMMLV | ✅ (art. 4) |
| Reglamentaciones del decreto | ✅ RNDC: Res. 20263040016075 de 2026. 🟡 Vehículos de 3,5 a 10,5 t: Res. 20263040015655 de 2026 (verificar). 🟡 Patios y enturnamiento: Res. 20263040028845 de 2026 (verificar) |

## C. RNDC

*(Actualizado en oct. 2026)*
- ✅ **Resolución 20263040016075 del 29 de abril de 2026**: unifica toda la normativa del RNDC e incluye su manual técnico. La copia está en `07_FUENTES/DOCUMENTOS_OFICIALES`. El detalle está en `07_FUENTES/02_ACTUALIZACION_INVESTIGACION_OCT_2026.md`.
- Novedades clave:
  - Bloqueo de nuevos manifiestos si los cumplidos pendientes superan el 20 %.
  - Reporte obligatorio de los tiempos reales por monitoreo de flota (desde el 30 de noviembre de 2025).
  - El generador debe aceptar la factura en el RNDC.
  - Rol de "Empresa de Monitoreo de Flota", que la plataforma puede ocupar.
- **"RNDC 360":** la ministra lo anunció el 2 de octubre de 2026 (Congreso de Colfecar) para el **1 de enero de 2027**, con gestión móvil, IA y operación 24/7. **Todavía no hay una resolución.** Se mantiene el adaptador intercambiable y el modo de contingencia, porque el RNDC tuvo 36 días de fallas entre enero y septiembre de 2026.

## D. Finanzas e impuestos

- El transporte nacional de carga está **excluido de IVA** (Estatuto Tributario, art. 476). La **comisión de la plataforma sí causa IVA** del 19 %.
- La retención en la fuente por transporte de carga es del 1 % y la retención de ICA depende del municipio. 🔧 Parametrizar ambas.
- Ley 2024 de 2020 (pago en plazos justos): plazo máximo de 45 días calendario entre empresas, **excepto entre grandes empresas**. Esto limita los plazos de 60 días con generadores que no sean grandes.

## E. Otros

- Los tiempos máximos de conducción para conductores de carga no se confirmaron en una norma oficial. Una fuente no oficial cita la Res. 315 de 2013. La **Circular conjunta Mintransporte–Mintrabajo de marzo de 2026** exige respetar la jornada y los descansos del Código Sustantivo del Trabajo. La app usa umbrales configurables de fatiga dentro del PESV.
- La Resolución 4100 de 2004 sobre pesos y dimensiones tiene modificaciones parciales. ⚠️ Verificar el texto consolidado.
- SARLAFT de la Supertransporte: Resolución 4607 del 9 de abril de 2026. ⚠️ Confirmar si alcanza a todas las empresas de carga y los umbrales en UVB.
- Valores de 2026: SMMLV $1.750.905 · UVT $52.374 · UVB $12.110 · tasa de usura de octubre de 2026: 28,59 % E.A. 🔧 Actualizar cada año o mes.
