# Implementación en una transportadora (plan estándar de 4 semanas)

Este plan se repite con cada cliente nuevo. Con Humadea será la primera vez; se documentan los aprendizajes para mejorarlo.

## Roles
| Plataforma | Transportadora |
|---|---|
| Líder de implementación (uno de los fundadores al inicio) | **Líder del proyecto** (jefe de operaciones) |
| Desarrollador de soporte | Despachadores del corredor piloto |
| — | Tesorería / contabilidad |
| — | Responsable de TI (credenciales RNDC, GPS) |

## Semana 1: Preparación
- [ ] Reunión de arranque: alcance, corredor, indicadores, fechas.
- [ ] **Línea base:** días de pago actuales, tiempos de espera, viajes vacíos, costo de intermediarios. Se registra en el informe del piloto.
- [ ] Firmas: contrato o carta del piloto, **acuerdo de tratamiento de datos**.
- [ ] La transportadora entrega:
  - [ ] Credenciales del RNDC (para el servicio web) en canal seguro.
  - [ ] Listado de vehículos, conductores y propietarios del corredor.
  - [ ] Clientes y destinatarios del piloto.
  - [ ] Rutas con su SICE-TAC.
  - [ ] Formato del archivo de pagos de su banco.
  - [ ] Catálogo de descuentos permitidos (anticipos, retenciones).

## Semana 2: Configuración
- [ ] Crear la empresa, los usuarios y los roles.
- [ ] Cargar parámetros (rutas, SICE-TAC, festivos, retenciones, FOPAT).
- [ ] Cargar la flota y los documentos; correr las validaciones y listar lo vencido.
- [ ] Probar la conexión con el RNDC (consulta y un registro de prueba).
- [ ] Configurar plantillas de mensajes (WhatsApp/SMS) y, si aplica, la marca.

## Semana 3: Capacitación y pruebas
- [ ] Capacitación a despachadores (2 h) y a tesorería (1 h).
- [ ] **Jornada de registro de camioneros** en el patio o la sede: instalar la app, verificar identidad y cuenta. Llevar un instructivo de una página y un video corto.
- [ ] 5 a 10 viajes de prueba completos (de la publicación al pago simulado).
- [ ] Ajustes.

## Semana 4: Salida a producción
- [ ] **Acta de salida a producción** firmada.
- [ ] Primeros viajes reales con acompañamiento diario.
- [ ] Reunión de seguimiento al final de la semana.

## Después: seguimiento del piloto
- Reunión **quincenal** con indicadores.
- Encuesta a camioneros en el mes 1 y en el mes 3.
- **Informe final y carta de resultados** en la semana 12.

## Material de capacitación que hay que producir
| Material | Para | Formato |
|---|---|---|
| Instructivo "Cómo tomar un viaje y cobrar" | Camioneros | 1 página + video de 2 minutos |
| Manual del despachador | Despachadores | PDF de 10 páginas |
| Manual de tesorería (liquidación, pagos, descuentos) | Tesorería | PDF |
| Preguntas frecuentes | Todos | En la app |
