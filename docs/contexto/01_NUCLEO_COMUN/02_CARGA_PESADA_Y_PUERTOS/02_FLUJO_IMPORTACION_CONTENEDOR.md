# Flujo: importación en contenedor (puerto → interior)

## Actores adicionales
- **Importador**, que es el generador.
- **Agencia de aduanas.**
- **Naviera o agente marítimo.**
- **Terminal portuaria.**
- **Autoridades:** DIAN, ICA, INVIMA y Policía Antinarcóticos (inspección simultánea).
- **Patio de contenedores**, para la devolución del vacío.

## Pasos

| # | Paso | Responsable | Qué hace la app | Documento o evidencia |
|---|---|---|---|---|
| 1 | El buque llega y la carga se descarga a la terminal | Naviera / terminal | Recibe el aviso de llegada (ETA del buque) del generador | BL, número de contenedor |
| 2 | Trámite de aduana: **nacionalización en puerto** (levante) o **DTA** hacia otra aduana o zona franca | Agencia de aduanas | El generador indica la modalidad. Si es DTA, solo transportadores **inscritos ante la DIAN** pueden tomarla (RN-060) | Declaración de importación o DTA (form. 651) |
| 3 | El generador **publica la carga** en la app | Generador | Formulario de contenedor: número, tamaño, tipo, peso, BL, naviera, terminal, días libres, destino, patio de devolución | — |
| 4 | Asignación del transportista | Generador / empresa | Solo se ofrecen vehículos con portacontenedor compatible y con los documentos del puerto al día | — |
| 5 | **Comodato o garantía** del contenedor ante la naviera | Generador o empresa (según quién la asuma) | Checklist de comodato y carga del documento | Comodato, garantía |
| 6 | **Cita en la terminal** para el retiro | Empresa / transportista | Integración con el sistema de citas o carga manual de la cita; el conductor ve la hora y los requisitos | Número de cita |
| 7 | Expedición del **manifiesto** en el RNDC | Empresa | Automático al asignar (ver `01_NORMATIVA/03_RNDC`) | Manifiesto |
| 8 | Ingreso a la terminal y retiro | Conductor | Llegada por geocerca, cronómetro de horas logísticas, **inspección del contenedor y del precinto con fotos** antes de firmar (RN-061) | **EIR de salida**, fotos, número de precinto |
| 9 | Tránsito al destino | Conductor | GPS, ruta autorizada, alertas | Trazabilidad |
| 10 | Entrega en la bodega del importador | Destinatario | Firma, fotos, verificación del precinto intacto, horas logísticas de descargue | Cumplido de remesa |
| 11 | **Devolución del contenedor vacío** al patio o puerto indicado, con cita | Conductor | Recordatorio de días libres; reserva de cita en el patio; evidencia del intento si el patio rechaza | **EIR de entrada**, cita, fotos |
| 12 | Cumplido del manifiesto y pago | Empresa | Pago en 5 días hábiles | Cumplido, comprobante de pago |
| 13 | Cierre del comodato o liberación de la garantía | Generador / naviera | Seguimiento de cobros de *detention* y daños | Liquidación de la naviera |

## Reglas específicas

- **RN-060:** carga con DTA → solo empresas inscritas ante la DIAN como transportador bajo control aduanero (Decreto 1165 de 2019, art. 113 y siguientes) y vehículo autorizado.
- **RN-061:** el contenedor no se "acepta" en la app sin fotos de las 6 caras, puertas, precinto (número legible) y una nota de daños. Si el precinto no coincide con el BL o la DTA → **alerta roja** y bloqueo del inicio del viaje.
- **RN-062:** el cálculo de días libres y la alerta de *detention* son para el generador y para la empresa. **El costo por la demora del vacío no se descuenta al propietario** si la demora no es imputable a él (Decreto 1017 de 2025: no trasladar costos de la empresa).
- **RN-063:** el viaje de devolución del vacío es un **tramo** del mismo viaje o un viaje separado, según lo pactado. Siempre tiene valor y tiempo registrados.
- **RN-064:** **emparejamiento automático**: al terminar la entrega, la app propone cargas de exportación que necesiten un contenedor vacío del mismo tipo y naviera (reutilización del contenedor, *triangulación*), sujeto a la autorización de la naviera.
