# Fraudes, mafias e intermediación ilegal en el sector

Mapa de amenazas que la app debe neutralizar. Para cada una se indica el control que aplica (detalle en `02_CONTROLES_EN_LA_APP.md`).

## 1. Contra el transportista

| Práctica | Descripción | Control |
|---|---|---|
| Pago por debajo del SICE-TAC | "Si no le sirve, hay otro que lo hace" | RN-010, RN-020: bloqueo |
| Descuentos ilegales | Cobro por "estudio de seguridad", "póliza", "papelería" o "afiliación" en cada viaje | RN-043: catálogo cerrado de descuentos |
| Pago a 60-90 días o nunca | Retención informal del dinero | RN-040: pago automático en 5 días hábiles; mérito ejecutivo |
| Comisionistas o "jaladores" | Cobran al camionero por conseguirle la carga o el turno en el puerto | Asignación en la app sin costo para el transportista; citas digitales |
| **Venta de manifiestos** | Empresa habilitada que "presta" su habilitación por un pago, sin operar ni responder | Trazabilidad completa y vinculación formal; la empresa responde en la app |
| Préstamos "gota a gota" | Financiación informal usurera para combustible o reparaciones | Anticipos y créditos formales |

## 2. Contra el generador

| Práctica | Descripción | Control |
|---|---|---|
| **Hurto de mercancía por transportista falso** | Se suplanta a un conductor o a una empresa (placas clonadas, documentos falsos) para robar la carga | Validación por RUNT y biometría del conductor al inicio del viaje; foto del vehículo comparada con la placa; GPS obligatorio |
| **Robo concertado** ("auto-hurto") | El conductor participa en el robo | Score y antecedentes; rutas y paradas autorizadas; alertas de desvío o detención; botón de pánico; análisis de patrones |
| Contaminación de carga (estupefacientes) | Se introduce droga en el contenedor o la carga | Cadena de custodia del precinto; fotos; OEA/BASC; protocolo con la Policía |
| Faltantes "hormiga" | Sustracción parcial | Pesajes origen-destino, precintos, conteos |
| Sobreprecios por intermediario | El generador paga mucho más de lo que llega al camionero | Transparencia flete / valor a pagar |

## 3. Contra la plataforma o el financiador

| Práctica | Descripción | Control |
|---|---|---|
| **Empresa de fachada** que pide crédito | Bust-out: paga bien un tiempo, llena el cupo y desaparece | Filtros de crédito en 5 capas; escalera de cupo; seguro de crédito |
| **Suplantación de un generador real** | Dominio parecido, documentos alterados | Validación con la empresa real por un canal independiente |
| **Doble cesión de facturas** (vender la misma factura a dos factores) | Fraude al factoring | RADIAN: el endoso registrado es único; la app solo permite factoring de facturas registradas |
| Facturas o cumplidos falsos | Viajes que no existieron | Cada factura nace de un viaje con GPS y cumplido del RNDC |
| Cambio de cuenta bancaria (*account takeover*) | Desvío del pago al camionero | RN-041: titularidad + biometría + espera de 48 h |
| Lavado de activos | Fletes ficticios o sobrevalorados para mover dinero | SARLAFT; alertas por fletes atípicos frente al SICE-TAC o el mercado; operaciones fraccionadas |

## 4. En puertos
- Cobros irregulares para "conseguir cita" o "pasar adelante" en la fila → citas digitales y reportes a la Supertransporte (RN-073).
- Patios que no reciben vacíos y cobros de *detention* injustos → evidencia (RN-075).
