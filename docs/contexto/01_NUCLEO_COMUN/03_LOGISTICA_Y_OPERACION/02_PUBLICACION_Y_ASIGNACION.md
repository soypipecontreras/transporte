# Publicación de cargas y asignación de vehículos

## 1. Datos mínimos de una carga publicada

| Grupo | Campos |
|---|---|
| Ruta | Origen y destino (dirección + geocerca), puntos intermedios, ruta preferida o autorizada |
| Fechas | Ventana de cargue, cita de cargue, fecha límite de entrega, cita de descargue |
| Mercancía | Descripción (obligatoria para el RNDC), naturaleza (general, peligrosa con número UN, refrigerada, extradimensionada, granel), peso, volumen, unidades, empaque, **valor declarado** |
| Vehículo requerido | Configuración (C2, C3, 2S2, 3S2, 3S3…), tipo de carrocería, requisitos (GPS, reefer, carpa, portacontenedor 20/40) |
| Puerto (si aplica) | Contenedor, BL o booking, naviera, terminal, días libres, patio de devolución, DTA sí/no |
| Comercial | Modo (precio fijo / recibir ofertas / asignación directa a favoritos), **flete ofrecido**, forma de pago (contado / plazo con cupo), seguros |
| Documentos | Remesa, orden de cargue, permisos especiales |

## 2. Modos de asignación

| Modo | Descripción | Cuándo usarlo |
|---|---|---|
| **Precio fijo – primero que acepta** | Flete fijo ≥ SICE-TAC; el primer transportista elegible que acepta toma la carga | Rutas comunes, rapidez |
| **Recibir ofertas** | Los transportistas ofertan (nunca por debajo del SICE-TAC, RN-020); el generador elige por precio, calificación y ETA | Rutas especiales |
| **Asignación directa** | El generador asigna a transportistas favoritos o a su flota vinculada | Relaciones de confianza |
| **Recomendación automática** | El algoritmo propone el mejor vehículo según cercanía, retorno, score, documentos y configuración | Optimización de viajes vacíos |

## 3. Algoritmo de emparejamiento (criterios)

1. **Elegibilidad dura** (filtro):
   - Documentos vigentes.
   - Configuración compatible.
   - Habilitaciones especiales (DTA, peligrosas, reefer).
   - Score mínimo.
   - Sin bloqueos de riesgo.
2. **Puntuación:**
   - Distancia al punto de cargue (vacío por recorrer).
   - **Encadenamiento**: el destino de la carga actual coincide con el origen de la siguiente.
   - Calificación y cumplimiento histórico.
   - Precio ofertado.
   - Preferencias del transportista: rutas y zonas de casa.
3. **Equidad:** límite para que ningún actor acapare las cargas 🔧 y rotación para nuevos transportistas bien calificados.

## 4. Lo que el transportista ve antes de aceptar (transparencia, RN-018)

- El flete total y el **valor a pagar** neto, con el desglose de descuentos permitidos (retención, anticipo, póliza si aplica).
- **Fecha estimada de pago** (cumplido + 5 días hábiles).
- Tiempos estimados de cargue y descargue y el **historial de demoras del generador o del puerto**.
- Calificación del generador (puntualidad en el cargue, trato, novedades).
- Peajes estimados y combustible estimado (referencia).
