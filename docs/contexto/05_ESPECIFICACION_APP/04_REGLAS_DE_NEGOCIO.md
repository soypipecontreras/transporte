# Catálogo de reglas de negocio (RN)

Fuente única de verdad. Cada regla indica su **tipo**:
- **B** = bloqueante (impide la acción).
- **A** = alerta.
- **C** = cálculo automático.
- **P** = proceso.

Cuando cambie la norma, se actualiza aquí y en los parámetros.

## Despacho, RNDC y precio
| ID | Regla | Tipo | Fuente |
|---|---|---|---|
| RN-001 | Solo un despachador de una empresa habilitada activa expide manifiestos | B | Decreto 1079/2015, 2.2.1.7.3 |
| RN-010 | Bloquear el manifiesto o la asignación si el valor a pagar < costo eficiente del SICE-TAC | B | Decreto 1017/2025, arts. 2 y 12 |
| RN-011 | Los servicios adicionales van en un campo separado y no se descuentan del valor a pagar | B | Decreto 1017/2025, art. 10 |
| RN-012 | Fecha de pago al titular = cumplido + 5 días hábiles (calendario de festivos de Colombia) | C | Decreto 1017/2025, art. 10 |
| RN-013 | El manifiesto está disponible sin conexión para el conductor (QR + PDF) | P | Operativa |
| RN-014 | La entrega exige firma del destinatario, fotos, geolocalización, hora y novedades | B | Evidencia |
| RN-015 | Historial inmutable de los documentos y cambios (conservación ≥ 10 años) | P | C. Co. art. 60 |
| RN-016 | Conciliación diaria app ↔ RNDC | P | Control |
| RN-017 | El titular descarga su manifiesto y cumplido certificados cuando quiera | P | Mérito ejecutivo |
| RN-018 | Transparencia: el transportista ve el flete, el valor a pagar, los descuentos y la fecha de pago antes de aceptar | P | Misión |
| RN-019 | Sugerencia de precio = SICE-TAC + rango de mercado | C | Producto |
| RN-020 | Ninguna oferta del transportista por debajo del SICE-TAC | B | Decreto 1017/2025 |
| RN-021 | Alerta temprana si los cumplidos pendientes se acercan al **20 %** de los manifiestos de los últimos 30 días (al superarlo, el RNDC bloquea nuevos manifiestos). Alertas al 10 % y al 15 % 🔧 | A | Res. 20263040016075/2026, art. 9 |
| RN-022 | Monitoreo de los otros controles del 20 % del RNDC (remesas sin dato del flete, facturas sin aceptar después de 5 días hábiles) | A | Res. 20263040016075/2026, Manual |
| RN-023 | Recordatorio al generador para registrar el flete y **aceptar la factura en el RNDC** dentro de los 5 días hábiles | A/P | Res. 20263040016075/2026, Manual 5.4 |
| RN-024 | Reporte de los **tiempos reales** de cargue y descargue al RNDC por medio de un sistema de monitoreo de flota (obligatorio desde el 30-11-2025) | B | Res. 20263040016075/2026, art. 18.4 |
| RN-025 | PDF del manifiesto y del cumplido en el **formato estándar** del Ministerio, con QR de seguridad | B | Res. 20263040016075/2026, arts. 11 y 19 |

## Tiempos logísticos
| ID | Regla | Tipo | Fuente |
|---|---|---|---|
| RN-030 | Cronómetro de cargue y descargue por geocerca más confirmación manual | C | Decreto 1017/2025, art. 15 |
| RN-031 | El conteo inicia desde la cita (si llegó antes) o desde la llegada dentro de la ventana | C | Decreto 1017/2025, art. 15 |
| RN-032 | Exceso sobre 8 h: 3 SMLDV/h (articulado) o 2 SMLDV/h (rígido), sumado al valor a pagar y facturado al generador | C | Decreto 1017/2025, art. 15 |
| RN-033 | Los acuerdos entre generador y empresa no reducen lo que recibe el propietario | B | Decreto 1017/2025, art. 15 |

## Pagos
| ID | Regla | Tipo | Fuente |
|---|---|---|---|
| RN-040 | El pago al propietario es ≤ 5 días hábiles después del cumplido y no depende del pago del generador | B/C | Decreto 1017/2025, arts. 10 y 14 |
| RN-041 | Pago solo a una cuenta del titular verificado; el cambio de cuenta exige biometría y una espera de 48 h | B | Antifraude |
| RN-042 | Anticipo ≤ % máximo 🔧, registrado en el manifiesto | B | Política |
| RN-043 | Catálogo cerrado de descuentos permitidos | B | Decreto 1017/2025, arts. 6 y 16 |
| RN-044 | Interés de mora automático a la tasa máxima legal si se paga tarde | C | C. Co. art. 884 |
| RN-045 | Extracto discriminado al propietario por viaje y mensual | P | Decreto 1017/2025, art. 6 |

## Vehículos, conductores y carga
| ID | Regla | Tipo | Fuente |
|---|---|---|---|
| RN-050 | Vehículo y conductor válidos (documentos vigentes) para tomar una carga | B | Normativa de tránsito |
| RN-051 | Revalidación (RUNT) antes de cada manifiesto | B | Control |
| RN-052 | Alertas de vencimiento a 30, 15 y 5 días | A | Control |
| RN-053 | Soporte PILA mensual de los conductores | A/B 🔧 | Seguridad social |
| RN-055 | El peso declarado no supera el PBV de la configuración | B | Res. 4100/2004; Decreto 1017/2025, art. 16 |
| RN-056 | La carga extradimensionada exige un permiso vigente y la ruta coincidente | B | INVÍAS / autoridad vial |

