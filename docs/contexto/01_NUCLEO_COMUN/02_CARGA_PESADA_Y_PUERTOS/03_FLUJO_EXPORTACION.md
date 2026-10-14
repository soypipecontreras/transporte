# Flujo: exportación (interior → puerto)

| # | Paso | Responsable | Qué hace la app | Documento o evidencia |
|---|---|---|---|---|
| 1 | Reserva (*booking*) con la naviera | Exportador / agente de carga | El generador registra el booking, la naviera, la motonave, el *cut-off* (cierre de recibo) y la terminal | Booking |
| 2 | Retiro del contenedor vacío en el patio indicado | Transportista | Cita en el patio; inspección del vacío (limpio, sin daños, apto para la carga) | EIR del vacío, fotos |
| 3 | Llenado en la planta del exportador | Generador | Horas logísticas de cargue; **fotos del llenado**; colocación del **precinto** con número | Lista de empaque, precinto |
| 4 | Documentos de exportación | Agencia de aduanas | Carga de la Solicitud de Autorización de Embarque (SAE) / Declaración de Exportación (DEX) ⚠️ verificar la nomenclatura vigente de la DIAN | SAE |
| 5 | Manifiesto | Empresa | RNDC | Manifiesto |
| 6 | Tránsito al puerto | Conductor | GPS; **alerta de cut-off**: calcula el ETA contra el cierre de recibo | — |
| 7 | Cita de ingreso a la terminal | Empresa | Gestión de la cita; enturnamiento | Cita |
| 8 | Inspecciones (antinarcóticos, DIAN, ICA) | Autoridades | Registro de la inspección y nuevo precinto si se abre | Acta, nuevo precinto |
| 9 | Entrega en la terminal | Conductor | EIR de entrada | EIR |
| 10 | Cumplido y pago | Empresa | Pago en 5 días hábiles | — |

## Reglas
- **RN-065:** si el ETA calculado es posterior al *cut-off* menos un margen 🔧 → alerta al generador y a la empresa.
- **RN-066:** la cadena de custodia del precinto (número en el llenado → número en el puerto) queda registrada. Cualquier cambio exige un acta o una foto de la autoridad.
- **RN-067:** el retorno se ofrece automáticamente: carga de importación desde el mismo puerto (viaje redondo).
