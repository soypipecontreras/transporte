# RNDC: manifiesto electrónico de carga y cumplido

## 1. Qué es

El **Registro Nacional de Despachos de Carga (RNDC)** es el sistema del Ministerio de Transporte donde la empresa habilitada registra cada despacho. Hoy funciona como **portal web y servicio web (XML)** para integración entre sistemas.

✅ **Norma vigente (actualizado en oct. 2026):** **Resolución 20263040016075 del 29 de abril de 2026**. Unifica toda la normativa del RNDC y trae el **Manual de operación (Anexo 1)**. Copia en `07_FUENTES/DOCUMENTOS_OFICIALES/`.
- **Canales:** interoperabilidad (web service), plataforma web, apps móviles del Ministerio y archivo plano.
- **Obligados:** empresas, **generadores**, titulares, contratación directa y puertos (enturnamiento, módulo INSIDE).
- **Rol opcional "Empresa de Monitoreo de Flota":** reporta la ubicación y los **tiempos reales**, obligatorios por monitoreo desde el 30 de noviembre de 2025.
- **Control del 20 %:** si los cumplidos pendientes superan el 20 % de los manifiestos de los últimos 30 días, **no se pueden expedir nuevos manifiestos**.
- **Tipos de manifiesto:** varios viajes en un día, multiparadas, ida y regreso, municipal y general.
- **Formatos estándar** del manifiesto y del cumplido con **QR de seguridad**.
- **El generador** registra el flete y **acepta la factura en el RNDC** dentro de los 5 días hábiles.
- **El titular** puede aceptar el manifiesto y aceptar o rechazar el cumplido.
- Resumen completo en `07_FUENTES/02_ACTUALIZACION_INVESTIGACION_OCT_2026.md`, sección 3.

**Decisión de arquitectura:** la app implementa un `AdaptadorRNDC` con una interfaz única (web service + archivo plano de contingencia), preparado para futuras versiones. Ver `05_ESPECIFICACION_APP/06_INTEGRACIONES.md`.

## 2. Secuencia típica de registros

| # | Registro | Quién | Cuándo | Datos clave |
|---|---|---|---|---|
| 1 | Terceros | Empresa | Antes del despacho | Generador, destinatario, propietario, tenedor, conductor |
| 2 | Vehículo (y remolque) | Empresa | Antes del despacho | Placa, configuración, propietario/tenedor |
| 3 | **Información de carga / remesa** | Empresa (con datos del generador) | Al aceptar la carga | Mercancía, peso, empaque, origen-destino, citas de cargue y descargue |
| 4 | **Manifiesto electrónico** | Empresa | Antes de iniciar el viaje | Remesas, vehículo, conductor, **flete, valor a pagar (≥ SICE-TAC), anticipo, retenciones, fecha de pago** |
| 5 | Tiempos logísticos | Empresa | Cargue y descargue | Llegada, inicio, fin |
| 6 | **Cumplido de remesa** | Empresa | Al entregar | Cantidad entregada, novedades, horas |
| 7 | **Cumplido del manifiesto** | Empresa | Al cerrar el viaje | Valores finales, descuentos permitidos → **valor a pagar final** |
| 8 | Anulaciones o correcciones | Empresa | Por excepción | Motivo, con trazabilidad |

## 3. Reglas que la app debe cumplir

- **RN-001:** solo un usuario con rol "Despachador" de una **empresa habilitada activa** puede expedir manifiestos.
- **RN-010:** antes de enviar el manifiesto, la app calcula o consulta el SICE-TAC de la ruta y la configuración. Si `valor_a_pagar < costo_eficiente`, **bloquea** el manifiesto y muestra la diferencia.
- **RN-011:** los servicios adicionales van en un campo separado y **no restan** del valor a pagar.
- **RN-012:** la fecha de pago se calcula automáticamente como `fecha_cumplido + 5 días hábiles`, usando el calendario de festivos de Colombia 🔧.
- **RN-013:** el conductor siempre tiene el manifiesto disponible en la app, **también sin conexión**, con código QR y PDF.
- **RN-014:** el cumplido exige evidencias: firma del destinatario, fotos, geolocalización y hora. Las novedades (faltantes, averías) se documentan antes de cerrar.
- **RN-015:** se conserva todo el historial: el manifiesto, cada cambio, quién lo hizo y cuándo. ⚠️ Los plazos de conservación son de al menos 10 años para documentos comerciales (C. Co. art. 60). Se recomienda conservar todo lo financiero por 10 años.
- **RN-016:** se concilia a diario lo registrado en la app con lo aceptado por el RNDC (número de radicado).

## 4. Mérito ejecutivo: valor para el camionero

Con el manifiesto y el cumplido expedidos, el titular tiene un **título para cobrar judicialmente**. La app debe permitirle **descargar su manifiesto y cumplido certificados** en cualquier momento (RN-017). Es una herramienta directa contra el no pago.