## Puerto y aduana
| ID | Regla | Tipo | Fuente |
|---|---|---|---|
| RN-060 | Carga con DTA solo para un transportador inscrito ante la DIAN y un vehículo autorizado | B | Decreto 1165/2019, art. 113 |
| RN-061 | Inspección del contenedor (6 caras, puertas, precinto). Un precinto distinto bloquea el viaje | B | Seguridad |
| RN-062 | El *detention* no imputable no se traslada al propietario | B | Decreto 1017/2025, art. 6 |
| RN-063 | El tramo de devolución del vacío siempre tiene valor y tiempo | B | Misión |
| RN-064 | Emparejamiento importación → exportación (reutilización del contenedor) | P | Producto |
| RN-065 | Alerta si el ETA es posterior al *cut-off* menos el margen | A | Operativa |
| RN-066 | Cadena de custodia del precinto | P | Seguridad / OEA |
| RN-067 | Ofrecer el retorno automáticamente | P | Producto |
| RN-068 | Alerta por el plazo de tránsito de la DTA | A | DIAN |
| RN-070 | Registro y reserva de la cita en la terminal | P | Operativa |
| RN-071 | Enturnamiento virtual en un parqueadero aliado | P | Producto |
| RN-072 | No despachar hacia el puerto sin cita confirmada (salvo excepción) | B | Operativa |
| RN-073 | Reporte con evidencia del incumplimiento de la terminal | P | Supertransporte |
| RN-074 | Alertas de días libres del contenedor | A | Naviera |
| RN-075 | Evidencia del intento fallido de devolución del vacío | P | Disputa |
| RN-076 | Comparación de las fotos del EIR de salida y de entrada | P | Disputa |

## Graneles, peligrosas, refrigerada
| ID | Regla | Tipo |
|---|---|---|
| RN-080 | Tiquetes de báscula de origen y destino | B |
| RN-081 | Merma tolerada 🔧; faltante mayor → novedad, sin descuento automático | B |
| RN-082 | Carpado con foto | B |
| RN-083 | Bloqueo por sobrepeso | B |
| RN-085 | Carga UN solo para un conductor y vehículo certificados | B |
| RN-086 | Matriz de segregación de peligrosas | B |
| RN-087 | Alerta de temperatura fuera de rango (reefer) | A |

## Seguros
| ID | Regla | Tipo |
|---|---|---|
| RN-090 | Valor declarado ≤ límite asegurado disponible | B |
| RN-091 | Seguro por viaje opcional | P |
| RN-092 | Notificación del siniestro a la aseguradora con su expediente | P |

## Ciclo del viaje
| ID | Regla | Tipo |
|---|---|---|
| RN-100 | Requisitos para publicar (KYB; cupo si es a plazo) | B |
| RN-101 | Validaciones para asignar | B |
| RN-102 | Vinculación (transitoria o permanente) firmada antes del manifiesto | B |
| RN-103 | Lista de chequeo preoperacional antes de salir | B |
| RN-104 | Cierre con calificaciones y sin disputas | P |
| RN-105 | Una disputa del generador no frena el pago al transportista sin una novedad imputable a él | B |
| RN-106 | Inicio biométrico del viaje por el conductor | B |

## Facturación, conciliación, cumplimiento
| ID | Regla | Tipo |
|---|---|---|
| RN-150 | Factura electrónica automática desde el cumplido | C |
| RN-151 | Seguimiento de la aceptación en RADIAN; sin aceptación no hay factoring | B |
| RN-160 | Conciliación diaria en 4 vías (app, RNDC, DIAN, banco) | P |
| RN-161 | Doble aprobación en pagos manuales y cambios críticos | B |
| RN-170 | Coincidencia en una lista vinculante → bloqueo inmediato y caso para el oficial de cumplimiento | B |
| RN-171 | Debida diligencia intensificada en corredores, países y mercancías de riesgo | P |
| RN-180 | Calendario de obligaciones normativas con alertas | A |

## Crédito
| ID | Regla | Tipo |
|---|---|---|
| RN-200 | Publicar "a plazo" exige un cupo disponible ≥ el flete | B |
| RN-201 | Plazo máximo según el tamaño de las partes (Ley 2024 de 2020) | B |
| RN-202 | Tasas ≤ tasa de usura vigente 🔧 | B |
| RN-203 | Aviso 20 días antes del reporte negativo (Ley 1266) | P |
| RN-204 | Cobranza en los horarios y la frecuencia de la Ley 2300 de 2023 | B |
| RN-205 | Congelamiento del cupo por disparadores (mora, insolvencia, listas, bust-out) | B |
| RN-206 | Crecimiento del cupo ≤ 50 %/mes 🔧 | B |

## Internacional
| ID | Regla | Tipo |
|---|---|---|
| RN-300 | Viaje internacional solo con permiso originario y vehículos habilitados para el país | B |
| RN-301 | Generación de la CPIC | C |
| RN-302 | No se inicia el viaje sin el MCI/DTAI aceptado | B |
| RN-303 | Multimoneda y régimen cambiario | P |
| RN-304 | Viaje a **Venezuela**: solo empresas con el **Documento de Idoneidad** (Circular 0547 de 2025), el permiso complementario del INTT, vehículos habilitados y una póliza de RC internacional por vehículo | B |

## Tributario
| ID | Regla | Tipo |
|---|---|---|
| RN-155 | Retención FOPAT del 0,1 % sobre la base parametrizada (valor a pagar) en vehículos con PBV > 10,5 t al aceptarse el cumplido; liquidación mensual para el F490 concepto 81 | C |
