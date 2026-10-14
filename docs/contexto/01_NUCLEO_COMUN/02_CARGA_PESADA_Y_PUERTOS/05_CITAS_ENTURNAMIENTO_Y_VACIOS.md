# Citas portuarias, enturnamiento y contenedores vacíos

## 1. Marco
- *(Actualizado en oct. 2026)* **Sí hay un marco nacional:**
  - Los puertos autorizados son **obligados del RNDC** con su **Sistema de Información para el Enturnamiento Portuario** (Res. 20213040005875 de 2021, módulo INSIDE, ratificado en la Res. 20263040016075 de 2026).
  - **Res. 20263040028845 de 2026** (⚠️ confirmar número y fecha): condiciones mínimas obligatorias para **patios de contenedores y zonas de enturnamiento** (reglamento de operación, atención 24/7).
  - Para Buenaventura: **Res. 312 de 2025** y la **Circular conjunta MT-ST del 6 de febrero de 2026** (plan semanal de vacíos; se ordenó a las navieras recoger los vacíos y frenar los cobros de mora).
- **Situación en Buenaventura (septiembre de 2026, Analdex):** después del terremoto del 10 de agosto de 2026 hay:
  - **Cierre nocturno del corredor Buga–Buenaventura (8 p. m. a 6 a. m.)**.
  - Un carril en Cajamarca.
  - Patios congestionados, pocas citas y sobrecostos por mora y *stand-by*.
  - 🔧 Parámetro `corredor.restricciones_horarias` para que la app programe los viajes dentro de las ventanas permitidas.
- Cada terminal mantiene su propio sistema de citas, y la **Supertransporte** vigila y da órdenes puntuales. Ejemplos:
  - **Puerto Tolú (2024):** se le ordenó corregir enturnamientos, cargues y agendamiento de citas, con posibles sanciones de hasta 500 SMMLV.
  - **Puerto Aguadulce:** se le ordenó un punto de control que distinga vehículos con y sin cita y reporte a los que llegan sin cita.
- **Resolución 341 de 2022** (Supertransporte, crisis de contenedores en Buenaventura):
  - A los puertos: informar a diario su ocupación a las navieras.
  - A las navieras: justificar los cobros por demora del vacío.
  - A los patios: garantizar la operación.
- 2026: la Supertransporte ordenó evaluar la **redistribución de flotas de vacíos** (Res. 1059 de 2026). Hay un borrador de resolución sobre la trazabilidad de la higienización de contenedores vacíos. ⚠️ Verificar el estado.

## 2. Funcionalidad de citas (módulo "Puerto")

| Función | Descripción | Regla |
|---|---|---|
| Catálogo de terminales y patios | Geocercas, horarios, sistema de citas, requisitos, capacidad | 🔧 |
| Reserva de cita | Por **API** de la terminal si existe; si no, registro manual con soporte (captura o número) | RN-070 |
| **Enturnamiento virtual** | El conductor espera en un **parqueadero aliado** cercano (no en la vía) y la app lo llama cuando faltan X minutos | RN-071 |
| Llegada sin cita | La app no despacha hacia el puerto sin cita confirmada (salvo excepción autorizada) | RN-072 |
| Medición de tiempos | Llegada, ingreso, cargue y salida por geocerca → horas logísticas | RN-030 |
| Evidencia de incumplimiento de la terminal | Si la terminal no atiende la cita, se genera un **reporte con evidencia** (hora, ubicación, fotos) para reclamo o queja ante la Supertransporte | RN-073 |
| Estadísticas públicas | Tiempo promedio por terminal, cumplimiento de citas | Transparencia |

## 3. Contenedores vacíos

| Problema | Funcionalidad |
|---|---|
| Plazo de días libres que vence | Contador por contenedor y alertas a 3, 2 y 1 días 🔧 (RN-074) |
| El patio no recibe (lleno) | Registro del intento de devolución con evidencia → soporte para disputar el *detention* (RN-075) |
| Daños atribuidos al transportista | Comparación de las fotos del EIR de salida contra el de entrada (RN-076) |
| Retorno vacío sin pago | El tramo de devolución siempre tiene valor (RN-063) |
| Reutilización | Emparejamiento importación → exportación (RN-064) |

## 4. Integraciones a buscar con las terminales (hoja de ruta)

1. **Fase 1:** carga manual de citas y documentos, sin integración.
2. **Fase 2:** convenios de API con las terminales principales (Buenaventura y Cartagena primero).
3. **Fase 3:** intercambio EDI (mensajes estándar de contenedores, por ejemplo CODECO para movimientos de entrada y salida y COARRI para cargue y descargue) con terminales y navieras.
