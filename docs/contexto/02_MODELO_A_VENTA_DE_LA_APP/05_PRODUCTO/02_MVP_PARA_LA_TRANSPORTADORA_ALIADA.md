# MVP para la transportadora aliada (lo mínimo para el piloto con Humadea)

**Objetivo:** que en **8 a 10 semanas de desarrollo** una transportadora pueda operar viajes reales del corredor piloto con la app, demostrar el cumplimiento del Decreto 1017 y medir los indicadores del piloto.

**Regla:** si algo no ayuda a medir un indicador del piloto o a cumplir la norma, **no entra en el MVP**.

## 1. Arquitectura base (decidir con el desarrollador)
- **Multi-empresa desde el día 1:** cada transportadora es un *tenant* con sus datos separados. Es indispensable para vender a varias.
- **Panel web** para la transportadora y **app móvil Android** para el camionero (la más usada). La versión iOS va después.
- **Portal web liviano** para el cliente y el destinatario (enlace por WhatsApp).
- **Tabla de parámetros** y **bitácora de auditoría** desde el inicio.
- Marca blanca: diseñar con **temas configurables** (logo y colores) aunque se active después.

## 2. Historias de usuario del MVP (en orden de prioridad)

### Bloque 1: Base (semanas 1-3)
| # | Como… | Quiero… | Para… | RN |
|---|---|---|---|---|
| 1 | Administrador de la transportadora | Crear mi empresa, usuarios y roles (despachador, tesorería, gerencia) | Operar con permisos | — |
| 2 | Despachador | Registrar vehículos, remolques y conductores con sus documentos y vencimientos | Saber quién puede viajar | RN-050, RN-052 |
| 3 | Camionero | Registrarme en la app con cédula, selfie, licencia, placa y cuenta bancaria propia | Recibir cargas y pagos | RN-041, RN-106 |
| 4 | Sistema | Revisar las listas restrictivas en el registro | Cumplir el SARLAFT | RN-170 |
| 5 | Administrador | Configurar parámetros (SMMLV, SICE-TAC de las rutas del piloto, festivos) | Que las reglas calculen bien | — |

### Bloque 2: Despacho y cumplimiento (semanas 3-6)
| # | Como… | Quiero… | Para… | RN |
|---|---|---|---|---|
| 6 | Despachador | Crear un viaje (origen, destino, carga, cliente, fechas, flete y valor a pagar) | Despachar | RN-100 |
| 7 | Sistema | **Bloquear** si el valor a pagar es menor al SICE-TAC | Cumplir la norma | RN-010 |
| 8 | Despachador | Ofrecer el viaje a mis camioneros (todos o favoritos) y que lo acepten desde la app | Asignar sin intermediarios | RN-018 |
| 9 | Camionero | Ver el flete, el valor a pagar, los descuentos y la **fecha de pago** antes de aceptar, y firmar la vinculación transitoria | Decidir con transparencia | RN-018, RN-102 |
| 10 | Despachador | Expedir el **manifiesto en el RNDC** desde la app (web service). Si el RNDC falla, cola y reintento | Formalizar el viaje | RN-001, RN-016 |
| 11 | Camionero | Tener el manifiesto en PDF con QR **sin conexión** | Mostrarlo en la vía | RN-013, RN-025 |

### Bloque 3: Viaje y entrega (semanas 5-8)
| # | Como… | Quiero… | Para… | RN |
|---|---|---|---|---|
| 12 | Camionero | Marcar eventos (llegué, inicio de cargue, salgo, llegué al destino, entregué) con foto y GPS del celular | Registrar tiempos | RN-030 |
| 13 | Sistema | Calcular las **horas logísticas** y el recargo si se pasan de 8 h | Pagar las esperas | RN-031 a RN-033 |
| 14 | Destinatario | Firmar la entrega desde un enlace, con fotos y novedades | Cerrar la entrega | RN-014 |
| 15 | Despachador | Registrar el **cumplido en el RNDC** y ver la alerta del 20 % de pendientes | No quedar bloqueado | RN-016, RN-021 |
| 16 | Generador | Ver el viaje y el ETA por un enlace | Trazabilidad | — |

### Bloque 4: Pago (semanas 7-10)
| # | Como… | Quiero… | Para… | RN |
|---|---|---|---|---|
| 17 | Tesorería | Ver la liquidación automática de cada viaje (valor a pagar, anticipo, retenciones, FOPAT, horas) con solo descuentos permitidos | Pagar bien | RN-043, RN-155 |
| 18 | Tesorería | Lista de pagos que vencen (≤ 5 días hábiles) y **archivo de pago masivo** para el banco | Pagar a tiempo | RN-012, RN-040 |
| 19 | Camionero | Ver "Mis pagos" (por cobrar, fecha, pagado) y descargar el extracto | Confiar | RN-045 |
| 20 | Gerencia | Tablero con los **indicadores del piloto** | Medir | — |

## 3. Fuera del MVP (se hace después del piloto)
- Integración directa por API con bancos (en el MVP basta el archivo de pago masivo).
- Factoring integrado por API (en el piloto se gestiona manualmente con el aliado).
- Módulo de puerto completo (en el MVP se registran la cita y el contenedor como campos del viaje).
- Monitoreo RNDC por el GPS de la empresa (en el MVP se usa el celular; la integración con Mayasoft va en la fase 2).
- Crédito a clientes y scoring.
- Marca blanca publicada en tiendas.
- App iOS, red entre transportadoras e internacional.

## 4. Integraciones mínimas del MVP
| Integración | Forma |
|---|---|
| RNDC | Web service con las credenciales de la transportadora + modo de contingencia |
| Verificación de identidad | Un proveedor (Verifik, Didit u otro) |
| Listas restrictivas | Un proveedor o descarga de las listas ONU y OFAC |
| Mapas y geocercas | Proveedor de mapas |
| Mensajes | WhatsApp Business o SMS para enlaces y OTP |
| Banco | Archivo plano de pagos masivos del banco de la transportadora |

## 5. Definición de "listo" del MVP
- Todas las RN bloqueantes del MVP tienen **prueba automatizada**.
- Se hicieron 10 viajes de prueba en el ambiente de pruebas del RNDC (o con la contingencia).
- La transportadora firmó el acta de aceptación de salida a producción.
