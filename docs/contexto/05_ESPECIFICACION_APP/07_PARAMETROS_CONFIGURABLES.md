# Parámetros configurables 🔧

Todos se guardan en la tabla `parametro` con su vigencia y su aprobación (doble aprobación). Los valores de ejemplo son **solo referencia** y deben validarse.

| Clave | Descripción | Valor de ejemplo / fuente |
|---|---|---|
| `smmlv.<año>` | Salario mínimo mensual | 2025: $1.423.500 · **2026: $1.750.905** (Decreto 1469 de 2025) |
| `smldv.<año>` | Salario mínimo diario | smmlv/30 |
| `uvt.<año>`, `uvb.<año>` | Unidades de valor | 2026: UVT $52.374 · UVB $12.110 |
| `tamano_empresa.umbral_uvt` | Decreto 957 de 2019 (servicios) | Micro ≤ 32.988 · pequeña ≤ 131.951 · mediana ≤ 483.034 · grande > 483.034 UVT |
| `festivos.<año>` | Calendario de festivos de Colombia | Ley 51 de 1983 (Ley Emiliani) |
| `pago.dias_habiles_max` | Plazo de pago al titular | 5 |
| `horas_logisticas.max` | Horas de cargue y descargue sin recargo | 8 |
| `horas_logisticas.smldv_articulado` | Recargo por hora | 3 |
| `horas_logisticas.smldv_rigido` | Recargo por hora | 2 |
| `fopat.retencion_pct` / `fopat.activo` / `fopat.pbv_min_kg` / `fopat.base` | Retención del FOPAT | 0,1 % / **verdadero desde el 01-04-2026** / 10.500 / `valor_a_pagar` (⚠️ confirmar con el contador; Res. DIAN 0008 de 2026) |
| `rndc.max_cumplidos_pendientes_pct` | Control del RNDC | 20 % de los manifiestos de los últimos 30 días |
| `retefuente.transporte_carga_pct` | Retención en la fuente | 1 % ⚠️ |
| `iva.servicios_plataforma_pct` | IVA de la comisión | 19 % |
| `reteica.<municipio>` | Tabla de ICA | Por municipio |
| `tasa_usura.<mes>` | Tasa máxima | Certificación de la SFC · oct. 2026: 28,59 % E.A. |
| `plazo_max.<tamano_gen>.<tamano_emp>` | Plazos de la Ley 2024 | 45 días / excepción entre grandes |
| `anticipo.max_pct` | Máximo de anticipo | 50 % (política) |
| `cuenta.espera_cambio_horas` | Espera tras el cambio de cuenta | 48 |
| `gps.intervalo_s` / `gps.intervalo_riesgo_s` | Frecuencia | 60 / 15 |
| `alerta.desvio_km` / `alerta.detencion_min` / `alerta.sin_senal_min` | Umbrales de seguridad | 2 km / 30 min / 10 min |
| `fatiga.continua_h` / `fatiga.diaria_h` | Fatiga | 4 / 10 ⚠️ |
| `credito.antiguedad_min_meses` | KYB | 12 |
| `credito.crecimiento_cupo_max_pct` | Escalera | 50 % |
| `credito.pesos_scoring` | Ponderaciones | Ver 01/06/03 |
| `cobranza.horarios` / `cobranza.frecuencia` | Ley 2300 | ⚠️ |
| `contenedor.alerta_dias_libres` | Alertas | [3, 2, 1] |
| `exportacion.margen_cutoff_h` | Margen | 6 |
| `merma.<producto>_pct` | Tolerancia | Por contrato |
| `pbv.<configuracion>` | Peso máximo | Res. 4100/2004 ⚠️ |
| `trm` | Tasa de cambio | Diaria (Banco de la República) |
