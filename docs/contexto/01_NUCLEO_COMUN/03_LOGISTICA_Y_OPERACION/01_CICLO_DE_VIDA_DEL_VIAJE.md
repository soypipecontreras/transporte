# Ciclo de vida del viaje (estados)

Esta es la máquina de estados oficial del **Viaje**. El desarrollador debe implementarla tal cual: cada transición tiene responsable, condición y evento registrado.

```
BORRADOR → PUBLICADA → EN_OFERTAS → ASIGNADA → DOCUMENTADA (manifiesto) → EN_CAMINO_A_CARGUE
→ EN_CARGUE → EN_TRANSITO → EN_DESCARGUE → ENTREGADA → CUMPLIDA → PAGADA_TRANSPORTISTA
→ FACTURADA → COBRADA → CERRADA
Estados laterales: CANCELADA · CON_NOVEDAD · SINIESTRO · EN_DISPUTA · SUSPENDIDA_POR_RIESGO
```

| Transición | Quién la dispara | Condición previa (validaciones) | Regla |
|---|---|---|---|
| BORRADOR → PUBLICADA | Generador | KYB aprobado; datos completos; si paga a plazo: **cupo de crédito disponible** o pago anticipado/garantía | RN-100, RN-200 |
| PUBLICADA → EN_OFERTAS | Sistema | Al llegar la primera oferta | — |
| → ASIGNADA | Generador o empresa | Vehículo y conductor válidos (RN-050), configuración compatible, valor a pagar ≥ SICE-TAC | RN-010, RN-101 |
| → DOCUMENTADA | Empresa (despachador) | Vinculación (permanente o transitoria) firmada; **manifiesto aceptado por el RNDC** | RN-001, RN-102 |
| → EN_CAMINO_A_CARGUE | Conductor | Check-list previo al viaje (vehículo, documentos, EPP) | RN-103 |
| → EN_CARGUE | Geocerca o conductor | Llegada al punto; arranca el cronómetro de horas logísticas | RN-030 |
| → EN_TRANSITO | Conductor y generador | Fotos de la carga, precinto, peso o tiquete; firma del remitente | RN-061, RN-080 |
| → EN_DESCARGUE | Geocerca | Llegada al destino | RN-030 |
| → ENTREGADA | Destinatario | Firma electrónica, fotos y novedades | RN-014 |
| → CUMPLIDA | Empresa | Cumplido aceptado por el RNDC; valor a pagar final calculado | RN-016 |
| → PAGADA_TRANSPORTISTA | Sistema / tesorería | **≤ 5 días hábiles** desde el cumplido; pago a la cuenta **del titular verificado** | RN-040, RN-041 |
| → FACTURADA | Sistema | Factura electrónica validada por la DIAN | RN-150 |
| → COBRADA | Sistema | Pago del generador conciliado (o factoring) | RN-160 |
| → CERRADA | Sistema | Calificaciones registradas, sin disputas abiertas | RN-104 |

## Eventos durante el tránsito (registro automático)

- Posición GPS cada N segundos 🔧 (sugerido: 60 s en ruta y 15 s en zonas de riesgo).
- **Desvío de ruta** de más de X km 🔧 → alerta.
- **Detención no programada** de más de X minutos 🔧 fuera de una parada autorizada → alerta.
- Pérdida de señal del GPS de más de X minutos → alerta roja (posible inhibidor).
- Apertura de puerta o precinto electrónico → alerta roja.
- Botón de pánico.
- Exceso de velocidad → reporte PESV.

## Cancelaciones (reglas mínimas, pactadas en los términos y condiciones)

| Quién cancela | Cuándo | Consecuencia 🔧 |
|---|---|---|
| Generador | Antes de ASIGNADA | Sin costo |
| Generador | Después de que el vehículo salió hacia el cargue | Se paga un **falso flete** al transportista (porcentaje o valor por km recorrido) |
| Transportista | Después de ASIGNADA | Penalidad en el score; reasignación prioritaria |
| Cualquiera | Por riesgo o fraude detectado | SUSPENDIDA_POR_RIESGO; revisión manual |
