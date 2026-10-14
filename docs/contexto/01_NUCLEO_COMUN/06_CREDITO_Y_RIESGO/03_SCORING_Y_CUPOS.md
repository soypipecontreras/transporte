# Scoring y cupos

## 1. Modelo de puntaje inicial (reglas, antes de tener datos para modelos estadísticos)

Puntaje de 0 a 1.000. **Todas las ponderaciones son 🔧 parámetros** que el comité de riesgo calibra.

| Variable | Peso | Cómo se puntúa |
|---|---|---|
| Antigüedad de la empresa | 10 % | Menos de 1 año = 0; 1-3 años = medio; más de 5 años = máximo |
| Score de centrales de riesgo | 25 % | Escalado del score del buró |
| Indicadores financieros (liquidez, endeudamiento, rentabilidad, ventas) | 20 % | Razones contra benchmarks del sector |
| Comportamiento de pago externo (RADIAN, referencias) | 10 % | Días de pago promedio a proveedores |
| **Comportamiento interno** (días reales de pago en la app, disputas) | 20 % | Comienza neutro; sube o baja con el historial |
| Sector y tipo de mercancía | 5 % | Riesgo sectorial |
| Concentración / tamaño relativo del cupo solicitado | 5 % | Cupo / ventas mensuales |
| Calidad del KYB (verificaciones completas, visita) | 5 % | Completo = máximo |

**Rechazo automático (knock-outs):** listas vinculantes, insolvencia, matrícula no renovada, falla de identidad, fraude interno previo, mora mayor a 90 días en centrales (⚠️ ajustar por política).

## 2. Tabla de decisión

| Puntaje | Decisión | Cupo máximo | Plazo máximo |
|---|---|---|---|
| < 400 | Solo contado | 0 | — |
| 400–549 | Cupo de prueba | Bajo 🔧 (por ejemplo, 1 viaje) | 15 días |
| 550–699 | Cupo estándar | min(X, 10 % de las ventas mensuales) | 30 días |
| 700–849 | Cupo alto | min(Y, 15 % de las ventas mensuales) | 45 días |
| ≥ 850 y gran empresa | Cupo premium | Comité | Hasta 60 días si ambas partes son grandes (Ley 2024) |

## 3. Escalera de cupo (para nuevos clientes)
1. Mes 1: contado o cupo de prueba.
2. Después de N viajes pagados a tiempo 🔧 → sube un nivel.
3. Máximo un **aumento del 50 % por mes** 🔧.
4. **Cupo cubierto:** el cupo otorgado nunca supera lo que cubren el seguro de crédito y la capacidad del factoring.

## 4. Revisión y monitoreo
- Revisión automática **mensual** y completa **anual** (o con nuevos estados financieros).
- **Disparadores de congelamiento inmediato:**
  - Mora mayor a 5 días 🔧.
  - Reporte negativo nuevo en centrales.
  - Proceso de insolvencia.
  - Cambio de representante legal.
  - Alerta de lista.
  - Patrón bust-out.

## 5. Score del transportista (para crédito y priorización)
- **Variables:**
  - Viajes cumplidos.
  - Puntualidad.
  - Novedades.
  - Calificaciones.
  - Antigüedad.
  - Documentos al día.
  - Siniestralidad.
  - Comportamiento de pago de los anticipos.
- **Uso:**
  - Prioridad en la asignación.
  - Monto del anticipo.
  - Acceso a la financiación de llantas, combustible, repuestos o del vehículo, a través de aliados.

## 6. Gobierno del modelo
- Documentar cada versión del modelo, sus variables y los resultados (backtesting).
- **No usar variables discriminatorias** (sexo, etnia, religión, etc.).
- Explicabilidad: al rechazar, informar las razones generales (Ley 1266 y buenas prácticas).
